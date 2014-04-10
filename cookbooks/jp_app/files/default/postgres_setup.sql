-- This is an idempotent script to set up the postgres database(s) for just-pikd
-- It should evolve over time so that it can always be run to get up to the latest version

-- create jp_readwrite database user if it doesn't exist
DO
$body$
BEGIN
   IF NOT EXISTS (
      SELECT *
      FROM   pg_catalog.pg_user
      WHERE  usename = 'jp_readwrite') THEN

      CREATE ROLE jp_readwrite LOGIN PASSWORD 'justpikd';
   END IF;
END
$body$
;

-- create jp_product database if it doesn't exist
-- need dblink since you can't technically create a DB inside a pgplsql block
CREATE EXTENSION IF NOT EXISTS dblink;
DO
$do$
BEGIN

IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'product') THEN
   SELECT dblink_exec('dbname=postgres', 'CREATE DATABASE product');
END IF;

END
$do$
;

GRANT CONNECT, TEMPORARY ON DATABASE product to jp_readwrite;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
ON ALL TABLES IN SCHEMA public to jp_readwrite;
