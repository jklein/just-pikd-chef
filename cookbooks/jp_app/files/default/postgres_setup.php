<?php
$db_conn = get_connection("postgres");
var_dump($db_conn);
var_dump(pg_version($db_conn));

//create jp_readwrite user
if (!has_results($db_conn, "SELECT 1 FROM pg_catalog.pg_user WHERE usename = 'jp_readwrite';")) {
    pg_query($db_conn, "CREATE ROLE jp_readwrite LOGIN PASSWORD 'justpikd';");
}

//create product database
if (!has_results($db_conn, "SELECT 1 FROM pg_database WHERE datname = 'product';")) {
    pg_query($db_conn, "CREATE DATABASE product;");
    pg_query($db_conn, "GRANT CONNECT, TEMPORARY ON DATABASE product to jp_readwrite;");
    $product_conn = get_connection("product");
}

//get connection again even if we already have one for product, no biggie
$product_conn = get_connection("product");
if (!has_results($product_conn, "select 1 from pg_type where typname = 'measurement_unit';")) {
    pg_query(
        $product_conn,
        "CREATE TYPE measurement_unit
        AS ENUM ('fl oz', 'oz', 'sq ft', 'lbs', 'count');"
    );
}

if (!has_results($product_conn, "select 1 from pg_type where typname = 'temperature_zone';")) {
    pg_query(
        $product_conn,
        "CREATE TYPE temperature_zone
        AS ENUM ('frozen', 'cold', 'fresh', 'dry');"
    );
}

if (!has_results($product_conn, "select 1 from information_schema.tables where table_name = 'products';")) {
    $sql = "
    create table products (
    product_id serial primary key,
    name varchar(255) not null,
    temperature_zone temperature_zone not null,
    manufacturer_id int not null, --need to make a manufacturer for any kind of supplier including a farmer, etc. who gives us produce
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
    ";
    pg_query($product_conn, $sql);
}

//grant permissions, has to be done after tables are created
pg_query($product_conn, "GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA public to jp_readwrite;");

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
