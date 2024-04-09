with sub_query as (
	select c.id
	, c.currency
	, c.budget
	from campaigns c
	join campaign_publishers cp on 1=1
		and cp."campaignId" = c.id
	where 1=1
		and DATE(c."startDate" at TIME zone 'UTC' at TIME zone 'Australia/Sydney') between '2022-04-01' and '2022-06-30'
	group by 1,2
)
select currency
, TO_CHAR(PERCENTILE_CONT(0.5) within group (order by budget), '9999999999999999D00') as median_budget
from sub_query
group by currency