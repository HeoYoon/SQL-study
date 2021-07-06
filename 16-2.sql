/*#입력~확인~완료 까지의 이동률 집계하기*/

/*sample ddl*/
DROP TABLE IF EXISTS form_log;
CREATE TABLE form_log(
    stamp    varchar(255)
  , session  varchar(255)
  , action   varchar(255)
  , path     varchar(255)
  , status   varchar(255)
);

INSERT INTO form_log
VALUES
    ('2016-12-30 00:56:08', '647219c7', 'view', '/regist/input'    , ''     )
  , ('2016-12-30 00:56:08', '9b5f320f', 'view', '/cart/input'      , ''     )
  , ('2016-12-30 00:57:04', '9b5f320f', 'view', '/regist/confirm'  , 'error')
  , ('2016-12-30 00:57:56', '9b5f320f', 'view', '/regist/confirm'  , 'error')
  , ('2016-12-30 00:58:50', '9b5f320f', 'view', '/regist/confirm'  , 'error')
  , ('2016-12-30 01:00:19', '9b5f320f', 'view', '/regist/confirm'  , 'error')
  , ('2016-12-30 00:56:08', '8e9afadc', 'view', '/contact/input'   , ''     )
  , ('2016-12-30 00:56:08', '46b4c72c', 'view', '/regist/input'    , ''     )
  , ('2016-12-30 00:57:31', '46b4c72c', 'view', '/regist/confirm'  , ''     )
  , ('2016-12-30 00:56:08', '539eb753', 'view', '/contact/input'   , ''     )
  , ('2016-12-30 00:56:08', '42532886', 'view', '/contact/input'   , ''     )
  , ('2016-12-30 00:56:08', 'b2dbcc54', 'view', '/contact/input'   , ''     )
  , ('2016-12-30 00:57:48', 'b2dbcc54', 'view', '/contact/confirm' , 'error')
  , ('2016-12-30 00:58:58', 'b2dbcc54', 'view', '/contact/confirm' , ''     )
  , ('2016-12-30 01:00:06', 'b2dbcc54', 'view', '/contact/complete', ''     )
;



with
mst_fallout_step as (
	select 1 as step, '/regist/input' as path
	 union all select 2 as step, '/regist/confirm' as path
	 union all select 3 as step, '/regist/complete' as path

), form_log_with_fallout_step as (

	select l.session
	    , m.step
	    , m.path
	    , max(l.stamp) as max_stamp
	    , min(l.stamp) as min_stamp
	 from mst_fallout_step m
	 inner join form_log as l  
	 on m.path = l.path
	 where status = ''
	 group by l.session , m.step , m.path
), form_log_with_mod_fallout_step as (

	select session
		 , step
		 , path
		 , max_stamp
		 , lag(min_stamp) over (partition by session order by step) as lag_min_stamp
		 , min(step) over(partition by session ) as min_step
		 , count(1) over (partition by session order by step rows between unbounded preceding and current row) as cum_count
		 from form_log_with_fallout_step
), fallout_log as (
	select session
	    , step
	    , path 
	    from form_log_with_mod_fallout_step
	    where min_step = 1
	    and step = cum_count 
	    and (lag_min_stamp is null or max_stamp >= lag_min_stamp)
)


select step
     , path
     , count(1) as count
     , 100.0 * count(1) / first_value (count(1)) over(order by step asc rows between unbounded preceding and unbounded following) as first_trans_rate
     , 100.0 * count(1) / lag(count(1)) over(order by step asc) as step_trans_rate
     from fallout_log
     group by step , path 
     order by step


		 
		 



