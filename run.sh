#!/bin/bash

set -e

ADMIN_PASS=${ADMIN_PASS:-secret}
CH_PWFILE="./.admin_pw_changed"

function change_admin_password() {

    echo ""
    echo "=> Changing admin password..."
    /change_admin_pass.expect ${ADMIN_PASS}
    echo "=> Done."
    echo ""
    echo "=> Enabling secure admin..."
    /asadmin_cmd.expect ${ADMIN_PASS} login
    asadmin enable-secure-admin
    echo "=> Done."

    touch $CH_PWFILE

    echo "========================================================================"
    echo "You can now connect to this Glassfish server using:"
    echo ""
    echo "     admin:$ADMIN_PASS"
    echo ""
    echo "Please remember to change the above password as soon as possible!"
    echo "========================================================================"
    
}


function create_javadb(){
    echo "login"
    /asadmin_cmd.expect ${ADMIN_PASS} login
    echo "creating java connection-pool wed_pool"
    asadmin create-jdbc-connection-pool \
        --datasourceclassname org.apache.derby.jdbc.ClientDataSource \
        --restype javax.sql.DataSource \
        --property portNumber=1527:password=app:user=app:serverName=localhost:databaseName=wedding-site-db:connectionAttributes=\;create\\=true wed_pool

    echo "creating java resource wedding-site-db"
    asadmin create-jdbc-resource --connectionpoolid wed_pool jdbc/wedding-site-db
    echo done
}

if [[ ! -f ${CH_PWFILE} ]]; then

    echo "=> Setting up the container for the first time..."
    asadmin start-domain
    change_admin_password
    create_javadb
    asadmin stop-domain
    echo "=> Done."
fi

echo "=> Starting the glassfish server..."
asadmin start-database
asadmin start-domain -w
echo "=> Done."
