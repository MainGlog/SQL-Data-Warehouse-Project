/* Gets all the names of the tables in the bronze schema */ 
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @TableNames TABLE (ID INT, Name NVARCHAR(64)); 

	INSERT INTO @TableNames
	SELECT ROW_NUMBER() OVER (ORDER BY T.object_id) AS 'ID', T.name
	FROM SYS.SCHEMAS S
	JOIN SYS.TABLES T ON S.schema_id = T.schema_id
	WHERE S.name = 'bronze'
	ORDER BY T.name;



	PRINT '============================================';
	PRINT '			 Loading Bronze Layer ';
	PRINT '============================================' + CHAR(13);;
	DECLARE @Count INT = 1;	

	DECLARE @FilePathPrefix NVARCHAR(3) = ''; 

	/* Iterates through the tables */
	WHILE @Count <= 6
	BEGIN
		DECLARE @TableName NVARCHAR (64) = (SELECT Name FROM @TableNames WHERE ID = @Count); 

		/* Only prints out a new section if the section has changed. I.e. crm to erp */
		DECLARE @TempPrefix NVARCHAR(3) = (SELECT TOP 1 * FROM STRING_SPLIT(@TableName, '_'));
		IF @FilePathPrefix != @TempPrefix
		BEGIN
			SET @FilePathPrefix = @TempPrefix;

			PRINT '--------------------------------------------';
			PRINT '			 Loading ' + UPPER(@FilePathPrefix) + ' Tables...';
			PRINT '--------------------------------------------';
		END

		/* Obtains the file name of the data source */
		DECLARE @FileName NVARCHAR(32) = (SELECT SUBSTRING(@TableName, CHARINDEX('_', @TableName) + 1, LEN(@TableName)) + '.csv');
	
		/* Truncates the table before bulk loading the data from the file source into the appropriate table */
		DECLARE @Statement NVARCHAR(MAX) = '
		PRINT ''>> Truncating Table: bronze.' + @TableName + ''';
	
		TRUNCATE TABLE bronze.' + @TableName + ';

		PRINT ''>> Inserting Data Into: bronze.' + @TableName + ''';

		BULK INSERT bronze.' + @TableName + '
		FROM ''C:\Users\mtnje\OneDrive\Desktop\Programming\Database Stuff\SQL Data Warehouse Project\datasets\source_' + @FilePathPrefix + '\' + @FileName + '''
		WITH (
			FIRSTROW = 2, 
			FIELDTERMINATOR = '','',
			TABLOCK 
		);

		PRINT '''';
		';

		EXEC(@Statement);

		SET @Count = @Count + 1;
	END
END