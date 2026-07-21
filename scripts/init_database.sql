-- Database: DWh

-- DROP DATABASE IF EXISTS "DWh";

CREATE DATABASE "DWh"
    WITH
    OWNER = pg_database_owner
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_Malaysia.1252'
    LC_CTYPE = 'English_Malaysia.1252'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

	CREATE SCHEMA "bronze";
	CREATE SCHEMA "silver";
	CREATE SCHEMA "gold";
