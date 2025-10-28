/* 1.2 Розрахунок ROMI та пошук топ-5 днів з найбільшим ROMI

Цей запит:
    1. Обʼєднує дані таблиць google_ads_basic_daily та facebook_ads_basic_daily
    2. Обчислює ROMI для кожної дати по обом платформам
    3. Відбирає топ 5 днів з найбільшим ROMI
*/

SELECT
	ad_date,
	concat(round((SUM(value)::NUMERIC - SUM(spend)::NUMERIC) / nullif(SUM(spend), 0) * 100, 2), '%') AS ROMI
FROM (
	SELECT ad_date, spend, value
	FROM google_ads_basic_daily
	
UNION ALL

	SELECT ad_date, spend, value
	FROM facebook_ads_basic_daily
) AS all_ads
GROUP BY ad_date
HAVING sum(spend) <> 0
ORDER BY round((SUM(value)::NUMERIC - SUM(spend)::NUMERIC) / nullif(SUM(spend), 0) * 100, 2) DESC
LIMIT 5