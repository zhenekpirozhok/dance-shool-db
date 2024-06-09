-- Customer Management Screen
SELECT CustomerID, FirstName, LastName, Email, Phone, DateOfBirth, Address, Gender, JoinDate
FROM Customers;

-- Instructor Management Screen
SELECT InstructorID, FirstName, LastName, Email, Phone, Specialization, HireDate, Rating
FROM Instructors;

-- Class Management Screen
SELECT ClassID, ClassName, Description, Level, Duration, Price, Category
FROM Classes;

-- Subscription Management Screen
SELECT SubscriptionID, SubscriptionName, Price, Duration, NumberOfClasses, Benefits
FROM Subscriptions;

-- Room Management Screen
SELECT RoomID, RoomName, Capacity, Location, Equipment
FROM Rooms;

-- Room Rental Management Screen
SELECT RoomRentalID, RoomID, InstructorID, RentalDate, StartTime, EndTime, Price
FROM RoomRentals;

-- Class Schedule Management Screen
SELECT ClassScheduleID, ClassID, InstructorID, RoomID, ClassDate, StartTime, EndTime, EnrolledStudents
FROM ClassSchedules;
