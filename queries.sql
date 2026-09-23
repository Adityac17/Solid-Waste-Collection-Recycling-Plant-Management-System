-- Solid Waste Collection and Recycling Plant - 20 Business Queries

-- ############################################################################
-- ADITYA CHOUKSEY - Aggregation & Filtering
-- Queries: 2, 3, 5, 6, 7, 8, 9, 10
-- ############################################################################


-- QUERY 2: List weighbridge tickets whose net weight lies between two values

SELECT
    wt.ticket_id,
    t.trip_id,
    wt.weighbridge_date,
    wt.gross_weight_kg,
    wt.tare_weight_kg,
    wt.net_weight_kg,
    z.zone_name,
    v.vehicle_number
FROM weighbridge_ticket wt
JOIN trip t 
ON wt.trip_id = t.trip_id
JOIN zone z 
ON t.zone_id = z.zone_id
JOIN vehicle v 
ON t.vehicle_id = v.vehicle_id
WHERE wt.net_weight_kg BETWEEN 4000 AND 6000
ORDER BY wt.net_weight_kg DESC;


-- QUERY 3: Find vehicles whose number matches a given pattern

SELECT
    vehicle_id,
    vehicle_number,
    vehicle_type,
    capacity_kg,
    status,
    registration_date
FROM vehicle
WHERE vehicle_number LIKE 'DL-01-AB-%'
ORDER BY vehicle_number;


-- QUERY 5: Show the five heaviest trips recorded

SELECT
    wt.ticket_id,
    t.trip_id,
    z.zone_name,
    v.vehicle_number,
    d.driver_name,
    wt.net_weight_kg,
    t.trip_date,
    RANK() OVER (ORDER BY wt.net_weight_kg DESC) AS weight_rank
FROM weighbridge_ticket wt
JOIN trip t 
ON wt.trip_id = t.trip_id
JOIN zone z 
ON t.zone_id = z.zone_id
JOIN vehicle v 
ON t.vehicle_id = v.vehicle_id
JOIN driver d 
ON t.driver_id = d.driver_id
ORDER BY wt.net_weight_kg DESC
LIMIT 5;


-- QUERY 6: Count the number of trips made by each vehicle

SELECT
    v.vehicle_id,
    v.vehicle_number,
    v.vehicle_type,
    v.capacity_kg,
    COUNT(t.trip_id) AS total_trips,
    ROUND(AVG(wt.net_weight_kg), 2) AS avg_load_kg,
    SUM(wt.net_weight_kg) AS total_tonnage_kg
FROM vehicle v
LEFT JOIN trip t 
ON v.vehicle_id = t.vehicle_id
LEFT JOIN weighbridge_ticket wt 
ON t.trip_id = wt.trip_id
GROUP BY v.vehicle_id, v.vehicle_number, v.vehicle_type, v.capacity_kg
ORDER BY total_trips DESC;


-- QUERY 7: Total tonnage collected from each zone

SELECT
    z.zone_id,
    z.zone_name,
    z.location,
    COUNT(t.trip_id) AS total_trips,
    ROUND(SUM(wt.net_weight_kg)/1000, 2) AS total_tonnage,
    ROUND(AVG(wt.net_weight_kg), 2) AS avg_weight_per_trip,
    MAX(wt.net_weight_kg) AS max_trip_weight
FROM zone z
LEFT JOIN trip t ON z.zone_id = t.zone_id
LEFT JOIN weighbridge_ticket wt ON t.trip_id = wt.trip_id
GROUP BY z.zone_id, z.zone_name, z.location
ORDER BY total_tonnage DESC;


-- QUERY 8: Average net weight carried by each driver

SELECT
    d.driver_id,
    d.driver_name,
    d.license_number,
    d.status,
    COUNT(t.trip_id) AS total_trips,
    ROUND(AVG(wt.net_weight_kg), 2) AS avg_load_kg,
    ROUND(SUM(wt.net_weight_kg)/1000, 2) AS total_tonnage,
    ROUND(MIN(wt.net_weight_kg), 2) AS lightest_load,
    ROUND(MAX(wt.net_weight_kg), 2) AS heaviest_load
FROM driver d
LEFT JOIN trip t 
ON d.driver_id = t.driver_id
LEFT JOIN weighbridge_ticket wt 
ON t.trip_id = wt.trip_id
GROUP BY d.driver_id, d.driver_name, d.license_number, d.status
ORDER BY avg_load_kg DESC;


-- QUERY 9: Highest and lowest net weight recorded for each material category

SELECT
    mc.material_id,
    mc.material_name,
    COUNT(ba.allocation_id) AS allocations,
    ROUND(MAX(ba.allocated_weight_kg), 2) AS max_allocation_kg,
    ROUND(MIN(ba.allocated_weight_kg), 2) AS min_allocation_kg,
    ROUND(AVG(ba.allocated_weight_kg), 2) AS avg_allocation_kg,
    ROUND(SUM(ba.allocated_weight_kg)/1000, 2) AS total_tonnage,
    ROUND(SUM(ba.allocated_weight_kg) * mc.recovery_value / 1000, 2) AS recovery_value_estimated
FROM material_category mc
LEFT JOIN batch_allocation ba 
ON mc.material_id = ba.material_id
GROUP BY mc.material_id, mc.material_name, mc.recovery_value
ORDER BY total_tonnage DESC;

-- QUERY 10: List zones whose total tonnage exceeds a stated limit

SELECT
    z.zone_id,
    z.zone_name,
    z.location,
    z.supervisor_contact,
    COUNT(DISTINCT t.trip_id) AS total_trips,
    ROUND(SUM(wt.net_weight_kg)/1000, 2) AS total_tonnage,
    ROUND(AVG(wt.net_weight_kg), 2) AS avg_trip_weight
FROM zone z
JOIN trip t 
ON z.zone_id = t.zone_id
JOIN weighbridge_ticket wt 
ON t.trip_id = wt.trip_id
GROUP BY z.zone_id, z.zone_name, z.location, z.supervisor_contact
HAVING ROUND(SUM(wt.net_weight_kg)/1000, 2) > 30
ORDER BY total_tonnage DESC;

-- ############################################################################
-- TANAY SHELAR - Setup & Core Queries
-- Queries: 1, 4, 12, 13
-- ############################################################################

-- QUERY 1: List all trips in a given zone sorted by net weight descending

SELECT
    t.trip_id,
    z.zone_name,
    v.vehicle_number,
    d.driver_name,
    t.trip_date,
    wt.net_weight_kg,
    wt.weighbridge_time
FROM trip t
JOIN zone z 
ON t.zone_id = z.zone_id
JOIN vehicle v 
ON t.vehicle_id = v.vehicle_id
JOIN driver d 
ON t.driver_id = d.driver_id
JOIN weighbridge_ticket wt 
ON t.trip_id = wt.trip_id
WHERE z.zone_name = 'North Zone'
ORDER BY wt.net_weight_kg DESC;


-- QUERY 4: List the distinct material categories processed at the plant

SELECT DISTINCT
    mc.material_id,
    mc.material_name,
    mc.description,
    mc.recovery_value,
    mc.is_recyclable,
    COUNT(ba.allocation_id) AS times_allocated
FROM material_category mc
LEFT JOIN batch_allocation ba ON mc.material_id = ba.material_id
GROUP BY mc.material_id, mc.material_name, mc.description, mc.recovery_value, mc.is_recyclable
ORDER BY mc.material_name;


-- QUERY 12: List vehicles with no trip recorded

SELECT
    v.vehicle_id,
    v.vehicle_number,
    v.vehicle_type,
    v.capacity_kg,
    v.status,
    v.registration_date,
    v.last_service_date
FROM vehicle v
LEFT JOIN trip t 
ON v.vehicle_id = t.vehicle_id
WHERE t.trip_id IS NULL
ORDER BY v.registration_date;


-- QUERY 13: List all tickets above given weight with driver, vehicle and zone

SELECT
    wt.ticket_id,
    t.trip_id,
    wt.net_weight_kg,
    d.driver_name,
    v.vehicle_number,
    z.zone_name,
    wt.weighbridge_date,
    CASE
        WHEN wt.net_weight_kg > 7000 THEN 'HEAVY'
        WHEN wt.net_weight_kg > 5000 THEN 'MEDIUM'
        ELSE 'LIGHT'
    END AS load_category
FROM weighbridge_ticket wt
JOIN trip t 
ON wt.trip_id = t.trip_id
JOIN driver d 
ON t.driv5er_id = d.driver_id
JOIN vehicle v 
ON t.vehicle_id = v.vehicle_id
JOIN zone z 
ON t.zone_id = z.zone_id
WHERE wt.net_weight_kg > 6500
ORDER BY wt.net_weight_kg DESC;

-- ############################################################################
-- JANMESH ROHIDA - Advanced SQL
-- Queries: 11, 14, 15, 16, 17, 18, 19, 20
-- ############################################################################

-- ============================================================================
-- QUERY 11: Zone wise collection report (Multi-table join)
-- ============================================================================
-- Purpose: Comprehensive zone performance report
-- Business Use: Management reporting and decision making
SELECT
    z.zone_name,
    t.trip_date,
    v.vehicle_number,
    d.driver_name,
    wt.net_weight_kg,
    wt.weighbridge_date,
    wt.weighbridge_time,
    t.status,
    COUNT(*) OVER (PARTITION BY z.zone_id) AS zone_total_trips
FROM trip t
JOIN zone z 
ON t.zone_id = z.zone_id
JOIN vehicle v 
ON t.vehicle_id = v.vehicle_id
JOIN driver d 
ON t.driver_id = d.driver_id
JOIN weighbridge_ticket wt 
ON t.trip_id = wt.trip_id
ORDER BY z.zone_name, t.trip_date DESC;

-- ============================================================================
-- QUERY 14: Self-join - List drivers who worked the same zone
-- ============================================================================
-- Purpose: Zone expertise and team composition
-- Business Use: Shift planning and zone coverage optimization
SELECT DISTINCT
    d1.driver_name AS driver_1,
    d2.driver_name AS driver_2,
    z.zone_name,
    COUNT(DISTINCT CASE WHEN t1.trip_id IS NOT NULL THEN t1.trip_id END) AS driver1_trips,
    COUNT(DISTINCT CASE WHEN t2.trip_id IS NOT NULL THEN t2.trip_id END) AS driver2_trips
FROM driver d1
JOIN trip t1 
ON d1.driver_id = t1.driver_id
JOIN zone z 
ON t1.zone_id = z.zone_id
JOIN trip t2 
ON t2.zone_id = z.zone_id
JOIN driver d2 
ON t2.driver_id = d2.driver_id
WHERE d1.driver_id < d2.driver_id
GROUP BY d1.driver_id, d1.driver_name, d2.driver_id, d2.driver_name, z.zone_id, z.zone_name
ORDER BY z.zone_name, d1.driver_name;

-- ============================================================================
-- QUERY 15: Processing batch report - material, weight and capacity
-- ============================================================================
-- Purpose: Batch fill analysis and processing status
-- Business Use: Production planning and waste processing optimization
SELECT
    pb.batch_id,
    pb.batch_date,
    pb.batch_capacity_kg,
    pb.current_load_kg,
    ROUND((pb.current_load_kg::numeric / pb.batch_capacity_kg::numeric) * 100, 2) AS fill_percentage,
    pb.batch_capacity_kg - pb.current_load_kg AS remaining_capacity_kg,
    pb.status,
    mc.material_name,
    COUNT(ba.allocation_id) AS material_allocations,
    ROUND(SUM(ba.allocated_weight_kg), 2) AS material_weight_kg
FROM processing_batch pb
LEFT JOIN batch_allocation ba 
ON pb.batch_id = ba.batch_id
LEFT JOIN material_category mc 
ON ba.material_id = mc.material_id
GROUP BY pb.batch_id, pb.batch_date, pb.batch_capacity_kg, pb.current_load_kg,
         pb.status, mc.material_id, mc.material_name
ORDER BY pb.batch_date DESC, pb.batch_id;

-- ============================================================================
-- QUERY 16: Drivers whose trip count is above overall average
-- ============================================================================
-- Purpose: High-performing drivers identification
-- Business Use: Performance incentives and team recognition
WITH driver_trip_stats AS (
    SELECT
        d.driver_id,
        d.driver_name,
        d.status,
        COUNT(t.trip_id) AS trip_count,
        ROUND(AVG(wt.net_weight_kg), 2) AS avg_load
    FROM driver d
    LEFT JOIN trip t 
    ON d.driver_id = t.driver_id
    LEFT JOIN weighbridge_ticket wt 
    ON t.trip_id = wt.trip_id
    GROUP BY d.driver_id, d.driver_name, d.status
),
avg_stats AS (
    SELECT AVG(trip_count) AS overall_avg_trips FROM driver_trip_stats
)
SELECT
    dts.driver_id,
    dts.driver_name,
    dts.status,
    dts.trip_count,
    ROUND(avg_stats.overall_avg_trips, 2) AS overall_avg,
    dts.trip_count - ROUND(avg_stats.overall_avg_trips, 0) AS above_average_trips,
    dts.avg_load,
    ROUND((dts.trip_count / avg_stats.overall_avg_trips) * 100, 2) AS percentage_of_average
FROM driver_trip_stats dts
CROSS JOIN avg_stats
WHERE dts.trip_count > avg_stats.overall_avg_trips
ORDER BY dts.trip_count DESC;

-- ============================================================================
-- QUERY 17: Drivers whose trip count is above average of their own zone
-- ============================================================================
-- Purpose: Zone-level performance benchmarking
-- Business Use: Zone-specific incentive allocation
WITH zone_driver_stats AS (
    SELECT
        z.zone_id,
        z.zone_name,
        d.driver_id,
        d.driver_name,
        COUNT(t.trip_id) AS trip_count
    FROM zone z
    LEFT JOIN trip t 
    ON z.zone_id = t.zone_id
    LEFT JOIN driver d 
    ON t.driver_id = d.driver_id
    GROUP BY z.zone_id, z.zone_name, d.driver_id, d.driver_name
),
zone_avg AS (
    SELECT
        zone_id,
        zone_name,
        AVG(trip_count) AS zone_avg_trips
    FROM zone_driver_stats
    GROUP BY zone_id, zone_name
)
SELECT
    zds.zone_name,
    zds.driver_name,
    zds.trip_count,
    za.zone_avg_trips,
    ROUND(zds.trip_count - za.zone_avg_trips, 2) AS above_zone_average
FROM zone_driver_stats zds
JOIN zone_avg za 
ON zds.zone_id = za.zone_id
WHERE zds.trip_count > za.zone_avg_trips
ORDER BY zds.zone_name, zds.trip_count DESC;

-- ============================================================================
-- QUERY 18: Trips made in any zone from a given list using IN
-- ============================================================================
-- Purpose: Multi-zone report generation
-- Business Use: Regional performance analysis
SELECT
    t.trip_id,
    z.zone_name,
    d.driver_name,
    v.vehicle_number,
    t.trip_date,
    wt.net_weight_kg,
    t.status
FROM trip t
LEFT JOIN zone z 
ON t.zone_id = z.zone_id
JOIN driver d
ON t.driver_id = d.driver_id
JOIN vehicle v 
ON t.vehicle_id = v.vehicle_id
JOIN weighbridge_ticket wt 
ON t.trip_id = wt.trip_id
WHERE z.zone_name IN ('North Zone', 'East Zone', 'Central Zone')
ORDER BY z.zone_name, t.trip_date DESC;

-- ============================================================================
-- QUERY 19: Material categories never allocated to any batch using NOT EXISTS
-- ============================================================================
-- Purpose: Identify unused material categories
-- Business Use: Process improvement and operational planning
SELECT
    mc.material_id,
    mc.material_name,
    mc.description,
    mc.recovery_value,
    mc.is_recyclable
FROM material_category mc
WHERE NOT EXISTS (
    SELECT 1 FROM batch_allocation ba
    WHERE ba.material_id = mc.material_id
)
ORDER BY mc.material_name;

-- ============================================================================
-- QUERY 20: Trips heavier than every trip in a named zone using ALL
-- ============================================================================
-- Purpose: Comparative load analysis
-- Business Use: Route optimization and vehicle allocation
SELECT
    t.trip_id,
    z.zone_name,
    d.driver_name,
    v.vehicle_number,
    wt.net_weight_kg,
    t.trip_date,
    (SELECT MAX(wt2.net_weight_kg)
     FROM weighbridge_ticket wt2
     JOIN trip t2 ON wt2.trip_id = t2.trip_id
     WHERE t2.zone_id = (SELECT zone_id FROM zone WHERE zone_name = 'South Zone')
    ) AS south_zone_max_weight
FROM trip t
JOIN zone z 
ON t.zone_id = z.zone_id
JOIN driver d
ON t.driver_id = d.driver_id
JOIN vehicle v 
ON t.vehicle_id = v.vehicle_id
JOIN weighbridge_ticket wt 
ON t.trip_id = wt.trip_id
WHERE wt.net_weight_kg > ALL (
    SELECT wt3.net_weight_kg
    FROM weighbridge_ticket wt3
    JOIN trip t3 
    ON wt3.trip_id = t3.trip_id
    WHERE t3.zone_id = (SELECT zone_id FROM zone WHERE zone_name = 'South Zone')
)
ORDER BY wt.net_weight_kg DESC;