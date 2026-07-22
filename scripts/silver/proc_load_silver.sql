CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$

DECLARE

    -- Job level tracking
    v_job_start     TIMESTAMP;
    v_job_end       TIMESTAMP;

    -- Table level tracking
    v_table_start   TIMESTAMP;
    v_table_end     TIMESTAMP;

    -- Metrics
    v_rows          INTEGER;
    v_total_rows    INTEGER := 0;
    v_tables_loaded INTEGER := 0;

BEGIN

    v_job_start := clock_timestamp();

    RAISE NOTICE '';
    RAISE NOTICE '============================================================';
    RAISE NOTICE '                    SILVER LAYER LOAD';
    RAISE NOTICE '============================================================';
    RAISE NOTICE 'Started : %', v_job_start;

    RAISE NOTICE '';
    RAISE NOTICE '---------------- PREPARING ENVIRONMENT ----------------';

    BEGIN

        v_table_start := clock_timestamp();

        RAISE NOTICE '';
        RAISE NOTICE 'Truncating Silver tables...';

        TRUNCATE TABLE
            silver.crm_cust_info,
            silver.crm_prd_info,
            silver.crm_sales_details,
            silver.erp_cust_az12,
            silver.erp_loc_a101,
            silver.erp_px_cat_g1v2;

        v_table_end := clock_timestamp();

        RAISE NOTICE '✓ SUCCESS';
        RAISE NOTICE 'All Silver tables truncated.';
        RAISE NOTICE 'Duration : %', v_table_end - v_table_start;

    EXCEPTION
        WHEN OTHERS THEN

            v_table_end := clock_timestamp();

            RAISE NOTICE '';
            RAISE NOTICE '✗ FAILED';
            RAISE NOTICE 'Failed to truncate Silver tables.';
            RAISE NOTICE 'Error    : %', SQLERRM;
            RAISE NOTICE 'Duration : %', v_table_end - v_table_start;

            RAISE;

    END;

    ------------------------------------------------------------
    -- CRM TABLES
    ------------------------------------------------------------

    RAISE NOTICE '';
    RAISE NOTICE '------------------------ CRM -------------------------------';


    ------------------------------------------------------------
    -- crm_cust_info
    ------------------------------------------------------------

    BEGIN

        v_table_start := clock_timestamp();

        RAISE NOTICE '';
        RAISE NOTICE 'Loading silver.crm_cust_info...';

        INSERT INTO silver.crm_cust_info (
            cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date
        )

        --Remove duplicate cst_id and take the newest row only
        --Remove whitespaces
        --Standardise values in other columns
        SELECT
            cst_id,
            cst_key,
            TRIM (cst_firstname) AS cst_firstname,
            TRIM (cst_lastname) AS cst_lastname,
            CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'N/A'
            END cst_marital_status,
            CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'N/A'
            END cst_gndr,
            cst_create_date
        FROM (
            SELECT *, ROW_NUMBER() OVER (
                PARTITION BY cst_id ORDER BY cst_create_date DESC
                ) AS flag_last
            FROM bronze.crm_cust_info
        )t WHERE flag_last = 1;

        GET DIAGNOSTICS v_rows = ROW_COUNT;

        v_table_end := clock_timestamp();

        v_total_rows := v_total_rows + v_rows;
        v_tables_loaded := v_tables_loaded + 1;

        RAISE NOTICE '✓ SUCCESS';
        RAISE NOTICE 'Rows Loaded : %', v_rows;
        RAISE NOTICE 'Duration    : %', v_table_end - v_table_start;


    EXCEPTION
        WHEN OTHERS THEN

            RAISE NOTICE '';
            RAISE NOTICE '✗ FAILED';
            RAISE NOTICE 'Table : silver.crm_cust_info';
            RAISE NOTICE 'Error : %', SQLERRM;

            RAISE;
    END;



    ------------------------------------------------------------
    -- crm_prd_info
    ------------------------------------------------------------

    BEGIN

        v_table_start := clock_timestamp();

        RAISE NOTICE '';
        RAISE NOTICE 'Loading silver.crm_prd_info...';

        INSERT INTO silver.crm_prd_info (
            prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
        )
        SELECT
            prd_id,
            REPLACE(SUBSTRING (prd_key, 1, 5), '-', '_') AS cat_id,
            SUBSTRING (prd_key, 7, LENGTH(prd_key)) AS prd_key,
            prd_nm,
            COALESCE (prd_cost, 0) AS prd_cost,
            -- Standardizing values to make more sense
            CASE WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
                WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                ELSE 'N/A'
            END AS prd_line,
            CAST(prd_start_dt AS DATE) AS prd_start_dt,
            CAST(LEAD (prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - INTERVAL '1 day' AS DATE) AS prd_end_dt
        FROM bronze.crm_prd_info;

        GET DIAGNOSTICS v_rows = ROW_COUNT;

        v_table_end := clock_timestamp();

        v_total_rows := v_total_rows + v_rows;
        v_tables_loaded := v_tables_loaded + 1;

        RAISE NOTICE '✓ SUCCESS';
        RAISE NOTICE 'Rows Loaded : %', v_rows;
        RAISE NOTICE 'Duration    : %', v_table_end - v_table_start;


    EXCEPTION
        WHEN OTHERS THEN

            RAISE NOTICE '';
            RAISE NOTICE '✗ FAILED';
            RAISE NOTICE 'Table : silver.crm_prd_info';
            RAISE NOTICE 'Error : %', SQLERRM;

            RAISE;
    END;



    ------------------------------------------------------------
    -- crm_sales_details
    ------------------------------------------------------------

    BEGIN

        v_table_start := clock_timestamp();

        RAISE NOTICE '';
        RAISE NOTICE 'Loading silver.crm_sales_details...';

        INSERT INTO silver.crm_sales_details (
            sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            -- Change integer into date
            CASE WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt::TEXT) != 8 THEN NULL
                ELSE TO_DATE(sls_order_dt::TEXT, 'YYYYMMDD')
            END AS sls_order_dt,
            CASE WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt::TEXT) != 8 THEN NULL
                ELSE TO_DATE(sls_ship_dt::TEXT, 'YYYYMMDD')
            END AS sls_ship_dt,
            CASE WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt::TEXT) != 8 THEN NULL
                ELSE TO_DATE(sls_due_dt::TEXT, 'YYYYMMDD')
            END AS sls_due_dt,
            -- Handling missing or invalid data, fixing calculations
            CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END AS sls_sales,
            sls_quantity,
            CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN ABS(sls_sales/NULLIF(sls_quantity, 0))
                ELSE sls_price
            END AS sls_price
        FROM bronze.crm_sales_details;

        GET DIAGNOSTICS v_rows = ROW_COUNT;

        v_table_end := clock_timestamp();

        v_total_rows := v_total_rows + v_rows;
        v_tables_loaded := v_tables_loaded + 1;

        RAISE NOTICE '✓ SUCCESS';
        RAISE NOTICE 'Rows Loaded : %', v_rows;
        RAISE NOTICE 'Duration    : %', v_table_end - v_table_start;


    EXCEPTION
        WHEN OTHERS THEN

            RAISE NOTICE '';
            RAISE NOTICE '✗ FAILED';
            RAISE NOTICE 'Table : silver.crm_sales_details';
            RAISE NOTICE 'Error : %', SQLERRM;

            RAISE;
    END;



    ------------------------------------------------------------
    -- ERP TABLES
    ------------------------------------------------------------

    RAISE NOTICE '';
    RAISE NOTICE '------------------------ ERP -------------------------------';



    ------------------------------------------------------------
    -- erp_cust_az12
    ------------------------------------------------------------

    BEGIN

        v_table_start := clock_timestamp();

        RAISE NOTICE '';
        RAISE NOTICE 'Loading silver.erp_cust_az12...';

        INSERT INTO silver.erp_cust_az12 (
            cid, bdate, gen
        )
        SELECT
            -- Remove the first 3 characters in cid to match crm_cust_info
            CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
                ELSE cid
            END AS cid,
            CASE WHEN bdate > NOW() THEN NULL
                ELSE bdate
            END AS bdate,
            -- Standardize gender values
            CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
                ELSE 'N/A'
            END AS gen
        FROM bronze.erp_cust_az12;

        GET DIAGNOSTICS v_rows = ROW_COUNT;

        v_table_end := clock_timestamp();

        v_total_rows := v_total_rows + v_rows;
        v_tables_loaded := v_tables_loaded + 1;

        RAISE NOTICE '✓ SUCCESS';
        RAISE NOTICE 'Rows Loaded : %', v_rows;
        RAISE NOTICE 'Duration    : %', v_table_end - v_table_start;


    EXCEPTION
        WHEN OTHERS THEN

            RAISE NOTICE '';
            RAISE NOTICE '✗ FAILED';
            RAISE NOTICE 'Table : silver.erp_cust_az12';
            RAISE NOTICE 'Error : %', SQLERRM;

            RAISE;
    END;



    ------------------------------------------------------------
    -- erp_loc_a101
    ------------------------------------------------------------

    BEGIN

        v_table_start := clock_timestamp();

        RAISE NOTICE '';
        RAISE NOTICE 'Loading silver.erp_loc_a101...';

        INSERT INTO silver.erp_loc_a101(
            cid, cntry
        )
        SELECT
            -- Remove dash to match crm_cust_info
            REPLACE (cid, '-', '') AS cid,
            -- Standardise country names and handle missing values
            CASE WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
                WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
                WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
                ELSE cntry
            END AS cntry
        FROM bronze.erp_loc_a101;

        GET DIAGNOSTICS v_rows = ROW_COUNT;

        v_table_end := clock_timestamp();

        v_total_rows := v_total_rows + v_rows;
        v_tables_loaded := v_tables_loaded + 1;

        RAISE NOTICE '✓ SUCCESS';
        RAISE NOTICE 'Rows Loaded : %', v_rows;
        RAISE NOTICE 'Duration    : %', v_table_end - v_table_start;


    EXCEPTION
        WHEN OTHERS THEN

            RAISE NOTICE '';
            RAISE NOTICE '✗ FAILED';
            RAISE NOTICE 'Table : silver.erp_loc_a101';
            RAISE NOTICE 'Error : %', SQLERRM;

            RAISE;
    END;



    ------------------------------------------------------------
    -- erp_px_cat_g1v2
    ------------------------------------------------------------

    BEGIN

        v_table_start := clock_timestamp();

        RAISE NOTICE '';
        RAISE NOTICE 'Loading silver.erp_px_cat_g1v2...';

        INSERT INTO silver.erp_px_cat_g1v2 (
            id, cat, subcat, maintenance
        )
        SELECT
            id,
            cat,
            subcat,
            maintenance
        FROM bronze.erp_px_cat_g1v2;

        GET DIAGNOSTICS v_rows = ROW_COUNT;

        v_table_end := clock_timestamp();

        v_total_rows := v_total_rows + v_rows;
        v_tables_loaded := v_tables_loaded + 1;

        RAISE NOTICE '✓ SUCCESS';
        RAISE NOTICE 'Rows Loaded : %', v_rows;
        RAISE NOTICE 'Duration    : %', v_table_end - v_table_start;


    EXCEPTION
        WHEN OTHERS THEN

            RAISE NOTICE '';
            RAISE NOTICE '✗ FAILED';
            RAISE NOTICE 'Table : silver.erp_px_cat_g1v2';
            RAISE NOTICE 'Error : %', SQLERRM;

            RAISE;
    END;



    ------------------------------------------------------------
    -- FINAL SUMMARY
    ------------------------------------------------------------

    v_job_end := clock_timestamp();


    RAISE NOTICE '';
    RAISE NOTICE '============================================================';
    RAISE NOTICE '                       JOB SUMMARY';
    RAISE NOTICE '============================================================';
    RAISE NOTICE 'Tables Loaded : %', v_tables_loaded;
    RAISE NOTICE 'Rows Loaded   : %', v_total_rows;
    RAISE NOTICE 'Total Runtime : %', v_job_end - v_job_start;

    RAISE NOTICE '';
    RAISE NOTICE '============================================================';
    RAISE NOTICE '          ✓ SILVER LAYER LOADED SUCCESSFULLY';
    RAISE NOTICE '============================================================';


END;
$$;
