===========================================
      Create Database and Schemas
===========================================

Introduction:
    This script sets up the DataWarehouse environment from scratch.

Purpose:
    - Drop existing DataWarehouse if it exists.
    - Create a fresh database and switch context.
    - Define schemas: bronze (raw), silver (cleaned), gold (curated).
*/

-- Use master database
USE master;
GO

-- Check if DataWarehouse exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    -- Force single-user mode to disconnect sessions
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    -- Drop the old DataWarehouse
    DROP DATABASE DataWarehouse;
END;
GO

-- Create new DataWarehouse
CREATE DATABASE DataWarehouse;

-- Switch context to DataWarehouse
USE DataWarehouse;
GO

-- Create Bronze schema (raw landing zone)
CREATE SCHEMA bronze;
GO

-- Create Silver schema (cleaned data zone)
CREATE SCHEMA silver;
GO

-- Create Gold schema (curated reporting zone)
CREATE SCHEMA gold;
GO
