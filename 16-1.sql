/* �ڷ� û�� ��İ� ���� ��� ���� ��Ʈ�� ���̶�� �θ���.
 * 
 * �Է¾���� �׸��� �ʹ������� ����ڰ� ��Ʈ������ �ްԵǰ� �߰��� ��Ż�� Ȯ���� ����.
 * �̷��� ��Ż�� ���� ������ ���̰��� �Է� ����� ����ȭ �ϴ°��� �Է� ��� ����ȭ ( Entry Form Optimization) EFO ��� �θ���.
 * 
 * 
 * 1. �ʼ��Է°� ���� �Է��� ��Ȯ�ϰ� �����ؼ� �Է� ���� ���δ�.
 * 2. ���� �߻� �󵵸� ���δ�. (�Է¿��� �����ش� , ����� �Է������ʾҴٰ� �ǽð����� �˷��ش�.)
 * 3. ���� �Է��� �� �ְ� �����. (�Է��׸����̱� , �����ȣ,�ּ� �ڵ��ϼ���� �̿�)
 * 4. ��Ż�� ���� ��Ҹ� ���� (���ʿ��� ��ũ ���� , �Ǽ���Ż������ Ȯ��â)
 */
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


/* #������ �����ϱ�*/
/*confirm ���������� ������ �߻��ؼ� ���Է� ȭ���� ����� ��츦 �����ϴ� ����.*/
 select COUNT(*) as confirm_count
      , SUM(case when status = 'error' then 1 else 0 END) as ERROR_COUNT
      , ROUND(AVG(case when STATUS = 'error' then 1.0 else 0.0 end),1) * 100 as error_rate
      , ROUND(SUM(case when status = 'error' then 1.0 else 0.0 END) / COUNT(distinct session),1) as error_per_user
      from form_log
      where path = '/regist/confirm';