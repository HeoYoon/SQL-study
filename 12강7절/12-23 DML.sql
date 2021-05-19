�ڵ� 12-23 /*�湮 �󵵸� ������� ����� �Ӽ��� �����ϰ� �����ϱ�

* �湮�󵵿� ���� ����ڸ� �з��ϰ� ������ �����ϴ� ���
* 
**/


# MAU = Ư�� ���� ���񽺸� ����� ����� �� (Monthly Active Users)
 ���� ������� ������ �� �ڼ��ϰ� �ľ��Ϸ��� MAU�� 3���� �Ӽ����� ������ �м��ؾ���.
 
 1.�ű� ����� : �� �޿� ����� �ű� �����
 2.����Ʈ ����� : ���� �޿��� ����ߴ� �����
 3.�Ĺ� ����� : �̹� ���� �ű� ����ڰ� �ƴϰ�, ���� �޿��� ������� �ʾҴ� , �ѵ��� ������� �ʾҴ� �޸�����
 
 
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
  ) ,monthly_user_with_type AS(
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
  
  select action_month
  , Count(user_id) as mau
  , COUNT(case when c = 'new user' then 1 end) as new_users
  , COUNT(case when c = 'repeat_user' then 1 end) as repeat_user
  , COUNT(case when c = 'comback_user' then 1 end) as comback_user
  from monthly_user_with_type
  group by action_month 
  order by action_month
  
  
  
  
  
  