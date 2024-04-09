with click_incurred as (
select EXTRACT(month from DATE(cc."createdAt" at TIME zone 'UTC' at TIME zone 'Australia/Sydney')) as click_month
, cc."campaignId" as campaign_id
, COUNT(cc.*) as clicks
from campaign_clicklogs cc
where 1=1
	and EXTRACT(year from DATE(cc."createdAt" at TIME zone 'UTC' at TIME zone 'Australia/Sydney')) = 2022
	and EXTRACT(month from DATE(cc."createdAt" at TIME zone 'UTC' at TIME zone 'Australia/Sydney')) < 7
group by 1,2
)
, active_campaigns as (
select EXTRACT(month from DATE(c."createdAt" at TIME zone 'UTC' at TIME zone 'Australia/Sydney')) as created_month
	, c.id
	, "accountId" as advertiser_id
from campaigns c
join accounts a on 1=1
	and a.id = c."accountId"
	and a.type = 1
where 1=1
	and c.status not in (0,1)
	and EXTRACT(year from DATE(c."createdAt" at TIME zone 'UTC' at TIME zone 'Australia/Sydney')) = 2022
	and EXTRACT(month from DATE(c."createdAt" at TIME zone 'UTC' at TIME zone 'Australia/Sydney')) < 7
)
select case when ac.created_month = 1 then 'Jan'
			when ac.created_month = 2 then 'Feb'
			when ac.created_month = 3 then 'Mar'
			when ac.created_month = 4 then 'Apr'
			when ac.created_month = 5 then 'May'
			when ac.created_month = 6 then 'Jun'
			else null
		end as month
, COUNT(distinct advertiser_id) as active_advertiser
from active_campaigns ac
join click_incurred ci on 1=1
	and ci.click_month = ac.created_month
	and ci.campaign_id = ac.id
group by created_month
order by created_month ASC