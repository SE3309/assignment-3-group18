CREATE DATABASE IF NOT EXISTS Assignment3_3309;
USE Assignment3_3309;

-- ====== VENUE ======
CREATE TABLE Venue (
    name        VARCHAR(120) NOT NULL,
    address     VARCHAR(200) NOT NULL,
    capacity    INT NOT NULL CHECK (capacity >= 0),
    PRIMARY KEY (name, address)
);

-- ===== SEAT =====
CREATE TABLE Seat (
    venue_name    VARCHAR(120) NOT NULL,
    venue_address VARCHAR(200) NOT NULL,
    section       VARCHAR(40)  NOT NULL,
    `row`         VARCHAR(20)  NOT NULL,
    number        VARCHAR(20)  NOT NULL,
    status        ENUM('ACTIVE','INACTIVE') DEFAULT 'ACTIVE',
    PRIMARY KEY (venue_name, venue_address, section, `row`, number),
    FOREIGN KEY (venue_name, venue_address)
        REFERENCES Venue(name, address)
        ON DELETE RESTRICT
);

-- ====== EVENT ======
CREATE TABLE Event (
    name          VARCHAR(160) NOT NULL,
    date          DATE NOT NULL,
    venue_name    VARCHAR(120) NOT NULL,
    venue_address VARCHAR(200) NOT NULL,
    status        ENUM('SCHEDULED','CANCELLED','COMPLETED') NOT NULL DEFAULT 'SCHEDULED',
    PRIMARY KEY (name, date, venue_name, venue_address),
    FOREIGN KEY (venue_name, venue_address)
        REFERENCES Venue(name, address)
);

-- ====== EVENT SEAT ======
CREATE TABLE EventSeat (
    event_name       VARCHAR(160) NOT NULL,
    event_date       DATE NOT NULL,
    venue_name       VARCHAR(120) NOT NULL,
    venue_address    VARCHAR(200) NOT NULL,
    section          VARCHAR(40) NOT NULL,
    `row`              VARCHAR(20) NOT NULL,
    number           VARCHAR(20) NOT NULL,
    price            DECIMAL(10,2) NOT NULL,
    availability_status ENUM('AVAILABLE','HELD','SOLD') NOT NULL DEFAULT 'AVAILABLE',
    PRIMARY KEY (event_name, event_date, venue_name, venue_address, section, `row`, number),
    FOREIGN KEY (event_name, event_date, venue_name, venue_address)
        REFERENCES Event(name, date, venue_name, venue_address),
    FOREIGN KEY (venue_name, venue_address, section, `row`, number)
        REFERENCES Seat(venue_name, venue_address, section, `row`, number)
);

-- ====== PERSON ======
CREATE TABLE Person (
    email         VARCHAR(120) NOT NULL,
    first_name    VARCHAR(60) NOT NULL,
    last_name     VARCHAR(60) NOT NULL,
    phone_number  VARCHAR(30),
    PRIMARY KEY (email)
);

-- ====== CUSTOMER ======
CREATE TABLE Customer (
    email         VARCHAR(120) NOT NULL,
    loyalty_tier  ENUM('Bronze','Silver','Gold') DEFAULT 'Bronze',
    PRIMARY KEY (email),
    FOREIGN KEY (email) REFERENCES Person(email)
);

-- ====== STAFF ======
CREATE TABLE Staff (
    email   VARCHAR(120) NOT NULL,
    role    ENUM('Admin','Organizer','Manager','CheckIn') NOT NULL,
    PRIMARY KEY (email),
    FOREIGN KEY (email) REFERENCES Person(email)
);

-- ====== PROMOTION ======
CREATE TABLE Promotion (
    code             VARCHAR(40) NOT NULL,
    type             ENUM('PERCENT','FIXED') NOT NULL,
    description      VARCHAR(255),
    discount_percent DECIMAL(5,2),
    valid_from       DATE NOT NULL,
    valid_to         DATE NOT NULL,
    isActive         BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (code)
);

-- ====== ORDER (NO total_amount) ======
CREATE TABLE `Order` (
    order_num       INT AUTO_INCREMENT,
    order_date      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    subtotal        DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    order_status    ENUM('PENDING','PAID','REFUNDED','CANCELLED') NOT NULL DEFAULT 'PENDING',
    applied_promo   VARCHAR(40),
    customer_email  VARCHAR(120) NOT NULL,
    PRIMARY KEY (order_num),
    FOREIGN KEY (applied_promo) REFERENCES Promotion(code),
    FOREIGN KEY (customer_email) REFERENCES Customer(email)
);

-- ====== PAYMENT ======
CREATE TABLE Payment (
    payment_reference VARCHAR(60) NOT NULL,
    amount            DECIMAL(10,2) NOT NULL,
    payment_date      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method    ENUM('CARD','CASH','TRANSFER') NOT NULL,
    transaction_status ENUM('AUTHORIZED','CAPTURED','FAILED','REFUNDED') NOT NULL,
    order_num         INT NOT NULL,
    PRIMARY KEY (payment_reference),
    FOREIGN KEY (order_num) REFERENCES `Order`(order_num)
);

-- ====== TICKET ======
CREATE TABLE Ticket (
    qr_code        VARCHAR(120) NOT NULL,
    issue_date     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status         ENUM('ISSUED','VOID','CHECKED_IN') NOT NULL DEFAULT 'ISSUED',
    order_num      INT NOT NULL,
    event_name     VARCHAR(160) NOT NULL,
    event_date     DATE NOT NULL,
    venue_name     VARCHAR(120) NOT NULL,
    venue_address  VARCHAR(200) NOT NULL,
    section        VARCHAR(40) NOT NULL,
    `row`           VARCHAR(20) NOT NULL,
    number         VARCHAR(20) NOT NULL,
    PRIMARY KEY (qr_code),
    FOREIGN KEY (order_num) REFERENCES `Order`(order_num),
    FOREIGN KEY (event_name, event_date, venue_name, venue_address, section, `row`, number)
        REFERENCES EventSeat(event_name, event_date, venue_name, venue_address, section, `row`, number)
);

-- ====== CHECK IN ======
CREATE TABLE CheckIn (
    qr_code      VARCHAR(120) NOT NULL,
    checkin_time DATETIME NOT NULL,
    gate         VARCHAR(20),
    PRIMARY KEY (qr_code, checkin_time),
    FOREIGN KEY (qr_code) REFERENCES Ticket(qr_code)
);

DESCRIBE Venue;
DESCRIBE Seat;
DESCRIBE Event;
DESCRIBE EventSeat;
DESCRIBE Person;
DESCRIBE Customer;
DESCRIBE Staff;
DESCRIBE Promotion;
DESCRIBE `Order`;
DESCRIBE Payment;
DESCRIBE Ticket;
DESCRIBE CheckIn;