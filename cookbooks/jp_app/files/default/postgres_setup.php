<?php
$db_conn = get_connection("postgres");

//create jp_readwrite user
if (!has_results($db_conn, "SELECT 1 FROM pg_catalog.pg_user WHERE usename = 'jp_readwrite';")) {
    pg_query($db_conn, "CREATE ROLE jp_readwrite LOGIN PASSWORD 'justpikd';");
}


$databases = [
    'product',
    'customer',
    'hr'
];

$connections = [];

// Create all databases
foreach ($databases as $database) {
    if (!has_results($db_conn, "SELECT 1 FROM pg_database WHERE datname = '" . $database . "';")) {
        pg_query($db_conn, "CREATE DATABASE " . $database . ";");
        pg_query($db_conn, "GRANT CONNECT, TEMPORARY ON DATABASE " . $database . " to jp_readwrite;");
    }
    $connections[$database] = get_connection($database);
    load_data_if_empty($database);
}

//grant permissions, has to be done after tables are created and we just do this every time because why not
$grant = "GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA public to jp_readwrite;";
foreach ($databases as $database) {
    pg_query($connections[$database], $grant);
}

function load_data_if_empty($dbname) {
    if (!has_results($connections[$dbname], "select 1 from information_schema.tables where table_schema = 'public';")) {
        /* Some notes:
        we should update this to use a pgpass file instead of the hard coded, plain text password ideally

        The dump is created with this command (via vagrant ssh):
        pg_dump -h localhost -U postgres -d product -W -Fc  > /usr/share/nginx/html/data/product.dump

        I found this didn't work when using the --clean option.
        Also didn't use --create because I don't want DB permissions set
        above to be lost.
        */
        putenv("PGPASSWORD=justpikd");
        exec("/usr/bin/pg_restore -h localhost -U postgres -d $dbname -Fc < /mnt/database/$dbname.dump");
    }
}

//get a connection to the local postgres instance
function get_connection ($dbname) {
    return pg_connect("host=localhost dbname=$dbname user=postgres password=justpikd");
}

//returns truthy values if the sql query has results, falsy values otherwise
function has_results ($connection, $query) {
    $result=pg_query($connection, $query);
    if (!$result) {
        return false;
    }
    return pg_num_rows($result);
}
