-- Fact Tables
CREATE TABLE Sales_Fact (
    SalesFactID SERIAL PRIMARY KEY,
    CustomerID INT,
    InstructorID INT,
    ClassID INT,
    RoomID INT,
    SubscriptionID INT,
    ClassScheduleID INT,
    SaleDate DATE,
    Price DECIMAL(10, 2)
);

CREATE TABLE Room_Rental_Fact (
    RoomRentalID SERIAL PRIMARY KEY,
    RoomID INT,
    InstructorID INT,
    RentalDate DATE,
    StartTime TIME,
    EndTime TIME,
    Price DECIMAL(10, 2)
);

-- Dimension Tables
CREATE TABLE Customer_Dim (
    CustomerKey SERIAL PRIMARY KEY,            -- Surrogate key
    CustomerID INT NOT NULL,                   -- Business key (natural key)
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    DateOfBirth DATE,
    Address VARCHAR(255),
    Gender VARCHAR(10),
    JoinDate DATE,
    EffectiveStartDate DATE NOT NULL,          -- Start date of the record's validity
    EffectiveEndDate DATE,                     -- End date of the record's validity (NULL for current records)
    IsCurrent BOOLEAN NOT NULL,                -- Flag to indicate if the record is the current version
    CONSTRAINT unique_customer_business_key UNIQUE (CustomerID, EffectiveStartDate)  -- Unique constraint on business key and start date
);

CREATE TABLE Instructor_Dim (
    InstructorID SERIAL PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    Specialization VARCHAR(100),
    HireDate DATE,
    Rating DECIMAL(2, 1)
);


CREATE TABLE Class_Dim (
    ClassID SERIAL PRIMARY KEY,
    ClassName VARCHAR(100) NOT NULL,
    Description TEXT,
    Level VARCHAR(50),
    Duration INT,
    Price DECIMAL(10, 2),
    Category VARCHAR(50)
);


CREATE TABLE Subscription_Dim (
    SubscriptionID SERIAL PRIMARY KEY,
    SubscriptionName VARCHAR(100) NOT NULL,
    Price DECIMAL(10, 2),
    Duration INT,
    NumberOfClasses INT,
    Benefits TEXT
);


CREATE TABLE Room_Dim (
    RoomID SERIAL PRIMARY KEY,
    RoomName VARCHAR(100) NOT NULL,
    Capacity INT NOT NULL,
    Location VARCHAR(255) NOT NULL,
    Equipment TEXT
);


CREATE TABLE ClassSchedule_Dim (
    ClassScheduleID SERIAL PRIMARY KEY,
    ClassID INT,
    InstructorID INT,
    RoomID INT,
    ClassDate DATE,
    StartTime TIME,
    EndTime TIME,
    EnrolledStudents INT
);