with us_and_gb_publisher as (
	select id, name
	from accounts
	where 1=1
		and type =2
		and profile->'country' in ('"US"', '"GB"')
)
, clicklogs as (
	select id
	, "publisherId" as publisher_id
	, case when currency = 'USD' then cpc*1.34
		   when currency = 'GBP' then cpc*1.86
		   when currency = 'SGD' then cpc*1.08
		   when currency = 'CAD' then cpc*1.12
		   else cpc
	end as cpc
	from campaign_clicklogs cc
	where 1=1
		and context->'ctx'->>'mode' = 'hash'
		and EXTRACT(year from DATE(cc."createdAt" at TIME zone 'UTC' at TIME zone 'Australia/Sydney')) = 2021
		and EXTRACT(month from DATE(cc."createdAt" at TIME zone 'UTC' at TIME zone 'Australia/Sydney')) =12
)
select pb.id
, pb.name
, coalesce(ROUND(SUM(cpc),2),0) as revenue
from us_and_gb_publisher pb
left join clicklogs cl on 1=1
	and pb.id = cl.publisher_id
group by 1,2