CREATE TABLE Customers (
    CustomerID SERIAL PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    DateOfBirth DATE,
    Address VARCHAR(255),
    Gender VARCHAR(10),
    JoinDate DATE
);

CREATE TABLE Instructors (
    InstructorID SERIAL PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    Specialization VARCHAR(100),
    HireDate DATE,
    Rating DECIMAL(2, 1)
);

CREATE TABLE Classes (
    ClassID SERIAL PRIMARY KEY,
    ClassName VARCHAR(100) NOT NULL,
    Description TEXT,
    Level VARCHAR(50),
    Duration INT,
    Price DECIMAL(10, 2),
    Category VARCHAR(50)
);

CREATE TABLE Subscriptions (
    SubscriptionID SERIAL PRIMARY KEY,
    SubscriptionName VARCHAR(100) NOT NULL,
    Price DECIMAL(10, 2),
    Duration INT,
    NumberOfClasses INT,
    Benefits TEXT
);

CREATE TABLE CustomerSubscriptions (
    CustomerSubscriptionID SERIAL PRIMARY KEY,
    CustomerID INT NOT NULL,
    SubscriptionID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    RemainingClasses INT,
    TotalClassesAttended INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (SubscriptionID) REFERENCES Subscriptions(SubscriptionID)
);

CREATE TABLE Rooms (
    RoomID SERIAL PRIMARY KEY,
    RoomName VARCHAR(100) NOT NULL,
    Capacity INT NOT NULL,
    Location VARCHAR(255) NOT NULL,
    Equipment TEXT
);

CREATE TABLE RoomRentals (
    RoomRentalID SERIAL PRIMARY KEY,
    RoomID INT NOT NULL,
    InstructorID INT NOT NULL,
    RentalDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    Price DECIMAL(10, 2),
    FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID),
    FOREIGN KEY (InstructorID) REFERENCES Instructors(InstructorID)
);

CREATE TABLE ClassSchedules (
    ClassScheduleID SERIAL PRIMARY KEY,
    ClassID INT NOT NULL,
    InstructorID INT NOT NULL,
    RoomID INT NOT NULL,
    ClassDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    EnrolledStudents INT,
    FOREIGN KEY (ClassID) REFERENCES Classes(ClassID),
    FOREIGN KEY (InstructorID) REFERENCES Instructors(InstructorID),
    FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID)
);
