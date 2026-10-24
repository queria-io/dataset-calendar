{# 非推奨。calendar.calendar.day と同じ中身で、のちに削除する。
   ビューにすると、カタログを calendar 以外の名前で開いたとき day を引けずに列が読めない
   （queria compile がそう開く）ので、表として写す #}
{{ config(materialized='table') }}

select * from {{ ref('day') }}
