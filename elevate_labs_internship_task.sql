mysql> USE elevate_labs;
Database changed
mysql> CREATE TABLE e_commerce_data (
    ->     InvoiceNo VARCHAR(20),
    ->     StockCode VARCHAR(20),
    ->     Description VARCHAR(255),
    ->     Quantity INT,
    ->     InvoiceDate DATETIME,
    ->     UnitPrice DECIMAL(10, 2),
    ->     CustomerID INT,
    ->     Country VARCHAR(50)
    -> );
Query OK, 0 rows affected (0.06 sec)

mysql> CREATE TABLE temp_e_commerce_data (
    ->     InvoiceNo VARCHAR(20),
    ->     StockCode VARCHAR(20),
    ->     Description VARCHAR(255),
    ->     Quantity VARCHAR(20),
    ->     InvoiceDate VARCHAR(50),
    ->     UnitPrice VARCHAR(20),
    ->     CustomerID VARCHAR(20),
    ->     Country VARCHAR(50)
    -> );
Query OK, 0 rows affected (0.04 sec)

mysql> LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/data.csv'
    -> INTO TABLE temp_e_commerce_data
    -> CHARACTER SET latin1
    -> FIELDS TERMINATED BY ','
    -> ENCLOSED BY '"'
    -> LINES TERMINATED BY '\n'
    -> IGNORE 1 ROWS;
Query OK, 541909 rows affected (5.89 sec)
Records: 541909  Deleted: 0  Skipped: 0  Warnings: 0

mysql> INSERT INTO e_commerce_data (
    ->     InvoiceNo, StockCode, Description, Quantity,
    ->     InvoiceDate, UnitPrice, CustomerID, Country
    -> )
    -> SELECT
    ->     InvoiceNo,
    ->     StockCode,
    ->     Description,
    ->     CAST(Quantity AS SIGNED),
    ->     STR_TO_DATE(InvoiceDate, '%c/%e/%Y %H:%i'),
    ->     CAST(UnitPrice AS DECIMAL(10, 2)),
    ->     CASE
    ->         WHEN CustomerID = '' THEN NULL
    ->         ELSE CAST(CustomerID AS UNSIGNED)
    ->     END AS CustomerID,
    ->     Country
    -> FROM temp_e_commerce_data;
Query OK, 541909 rows affected (6.71 sec)
Records: 541909  Duplicates: 0  Warnings: 0

mysql> UPDATE e_commerce_data
    -> SET Country = TRIM(REPLACE(Country, '\r', ''));
Query OK, 541909 rows affected (11.79 sec)
Rows matched: 541909  Changed: 541909  Warnings: 0

mysql> SELECT Country, COUNT(DISTINCT InvoiceNo) AS NumberOfOrders
    -> FROM e_commerce_data
    -> GROUP BY Country
    -> ORDER BY NumberOfOrders DESC
    -> LIMIT 10;
+----------------+----------------+
| Country        | NumberOfOrders |
+----------------+----------------+
| United Kingdom |          23494 |
| Germany        |            603 |
| France         |            461 |
| EIRE           |            360 |
| Belgium        |            119 |
| Spain          |            105 |
| Netherlands    |            101 |
| Switzerland    |             74 |
| Portugal       |             71 |
| Australia      |             69 |
+----------------+----------------+
10 rows in set (1.44 sec)

mysql> SELECT c.CustomerID, c.Country, COUNT(o.InvoiceNo) AS Orders
    -> FROM customers c
    -> INNER JOIN e_commerce_data o
    ->     ON c.CustomerID = o.CustomerID
    -> GROUP BY c.CustomerID, c.Country
    -> ORDER BY Orders DESC;
ERROR 1146 (42S02): Table 'elevate_labs.customers' doesn't exist
mysql> SELECT
    ->     a.CustomerID,
    ->     a.StockCode,
    ->     a.InvoiceNo AS Invoice1,
    ->     b.InvoiceNo AS Invoice2
    -> FROM
    ->     e_commerce_data AS a
    -> INNER JOIN
    ->     e_commerce_data AS b ON a.CustomerID = b.CustomerID
    ->     AND a.StockCode = b.StockCode
    ->     AND a.InvoiceNo <> b.InvoiceNo
    -> LIMIT 10;
+------------+-----------+----------+----------+
| CustomerID | StockCode | Invoice1 | Invoice2 |
+------------+-----------+----------+----------+
|      17850 | 85123A    | 536790   | 536365   |
|      17850 | 85123A    | 536787   | 536365   |
|      17850 | 85123A    | 536752   | 536365   |
|      17850 | 85123A    | 536750   | 536365   |
|      17850 | 85123A    | 536690   | 536365   |
|      17850 | 85123A    | 536685   | 536365   |
|      17850 | 85123A    | 536630   | 536365   |
|      17850 | 85123A    | 536628   | 536365   |
|      17850 | 85123A    | 536612   | 536365   |
|      17850 | 85123A    | 536609   | 536365   |
+------------+-----------+----------+----------+
10 rows in set (0.01 sec)

mysql> SELECT
    ->     InvoiceNo,
    ->     CustomerID,
    ->     Country
    -> FROM
    ->     e_commerce_data
    -> WHERE
    ->     CustomerID IN (
    ->         SELECT CustomerID
    ->         FROM e_commerce_data
    ->         WHERE Country = 'France'
    ->     )
    -> ORDER BY
    ->     CustomerID, InvoiceNo
    -> LIMIT 10;
+-----------+------------+---------+
| InvoiceNo | CustomerID | Country |
+-----------+------------+---------+
| 540365    |      12413 | France  |
| 540365    |      12413 | France  |
| 540365    |      12413 | France  |
| 540365    |      12413 | France  |
| 540365    |      12413 | France  |
| 540365    |      12413 | France  |
| 540365    |      12413 | France  |
| 540365    |      12413 | France  |
| 540365    |      12413 | France  |
| 540365    |      12413 | France  |
+-----------+------------+---------+
10 rows in set (1.34 sec)

mysql> SELECT SUM(Quantity * UnitPrice) AS TotalRevenue FROM e_commerce_data;
+--------------+
| TotalRevenue |
+--------------+
|   9747747.93 |
+--------------+
1 row in set (0.42 sec)

mysql> SELECT AVG(Quantity) AS AverageQuantity FROM e_commerce_data;
+-----------------+
| AverageQuantity |
+-----------------+
|          9.5522 |
+-----------------+
1 row in set (0.28 sec)

mysql> CREATE VIEW Daily_Revenue AS
    -> SELECT
    ->     DATE(InvoiceDate) AS SaleDate,
    ->     SUM(Quantity * UnitPrice) AS DailyTotal
    -> FROM
    ->     e_commerce_data
    -> GROUP BY
    ->     DATE(InvoiceDate);
ERROR 1050 (42S01): Table 'Daily_Revenue' already exists
mysql> SELECT * FROM Daily_Revenue WHERE SaleDate > '2011-10-01';
+------------+------------+
| SaleDate   | DailyTotal |
+------------+------------+
| 2011-10-02 |   11623.58 |
| 2011-10-03 |   64214.78 |
| 2011-10-04 |   48240.84 |
| 2011-10-05 |   75244.43 |
| 2011-10-06 |   55306.28 |
| 2011-10-07 |   47538.02 |
| 2011-10-09 |   11922.24 |
| 2011-10-10 |   44265.89 |
| 2011-10-11 |   38267.75 |
| 2011-10-12 |   29302.85 |
| 2011-10-13 |   37067.17 |
| 2011-10-14 |   35225.54 |
| 2011-10-16 |   21605.44 |
| 2011-10-17 |   47064.14 |
| 2011-10-18 |   44637.84 |
| 2011-10-19 |   36003.43 |
| 2011-10-20 |   60793.14 |
| 2011-10-21 |   62961.26 |
| 2011-10-23 |   12302.41 |
| 2011-10-24 |   38407.72 |
| 2011-10-25 |   40807.49 |
| 2011-10-26 |   37842.08 |
| 2011-10-27 |   47480.15 |
| 2011-10-28 |   39559.47 |
| 2011-10-30 |   34545.28 |
| 2011-10-31 |   48475.45 |
| 2011-11-01 |   28741.55 |
| 2011-11-02 |   45239.06 |
| 2011-11-03 |   62816.55 |
| 2011-11-04 |   60081.76 |
| 2011-11-06 |   42912.40 |
| 2011-11-07 |   70001.08 |
| 2011-11-08 |   56647.66 |
| 2011-11-09 |   62599.43 |
| 2011-11-10 |   68956.24 |
| 2011-11-11 |   54835.51 |
| 2011-11-13 |   33520.22 |
| 2011-11-14 |  112141.11 |
| 2011-11-15 |   60594.23 |
| 2011-11-16 |   64408.70 |
| 2011-11-17 |   60329.72 |
| 2011-11-18 |   48031.80 |
| 2011-11-20 |   34902.01 |
| 2011-11-21 |   48302.50 |
| 2011-11-22 |   62307.32 |
| 2011-11-23 |   78480.70 |
| 2011-11-24 |   48080.28 |
| 2011-11-25 |   50442.72 |
| 2011-11-27 |   20571.50 |
| 2011-11-28 |   55442.02 |
| 2011-11-29 |   72219.20 |
| 2011-11-30 |   59150.98 |
| 2011-12-01 |   51410.95 |
| 2011-12-02 |   57086.06 |
| 2011-12-04 |   24565.78 |
| 2011-12-05 |   57751.32 |
| 2011-12-06 |   54228.37 |
| 2011-12-07 |   75076.22 |
| 2011-12-08 |   81417.78 |
| 2011-12-09 |   32131.53 |
+------------+------------+
60 rows in set (0.63 sec)

mysql> SELECT *
    -> FROM e_commerce_data
    -> WHERE CustomerID = 17850
    -> LIMIT 20;
+-----------+-----------+-------------------------------------+----------+---------------------+-----------+------------+----------------+
| InvoiceNo | StockCode | Description                         | Quantity | InvoiceDate         | UnitPrice | CustomerID | Country        |
+-----------+-----------+-------------------------------------+----------+---------------------+-----------+------------+----------------+
| 536365    | 85123A    | WHITE HANGING HEART T-LIGHT HOLDER  |        6 | 2010-12-01 08:26:00 |      2.55 |      17850 | United Kingdom |
| 536365    | 71053     | WHITE METAL LANTERN                 |        6 | 2010-12-01 08:26:00 |      3.39 |      17850 | United Kingdom |
| 536365    | 84406B    | CREAM CUPID HEARTS COAT HANGER      |        8 | 2010-12-01 08:26:00 |      2.75 |      17850 | United Kingdom |
| 536365    | 84029G    | KNITTED UNION FLAG HOT WATER BOTTLE |        6 | 2010-12-01 08:26:00 |      3.39 |      17850 | United Kingdom |
| 536365    | 84029E    | RED WOOLLY HOTTIE WHITE HEART.      |        6 | 2010-12-01 08:26:00 |      3.39 |      17850 | United Kingdom |
| 536365    | 22752     | SET 7 BABUSHKA NESTING BOXES        |        2 | 2010-12-01 08:26:00 |      7.65 |      17850 | United Kingdom |
| 536365    | 21730     | GLASS STAR FROSTED T-LIGHT HOLDER   |        6 | 2010-12-01 08:26:00 |      4.25 |      17850 | United Kingdom |
| 536366    | 22633     | HAND WARMER UNION JACK              |        6 | 2010-12-01 08:28:00 |      1.85 |      17850 | United Kingdom |
| 536366    | 22632     | HAND WARMER RED POLKA DOT           |        6 | 2010-12-01 08:28:00 |      1.85 |      17850 | United Kingdom |
| 536372    | 22632     | HAND WARMER RED POLKA DOT           |        6 | 2010-12-01 09:01:00 |      1.85 |      17850 | United Kingdom |
| 536372    | 22633     | HAND WARMER UNION JACK              |        6 | 2010-12-01 09:01:00 |      1.85 |      17850 | United Kingdom |
| 536373    | 85123A    | WHITE HANGING HEART T-LIGHT HOLDER  |        6 | 2010-12-01 09:02:00 |      2.55 |      17850 | United Kingdom |
| 536373    | 71053     | WHITE METAL LANTERN                 |        6 | 2010-12-01 09:02:00 |      3.39 |      17850 | United Kingdom |
| 536373    | 84406B    | CREAM CUPID HEARTS COAT HANGER      |        8 | 2010-12-01 09:02:00 |      2.75 |      17850 | United Kingdom |
| 536373    | 20679     | EDWARDIAN PARASOL RED               |        6 | 2010-12-01 09:02:00 |      4.95 |      17850 | United Kingdom |
| 536373    | 37370     | RETRO COFFEE MUGS ASSORTED          |        6 | 2010-12-01 09:02:00 |      1.06 |      17850 | United Kingdom |
| 536373    | 21871     | SAVE THE PLANET MUG                 |        6 | 2010-12-01 09:02:00 |      1.06 |      17850 | United Kingdom |
| 536373    | 21071     | VINTAGE BILLBOARD DRINK ME MUG      |        6 | 2010-12-01 09:02:00 |      1.06 |      17850 | United Kingdom |
| 536373    | 21068     | VINTAGE BILLBOARD LOVE/HATE MUG     |        6 | 2010-12-01 09:02:00 |      1.06 |      17850 | United Kingdom |
| 536373    | 82483     | WOOD 2 DRAWER CABINET WHITE FINISH  |        2 | 2010-12-01 09:02:00 |      4.95 |      17850 | United Kingdom |
+-----------+-----------+-------------------------------------+----------+---------------------+-----------+------------+----------------+
20 rows in set (0.00 sec)                                                                                                                                                                               