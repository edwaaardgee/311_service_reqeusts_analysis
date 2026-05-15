# CIS 4560 Term Project Tutorial

**Project:** NYC 311 Service Requests Big Data Analysis Using Hadoop, Hive, and Excel 3D Map  
**Name:** Edward Gallegos  
**Course:** CIS 4560 - Introduction to Big Data  

## Source Code

**GitHub repository:**  
https://github.com/edwaaardgee/311_service_request_analysis

The GitHub repository includes the HiveQL commands, tutorial steps, project slides, and supporting project documents.

## Important Note

In this tutorial, replace `<your_username>` with your own Hadoop cluster username.

Replace `<your_database_name>` with your Hive database name.

---

## 1. Materials Needed

**Dataset source:** Kaggle  
**Dataset page:** https://www.kaggle.com/datasets/aliafzal9323/los-angeles-crime-data-2020-2026  
**CSV file used:** `311_Service_Requests_from_2020_to_Present.csv`  
**Dataset size:** 12.63 GB  
**Columns:** 44  

Download the dataset from Kaggle and locate the file named:

```text
311_Service_Requests_from_2020_to_Present.csv
```

Note: Kaggle may require users to sign in before downloading the dataset.

---

## 2. Connect to the Hadoop Cluster

Open the SSH terminal and connect to the Hadoop cluster:

```bash
ssh <your_username>@129.146.237.12
```

---

## 3. Create an HDFS Directory

Create an HDFS project directory for the dataset:

```bash
hdfs dfs -mkdir -p /user/<your_username>/tmp/311_service_requests
```

Verify the folder was created:

```bash
hdfs dfs -ls /user/<your_username>/tmp
```

You should see:

```text
/user/<your_username>/tmp/311_service_requests
```

---

## 4. Upload the CSV File to HDFS

Make sure the CSV file is in your Linux home directory:

```bash
ls -lh
```

You should see:

```text
311_Service_Requests_from_2020_to_Present.csv
```

Upload the CSV file to HDFS:

```bash
hdfs dfs -put -f 311_Service_Requests_from_2020_to_Present.csv /user/<your_username>/tmp/311_service_requests/
```

Verify the CSV file was uploaded:

```bash
hdfs dfs -ls -h /user/<your_username>/tmp/311_service_requests/
```

You should see:

```text
Found 1 items /user/<your_username>/tmp/311_service_requests/311_Service_Requests_from_2020_to_Present.csv
```

---

## 5. Open Beeline

In terminal, open Beeline:

```bash
beeline
```

Select your Hive database:

```sql
USE <your_database_name>;
```

---

## 6. Create the Hive External Table

Run the following HiveQL code in Beeline:

```sql
DROP TABLE IF EXISTS service_requests_311;

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
```

---

## 7. Preview the Hive Table

Run this query to verify that Hive is reading the CSV file correctly:

```sql
SELECT created_date, agency, problem, borough, latitude, longitude
FROM service_requests_311
LIMIT 10;
```

This query should return sample rows from the dataset. It should show fields such as `created_date`, `agency`, `problem`, `borough`, `latitude`, and `longitude`.

---

## 8. Run HiveQL Analysis for Top Request Categories

Run this query to identify the most common NYC 311 service request categories:

```sql
SELECT
    problem,
    COUNT(*) AS total_requests
FROM service_requests_311
GROUP BY problem
ORDER BY total_requests DESC
LIMIT 10;
```

This query ranks each service request category by total count. The output shows which city service request types appeared most often in the dataset.

---

## 9. Export a Cleaned 10,000-Record Subset

Run this HiveQL command in Beeline:

```sql
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
```

This query removes records with missing latitude and longitude values. It also selects the main fields needed for the Excel 3D Map visualization.

Exit Beeline:

```sql
!quit
```

Merge the Hive output into one CSV file:

```bash
hdfs dfs -getmerge /user/<your_username>/tmp/clean_311_output clean_311_subset.csv
```

Check that the file was created:

```bash
ls -lh clean_311_subset.csv
```

---

## 10. Export a Top 5 Map Subset

This smaller file is used to make a cleaner Excel 3D Map visualization. Using a smaller Top 5 subset helps prevent the 3D Map from becoming too crowded.

Open Beeline again:

```bash
beeline
```

Select your Hive database:

```sql
USE <your_database_name>;
```

Run this HiveQL command:

```sql
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
```

Exit Beeline:

```sql
!quit
```

Merge the HDFS output into one local CSV file:

```bash
hdfs dfs -getmerge /user/<your_username>/tmp/top5_map_output top5_311_map.csv
```

Check that the file was created:

```bash
ls -lh top5_311_map_300.csv
```

---

## 11. Download the CSV File to Local Computer

Open a new local Git Bash window on your computer.

Do **not** run this command inside the SSH terminal.

Download the file to the Desktop:

```bash
scp <your_username>@129.146.237.12:~/top5_311_map.csv ~/Desktop/
```

The file should now appear on your Desktop.

---

## 12. Prepare the CSV File in Excel

Open `top5_311_map.csv` in Microsoft Excel.

If the CSV file does not have headers, add the following headers as Row 1:

```text
unique_key,created_date,agency,problem,borough,latitude,longitude
```

Save the file as an Excel workbook:

```text
top5_311_map_300.xlsx
```

---

## 13. Create the Excel 3D Map Visualization

In Excel, follow these steps:

1. Click anywhere inside the data table.
2. Go to **Insert**.
3. Select **3D Map**.
4. Click **Open 3D Maps**.
5. Select **New Tour**.

Set the 3D Map fields:

**Location:**

```text
latitude = Latitude
longitude = Longitude
```

**Category:**

```text
problem
```

**Time:**

```text
created_date
```

Use **Bubble** or **Column** view to show the top 5 service request types by color.

The legend should show these five categories:

```text
Noise - Residential
HEAT/HOT WATER
Request Large Bulky Item Collection
Illegal Parking
Blocked Driveway
```

The map uses latitude and longitude for the geographic location. It uses `created_date` for the time-based analysis. This creates the tempo-spatial visualization because it shows both where and when service requests occurred.

---

## 14. Final Output

The final project outputs include:

1. Hive external table created from HDFS data.
2. HiveQL query results showing top service request categories.
3. Cleaned 10,000-record subset.
4. Top 5 map subset for readability.
5. Excel 3D Map using latitude, longitude, problem type, and `created_date`.
6. Slides, paper, tutorial, and source code in GitHub.

---

## 15. Summary

This tutorial shows how to reproduce the project from beginning to end. The dataset is downloaded from Kaggle, uploaded to HDFS, processed using HiveQL, exported into cleaned CSV files, and visualized using Excel 3D Map.

The HiveQL analysis identifies the most common NYC 311 service request categories. The Excel 3D Map visualization uses latitude and longitude to map service request locations, while the `created_date` field supports time-based analysis. This allows the project to show both geographic request hotspots and time-based request patterns.
