-- ex5.sql
-- SE3309 Assignment 3 – Part 5
-- Queries for Event Ticketing System

USE Assignment3_3309;

------------------------------------------------------------
-- Q1: List all tickets for a given customer with event info
-- (Alice in this dataset)
------------------------------------------------------------
SELECT  c.email                              AS customer_email,
        CONCAT(p.first_name, ' ', p.last_name) AS customer_name,
        t.qr_code,
        e.name                               AS event_name,
        e.date                               AS event_date,
        t.status                             AS ticket_status
FROM Customer c
JOIN Person p   ON c.email = p.email
JOIN `Order` o  ON c.email = o.customer_email
JOIN Ticket t   ON o.order_num = t.order_num
JOIN Event e
   ON t.event_name     = e.name
  AND t.event_date     = e.date
  AND t.venue_name     = e.venue_name
  AND t.venue_address  = e.venue_address
WHERE c.email = 'alice@gmail.com';


------------------------------------------------------------
-- Q2: Seat occupancy for each event (sold vs total)
-- Our dataset: 3 EventSeat rows, 1 sold via Ticket
------------------------------------------------------------
SELECT  e.name AS event_name,
        e.date AS event_date,
        COUNT(*) AS total_seats,
        SUM(CASE WHEN es.availability_status = 'SOLD' THEN 1 ELSE 0 END) AS seats_sold
FROM Event e
JOIN EventSeat es
   ON e.name          = es.event_name
  AND e.date          = es.event_date
  AND e.venue_name    = es.venue_name
  AND e.venue_address = es.venue_address
GROUP BY e.name, e.date
ORDER BY e.date;


------------------------------------------------------------
-- Q3: Revenue per event (sum of captured payments)
-- Payment PAY123 for Order 1, status CAPTURED
------------------------------------------------------------
SELECT  e.name AS event_name,
        e.date AS event_date,
        SUM(p.amount) AS total_revenue
FROM Payment p
JOIN `Order` o   ON p.order_num = o.order_num
JOIN Ticket t    ON o.order_num = t.order_num
JOIN Event e
   ON t.event_name     = e.name
  AND t.event_date     = e.date
  AND t.venue_name     = e.venue_name
  AND t.venue_address  = e.venue_address
WHERE p.transaction_status = 'CAPTURED'
GROUP BY e.name, e.date
ORDER BY total_revenue DESC;


------------------------------------------------------------
-- Q4: Customers who bought more than one ticket for a single event
-- (With current data: will return empty set, which is OK)
------------------------------------------------------------
SELECT  c.email AS customer_email,
        e.name  AS event_name,
        e.date,
        COUNT(t.qr_code) AS tickets_bought
FROM Customer c
JOIN `Order` o ON c.email = o.customer_email
JOIN Ticket t  ON o.order_num = t.order_num
JOIN Event e
   ON t.event_name     = e.name
  AND t.event_date     = e.date
  AND t.venue_name     = e.venue_name
  AND t.venue_address  = e.venue_address
GROUP BY c.email, e.name, e.date
HAVING COUNT(t.qr_code) > 1;


------------------------------------------------------------
-- Q5: Tickets that were sold but never checked in (no-shows)
-- In your data QR001 IS checked in, so result should be empty
------------------------------------------------------------
SELECT  t.qr_code,
        t.order_num,
        e.name AS event_name,
        e.date
FROM Ticket t
JOIN Event e
   ON t.event_name     = e.name
  AND t.event_date     = e.date
  AND t.venue_name     = e.venue_name
  AND t.venue_address  = e.venue_address
LEFT JOIN CheckIn ci ON ci.qr_code = t.qr_code
WHERE ci.qr_code IS NULL
  AND e.date < CURDATE();   -- only past events (may be empty until event date passes)


------------------------------------------------------------
-- Q6: Orders that used a promotion and how much discount was given
-- Order 1 used SAVE10
------------------------------------------------------------
SELECT  o.order_num,
        o.order_date,
        o.subtotal,
        o.discount_amount,
        o.applied_promo,
        pr.description AS promo_description
FROM `Order` o
JOIN Promotion pr ON o.applied_promo = pr.code;


------------------------------------------------------------
-- Q7: Upcoming events at Budweiser Gardens, sorted by date
------------------------------------------------------------
SELECT  e.name   AS event_name,
        e.date   AS event_date,
        e.status AS event_status
FROM Event e
WHERE e.venue_name    = 'Budweiser Gardens'
  AND e.venue_address = '99 Dundas St, London, ON'
ORDER BY e.date;