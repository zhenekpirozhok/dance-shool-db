CREATE INDEX idx_customer_email ON Customers(Email);
CREATE INDEX idx_instructor_email ON Instructors(Email);
CREATE INDEX idx_class_name ON Classes(ClassName);
CREATE INDEX idx_subscription_name ON Subscriptions(SubscriptionName);
CREATE INDEX idx_customer_subscription ON CustomerSubscriptions(CustomerID, SubscriptionID);
CREATE INDEX idx_room_rental ON RoomRentals(RoomID, InstructorID);
CREATE INDEX idx_class_schedule ON ClassSchedules(ClassID, InstructorID, RoomID);
