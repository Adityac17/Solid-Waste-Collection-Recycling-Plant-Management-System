-- Solid Waste Collection and Recycling Plant - Seed Data
-- Realistic sample data for testing queries

-- Insert Zones
INSERT INTO zone (zone_name, location, description, supervisor_contact) VALUES
('North Zone', 'North Delhi', 'Residential area with high population density', '9876543210'),
('South Zone', 'South Delhi', 'Commercial and residential mixed area', '9876543211'),
('East Zone', 'East Delhi', 'Industrial area with manufacturing units', '9876543212'),
('West Zone', 'West Delhi', 'Suburban area with moderate density', '9876543213'),
('Central Zone', 'Central Delhi', 'Commercial hub with offices and shops', '9876543214');

-- Insert Material Categories
INSERT INTO material_category (material_name, description, recovery_value, is_recyclable) VALUES
('Organic Waste', 'Food waste, vegetable waste', 50.00, TRUE),
('Plastic', 'Plastic bottles, bags, packaging', 15.00, TRUE),
('Paper', 'Cardboard, newspapers, office paper', 8.00, TRUE),
('Metal', 'Aluminum, steel, copper scrap', 200.00, TRUE),
('Glass', 'Bottles, jars, other glass items', 5.00, TRUE),
('Hazardous Waste', 'Chemicals, batteries, electronic waste', 0.00, FALSE),
('Construction Waste', 'Concrete, bricks, debris', 2.00, FALSE),
('Mixed Waste', 'Unsorted composite waste', 0.00, FALSE);

-- Insert Vehicles
INSERT INTO vehicle (vehicle_number, vehicle_type, capacity_kg, registration_date, last_service_date, status) VALUES
('DL-01-AB-1001', 'Tipper Truck', 5000.00, '2020-01-15', '2026-08-20', 'ACTIVE'),
('DL-01-AB-1002', 'Tipper Truck', 5000.00, '2020-06-10', '2026-07-15', 'ACTIVE'),
('DL-01-AB-1003', 'Compactor Truck', 8000.00, '2019-03-22', '2026-09-01', 'ACTIVE'),
('DL-01-AB-1004', 'Tipper Truck', 5000.00, '2021-05-18', '2026-08-10', 'MAINTENANCE'),
('DL-01-AB-1005', 'Open Bed Truck', 4000.00, '2021-11-25', '2026-06-30', 'ACTIVE'),
('DL-01-AB-1006', 'Compactor Truck', 8000.00, '2022-02-14', '2026-09-05', 'ACTIVE'),
('DL-01-AB-1007', 'Tipper Truck', 5000.00, '2022-09-08', '2026-08-25', 'INACTIVE');

-- Insert Drivers
INSERT INTO driver (driver_name, license_number, license_expiry, contact_number, email, date_of_birth, joining_date, status) VALUES
('Rajesh Kumar', 'DL-0001/2015', '2027-05-20', '9988776655', 'rajesh.kumar@waste.local', '1985-03-15', '2015-06-01', 'ACTIVE'),
('Priya Singh', 'DL-0002/2016', '2028-08-10', '9988776656', 'priya.singh@waste.local', '1988-07-22', '2016-09-15', 'ACTIVE'),
('Amit Patel', 'DL-0003/2017', '2027-12-05', '9988776657', 'amit.patel@waste.local', '1982-11-30', '2017-01-20', 'ACTIVE'),
('Vikram Sharma', 'DL-0004/2018', '2028-03-15', '9988776658', 'vikram.sharma@waste.local', '1990-04-12', '2018-05-10', 'ACTIVE'),
('Deepak Singh', 'DL-0005/2018', '2029-01-25', '9988776659', 'deepak.singh@waste.local', '1987-09-18', '2018-11-01', 'ACTIVE'),
('Suresh Verma', 'DL-0006/2019', '2028-06-20', '9988776660', 'suresh.verma@waste.local', '1986-02-10', '2019-07-15', 'ACTIVE'),
('Mohan Reddy', 'DL-0007/2019', '2027-09-30', '9988776661', 'mohan.reddy@waste.local', '1984-10-05', '2019-10-20', 'ON_LEAVE'),
('Ashok Kumar', 'DL-0008/2020', '2028-11-12', '9988776662', 'ashok.kumar@waste.local', '1991-12-22', '2020-12-01', 'ACTIVE'),
('Naveen Kumar', 'DL-0009/2021', '2029-04-08', '9988776663', 'naveen.kumar@waste.local', '1993-05-14', '2021-05-15', 'ACTIVE'),
('Rohan Das', 'DL-0010/2021', '2028-07-19', '9988776664', 'rohan.das@waste.local', '1989-08-20', '2021-08-10', 'ACTIVE');

-- Insert Trips
INSERT INTO trip (vehicle_id, driver_id, zone_id, trip_date, trip_time, status, comments) VALUES
-- North Zone trips
(1, 1, 1, '2026-09-15', '06:00:00', 'COMPLETED', 'Regular collection'),
(2, 2, 1, '2026-09-15', '07:30:00', 'COMPLETED', 'High density area'),
(3, 3, 1, '2026-09-16', '08:00:00', 'COMPLETED', 'Evening shift'),
(1, 1, 1, '2026-09-17', '06:15:00', 'COMPLETED', 'Regular collection'),

-- South Zone trips
(2, 4, 2, '2026-09-15', '09:00:00', 'COMPLETED', 'Commercial area'),
(4, 5, 2, '2026-09-16', '07:00:00', 'COMPLETED', 'Regular collection'),
(3, 6, 2, '2026-09-17', '08:30:00', 'COMPLETED', 'Heavy load'),
(5, 7, 2, '2026-09-15', '10:00:00', 'COMPLETED', 'Residential area'),

-- East Zone trips
(1, 2, 3, '2026-09-15', '11:00:00', 'COMPLETED', 'Industrial pickup'),
(3, 8, 3, '2026-09-16', '06:00:00', 'COMPLETED', 'Factory waste'),
(6, 9, 3, '2026-09-17', '09:00:00', 'COMPLETED', 'Multiple pickups'),
(2, 10, 3, '2026-09-14', '07:30:00', 'COMPLETED', 'Regular route'),

-- West Zone trips
(5, 1, 4, '2026-09-16', '10:00:00', 'COMPLETED', 'Suburban area'),
(1, 3, 4, '2026-09-17', '11:00:00', 'COMPLETED', 'High waste'),
(6, 4, 4, '2026-09-15', '12:00:00', 'COMPLETED', 'Afternoon shift'),
(3, 5, 4, '2026-09-14', '08:00:00', 'COMPLETED', 'Regular collection'),

-- Central Zone trips
(2, 6, 5, '2026-09-15', '14:00:00', 'COMPLETED', 'Office area'),
(1, 7, 5, '2026-09-16', '13:00:00', 'COMPLETED', 'Shopping complex'),
(4, 8, 5, '2026-09-17', '15:00:00', 'COMPLETED', 'Business district'),
(3, 9, 5, '2026-09-14', '14:30:00', 'COMPLETED', 'Mixed commercial');

-- Insert Weighbridge Tickets
INSERT INTO weighbridge_ticket (trip_id, gross_weight_kg, tare_weight_kg, net_weight_kg, weighbridge_date, weighbridge_time, weighbridge_operator, ticket_status) VALUES
(1, 6200.50, 1200.50, 5000.00, '2026-09-15', '06:30:00', 'Operator A', 'RECORDED'),
(2, 5800.75, 1300.75, 4500.00, '2026-09-15', '08:00:00', 'Operator B', 'RECORDED'),
(3, 8950.00, 950.00, 8000.00, '2026-09-16', '08:45:00', 'Operator C', 'RECORDED'),
(4, 6100.25, 1100.25, 5000.00, '2026-09-17', '06:45:00', 'Operator A', 'RECORDED'),
(5, 5400.50, 1400.50, 4000.00, '2026-09-15', '09:30:00', 'Operator D', 'RECORDED'),
(6, 4800.00, 1000.00, 3800.00, '2026-09-16', '07:30:00', 'Operator B', 'RECORDED'),
(7, 8200.75, 975.75, 7225.00, '2026-09-17', '09:00:00', 'Operator C', 'RECORDED'),
(8, 4300.00, 800.00, 3500.00, '2026-09-15', '10:30:00', 'Operator A', 'RECORDED'),
(9, 5900.50, 1100.50, 4800.00, '2026-09-15', '11:45:00', 'Operator E', 'RECORDED'),
(10, 8100.00, 900.00, 7200.00, '2026-09-16', '06:30:00', 'Operator C', 'RECORDED'),
(11, 7500.25, 850.25, 6650.00, '2026-09-17', '09:30:00', 'Operator D', 'RECORDED'),
(12, 5200.75, 1200.75, 4000.00, '2026-09-14', '08:00:00', 'Operator B', 'RECORDED'),
(13, 4500.00, 950.00, 3550.00, '2026-09-16', '10:45:00', 'Operator A', 'RECORDED'),
(14, 6300.50, 1300.50, 5000.00, '2026-09-17', '11:30:00', 'Operator E', 'RECORDED'),
(15, 7000.75, 800.75, 6200.00, '2026-09-15', '14:30:00', 'Operator C', 'RECORDED'),
(16, 5100.00, 1100.00, 4000.00, '2026-09-16', '13:45:00', 'Operator D', 'RECORDED'),
(17, 4900.25, 1100.25, 3800.00, '2026-09-17', '15:30:00', 'Operator B', 'RECORDED'),
(18, 8600.50, 850.50, 7750.00, '2026-09-14', '14:00:00', 'Operator A', 'RECORDED');

-- Insert Processing Batches
INSERT INTO processing_batch (batch_date, batch_capacity_kg, current_load_kg, status) VALUES
('2026-09-15', 20000.00, 15500.00, 'FULL'),
('2026-09-16', 20000.00, 18650.00, 'FULL'),
('2026-09-17', 20000.00, 19825.00, 'FULL'),
('2026-09-14', 20000.00, 11550.00, 'PROCESSING'),
('2026-09-18', 20000.00, 0.00, 'OPEN');

-- Insert Batch Allocations
INSERT INTO batch_allocation (batch_id, ticket_id, material_id, allocated_weight_kg) VALUES
-- Batch 1 (2026-09-15)
(1, 1, 1, 2500.00),
(1, 1, 2, 1500.00),
(1, 1, 3, 1000.00),
(1, 2, 1, 2250.00),
(1, 2, 3, 1500.00),
(1, 2, 4, 750.00),
(1, 8, 1, 1750.00),
(1, 8, 5, 1000.00),
(1, 8, 6, 750.00),
(1, 9, 2, 2400.00),
(1, 9, 3, 1600.00),
(1, 9, 4, 800.00),
(1, 15, 1, 3100.00),
(1, 15, 2, 2000.00),
(1, 15, 4, 1100.00),

-- Batch 2 (2026-09-16)
(2, 3, 1, 4000.00),
(2, 3, 2, 2500.00),
(2, 3, 7, 1500.00),
(2, 6, 1, 1900.00),
(2, 6, 3, 1200.00),
(2, 6, 5, 700.00),
(2, 10, 1, 3600.00),
(2, 10, 2, 2100.00),
(2, 10, 4, 1500.00),
(2, 16, 1, 2000.00),
(2, 16, 3, 1500.00),
(2, 16, 5, 500.00),
(2, 4, 2, 2500.00),
(2, 4, 3, 1500.00),
(2, 4, 4, 1000.00),

-- Batch 3 (2026-09-17)
(3, 5, 1, 2000.00),
(3, 5, 2, 1200.00),
(3, 5, 3, 800.00),
(3, 7, 1, 3612.50),
(3, 7, 2, 2312.50),
(3, 7, 6, 1300.00),
(3, 11, 1, 3325.00),
(3, 11, 3, 2112.50),
(3, 11, 4, 1212.50),
(3, 14, 1, 2500.00),
(3, 14, 2, 1500.00),
(3, 14, 5, 1000.00),
(3, 17, 1, 1900.00),
(3, 17, 3, 1200.00),
(3, 17, 7, 700.00),

-- Batch 4 (2026-09-14)
(4, 12, 1, 2000.00),
(4, 12, 2, 1200.00),
(4, 12, 3, 800.00),
(4, 13, 1, 1775.00),
(4, 13, 5, 1000.00),
(4, 13, 6, 775.00),
(4, 18, 1, 3875.00),
(4, 18, 2, 2437.50),
(4, 18, 4, 1437.50);

-- Verify data integrity
SELECT 'ZONES INSERTED:' AS info, COUNT(*) FROM zone;
SELECT 'MATERIALS INSERTED:' AS info, COUNT(*) FROM material_category;
SELECT 'VEHICLES INSERTED:' AS info, COUNT(*) FROM vehicle;
SELECT 'DRIVERS INSERTED:' AS info, COUNT(*) FROM driver;
SELECT 'TRIPS INSERTED:' AS info, COUNT(*) FROM trip;
SELECT 'TICKETS INSERTED:' AS info, COUNT(*) FROM weighbridge_ticket;
SELECT 'BATCHES INSERTED:' AS info, COUNT(*) FROM processing_batch;
SELECT 'ALLOCATIONS INSERTED:' AS info, COUNT(*) FROM batch_allocation;
