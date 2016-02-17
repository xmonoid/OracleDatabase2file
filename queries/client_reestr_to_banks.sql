select (select ac.adhoc_char_val
          from rusadm.ci_acct_char ac
         where a.acct_id = ac.acct_id
               and ac.char_type_cd = 'LKKLOGIN'
               and ac.effdt =
               (select max(ac2.effdt)
                      from rusadm.ci_acct_char ac2
                     where ac2.acct_id = ac.acct_id
                           and ac2.char_type_cd = ac.char_type_cd)) numb,
        pr.postal ind,
        pr.state reg,
        (select sl.descr from rusadm.ci_state_l sl where sl.state=pr.state and sl.language_cd='RUS') distr,
        pr.city loc,
        pr.address3 str,
        pr.address2 house,
        pr.address4 apart                                                   

  from rusadm.ci_per      p,
       rusadm.ci_acct_per ap,
       rusadm.ci_acct     a,
       rusadm.ci_prem     pr
 where ap.acct_id = a.acct_id
       and p.per_or_bus_flg = 'P'
       and p.per_id = ap.per_id
       and a.cis_division = &pcis_division
       and a.mailing_prem_id=pr.prem_id
and rownum <= 50