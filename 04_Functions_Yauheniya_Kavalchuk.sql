-- Procedure to Enroll Customer in Class
CREATE OR REPLACE FUNCTION EnrollCustomerInClass(
    p_CustomerID INT,
    p_ClassScheduleID INT
)
RETURNS VOID AS $$
DECLARE
    v_SubscriptionID INT;
    v_RemainingClasses INT;
BEGIN
    SELECT cs.SubscriptionID, cs.RemainingClasses
    INTO v_SubscriptionID, v_RemainingClasses
    FROM CustomerSubscriptions cs
    WHERE cs.CustomerID = p_CustomerID AND cs.EndDate >= CURRENT_DATE
    LIMIT 1;
    
    IF v_RemainingClasses > 0 THEN
        UPDATE CustomerSubscriptions
        SET RemainingClasses = RemainingClasses - 1,
            TotalClassesAttended = TotalClassesAttended + 1
        WHERE CustomerSubscriptionID = v_SubscriptionID;
        
        UPDATE ClassSchedules
        SET EnrolledStudents = EnrolledStudents + 1
        WHERE ClassScheduleID = p_ClassScheduleID;
    ELSE
        RAISE EXCEPTION 'No remaining classes in subscription';
    END IF;
END;
$$ LANGUAGE plpgsql;


-- Procedure to Book a Room for a Class
CREATE OR REPLACE FUNCTION BookRoomForClass(
    p_ClassID INT,
    p_InstructorID INT,
    p_RoomID INT,
    p_ClassDate DATE,
    p_StartTime TIME,
    p_EndTime TIME
)
RETURNS VOID AS $$
BEGIN
    -- Ensure the room is available during the specified time
    IF EXISTS (
        SELECT 1
        FROM RoomRentals rr
        WHERE rr.RoomID = p_RoomID
        AND rr.RentalDate = p_ClassDate
        AND (
            (rr.StartTime <= p_StartTime AND rr.EndTime > p_StartTime) OR
            (rr.StartTime < p_EndTime AND rr.EndTime >= p_EndTime) OR
            (rr.StartTime >= p_StartTime AND rr.EndTime <= p_EndTime)
        )
    ) THEN
        RAISE EXCEPTION 'Room is already booked during the specified time';
    END IF;
    
    -- Insert the room rental record
    INSERT INTO RoomRentals (RoomID, InstructorID, RentalDate, StartTime, EndTime, Price)
    VALUES (p_RoomID, p_InstructorID, p_ClassDate, p_StartTime, p_EndTime, 0);
    
    -- Insert the class schedule record
    INSERT INTO ClassSchedules (ClassID, InstructorID, RoomID, ClassDate, StartTime, EndTime, EnrolledStudents)
    VALUES (p_ClassID, p_InstructorID, p_RoomID, p_ClassDate, p_StartTime, p_EndTime, 0);
END;
$$ LANGUAGE plpgsql;
