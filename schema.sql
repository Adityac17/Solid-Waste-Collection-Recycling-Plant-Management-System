-- Solid Waste Collection and Recycling Plant - Database Schema

DROP TABLE IF EXISTS batch_allocation CASCADE;
DROP TABLE IF EXISTS processing_batch CASCADE;
DROP TABLE IF EXISTS weighbridge_ticket CASCADE;
DROP TABLE IF EXISTS trip CASCADE;
DROP TABLE IF EXISTS driver CASCADE;
DROP TABLE IF EXISTS vehicle CASCADE;
DROP TABLE IF EXISTS material_category CASCADE;
DROP TABLE IF EXISTS zone CASCADE;

-- 1. ZONE Table
CREATE TABLE zone (
    zone_id SERIAL PRIMARY KEY,
    zone_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(200),
    description TEXT,
    supervisor_contact VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. MATERIAL_CATEGORY Table
CREATE TABLE material_category (
    material_id SERIAL PRIMARY KEY,
    material_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    recovery_value DECIMAL(8, 2) DEFAULT 0,
    is_recyclable BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. VEHICLE Table
CREATE TABLE vehicle (
    vehicle_id SERIAL PRIMARY KEY,
    vehicle_number VARCHAR(20) NOT NULL UNIQUE,
    vehicle_type VARCHAR(50),
    capacity_kg DECIMAL(10, 2) NOT NULL CHECK (capacity_kg > 0),
    registration_date DATE NOT NULL,
    last_service_date DATE,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'MAINTENANCE')),
    driver_license_required BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. DRIVER Table
CREATE TABLE driver (
    driver_id SERIAL PRIMARY KEY,
    driver_name VARCHAR(100) NOT NULL,
    license_number VARCHAR(50) NOT NULL UNIQUE,
    license_expiry DATE NOT NULL,
    contact_number VARCHAR(20),
    email VARCHAR(100),
    date_of_birth DATE,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'ON_LEAVE')),
    joining_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. TRIP Table
CREATE TABLE trip (
    trip_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL,
    driver_id INTEGER NOT NULL,
    zone_id INTEGER NOT NULL,
    trip_date DATE NOT NULL,
    trip_time TIME,
    status VARCHAR(20) DEFAULT 'COMPLETED' CHECK (status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    comments TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vehicle_id) REFERENCES vehicle(vehicle_id) ON DELETE RESTRICT,
    FOREIGN KEY (driver_id) REFERENCES driver(driver_id) ON DELETE RESTRICT,
    FOREIGN KEY (zone_id) REFERENCES zone(zone_id) ON DELETE RESTRICT,
    CONSTRAINT trip_vehicle_driver_zone_date UNIQUE (vehicle_id, driver_id, zone_id, trip_date)
);

-- 6. WEIGHBRIDGE_TICKET Table
CREATE TABLE weighbridge_ticket (
    ticket_id SERIAL PRIMARY KEY,
    trip_id INTEGER NOT NULL UNIQUE,
    gross_weight_kg DECIMAL(10, 2) NOT NULL CHECK (gross_weight_kg > 0),
    tare_weight_kg DECIMAL(10, 2) NOT NULL CHECK (tare_weight_kg >= 0),
    net_weight_kg DECIMAL(10, 2) NOT NULL CHECK (net_weight_kg > 0),
    weighbridge_date DATE NOT NULL,
    weighbridge_time TIME NOT NULL,
    weighbridge_operator VARCHAR(100),
    ticket_status VARCHAR(20) DEFAULT 'RECORDED' CHECK (ticket_status IN ('RECORDED', 'PROCESSED', 'CANCELLED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (trip_id) REFERENCES trip(trip_id) ON DELETE CASCADE,
    CONSTRAINT valid_net_weight CHECK (net_weight_kg = (gross_weight_kg - tare_weight_kg))
);

-- 7. PROCESSING_BATCH Table
CREATE TABLE processing_batch (
    batch_id SERIAL PRIMARY KEY,
    batch_date DATE NOT NULL,
    batch_capacity_kg DECIMAL(10, 2) NOT NULL CHECK (batch_capacity_kg > 0),
    current_load_kg DECIMAL(10, 2) DEFAULT 0 CHECK (current_load_kg >= 0),
    status VARCHAR(20) DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'FULL', 'PROCESSING', 'COMPLETED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE batch_allocation (
    batch_id INT,
    ticket_id INT,
    material_id INT,
    allocated_weight_kg DECIMAL(10, 2)
);

-- 8. BATCH_ALLOCATION Table (Junction table for M:M relationship)
CREATE TABLE batch_allocation (
    allocation_id SERIAL PRIMARY KEY,
    batch_id INTEGER NOT NULL,
    ticket_id INTEGER NOT NULL,
    material_id INTEGER NOT NULL,
    allocated_weight_kg DECIMAL(10, 2) NOT NULL CHECK (allocated_weight_kg > 0),
    allocation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (batch_id) REFERENCES processing_batch(batch_id) ON DELETE CASCADE,
    FOREIGN KEY (ticket_id) REFERENCES weighbridge_ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (material_id) REFERENCES material_category(material_id) ON DELETE RESTRICT,
    CONSTRAINT allocation_weight_limit CHECK (allocated_weight_kg <=
        (SELECT net_weight_kg FROM weighbridge_ticket WHERE ticket_id = batch_allocation.ticket_id))
);

-- 9. CREATE INDEXES for better query performance
CREATE INDEX idx_trip_vehicle ON trip(vehicle_id);
CREATE INDEX idx_trip_driver ON trip(driver_id);
CREATE INDEX idx_trip_zone ON trip(zone_id);
CREATE INDEX idx_trip_date ON trip(trip_date);
CREATE INDEX idx_ticket_trip ON weighbridge_ticket(trip_id);
CREATE INDEX idx_ticket_weight ON weighbridge_ticket(net_weight_kg);
CREATE INDEX idx_ticket_date ON weighbridge_ticket(weighbridge_date);
CREATE INDEX idx_batch_allocation_batch ON batch_allocation(batch_id);
CREATE INDEX idx_batch_allocation_material ON batch_allocation(material_id);
CREATE INDEX idx_batch_allocation_date ON batch_allocation(allocation_date);
CREATE INDEX idx_vehicle_number ON vehicle(vehicle_number);
CREATE INDEX idx_driver_license ON driver(license_number);
CREATE INDEX idx_zone_name ON zone(zone_name);

-- 10. CREATE SEQUENCE for batch numbering (optional but useful)
CREATE SEQUENCE batch_number_seq START 1000;

-- 11. Alter batch table to use sequence (optional)
-- ALTER TABLE processing_batch ADD COLUMN batch_number INTEGER DEFAULT nextval('batch_number_seq') UNIQUE;
