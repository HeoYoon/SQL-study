-- 코드 12-25 MAU 내역과 MAU 속성들의 반복률을 계산하는 쿼리

with monthly_user_action as (

	select distinct 
	       U.USER_ID
	       , substring(u.register_date , 1, 7) as register_month
	       , substring(l.stamp , 1, 7) as action_month
	       , substring(cast(l.stamp::date - interval '1 month' as text), 1, 7) as action_month_priv
	       
	       from mst_users as u
	       inner join action_log as l
	       on u.user_id = l.user_id
),
monthly_user_with_type as (

	select action_month
		  , user_id
		  , case when register_month = action_month then 'new_user'
		  		   when action_month_priv = LAG(action_month_priv) over(partition by user_id order by action_month) then 'repeat_user'
		  		   else 'comeback_user'
		  		   end as c
		  , action_month_priv
		  
		  from monthly_user_action
),

monthly_users as (
	select m1.action_month
	 	  , COUNT(m1.user_id) as mau
	 	  , count(case when m1.c = 'new_user' then 1 end) as new_users
	 	  , count(case when m1.c = 'repeat_user' then 1 end) as repeat_users
	 	  , count(case when m1.c = 'comeback_user' then 1 end) as comeback_users
	 	  , count(case when m1.c = 'repeat_user' and m0.c = 'new_user' then 1 end ) as new_repeat_users
	 	  , count(case when m1.c = 'repeat_user' and m0.c = 'repeat_user' then 1 end) as continuous_repeat_users
	 	  , count(case when m1.c = 'repeat_user' and m0.c = 'comeback_user' then 1 end ) as comeback_repeat_users
	 	  
	 	  from monthly_user_with_type as m1
	 	  left outer join 
	 	  monthly_user_with_type as m0
	 	  on m1.user_id = m0.user_id
	 	  and m1.action_month_priv = m0.action_month
	 	  group by m1.action_month
	 	  )
	 	  
	 	  
	 	  select action_month 
	 	  		, mau
	 	  		, new_users
	 	  		, repeat_users
	 	  		, comeback_users
	 	  		, new_repeat_users
	 	  		, continuous_repeat_users
	 	  		, comeback_repeat_users
	 	  		, 100.0 * new_repeat_users / nullif (lag(new_users) over(order by action_month) ,0) as priv_new_repeat_ratio
	 	  		, 100.0 * continuous_repeat_users / nullif (lag(repeat_users) over(order by action_month) ,0) as priv_contiuous_repeat_users
	 	  		, 100.0 * continuous_repeat_users / nullif (lag(comeback_repeat_users) over(order by action_month) ,0) as priv_comeback_repeat_ratio
	 	  		
	 	  from monthly_users
	 	  order by action_month;




