SET SESSION group_concat_max_len = 1000000;
-- Consider all users who purchased a plan for the first time between January 1 and March 31, 2023 (inclusive).
WITH users_purchases AS (
    SELECT *,
        CASE
            WHEN purchase_type = 0 THEN 'monthly'
            WHEN purchase_type = 1 THEN 'quarterly'
            ELSE 'annual'
        END AS subscription_type,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY date_purchased) AS purchase_order
    FROM student_purchases
    WHERE purchase_price <> 0 -- eliminate test users
    AND date_purchased BETWEEN '2023-01-01' AND '2023-03-31'
),
user_first_purchase AS (
    SELECT user_id,
        purchase_id,
        subscription_type,
        date_purchased
    FROM users_purchases
    WHERE purchase_order = 1
),
-- Join the user_first_purchase CTE with the front_visitors table
user_first_purchase_with_visitors_ids AS (
    SELECT user_first_purchase.user_id AS user_id,
        purchase_id,
        subscription_type,
        date_purchased,
        visitor_id
    FROM user_first_purchase
    JOIN front_visitors
        ON user_first_purchase.user_id = front_visitors.user_id
),
paid_users_sessions AS (
    SELECT user_id,
        session_id,
        subscription_type,
        event_source_url,
        event_destination_url,
        event_date,
        date_purchased
    FROM user_first_purchase_with_visitors_ids
    JOIN front_interactions
        ON front_interactions.visitor_id = user_first_purchase_with_visitors_ids.visitor_id
        AND event_date < date_purchased
),
paid_users_sessions_names AS (
    SELECT user_id,
        session_id,
        subscription_type,
        CASE
            WHEN event_source_url = 'https://365datascience.com/' THEN 'Homepage'
            WHEN event_source_url LIKE 'https://365datascience.com/login/%' THEN 'Log in'
            WHEN event_source_url LIKE 'https://365datascience.com/signup/%' THEN 'Sign up'
            WHEN event_source_url LIKE 'https://365datascience.com/resources-center/%' THEN 'Resources centre'
            WHEN event_source_url LIKE 'https://365datascience.com/courses/%' THEN 'Courses'
            WHEN event_source_url LIKE 'https://365datascience.com/career-tracks/%' THEN 'Career Tracks'
            WHEN event_source_url LIKE 'https://365datascience.com/upcoming-courses/%' THEN 'Upcoming courses'
            WHEN event_source_url LIKE 'https://365datascience.com/career-track-certificate/%' THEN 'Career track certificate'
            WHEN event_source_url LIKE 'https://365datascience.com/course-certificate/%' THEN 'Course certificate'
            WHEN event_source_url LIKE 'https://365datascience.com/success-stories/%' THEN 'Success stories'
            WHEN event_source_url LIKE 'https://365datascience.com/pricing/%' THEN 'Pricing'
            WHEN event_source_url LIKE 'https://365datascience.com/about-us/%' THEN 'About us'
            WHEN event_source_url LIKE 'https://365datascience.com/blog/%' THEN 'Blog'
            WHEN event_source_url LIKE 'https://365datascience.com/instructors/%' THEN 'Instructors'
            WHEN event_source_url LIKE '%coupon%' THEN 'Coupon'
            WHEN event_source_url LIKE '%checkout/%' AND event_source_url NOT LIKE '%coupon%' THEN 'Checkout'
            ELSE 'Other'
        END AS event_source_pages,
        CASE
            WHEN event_destination_url = 'https://365datascience.com/' THEN 'Homepage'
            WHEN event_destination_url LIKE 'https://365datascience.com/login/%' THEN 'Log in'
            WHEN event_destination_url LIKE 'https://365datascience.com/signup/%' THEN 'Sign up'
            WHEN event_destination_url LIKE 'https://365datascience.com/resources-center/%' THEN 'Resources centre'
            WHEN event_destination_url LIKE 'https://365datascience.com/courses/%' THEN 'Courses'
            WHEN event_destination_url LIKE 'https://365datascience.com/career-tracks/%' THEN 'Career Tracks'
            WHEN event_destination_url LIKE 'https://365datascience.com/upcoming-courses/%' THEN 'Upcoming courses'
            WHEN event_destination_url LIKE 'https://365datascience.com/career-track-certificate/%' THEN 'Career track certificate'
            WHEN event_destination_url LIKE 'https://365datascience.com/course-certificate/%' THEN 'Course certificate'
            WHEN event_destination_url LIKE 'https://365datascience.com/success-stories/%' THEN 'Success stories'
            WHEN event_destination_url LIKE 'https://365datascience.com/pricing/%' THEN 'Pricing'
            WHEN event_destination_url LIKE 'https://365datascience.com/about-us/%' THEN 'About us'
            WHEN event_destination_url LIKE 'https://365datascience.com/blog/%' THEN 'Blog'
            WHEN event_destination_url LIKE 'https://365datascience.com/instructors/%' THEN 'Instructors'
            WHEN event_destination_url LIKE '%coupon%' THEN 'Coupon'
            WHEN event_destination_url LIKE '%checkout/%' AND event_destination_url NOT LIKE '%coupon%' THEN 'Checkout'
            ELSE 'Other'
        END AS event_destination_page,
        event_date,
        date_purchased
    FROM paid_users_sessions
),
paid_users_journey AS (
    SELECT user_id,
        session_id,
        subscription_type,
        CONCAT(event_source_pages, '-', event_destination_page) AS user_journey
    FROM paid_users_sessions_names
)
SELECT user_id,
    session_id,
    subscription_type,
    GROUP_CONCAT(user_journey) AS user_journey
FROM paid_users_journey
GROUP BY 1, 2, 3
ORDER BY 1, 2;
