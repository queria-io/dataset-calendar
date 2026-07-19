---
title: 営業日・祝日を SQL で扱う
order: 1
---

`mart_calendar` は1955年から数年先までの1日1行のカレンダーで、祝日・振替休日・曜日・年度・和暦のフラグを持ちます。「今月の営業日数」「次の営業日」のような業務ロジックが JOIN 1つで書けます。

## 営業日判定は is_weekday を使う

`is_weekday` は「土日でも祝日でもない平日」を表します。振替休日や、祝日に挟まれた国民の休日は `holiday_name` が付かないため、`is_holiday` だけで判定すると営業日扱いにしてしまいます。2026年5月の連休明けで違いを確認できます。

```sql
SELECT date, weekday, is_holiday, holiday_name, is_weekday
FROM calendar.main.mart_calendar
WHERE date BETWEEN DATE '2026-05-03' AND DATE '2026-05-07'
ORDER BY date
```

5月6日(水)は振替休日のため `is_holiday` は false でも `is_weekday` は false です。営業日のカウントには `is_weekday` を使ってください。

## 今月の営業日数

```sql
SELECT COUNT(*) FILTER (is_weekday) AS business_days
FROM calendar.main.mart_calendar
WHERE year = year(CURRENT_DATE) AND month = month(CURRENT_DATE)
```

## 次の営業日・N営業日後

「次の営業日」は今日より後の最初の平日です。

```sql
SELECT MIN(date) AS next_business_day
FROM calendar.main.mart_calendar
WHERE date > CURRENT_DATE AND is_weekday
```

「5営業日後」のような期限計算は `LIMIT` と `OFFSET` で書けます。

```sql
SELECT date AS due_date
FROM calendar.main.mart_calendar
WHERE date > CURRENT_DATE AND is_weekday
ORDER BY date
LIMIT 1 OFFSET 4
```

## 月別の営業日数と祝日数

年間の営業日カレンダーを一覧にします。売上目標の月割りや稼働計画の分母に使えます。

```sql
SELECT
  month,
  COUNT(*) FILTER (is_weekday) AS business_days,
  COUNT(*) FILTER (is_holiday) AS holidays
FROM calendar.main.mart_calendar
WHERE year = 2026
GROUP BY month
ORDER BY month
```

## 年度・四半期・和暦

会計年度(4月始まり)と四半期、和暦のラベルも1行に揃っています。日付を年度で集計し直すときに便利です。

```sql
SELECT date, fiscal_year, fiscal_quarter, wareki_label
FROM calendar.main.mart_calendar
WHERE date = CURRENT_DATE
```

## 手元の売上データに営業日フラグを付ける

日付列を持つ CSV を手元の DuckDB で読み込めば、営業日あたりの売上のような指標がすぐ出せます(接続方法は[DuckDB CLI からの接続](https://docs.queria.io/connection/duckdb-cli)を参照)。

```text
CREATE TABLE sales AS FROM read_csv('sales.csv');  -- date, amount 列を持つ想定

SELECT
  c.year,
  c.month,
  SUM(s.amount) AS total,
  SUM(s.amount) / COUNT(DISTINCT c.date) FILTER (c.is_weekday) AS per_business_day
FROM sales s
JOIN calendar.main.mart_calendar c ON s.date = c.date
GROUP BY ALL
ORDER BY c.year, c.month;
```
