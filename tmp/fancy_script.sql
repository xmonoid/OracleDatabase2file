/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  Косых Евгений
 * Created: 29.12.2015
 */

select /*+ RULE */ 'г. Липецк ; '              as city, --  */ ;+ && ''' """
       /*
        * &  -- ' "
        */
       acct.acct_id             as ls,
       acct.setup_dt            as create_dt,
       acct.cis_division        as company,
       '&& """"; '              as "This is; -- &alias"
  from stgadm.ci_acct  acct
 where setup_dt < &pdat
   and &r_on = '320008'
   and rownum <= 50;
select sysdate
  from dual;