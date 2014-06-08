<?php
$db_conn = get_connection("postgres");

//create jp_readwrite user
if (!has_results($db_conn, "SELECT 1 FROM pg_catalog.pg_user WHERE usename = 'jp_readwrite';")) {
    pg_query($db_conn, "CREATE ROLE jp_readwrite LOGIN PASSWORD 'justpikd';");
}


$databases = [
    'product',
    'customer',
];

$connections = [];

// Create all databases
foreach ($databases as $database) {
    if (!has_results($db_conn, "SELECT 1 FROM pg_database WHERE datname = '" . $database . "';")) {
        pg_query($db_conn, "CREATE DATABASE " . $database . ";");
        pg_query($db_conn, "GRANT CONNECT, TEMPORARY ON DATABASE " . $database . " to jp_readwrite;");
    }
    $connections[$database] = get_connection($database);
}

// load data only if DB is empty
if (!has_results($connections['product'], "select 1 from information_schema.tables where table_schema = 'public';")) {
    /* Some notes:
    we should update this to use a pgpass file instead of the hard coded, plain text password ideally

    The dump is created with this command (via vagrant ssh):
    pg_dump -h localhost -U postgres -d product -W -Fc  > /usr/share/nginx/html/data/product.dump

    I found this didn't work when using the --clean option.
    Also didn't use --create because I don't want DB permissions set
    above to be lost.
    */
    putenv("PGPASSWORD=justpikd");
    exec('/usr/bin/pg_restore -h localhost -U postgres -d product -Fc < /usr/share/nginx/html/data/product.dump');
}

$customer_sql = <<<'Customers'
CREATE TABLE customers (
  customer_id serial primary key,
  email varchar(255) NOT NULL UNIQUE,
  password varchar(255) NOT NULL,
  permissions text,
  activated boolean NOT NULL DEFAULT FALSE,
  activation_code varchar(255) DEFAULT NULL,
  activated_at timestamp DEFAULT NULL,
  last_login timestamp DEFAULT NULL,
  persist_code varchar(255) DEFAULT NULL,
  reset_password_code varchar(255) DEFAULT NULL,
  first_name varchar(255) DEFAULT NULL,
  last_name varchar(255) DEFAULT NULL,
  created_at timestamp NOT NULL DEFAULT now(),
  updated_at timestamp NOT NULL DEFAULT now()
);
Customers;
maybe_create_table($connections['customer'], 'customers', $customer_sql);


//grant permissions, has to be done after tables are created and we just do this every time because why not
$grant = "GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA public to jp_readwrite;";
foreach ($databases as $database) {
    pg_query($connections[$database], $grant);
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

function maybe_create_type($connection, $name, $values) {
    if (!has_results($connection, "select 1 from pg_type where typname = '" . $name . "';")) {
        pg_query(
            $connection,
            "CREATE TYPE " . $name . " AS ENUM ('" . implode("','", $values) . "');"
        );
    }
}

function maybe_create_table($connection, $table_name, $sql) {
    if (!has_results($connection, "select 1 from information_schema.tables where table_name = '" . $table_name . "';")) {
        pg_query($connection, $sql);
    }
}
