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

// Create types if they don't already exist
maybe_create_type($connections['product'], 'measurement_unit', ['fl oz', 'oz', 'sq ft', 'lbs', 'count']);
maybe_create_type($connections['product'], 'temperature_zone', ['frozen', 'cold', 'fresh', 'dry']);

// Create tables
// Note: need to make a manufacturer for any kind of supplier including a farmer, etc. who gives us produce
$product_sql = <<<'Products'
create table products (
    product_id serial primary key,
    name varchar(255) not null,
    temperature_zone temperature_zone not null,
    manufacturer_id int not null,
    list_cost money not null,
    category_id int not null,
    description text,
    units_per_case smallint,
    measurement_unit measurement_unit,
    measurement_value int,
    upc_commodity int,
    upc_vendor int,
    upc_case int,
    upc_item int,
    source_warehouse_id int, -- should this live in another table?
    vendor_name varchar(500),
    length float, --what are the units?
    width float,
    height float,
    cubic_volume float,
    weight float,
    shelf_life_days int
);
Products;
maybe_create_table($connections['product'], 'products', $product_sql);


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
  created_at timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  updated_at timestamp NOT NULL DEFAULT '0000-00-00 00:00:00'
);
Customers;
maybe_create_table($connections['customer'], 'customers', $customer_sql);


//grant permissions, has to be done after tables are created
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
