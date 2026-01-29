/*
=======================================================================================================
Create Databsae and Schemas
=======================================================================================================
Script Purpose:
     This Script creates a new database named 'DataWareHouse' after checking if it already exists.
     If the database exists,it is drp[eed and recreated.Additionally, the script sets up three schemas
     within the database:'bronze','silver' and 'gold'.

Warning:
     Running this script will drop the entire 'DataWarehouse' databse if it exists.
     All data in the database will be permanently deleted. Proceed with caution
     and ensure you proper backups before running this script.
*/

Use Master;
GO

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
     ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
     DROP DATABASE DataWarehouse;
END;
GO

-- Create Database 'DataWarehouse'
Create Database DataWarehouse;
GO
  
 use DataWarehouse;
GO

  --Create Schemeas
 Create SCHEMA bronze;
 go
 Create SCHEMA silver;
 go
 Create SCHEMA gold;
Go
