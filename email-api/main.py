from flask import Flask, request, jsonify
import ldap3
import os

app = Flask(__name__)

LDAP_SERVER = os.environ["LDAP_SERVER"]
LDAP_USER = os.environ["LDAP_BIND_DN"]
LDAP_PASS = os.environ["LDAP_PASSWORD"]
LDAP_BASE = os.environ["LDAP_BASE_DN"]
BEARER_TOKEN = os.environ["BEARER_TOKEN"]

@app.route('/email')
def get_email():
    auth_header = request.headers.get('Authorization')
    if not auth_header or not auth_header.startswith("Bearer ") or auth_header.split()[1] != BEARER_TOKEN:
        return jsonify({'error': 'Unauthorized'}), 401

    user = request.args.get('user')
    if not user:
        return jsonify({'error': 'Missing user'}), 400

    server = ldap3.Server(LDAP_SERVER, use_ssl=True)
    conn = ldap3.Connection(server, LDAP_USER, LDAP_PASS, auto_bind=True)

    conn.search(LDAP_BASE, f"(uid={user})", attributes=["ccPrimaryEmail"])
    if conn.entries:
        email = conn.entries[0].ccPrimaryEmail.value
        return jsonify({'email': email})
    return jsonify({'error': 'Not found'}), 404

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
