-- Solid Waste Collection and Recycling Plant - Transactions and Concurrency Demonstration
-- PostgreSQL Implementation

-- ============================================================================
-- TRANSACTION 1: Record a new trip and weighing with rollback scenario
-- ============================================================================
-- Purpose: Demonstrate atomic transaction with rollback on error
-- Business Use: Ensure data consistency when recording collection activities

BEGIN;
    -- Insert new trip
    INSERT INTO trip (vehicle_id, driver_id, zone_id, trip_date, trip_time, status, comments)
    VALUES (1, 1, 1, '2026-09-18', '06:00:00', 'COMPLETED', 'Test transaction trip');

    -- Get the inserted trip ID
    -- In real application: SELECT lastval() or RETURNING clause

    -- Insert corresponding weighbridge ticket
    INSERT INTO weighbridge_ticket
    (trip_id, gross_weight_kg, tare_weight_kg, net_weight_kg, weighbridge_date,
     weighbridge_time, weighbridge_operator, ticket_status)
    VALUES
    (19, 5500.00, 1000.00, 4500.00, '2026-09-18', '06:30:00', 'Operator Test', 'RECORDED');

    -- Verify the insertion
    SELECT 'Trip and Ticket Inserted Successfully' AS transaction_status;
    SELECT COUNT(*) AS total_trips FROM trip WHERE trip_date = '2026-09-18';

COMMIT;

-- Show inserted data
SELECT * FROM trip WHERE trip_date = '2026-09-18';
SELECT * FROM weighbridge_ticket WHERE weighbridge_date = '2026-09-18';

-- ============================================================================
-- TRANSACTION 2: Batch allocation with error handling (Intentional Rollback)
-- ============================================================================
-- Purpose: Demonstrate rollback on constraint violation
-- Business Use: Ensure batch capacity is never exceeded

BEGIN;
    -- Try to allocate waste to a batch
    INSERT INTO batch_allocation
    (batch_id, ticket_id, material_id, allocated_weight_kg)
    VALUES
    (1, 19, 1, 2500.00),
    (1, 19, 2, 2000.00);

    -- This would violate the constraint if current_load + allocated > capacity
    -- Update batch current load
    UPDATE processing_batch
    SET current_load_kg = current_load_kg + 4500.00
    WHERE batch_id = 1;

    -- Verify batch capacity before commit
    SELECT batch_id, batch_capacity_kg, current_load_kg,
           batch_capacity_kg - current_load_kg AS remaining
    FROM processing_batch
    WHERE batch_id = 1;

-- ROLLBACK; -- Uncomment to rollback
COMMIT; -- Changed to COMMIT for demo

-- ============================================================================
-- TRANSACTION 3: Multi-step trip completion process
-- ============================================================================
-- Purpose: Complete workflow with validation at each step
-- Business Use: Ensure all trip records are properly completed

BEGIN;
    -- Step 1: Create new trip
    INSERT INTO trip (vehicle_id, driver_id, zone_id, trip_date, trip_time, status)
    VALUES (2, 2, 2, '2026-09-18', '09:00:00', 'COMPLETED');

    -- Step 2: Record weighbridge data
    INSERT INTO weighbridge_ticket
    (trip_id, gross_weight_kg, tare_weight_kg, net_weight_kg, weighbridge_date,
     weighbridge_time, weighbridge_operator)
    VALUES
    (20, 5200.00, 1100.00, 4100.00, '2026-09-18', '09:30:00', 'Operator A');

    -- Step 3: Allocate to batch
    INSERT INTO batch_allocation
    (batch_id, ticket_id, material_id, allocated_weight_kg)
    VALUES
    (5, 20, 1, 2000.00),
    (5, 20, 3, 2100.00);

    -- Step 4: Update batch capacity
    UPDATE processing_batch
    SET current_load_kg = current_load_kg + 4100.00,
        status = CASE
            WHEN (current_load_kg + 4100.00) >= batch_capacity_kg THEN 'FULL'
            ELSE 'OPEN'
        END
    WHERE batch_id = 5;

    -- Step 5: Verify transaction integrity
    SELECT 'All steps completed successfully' AS status;
    SELECT COUNT(*) AS allocations FROM batch_allocation WHERE batch_id = 5;

COMMIT;

-- Verify final state
SELECT * FROM trip WHERE trip_date = '2026-09-18' ORDER BY trip_id DESC LIMIT 2;
SELECT * FROM processing_batch WHERE batch_id = 5;

-- ============================================================================
-- TRANSACTION 4: Savepoint demonstration - Partial rollback
-- ============================================================================
-- Purpose: Show how savepoints allow partial rollback
-- Business Use: Complex updates with error recovery

BEGIN;
    -- Main work starts here
    UPDATE driver
    SET status = 'INACTIVE'
    WHERE driver_id = 7;

    SAVEPOINT sp1;

    -- Try to update license expiry (might violate business rule)
    UPDATE driver
    SET license_expiry = '2024-01-01'
    WHERE driver_id = 7;

    -- Check data
    SELECT driver_id, driver_name, status, license_expiry
    FROM driver
    WHERE driver_id = 7;

    -- Decide to rollback just the license update
    ROLLBACK TO SAVEPOINT sp1;

    -- This part remains
    UPDATE driver
    SET license_expiry = DATE '2027-09-30'
    WHERE driver_id = 7;

COMMIT;

-- Verify
SELECT driver_id, driver_name, status, license_expiry
FROM driver
WHERE driver_id = 7;

-- ============================================================================
-- CONCURRENCY SCENARIO 1: Lost Update Problem
-- ============================================================================
-- Purpose: Demonstrate dirty read and lost update scenarios
-- Instructions: Run this in two separate sessions simultaneously

-- Session 1: Read batch capacity
-- Session 1: Step A - Read current capacity
SELECT 'SESSION 1 - STEP A' AS session_id, batch_id, current_load_kg FROM processing_batch WHERE batch_id = 5;

-- Session 2: Step B - Read current capacity (same value as Session 1)
-- SELECT 'SESSION 2 - STEP B' AS session_id, batch_id, current_load_kg FROM processing_batch WHERE batch_id = 5;

-- Session 1: Step C - Update based on read value
-- UPDATE processing_batch SET current_load_kg = 100 WHERE batch_id = 5;
-- COMMIT;

-- Session 2: Step D - Update based on OLD read value (Lost update!)
-- UPDATE processing_batch SET current_load_kg = 200 WHERE batch_id = 5;
-- COMMIT;

-- Result: Session 2's update overwrites Session 1's update (lost update)

-- ============================================================================
-- CONCURRENCY SCENARIO 2: Read consistency with serializable isolation
-- ============================================================================
-- Purpose: Prevent phantom reads and dirty reads

-- Session 1: Start serializable transaction
BEGIN ISOLATION LEVEL SERIALIZABLE;
    SELECT COUNT(*) AS trip_count FROM trip WHERE zone_id = 1 AND trip_date = '2026-09-18';

    -- At this point, Session 2 tries to insert a new trip for same zone/date
    -- Session 1 will see consistent view

    SELECT COUNT(*) AS trip_count_2 FROM trip WHERE zone_id = 1 AND trip_date = '2026-09-18';

COMMIT;

-- ============================================================================
-- CONCURRENCY SCENARIO 3: Phantom Read Scenario
-- ============================================================================
-- Purpose: Demonstrate phantom read with different isolation levels

-- Session 1: Read all zones
BEGIN;
    SELECT COUNT(*) AS initial_zone_count FROM zone;

    -- Session 2 inserts new zone here

    -- Session 1 reads again - might see new zone (phantom read)
    SELECT COUNT(*) AS after_insert_zone_count FROM zone;

COMMIT;

-- ============================================================================
-- DEMONSTRATION: Batch allocation with concurrency control
-- ============================================================================
-- Purpose: Show how to handle concurrent batch allocations

-- Scenario: Two drivers submit trips to same batch simultaneously
-- Using row-level locking to prevent over-allocation

BEGIN;
    -- Lock the batch for update
    SELECT batch_id, current_load_kg, batch_capacity_kg
    FROM processing_batch
    WHERE batch_id = 4
    FOR UPDATE;

    -- Now safely check if allocation is possible
    -- and update
    UPDATE processing_batch
    SET current_load_kg = current_load_kg + 1000
    WHERE batch_id = 4
    AND (current_load_kg + 1000) <= batch_capacity_kg;

COMMIT;

-- ============================================================================
-- PERFORMANCE TEST: Transaction timing
-- ============================================================================
-- Purpose: Demonstrate transaction isolation and performance

-- Single transaction with multiple operations
BEGIN;
    -- Bulk insert of allocations
    INSERT INTO batch_allocation (batch_id, ticket_id, material_id, allocated_weight_kg)
    SELECT 4, 18, material_id, 100.00
    FROM material_category
    LIMIT 5;

    -- Check results
    SELECT COUNT(*) FROM batch_allocation WHERE batch_id = 4;

COMMIT;

-- ============================================================================
-- PRACTICAL SCENARIO: Daily batch completion
-- ============================================================================
-- Purpose: Real-world transaction showing batch processing workflow

BEGIN;
    DECLARE batch_date DATE := CURRENT_DATE - 1;

    -- Find all open batches from yesterday
    -- Mark them as completed
    UPDATE processing_batch
    SET status = 'COMPLETED'
    WHERE batch_date = batch_date
    AND status != 'COMPLETED';

    -- Get summary of completed batches
    SELECT batch_id, batch_capacity_kg, current_load_kg,
           ROUND((current_load_kg::numeric / batch_capacity_kg) * 100, 2) AS fill_rate
    FROM processing_batch
    WHERE batch_date = batch_date
    AND status = 'COMPLETED';

COMMIT;

-- ============================================================================
-- PRACTICAL SCENARIO: Vehicle maintenance scheduling
-- ============================================================================
-- Purpose: Update vehicle status and reschedule trips

BEGIN;
    -- Mark vehicle for maintenance
    UPDATE vehicle
    SET status = 'MAINTENANCE',
        last_service_date = CURRENT_DATE
    WHERE vehicle_id = 4;

    -- Cancel its pending trips
    UPDATE trip
    SET status = 'CANCELLED',
        comments = 'Vehicle maintenance'
    WHERE vehicle_id = 4
    AND status = 'PENDING';

    -- Verify changes
    SELECT 'Vehicle maintenance scheduled' AS action;
    SELECT COUNT(*) AS cancelled_trips
    FROM trip
    WHERE vehicle_id = 4 AND status = 'CANCELLED';

COMMIT;

-- ============================================================================
-- LOCKING DEMONSTRATION: Explicit locking for critical operations
-- ============================================================================
-- Purpose: Show row-level locking for data consistency

BEGIN;
    -- Lock trip for update (no other transaction can modify until commit)
    SELECT * FROM trip WHERE trip_id = 1 FOR UPDATE;

    -- Safe to make modifications
    UPDATE trip
    SET status = 'CANCELLED'
    WHERE trip_id = 1;

COMMIT;

-- ============================================================================
-- DEADLOCK SCENARIO (Educational - Do not run simultaneously)
-- ============================================================================
-- Purpose: Demonstrate deadlock possibility and prevention

-- Session 1: Lock in order A -> B
-- BEGIN;
-- SELECT * FROM processing_batch WHERE batch_id = 1 FOR UPDATE;
-- -- Session 2 now tries: Lock in order B -> A (deadlock!)
-- SELECT * FROM processing_batch WHERE batch_id = 2 FOR UPDATE;
-- COMMIT;

-- Prevention: Always lock resources in same order
-- Always: Lock batches before zones, or zones before trips, etc.

-- ============================================================================
-- FINAL VERIFICATION QUERIES
-- ============================================================================

-- Show all transactions were committed
SELECT 'Transaction Execution Summary' AS Summary;
SELECT COUNT(*) AS Total_Trips FROM trip;
SELECT COUNT(*) AS Total_Allocations FROM batch_allocation;
SELECT COUNT(*) AS Total_Batches FROM processing_batch;
SELECT COUNT(*) AS Total_Tickets FROM weighbridge_ticket;
