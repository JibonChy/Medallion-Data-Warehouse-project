**Data Catalog — Gold Layer**

**Overview**
The Gold Layer is the business‑level representation of data, designed to support analytics and reporting.
It consists of dimension tables (contextual attributes) and fact tables (business metrics).

**1. Dimension: gold.dim_customers** 

Purpose: Stores customer details enriched with demographic and geographic attributes.
| **Column Name** | **Data Type** | **Description** |
| --- | --- | --- |
| customer_key | INT | Surrogate key uniquely identifying each customer record. |
| customer_id | INT | Unique numerical identifier assigned to each customer. |
| customer_number | NVARCHAR(50) | Alphanumeric identifier used for tracking and referencing. |
| first_name | NVARCHAR(50) | Customer’s first name. |
| last_name | NVARCHAR(50) | Customer’s last name or family name. |
| country | NVARCHAR(50) | Country of residence (e.g., 'Australia'). |
| marital_status | NVARCHAR(50) | Marital status (e.g., 'Married', 'Single'). |
| gender | NVARCHAR(50) | Gender (e.g., 'Male', 'Female', 'n/a'). |
| birthdate | DATE | Date of birth (YYYY‑MM‑DD). |
| create_date | DATE | Date when the customer record was created. |


**2. Dimension: gold.dim_products** 

**Purpose:** Provides detailed information about products and their attributes.

| **Column Name** | **Data Type** | **Description** |
| --- | --- | --- |
| product_key | INT | Surrogate key uniquely identifying each product record. |
| product_id | INT | Unique identifier assigned to the product. |
| product_number | NVARCHAR(50) | Structured alphanumeric code for categorization/inventory. |
| product_name | NVARCHAR(50) | Descriptive product name (type, color, size). |
| category_id | NVARCHAR(50) | Identifier for product’s category. |
| category | NVARCHAR(50) | Broad classification (e.g., Bikes, Components). |
| subcategory | NVARCHAR(50) | Detailed classification within the category. |
| maintenance_required | NVARCHAR(50) | Indicates if product requires maintenance ('Yes', 'No'). |
| cost | INT | Base price of the product. |
| product_line | NVARCHAR(50) | Product line or series (e.g., Road, Mountain). |
| start_date | DATE | Date when product became available. |


**3.Fact: gold.fact_sales**
**Purpose:** Stores transactional sales data for analytical purposes.


| **Column Name** | **Data Type** | **Description** |
| --- | --- | --- |
| order_number | NVARCHAR(50) | Unique alphanumeric identifier for each sales order. |
| product_key | INT | Surrogate key linking to product dimension. |
| customer_key | INT | Surrogate key linking to customer dimension. |
| order_date | DATE | Date when the order was placed. |
| shipping_date | DATE | Date when the order was shipped. |
| due_date | DATE | Payment due date. |
| sales_amount | INT | Total monetary value of the sale. |
| quantity | INT | Number of units ordered. |
| price | INT | Price per unit of the product. |
