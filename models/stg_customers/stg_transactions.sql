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