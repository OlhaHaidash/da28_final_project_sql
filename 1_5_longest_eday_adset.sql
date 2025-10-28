/* 1.5 Найдовший безперервний показ реклами (adset)

Цей запит:
1. Обʼєднує дані таблиць google_ads_basic_daily, facebook_ads_basic_daily та facebook_adset
2. Відбирає унікальні комбінації назв adset та дат показу (ad_date)
3. Для кожного adset обчислює дату попереднього показу за допомогою LAG
4. Визначає групи безперервних показів — якщо між поточним і попереднім днем різниця > 1 день або попередня дата відсутня, починається нова група
5. Для кожної групи визначає початок, кінець і тривалість безперервного показу
6. Вибирає adset із найдовшим безперервним періодом показу реклами

*/

WITH combined AS (
  SELECT DISTINCT fadb.ad_date::date AS ad_date, fa.adset_name
  FROM facebook_ads_basic_daily AS fadb
  JOIN facebook_adset AS fa ON fadb.adset_id = fa.adset_id
  WHERE fa.adset_name IS NOT NULL

  UNION ALL

  SELECT DISTINCT ad_date::date, adset_name
  FROM google_ads_basic_daily
  WHERE adset_name IS NOT NULL
),

with_lag AS (
  SELECT
    adset_name,
    ad_date,
    LAG(ad_date) OVER (PARTITION BY adset_name ORDER BY ad_date) AS prev_ad_date
  FROM combined
),

groups AS (
  SELECT
    adset_name,
    ad_date,
    SUM(
      CASE WHEN prev_ad_date IS NULL OR (ad_date - prev_ad_date) > 1 THEN 1 ELSE 0 END
    ) OVER (PARTITION BY adset_name ORDER BY ad_date) AS grp
  FROM with_lag
),

sequences AS (
  SELECT
    adset_name,
    grp,
    MIN(ad_date) AS start_date,
    MAX(ad_date) AS end_date,
    (MAX(ad_date) - MIN(ad_date) + 1) AS duration
  FROM groups
  GROUP BY adset_name, grp
)

  SELECT adset_name, duration
  FROM sequences
  ORDER BY duration DESC
  LIMIT 1