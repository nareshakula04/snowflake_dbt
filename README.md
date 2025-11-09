# Banking Analytics dbt Project

## Overview
This dbt project builds an end-to-end **Banking Data Pipeline** on Snowflake and exposes a unified analytics view for **Power BI dashboards**.  

The pipeline transforms data from:
- **Raw Layer:** `RAW.CUSTOMERS_SCHEMA`  
- **Staging Layer:** `stg_customers`, `stg_accounts`, `stg_transactions`  
- **Analytics Layer:** `transactions` (view - joins all three models)

---

## Folder Structure
```
banking_dbt_project/
│
├── models/
│   ├── stg_customers/
│   │   ├── stg_customers.sql
│   │   ├── stg_accounts.sql
│   │   ├── stg_transactions.sql
│   │   └── schema.yml
│   │
│   └── stg_marts/
│       └── transactions.sql
|
├── dbt_project.yml
├── .gitignore
└── README.md
```

---

## 1. Source Setup in Snowflake

### Create Warehouse, Databases, Schemas and Tables
```sql
create warehouse analytics_wh;

create database raw;

create database analytics;

create schema raw.customers_schema;

CREATE TABLE raw.customers_schema.customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender CHAR(1),
    dob DATE,
    city VARCHAR(50),
    state VARCHAR(50),
    pincode VARCHAR(10),
    email VARCHAR(80),
    contact_no VARCHAR(15),
    occupation VARCHAR(50),
    annual_income DECIMAL(12,2)
);

CREATE TABLE raw.customers_schema.accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    branch_name VARCHAR(50),
    account_type VARCHAR(20),
    opening_date DATE,
    status VARCHAR(20),
    balance DECIMAL(12,2),
    ifsc_code VARCHAR(15),
    interest_rate DECIMAL(5,2),
    currency VARCHAR(10),
    nominee_name VARCHAR(50),
    nominee_relation VARCHAR(30),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE raw.customers_schema.transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT,
    transaction_date DATE,
    transaction_type VARCHAR(20),
    mode_of_payment VARCHAR(20),
    amount DECIMAL(12,2),
    opening_balance DECIMAL(12,2),
    closing_balance DECIMAL(12,2),
    branch_name VARCHAR(50),
    city VARCHAR(50),
    remarks VARCHAR(100),
    cheque_no VARCHAR(20),
    reference_no VARCHAR(20),
    channel VARCHAR(20),
    status VARCHAR(15),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

INSERT INTO RAW.CUSTOMERS_SCHEMA.CUSTOMERS VALUES
(101, 'Rahul', 'Verma', 'M', '1988-02-12', 'Mumbai', 'Maharashtra', '400001', 'rahul.verma@gmail.com', '9876543210', 'Software Engineer', 1200000.00),
(102, 'Sneha', 'Iyer', 'F', '1990-06-05', 'Bangalore', 'Karnataka', '560001', 'sneha.iyer@gmail.com', '9988776655', 'Data Analyst', 950000.00),
(103, 'Arjun', 'Reddy', 'M', '1985-11-20', 'Hyderabad', 'Telangana', '500001', 'arjun.reddy@gmail.com', '9123456789', 'Doctor', 1500000.00),
(104, 'Kiran', 'Kumar', 'M', '1992-04-11', 'Chennai', 'Tamil Nadu', '600001', 'kiran.kumar@gmail.com', '9797979797', 'Civil Engineer', 1100000.00),
(105, 'Priya', 'Nair', 'F', '1993-08-08', 'Kochi', 'Kerala', '682001', 'priya.nair@gmail.com', '9012345678', 'Marketing Lead', 1050000.00),
(106, 'Vikram', 'Das', 'M', '1987-12-14', 'Pune', 'Maharashtra', '411001', 'vikram.das@gmail.com', '9090909090', 'Bank Manager', 1250000.00),
(107, 'Ananya', 'Sharma', 'F', '1991-03-21', 'Delhi', 'Delhi', '110001', 'ananya.sharma@gmail.com', '9123456700', 'Architect', 950000.00),
(108, 'Rajesh', 'Mehta', 'M', '1984-07-30', 'Jaipur', 'Rajasthan', '302001', 'rajesh.mehta@gmail.com', '9955443322', 'Business Owner', 2000000.00),
(109, 'Sandeep', 'Ghosh', 'M', '1989-01-09', 'Kolkata', 'West Bengal', '700001', 'sandeep.ghosh@gmail.com', '9123456799', 'Teacher', 800000.00),
(110, 'Deepika', 'Rao', 'F', '1994-09-22', 'Hyderabad', 'Telangana', '500002', 'deepika.rao@gmail.com', '9811122233', 'Software Engineer',970000.00);

INSERT INTO RAW.CUSTOMERS_SCHEMA.ACCOUNTS VALUES
(2001, 101, 'Mumbai Main', 'Savings', '2020-01-15', 'Active', 50000.00, 'HDFC0001', 3.50, 'INR', 'Anita Verma', 'Wife'),
(2002, 101, 'Mumbai Main', 'Current', '2021-02-20', 'Active', 120000.00, 'HDFC0001', 0.00, 'INR', 'Ravi Verma', 'Brother'),
(2003, 102, 'Bangalore Central', 'Savings', '2019-06-05', 'Active', 75000.00, 'SBI0002', 3.75, 'INR', 'Maya Iyer', 'Mother'),
(2004, 103, 'Hyderabad Banjara', 'Savings', '2018-10-11', 'Active', 90000.00, 'ICIC0003', 3.50, 'INR', 'Anu Reddy', 'Wife'),
(2005, 103, 'Hyderabad Banjara', 'Current', '2021-04-01', 'Active', 30000.00, 'ICIC0003', 0.00, 'INR', 'Arav Reddy', 'Son'),
(2006, 104, 'Chennai South', 'Savings', '2017-05-09', 'Active', 65000.00, 'AXIS0004', 3.50, 'INR', 'Latha Kumar', 'Mother'),
(2007, 105, 'Kochi Fort', 'Savings', '2020-08-22', 'Active', 40000.00, 'KOTK0005', 3.60, 'INR', 'Raj Nair', 'Father'),
(2008, 106, 'Pune Camp', 'Current', '2016-03-18', 'Active', 80000.00, 'YESB0006', 0.00, 'INR', 'Vikas Das', 'Brother'),
(2009, 106, 'Pune Camp', 'Savings', '2022-01-25', 'Active', 55000.00, 'YESB0006', 3.40, 'INR', 'Neha Das', 'Wife'),
(2010, 107, 'Delhi Connaught', 'Savings', '2019-07-05', 'Active', 95000.00, 'PNB0007', 3.75, 'INR', 'Kunal Sharma', 'Husband'),
(2011, 108, 'Jaipur City', 'Savings', '2020-09-14', 'Active', 42000.00, 'BOB0008', 3.60, 'INR', 'Rina Mehta', 'Wife'),
(2012, 108, 'Jaipur City', 'Current', '2019-04-20', 'Active', 50000.00, 'BOB0008', 0.00, 'INR', 'Rekha Mehta', 'Sister'),
(2013, 109, 'Kolkata Park St', 'Savings', '2020-10-25', 'Active', 35000.00, 'UCO0009', 3.80, 'INR', 'Anjali Ghosh', 'Wife'),
(2014, 110, 'Hyderabad KPHB', 'Current', '2021-06-15', 'Active', 70000.00, 'HDFC0010', 0.00, 'INR', 'Vivek Rao', 'Brother'),
(2015, 110, 'Hyderabad KPHB', 'Savings', '2018-02-01', 'Active', 25000.00, 'HDFC0010', 3.45, 'INR', 'Ravi Rao','Father');

INSERT INTO RAW.CUSTOMERS_SCHEMA.TRANSACTIONS VALUES
(1, 2002, '2024-01-02', 'Deposit', 'Online', 44564.21, 73669.78, 118233.99, 'Hyderabad Banjara', 'Hyderabad', 'Salary credited via online transfer', NULL, 'REF0001', 'NetBanking', 'Success'),
(2, 2003, '2024-01-03', 'Withdrawal', 'Cheque', 45960.54, 88716.89, 42756.35, 'Pune Camp', 'Pune', 'Vendor payment - Alpha Corp', 'CHQ1002', 'REF0002', 'Branch', 'Success'),
(3, 2004, '2024-01-04', 'Deposit', 'ATM', 33994.04, 72771.12, 106765.16, 'Delhi Connaught', 'Delhi', NULL, NULL, 'REF0003', 'ATM', 'Success'),
(4, 2005, '2024-01-05', 'Withdrawal', 'Online', 29064.47, 22128.52, -6935.95, 'Jaipur City', 'Jaipur', 'Online bill payment', NULL, 'REF0004', 'NetBanking', 'Failed'),
(5, 2006, '2024-01-06', 'Deposit', 'Cheque', 42902.91, 86049.52, 128952.43, 'Chennai South', 'Chennai', NULL, 'CHQ1005', 'REF0005', NULL, 'Success'),
(6, 2007, '2024-01-07', 'Withdrawal', 'ATM', 22265.78, 88619.67, 66353.89, 'Kolkata Park St', 'Kolkata', 'ATM cash withdrawal', NULL, 'REF0006', 'ATM', 'Success'),
(7, 2008, '2024-01-08', 'Deposit', 'Online', 32898.57, 66909.83, 99808.40, 'Kochi Fort', 'Kochi', NULL, NULL, 'REF0007', 'NetBanking', 'Success'),
(8, 2009, '2024-01-09', 'Withdrawal', 'Cash', 31744.89, 60656.12, 28911.23, 'Mumbai Main', 'Mumbai', 'Cash withdrawal branch counter', NULL, 'REF0008', NULL, 'Success'),
(9, 2010, '2024-01-10', 'Deposit', 'Cheque', 14879.23, 35276.34, 50155.57, 'Hyderabad Banjara', 'Hyderabad', NULL, 'CHQ1009', 'REF0009', 'Branch', 'Success'),
(10, 2011, '2024-01-11', 'Withdrawal', 'Online', 20137.47, 51612.47, 31475.00, 'Pune Camp', 'Pune', 'UPI merchant transfer', NULL, 'REF0010', 'MobileApp', 'Success'),
(11, 2012, '2024-01-12', 'Deposit', 'Cash', 41552.18, 14526.37, 56078.55, 'Delhi Connaught', 'Delhi', NULL, NULL, 'REF0011', 'Branch', 'Success'),
(12, 2013, '2024-01-13', 'Withdrawal', 'Cheque', 45622.59, 85489.73, 39867.14, 'Jaipur City', 'Jaipur', 'Client refund', 'CHQ1012', 'REF0012', NULL, 'Success'),
(13, 2014, '2024-01-14', 'Deposit', 'UPI', 13291.34, 32889.45, 46180.79, 'Chennai South', 'Chennai', 'GPay transfer from employer', NULL, 'REF0013', 'MobileApp', 'Success'),
(14, 2015, '2024-01-15', 'Withdrawal', 'ATM', 27465.29, 81298.11, 53832.82, 'Kolkata Park St', 'Kolkata', NULL, NULL, 'REF0014', 'ATM', 'Success'),
(15, 2001, '2024-01-16', 'Deposit', 'Online', 44234.83, 18344.58, 62579.41, 'Kochi Fort', 'Kochi', 'Deposit via IMPS', NULL, 'REF0015', 'NetBanking', 'Success'),
(16, 2002, '2024-01-17', 'Withdrawal', 'Cheque', 17746.59, 70371.82, 52625.23, 'Mumbai Main', 'Mumbai', NULL, 'CHQ1016', 'REF0016', 'Branch', 'Pending'),
(17, 2003, '2024-01-18', 'Deposit', 'UPI', 19388.27, 59159.74, 78548.01, 'Hyderabad Banjara', 'Hyderabad', 'UPI Payment from client', NULL, 'REF0017', 'MobileApp', 'Success'),
(18, 2004, '2024-01-19', 'Withdrawal', 'Online', 47968.09, 57056.47, 9088.38, 'Pune Camp', 'Pune', NULL, NULL, 'REF0018', 'NetBanking', 'Success'),
(19, 2005, '2024-01-20', 'Deposit', 'Cash', 35547.29, 39553.42, 75000.71, 'Delhi Connaught', 'Delhi', 'Branch cash counter', NULL, 'REF0019', 'Branch', 'Success'),
(20, 2006, '2024-01-21', 'Withdrawal', 'ATM', 25689.04, 65540.72, 39851.68, 'Jaipur City', 'Jaipur', NULL, NULL, 'REF0020', 'ATM', 'Success'),
(21, 2007, '2024-01-22', 'Deposit', 'Cheque', 33231.66, 25639.44, 58871.10, 'Chennai South', 'Chennai', NULL, 'CHQ1021', 'REF0021', NULL, 'Success'),
(22, 2008, '2024-01-23', 'Withdrawal', 'UPI', 31068.87, 46352.29, 15283.42, 'Kolkata Park St', 'Kolkata', 'PhonePe grocery payment', NULL, 'REF0022', 'MobileApp', 'Success'),
(23, 2009, '2024-01-24', 'Deposit', 'Online', 15309.93, 23132.66, 38442.59, 'Kochi Fort', 'Kochi', NULL, NULL, 'REF0023', 'NetBanking', 'Success'),
(24, 2010, '2024-01-25', 'Withdrawal', 'ATM', 24226.44, 87438.37, 63211.93, 'Mumbai Main', 'Mumbai', 'ATM withdrawal late night', NULL, 'REF0024', 'ATM', 'Success'),
(25, 2011, '2024-01-26', 'Deposit', 'Cheque', 18289.72, 74519.16, 92808.88, 'Hyderabad Banjara', 'Hyderabad', NULL, 'CHQ1025', 'REF0025', 'Branch','Success');
```


---

## 2. dbt Source Configuration and test Cases
**File:** `models/stg_customers/schema.yml`
```yaml
version: 2

sources:
  - name: raw                          # logical source name
    database: raw                     # actual Snowflake database
    schema: customers_schema           # actual schema name in Snowflake

    tables:
      - name: customers
        description: "Raw customer master data containing personal and demographic details."
        columns:
          - name: customer_id
            description: "Unique identifier for each customer"
            tests:
              - not_null
              - unique
          - name: email
            description: "Customer email address"
            tests:
              - not_null
          - name: annual_income
            description: "Annual income of the customer"

      - name: accounts
        description: "Customer account details table containing account metadata and status."
        columns:
          - name: account_id
            description: "Unique account identifier"
            tests:
              - not_null
              - unique
          - name: customer_id
            description: "Foreign key linked to customers table"
            tests:
              - not_null
          - name: account_type
            description: "Type of the bank account (Savings, Current, etc.)"
          - name: balance
            description: "Current account balance"

      - name: transactions
        description: "Transactional data capturing all customer account transactions."
        columns:
          - name: transaction_id
            description: "Unique transaction identifier"
            tests:
              - not_null
              - unique
          - name: account_id
            description: "Foreign key linked to accounts table"
            tests:
              - not_null
          - name: transaction_date
            description: "Date when the transaction occurred"
          - name: transaction_amount
            description: "Amount of the transaction"
          - name: transaction_type
            description: "Type of transaction (Credit/Debit/Transfer)"
```

---

## 3. Staging Models

### stg_customers.sql
Cleans and standardizes customer attributes.
```sql
{{
    config(
        materialized='table'
    )
}}

with
    source as (select * from {{ source("raw", "customers") }}),

    cleaned as (
        select
            customer_id,
            initcap(trim(first_name)) as first_name,
            initcap(trim(last_name)) as last_name,
            upper(trim(gender)) as gender,
            dob,
            initcap(trim(city)) as city,
            initcap(trim(state)) as state,
            pincode,
            lower(trim(email)) as email,
            contact_no,
            initcap(trim(occupation)) as occupation,
            coalesce(annual_income, 0) as annual_income
        from source
        where customer_id is not null
    )

select *
from cleaned
```

### stg_accounts.sql
Normalizes account details and cleans text fields.
```sql
{{
    config(
        materialized='table'
    )
}}

with source as (
    select * from {{ source("raw", "accounts") }}
),

cleaned as (
    select
        account_id,
        customer_id,
        initcap(trim(branch_name)) as branch_name,
        initcap(trim(account_type)) as account_type,
        opening_date,
        initcap(trim(status)) as status,
        coalesce(balance, 0) as balance,
        upper(trim(ifsc_code)) as ifsc_code,
        coalesce(interest_rate, 0) as interest_rate,
        upper(trim(currency)) as currency,
        initcap(trim(nominee_name)) as nominee_name,
        initcap(trim(nominee_relation)) as nominee_relation
    from source
    where account_id is not null
)

select * from cleaned
```

### stg_transactions.sql
Implements incremental load logic on `transaction_date`.
```sql
{{ 
    config(
        materialized = 'incremental',
        unique_key = 'transaction_id',
        incremental_strategy = 'append'
    )
}}

with source as (
    select * from {{ source('raw', 'transactions') }}
),

cleaned as (
    select
        transaction_id,
        account_id,
        transaction_date,
        initcap(trim(transaction_type)) as transaction_type,
        initcap(trim(mode_of_payment)) as mode_of_payment,
        coalesce(amount, 0) as amount,
        coalesce(opening_balance, 0) as opening_balance,
        coalesce(closing_balance, 0) as closing_balance,
        initcap(trim(branch_name)) as branch_name,
        initcap(trim(city)) as city,
        trim(remarks) as remarks,
        cheque_no,
        reference_no,
        initcap(trim(channel)) as channel,
        initcap(trim(status)) as status
    from source
    where transaction_id is not null
)

-- Incremental
{% if is_incremental() %}
    -- Only pick new or modified records
    select *
    from cleaned
    where transaction_date > (select max(transaction_date) from {{ this }})
{% else %}
    select * from cleaned
{% endif %}
```

---

## 4. stg_marts

### transactions.sql
Joins all 3 staging models into one analytics view.
```sql
{{ config(materialized="view") }}

with
    customers as (select * from {{ ref("stg_customers") }}),
    accounts as (select * from {{ ref("stg_accounts") }}),
    transactions as (select * from {{ ref("stg_transactions") }})

select
    --Customer Details
    c.customer_id,
    c.first_name,
    c.last_name,
    c.gender,
    c.city as customer_city,
    c.state as customer_state,
    c.email,
    c.contact_no,
    c.occupation,
    c.annual_income,

    --Account Details
    a.account_id,
    a.account_type,
    a.branch_name,
    a.balance,
    a.ifsc_code,
    a.currency,
    a.opening_date,
    a.status as account_status,

    --Transaction Details
    t.transaction_id,
    t.transaction_date,
    t.transaction_type,
    t.mode_of_payment,
    t.amount,
    t.opening_balance,
    t.closing_balance,
    t.city as transaction_city,
    t.channel,
    t.status as transaction_status,
    t.remarks

from customers c
join accounts a on c.customer_id = a.customer_id
join transactions t on a.account_id = t.account_id
```

---

## 5. dbt Execution Flow
```bash
dbt run
dbt run --select customer_account_transactions_view
dbt docs generate
```

---

## 6. Power BI Integration

1. **Open Power BI Desktop → Get Data → Snowflake**
2. Enter:
   - **Server:** `<your_account>.snowflakecomputing.com`
   - **Warehouse:** `MY_WH`
   - **Database:** `ANALYTICS`
   - **Schema:** `MARTS`
3. Choose **DirectQuery** for real-time updates  
4. Select:  
    `TRANSACTIONS_VIEW`  
5. Click **Load**

---

## 7. Model Strategy Summary

| Model | Materialization | Key | Logic |
|--------|------------------|-----|--------|
| stg_customers | Table | customer_id | Full refresh |
| stg_accounts | Table | account_id | Full refresh |
| stg_transactions | Incremental (merge) | transaction_id | transaction_date > max(date) |
| transactions | View | — | Joins staging models |

---

## 8. Final Data Flow
```
RAW.CUSTOMERS_SCHEMA  →  dbt Staging (stg_*)  →  stg_marts View  →  Snowflake Analytics  →  Power BI
```