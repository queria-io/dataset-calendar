{# 非推奨。calendar.calendar.day と同じ中身で、のちに削除する #}
{{ config(materialized='view') }}

select * from {{ ref('day') }}
