/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/


IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info (
	cst_id				INT,
	cst_key				NVARCHAR(64),
	cst_firstname		NVARCHAR(64),
	cst_lastname		NVARCHAR(64),
	cst_marital_status	NVARCHAR(4),
	cst_gndr			NVARCHAR(32),
	cst_create_date		DATE
);


IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info (
	prd_id			INT,
	prd_key			NVARCHAR(64),
	prd_nm			NVARCHAR(256),
	prd_cost		INT,
	prd_line		NVARCHAR(32),
	prd_start_dt	DATETIME,
	prd_end_dt		DATETIME
);


IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details (
	sls_ord_num		NVARCHAR(32),
	sls_prd_key		NVARCHAR(32),
	sls_cust_id		INT,
	sls_order_dt	INT,
	sls_ship_dt		INT,
	sls_due_dt		INT,
	sls_sales		INT,
	sls_quantity	INT,
	sls_price		INT
);


IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12 (
	cid		NVARCHAR(32),
	bdate	DATE,
	gen		NVARCHAR(32)
);


IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101 (
	cid		NVARCHAR(32),
	cntry	NVARCHAR(128)
);

IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2 (
	id			NVARCHAR(8),
	cat			NVARCHAR(64),
	subcat		NVARCHAR(64),
	maintenace  NVARCHAR(3)
);