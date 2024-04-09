with accepted_campaign_count as (
	select "brandId" as brand_id
	, COUNT(*) as accepted_campaigns
	from campaign_publishers
	group by 1
)
, campaigns_pitched as (
	select json_object_keys("directBrands"::json) as brand_id
	, COUNT(*) as pitched_campaigns
	from campaigns
	group by 1
)
select pb.id, pb.name, coalesce(ROUND((acc.accepted_campaigns::float/cp.pitched_campaigns)::numeric,2),0) as acceptance_rate
from publisher_brands pb
left join  campaigns_pitched cp on 1=1
	and cast(cp.brand_id as int)= pb.id
left join accepted_campaign_count acc on 1=1
	and acc.brand_id = pb.id
order by acceptance_rate desc