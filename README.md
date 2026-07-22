# data-warehouse-proj

A small PostgreSQL data warehouse built on the bronze/silver/gold (medallion) pattern. Raw CRM and ERP CSVs get loaded as-is into bronze, cleaned and standardized into silver, then modeled into a star schema in gold.

This follows the layer structure and general approach from a well-known SQL Server data warehousing tutorial — I ported it to PostgreSQL myself, which meant rewriting the load procedures in plpgsql (the original uses T-SQL), adjusting the DDL to Postgres types, and swapping `BULK INSERT` for `COPY`.

<img width="741" height="313" alt="Data Flow" src="https://github.com/user-attachments/assets/4ade2808-2e6e-42ae-9423-8cfb44aa97d5" />

## Layers

**Bronze** — raw load, no transformation. Six tables mirroring the source CSVs: `crm_cust_info`, `crm_prd_info`, `crm_sales_details` from CRM, and `erp_cust_az12`, `erp_loc_a101`, `erp_px_cat_g1v2` from ERP (~18K customers, ~60K sales records total). Loaded via `COPY` inside `bronze.load_bronze()`, which truncates and reloads every table and logs row counts + duration for each one via `RAISE NOTICE`.

**Silver** — same tables, cleaned up. This layer:
- deduplicates customer records, keeping the latest row per `cst_id`
- trims whitespace and standardizes coded values (`M`/`F` → `Male`/`Female`, etc.)
- fixes invalid order/ship/due dates and recalculates sales figures where they don't match `quantity * price`
- normalizes country names and strips formatting inconsistencies between source systems

Built the same way as bronze — `silver.load_silver()`, same truncate/reload/log pattern.

**Gold** — three views on top of silver: `dim_customers`, `dim_products`, `fact_sales`. This is the layer meant to actually be queried.

<img width="641" height="361" alt="Gold layer ERD" src="https://github.com/user-attachments/assets/ca1c98e6-0d09-4204-80ed-1a0b3a56482f" />

## Structure

```
datasets/
  source_crm/                raw CRM CSVs
  source_erp/                 raw ERP CSVs
scripts/
  init_database.sql           creates the DWh database + bronze/silver/gold schemas
  bronze/
    ddl_bronze.sql             bronze table definitions
    proc_load_bronze.sql        bronze.load_bronze()
  silver/
    ddl_silver.sql              silver table definitions
    proc_load_silver.sql         silver.load_silver()
  gold/
    ddl_gold.sql                gold views
```

## Running it

1. `scripts/init_database.sql` — creates the database and the three schemas
2. `scripts/bronze/ddl_bronze.sql` — creates bronze tables
3. `scripts/bronze/proc_load_bronze.sql` — creates the procedure, then run `CALL bronze.load_bronze();`
4. `scripts/silver/ddl_silver.sql` — creates silver tables
5. `scripts/silver/proc_load_silver.sql` — creates the procedure, then run `CALL silver.load_silver();`
6. `scripts/gold/ddl_gold.sql` — creates the gold views

The CSV paths inside `proc_load_bronze.sql` are hardcoded to a local path — update those to match wherever you've cloned the repo before running.

## Stack

PostgreSQL, plpgsql, SQL.
