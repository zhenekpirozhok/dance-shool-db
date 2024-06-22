CREATE TABLE ETLPROCESSED (
    ETLProcess VARCHAR(50) PRIMARY KEY,
    LastProcessedID INT
);

INSERT INTO ETLPROCESSED (ETLProcess, LastProcessedID)
VALUES 
    ('CustomerETL', 0),
    ('InstructorETL', 0),
    ('ClassETL', 0),
    ('SubscriptionETL', 0),
    ('RoomETL', 0),
    ('ClassScheduleETL', 0),
	('RoomRentalETL', 0),
	('CustomerSubscriptionETL', 0);


CREATE OR REPLACE PROCEDURE CustomerETLProcess()
LANGUAGE plpgsql
AS $$
DECLARE
    last_processed_id INT;
BEGIN
    SELECT LastProcessedID INTO last_processed_id FROM ETLPROCESSED WHERE ETLProcess = 'CustomerETL';
    
    INSERT INTO Customer_Dim (CustomerID, FirstName, LastName, Email, Phone, DateOfBirth, Address, Gender, JoinDate, EffectiveStartDate, EffectiveEndDate, IsCurrent)
    SELECT 
        CustomerID,
        FirstName,
        LastName,
        Email,
        Phone,
        DateOfBirth,
        Address,
        Gender,
        JoinDate,
        NOW()::DATE AS EffectiveStartDate,
        NULL AS EffectiveEndDate,
        TRUE AS IsCurrent
    FROM staging.Customers
    WHERE CustomerID > last_processed_id
    ON CONFLICT (CustomerID, EffectiveStartDate)
    DO UPDATE SET IsCurrent = FALSE, EffectiveEndDate = NOW()::DATE - INTERVAL '1 day'
    WHERE Customer_Dim.CustomerID = EXCLUDED.CustomerID
      AND Customer_Dim.EffectiveStartDate = EXCLUDED.EffectiveStartDate;
    
    UPDATE ETLPROCESSED SET LastProcessedID = (SELECT MAX(CustomerID) FROM staging.Customers) WHERE ETLProcess = 'CustomerETL';
END $$;


CREATE OR REPLACE PROCEDURE InstructorETLProcess()
LANGUAGE plpgsql
AS $$
DECLARE
    last_processed_id INT;
BEGIN
    SELECT LastProcessedID INTO last_processed_id FROM ETLPROCESSED WHERE ETLProcess = 'InstructorETL';
    
    INSERT INTO Instructor_Dim (InstructorID, FirstName, LastName, Email, Phone, Specialization, HireDate, Rating)
    SELECT DISTINCT
		InstructorID, 
        FirstName,
        LastName,
        Email,
        Phone,
        Specialization,
        HireDate,
        Rating
    FROM staging.Instructors
    WHERE InstructorID > last_processed_id
    ON CONFLICT (InstructorID)
    DO NOTHING;
    
    UPDATE ETLPROCESSED SET LastProcessedID = (SELECT MAX(InstructorID) FROM staging.Instructors) WHERE ETLProcess = 'InstructorETL';
END $$;


CREATE OR REPLACE PROCEDURE ClassETLProcess()
LANGUAGE plpgsql
AS $$
DECLARE
    last_processed_id INT;
BEGIN
    SELECT LastProcessedID INTO last_processed_id FROM ETLPROCESSED WHERE ETLProcess = 'ClassETL';
    
    INSERT INTO Class_Dim (ClassID, ClassName, Description, Level, Duration, Price, Category)
    SELECT DISTINCT
		ClassID, 
        ClassName,
        Description,
        Level,
        Duration,
        Price,
        Category
    FROM staging.Classes
    WHERE ClassID > last_processed_id
    ON CONFLICT (ClassID)
    DO NOTHING;
    
    UPDATE ETLPROCESSED SET LastProcessedID = (SELECT MAX(ClassID) FROM staging.Classes) WHERE ETLProcess = 'ClassETL';
END $$;


CREATE OR REPLACE PROCEDURE SubscriptionETLProcess()
LANGUAGE plpgsql
AS $$
DECLARE
    last_processed_id INT;
BEGIN
    SELECT LastProcessedID INTO last_processed_id FROM ETLPROCESSED WHERE ETLProcess = 'SubscriptionETL';
    
    INSERT INTO Subscription_Dim (SubscriptionID, SubscriptionName, Price, Duration, NumberOfClasses, Benefits)
    SELECT DISTINCT
		SubscriptionID,
        SubscriptionName,
        Price,
        Duration,
        NumberOfClasses,
        Benefits
    FROM staging.Subscriptions
    WHERE SubscriptionID > last_processed_id
    ON CONFLICT (SubscriptionID)
    DO NOTHING;
    
    UPDATE ETLPROCESSED SET LastProcessedID = (SELECT MAX(SubscriptionID) FROM staging.Subscriptions) WHERE ETLProcess = 'SubscriptionETL';
END $$;


CREATE OR REPLACE PROCEDURE RoomETLProcess()
LANGUAGE plpgsql
AS $$
DECLARE
    last_processed_id INT;
BEGIN
    SELECT LastProcessedID INTO last_processed_id FROM ETLPROCESSED WHERE ETLProcess = 'RoomETL';
    
    INSERT INTO Room_Dim (RoomID, RoomName, Capacity, Location, Equipment)
    SELECT DISTINCT
		RoomID,
        RoomName,
        Capacity,
        Location,
        Equipment
    FROM staging.Rooms
    WHERE RoomID > last_processed_id
    ON CONFLICT (RoomID)
    DO NOTHING;
    
    UPDATE ETLPROCESSED SET LastProcessedID = (SELECT MAX(RoomID) FROM staging.Rooms) WHERE ETLProcess = 'RoomETL';
END $$;


CREATE OR REPLACE PROCEDURE ClassScheduleETLProcess()
LANGUAGE plpgsql
AS $$
DECLARE
    last_processed_id INT;
BEGIN
    SELECT LastProcessedID INTO last_processed_id FROM ETLPROCESSED WHERE ETLProcess = 'ClassScheduleETL';
    
    INSERT INTO ClassSchedule_Dim (ClassScheduleID, ClassID, InstructorID, RoomID, ClassDate, StartTime, EndTime, EnrolledStudents)
    SELECT DISTINCT
		cs.ClassScheduleID,
        cs.ClassID,
        cs.InstructorID,
        cs.RoomID,
        cs.ClassDate,
        cs.StartTime,
        cs.EndTime,
        cs.EnrolledStudents
    FROM staging.ClassSchedules cs
    LEFT JOIN ClassSchedule_Dim csd ON cs.ClassID = csd.ClassID 
                                    AND cs.InstructorID = csd.InstructorID 
                                    AND cs.RoomID = csd.RoomID 
                                    AND cs.ClassDate = csd.ClassDate 
                                    AND cs.StartTime = csd.StartTime 
                                    AND cs.EndTime = csd.EndTime
    WHERE csd.ClassScheduleID IS NULL AND cs.ClassScheduleID > last_processed_id;
    
    UPDATE ETLPROCESSED SET LastProcessedID = (SELECT MAX(ClassScheduleID) FROM staging.ClassSchedules) WHERE ETLProcess = 'ClassScheduleETL';
END $$;


CREATE OR REPLACE PROCEDURE CustomerSubscriptionETLProcess()
LANGUAGE plpgsql
AS $$
DECLARE
    last_processed_id INT;
BEGIN
    -- Get the last processed CustomerSubscriptionID for the CustomerSubscriptionETL process
    SELECT LastProcessedID INTO last_processed_id FROM ETLPROCESSED WHERE ETLProcess = 'CustomerSubscriptionETL';

    -- Insert new sales records into Sales_Fact
    INSERT INTO Sales_Fact (
        CustomerID, 
        InstructorID, 
        ClassID, 
        RoomID, 
        SubscriptionID, 
        ClassScheduleID, 
        SaleDate, 
        Price 
    )
    SELECT
        cd.CustomerID,
        id.InstructorID,
        cld.ClassID,
        csd.RoomID,
        sd.SubscriptionID,
        csd.ClassScheduleID,
        cs.StartDate AS SaleDate,
        sd.Price
    FROM staging.CustomerSubscriptions cs
    JOIN Customer_Dim cd ON cs.CustomerID = cd.CustomerID AND cd.IsCurrent = TRUE
    JOIN Subscription_Dim sd ON cs.SubscriptionID = sd.SubscriptionID
    JOIN ClassSchedule_Dim csd ON csd.ClassScheduleID = cs.SubscriptionID
    JOIN Class_Dim cld ON cld.ClassID = csd.ClassID
    JOIN Instructor_Dim id ON id.InstructorID = csd.InstructorID
    JOIN Room_Dim rd ON rd.RoomID = csd.RoomID
    WHERE cs.CustomerSubscriptionID > last_processed_id;

    -- Update the LastProcessedID in the ETLPROCESSED table
    UPDATE ETLPROCESSED 
    SET LastProcessedID = (SELECT COALESCE(MAX(CustomerSubscriptionID), last_processed_id) FROM staging.CustomerSubscriptions)
    WHERE ETLProcess = 'CustomerSubscriptionETL';
END $$;

-- ETL Process for RoomRentals
CREATE OR REPLACE PROCEDURE RoomRentalETLProcess()
LANGUAGE plpgsql
AS $$
DECLARE
    last_processed_id INT;
BEGIN
    -- Get the last processed RoomRentalID for the RoomRentalETL process
    SELECT LastProcessedID INTO last_processed_id FROM ETLPROCESSED WHERE ETLProcess = 'RoomRentalETL';

    -- Insert new room rental records into Room_Rental_Fact
    INSERT INTO Room_Rental_Fact (
        RoomRentalID, 
        RoomID, 
        InstructorID, 
        RentalDate, 
        StartTime, 
        EndTime, 
        Price 
    )
    SELECT
        rr.RoomRentalID,
        rd.RoomID,
        id.InstructorID,
        rr.RentalDate,
        rr.StartTime,
        rr.EndTime,
        rr.Price
    FROM staging.RoomRentals rr
    JOIN Room_Dim rd ON rr.RoomID = rd.RoomID
    JOIN Instructor_Dim id ON rr.InstructorID = id.InstructorID
    WHERE rr.RoomRentalID > last_processed_id;

    -- Update the LastProcessedID in the ETLPROCESSED table
    UPDATE ETLPROCESSED 
    SET LastProcessedID = (SELECT COALESCE(MAX(RoomRentalID), last_processed_id) FROM staging.RoomRentals)
    WHERE ETLProcess = 'RoomRentalETL';
END $$;


SELECT cron.schedule('0 0 * * *', 'CALL CustomerETLProcess()');
SELECT cron.schedule('0 0 * * *', 'CALL InstructorETLProcess()');
SELECT cron.schedule('0 0 * * *', 'CALL ClassETLProcess()');
SELECT cron.schedule('0 0 * * *', 'CALL SubscriptionETLProcess()');
SELECT cron.schedule('0 0 * * *', 'CALL RoomETLProcess()');
SELECT cron.schedule('0 0 * * *', 'CALL ClassScheduleETLProcess()');
SELECT cron.schedule('0 0 * * *', 'CALL CustomerSubscriptionETLProcess()');
SELECT cron.schedule('0 0 * * *', 'CALL RoomRentalETLProcess()');