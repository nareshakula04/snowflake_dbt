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