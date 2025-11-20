import random

# This script generates a big-data SQL file for Assignment3_3309.
# Run AFTER you've created the schema (ex2.sql) and sample data (ex3.sql).
# It writes INSERTs into SQL/ex4_bigdata.sql.
# Then open that .sql in MySQL Workbench and execute it once.

OUTPUT_FILE = "SQL/ex4_bigdata.sql"


def write_header(f):
    f.write("-- Auto-generated big data for Assignment3_3309\n")
    f.write("-- Run this AFTER ex2.sql and ex3.sql\n")
    f.write("-- Run only once, otherwise you may get duplicate-key errors.\n\n")
    f.write("USE Assignment3_3309;\n\n")


def generate_venues(f):
    # New venue so we don't clash with Budweiser Gardens from ex3.sql
    venues = [
        {
            "name": "Simulated Arena",
            "address": "1 Simulation Way, London, ON",
            "capacity": 3000
        }
    ]
    for v in venues:
        f.write(
            "INSERT INTO Venue (name, address, capacity) "
            f"VALUES ('{v['name']}', '{v['address']}', {v['capacity']});\n"
        )
    f.write("\n")
    return venues


def generate_seats(f, venue, sections=25, rows=10, seats_per_row=10):
    """
    Generates ~2500 seats for one venue:
    25 sections x 10 rows x 10 seats.
    This gives "a few thousand" tuples for Seat.
    """
    seat_keys = []
    vn = venue["name"]
    va = venue["address"]
    for s in range(1, sections + 1):
        section = f"S{s:02d}"       # S01, S02, ...
        for r in range(1, rows + 1):
            row = f"R{r:02d}"       # R01, R02, ...
            for n in range(1, seats_per_row + 1):
                number = str(n)     # "1"..."10"
                f.write(
                    "INSERT INTO Seat (venue_name, venue_address, section, `row`, number, status) "
                    f"VALUES ('{vn}', '{va}', '{section}', '{row}', '{number}', 'ACTIVE');\n"
                )
                seat_keys.append((section, row, number))
    f.write("\n")
    return seat_keys


def generate_events(f, venue):
    """
    Three events at the new venue.
    """
    vn = venue["name"]
    va = venue["address"]
    events = [
        ("Sim Rock Night", "2025-10-01"),
        ("Sim Jazz Fest", "2025-11-15"),
        ("Sim Hockey Game", "2026-01-20"),
    ]
    for name, date in events:
        f.write(
            "INSERT INTO Event (name, date, venue_name, venue_address, status) "
            f"VALUES ('{name}', '{date}', '{vn}', '{va}', 'SCHEDULED');\n"
        )
    f.write("\n")
    return [{"name": e[0], "date": e[1], "venue_name": vn, "venue_address": va} for e in events]


def generate_event_seats(f, events, venue, seat_keys):
    """
    For each event, create an EventSeat row for every Seat.
    3 events x 2500 seats = 7500 EventSeat rows (also "few thousand").
    """
    vn = venue["name"]
    va = venue["address"]
    event_seats = []
    base_price = 80.0

    for ev in events:
        for (section, row, number) in seat_keys:
            # Simple pricing: closer rows more expensive
            row_num = int(row[1:])          # from "R05" -> 5
            price = base_price + max(0, 15 - row_num) * 2
            f.write(
                "INSERT INTO EventSeat (event_name, event_date, venue_name, venue_address, "
                "section, `row`, number, price, availability_status) "
                f"VALUES ('{ev['name']}', '{ev['date']}', '{vn}', '{va}', "
                f"'{section}', '{row}', '{number}', {price:.2f}, 'AVAILABLE');\n"
            )
            event_seats.append({
                "event_name": ev["name"],
                "event_date": ev["date"],
                "venue_name": vn,
                "venue_address": va,
                "section": section,
                "row": row,
                "number": number,
                "price": price,
            })
    f.write("\n")
    return event_seats


def generate_people_and_customers(f, num_people=500, num_customers=400):
    """
    500 Person rows, first 400 become Customers.
    Gives "hundreds" of tuples in these relations.
    """
    people_emails = []
    for i in range(1, num_people + 1):
        email = f"user{i}@example.com"
        first = f"First{i}"
        last = f"Last{i}"
        phone = f"555-{1000 + i}"
        people_emails.append(email)
        f.write(
            "INSERT INTO Person (email, first_name, last_name, phone_number) "
            f"VALUES ('{email}', '{first}', '{last}', '{phone}');\n"
        )
    f.write("\n")

    tiers = ["Bronze", "Silver", "Gold"]
    customer_emails = people_emails[:num_customers]
    for idx, email in enumerate(customer_emails):
        tier = tiers[idx % len(tiers)]
        f.write(
            "INSERT INTO Customer (email, loyalty_tier) "
            f"VALUES ('{email}', '{tier}');\n"
        )
    f.write("\n")
    return people_emails, customer_emails


def generate_staff(f, people_emails, num_staff=20):
    """
    Randomly pick 20 people to be Staff with different roles.
    """
    roles = ["Admin", "Organizer", "Manager", "CheckIn"]
    chosen = random.sample(people_emails, num_staff)
    for idx, email in enumerate(chosen):
        role = roles[idx % len(roles)]
        f.write(
            "INSERT INTO Staff (email, role) "
            f"VALUES ('{email}', '{role}');\n"
        )
    f.write("\n")


def generate_orders_payments_tickets(
    f,
    event_seats,
    customer_emails,
    start_order_num=2,
    num_orders=1000,
):
    """
    Create ~1000 Orders, Payments, Tickets, CheckIns.
    Uses EventSeat + Customer so everything joins.
    """
    num_orders = min(num_orders, len(event_seats))
    random.shuffle(event_seats)
    used_seats = event_seats[:num_orders]

    for i in range(num_orders):
        seat = used_seats[i]
        order_num = start_order_num + i      # ex3 already used order_num 1
        subtotal = seat["price"]

        # 30% of orders use SAVE10 promotion
        if random.random() < 0.3:
            discount = round(subtotal * 0.10, 2)
            applied_promo_sql = "'SAVE10'"
        else:
            discount = 0.00
            applied_promo_sql = "NULL"

        customer_email = random.choice(customer_emails)

        # ORDER
        f.write(
            "INSERT INTO `Order` (order_num, order_date, subtotal, discount_amount, "
            "order_status, applied_promo, customer_email) "
            f"VALUES ({order_num}, NOW(), {subtotal:.2f}, {discount:.2f}, "
            f"'PAID', {applied_promo_sql}, '{customer_email}');\n"
        )

        # PAYMENT
        amount = subtotal - discount
        pay_ref = f"PAY{order_num:05d}"
        method = random.choice(["CARD", "CASH", "TRANSFER"])
        f.write(
            "INSERT INTO Payment (payment_reference, amount, payment_date, "
            "payment_method, transaction_status, order_num) "
            f"VALUES ('{pay_ref}', {amount:.2f}, NOW(), '{method}', "
            f"'CAPTURED', {order_num});\n"
        )

        # TICKET (one seat per order)
        qr = f"QR{order_num:06d}"
        f.write(
            "INSERT INTO Ticket (qr_code, status, order_num, "
            "event_name, event_date, venue_name, venue_address, section, `row`, number) "
            f"VALUES ('{qr}', 'ISSUED', {order_num}, "
            f"'{seat['event_name']}', '{seat['event_date']}', "
            f"'{seat['venue_name']}', '{seat['venue_address']}', "
            f"'{seat['section']}', '{seat['row']}', '{seat['number']}');\n"
        )

        # 70% of tickets actually check in
        if random.random() < 0.7:
            gate = random.choice(["Gate A", "Gate B", "Gate C"])
            f.write(
                "INSERT INTO CheckIn (qr_code, checkin_time, gate) "
                f"VALUES ('{qr}', NOW(), '{gate}');\n"
            )

    f.write("\n")


def main():
    random.seed(3309)  # reproducible for your report
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        write_header(f)

        # 1) Venue + Seats + Events + EventSeats
        venues = generate_venues(f)
        main_venue = venues[0]

        seat_keys = generate_seats(
            f,
            main_venue,
            sections=25,
            rows=10,
            seats_per_row=10,
        )
        events = generate_events(f, main_venue)
        event_seats = generate_event_seats(f, events, main_venue, seat_keys)

        # 2) People / Customers / Staff
        people_emails, customer_emails = generate_people_and_customers(f)
        generate_staff(f, people_emails)

        # 3) Orders / Payments / Tickets / CheckIns
        generate_orders_payments_tickets(
            f,
            event_seats,
            customer_emails,
            start_order_num=2,
            num_orders=1000,
        )

    print(f"Wrote SQL to {OUTPUT_FILE}")


if __name__ == "__main__":
    main()
