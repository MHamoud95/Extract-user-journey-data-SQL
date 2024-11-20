SET SESSION group_concat_max_len = 1000000;
#number of vistiors
select count(DISTINCT front_interactions.visitor_id) as vistiors_count from front_interactions;
# number of vistiors who became users
SELECT count(distinct front_visitors.user_id) users_count from front_visitors;
# number of users who made a purchase
select count(distinct student_purchases.user_id) purchase_count from student_purchases;

# condiser all users who purchased a plan for the first time between January 1 and March 31, 2023 (inclusive).
with users_purchases as(
select *, case  when purchase_type = 0 then "monthly"
				when purchase_type = 1 then "quarterly"
                else "annual"
		  end as subscription_type,
		  ROW_NUMBER() over(PARTITION BY user_id order by date_purchased) as purchase_order
from student_purchases
where purchase_price <> 0 #eliminate test users
and date_purchased BETWEEN '2023-01-01' AND '2023-03-31'),

user_first_purchase as(
select  user_id,
		purchase_id,
        subscription_type,
        date_purchased
from users_purchases
where purchase_order = 1),
# join the user_first_purchase cte with the front_visitors table the table should have the same count as the cte (1373) for validation
user_first_purchase_with_visitors_ids as(
select  user_first_purchase.user_id as user_id,
		purchase_id,
        subscription_type,
        date_purchased,
        visitor_id
from user_first_purchase
join front_visitors
on user_first_purchase.user_id = front_visitors.user_id),
paid_users_sessions as(
select user_id, session_id, subscription_type, event_source_url, event_destination_url, event_date, date_purchased
from user_first_purchase_with_visitors_ids
join front_interactions
on front_interactions.visitor_id = user_first_purchase_with_visitors_ids.visitor_id and event_date < date_purchased),
paid_users_sessions_names as(
SELECT user_id,
		session_id,
        subscription_type,
        case when event_source_url = 'https://365datascience.com/' then 'Homepage'
			 when event_source_url like 'https://365datascience.com/login/%' then 'Log in'
			 when event_source_url like 'https://365datascience.com/signup/%' then 'Sign up'
			 when event_source_url like 'https://365datascience.com/resources-center/%' then 'Resources centre'
			 when event_source_url LIKE 'https://365datascience.com/courses/%' then 'Courses'
			 when event_source_url LIKE 'https://365datascience.com/career-tracks/%' then 'Career Tracks'
			 when event_source_url LIKE 'https://365datascience.com/upcoming-courses/%' then 'Upcoming courses'
			 when event_source_url LIKE 'https://365datascience.com/career-track-certificate/%' then 'Career track certificate'
			 when event_source_url LIKE 'https://365datascience.com/course-certificate/%' then 'Course certificate'
			 when event_source_url LIKE 'https://365datascience.com/success-stories/%' then 'Success stories'
			 when event_source_url LIKE 'https://365datascience.com/pricing/%' then 'Pricing'
			 when event_source_url LIKE 'https://365datascience.com/about-us/%' then 'About us'
			 when event_source_url LIKE 'https://365datascience.com/blog/%' then 'Blog'
			 when event_source_url LIKE 'https://365datascience.com/instructors/%' then 'instructors'
			 when event_source_url like '%coupon%' then 'Coupoun'
			 when event_source_url like '%checkout/%' and event_source_url not like '%coupon%' then 'Checkout'
             else 'Other'
		end as event_source_pages,
        case when event_destination_url = 'https://365datascience.com/' then 'Homepage'
			 when event_destination_url like 'https://365datascience.com/login/%' then 'Log in'
			 when event_destination_url like 'https://365datascience.com/signup/%' then 'Sign up'
			 when event_destination_url like 'https://365datascience.com/resources-center/%' then 'Resources centre'
			 when event_destination_url like 'https://365datascience.com/courses/%' then 'Courses'
			 when event_destination_url like 'https://365datascience.com/career-tracks/%' then 'Career Tracks'
			 when event_destination_url like 'https://365datascience.com/upcoming-courses/%' then 'Upcoming courses'
			 when event_destination_url like 'https://365datascience.com/career-track-certificate/%' then 'Career track certificate'
			 when event_destination_url like 'https://365datascience.com/course-certificate/%' then 'Course certificate'
			 when event_destination_url like 'https://365datascience.com/success-stories/%' then 'Success stories'
			 when event_destination_url like 'https://365datascience.com/pricing/%' then 'Pricing'
			 when event_destination_url like 'https://365datascience.com/about-us/%' then 'About us'
			 when event_destination_url like 'https://365datascience.com/blog/%' then 'Blog'
			 when event_destination_url like 'https://365datascience.com/instructors/%' then 'instructors'
			 when event_destination_url like '%coupon%' then 'Coupoun'
			 when event_destination_url like '%checkout/%' and event_destination_url not like '%coupon%' then 'Checkout'
             else 'Other'
		end as event_destination_page,
        event_date,
        date_purchased
from paid_users_sessions),
paid_users_journey as(
select user_id, session_id, subscription_type,concat(event_source_pages, '-',event_destination_page) as user_journey
from paid_users_sessions_names)
select user_id, session_id, subscription_type, group_concat(user_journey) as user_journey
from paid_users_journey
group by 1,2,3
order by 1,2;










