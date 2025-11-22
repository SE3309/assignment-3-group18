
-- update the customer loyalty based of total successful payments, silver for totals spend over 500, gold for over 100 and bronze otherwise  
UPDATE Customer AS c
JOIN (
    SELECT
        o.customer_email,
        SUM(p.amount) AS total_spent
    FROM `Order` AS o
    JOIN Payment AS p
        ON p.order_num = o.order_num
    WHERE p.transaction_status IN ('CAPTURED', 'AUTHORIZED')
    GROUP BY o.customer_email
) AS spending
    ON spending.customer_email = c.email
SET c.loyalty_tier = CASE
    WHEN spending.total_spent >= 1000 THEN 'Gold'
    WHEN spending.total_spent >= 500  THEN 'Silver'
    ELSE 'Bronze' 
END;

-- markes seats as sold if tickets have already been given out for the seat. (since ticketed seats should not remain avalible for others to purchase)
UPDATE EventSeat AS es
JOIN Ticket AS t
    ON  es.event_name     = t.event_name
    AND es.event_date     = t.event_date
    AND es.venue_name     = t.venue_name
    AND es.venue_address  = t.venue_address
    AND es.section        = t.section
    AND es.`row`          = t.`row`
    AND es.number         = t.number
SET es.availability_status = 'SOLD'
WHERE es.availability_status <> 'SOLD';

