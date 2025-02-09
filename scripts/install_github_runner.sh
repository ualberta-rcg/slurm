#!/bin/bash

# Stop on Error
set -eE  # same as: `set -o errexit -o errtrace`

# Variables
LOGFILE=/var/log/github_runner_setup.log
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DEBUG=1
STATUS="Initializing"
TIMESTAMP="$( date +%s )"

# Function to collect user input with validation
function get_input() {
    local prompt="$1"
    local default="$2"
    local var
    finish="-1"
    while [ "$finish" = "-1" ]; do
        finish="1"
        read -p "$prompt [$default]: " var
        var=${var:-$default}
        echo
        read -p "You entered: $var [y/n]? " answer

        if [ "$answer" = "" ]; then
            answer=""
        else
            case $answer in
                y | Y | yes | YES ) answer="y";;
                n | N | no | NO ) answer="n"; finish="-1";;
                *) finish="-1";
                   echo -n 'Invalid Response
';;
            esac
        fi
    done
    echo "$var"
}

# Dump Vars Function
function dump_vars {
    if ! ${STATUS+false}; then echo "STATUS = ${STATUS}"; fi
    if ! ${LOGFILE+false}; then echo "LOGFILE = ${LOGFILE}"; fi
    if ! ${SCRIPTDIR+false}; then echo "SCRIPTDIR = ${SCRIPTDIR}"; fi
    if ! ${DEBUG+false}; then echo "DEBUG = ${DEBUG}"; fi
    if ! ${TIMESTAMP+false}; then echo "TIMESTAMP = ${TIMESTAMP}"; fi
    if ! ${GITHUB_REPO+false}; then echo "GITHUB_REPO = ${GITHUB_REPO}"; fi
    if ! ${GITHUB_TOKEN+false}; then echo "GITHUB_TOKEN = ${GITHUB_TOKEN}"; fi
}

# Failure Function
function failure() {
    local lineno=$1
    local msg=$2
    echo ""
    echo -e "\033[0;31mError at Line Number $lineno: '$msg'\033[0m"
    echo ""
    if [[ $DEBUG -eq 1 ]]; then
      dump_vars
    fi
}

# Failure Function Trap
trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

# Check the script is being run as root
STATUS="Check - Script Run as Root user"
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

STATUS="Starting Installation"
echo "$(date "+%FT%T") $STATUS" >> "${LOGFILE}"

# Get GitHub Repo and Token
GITHUB_REPO=$(get_input "Please Enter GitHub Repository URL" "https://github.com/YOUR_ORG/YOUR_REPO" | tr -d '\n\r')
GITHUB_TOKEN=$(get_input "Please Enter GitHub Token" "YOUR_TOKEN" | tr -d '\n\r')

# Create the GitHub Actions User
sudo groupadd --system github-runner || true
sudo useradd --system --gid github-runner --create-home --shell /usr/sbin/nologin --comment "GitHub Actions Runner" github-runner || true

# Ensure the runner directory exists
sudo mkdir -p /opt/actions-runner
sudo chown github-runner:github-runner /opt/actions-runner

# Create the SystemD File
sudo bash -c 'cat > /etc/systemd/system/github-runner.service <<EOF
[Unit]
Description=GitHub Actions Runner
After=network.target

[Service]
Type=simple
User=github-runner
Group=github-runner
WorkingDirectory=/opt/actions-runner
ExecStart=/opt/actions-runner/run.sh
KillMode=process
KillSignal=SIGTERM
TimeoutStopSec=5min
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF'

# Add The GitHub Runner User to Sudo for Commands
sudo bash -c 'cat > /etc/sudoers.d/github-runner <<EOF
github-runner ALL=(ALL) NOPASSWD: /usr/bin/kubectl
github-runner ALL=(ALL) NOPASSWD: /usr/bin/sinfo
github-runner ALL=(ALL) NOPASSWD: /usr/bin/scontrol
EOF'

# Navigate to the runner directory
cd /opt/actions-runner

# Run the config script with variables
STATUS="Configuring GitHub Runner"
sudo -u github-runner ./config.sh --url "$GITHUB_REPO" --token "$GITHUB_TOKEN"

echo "$(date "+%FT%T") GitHub Runner Configured" >> "${LOGFILE}"

# Test Slurm commands
STATUS="Testing Slurm Commands"
sudo -u github-runner sinfo
sudo -u github-runner scontrol show nodes

echo "$(date "+%FT%T") Slurm Commands Tested" >> "${LOGFILE}"

# Reload SystemD and Start the Service
STATUS="Starting GitHub Runner Service"
sudo systemctl daemon-reload
sudo systemctl enable github-runner
sudo systemctl start github-runner

echo "$(date "+%FT%T") GitHub Runner Service Started" >> "${LOGFILE}"

# Verify the service status
STATUS="Verifying GitHub Runner Service"
sudo systemctl status github-runner --no-pager

echo "$(date "+%FT%T") GitHub Runner Setup Completed Successfully" >> "${LOGFILE}"
