COPY bronze.crm_cust_info
FROM 'C:\Portfolio\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
DELIMITER ','
CSV HEADER;

COPY bronze.crm_prd_info
FROM 'C:\Portfolio\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
DELIMITER ','
CSV HEADER;

COPY bronze.crm_sales_details
FROM 'C:\Portfolio\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
DELIMITER ','
CSV HEADER;

COPY bronze.erp_cust_az12
FROM 'C:\Portfolio\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
DELIMITER ','
CSV HEADER;

COPY bronze.erp_loc_a101
FROM 'C:\Portfolio\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
DELIMITER ','
CSV HEADER;

COPY bronze.erp_px_cat_g1v2
FROM 'C:\Portfolio\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM bronze.erp_px_cat_g1v2;
