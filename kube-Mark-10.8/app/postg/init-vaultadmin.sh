#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username postgres <<-EOSQL
  CREATE ROLE vaultadmin WITH LOGIN SUPERUSER PASSWORD 'vault-admin-1234';
EOSQL

