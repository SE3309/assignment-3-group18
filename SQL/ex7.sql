CREATE VIEW CustomerOrderSummary AS
SELECT 
    c.email,
    p.first_name,
    p.last_name,
    c.loyalty_tier,
    COUNT(o.order_num) AS total_orders,
    SUM(o.subtotal) AS total_spent,
    SUM(o.discount_amount) AS total_discounts,
    AVG(o.subtotal) AS avg_order_value,
    MAX(o.order_date) AS last_order_date
FROM Customer AS c
JOIN Person AS p ON c.email = p.email
LEFT JOIN `Order` AS o ON c.email = o.customer_email
GROUP BY c.email, p.first_name, p.last_name, c.loyalty_tier;



CREATE VIEW EventSeatStatus AS
SELECT 
    e.name AS event_name,
    e.date AS event_date,
    e.venue_name,
    e.venue_address,
    es.section,
    COUNT(*) AS total_seats,
    SUM(CASE WHEN es.availability_status = 'AVAILABLE' THEN 1 ELSE 0 END) AS available_seats,
    SUM(CASE WHEN es.availability_status = 'SOLD' THEN 1 ELSE 0 END) AS sold_seats,
    SUM(CASE WHEN es.availability_status = 'HELD' THEN 1 ELSE 0 END) AS held_seats,
    ROUND(SUM(CASE WHEN es.availability_status = 'SOLD' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS occupancy_percent,
    AVG(es.price) AS avg_seat_price
FROM Event AS e
JOIN EventSeat AS es ON e.name = es.event_name 
    AND e.date = es.event_date 
    AND e.venue_name = es.venue_name 
    AND e.venue_address = es.venue_address
GROUP BY e.name, e.date, e.venue_name, e.venue_address, es.section;
