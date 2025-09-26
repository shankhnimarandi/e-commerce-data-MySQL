# e-commerce-data-MySQL

This repository contains the deliverables for the SQL for Data Analysis task as part of the Elevate Labs Data Analyst Internship. The objective of this project was to use SQL to extract, clean, and analyze a large e-commerce dataset.

## Project Contents
elevate_labs_internship_task.sql: This file contains all the SQL queries used to complete the assignment, including data loading, cleaning, and analysis queries.

Screenshots: The screenshots of the output for each query, as required by the assignment guidelines.

## Key Skills Demonstrated

Data Import and Cleaning: I successfully loaded a raw CSV file into a MySQL database. This involved troubleshooting and resolving several common data import errors, including issues with file permissions (LOAD DATA LOCAL INFILE), character encoding (utf8mb4 vs. latin1), and data type mismatches (e.g., negative Quantity values and NULL CustomerID values).

Data Analysis with SQL: I used a variety of SQL commands to analyze the dataset, including:

SELECT, WHERE, GROUP BY, and ORDER BY for fundamental data aggregation.

JOINS (specifically, a self-join) to find relationships within a single table.

Subqueries to filter data based on a condition from another query.

Aggregate Functions (SUM and AVG) to perform calculations on revenue and product quantity.

Database Objects: I created a VIEW to simplify future analysis and created an INDEX to optimize query performance on a large dataset.

## Challenges and Solutions

Incorrect datetime value: The date format in the CSV (MM/DD/YYYY HH:MM) did not match MySQL's standard DATETIME format.

Solution: I used a temporary table to import the data as strings and then used the STR_TO_DATE() function to convert the date format correctly during the final insertion into the main table.

Out of range value: The Quantity column contained negative numbers for returns, which caused an error when I tried to cast it as UNSIGNED INT.

Solution: I changed the Quantity column's data type to SIGNED INT to allow for both positive and negative values.

