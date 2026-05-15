-- CIS 4560 Term Project
-- NYC 311 Service Requests Big Data Analysis
-- HiveQL Source Code
-- Replace <your_username> with your Hadoop cluster username.
-- Replace <your_database_name> with your Hive database name.

USE <your_database_name>;

-- Drop the table if it already exists
DROP TABLE IF EXISTS service_requests_311;

-- Create external Hive table for NYC 311 CSV data
CREATE EXTERNAL TABLE service_requests_311 (
    unique_key STRING,
    created_date STRING,
    closed_date STRING,
    agency STRING,
    agency_name STRING,
    problem STRING,
    problem_detail STRING,
    additional_details STRING,
    location_type STRING,
    incident_zip STRING,
    incident_address STRING,
    street_name STRING,
    cross_street_1 STRING,
    cross_street_2 STRING,
    intersection_street_1 STRING,
    intersection_street_2 STRING,
    address_type STRING,
    city STRING,
    landmark STRING,
    facility_type STRING,
    status STRING,
    due_date STRING,
    resolution_description STRING,
    resolution_action_updated_date STRING,
    community_board STRING,
    council_district STRING,
    police_precinct STRING,
    bbl STRING,
    borough STRING,
    x_coordinate STRING,
    y_coordinate STRING,
    open_data_channel_type STRING,
    park_facility_name STRING,
    park_borough STRING,
    vehicle_type STRING,
    taxi_company_borough STRING,
    taxi_pick_up_location STRING,
    bridge_highway_name STRING,
    bridge_highway_direction STRING,
    road_ramp STRING,
    bridge_highway_segment STRING,
    latitude STRING,
    longitude STRING,
    location STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
    "separatorChar" = ",",
    "quoteChar" = "\"",
    "escapeChar" = "\\"
)
STORED AS TEXTFILE
LOCATION '/user/<your_username>/tmp/311_service_requests'
TBLPROPERTIES ("skip.header.line.count"="1");


-- Preview selected fields from the Hive table
SELECT created_date, agency, problem, borough, latitude, longitude
FROM service_requests_311
LIMIT 10;


-- Count total records in the Hive table
SELECT COUNT(*)
FROM service_requests_311;


-- Find the top 10 most common service request categories
SELECT
    problem,
    COUNT(*) AS total_requests
FROM service_requests_311
GROUP BY problem
ORDER BY total_requests DESC
LIMIT 10;


-- Count service requests by borough
SELECT
    borough,
    COUNT(*) AS total_requests
FROM service_requests_311
GROUP BY borough
ORDER BY total_requests DESC;


-- Count service requests by problem type and borough
SELECT
    problem,
    borough,
    COUNT(*) AS total_requests
FROM service_requests_311
GROUP BY problem, borough
ORDER BY total_requests DESC
LIMIT 20;


-- Export cleaned 10,000-record subset for analysis and visualization
-- This removes records with missing latitude and longitude values.
INSERT OVERWRITE DIRECTORY '/user/<your_username>/tmp/clean_311_output'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT
    unique_key,
    created_date,
    agency,
    problem,
    borough,
    latitude,
    longitude
FROM service_requests_311
WHERE latitude IS NOT NULL
  AND longitude IS NOT NULL
  AND latitude != ''
  AND longitude != ''
LIMIT 10000;


-- Export Top 5 service request categories for a cleaner Excel 3D Map
-- This smaller subset helps prevent the map from becoming overcrowded.
INSERT OVERWRITE DIRECTORY '/user/<your_username>/tmp/top5_map_output'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT
    unique_key,
    created_date,
    agency,
    problem,
    borough,
    latitude,
    longitude
FROM service_requests_311
WHERE latitude IS NOT NULL
  AND longitude IS NOT NULL
  AND latitude != ''
  AND longitude != ''
  AND problem IN (
      'Noise - Residential',
      'HEAT/HOT WATER',
      'Request Large Bulky Item Collection',
      'Illegal Parking',
      'Blocked Driveway'
  )
LIMIT 300;
