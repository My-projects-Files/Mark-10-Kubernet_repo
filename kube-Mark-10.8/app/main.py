import os
import time

def read_db_credentials(path):
    with open(path, 'r') as f:
        lines = f.read().splitlines()
        creds = dict(line.split('=') for line in lines if '=' in line)
        return creds

while True:
    try:
        creds = read_db_credentials(os.environ['DB_CREDENTIALS_FILE'])
        print("Username:", creds['username'])
        print("Password:", creds['password'])
    except Exception as e:
        print("Waiting for Vault Agent to write credentials...")
    time.sleep(5)
