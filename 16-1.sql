/* 자료 청구 양식과 구매 양식 등을 엔트리 폼이라고 부른다.
 * 
 * 입력양식의 항목이 너무많으면 사용자가 스트레스를 받게되고 중간에 이탈할 확률이 높다.
 * 이러한 이탈을 막고 성과를 높이고자 입력 양식을 최적화 하는것을 입력 양식 최적화 ( Entry Form Optimization) EFO 라고 부른다.
 * 
 * 
 * 1. 필수입력과 선택 입력을 명확하게 구분해서 입력 수를 줄인다.
 * 2. 오류 발생 빈도를 줄인다. (입력예를 보여준다 , 제대로 입력하지않았다고 실시간으로 알려준다.)
 * 3. 쉽게 입력할 수 있게 만든다. (입력항목줄이기 , 우편번호,주소 자동완성기능 이용)
 * 4. 이탈할 만한 요소를 제거 (불필요한 링크 제거 , 실수이탈방지용 확인창)
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


/* #오류율 집계하기*/
/*confirm 페이지에서 오류가 발생해서 재입력 화면을 출력한 경우를 집계하는 쿼리.*/
 select COUNT(*) as confirm_count
      , SUM(case when status = 'error' then 1 else 0 END) as ERROR_COUNT
      , ROUND(AVG(case when STATUS = 'error' then 1.0 else 0.0 end),1) * 100 as error_rate
      , ROUND(SUM(case when status = 'error' then 1.0 else 0.0 END) / COUNT(distinct session),1) as error_per_user
      from form_log
      where path = '/regist/confirm';