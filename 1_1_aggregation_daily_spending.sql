/* 1.1 Агрегація показників та аналіз їх динаміки (витрати на рекламу для Google та Facebook)

Цей запит:
    1. Обʼєднує дані таблиць google_ads_basic_daily та facebook_ads_basic_daily
    2. Обчислює агреговані показники (середнє, максимум та мінімум) для витрат на рекламу окремо на кожну дату і по платформам
*/

WITH all_ads AS (
	SELECT ad_date, 'google ads' AS media_source, spend
	FROM google_ads_basic_daily
	
UNION ALL

	SELECT ad_date, 'facebook ads' AS media_sourse, spend
	FROM facebook_ads_basic_daily
)
SELECT
	ad_date,
	media_source,
	ROUND(AVG(spend),2) AS spend_avg,
	ROUND(MAX(spend), 2) AS spend_max,
	ROUND(MIN(spend), 2) AS spend_min
FROM all_ads
GROUP BY ad_date, media_source
ORDER BY ad_date, media_source;
