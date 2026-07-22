------------------------------------------------------------
-- Customer dimension table

CREATE VIEW gold.dim_customers AS
SELECT 
ROW_NUMBER() OVER  (ORDER BY cst_id) as customer_key,
cst_id AS customer_id, 
cst_key AS customer_number, 
cst_firstname AS firstname, 
cst_lastname AS lastname, 
bdate AS birthdate, 
CASE WHEN cst_gndr != 'N/A' THEN cst_gndr -- Follow gender from master table CRM
		 ELSE COALESCE(gen, 'N/A')
END AS gender,
cst_marital_status AS marital_status,
cntry as country,
cst_create_date AS create_date
FROM silver.crm_cust_info a
LEFT JOIN silver.erp_cust_az12 b ON a.cst_key = b.cid
LEFT JOIN silver.erp_loc_a101 c ON b.cid = c.cid

--------------------------------------------------------------
-- Product dimension table

CREATE VIEW gold.dim_products AS
SELECT 
ROW_NUMBER() OVER  (ORDER BY prd_start_dt, prd_key) as product_key,
prd_id AS product_id, 
prd_key AS product_number, 
prd_nm AS product_name,
cat_id AS category_id,
cat AS category, 
subcat AS subcategory, 
maintenance,
prd_cost AS cost, 
prd_line AS product_line, 
prd_start_dt AS start_date
FROM silver.crm_prd_info a
LEFT JOIN silver.erp_px_cat_g1v2 b ON a.cat_id = b.id
WHERE prd_end_dt IS NULL -- Only extract current ongoing products

------------------------------------------------------------
-- Sales fact table

CREATE VIEW gold.fact_sales AS
SELECT 
sls_ord_num AS order_number, 
product_number AS product_key,
customer_key,
sls_sales AS sales_amount, 
sls_quantity AS quantity, 
sls_price AS price,
sls_order_dt AS order_date, 
sls_ship_dt AS shipping_date, 
sls_due_dt AS due_date
FROM silver.crm_sales_details s
LEFT JOIN gold.dim_products p ON s.sls_prd_key = p.product_number
LEFT JOIN gold.dim_customers c ON s.sls_cust_id = c.customer_id
