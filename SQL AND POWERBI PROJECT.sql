-- 1. Traffic Flow & Sensor Data

-- Creating TrafficSensors Table
CREATE TABLE TrafficSensors (
    SensorID SERIAL PRIMARY KEY,
    Location VARCHAR(100),
    SensorType VARCHAR(50),  -- "Intersection", "Speed Sensor"
    InstallationDate DATE,
    Latitude DECIMAL(10, 8),
    Longitude DECIMAL(11, 8)
);

-- Inserting Sample Data for TrafficSensors Table
INSERT INTO TrafficSensors (Location, SensorType, InstallationDate, Latitude, Longitude) VALUES
('Downtown Intersection', 'Intersection', '2023-01-10', 40.712776, -74.005974),
('North Bridge', 'Speed Sensor', '2023-02-05', 40.752776, -74.015974),
('East Highway', 'Speed Sensor', '2022-12-20', 40.732776, -74.025974),
('West Entrance', 'Intersection', '2023-01-15', 40.712976, -74.035974),
('Central Park', 'Intersection', '2023-03-01', 40.702776, -74.015674),
('South Bridge', 'Speed Sensor', '2023-01-10', 40.692776, -74.025674),
('City Mall', 'Intersection', '2023-02-10', 40.712876, -74.045974),
('Lakeview Street', 'Speed Sensor', '2022-11-25', 40.762776, -74.005674),
('Old Town Square', 'Intersection', '2023-01-20', 40.742776, -74.085974),
('Airport Road', 'Speed Sensor', '2023-02-01', 40.792776, -74.055974);

-- Creating TrafficLogs Table
CREATE TABLE TrafficLogs (
    LogID SERIAL PRIMARY KEY,
    SensorID INT,
    Timestamp TIMESTAMP,
    VehicleCount INT,
    AverageSpeed DECIMAL(5,2),  -- km/h
    TrafficFlow VARCHAR(50),    -- 'Heavy', 'Moderate', 'Light'
    FOREIGN KEY (SensorID) REFERENCES TrafficSensors(SensorID)
);

-- Inserting Sample Data for TrafficLogs Table
INSERT INTO TrafficLogs (SensorID, Timestamp, VehicleCount, AverageSpeed, TrafficFlow) 
SELECT 
    i.SensorID,
    NOW() - INTERVAL '10 minutes' * (random() * 10)::int,
    (random() * 500)::int,
    (random() * 80 + 20)::decimal(5,2),
    CASE WHEN random() < 0.33 THEN 'Light' WHEN random() < 0.66 THEN 'Moderate' ELSE 'Heavy' END
FROM TrafficSensors i
WHERE i.SensorID <= 10;

-- 2. Public Transport Data

-- Creating PublicTransport Table
CREATE TABLE PublicTransport (
    RouteID SERIAL PRIMARY KEY,
    RouteName VARCHAR(100),
    VehicleType VARCHAR(50),  -- "Bus", "Tram", "Train"
    OperatingHours VARCHAR(50) -- "6:00 AM - 10:00 PM"
);

-- Inserting Sample Data for PublicTransport Table
INSERT INTO PublicTransport (RouteName, VehicleType, OperatingHours) VALUES
('Downtown Express', 'Bus', '6:00 AM - 10:00 PM'),
('City Loop', 'Tram', '7:00 AM - 9:00 PM'),
('Airport Shuttle', 'Train', '24/7'),
('Uptown Link', 'Bus', '5:00 AM - 11:00 PM'),
('Westside Connector', 'Tram', '6:30 AM - 8:30 PM');

-- Creating PublicTransportLogs Table
CREATE TABLE PublicTransportLogs (
    LogID SERIAL PRIMARY KEY,
    RouteID INT,
    VehicleID INT,
    Timestamp TIMESTAMP,
    CurrentLocation VARCHAR(100),
    PassengersCount INT,
    FOREIGN KEY (RouteID) REFERENCES PublicTransport(RouteID)
);

-- Inserting Sample Data for PublicTransportLogs Table
INSERT INTO PublicTransportLogs (RouteID, VehicleID, Timestamp, CurrentLocation, PassengersCount)
SELECT 
    i.RouteID,
    (random() * 100)::int, -- Simulating different vehicles
    NOW() - INTERVAL '1 hour' * (random() * 10)::int,
    CASE WHEN random() < 0.5 THEN 'Downtown Station' ELSE 'North Station' END,
    (random() * 200)::int
FROM PublicTransport i
WHERE i.RouteID <= 5;

-- 3. Incident Reports

-- Creating IncidentReports Table
CREATE TABLE IncidentReports (
    IncidentID SERIAL PRIMARY KEY,
    IncidentType VARCHAR(50), -- "Accident", "Road Closure"
    Description TEXT,
    Location VARCHAR(100),
    StartTime TIMESTAMP,
    EndTime TIMESTAMP,
    Severity VARCHAR(50) -- 'High', 'Medium', 'Low'
);

-- Inserting Sample Data for IncidentReports Table
INSERT INTO IncidentReports (IncidentType, Description, Location, StartTime, EndTime, Severity)
SELECT 
    CASE WHEN random() < 0.5 THEN 'Accident' ELSE 'Road Closure' END,
    'Detailed incident description here',
    'Intersection ' || (random() * 10)::int,
    NOW() - INTERVAL '1 day' * (random() * 30)::int,
    NOW() - INTERVAL '1 hour' * (random() * 5)::int,
    CASE WHEN random() < 0.33 THEN 'High' WHEN random() < 0.66 THEN 'Medium' ELSE 'Low' END
FROM generate_series(1, 20);

-- 4. City Infrastructure Monitoring

-- Creating CityInfrastructure Table
CREATE TABLE CityInfrastructure (
    InfrastructureID SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Type VARCHAR(50), -- 'Road', 'Bridge', 'Tunnel'
    Status VARCHAR(50), -- 'Operational', 'Under Construction', 'Closed'
    LastMaintenanceDate DATE
);

-- Inserting Sample Data for CityInfrastructure Table
INSERT INTO CityInfrastructure (Name, Type, Status, LastMaintenanceDate)
VALUES
('Main Street', 'Road', 'Operational', '2022-05-12'),
('5th Ave Bridge', 'Bridge', 'Under Construction', '2023-01-25'),
('Central Tunnel', 'Tunnel', 'Closed', '2023-02-01');
--===========================================================================================
--1) Traffic Flow & Sensor Data: Analyze vehicle counts, traffic speed, and flow at various sensor locations across the city.
	
select TS.SensorID,TS.location ,
TS.SensorType,
SUM(TL.VehicleCount) AS TotalVehicleCount,
avg(TL.AverageSpeed) as avgspeed,
TL.TrafficFlow
from TrafficSensors TS 
Join TrafficLogs TL
ON TS.SensorID = TL.SensorID
where  TL.TimeStamp>now() - INTERVAL '7 DAYS'
group by TS.SensorID, TS.Location, TS.SensorType, TL.TrafficFlow
order by TS.Location
--===========================================================================================
-- 2) Public Transport Efficiency: Measure passenger counts, track public transport vehicles, and analyze crowded routes and peak hours.

SELECT 
    PT.RouteName,
    PT.VehicleType,
    PT.OperatingHours,
    PTL.VehicleID,
    COUNT(PTL.PassengersCount) AS Total_Passengers,
    PTL.RouteID,
    PTL.CurrentLocation
FROM PublicTransport PT
JOIN PublicTransportLogs PTL
    ON PT.RouteID = PTL.RouteID
GROUP BY PT.RouteName, PT.VehicleType, PT.OperatingHours, PTL.VehicleID, PTL.RouteID, PTL.CurrentLocation
ORDER BY Total_Passengers DESC;
--=================================================================================================================
--3) Incident Reporting: Monitor accidents and road closures, calculate incident durations, and assess their impact on traffic.
SELECT 
    IncidentID,
    IncidentType,
    Location,
    StartTime,
    EndTime,
    Severity
FROM IncidentReports
ORDER BY Severity DESC;
--==================================================================================================================
-- 4) CREATE TABLE CityInfrastructure (
    InfrastructureID SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Type VARCHAR(50), -- 'Road', 'Bridge', 'Tunnel'
    Status VARCHAR(50), -- 'Operational', 'Under Construction', 'Closed'
    LastMaintenanceDate DATE
);

SELECT * 
FROM CityInfrastructure
WHERE Type IN ('Road', 'Bridge');



