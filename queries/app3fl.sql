select rownum           "№ п/п",
       mrsk_id          "Уникальный код МРСК",
       sp_id            "Уникальный код ЛЭСК",
       fio              "ФИО",
       state_d          "Район",
       city             "Нас. пункт",
       street           "Улица",
       house            "Дом",
       flat             "Квартира",
       naim_eu          "Наименование ЭПУ",
       class_of_v       "Класс напряжения",
       price_1_d        "Тарифная группа",
       mtr_type_d       "Тип ПУ",
       badge_nbr        "Заводской №",
       kl_tochn         "Класс точности",
       reg_const        "Коэфф. трансформации",
       full_scale       "Разрядность",
       askue            "Удалённый опрос",
       to_gbp           "Алгоритм приведения к ГБП",
       max_power        "Макс. мощность",
       tip_plit_d       "Тип уст. плит",
       kol_zare         "Количество проживающих",
       kol_kom          "Количество комнат",
       vodonagr_d       "Водонагреватель",
       kind             "Вид неж. помещения",
       hours            "Часы использования",
       start_dt         "Начало оказания услуг",
       end_dt           "Окончание оказания услуг",
       also             "Дополнительная информация" 
  from (select distinct
               to_char(null) mrsk_id,
               sp.sp_id,
               case
                 when &pdat < sa.start_dt then
                   sa.start_dt
                 else
                   trunc(&pdat, 'mm')
               end start_dt,
               case
                 when trunc(sa.end_dt) between trunc(&pdat, 'mm') and last_day(trunc(&pdat)) then
                   sa.end_dt
                 else
                   last_day(trunc(&pdat))
               end end_dt,
               spri.price_1_d,
               pn.entity_name fio,
               pr.state,
               st.state_d,
               pr.city,
               pr.address3 street,
               pr.address2 house,
               pr.address4 flat,
               case
                 when trim(pr.prem_type_cd) in ('HOME', 'COTTEGE')
                      and trim(sa.sa_type_cd) in ('L_EL_RES', 'L_ELNRES')
                      and not exists (select null
                                        from rusadm.ci_sa  isa
                                       where isa.acct_id = sa.acct_id
                                         and trim(isa.sa_type_cd) = 'ODN') then
                   'ИЖД'
                 when trim(pr.prem_type_cd) in ('DOMOVLAD', 'NADVORN', 'PROCHIE')
                      and trim(sa.sa_type_cd) in ('L_EL_RES', 'L_ELNRES')
                      and not exists (select null
                                        from rusadm.ci_sa  isa
                                       where isa.acct_id = sa.acct_id
                                         and trim(isa.sa_type_cd) = 'ODN') then
                   'НО'
                 else
                   'МКД'
               end naim_eu,
               to_char(null) class_of_v,
               plit.tip_plit_d,
               kom.kol_kom,
               zare.kol_zare,
               nagr.vodonagr_d,
               mt.mtr_type_d,
               m.badge_nbr,
               toch.kl_tochn,
               r.full_scale,
               r.reg_const,
               to_char(null) askue,
               to_char(null) to_gbp,
               to_number(null) max_power,
               to_char(null) kind,
               to_char(null) hours,
               to_char(null) also
          from rusadm.ci_sp                 sp,
               rusadm.ci_sa_sp              sap,
               rusadm.ci_sa                 sa,
               (select sh.sa_id,
                       sh.char_val price_1,
                       cv.descr    price_1_d
                  from rusadm.ci_sa_char  sh,
                       rusadm.ci_char_val_l cv
                 where trim(sh.char_type_cd) = 'PRICE-1'
                   and cv.char_type_cd = sh.char_type_cd
                   and cv.char_val = sh.char_val
                   and cv.language_cd = 'RUS'
                   and sh.effdt = (select max(sh2.effdt)
                                     from rusadm.ci_sa_char  sh2
                                    where sh2.sa_id = sh.sa_id
                                      and sh2.char_type_cd = sh.char_type_cd
                                      and sh2.effdt <= last_day(trunc(&pdat)))) spri,
               rusadm.ci_acct_per           ap,
               rusadm.ci_per                p,
               rusadm.ci_per_name           pn,
               rusadm.ci_prem               pr,
               (select s.state,
                       s.descr state_d
                  from rusadm.ci_state_l s
                 where s.language_cd = 'RUS') st,
               (select pc.prem_id,
                       trim(pc.char_val) kol_kom
                  from rusadm.ci_prem_char  pc
                 where trim(pc.char_type_cd) = 'KOL_KOM'
                   and pc.effdt = (select max(pc2.effdt)
                                     from rusadm.ci_prem_char  pc2
                                    where pc2.prem_id = pc.prem_id
                                      and pc2.char_type_cd = pc.char_type_cd
                                      and pc2.effdt <= last_day(trunc(&pdat)))) kom,
               (select pc.prem_id,
                       trim(pc.char_val) kol_zare
                  from rusadm.ci_prem_char  pc
                 where trim(pc.char_type_cd) = 'KOL_ZARE'
                   and pc.effdt = (select max(pc2.effdt)
                                     from rusadm.ci_prem_char  pc2
                                    where pc2.prem_id = pc.prem_id
                                      and pc2.char_type_cd = pc.char_type_cd
                                      and pc2.effdt <= last_day(trunc(&pdat)))) zare,
               (select pc.prem_id,
                       trim(pc.char_val) tip_plit,
                       cv.descr    tip_plit_d
                  from rusadm.ci_prem_char  pc,
                       rusadm.ci_char_val_l cv
                 where trim(pc.char_type_cd) = 'TIP_PLIT'
                   and cv.char_type_cd = pc.char_type_cd
                   and cv.char_val = pc.char_val
                   and cv.language_cd = 'RUS'
                   and pc.effdt = (select max(pc2.effdt)
                                     from rusadm.ci_prem_char  pc2
                                    where pc2.prem_id = pc.prem_id
                                      and pc2.char_type_cd = pc.char_type_cd
                                      and pc2.effdt <= last_day(trunc(&pdat)))) plit,
               (select pc.prem_id,
                       trim(pc.char_val) vodonagr,
                       cv.descr    vodonagr_d
                  from rusadm.ci_prem_char  pc,
                       rusadm.ci_char_val_l cv
                 where trim(pc.char_type_cd) = 'VODONAGR'
                   and cv.char_type_cd = pc.char_type_cd
                   and cv.char_val = pc.char_val
                   and cv.language_cd = 'RUS'
                   and pc.effdt = (select max(pc2.effdt)
                                     from rusadm.ci_prem_char  pc2
                                    where pc2.prem_id = pc.prem_id
                                      and pc2.char_type_cd = pc.char_type_cd
                                      and pc2.effdt <= last_day(trunc(&pdat)))) nagr,

               rusadm.ci_sp_mtr_hist  mh,
               rusadm.ci_mtr_config   mc,
               rusadm.ci_mtr          m,
               (select t.mtr_type_cd,
                       t.descr mtr_type_d
                  from rusadm.ci_mtr_type_l   t
                 where t.language_cd = 'RUS') mt,
               (select mch.mtr_id,
                       trim(mch.char_val) kl_tochn
                  from rusadm.ci_mtr_char  mch
                 where trim(mch.char_type_cd) = 'KL-TOCHN'
                   and mch.effdt = (select max(mch2.effdt)
                                      from rusadm.ci_mtr_char  mch2
                                     where mch2.mtr_id = mch.mtr_id
                                       and mch2.char_type_cd = mch.char_type_cd
                                       and mch2.effdt <= last_day(trunc(&pdat)))) toch,
               rusadm.ci_reg          r
         where sp.sp_id = sap.sp_id
           and sap.sa_id = sa.sa_id
           and (sap.stop_dttm is null or sap.stop_dttm <= last_day(trunc(&pdat))) 
           and sa.start_dt <= last_day(trunc(&pdat))
           and (sa.end_dt is null or sa.end_dt <= last_day(trunc(&pdat)))
           and sa.sa_id = spri.sa_id(+)
           and sa.acct_id = ap.acct_id
           and ap.per_id = p.per_id
           and p.per_or_bus_flg = 'P '
           and ap.main_cust_sw = 'Y'
           and p.per_id = pn.per_id
           and pn.prim_name_sw = 'Y'
           and trim(pn.entity_name) != 'М,КД'
           and sp.prem_id = pr.prem_id
           and trim(pr.cis_division) = 'LESK'
           and pr.state = st.state
           and trim(pr.state) = decode(&pdb_lesk, '-1', trim(pr.state), &pdb_lesk)
           and pr.prem_id = kom.prem_id(+)
           and pr.prem_id = zare.prem_id(+)
           and pr.prem_id = plit.prem_id(+)
           and pr.prem_id = nagr.prem_id(+)
           and mh.sp_id = sp.sp_id
           and mh.removal_dttm is null
           and mh.mtr_config_id = mc.mtr_config_id
           and mc.mtr_id = m.mtr_id
           and m.mtr_status_flg = 'A '
           and mt.mtr_type_cd = m.mtr_type_cd
           and m.mtr_id = toch.mtr_id(+)
           and m.mtr_id = r.mtr_id)
