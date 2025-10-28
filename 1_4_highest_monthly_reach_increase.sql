/* 1.4 Кампанія з найбільшим приростом охоплень (reach)

Цей запит:
    1. Обʼєднує дані таблиць google_ads_basic_daily, facebook_ads_basic_daily та facebook_campaign
    2. Визначає дату початку місяця за допомогою DATE_TRUNC
    3. Визначає reach за попередній місяць
    4. Відбирає кампанію, що має найбільший приріст, порівняно з минулим місяцем
 */

WITH ads_combine AS (
	SELECT ad_date, 'facebook' AS media_source, fc.campaign_name, reach
	FROM facebook_ads_basic_daily fabd LEFT JOIN facebook_campaign fc ON fabd.campaign_id = fc.campaign_id
    UNION ALL
	SELECT ad_date, 'google' AS media_source, campaign_name, reach
	FROM google_ads_basic_daily
),

month_ads AS (
	SELECT 
		DATE_TRUNC('month', ad_date)::date AS ad_month,
		media_source,
		campaign_name,
		SUM(reach) AS total_reach
	FROM ads_combine
	GROUP BY 1, 2, 3
),

reach_growth AS (
	SELECT 
		ad_month,
		media_source,
		campaign_name,
		total_reach,
		LAG(total_reach) OVER (PARTITION BY campaign_name ORDER BY ad_month) AS reach_prev
	FROM month_ads
)

SELECT 	
	ad_month,
	media_source,
	campaign_name,
	total_reach - reach_prev AS reach_growth
FROM reach_growth
WHERE reach_prev IS NOT NULL
ORDER BY reach_growth DESC
LIMIT 1;
