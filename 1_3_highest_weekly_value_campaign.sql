/* 1.3 Кампанія з найвищим тижневим доходом (value)

Цей запит:
    1. Обʼєднує дані таблиць google_ads_basic_daily, facebook_ads_basic_daily та facebook_campaign
    2. Визначає дату початку тижня за допомогою DATE_TRUNC
    3. Визначає кампанію із найбільшим доходом за тиждень
*/

SELECT
	date_trunc('week', ad_date)::DATE AS ad_week_start,
	campaign_name,
	sum(value) AS weekly_value
FROM (
	SELECT ad_date, campaign_name, value
	FROM facebook_ads_basic_daily fabd 
	LEFT JOIN facebook_campaign fc ON fabd.campaign_id = fc.campaign_id

	UNION ALL
	
	SELECT ad_date, campaign_name, value
	FROM google_ads_basic_daily

) AS all_ads
GROUP BY campaign_name, date_trunc('week', ad_date)
HAVING campaign_name IS NOT NULL
ORDER BY weekly_value DESC 
LIMIT 1