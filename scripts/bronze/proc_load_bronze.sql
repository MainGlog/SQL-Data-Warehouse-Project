/* Gets all the names of the tables in the bronze schema */ 
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	BEGIN TRY
		DECLARE @table_names TABLE (ID INT, Name NVARCHAR(64)); 

		INSERT INTO @table_names
		SELECT ROW_NUMBER() OVER (ORDER BY T.object_id) AS 'ID', T.name
		FROM SYS.SCHEMAS S
		JOIN SYS.TABLES T ON S.schema_id = T.schema_id
		WHERE S.name = 'bronze'
		ORDER BY T.name;



		PRINT '============================================';
		PRINT '			 Loading Bronze Layer ';
		PRINT '============================================' + CHAR(13);;


		DECLARE @count INT = 1;	-- Loop iteration variable
		DECLARE @file_path_prefix NVARCHAR(3) = ''; -- Whether the source is from CRM or ERP
		DECLARE @total_time INT = 0;

		/* Iterates through the tables */
		WHILE @count <= 6
		BEGIN
			DECLARE @table_name NVARCHAR (64) = (SELECT Name FROM @table_names WHERE ID = @count); 

			/* Only prints out a new section if the section has changed. I.e. crm to erp */
			DECLARE @temp_prefix NVARCHAR(3) = (SELECT TOP 1 * FROM STRING_SPLIT(@table_name, '_'));
			IF @file_path_prefix != @temp_prefix
			BEGIN
				SET @file_path_prefix = @temp_prefix;

				PRINT '=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=';
				PRINT '			 Loading ' + UPPER(@file_path_prefix) + ' Tables...';
				PRINT '=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=' + CHAR(13);
			END

			/* Obtains the file name of the data source */
			DECLARE @file_name NVARCHAR(32) = (SELECT SUBSTRING(@table_name, CHARINDEX('_', @table_name) + 1, LEN(@table_name)) + '.csv');
			
			/* Truncates the table before bulk loading the data from the file source into the appropriate table */
			DECLARE @statement NVARCHAR(MAX) = '
			PRINT ''--------------------------------------------'';

			PRINT ''>> Truncating Table: bronze.' + @table_name + ''';
			


			TRUNCATE TABLE bronze.' + @table_name + ';

			PRINT ''>> Inserting Data Into: bronze.' + @table_name + ''';

			BULK INSERT bronze.' + @table_name + '
			FROM ''C:\Users\mtnje\OneDrive\Desktop\Programming\Database Stuff\SQL Data Warehouse Project\datasets\source_' + @file_path_prefix + '\' + @file_name + '''
			WITH (
				FIRSTROW = 2, 
				FIELDTERMINATOR = '','',
				TABLOCK 
			);
			';

			DECLARE @start_time DATETIME, @end_time DATETIME, @difference INT;
			
			SET @start_time = GETDATE();
			
			EXEC(@statement);
			
			SET @end_time = GETDATE();
			SET @difference = DATEDIFF(second, @start_time, @end_time);
			SET @total_time = @total_time + @difference;
			
			PRINT '>> Load Duration: ' + CAST(@difference AS NVARCHAR) + ' seconds';
			PRINT '--------------------------------------------' + CHAR(13);
			
			SET @count = @count + 1;
		END
		PRINT '============================================';
		PRINT '		Bronze Layer Loaded in ' + CAST(@total_time AS NVARCHAR) + ' seconds';
		PRINT '============================================' + CHAR(13);;
	END TRY

	BEGIN CATCH
		PRINT '============================================';
		PRINT '  ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '============================================';
	END CATCH
END

