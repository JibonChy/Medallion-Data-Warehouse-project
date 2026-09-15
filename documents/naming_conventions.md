

#  Naming Conventions — Data Warehouse  

##  Overview  
This document defines the **naming conventions** for schemas, tables, views, columns, and stored procedures in the data warehouse.  
The goal is to maintain **consistency, clarity, and governance** across all layers (Bronze, Silver, Gold).  

---

##  General Principles  
- **Snake case**: Use lowercase letters with underscores (`_`) to separate words.  
- **Language**: Use English for all names.  
- **Avoid reserved words**: Do not use SQL reserved words as object names.  

---

##  Table Naming Conventions  

###  Bronze Rules  
- Names must start with the **source system name**.  
- Table names must match their **original source names** without renaming.  
- **Pattern:** `<sourcesystem>_<entity>`  
- Example: `crm_customer_info` → Customer information from the CRM system.  

###  Silver Rules  
- Same as Bronze: names start with the **source system name** and match original source names.  
- **Pattern:** `<sourcesystem>_<entity>`  
- Example: `erp_product_category` → Product category data from ERP system.  

###  Gold Rules  
- Names must be **business‑aligned** and start with a **category prefix**.  
- **Pattern:** `<category>_<entity>`  
- Examples:  
  - `dim_customers` → Dimension table for customer data.  
  - `fact_sales` → Fact table containing sales transactions.  

---

##  Glossary of Category Patterns  

| **Pattern** | **Meaning**            | **Examples** |
|-------------|------------------------|--------------|
| dim_        | Dimension table        | dim_customer, dim_product |
| fact_       | Fact table             | fact_sales |
| report_     | Reporting table        | report_customers, report_sales_monthly |

---

##  Column Naming Conventions  

###  Surrogate Keys  
- All primary keys in dimension tables must use the suffix **`_key`**.  
- **Pattern:** `<table_name>_key`  
- Example: `customer_key` → Surrogate key in `dim_customers`.  

###  Technical Columns  
- All technical/system columns must start with the prefix **`dwh_`**.  
- **Pattern:** `dwh_<column_name>`  
- Example: `dwh_load_date` → Date when the record was loaded into the warehouse.  

---

##  Stored Procedure Naming  

- All stored procedures must follow the pattern: **`load_<layer>`**  
- `<layer>` = bronze, silver, or gold.  
- Examples:  
  - `load_bronze` → Procedure for loading Bronze layer.  
  - `load_silver` → Procedure for loading Silver layer.  
  - `load_gold` → Procedure for loading Gold layer.  

---

