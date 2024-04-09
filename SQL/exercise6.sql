with publishers as (
	select profile->'country' as country
	, id
	from accounts a
	where 1=1
		and type =2
	group by 1,2
)
, invited_to_campaign as (
	select country
	, COUNT(DISTINCT key) AS publishers
	from (
    	select key, value
    from campaigns, jsonb_each(campaigns."directBrands") AS j
    where 1=1
       and jsonb_exists(value, 'invitedAt')
	) as filtered_data
	left join publishers p on 1=1
		and cast(p.id as int) = cast(key as int)
	group by 1
)
, accepting_advertiser_campaign as (
	select country
	, COUNT(distinct key) as publishers
	from (
    	select key, value
    from campaigns, jsonb_each(campaigns."directBrands") AS j
    where 1=1
       and jsonb_exists(value, 'acceptedAt')
	) as filtered_data
	left join publishers p on 1=1
		and cast(p.id as int) = cast(key as int)
	group by 1
)
, article_published as (
	select country
		, COUNT(distinct "publisherId") as publishers
	from campaign_publishers cp 
	left join publishers p on 1=1
		and cp."publisherId" = p.id
	where 1=1
		and cp."storyAt" is not null
	group by 1
) 
select p.country
, COUNT(p.id) as total_publishers
, i.publishers as publishers_invited
, a.publishers as publishers_accepted
, published.publishers as publishers_published
from publishers p
left join accepting_advertiser_campaign a on p.country = a.country
left join invited_to_campaign i on p.country = i.country
left join article_published published on p.country = published.country
group by 1,3,4,5