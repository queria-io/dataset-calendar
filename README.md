# 日本の暦

1955 年から 2027 年までの日本の暦を 1 日 1 行にまとめ、祝日・振替休日・曜日・会計年度・和暦を付けたデータセットです。営業日数の計算や、日付の列を持つテーブルとの結合に使えます。

## 出典と利用条件

- [内閣府「国民の祝日について」](https://www8.cao.go.jp/chosei/shukujitsu/gaiyou.html)の祝日データを加工して作成しています（CC BY、出典: 内閣府）
- 日付は DuckDB の generate_series で生成しています

## テーブル

`calendar.day` は 1955-01-01 から 2027-12-31 までの 26,663 日を 1 日 1 行で持ちます。

| 列 | 内容 |
| --- | --- |
| `date` | 日付（主キー） |
| `year` / `month` / `day` | 年 / 月 / 日 |
| `weekday_code` / `weekday` | 曜日コード（ISO 8601、月曜=1〜日曜=7） / 曜日名 |
| `is_holiday` / `holiday_name` | 国民の祝日か / 祝日名（祝日でなければ NULL） |
| `is_substitute_holiday` | 振替休日か |
| `is_sat` / `is_sun` / `is_sat_sun` | 土曜 / 日曜 / 土日か |
| `is_sat_sun_holiday` | 土曜・日曜・祝日・振替休日のいずれか |
| `is_weekday` | 土日祝でない日か |
| `fiscal_year` / `fiscal_quarter` | 会計年度（4 月始まり） / 四半期（Q1=4〜6 月） |
| `wareki_era` / `wareki_year` / `wareki_label` | 元号 / 和暦年 / 表記（例: 令和2年） |

## 使い方

2025 年度の平日の日数を数える:

```sql
SELECT count(*) AS weekdays
FROM calendar.calendar.day
WHERE fiscal_year = 2025 AND is_weekday;
```

営業日の数え方は [営業日・祝日を SQL で扱う](docs/business-days.md) にあります。

## 注意

- `is_holiday` は国民の祝日だけで、振替休日を含みません。休日かどうかは `is_sat_sun_holiday` で判定してください
- 年末年始などの企業の休業日は含みません
- 2027 年より後の日付はありません
