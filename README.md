# Solid Waste Collection and Recycling Plant - Database Project

## Project Overview

This project implements a comprehensive PostgreSQL database system for managing solid waste collection, weighing, and processing at a municipal recycling plant. The system tracks waste collection trips zone-by-zone, records weights at weighbridges, allocates waste to processing batches by material category, and provides zone-wise and material-wise reporting.

---

## ER Model Design

### Entities Identified

#### 1. **ZONE**
- Represents geographic areas for waste collection
- Attributes: zone_id (PK), zone_name, location, description, supervisor_contact
- Cardinality: 1 Zone → Many Trips

#### 2. **VEHICLE**
- Represents collection vehicles/trucks
- Attributes: vehicle_id (PK), vehicle_number (UNIQUE), vehicle_type, capacity_kg, registration_date, last_service_date, status
- Cardinality: 1 Vehicle → Many Trips
- Business Rules: capacity > 0, status IN ('ACTIVE', 'INACTIVE', 'MAINTENANCE')

#### 3. **DRIVER**
- Represents vehicle operators
- Attributes: driver_id (PK), driver_name, license_number (UNIQUE), license_expiry, contact_number, email, date_of_birth, status, joining_date
- Cardinality: 1 Driver → Many Trips
- Business Rules: status IN ('ACTIVE', 'INACTIVE', 'ON_LEAVE'), license_expiry must be future date

#### 4. **TRIP**
- Represents individual waste collection journeys
- Attributes: trip_id (PK), vehicle_id (FK), driver_id (FK), zone_id (FK), trip_date, trip_time, status, comments
- Cardinality: Vehicle → 1-Many → Trip, Driver → 1-Many → Trip, Zone → 1-Many → Trip
- Constraints: Composite unique (vehicle_id, driver_id, zone_id, trip_date)
- Business Rules: status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')

#### 5. **WEIGHBRIDGE_TICKET**
- Records weight measurements at weighbridge
- Attributes: ticket_id (PK), trip_id (FK, UNIQUE), gross_weight_kg, tare_weight_kg, net_weight_kg (calculated), weighbridge_date, weighbridge_time, weighbridge_operator, ticket_status
- Cardinality: 1 Trip → 1 Weighbridge Ticket
- Constraints: net_weight_kg = gross_weight_kg - tare_weight_kg (CHECK constraint)
- Business Rules: Ensures weight calculation accuracy

#### 6. **MATERIAL_CATEGORY**
- Classifies waste types being processed
- Attributes: material_id (PK), material_name (UNIQUE), description, recovery_value, is_recyclable
- Cardinality: 1 Material → Many Batch Allocations
- Business Rules: Different materials have different recovery values and recyclability status

#### 7. **PROCESSING_BATCH**
- Groups waste for processing
- Attributes: batch_id (PK), batch_date, batch_capacity_kg, current_load_kg, status
- Cardinality: 1 Batch → Many Allocations
- Business Rules: current_load_kg ≤ batch_capacity_kg, status tracks filling progress

#### 8. **BATCH_ALLOCATION** (Junction Table)
- Links weighbridge tickets to processing batches with material classification
- Attributes: allocation_id (PK), batch_id (FK), ticket_id (FK), material_id (FK), allocated_weight_kg, allocation_date
- Cardinality: Many-to-Many relationship
- Constraints: Foreign keys to Batch, Ticket, Material; CHECK constraint on allocated_weight_kg
- Business Rules: allocated_weight_kg cannot exceed ticket's net_weight_kg

---

## Database Schema Overview

### Key Design Decisions

1. **Surrogate Keys**: Used SERIAL (auto-increment) for all primary keys for:
   - Performance in joins
   - Database independence
   - Simplicity in foreign key references

2. **Candidate Keys**: 
   - vehicle_number (UNIQUE) - registration number is business identifier
   - license_number (UNIQUE) - driver's license is globally unique
   - material_name (UNIQUE) - material types are uniquely named
   - zone_name (UNIQUE) - zone names are business identifiers

3. **Constraints for Data Integrity**:
   - CHECK constraints on capacity (> 0)
   - CHECK constraints on weights (> 0, valid calculations)
   - Foreign key constraints with ON DELETE RESTRICT to prevent orphaned records
   - UNIQUE constraints for business identifiers
   - Composite UNIQUE constraints to prevent duplicate trip records

4. **Indexes**: Created on frequently queried columns:
   - Foreign keys (vehicle, driver, zone, batch)
   - Date columns for range queries
   - Weight columns for filtering
   - Business identifiers for searches

5. **Data Normalization**: Third Normal Form (3NF)
   - No transitive dependencies
   - All non-key attributes depend on primary key
   - Proper decomposition to eliminate redundancy

---

## Seed Data Specifications

### Data Volume
- **5 Zones**: North, South, East, West, Central
- **8 Material Categories**: Organic, Plastic, Paper, Metal, Glass, Hazardous, Construction, Mixed
- **7 Vehicles**: Mix of Tipper and Compactor trucks with varying capacities
- **10 Drivers**: Active, on-leave, and inactive statuses represented
- **18 Trips**: Distributed across zones and dates
- **18 Weighbridge Tickets**: One per trip with realistic weight data
- **5 Processing Batches**: Various fill levels from open to full
- **49 Batch Allocations**: Multiple materials allocated to batches

### Realistic Characteristics
- Vehicle capacities range from 4,000 to 8,000 kg
- Net weights vary from 3,500 to 8,000 kg
- Dates span September 14-18, 2026
- Multiple drivers per zone for shift coverage
- Batch utilization ranges from 0% (open) to 99% (full)
- Mix of vehicle types and driver statuses

---

## 20 Queries Implementation

### Query 1: Trips by Zone (Sorted by Weight)
**Business Purpose**: Identify heaviest loads from specific zones for route optimization
```sql
SELECT trips in North Zone ordered by net weight descending
```
**Use Case**: Zone manager analyzing collection efficiency

### Query 2: Weight Range Filtering
**Business Purpose**: Find trips within specific weight ranges for batch assembly
```sql
SELECT tickets with net_weight BETWEEN 4000 AND 6000 kg
```
**Use Case**: Batch planning and load balancing

### Query 3: Vehicle Pattern Search
**Business Purpose**: Search vehicles by registration number pattern
```sql
LIKE 'DL-01-AB-%'
```
**Use Case**: Fleet management and vehicle tracking

### Query 4: Distinct Material Categories
**Business Purpose**: Show all waste types being processed with allocation frequency
```sql
SELECT DISTINCT materials with allocation counts
```
**Use Case**: Material handling and recovery planning

### Query 5: Five Heaviest Trips
**Business Purpose**: Identify peak collection events
```sql
TOP 5 trips by net weight with ranking
```
**Use Case**: Performance benchmarking and capacity planning

### Query 6: Trip Count by Vehicle
**Business Purpose**: Measure vehicle utilization and efficiency
```sql
COUNT(trips) GROUP BY vehicle
```
**Use Case**: Maintenance scheduling and fleet optimization

### Query 7: Total Tonnage by Zone
**Business Purpose**: Zone performance reporting and target tracking
```sql
SUM(net_weight)/1000 GROUP BY zone
```
**Use Case**: Monthly/annual reporting to management

### Query 8: Average Load by Driver
**Business Purpose**: Driver performance metrics for incentives
```sql
AVG(net_weight) GROUP BY driver
```
**Use Case**: Performance evaluation and compensation

### Query 9: Min/Max/Avg by Material
**Business Purpose**: Material handling specifications
```sql
Highest, lowest, average allocations per material
```
**Use Case**: Equipment sizing and batch optimization

### Query 10: High-Performing Zones
**Business Purpose**: Identify zones exceeding targets
```sql
Zones with total tonnage > threshold
```
**Use Case**: Resource allocation and incentive distribution

### Query 11: Multi-Table Zone Report
**Business Purpose**: Comprehensive zone performance view
```sql
JOIN trip, zone, vehicle, driver, weighbridge_ticket
```
**Use Case**: Management dashboard and reporting

### Query 12: Inactive Vehicles
**Business Purpose**: Identify vehicles not in use
```sql
Vehicles with NO trip recorded (LEFT JOIN with WHERE NULL)
```
**Use Case**: Maintenance scheduling and fleet assessment

### Query 13: Heavy Loads Report
**Business Purpose**: Load distribution analysis
```sql
Tickets > 6500 kg with load categorization
```
**Use Case**: Safety review and equipment monitoring

### Query 14: Driver Zone Coverage (Self-Join)
**Business Purpose**: Identify drivers working same zones
```sql
SELF-JOIN drivers on trip->zone
```
**Use Case**: Shift planning and zone expertise development

### Query 15: Batch Status Report
**Business Purpose**: Batch utilization and capacity analysis
```sql
Batch fill percentage and remaining capacity
```
**Use Case**: Production planning and processing optimization

### Query 16: Above-Average Drivers
**Business Purpose**: High-performer identification
```sql
Trip count > overall average using CTE and AVG()
```
**Use Case**: Performance incentives and team recognition

### Query 17: Zone-Level Performance
**Business Purpose**: Drivers exceeding their zone average
```sql
Trip count > zone average using CTE
```
**Use Case**: Zone-specific incentive allocation

### Query 18: Multi-Zone Report (IN Clause)
**Business Purpose**: Regional analysis
```sql
WHERE zone_name IN (list of zones)
```
**Use Case**: Regional performance analysis

### Query 19: Unused Materials (NOT EXISTS)
**Business Purpose**: Identify unused waste categories
```sql
Materials never allocated using NOT EXISTS
```
**Use Case**: Process improvement planning

### Query 20: Comparative Load Analysis (ALL)
**Business Purpose**: Cross-zone comparison
```sql
Trips heavier than ALL trips in South Zone
```
**Use Case**: Route optimization and vehicle allocation

---

## Transaction Management

### Transaction 1: Trip and Ticket Recording
**Scenario**: Record new collection trip with weight measurement
**Features**: 
- BEGIN/COMMIT
- Multiple inserts ensuring data consistency
- Foreign key validation

### Transaction 2: Batch Allocation with Constraints
**Scenario**: Allocate waste to batch with capacity validation
**Features**:
- Constraint enforcement
- Rollback capability
- Capacity checking

### Transaction 3: Multi-Step Trip Completion
**Scenario**: Complete end-to-end trip workflow
**Features**:
- Multiple operations in sequence
- Batch capacity updates
- Validation at each step

### Transaction 4: Savepoint Usage
**Scenario**: Partial rollback for driver status update
**Features**:
- SAVEPOINT creation
- ROLLBACK TO SAVEPOINT
- Selective transaction rollback

---

## Concurrency Scenarios

### Scenario 1: Lost Update Problem
**Situation**: Two sessions reading and updating same batch capacity
**Prevention**: Use explicit locks (FOR UPDATE)

### Scenario 2: Read Consistency
**Situation**: Phantom reads with default isolation level
**Prevention**: Use ISOLATION LEVEL SERIALIZABLE for strict consistency

### Scenario 3: Batch Allocation Concurrency
**Situation**: Multiple drivers submitting trips to same batch simultaneously
**Solution**: Row-level locking with FOR UPDATE
```sql
SELECT * FROM processing_batch WHERE batch_id = X FOR UPDATE;
```

### Scenario 4: Deadlock Prevention
**Strategy**: Always lock resources in consistent order
- Lock batches before zones
- Lock trips before tickets
- Prevents circular wait condition

---

## Performance Optimization

### Indexes Created
1. **Foreign Key Indexes**: Automatic via FK constraints, optimizes joins
2. **Date Indexes**: On trip_date, weighbridge_date for range queries
3. **Weight Indexes**: On net_weight_kg for filtering queries
4. **Business ID Indexes**: On vehicle_number, license_number, zone_name

### Query Optimization Techniques
1. **Aggregate Functions**: COUNT, SUM, AVG with GROUP BY
2. **Window Functions**: RANK() OVER in Query 5 for top-N queries
3. **Common Table Expressions**: CTE for complex multi-step queries (Queries 16-17)
4. **Subqueries**: NOT EXISTS (Query 19), ALL/ANY (Query 20)
5. **Joins**: Strategic joins minimizing result set size

---

## Business Rules Enforced

1. **Data Integrity**:
   - Vehicle capacity must be > 0
   - All weights must be > 0
   - Net weight = Gross weight - Tare weight (CHECK constraint)
   - Allocated weight ≤ Ticket net weight

2. **Status Management**:
   - Vehicles: ACTIVE, INACTIVE, MAINTENANCE
   - Drivers: ACTIVE, INACTIVE, ON_LEAVE
   - Trips: PENDING, IN_PROGRESS, COMPLETED, CANCELLED
   - Batches: OPEN, FULL, PROCESSING, COMPLETED
   - Tickets: RECORDED, PROCESSED, CANCELLED

3. **Referential Integrity**:
   - Cascade deletes from Batch→Allocation
   - Restrict deletes from Trip→Ticket (maintains audit trail)
   - Restrict deletes from Material (prevents orphaned data)

4. **Unique Constraints**:
   - vehicle_number (registration)
   - license_number (driver identification)
   - material_name (category uniqueness)
   - Composite: (vehicle, driver, zone, date) for trips

---

## File Descriptions

### schema.sql
- 8 table definitions with complete constraints
- 11 indexes for performance
- Foreign key relationships with cascading rules
- CHECK constraints for business logic
- UNIQUE constraints for business identifiers

### seed.sql
- Realistic data for all 8 tables
- Data consistency across relationships
- Diversified status values for testing
- Sufficient volume for meaningful query results

### queries.sql
- All 20 business queries with documentation
- Sorting and filtering based on requirements
- Complex joins and aggregations
- Set operations (IN, NOT EXISTS, ALL)

### transactions.sql
- 4 transaction demonstrations
- Savepoint usage
- Concurrency scenarios (6 total)
- Practical business workflows
- Lock demonstrations

---

## Project Statistics

| Metric | Value |
|--------|-------|
| Tables | 8 |
| Relationships | 7 |
| Primary Keys | 8 |
| Foreign Keys | 8 |
| CHECK Constraints | 12 |
| UNIQUE Constraints | 6 |
| Indexes | 11 |
| Queries | 20 |
| Transactions | 4+ |
| Seed Records | 100+ |
| Total SQL Lines | 1000+ |

---

## How to Use

### Setup
```bash
# Login to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE waste_management;

# Connect to database
\c waste_management

# Load schema
\i schema.sql

# Load seed data
\i seed.sql
```

### Running Queries
```bash
# Run specific query
\i queries.sql

# Or run individual query from file
```

### Testing Transactions
```bash
# Run transactions
\i transactions.sql

# For concurrency testing: Open two psql sessions
# Run scenario 1 in each session simultaneously
```

---

## Design Rationale

### Why This Schema?

1. **Separates Concerns**: 
   - Trip (event), Weighbridge (measurement), Batch (processing)
   - Each table has single responsibility

2. **Supports Reporting**:
   - Zone-wise metrics via Zone table
   - Material-wise via Material_Category table
   - Driver/Vehicle performance via respective tables

3. **Maintains Audit Trail**:
   - Weighbridge tickets tied to trips
   - Allocations tracked with dates
   - Allows historical analysis

4. **Enables Scalability**:
   - Efficient indexing for large datasets
   - Proper normalization prevents data anomalies
   - Transaction support for concurrent operations

5. **Enforces Business Rules**:
   - CHECK constraints prevent invalid states
   - Foreign keys prevent orphaned records
   - UNIQUE constraints ensure identifier consistency

---

## Potential Enhancements

1. **Add Time Series Data**: Historical batch processing metrics
2. **Add Certification Tracking**: Recyclable material certifications
3. **Add Cost Accounting**: Transportation and processing costs
4. **Add Route Optimization**: Planned vs actual routes
5. **Add Quality Control**: Weight verification and discrepancies
6. **Add Environmental Metrics**: Carbon footprint tracking
7. **Add Compliance**: Regulatory compliance tracking per material

---

## Notes for Viva/Presentation

### Key Concepts to Explain

1. **ER Model**: Entities, attributes, relationships, cardinality
2. **Normalization**: Why 3NF was chosen, benefits
3. **Constraints**: Business rules enforcement at database level
4. **Indexing**: Performance optimization strategy
5. **Transactions**: ACID properties in waste collection context
6. **Concurrency**: How multiple collectors don't conflict

### Query Categories

- **Aggregation** (Queries 6, 7, 8, 9): GROUP BY with calculations
- **Filtering** (Queries 1, 2, 3, 4): WHERE clauses and patterns
- **Set Operations** (Queries 18, 19, 20): IN, NOT EXISTS, ALL
- **Joins** (Query 11, 14): Multi-table relationships
- **Subqueries** (Queries 16, 17): CTE and complex logic
- **Window Functions** (Query 5): RANK() OVER for top-N queries

---

**AUTHOR:- ADITYA SUNIL CHOUKSEY, TANAY SHELAR, JANMESH ROHIDA
**Total Development Effort**: Comprehensive DBMS implementation with advanced SQL features
