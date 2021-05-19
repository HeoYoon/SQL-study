
/*
 *  ����Ʈ ����ڸ� 3������ �з��ϱ�
 *  ����Ʈ ����ڴ� ���� �޿��� ����� ����ڶ�� �����մϴ�. 
 *  �׷��� ���� ���� ����� ���¿� ���� �߰��� ����Ʈ ����ڸ� ���� 3������ �з��� �� �ֽ��ϴ�.
 *  
 *  1.�ű� ����Ʈ ����� : ���� �޿��� �ű� ����ڷ� �з��Ǿ�����, �̹� �޿��� ����� �����
 *  2.���� ����Ʈ ����� : ���� �޵� ����Ʈ ����ڷ� �з��Ǿ�����, �̹� �޿��� ����� �����
 *  3.�Ĺ� ����Ʈ ����� : ���� �޿� �Ĺ� ����ڷ� �з��Ǿ�����, �̹� �޿��� ����� �����
 * 
 * */

�ڵ� 12-24 ����Ʈ ����ڸ� ����ȭ�ؼ� �����ϴ� ����

 with monthly_user_action as (
   --���� ����� �׼� �����ϱ�
    select distinct 
    u.user_id
    , substring(u.register_date , 1, 7) as register_month
    , substring(l.stamp , 1, 7) as action_month
    , substring(cast(l.stamp::date - interval '1 month' as text) , 1, 7) as ACTION_MONTH_PRIV 
  
  from mst_users as U
  inner join action_log as L
  on U.user_id = L.user_id 
  ) 
  , monthly_user_with_type AS(
  								select action_month
							  	     , user_id
							  	     , case when register_month = action_month 
							  	     			then 'new_user'
							  	     		when action_month_priv = LAG(action_month) OVER(partition by user_id order by action_month)
							  	     			then 'repeat_user'
							  	     			else 'comback_user'
							  	     			end as c  						
							  	     , action_month_priv
							  	    
							  	    from monthly_user_action
  )
  , monthly_users as (select M1.action_month
  							,count(m1.user_id) as mau
  							,count(case when m1.c = 'new_user' then 1 end) as new_users
  							,count(case when m1.c = 'repeat_user' then 1 end) as repeat_users
  							,count(case when m1.c = 'comback_user' then 1 end) as comback_users
  							
  							, count( case when m1.c = 'repeat_user' and m0.c = 'new_user' then 1 end) as new_repeat_users
  							, count( case when m1.c = 'repeat_user' and m0.c = 'repeat_user' then 1 end) as continuous_repeat_users
  							, count( case when m1.c = 'repeat_user' and m0.c = 'comback_user' then 1 end) as come_back_repeat_users
  							
  						from monthly_user_with_type as m1
  						left outer join monthly_user_with_type as m0
  						on m1.user_id = m0.user_id
  						and m1.action_month_priv = m0.action_month
  						group by m1.action_month
  						)
  						
  						
  						select * from monthly_users
  						order by action_month;
  							
  							
  							
  
  )
  
  					