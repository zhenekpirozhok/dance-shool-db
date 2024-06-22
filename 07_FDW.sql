-- Step 1: Create the Foreign Data Wrapper and Server
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE SERVER dance_school_server
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host 'localhost', dbname 'dance_school', port '5432');

CREATE USER MAPPING FOR CURRENT_USER
    SERVER dance_school_server
    OPTIONS (user 'postgres', password 'password');

-- Step 2: Create the Schema for Staging Tables
CREATE SCHEMA IF NOT EXISTS staging;

-- Step 3: Import the Foreign Schema
IMPORT FOREIGN SCHEMA public
FROM SERVER dance_school_server
INTO staging;
