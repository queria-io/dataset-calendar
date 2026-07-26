{# 内閣府 祝日CSV (UTF-8 変換済み)
   元データ: https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv
   main.py が Shift_JIS → UTF-8 変換して .queria/holidays.csv に保存 #}

{{
    config(
        materialized='table'
    )
}}

select *
from read_csv(
    '.queria/holidays.csv',
    header=true,
    columns={
        'date': 'DATE',
        'holiday_name': 'VARCHAR'
    }
)
