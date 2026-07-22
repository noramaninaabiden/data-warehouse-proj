CREATE OR REPLACE PROCEDURE bronze.load_bronze()
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
    RAISE NOTICE '                    BRONZE LAYER LOAD';
    RAISE NOTICE '============================================================';
    RAISE NOTICE 'Started : %', v_job_start;

    RAISE NOTICE '';
    RAISE NOTICE '---------------- PREPARING ENVIRONMENT ----------------';

    BEGIN

        v_table_start := clock_timestamp();

        RAISE NOTICE '';
        RAISE NOTICE 'Truncating Bronze tables...';

        TRUNCATE TABLE
            bronze.crm_cust_info,
            bronze.crm_prd_info,
            bronze.crm_sales_details,
            bronze.erp_cust_az12,
            bronze.erp_loc_a101,
            bronze.erp_px_cat_g1v2;

        v_table_end := clock_timestamp();

        RAISE NOTICE '✓ SUCCESS';
        RAISE NOTICE 'All Bronze tables truncated.';
        RAISE NOTICE 'Duration : %', v_table_end - v_table_start;

    EXCEPTION
        WHEN OTHERS THEN

            v_table_end := clock_timestamp();

            RAISE NOTICE '';
            RAISE NOTICE '✗ FAILED';
            RAISE NOTICE 'Failed to truncate Bronze tables.';
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
        RAISE NOTICE 'Loading bronze.crm_cust_info...';

        COPY bronze.crm_cust_info
        FROM 'C:\Portfolio\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        DELIMITER ','
        CSV HEADER;

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
            RAISE NOTICE 'Table : bronze.crm_cust_info';
            RAISE NOTICE 'Error : %', SQLERRM;

            RAISE;
    END;



    ------------------------------------------------------------
    -- crm_prd_info
    ------------------------------------------------------------

    BEGIN

        v_table_start := clock_timestamp();

        RAISE NOTICE '';
        RAISE NOTICE 'Loading bronze.crm_prd_info...';

        COPY bronze.crm_prd_info
        FROM 'C:\Portfolio\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        DELIMITER ','
        CSV HEADER;

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
            RAISE NOTICE 'Table : bronze.crm_prd_info';
            RAISE NOTICE 'Error : %', SQLERRM;

            RAISE;
    END;



    ------------------------------------------------------------
    -- crm_sales_details
    ------------------------------------------------------------

    BEGIN

        v_table_start := clock_timestamp();

        RAISE NOTICE '';
        RAISE NOTICE 'Loading bronze.crm_sales_details...';

        COPY bronze.crm_sales_details
        FROM 'C:\Portfolio\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        DELIMITER ','
        CSV HEADER;

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
            RAISE NOTICE 'Table : bronze.crm_sales_details';
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
        RAISE NOTICE 'Loading bronze.erp_cust_az12...';

        COPY bronze.erp_cust_az12
        FROM 'C:\Portfolio\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
        DELIMITER ','
        CSV HEADER;

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
            RAISE NOTICE 'Table : bronze.erp_cust_az12';
            RAISE NOTICE 'Error : %', SQLERRM;

            RAISE;
    END;



    ------------------------------------------------------------
    -- erp_loc_a101
    ------------------------------------------------------------

    BEGIN

        v_table_start := clock_timestamp();

        RAISE NOTICE '';
        RAISE NOTICE 'Loading bronze.erp_loc_a101...';

        COPY bronze.erp_loc_a101
        FROM 'C:\Portfolio\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
        DELIMITER ','
        CSV HEADER;

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
            RAISE NOTICE 'Table : bronze.erp_loc_a101';
            RAISE NOTICE 'Error : %', SQLERRM;

            RAISE;
    END;



    ------------------------------------------------------------
    -- erp_px_cat_g1v2
    ------------------------------------------------------------

    BEGIN

        v_table_start := clock_timestamp();

        RAISE NOTICE '';
        RAISE NOTICE 'Loading bronze.erp_px_cat_g1v2...';

        COPY bronze.erp_px_cat_g1v2
        FROM 'C:\Portfolio\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
        DELIMITER ','
        CSV HEADER;

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
            RAISE NOTICE 'Table : bronze.erp_px_cat_g1v2';
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
    RAISE NOTICE '          ✓ BRONZE LAYER LOADED SUCCESSFULLY';
    RAISE NOTICE '============================================================';


END;
$$;
