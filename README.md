# NYC 311 Service Requests Big Data Analysis

## Project Overview

This project analyzes NYC 311 service request data from 2020 to the present using Hadoop, HDFS, Hive, Beeline, HiveQL, YARN, and Microsoft Excel 3D Map.

The goal is to identify the most common service request categories and visualize request patterns by location and time.

## Dataset

- Source: Kaggle
- Dataset URL: https://www.kaggle.com/datasets/aliafzal9323/los-angeles-crime-data-2020-2026
- CSV File: 311_Service_Requests_from_2020_to_Present.csv
- Dataset Size: 12.63 GB
- Columns: 44
- Time Range: 2020 to present

Note: The Kaggle package title may differ, but the file used for this project is the NYC 311 Service Requests CSV.

## Source Code

The source code for this project is included in:

- hive_queries.sql

This file contains the HiveQL commands used to create the Hive table, clean the data, run analysis queries, and export CSV files for Excel 3D Map.

## Tools and Platform

- Hadoop / Hive
- HDFS
- Beeline
- HiveQL
- YARN
- Microsoft Excel 3D Map

Cluster Specs:
- Hadoop version: 3.4.1
- Cluster nodes: 5 nodes — 2 master, 3 worker
- Memory: 31 GB RAM
- CPU: AMD EPYC 7J13 processor
- CPU speed: 2.4 GHz

## Repository Files

- tutorial.md — step-by-step tutorial to reproduce the project
- hive_queries.sql — HiveQL code for table creation, data cleaning, analysis, and export
- dataset_instructions.txt — dataset download instructions
- slides/ — project presentation slides
- paper/ — final term paper

## Main Analysis

The main HiveQL query ranks service request categories by total count:

SELECT
    problem,
    COUNT(*) AS total_requests
FROM service_requests_311
GROUP BY problem
ORDER BY total_requests DESC
LIMIT 10;

The top request categories included:

1. Noise - Residential
2. HEAT/HOT WATER
3. Request Large Bulky Item Collection
4. Illegal Parking
5. Blocked Driveway

## Visualization

Microsoft Excel 3D Map was used to create a tempo-spatial visualization.

The map used:

- latitude
- longitude
- problem
- created_date

This allowed the project to show where and when common NYC 311 service requests occurred.

## How to Reproduce

Follow the full instructions in:

tutorial.md

The tutorial explains how to download the dataset, upload it to HDFS, create the Hive table, run HiveQL queries, export CSV files, and create the Excel 3D Map.

## References

- Kaggle Dataset: https://www.kaggle.com/datasets/aliafzal9323/los-angeles-crime-data-2020-2026
- Tools: Hadoop, HDFS, Hive, Beeline, HiveQL, YARN, Microsoft Excel 3D Map
