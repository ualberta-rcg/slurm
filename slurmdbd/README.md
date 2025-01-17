## **Slurmdbd Docker Image**
A customizable Docker image for running the Slurm Database Daemon (`slurmdbd`) with support for mounting configuration files and Munge authentication.

### **Image**
Docker Hub: [rkhoja/slurm:slurmdbd](https://hub.docker.com/r/rkhoja/slurm)

---

### **Environment Variables**

You can customize the `slurmdbd` configuration by setting the following environment variables. Default values are provided for most variables:

| Variable                  | Default                     | Description                                                                 |
|---------------------------|-----------------------------|-----------------------------------------------------------------------------|
| `AUTH_TYPE`               | `auth/munge`               | Authentication method for Slurm. Typically `auth/munge`.                   |
| `DBD_HOST`                | `localhost`                | Hostname for the Slurm Database Daemon (`slurmdbd`).                       |
| `DBD_PORT`                | `6819`                     | Port on which `slurmdbd` listens.                                          |
| `STORAGE_TYPE`            | `accounting_storage/mysql` | Type of accounting storage backend (e.g., `mysql`, `postgresql`).          |
| `STORAGE_HOST`            | `localhost`                | Hostname or IP of the database server.                                     |
| `STORAGE_PORT`            | `3306`                     | Port for the database server.                                              |
| `STORAGE_USER`            | `slurm`                    | Username for the database connection.                                      |
| `STORAGE_PASS`            | `password`                 | Password for the database user.                                            |
| `STORAGE_LOC`             | `slurm_acct_db`            | Database name for Slurm accounting.                                        |
| `LOG_FILE`                | `/var/log/slurm/slurm-dbd.log` | Path to the `slurmdbd` log file.                                          |
| `PID_FILE`                | `/var/run/slurmdbd.pid`    | Path to the `slurmdbd` PID file.                                           |
| `SLURM_USER`              | `slurm`                    | User under which `slurmdbd` runs.                                          |
| `DEBUG_LEVEL`             | `debug`                    | Log verbosity level (`quiet`, `info`, `debug`).                            |
| `ACCOUNTING_STORAGE_ENFORCE` | *Optional*              | Additional accounting storage enforcement settings (e.g., `none`).         |
| `AUTH_ALT_TYPES`          | *Optional*                 | Alternative authentication methods (`auth/jwt`, etc.).                     |

---

### **Prerequisites**

1. **Munge Key**:
   - A valid Munge key must be mounted into the container at `/etc/munge/munge.key`.
   - You can generate this key on your host system:
     ```bash
     dd if=/dev/urandom bs=1 count=1024 > /etc/munge/munge.key
     chmod 400 /etc/munge/munge.key
     chown munge:munge /etc/munge/munge.key
     ```

2. **Database Configuration**:
   - Ensure your database server (e.g., MySQL, MariaDB, or PostgreSQL) is accessible from the container and configured with the necessary schema for Slurm.

---

### **Usage**

#### **Run the Container**
To run the `slurmdbd` container with basic configuration:
```bash
docker run -d \
  --name slurmdbd \
  -e STORAGE_HOST=your-database-host \
  -e STORAGE_USER=your-database-user \
  -e STORAGE_PASS=your-database-password \
  -e STORAGE_LOC=your-database-name \
  -e AUTH_TYPE=auth/munge \
  -v /path/to/munge.key:/etc/munge/munge.key:ro \
  rkhoja/slurm:slurmdbd
```

---

### **Volumes**

- **Munge Key**:
  - The Munge key must be mounted to `/etc/munge/munge.key`.

- **Logs** (Optional):
  - To persist logs, you can mount the log directory, but you need to update the LOG_FILE:
    ```bash
    -v /path/to/logs:/var/log/slurm
    -e LOG_FILE=/var/log/slurm/slurmdbd.log
    ```

---

### **Verify the Setup**

1. **Check Logs**:
   ```bash
   docker logs slurmdbd
   ```
   Ensure the `slurmdbd` service starts without errors.

2. **Test Database Connectivity**:
   Verify that `slurmdbd` can connect to your database and perform accounting operations.

3. **Confirm Munge**:
   Test Munge authentication from within the container:
   ```bash
   munge -n | unmunge
   ```

---

### **Troubleshooting**

- **Munge Key Issues**:
  Ensure the Munge key is valid, correctly mounted, and has the correct permissions.

- **Database Connection Issues**:
  Check that the database server is reachable and the credentials are correct.

- **Log File Errors**:
  If logs are not being written, verify the `LOG_FILE` path and permissions.

---

### **Contributing**
Contributions and improvements are welcome! Please open an issue or submit a pull request.
