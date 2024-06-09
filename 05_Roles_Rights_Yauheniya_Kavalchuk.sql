-- Create roles
CREATE ROLE admin;
CREATE ROLE instructor;
CREATE ROLE front_desk;

-- Grant all privileges on the database to the admin role
GRANT ALL PRIVILEGES ON DATABASE dance_school TO admin;

-- Grant specific privileges to the instructor role
GRANT SELECT, INSERT, UPDATE ON TABLE Classes, ClassSchedules, RoomRentals TO instructor;
GRANT SELECT ON TABLE Customers, Rooms TO instructor;

-- Grant specific privileges to the front desk role
GRANT SELECT, INSERT, UPDATE ON TABLE Customers, CustomerSubscriptions, ClassSchedules TO front_desk;
GRANT SELECT, INSERT ON TABLE RoomRentals TO front_desk;

-- Allow roles to login; admin might also create new roles
ALTER ROLE admin WITH LOGIN CREATEROLE;
ALTER ROLE instructor WITH LOGIN;
ALTER ROLE front_desk WITH LOGIN;

-- Revoke all default privileges
REVOKE ALL ON DATABASE dance_school FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;

-- Restore specific necessary privileges
GRANT SELECT ON TABLE Classes, Customers, Rooms TO PUBLIC;
