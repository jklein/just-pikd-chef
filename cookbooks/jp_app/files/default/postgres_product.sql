DO
$do$
BEGIN

IF NOT EXISTS (select 1 from pg_type where typname = 'measurement_unit') THEN
  CREATE TYPE measurement_unit
AS ENUM ('fl oz', 'oz', 'sq ft', 'lbs', 'count');
END IF;

IF NOT EXISTS (select 1 from pg_type where typname = 'temperature_zone') THEN
  CREATE TYPE temperature_zone
  AS ENUM ('frozen', 'cold', 'fresh', 'dry');
END IF;

END
$do$
;


create table if not exists products (
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

