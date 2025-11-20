USE Assignment3_3309;

-- INSERT #1: single row into Venue
INSERT INTO Venue (name, address, capacity)
VALUES ('Budweiser Gardens',
        '99 Dundas St, London, ON',
        9000);
SELECT * FROM Venue;
DELETE FROM Venue
WHERE name = 'Budweiser Gardens'
  AND address = '99 Dundas St, London, ON';
  INSERT INTO Venue (name, address, capacity)
VALUES ('Budweiser Gardens',
        '99 Dundas St, London, ON',
        9000);
SELECT * FROM Venue;


USE Assignment3_3309;
-- ===========================================
-- SEAT (Dependent on Venue)
-- ===========================================
INSERT INTO Seat (venue_name, venue_address, section, `row`, number, status)
VALUES 
 ('Budweiser Gardens', '99 Dundas St, London, ON', 'A', '1', '1', 'ACTIVE'),
 ('Budweiser Gardens', '99 Dundas St, London, ON', 'A', '1', '2', 'ACTIVE'),
 ('Budweiser Gardens', '99 Dundas St, London, ON', 'A', '2', '1', 'ACTIVE');


-- ===========================================
-- EVENT (Depends on Venue)
-- ===========================================
INSERT INTO Event (name, date, venue_name, venue_address, status)
VALUES ('Rock Festival', '2025-12-01', 'Budweiser Gardens', '99 Dundas St, London, ON', 'SCHEDULED');


-- ===========================================
-- EVENT SEAT (Depends on EVENT + SEAT)
-- ===========================================
INSERT INTO EventSeat (
    event_name, event_date, venue_name, venue_address,
    section, `row`, number, price, availability_status
)
VALUES
 ('Rock Festival', '2025-12-01', 'Budweiser Gardens', '99 Dundas St, London, ON',
  'A', '1', '1', 120.00, 'AVAILABLE'),
 ('Rock Festival', '2025-12-01', 'Budweiser Gardens', '99 Dundas St, London, ON',
  'A', '1', '2', 120.00, 'AVAILABLE'),
 ('Rock Festival', '2025-12-01', 'Budweiser Gardens', '99 Dundas St, London, ON',
  'A', '2', '1', 110.00, 'AVAILABLE');


-- ===========================================
-- PERSON (Superclass for Customer + Staff)
-- ===========================================
INSERT INTO Person (email, first_name, last_name, phone_number)
VALUES
 ('alice@gmail.com', 'Alice', 'Brown', '555-1111'),
 ('bob@gmail.com', 'Bob', 'Miller', '555-2222'),
 ('sam@gmail.com', 'Sam', 'Daniels', '555-3333');


-- ===========================================
-- CUSTOMER (Subclass of Person)
-- ===========================================
INSERT INTO Customer (email, loyalty_tier)
VALUES 
 ('alice@gmail.com', 'Gold'),
 ('bob@gmail.com', 'Silver');


-- ===========================================
-- STAFF (Subclass of Person)
-- ===========================================
INSERT INTO Staff (email, role)
VALUES ('sam@gmail.com', 'Admin');


-- ===========================================
-- PROMOTION
-- ===========================================
INSERT INTO Promotion (code, type, description, discount_percent, valid_from, valid_to, isActive)
VALUES ('SAVE10', 'PERCENT', '10% off', 10.00, '2025-01-01', '2025-12-31', TRUE);


-- ===========================================
-- ORDER (Depends on Customer + Promotion (optional))
-- ===========================================
INSERT INTO `Order` (subtotal, discount_amount, order_status, applied_promo, customer_email)
VALUES (300.00, 30.00, 'PAID', 'SAVE10', 'alice@gmail.com');


-- ===========================================
-- PAYMENT (Depends on Order)
-- ===========================================
INSERT INTO Payment (payment_reference, amount, payment_date, payment_method, transaction_status, order_num)
VALUES ('PAY123', 270.00, NOW(), 'CARD', 'CAPTURED', 1);


-- ===========================================
-- TICKET (Depends on Order + EventSeat)
-- ===========================================
INSERT INTO Ticket (
    qr_code, status, order_num,
    event_name, event_date, venue_name, venue_address,
    section, `row`, number
)
VALUES
 ('QR001', 'ISSUED', 1,
  'Rock Festival', '2025-12-01', 'Budweiser Gardens', '99 Dundas St, London, ON',
  'A', '1', '1');


-- ===========================================
-- CHECK-IN (Depends on Ticket)
-- ===========================================
INSERT INTO CheckIn (qr_code, checkin_time, gate)
VALUES ('QR001', NOW(), 'Gate A');


-- ===========================================
-- Optional: See everything
-- ===========================================
SELECT * FROM Venue;
SELECT * FROM Seat;
SELECT * FROM Event;
SELECT * FROM EventSeat;
SELECT * FROM Person;
SELECT * FROM Customer;
SELECT * FROM Staff;
SELECT * FROM Promotion;
SELECT * FROM `Order`;
SELECT * FROM Payment;
SELECT * FROM Ticket;
SELECT * FROM CheckIn;







