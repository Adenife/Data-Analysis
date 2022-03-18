-- You show up to work Tuesday morning, September 2, 2014. The head of the Product team walks over to your desk and asks you what you think about the latest activity on the user engagement dashboards. You are responsible for determining what caused the dip at the end of the chart shown above and, if appropriate, recommending solutions for the problem.



-- 1. See weekly engagement by users of the system

SELECT DATE_TRUNC('week', event.occurred_at),
      COUNT(DISTINCT event.user_id) AS weekly_active_users
FROM tutorial.yammer_events AS event
WHERE event.event_type = 'engagement'
AND event.event_name = 'login'
GROUP BY 1


-- 2. check the number of new users and activated users per day

SELECT DATE_TRUNC('day',created_at) AS day,
      COUNT(created_at) AS all_users,
      COUNT(CASE WHEN activated_at IS NOT NULL THEN users.user_id ELSE NULL END) AS activated_users
  FROM tutorial.yammer_users AS users
GROUP BY 1


-- 3. Check how long it takes for user activity to drop from activated time

SELECT DATE_TRUNC('week',extract.occurred_at) AS "week",
      AVG(extract.age_at_event) AS "Average age during week",
      COUNT(DISTINCT CASE WHEN extract.user_age > 70 THEN extract.user_id ELSE NULL END) AS "10+ weeks",
      COUNT(DISTINCT CASE WHEN extract.user_age < 70 AND extract.user_age >= 63 THEN extract.user_id ELSE NULL END) AS "9 weeks",
      COUNT(DISTINCT CASE WHEN extract.user_age < 63 AND extract.user_age >= 56 THEN extract.user_id ELSE NULL END) AS "8 weeks",
      COUNT(DISTINCT CASE WHEN extract.user_age < 56 AND extract.user_age >= 49 THEN extract.user_id ELSE NULL END) AS "7 weeks",
      COUNT(DISTINCT CASE WHEN extract.user_age < 49 AND extract.user_age >= 42 THEN extract.user_id ELSE NULL END) AS "6 weeks",
      COUNT(DISTINCT CASE WHEN extract.user_age < 42 AND extract.user_age >= 35 THEN extract.user_id ELSE NULL END) AS "5 weeks",
      COUNT(DISTINCT CASE WHEN extract.user_age < 35 AND extract.user_age >= 28 THEN extract.user_id ELSE NULL END) AS "4 weeks",
      COUNT(DISTINCT CASE WHEN extract.user_age < 28 AND extract.user_age >= 21 THEN extract.user_id ELSE NULL END) AS "3 weeks",
      COUNT(DISTINCT CASE WHEN extract.user_age < 21 AND extract.user_age >= 14 THEN extract.user_id ELSE NULL END) AS "2 weeks",
      COUNT(DISTINCT CASE WHEN extract.user_age < 14 AND extract.user_age >= 7 THEN extract.user_id ELSE NULL END) AS "1 week",
      COUNT(DISTINCT CASE WHEN extract.user_age < 7 THEN extract.user_id ELSE NULL END) AS "Less than a week"
  FROM (
        SELECT event.occurred_at,
              users.user_id,
              DATE_TRUNC('week',users.activated_at) AS activation_week,
              EXTRACT('day' FROM event.occurred_at - users.activated_at) AS age_at_event,
              EXTRACT('day' FROM '2014-09-01'::TIMESTAMP - users.activated_at) AS user_age
          FROM tutorial.yammer_users users
          JOIN tutorial.yammer_events event
            ON event.user_id = users.user_id
          AND event.event_type = 'engagement'
          AND event.event_name = 'login'
          AND event.occurred_at >= '2014-05-01'
          AND event.occurred_at < '2014-09-01'
        WHERE users.activated_at IS NOT NULL
      ) extract
GROUP BY 1


-- 4. check user engagement by device used to see if drop is peculiar to device

SELECT DATE_TRUNC('week', occurred_at) AS week,
       COUNT(DISTINCT event.user_id) AS weekly_active_users,
       COUNT(DISTINCT CASE WHEN event.device IN ('macbook pro','lenovo thinkpad','macbook air','dell inspiron notebook',
          'asus chromebook','dell inspiron desktop','acer aspire notebook','hp pavilion desktop','acer aspire desktop','mac mini')
          THEN event.user_id ELSE NULL END) AS computer,
       COUNT(DISTINCT CASE WHEN event.device IN ('iphone 5','samsung galaxy s4','nexus 5','iphone 5s','iphone 4s','nokia lumia 635',
       'htc one','samsung galaxy note','amazon fire phone') THEN event.user_id ELSE NULL END) AS phone,
        COUNT(DISTINCT CASE WHEN event.device IN ('ipad air','nexus 7','ipad mini','nexus 10','kindle fire','windows surface',
        'samsumg galaxy tablet') THEN event.user_id ELSE NULL END) AS tablet
  FROM tutorial.yammer_events AS event
 WHERE event.event_type = 'engagement'
   AND event.event_name = 'login'
 GROUP BY 1
 
 
 -- 5 check the digest email to see if engagement with mail is normal
 
 SELECT DATE_TRUNC('week', occurred_at) AS week,
       COUNT(CASE WHEN emails.action = 'sent_weekly_digest' THEN emails.user_id ELSE NULL END) AS weekly_emails,
       COUNT(CASE WHEN emails.action = 'sent_reengagement_email' THEN emails.user_id ELSE NULL END) AS reengagement_emails,
       COUNT(CASE WHEN emails.action = 'email_open' THEN emails.user_id ELSE NULL END) AS email_opens,
       COUNT(CASE WHEN emails.action = 'email_clickthrough' THEN emails.user_id ELSE NULL END) AS email_clickthroughs
  FROM tutorial.yammer_emails emails
 GROUP BY 1