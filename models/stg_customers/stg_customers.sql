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
