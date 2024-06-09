-- Fact Tables
CREATE TABLE Sales_Fact (
    SalesFactID SERIAL PRIMARY KEY,
    CustomerKey INT,
    InstructorKey INT,
    ClassKey INT,
    RoomKey INT,
    SubscriptionKey INT,
    ClassScheduleKey INT,
    DateKey INT,
    TimeKey INT,
    Price DECIMAL(10, 2),
    Quantity INT,
    TotalAmount DECIMAL(10, 2)
);

CREATE TABLE Room_Rental_Fact (
    RoomRentalFactID SERIAL PRIMARY KEY,
    RoomRentalKey INT,
    RoomKey INT,
    InstructorKey INT,
    RentalDateKey INT,
    StartTimeKey INT,
    EndTimeKey INT,
    Price DECIMAL(10, 2),
    Quantity INT,
    TotalAmount DECIMAL(10, 2)
);

-- Dimension Tables
CREATE TABLE Customer_Dim (
    CustomerKey INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    DateOfBirth DATE,
    Address VARCHAR(255),
    Gender VARCHAR(10),
    JoinDate DATE
);

CREATE TABLE Instructor_Dim (
    InstructorKey INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    Specialization VARCHAR(100),
    HireDate DATE,
    Rating DECIMAL(2, 1)
);

CREATE TABLE Class_Dim (
    ClassKey INT PRIMARY KEY,
    ClassName VARCHAR(100) NOT NULL,
    Description TEXT,
    Level VARCHAR(50),
    Duration INT,
    Price DECIMAL(10, 2),
    Category VARCHAR(50)
);

CREATE TABLE Subscription_Dim (
    SubscriptionKey INT PRIMARY KEY,
    SubscriptionName VARCHAR(100) NOT NULL,
    Price DECIMAL(10, 2),
    Duration INT,
    NumberOfClasses INT,
    Benefits TEXT
);

CREATE TABLE Room_Dim (
    RoomKey INT PRIMARY KEY,
    RoomName VARCHAR(100) NOT NULL,
    Capacity INT NOT NULL,
    Location VARCHAR(255) NOT NULL,
    Equipment TEXT
);

CREATE TABLE ClassSchedule_Dim (
    ClassScheduleKey INT PRIMARY KEY,
    ClassID INT,
    InstructorID INT,
    RoomID INT,
    ClassDate DATE,
    StartTime TIME,
    EndTime TIME,
    EnrolledStudents INT
);

CREATE TABLE Date_Dim (
    DateKey INT PRIMARY KEY,
    Date DATE,
    DayOfWeek INT,
    Month INT,
    Quarter INT,
    Year INT
);

CREATE TABLE Time_Dim (
    TimeKey INT PRIMARY KEY,
    Time TIME,
    Hour INT,
    Minute INT,
    Second INT
);
