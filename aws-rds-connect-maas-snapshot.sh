#!/bin/bash

case $AWS_PROFILE in
    cloud-prod)
        SECRET="arn:aws:secretsmanager:eu-central-1:435571809706:secret:rds/prod/aurora-monitoring-maasdbtest-KI8u3z"
        ;;
    cloud-int)
        SECRET="arn:aws:secretsmanager:eu-central-1:413397719283:secret:rds/int/aurora-paas-maas-int-5ZYT5E"
        ;;
    *)
        echo -n "INVALID AWS_PROFILE = ${AWS_PROFILE}"
        exit 1
        ;;
esac
echo "$SECRET"

SS=$(aws secretsmanager get-secret-value --secret-id $SECRET | jq -r | jq .SecretString | jq -r)

PGHOST=$(echo $SS | jq -r ".host")
PGUSER=$(echo $SS | jq -r ".username")
PGPASSWORD=$(echo $SS | jq -r ".password")

#docker exec -it pgadmin4 /usr/local/pgsql-12/psql "host=$RDSHOST port=5432 sslmode=verify-full sslrootcert=rds-combined-ca-bundle.pem dbname=postgres user=$USERNAME password=$PASSWORD"
cat <<-EOF
echo "SET search_path TO core;"
\x   - extend view
\l   - show databases
\c        - switch to database
\dt       - show tables
\d+ table - table details

\dn  - List of schemas
SET schema 'core';

Save to FILE
\o monitoringdb-checks-out.txt

EOF

psql "host=$PGHOST port=5432 sslmode=verify-full sslrootcert=${HOME}/rds-combined-ca-bundle.pem dbname=monitoringdb user=$PGUSER password=$PGPASSWORD"
