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