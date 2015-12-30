/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  Косых Евгений
 * Created: 30.12.2015
 */


delete from lcmccb.cm_slice_lesk_data   ld
  where ld.dttm = &pdat
    and trim(ld.cis_division) = &cis_division;

insert into lcmccb.cm_slice_lesk_data
select distinct
       &pdat dttm,
       al.state,
       al.cis_division,
       nvl2(trim(al.state), al.state_d, 'ГЭСК')     r_on_text,
       case
         when length(al.ls_shtrih) > 21 then
           substr(al.ls_shtrih, 1, 21)
         else
           al.ls_shtrih
       end ls_shtrih,
       al.sp_id,
       al.abolish_dt,
       al.name_klient fio,
       al.city,
       al.street,
       al.house,
       al.flat,
       al.naim_tp,
       al.serial_nbr,
       al.val_date,
       al.val_period,
       al.start_dt,
       al.end_dt,
       al.start_reg_read_id,
       case
         when al.start_read_type_flg != '30' then
           al.start_reg_reading
       end start_reg_reading,
       case
         when al.start_read_type_flg != '30' then
           al.start_read_dttm
       end start_read_dttm,
       al.start_read_type_flg,
       al.start_read_type,
       al.end_reg_read_id,
       case
         when al.end_read_type_flg != '30' then
           al.end_reg_reading
       end end_reg_reading,
       case
         when al.end_read_type_flg != '30' then
           al.end_read_dttm
       end end_read_dttm,
       al.end_read_type_flg,
       al.end_read_type,
       al.koef_trans,
       al.sa_status_flg,
       al.sa_status,
       case
         when al.norm = 'NOTNORM' and al.end_read_type_flg != '30' then
           round(al.final_reg_qty)
       end v_ee_mtr,
       case
         when al.norm = 'NORM' and al.sqi_cd in ('NORMATIV', 'CONST_VO') then
           round(al.v_ee)
       end v_norm,
       case
         when al.norm = 'NOTNORM' and
              al.end_read_type_flg = '30' and
              al.vnorm is null then
           round(al.v_ee)
       end ras_vel_med,
       case
         when al.norm = 'NOTNORM' and
              al.end_read_type_flg = '30' and
              al.vnorm is not null then
           round(al.v_ee)
       end ras_vel_norm,
       round(al.unmet_cons) unmet_cons,
       round(al.v_ee) v_ee_all,
       al.kol_zare,
       al.kol_kom,
       al.tip_plit,
       al.tip_plit_d,
       al.tip_otop,
       al.tip_otop_d,
       al.vodonagr,
       al.vodonagr_d,
       al.tarif_gr,
       al.old_ls,
       al.bill_id,
       al.el_seti,
       al.sp_start_dt,
       al.sp_stop_dt,
       al.sp_start_reg_reading,
       al.sp_stop_reg_reading,
       al.prem_type,
       al.tou_cd,
       al.acct_id,
       al.receive_dt,
       al.retire_dt,
       al.manufacturer,
       al.amperage,
       al.voltage,
       al.precision,
       al.seal_num,
       al.substantion,
       al.sa_id,
       al.tou_d,
       al.unk,
       al.start_mr_source,
       al.end_mr_source,
       al.per_id,
       al.bill_stat,
       al.bseg_stat
  from (select 'NOTNORM' norm,
               trunc(&pdat, 'mm') dttm,
               to_char(trunc(&pdat, 'mm'), 'month') mes,
               to_char(trunc(&pdat, 'mm'), 'yyyy') god,
               substr(ls.ls_shtrih, 2, 6) r_on,
               a.acct_id,
               p.per_id,
               pn.entity_name name_klient,
               sa.sa_id,
               sa.sa_type_cd,
               sa.old_acct_id old_ls,
               sa.cis_division,
               sa.sa_status_flg,
               sa_stat.sa_status,
               ls.ls_shtrih,
               login.unk,
               prem.prem_id,
               prem.prem_type_cd,
               prem.state,
               prem.state_d,
               prem.city,
               prem.street,
               prem.house,
               prem.flat,
               prem.prem_type,
               prem.kol_kom,
               prem.kol_zare,
               prem.tip_plit,
               prem.tip_plit_d,
               prem.tip_otop,
               prem.tip_otop_d,
               prem.vodonagr,
               prem.vodonagr_d,
               sap.start_dttm          sp_start_dt,
               sap.stop_dttm           sp_stop_dt,
               sap.start_reg_reading   sp_start_reg_reading,
               sap.stop_reg_reading    sp_stop_reg_reading,
               sap.start_mtr_id        sp_start_mtr_id,
               sap.start_mtr_config_id sp_start_mtr_config_id,
               sap.stop_mtr_id         sp_stop_mtr_id,
               sap.stop_mtr_config_id  sp_stop_mtr_config_id,
               sap.sp_id,
               sap.abolish_dt,
               sap.substantion,
               sap.el_seti,
               sap.naim_tp,
               sap.tarif_gr,
               sap.tarif_gr_d,
               mtr.mtr_config_id,
               mtr.mtr_id,
               mtr.receive_dt,
               mtr.retire_dt,
               mtr.manufacturer,
               mtr.reg_id,
               mtr.koef_trans,
               mtr.badge_nbr,
               mtr.serial_nbr,
               mtr.full_scale,
               mtr.val_date,
               mtr.val_period,
               mtr.amperage,
               mtr.voltage,
               mtr.precision,
               mtr.seal_num,
               bill.v_ee,
               bill.tou_cd,
               bill.tou_d,
               bill.sqi_cd,
               bill.bill_id,
               bill.start_dt,
               bill.end_dt,
               bill.bill_stat,
               bill.bseg_stat,
               bill.start_reg_read_id,
               bill.start_reg_reading,
               bill.start_read_dttm,
               bill.start_read_type_flg,
               bill.start_read_type,
               bill.start_mtr_id,
               bill.start_mtr_config_id,
               bill.start_mr_source,
               bill.end_reg_read_id,
               bill.end_reg_reading,
               bill.end_read_dttm,
               bill.end_read_type_flg,
               bill.end_read_type,
               bill.end_mtr_id,
               bill.end_mtr_config_id,
               bill.end_mr_source,
               bill.vnorm,
               to_number(null) unmet_cons,
               bill.final_reg_qty
          from rusadm.ci_acct         a,
               (select ac.acct_id,
                       ac.adhoc_char_val   ls_shtrih
                  from rusadm.ci_acct_char  ac
                 where ac.char_type_cd = 'SHT_KOD'
                   and ac.effdt = (select max(ac2.effdt)
                                     from rusadm.ci_acct_char  ac2
                                    where ac2.acct_id = ac.acct_id
                                      and ac2.char_type_cd = ac.char_type_cd
                                      and ac2.effdt <= last_day(&pdat))) ls,
               (select ac.acct_id,
                       ac.adhoc_char_val   unk
                  from rusadm.ci_acct_char  ac
                 where ac.char_type_cd = 'LKKLOGIN'
                   and ac.effdt = (select max(ac2.effdt)
                                     from rusadm.ci_acct_char  ac2
                                    where ac2.acct_id = ac.acct_id
                                      and ac2.char_type_cd = ac.char_type_cd
                                      and ac2.effdt <= last_day(&pdat))) login,
               rusadm.ci_acct_per     ap,
               rusadm.ci_per          p,
               rusadm.ci_per_name     pn,
               rusadm.ci_sa           sa,
               (select lvl.field_value sa_status_flg,
                       lvl.descr       sa_status
                  from rusadm.ci_lookup_val_l   lvl
                 where lvl.field_name = 'SA_STATUS_FLG'
                   and lvl.language_cd = 'RUS') sa_stat,
               (select pr.prem_id,
                       l.prem_type_cd, -- Тип объекта обслуживания
                       pr.state,
                       st.descr state_d,
                       pr.city,
                       pr.address3 street,
                       pr.address2 house,
                       pr.address4 flat,
                       l.descr                prem_type,
                       kol_kom.char_val       kol_kom,
                       kol_zare.char_val      kol_zare,
                       tip_plit.char_val      tip_plit,
                       tip_plit.char_descr    tip_plit_d,
                       tip_otop.char_val      tip_otop,
                       tip_otop.char_descr    tip_otop_d,
                       vodonagr.char_val      vodonagr,
                       vodonagr.char_descr    vodonagr_d
                  from rusadm.ci_prem           pr,
                       rusadm.ci_state_l        st,
                       rusadm.ci_prem_type_l    l,
                       (select prc.prem_id,
                               prc.char_val
                          from rusadm.ci_prem_char   prc
                         where prc.char_type_cd = 'KOL_KOM'
                           and prc.effdt = (select max(prc2.effdt)
                                              from rusadm.ci_prem_char  prc2
                                             where prc.prem_id = prc2.prem_id
                                               and prc.char_type_cd = prc2.char_type_cd
                                               and prc2.effdt < add_months(trunc(&pdat, 'mm'), 1))) kol_kom,
                       (select prc.prem_id,
                               prc.char_val
                          from rusadm.ci_prem_char   prc
                         where prc.char_type_cd = 'KOL_ZARE'
                           and prc.effdt = (select max(prc2.effdt)
                                              from rusadm.ci_prem_char  prc2
                                             where prc.prem_id = prc2.prem_id
                                               and prc.char_type_cd = prc2.char_type_cd
                                               and prc2.effdt < add_months(trunc(&pdat, 'mm'), 1))) kol_zare,
                       (select prc.prem_id,
                               prc.char_val,
                               cvl.descr char_descr
                          from rusadm.ci_prem_char   prc,
                               rusadm.ci_char_val_l  cvl
                         where prc.char_type_cd = 'TIP_PLIT'
                           and prc.effdt = (select max(prc2.effdt)
                                              from rusadm.ci_prem_char  prc2
                                             where prc.prem_id = prc2.prem_id
                                               and prc.char_type_cd = prc2.char_type_cd
                                               and prc2.effdt < add_months(trunc(&pdat, 'mm'), 1))
                           and prc.char_type_cd = cvl.char_type_cd
                           and prc.char_val = cvl.char_val
                           and cvl.language_cd = 'RUS') tip_plit,
                       (select prc.prem_id,
                               prc.char_val,
                               cvl.descr char_descr
                          from rusadm.ci_prem_char   prc,
                               rusadm.ci_char_val_l  cvl
                         where prc.char_type_cd = 'TIP_OTOP'
                           and prc.effdt = (select max(prc2.effdt)
                                              from rusadm.ci_prem_char  prc2
                                             where prc.prem_id = prc2.prem_id
                                               and prc.char_type_cd = prc2.char_type_cd
                                               and prc2.effdt < add_months(trunc(&pdat, 'mm'), 1))
                           and prc.char_type_cd = cvl.char_type_cd
                           and prc.char_val = cvl.char_val
                           and cvl.language_cd = 'RUS') tip_otop,
                       (select prc.prem_id,
                               prc.char_val,
                               cvl.descr char_descr
                          from rusadm.ci_prem_char   prc,
                               rusadm.ci_char_val_l  cvl
                         where prc.char_type_cd = 'VODONAGR'
                           and prc.effdt = (select max(prc2.effdt)
                                              from rusadm.ci_prem_char  prc2
                                             where prc.prem_id = prc2.prem_id
                                               and prc.char_type_cd = prc2.char_type_cd
                                               and prc2.effdt < add_months(trunc(&pdat, 'mm'), 1))
                           and prc.char_type_cd = cvl.char_type_cd
                           and prc.char_val = cvl.char_val
                           and cvl.language_cd = 'RUS') vodonagr
                 where pr.state = st.state(+)
                   and pr.country = st.country(+)
                   and st.language_cd(+) = 'RUS'
                   and pr.prem_type_cd = l.prem_type_cd
                   and pr.prem_type_cd not in ('MNDOM', 'PROVIDER')
                   -- Учатсвуют только частный сектор либо 
                   -- квартиры в МКД без ОДПУ
                   and not exists (select pr2.prem_id
                                     from rusadm.ci_prem    pr2,
                                          rusadm.ci_sp      sp2
                                    where pr2.prem_type_cd = 'KVMKD'
                                      and pr2.prnt_prem_id = sp2.prem_id
                                      and sp2.sp_type_cd = 'E-L-MKD'
                                      and pr2.prem_id = pr.prem_id)
                   and l.language_cd = 'RUS'
                   and pr.prem_id = kol_kom.prem_id(+)
                   and pr.prem_id = kol_zare.prem_id(+)
                   and pr.prem_id = tip_plit.prem_id(+)
                   and pr.prem_id = tip_otop.prem_id(+)
                   and pr.prem_id = vodonagr.prem_id(+))   prem,
               (select sasp.sa_id,
                       sasp.start_dttm,
                       sasp.stop_dttm,
                       start_mr.start_reg_reading,
                       start_mr.start_mtr_id,
                       start_mr.start_mtr_config_id,
                       stop_mr.stop_reg_reading,
                       stop_mr.stop_mtr_id,
                       stop_mr.stop_mtr_config_id,
                       sp.sp_id,
                       sp.abolish_dt,
                       fac.descr              substantion,
                       tel_seti.el_seti,
                       tnaim_tp.naim_tp,
                       tarif_gr.char_val      tarif_gr,
                       tarif_gr.char_descr    tarif_gr_d
                  from rusadm.ci_sa_sp          sasp,
                       rusadm.ci_sp             sp,
                       rusadm.ci_fac_lvl_1_l    fac,
                       (select spc.sp_id,
                               spc.char_val,
                               cl.descr el_seti
                          from rusadm.ci_sp_char    spc,
                               rusadm.ci_char_val_l cl
                         where spc.char_type_cd = 'EL_SETI' -- Тип электросетей
                           and spc.char_type_cd = cl.char_type_cd
                           and spc.char_val = cl.char_val
                           and cl.language_cd = 'RUS'
                           and spc.effdt = (select max(spc2.effdt)
                                              from rusadm.ci_sp_char   spc2
                                             where spc2.sp_id = spc.sp_id
                                               and spc2.char_type_cd = spc.char_type_cd
                                               and spc2.effdt < add_months(trunc(&pdat, 'mm'), 1))) tel_seti,
                       (select spc.sp_id,
                               spc.adhoc_char_val naim_tp
                          from rusadm.ci_sp_char    spc
                         where spc.char_type_cd = 'NAIM-TP' -- Наименование точки поставки ээ
                           and spc.effdt = (select max(spc2.effdt)
                                              from rusadm.ci_sp_char   spc2
                                             where spc2.sp_id = spc.sp_id
                                               and spc2.char_type_cd = spc.char_type_cd
                                               and spc2.effdt < add_months(trunc(&pdat, 'mm'), 1))) tnaim_tp,
                       (select sac.sa_id,
                               sac.char_val,
                               cvl.descr char_descr
                          from rusadm.ci_sa_char     sac,
                               rusadm.ci_char_val_l  cvl
                         where sac.char_type_cd = 'PRICE-1' -- Тарифная группа абонента
                           and sac.effdt = (select max(sac2.effdt)
                                              from rusadm.ci_sa_char  sac2
                                             where sac.sa_id = sac2.sa_id
                                               and sac.char_type_cd = sac2.char_type_cd
                                               and sac2.effdt < add_months(trunc(&pdat, 'mm'), 1))
                           and sac.char_type_cd = cvl.char_type_cd
                           and sac.char_val = cvl.char_val
                           and cvl.language_cd = 'RUS') tarif_gr,
                       (select mr.mr_id,
                               mr.mr_source_cd,
                               mr.read_dttm,
                               rr.reg_reading       start_reg_reading,
                               rr.read_type_flg,
                               r.mtr_id             start_mtr_id,
                               mr.mtr_config_id     start_mtr_config_id
                          from rusadm.ci_mr             mr,
                               rusadm.ci_reg_read       rr,
                               rusadm.ci_reg            r
                         where mr.mr_id = rr.mr_id
                           and rr.reg_id = r.reg_id)     start_mr,
                       (select mr.mr_id,
                               mr.mr_source_cd,
                               mr.read_dttm,
                               rr.reg_reading       stop_reg_reading,
                               rr.read_type_flg,
                               r.mtr_id             stop_mtr_id,
                               mr.mtr_config_id     stop_mtr_config_id
                          from rusadm.ci_mr             mr,
                               rusadm.ci_reg_read       rr,
                               rusadm.ci_reg            r
                         where mr.mr_id = rr.mr_id
                           and rr.reg_id = r.reg_id)     stop_mr
                 where sasp.sp_id = sp.sp_id
                   -- Проверка даты связи РДО и ТУ
                   and not (sasp.start_dttm >= add_months(trunc(&pdat, 'mm'), 1) or
                            nvl(sasp.stop_dttm, to_date('3000', 'yyyy')) <= trunc(&pdat, 'mm'))
                   -- Проверка даты установки ТУ
                   and not (sp.install_dt >= add_months(trunc(&pdat, 'mm'), 1) or
                            nvl(sp.abolish_dt, to_date('3000', 'yyyy')) <= trunc(&pdat, 'mm'))
                   -- Нас интересуют только сети МРСК либо не указанные
                   and (tel_seti.char_val(+) is null or
                        tel_seti.char_val(+) = 'TCO')
                   and sp.sp_type_cd in ('E-GTU', 'E-GTU-S')
                   and sp.fac_lvl_1_cd = fac.fac_lvl_1_cd(+)
                   and fac.language_cd(+) = 'RUS'
                   and sp.sp_id = tel_seti.sp_id(+)
                   and sp.sp_id = tnaim_tp.sp_id(+)
                   and sasp.sa_id = tarif_gr.sa_id(+)
                   and sasp.start_mr_id = start_mr.mr_id(+)
                   and sasp.stop_mr_id = stop_mr.mr_id(+)) sap,
               (select mh.sp_id,
                       mh.removal_dttm,
                       mc.mtr_config_id,
                       m.mtr_id,
                       r.reg_id,
                       r.tou_cd,
                       r.reg_const koef_trans,
                       m.badge_nbr,
                       m.serial_nbr,
                       m.receive_dt,
                       m.retire_dt,
                       mfg.descr  manufacturer,
                       r.full_scale,
                       dv.val_date,
                       inter.val_period,
                       volt.voltage,
                       amp.amperage,
                       klpr.precision,
                       snum.seal_num
                  from rusadm.ci_sp_mtr_hist   mh,
                       rusadm.ci_mtr_config    mc,
                       rusadm.ci_mtr           m,
                       rusadm.ci_mfg_l         mfg,
                       rusadm.ci_reg           r,
                       (select mch.mtr_id,
                               to_date(mch.adhoc_char_val, 'dd.mm.yyyy') val_date
                          from rusadm.ci_mtr_char   mch
                         where mch.char_type_cd = 'DT-PP-OV' -- Дата последней проверки ПУ
                           and mch.effdt = (select max(mch2.effdt)
                                               from rusadm.ci_mtr_char  mch2
                                              where mch.mtr_id = mch2.mtr_id
                                                and mch.char_type_cd = mch2.char_type_cd
                                                and mch2.effdt < add_months(trunc(&pdat, 'mm'), 1))) dv,
                       (select mch.mtr_id,
                               mch.char_val val_period
                          from rusadm.ci_mtr_char   mch
                         where mch.char_type_cd = 'PRD-POV' -- Периодичность проверки ПУ
                           and mch.effdt = (select max(mch2.effdt)
                                              from rusadm.ci_mtr_char  mch2
                                             where mch.mtr_id = mch2.mtr_id
                                                and mch.char_type_cd = mch2.char_type_cd
                                                and mch2.effdt < add_months(trunc(&pdat, 'mm'), 1))) inter,
                       (select mch.mtr_id,
                               mch.char_val precision
                          from rusadm.ci_mtr_char   mch
                         where mch.char_type_cd = 'KL-TOCHN' -- Класс точности ПУ
                           and mch.effdt = (select max(mch2.effdt)
                                              from rusadm.ci_mtr_char  mch2
                                             where mch.mtr_id = mch2.mtr_id
                                                and mch.char_type_cd = mch2.char_type_cd
                                                and mch2.effdt < add_months(trunc(&pdat, 'mm'), 1))) klpr,
                       (select mch.mtr_id,
                               mch.char_val amperage
                          from rusadm.ci_mtr_char   mch
                         where mch.char_type_cd = 'TOK-PU' -- Ампераж ПУ
                           and mch.effdt = (select max(mch2.effdt)
                                              from rusadm.ci_mtr_char  mch2
                                             where mch.mtr_id = mch2.mtr_id
                                                and mch.char_type_cd = mch2.char_type_cd
                                                and mch2.effdt < add_months(trunc(&pdat, 'mm'), 1))) amp,
                       (select mch.mtr_id,
                               mch.char_val voltage
                          from rusadm.ci_mtr_char   mch
                         where mch.char_type_cd = 'NAPR-PU' -- Вольтаж ПУ
                           and mch.effdt = (select max(mch2.effdt)
                                              from rusadm.ci_mtr_char  mch2
                                             where mch.mtr_id = mch2.mtr_id
                                                and mch.char_type_cd = mch2.char_type_cd
                                                and mch2.effdt < add_months(trunc(&pdat, 'mm'), 1))) volt,
                       (select mch.mtr_id,
                               mch.adhoc_char_val seal_num
                          from rusadm.ci_mtr_char   mch
                         where mch.char_type_cd = 'NOM_PLOM' -- Номер пломбы
                           and mch.effdt = (select max(mch2.effdt)
                                              from rusadm.ci_mtr_char  mch2
                                             where mch.mtr_id = mch2.mtr_id
                                                and mch.char_type_cd = mch2.char_type_cd
                                                and mch2.effdt < add_months(trunc(&pdat, 'mm'), 1))) snum
                 where mh.mtr_config_id = mc.mtr_config_id
                   and mc.mtr_id = m.mtr_id
                   and m.mfg_cd = mfg.mfg_cd
                   and mfg.language_cd = 'RUS'
                   and r.mtr_id = m.mtr_id
                   and ((nvl(mh.removal_dttm, to_date('3000', 'yyyy')) >= trunc(&pdat, 'mm')
                         -- Проверка даты начала действия конфигурации ПУ
                         and mc.eff_dttm >= (select max(mc2.eff_dttm)
                                               from rusadm.ci_mtr_config mc2
                                              where mc2.mtr_id = mc.mtr_id
                                                and mc2.eff_dttm <= add_months(trunc(&pdat, 'mm'), 1))
                         and mc.eff_dttm < add_months(trunc(&pdat, 'mm'), 1)
                         -- Проверка даты получения ПУ
                         and not (m.receive_dt >= add_months(trunc(&pdat, 'mm'), 1) or
                                  nvl(m.retire_dt, to_date('3000', 'yyyy')) <= trunc(&pdat, 'mm'))
                         -- Проверка даты начала действия регистра ПУ
                         and r.eff_dttm >= (select max(re2.eff_dttm)
                                              from rusadm.ci_reg re2
                                             where re2.mtr_id = r.mtr_id
                                               and re2.eff_dttm <= add_months(trunc(&pdat, 'mm'), 1))
                         and r.eff_dttm < add_months(trunc(&pdat, 'mm'), 1))
                         -- По данному регистру долны существовать показания
                        or exists (select null
                                     from rusadm.ci_mr        mr2,
                                          rusadm.ci_reg_read  rr2
                                    where mr2.mr_id = rr2.mr_id
                                      and rr2.reg_id = r.reg_id
                                      and mr2.use_on_bill_sw = 'Y'
                                      and rr2.read_type_flg != '30'
                                      and mr2.read_dttm >= trunc(&pdat, 'mm')
                                      and mr2.read_dttm < last_day(&pdat) + 1)
                       and not exists (select null
                                         from rusadm.ci_sp_mtr_hist  mh2
                                        where mh2.mtr_config_id = mc.mtr_config_id
                                          and nvl(mh2.removal_dttm, to_date('3000', 'yyyy')) >= trunc(&pdat, 'mm')))
                   and m.mtr_id = dv.mtr_id(+)
                   and m.mtr_id = inter.mtr_id(+)
                   and m.mtr_id = volt.mtr_id(+)
                   and m.mtr_id = amp.mtr_id(+)
                   and m.mtr_id = klpr.mtr_id(+)
                   and m.mtr_id = snum.mtr_id(+)) mtr,
               (select round(bsr.msr_qty) v_ee,
                       count(*) over (partition by b.acct_id) count_seg,
                       bill_id,
                       b.acct_id,
                       sa_id,
                       sa.sa_type_cd,
                       bs.prem_id,
                       bsr.sp_id,
                       bsr.tou_cd,
                       t.descr tou_d,
                       bsr.sqi_cd,
                       case
                         when st_rd.read_type_flg ='80'
                          and st_rd.mr_source_cd = 'FOR_BILL' then
                           (select mrc.char_val_fk1
                              from rusadm.ci_reg_read  rr,
                                   rusadm.ci_mr_char   mrc,
                                   rusadm.ci_reg_read  rr2
                             where rr.reg_read_id = bsr.start_reg_read_id
                               and rr.mr_id = mrc.mr_id
                               and mrc.char_type_cd = 'ORIG_MR'
                               and rr2.mr_id = mrc.char_val_fk1
                               and rownum = 1)
                         else
                           (select rr.mr_id
                              from rusadm.ci_reg_read  rr
                             where rr.reg_read_id = bsr.start_reg_read_id)
                       end     start_reg_read_id,
                       case
                         when st_rd.read_type_flg ='80'
                          and st_rd.mr_source_cd = 'FOR_BILL' then
                           (select trunc(mr.read_dttm)
                              from rusadm.ci_reg_read  rr,
                                   rusadm.ci_mr_char   mrc,
                                   rusadm.ci_mr        mr,
                                   rusadm.ci_reg_read  rr2
                             where rr.reg_read_id = bsr.start_reg_read_id
                               and rr.mr_id = mrc.mr_id
                               and mrc.char_type_cd = 'ORIG_MR'
                               and mr.mr_id = mrc.char_val_fk1
                               and rr2.mr_id = mrc.char_val_fk1
                               and rownum = 1)
                         else
                           trunc(bsr.start_read_dttm)
                       end     start_read_dttm,
                       round(bsr.start_reg_reading) start_reg_reading,
                       case
                         when st_rd.read_type_flg ='80'
                          and st_rd.mr_source_cd = 'FOR_BILL' then
                           (select rr2.read_type_flg
                              from rusadm.ci_reg_read  rr,
                                   rusadm.ci_reg       r,
                                   rusadm.ci_mr_char   mrc,
                                   rusadm.ci_reg_read  rr2,
                                   rusadm.ci_reg       r2
                             where rr.reg_read_id = bsr.start_reg_read_id
                               and rr.mr_id = mrc.mr_id
                               and rr.reg_id = r.reg_id
                               and mrc.char_type_cd = 'ORIG_MR'
                               and rr2.mr_id = mrc.char_val_fk1
                               and rr2.reg_id = r2.reg_id
                               and r.tou_cd = r2.tou_cd
                               and rownum = 1)
                         else
                           st_rd.read_type_flg
                       end       start_read_type_flg,
                       case
                         when st_rd.read_type_flg ='80'
                          and st_rd.mr_source_cd = 'FOR_BILL' then
                           (select lvl.descr
                              from rusadm.ci_reg_read      rr,
                                   rusadm.ci_reg           r,
                                   rusadm.ci_mr_char       mrc,
                                   rusadm.ci_reg_read      rr2,
                                   rusadm.ci_reg           r2,
                                   rusadm.ci_lookup_val_l  lvl
                             where rr.reg_read_id = bsr.start_reg_read_id
                               and rr.mr_id = mrc.mr_id
                               and rr.reg_id = r.reg_id
                               and mrc.char_type_cd = 'ORIG_MR'
                               and rr2.mr_id = mrc.char_val_fk1
                               and rr2.reg_id = r2.reg_id
                               and r.tou_cd = r2.tou_cd
                               and lvl.field_name = 'READ_TYPE_FLG'
                               and lvl.language_cd = 'RUS'
                               and lvl.field_value = rr2.read_type_flg
                               and rownum = 1)
                         else
                           st_rd.read_type
                       end       start_read_type,
                       case
                         when st_rd.read_type_flg ='80'
                          and st_rd.mr_source_cd = 'FOR_BILL' then
                           (select mrs.descr
                              from rusadm.ci_reg_read      rr,
                                   rusadm.ci_mr_char       mrc,
                                   rusadm.ci_mr            mr,
                                   rusadm.ci_mr_source_l   mrs
                             where rr.reg_read_id = bsr.start_reg_read_id
                               and rr.mr_id = mrc.mr_id
                               and mrc.char_type_cd = 'ORIG_MR'
                               and mr.mr_id = mrc.char_val_fk1
                               and mr.mr_source_cd = mrs.mr_source_cd
                               and mrs.language_cd = 'RUS'
                               and rownum = 1)
                         else
                           st_rd.mr_source
                       end       start_mr_source,
                       case
                         when end_rd.read_type_flg ='80'
                          and end_rd.mr_source_cd = 'FOR_BILL' then
                           (select mrc.char_val_fk1
                              from rusadm.ci_reg_read  rr,
                                   rusadm.ci_mr_char   mrc,
                                   rusadm.ci_reg_read  rr2
                             where rr.reg_read_id = bsr.end_reg_read_id
                               and rr.mr_id = mrc.mr_id
                               and mrc.char_type_cd = 'ORIG_MR'
                               and rr2.mr_id = mrc.char_val_fk1
                               and rownum = 1)
                         else
                           (select rr.mr_id
                              from rusadm.ci_reg_read  rr
                             where rr.reg_read_id = bsr.end_reg_read_id)
                       end     end_reg_read_id,
                       case
                         when end_rd.read_type_flg ='80'
                          and end_rd.mr_source_cd = 'FOR_BILL' then
                           (select trunc(mr.read_dttm)
                              from rusadm.ci_reg_read  rr,
                                   rusadm.ci_mr_char   mrc,
                                   rusadm.ci_mr        mr,
                                   rusadm.ci_reg_read  rr2
                             where rr.reg_read_id = bsr.end_reg_read_id
                               and rr.mr_id = mrc.mr_id
                               and mrc.char_type_cd = 'ORIG_MR'
                               and mr.mr_id = mrc.char_val_fk1
                               and rr2.mr_id = mrc.char_val_fk1
                               and rownum = 1)
                         else
                           trunc(bsr.end_read_dttm)
                       end     end_read_dttm,
                       round(bsr.end_reg_reading) end_reg_reading,
                       case
                         when end_rd.read_type_flg ='80'
                          and end_rd.mr_source_cd = 'FOR_BILL' then
                           (select rr2.read_type_flg
                              from rusadm.ci_reg_read  rr,
                                   rusadm.ci_reg       r,
                                   rusadm.ci_mr_char   mrc,
                                   rusadm.ci_reg_read  rr2,
                                   rusadm.ci_reg       r2
                             where rr.reg_read_id = bsr.end_reg_read_id
                               and rr.mr_id = mrc.mr_id
                               and rr.reg_id = r.reg_id
                               and mrc.char_type_cd = 'ORIG_MR'
                               and rr2.mr_id = mrc.char_val_fk1
                               and rr2.reg_id = r2.reg_id
                               and r.tou_cd = r2.tou_cd
                               and rownum = 1)
                         else
                           end_rd.read_type_flg
                       end       end_read_type_flg,
                       case
                         when end_rd.read_type_flg ='80'
                          and end_rd.mr_source_cd = 'FOR_BILL' then
                           (select lvl.descr
                              from rusadm.ci_reg_read      rr,
                                   rusadm.ci_reg           r,
                                   rusadm.ci_mr_char       mrc,
                                   rusadm.ci_reg_read      rr2,
                                   rusadm.ci_reg           r2,
                                   rusadm.ci_lookup_val_l  lvl
                             where rr.reg_read_id = bsr.end_reg_read_id
                               and rr.mr_id = mrc.mr_id
                               and rr.reg_id = r.reg_id
                               and mrc.char_type_cd = 'ORIG_MR'
                               and rr2.mr_id = mrc.char_val_fk1
                               and rr2.reg_id = r2.reg_id
                               and r.tou_cd = r2.tou_cd
                               and lvl.field_name = 'READ_TYPE_FLG'
                               and lvl.language_cd = 'RUS'
                               and lvl.field_value = rr2.read_type_flg
                               and rownum = 1)
                         else
                           end_rd.read_type
                       end       end_read_type,
                       case
                         when end_rd.read_type_flg ='80'
                          and end_rd.mr_source_cd = 'FOR_BILL' then
                           (select mrs.descr
                              from rusadm.ci_reg_read      rr,
                                   rusadm.ci_mr_char       mrc,
                                   rusadm.ci_mr            mr,
                                   rusadm.ci_mr_source_l   mrs
                             where rr.reg_read_id = bsr.end_reg_read_id
                               and rr.mr_id = mrc.mr_id
                               and mrc.char_type_cd = 'ORIG_MR'
                               and mr.mr_id = mrc.char_val_fk1
                               and mr.mr_source_cd = mrs.mr_source_cd
                               and mrs.language_cd = 'RUS'
                               and rownum = 1)
                         else
                           end_rd.mr_source
                       end       end_mr_source,
                       tvnorm.vnorm,
                      /* tunmet_cons.unmet_cons,*/
                       bs.start_dt,
                       bs.end_dt,
                       st_rd.start_mtr_id,
                       st_rd.start_mtr_config_id,
                       end_rd.end_mtr_id,
                       end_rd.end_mtr_config_id,
                       bsr.final_reg_qty,
                       bf.bill_stat,
                       bsf.bseg_stat
                  from rusadm.ci_bill      b
                  join (select lv.field_value bill_stat_flg,
                               lv.descr       bill_stat
                          from rusadm.ci_lookup_val_l   lv
                         where lv.field_name = 'BILL_STAT_FLG'
                           and lv.language_cd = 'RUS') bf   using (bill_stat_flg)
                  join rusadm.ci_bseg      bs    using (bill_id)
                  join (select lv.field_value bseg_stat_flg,
                               lv.descr       bseg_stat
                          from rusadm.ci_lookup_val_l   lv
                         where lv.field_name = 'BSEG_STAT_FLG'
                           and lv.language_cd = 'RUS') bsf   using (bseg_stat_flg)
                  join rusadm.ci_bseg_read bsr   using (bseg_id)
/*                  left join
                       (select sum(bsq.bill_sq) unmet_cons,
                               bs.bill_id
                          from rusadm.ci_bseg_sq    bsq,
                               rusadm.ci_bseg       bs,
                               rusadm.ci_sa         sa
                         where bsq.bseg_id = bs.bseg_id
                           and bs.sa_id = sa.sa_id
                           and sa.sa_type_cd = 'PROCHEE'
                           --and trunc(sa.start_dt) = trunc(sa.end_dt)
                           and sa.start_dt between &pdat and add_months(&pdat, 1)
                         group by bs.bill_id) tunmet_cons using (bill_id)*/
                       -- Тип начальных показаний
                  join (select rr.reg_read_id,
                               rr.read_type_flg,
                               lvl.descr read_type,
                               mr.mr_source_cd,
                               ms.descr mr_source,
                               mr.mtr_config_id start_mtr_config_id,
                               r.mtr_id         start_mtr_id
                          from rusadm.ci_reg_read      rr,
                               rusadm.ci_reg           r,
                               rusadm.ci_mr            mr,
                               rusadm.ci_mr_source_l   ms,
                               rusadm.ci_lookup_val_l  lvl
                         where rr.read_type_flg = lvl.field_value
                           and rr.reg_id = r.reg_id
                           and lvl.field_name = 'READ_TYPE_FLG'
                           and lvl.language_cd = 'RUS'
                           and rr.mr_id = mr.mr_id
                           and mr.mr_source_cd = ms.mr_source_cd(+)
                           and ms.language_cd(+) = 'RUS') st_rd    on bsr.start_reg_read_id = st_rd.reg_read_id
                       -- Тип конечных показаний
                  join (select rr.reg_read_id,
                               rr.read_type_flg,
                               lvl.descr read_type,
                               mr.mr_source_cd,
                               ms.descr mr_source,
                               mr.mtr_config_id end_mtr_config_id,
                               r.mtr_id         end_mtr_id
                          from rusadm.ci_reg_read      rr,
                               rusadm.ci_reg           r,
                               rusadm.ci_mr            mr,
                               rusadm.ci_mr_source_l   ms,
                               rusadm.ci_lookup_val_l  lvl
                         where rr.read_type_flg = lvl.field_value
                           and rr.reg_id = r.reg_id
                           and lvl.field_name = 'READ_TYPE_FLG'
                           and lvl.language_cd = 'RUS'
                           and rr.mr_id = mr.mr_id
                           and mr.mr_source_cd = ms.mr_source_cd(+)
                           and ms.language_cd(+) = 'RUS') end_rd   on bsr.end_reg_read_id = end_rd.reg_read_id
                  join rusadm.ci_sa     sa     using (sa_id)
                       -- Характеристика на ТУ, определяющая тип системного расчёта:
                       -- 'YES' означает расчёт по нормативу, иначе по среднемесячному
                  left join
                       (select spc.sp_id,
                               nvl(trim(spc.adhoc_char_val), 'YES') vnorm,
                               spc.effdt
                          from rusadm.ci_sp_char  spc
                         where spc.char_type_cd = 'VNORM') tvnorm  on bsr.sp_id = tvnorm.sp_id and bs.end_dt = tvnorm.effdt
                  left join rusadm.ci_tou_l                t       on bsr.tou_cd = t.tou_cd and t.language_cd = 'RUS'
                 where bill_stat_flg = decode(&bill_stat, '-1', bill_stat_flg, &bill_stat)
                   and trim(bsr.sqi_cd) is null 
                   and bseg_stat_flg = decode(&bseg_stat, '-1', bseg_stat_flg, &bseg_stat)
                   and sa.sa_type_cd = case &cis_division
                                         when 'LESK' then
                                           'L_EL_RES'
                                         when 'GESK' then
                                           'G_EL_RES'
                                       end
                   and trunc(b.cre_dttm, 'mm') between &pdat and last_day(&pdat)) bill
         where a.acct_id = ls.acct_id(+)
           and a.acct_id = login.acct_id(+)
           and a.cis_division = &cis_division
           and a.acct_id = ap.acct_id
           and ap.per_id = p.per_id
           and p.per_or_bus_flg = 'P'
           and p.per_id = pn.per_id
           and pn.prim_name_sw = 'Y'
           and a.acct_id = sa.acct_id
           and sa.sa_status_flg < 60
           and sa.sa_status_flg = sa_stat.sa_status_flg
          /* and not (sa.start_dt >= add_months(trunc(&pdat, 'mm'), 1) or
                        nvl(sa.end_dt, to_date('3000', 'yyyy')) <= trunc(&pdat, 'mm'))*/
           and sa.char_prem_id = prem.prem_id
--           and pkcm_others.f_sverka_pr_mkd(sa.char_prem_id, &pdat) = 0
           and sa.sa_id = sap.sa_id
           and mtr.mtr_id = bill.start_mtr_id
           and bill.acct_id = sa.acct_id
           and bill.sa_id = sa.sa_id
           and bill.prem_id = prem.prem_id
--           and bill.start_mtr_config_id = sap.start_mtr_config_id
--           and ac.acct_id = '0111004928'
--           and ac.srch_char_val = '032001311112047000018'||'01'

        union all

        select 'NORM' norm,
               trunc(&pdat, 'mm') dttm,
               to_char(trunc(&pdat, 'mm'), 'month') mes,
               to_char(trunc(&pdat, 'mm'), 'yyyy') god,
               substr(ls.ls_shtrih, 2, 6) r_on,
               a.acct_id,
               p.per_id,
               pn.entity_name name_klient,
               sa.sa_id,
               sa.sa_type_cd,
               sa.old_acct_id old_ls,
               sa.cis_division,
               sa.sa_status_flg,
               sa_stat.sa_status,
               ls.ls_shtrih,
               login.unk,
               prem.prem_id,
               prem.prem_type_cd,
               nvl(prem.state, (select pr2.state
                                  from rusadm.ci_prem pr2
                                 where a.mailing_prem_id = pr2.prem_id)) state,
               nvl(prem.state_d, (select s2.descr
                                    from rusadm.ci_prem pr2,
                                         rusadm.ci_state_l s2
                                   where a.mailing_prem_id = pr2.prem_id
                                     and pr2.state = s2.state
                                     and s2.language_cd = 'RUS')) state_d,
               prem.city,
               prem.street,
               prem.house,
               prem.flat,
               prem.prem_type,
               prem.kol_kom,
               prem.kol_zare,
               prem.tip_plit,
               prem.tip_plit_d,
               prem.tip_otop,
               prem.tip_otop_d,
               prem.vodonagr,
               prem.vodonagr_d,
               sap.start_dttm          sp_start_dt,
               sap.stop_dttm           sp_stop_dt,
               sap.start_reg_reading   sp_start_reg_reading,
               sap.stop_reg_reading    sp_stop_reg_reading,
               sap.start_mtr_id        sp_start_mtr_id,
               sap.start_mtr_config_id sp_start_mtr_config_id,
               sap.stop_mtr_id         sp_stop_mtr_id,
               sap.stop_mtr_config_id  sp_stop_mtr_config_id,
               sap.sp_id,
               sap.abolish_dt,
               sap.substantion,
               sap.el_seti,
               sap.naim_tp,
               sap.tarif_gr,
               sap.tarif_gr_d,
               to_char(null) mtr_config_id,
               to_char(null) mtr_id,
               to_date(null) receive_dt,
               to_date(null) retire_dt,
               to_char(null) manufacturer,
               to_char(null) reg_id,
               to_number(null) koef_trans,
               to_char(null) badge_nbr,
               to_char(null) serial_nbr,
               to_number(null) full_scale,
               to_date(null) val_date,
               to_char(null) val_period,
               to_char(null) amperage,
               to_char(null) voltage,
               to_char(null) precision,
               to_char(null) seal_num,
               bill.v_ee,
               bill.tou_cd,
               bill.tou_d,
               bill.sqi_cd,
               bill.bill_id,
               bill.start_dt,
               bill.end_dt,
               bill.bill_stat,
               bill.bseg_stat,
               to_char(null) start_reg_read_id,
               to_number(null) start_reg_reading,
               to_date(null) start_read_dttm,
               to_char(null) start_read_type_flg,
               to_char(null) start_read_type,
               to_char(null) start_mtr_id,
               to_char(null) start_mtr_config_id,
               to_char(null) start_mr_source,
               to_char(null) end_reg_read_id,
               to_number(null) end_reg_reading,
               to_date(null) end_read_dttm,
               to_char(null) end_read_type_flg,
               to_char(null) end_read_type,
               to_char(null) end_mtr_id,
               to_char(null) end_mtr_config_id,
               to_char(null) end_mr_source,
               to_char(null) vnorm,
               decode(sa.sa_type_cd, 'PROCHEE ', bill.v_ee) unmet_cons,
               to_number(null) final_reg_qty
          from rusadm.ci_acct         a
          left
          join (select ac.acct_id,
                       ac.adhoc_char_val   ls_shtrih
                  from rusadm.ci_acct_char  ac
                 where ac.char_type_cd = 'SHT_KOD'
                   and ac.effdt = (select max(ac2.effdt)
                                     from rusadm.ci_acct_char  ac2
                                    where ac2.acct_id = ac.acct_id
                                      and ac2.char_type_cd = ac.char_type_cd
                                      and ac2.effdt <= last_day(&pdat))) ls on a.acct_id = ls.acct_id
          left
          join (select ac.acct_id,
                       ac.adhoc_char_val   unk
                  from rusadm.ci_acct_char  ac
                 where ac.char_type_cd = 'LKKLOGIN'
                   and ac.effdt = (select max(ac2.effdt)
                                     from rusadm.ci_acct_char  ac2
                                    where ac2.acct_id = ac.acct_id
                                      and ac2.char_type_cd = ac.char_type_cd
                                      and ac2.effdt <= last_day(&pdat))) login on a.acct_id = login.acct_id
          join rusadm.ci_acct_per     ap            on a.acct_id = ap.acct_id
          join rusadm.ci_per          p             on ap.per_id = p.per_id
          join rusadm.ci_per_name     pn            on p.per_id = pn.per_id
          join rusadm.ci_sa           sa            on a.acct_id = sa.acct_id
          join (select lvl.field_value sa_status_flg,
                       lvl.descr       sa_status
                  from rusadm.ci_lookup_val_l   lvl
                 where lvl.field_name = 'SA_STATUS_FLG'
                   and lvl.language_cd = 'RUS') sa_stat          on sa.sa_status_flg = sa_stat.sa_status_flg
          join (select bsq.bill_sq v_ee,
                       bsq.sqi_cd,
                       bsq.tou_cd,
                       t.descr tou_d,
                       b.bill_id,
                       b.acct_id,
                       bs.sa_id,
                       sa.sa_type_cd,
                       bs.prem_id,
                       bs.start_dt,
                       bs.end_dt,
                       bf.bill_stat,
                       bsf.bseg_stat
                  from rusadm.ci_bill        b,
                      (select lv.field_value bill_stat_flg,
                              lv.descr       bill_stat
                         from rusadm.ci_lookup_val_l   lv
                        where lv.field_name = 'BILL_STAT_FLG'
                          and lv.language_cd = 'RUS') bf,
                       rusadm.ci_bseg        bs,
                      (select lv.field_value bseg_stat_flg,
                              lv.descr       bseg_stat
                         from rusadm.ci_lookup_val_l   lv
                        where lv.field_name = 'BSEG_STAT_FLG'
                          and lv.language_cd = 'RUS') bsf,
                       rusadm.ci_bseg_sq     bsq,
                       rusadm.ci_sa          sa,
                       rusadm.ci_tou_l       t
                 where b.bill_id = bs.bill_id
                   and bsq.bseg_id = bs.bseg_id
                   and b.bill_stat_flg = decode(&bill_stat, '-1', b.bill_stat_flg, &bill_stat)
                   and b.bill_stat_flg = bf.bill_stat_flg
                   and bs.bseg_stat_flg = decode(&bseg_stat, '-1', bs.bseg_stat_flg, &bseg_stat)
                   and bs.bseg_stat_flg = bsf.bseg_stat_flg
                   and bsq.sqi_cd in ('NORMATIV', 'CONST_VO', 'AKT')
                   and bsq.tou_cd = t.tou_cd(+)
                   and t.language_cd(+) = 'RUS'
                   and trunc(b.cre_dttm, 'mm') between &pdat and last_day(&pdat)
                   and bs.sa_id = sa.sa_id) bill on bill.acct_id = sa.acct_id and bill.sa_id = sa.sa_id
          -- left
          join (select pr.prem_id,
                       l.prem_type_cd, -- Тип объекта обслуживания
                       pr.state,
                       st.descr state_d,
                       pr.city,
                       pr.address3 street,
                       pr.address2 house,
                       pr.address4 flat,
                       l.descr                prem_type,
                       kol_kom.char_val       kol_kom,
                       kol_zare.char_val      kol_zare,
                       tip_plit.char_val      tip_plit,
                       tip_plit.char_descr    tip_plit_d,
                       tip_otop.char_val      tip_otop,
                       tip_otop.char_descr    tip_otop_d,
                       vodonagr.char_val      vodonagr,
                       vodonagr.char_descr    vodonagr_d
                  from rusadm.ci_prem           pr,
                       rusadm.ci_state_l        st,
                       rusadm.ci_prem_type_l    l,
                       (select prc.prem_id,
                               prc.char_val
                          from rusadm.ci_prem_char   prc
                         where prc.char_type_cd = 'KOL_KOM'
                           and prc.effdt = (select max(prc2.effdt)
                                              from rusadm.ci_prem_char  prc2
                                             where prc.prem_id = prc2.prem_id
                                               and prc.char_type_cd = prc2.char_type_cd
                                               and prc2.effdt < add_months(trunc(&pdat, 'mm'), 1))) kol_kom,
                       (select prc.prem_id,
                               prc.char_val
                          from rusadm.ci_prem_char   prc
                         where prc.char_type_cd = 'KOL_ZARE'
                           and prc.effdt = (select max(prc2.effdt)
                                              from rusadm.ci_prem_char  prc2
                                             where prc.prem_id = prc2.prem_id
                                               and prc.char_type_cd = prc2.char_type_cd
                                               and prc2.effdt < add_months(trunc(&pdat, 'mm'), 1))) kol_zare,
                       (select prc.prem_id,
                               prc.char_val,
                               cvl.descr char_descr
                          from rusadm.ci_prem_char   prc,
                               rusadm.ci_char_val_l  cvl
                         where prc.char_type_cd = 'TIP_PLIT'
                           and prc.effdt = (select max(prc2.effdt)
                                              from rusadm.ci_prem_char  prc2
                                             where prc.prem_id = prc2.prem_id
                                               and prc.char_type_cd = prc2.char_type_cd
                                               and prc2.effdt < add_months(trunc(&pdat, 'mm'), 1))
                           and prc.char_type_cd = cvl.char_type_cd
                           and prc.char_val = cvl.char_val
                           and cvl.language_cd = 'RUS') tip_plit,
                       (select prc.prem_id,
                               prc.char_val,
                               cvl.descr char_descr
                          from rusadm.ci_prem_char   prc,
                               rusadm.ci_char_val_l  cvl
                         where prc.char_type_cd = 'TIP_OTOP'
                           and prc.effdt = (select max(prc2.effdt)
                                              from rusadm.ci_prem_char  prc2
                                             where prc.prem_id = prc2.prem_id
                                               and prc.char_type_cd = prc2.char_type_cd
                                               and prc2.effdt < add_months(trunc(&pdat, 'mm'), 1))
                           and prc.char_type_cd = cvl.char_type_cd
                           and prc.char_val = cvl.char_val
                           and cvl.language_cd = 'RUS') tip_otop,
                       (select prc.prem_id,
                               prc.char_val,
                               cvl.descr char_descr
                          from rusadm.ci_prem_char   prc,
                               rusadm.ci_char_val_l  cvl
                         where prc.char_type_cd = 'VODONAGR'
                           and prc.effdt = (select max(prc2.effdt)
                                              from rusadm.ci_prem_char  prc2
                                             where prc.prem_id = prc2.prem_id
                                               and prc.char_type_cd = prc2.char_type_cd
                                               and prc2.effdt < add_months(trunc(&pdat, 'mm'), 1))
                           and prc.char_type_cd = cvl.char_type_cd
                           and prc.char_val = cvl.char_val
                           and cvl.language_cd = 'RUS') vodonagr
                 where pr.state = st.state(+)
                   and pr.country = st.country(+)
                   and st.language_cd(+) = 'RUS'
                   and pr.prem_type_cd = l.prem_type_cd
                   and pr.prem_type_cd not in ('MNDOM', 'PROVIDER')
                   -- Учатсвуют только частный сектор либо 
                   -- квартиры в МКД без ОДПУ
                   and not exists (select pr2.prem_id
                                     from rusadm.ci_prem    pr2,
                                          rusadm.ci_sp      sp2
                                    where pr2.prem_type_cd = 'KVMKD'
                                      and pr2.prnt_prem_id = sp2.prem_id
                                      and sp2.sp_type_cd = 'E-L-MKD'
                                      and pr2.prem_id = pr.prem_id)
                   and l.language_cd = 'RUS'
                   and pr.prem_id = kol_kom.prem_id(+)
                   and pr.prem_id = kol_zare.prem_id(+)
                   and pr.prem_id = tip_plit.prem_id(+)
                   and pr.prem_id = tip_otop.prem_id(+)
                   and pr.prem_id = vodonagr.prem_id(+))   prem on sa.char_prem_id = prem.prem_id
          -- left
          join (select sasp.sa_id,
                       sasp.start_dttm,
                       sasp.stop_dttm,
                       start_mr.start_reg_reading,
                       start_mr.start_mtr_id,
                       start_mr.start_mtr_config_id,
                       stop_mr.stop_reg_reading,
                       stop_mr.stop_mtr_id,
                       stop_mr.stop_mtr_config_id,
                       sp.sp_id,
                       sp.abolish_dt,
                       fac.descr              substantion,
                       tel_seti.el_seti,
                       tnaim_tp.naim_tp,
                       tarif_gr.char_val      tarif_gr,
                       tarif_gr.char_descr    tarif_gr_d
                  from rusadm.ci_sa_sp          sasp,
                       rusadm.ci_sp             sp,
                       rusadm.ci_fac_lvl_1_l    fac,
                       (select spc.sp_id,
                               spc.char_val,
                               cl.descr el_seti
                          from rusadm.ci_sp_char    spc,
                               rusadm.ci_char_val_l cl
                         where spc.char_type_cd = 'EL_SETI'
                           and spc.char_type_cd = cl.char_type_cd
                           and spc.char_val = cl.char_val
                           and cl.language_cd = 'RUS'
                           and spc.effdt = (select max(spc2.effdt)
                                              from rusadm.ci_sp_char   spc2
                                             where spc2.sp_id = spc.sp_id
                                               and spc2.char_type_cd = spc.char_type_cd
                                               and spc2.effdt < add_months(trunc(&pdat, 'mm'), 1))) tel_seti,
                       (select spc.sp_id,
                               spc.adhoc_char_val naim_tp
                          from rusadm.ci_sp_char    spc
                         where spc.char_type_cd = 'NAIM-TP'
                           and spc.effdt = (select max(spc2.effdt)
                                              from rusadm.ci_sp_char   spc2
                                             where spc2.sp_id = spc.sp_id
                                               and spc2.char_type_cd = spc.char_type_cd
                                               and spc2.effdt < add_months(trunc(&pdat, 'mm'), 1))) tnaim_tp,
                       (select sac.sa_id,
                               sac.char_val,
                               cvl.descr char_descr
                          from rusadm.ci_sa_char   sac,
                               rusadm.ci_char_val_l  cvl
                         where sac.char_type_cd = 'PRICE-1'
                           and sac.effdt = (select max(sac2.effdt)
                                              from rusadm.ci_sa_char  sac2
                                             where sac.sa_id = sac2.sa_id
                                               and sac.char_type_cd = sac2.char_type_cd
                                               and sac2.effdt < add_months(trunc(&pdat, 'mm'), 1))
                           and sac.char_type_cd = cvl.char_type_cd
                           and sac.char_val = cvl.char_val
                           and cvl.language_cd = 'RUS') tarif_gr,
                       (select mr.mr_id,
                               mr.mr_source_cd,
                               mr.read_dttm,
                               rr.reg_reading       start_reg_reading,
                               rr.read_type_flg,
                               r.mtr_id             start_mtr_id,
                               mr.mtr_config_id     start_mtr_config_id
                          from rusadm.ci_mr             mr,
                               rusadm.ci_reg_read       rr,
                               rusadm.ci_reg            r
                         where mr.mr_id = rr.mr_id
                           and rr.reg_id = r.reg_id)     start_mr,
                       (select mr.mr_id,
                               mr.mr_source_cd,
                               mr.read_dttm,
                               rr.reg_reading       stop_reg_reading,
                               rr.read_type_flg,
                               r.mtr_id             stop_mtr_id,
                               mr.mtr_config_id     stop_mtr_config_id
                          from rusadm.ci_mr             mr,
                               rusadm.ci_reg_read       rr,
                               rusadm.ci_reg            r
                         where mr.mr_id = rr.mr_id
                           and rr.reg_id = r.reg_id)     stop_mr
                 where sasp.sp_id = sp.sp_id
                   /*and not (sasp.start_dttm >= add_months(trunc(&pdat, 'mm'), 1) or
                            nvl(sasp.stop_dttm, to_date('3000', 'yyyy')) <= trunc(&pdat, 'mm'))
                   and not (sp.install_dt >= add_months(trunc(&pdat, 'mm'), 1) or
                            nvl(sp.abolish_dt, to_date('3000', 'yyyy')) <= trunc(&pdat, 'mm'))*/
                   and (tel_seti.char_val is null or
                        tel_seti.char_val = 'TCO')
                   and sp.sp_type_cd in ('E-GTU', 'E-GTU-S', 'NO-PU')
                   and sp.fac_lvl_1_cd = fac.fac_lvl_1_cd(+)
                   and fac.language_cd(+) = 'RUS'
                   and sp.sp_id = tel_seti.sp_id(+)
                   and sp.sp_id = tnaim_tp.sp_id(+)
                   and sasp.sa_id = tarif_gr.sa_id(+)
                   and sasp.start_mr_id = start_mr.mr_id(+)
                   and sasp.stop_mr_id = stop_mr.mr_id(+)) sap on sa.sa_id = sap.sa_id /*and (sap.stop_dttm is null or sap.stop_dttm > bill.start_dt)*/
         where a.cis_division = &cis_division
           and p.per_or_bus_flg = 'P'
           and pn.prim_name_sw = 'Y'
           and sa.sa_type_cd != 'PROCHEE'
           and sa.sa_status_flg < 60
           /*and not (sa.start_dt >= add_months(trunc(&pdat, 'mm'), 1) or
                        nvl(sa.end_dt, to_date('3000', 'yyyy')) <= trunc(&pdat, 'mm'))*/) al
-- where al.unk = '1135488'
;

insert into lcmccb.cm_slice_lesk_data
select distinct
       &pdat dttm,
       al.state,
       al.cis_division,
       nvl2(trim(al.state), al.state_d, 'ГЭСК')     r_on_text,
       case
         when length(al.ls_shtrih) > 21 then
           substr(al.ls_shtrih, 1, 21)
         else
           al.ls_shtrih
       end ls_shtrih,
       al.sp_id,
       al.abolish_dt,
       al.name_klient fio,
       al.city,
       al.street,
       al.house,
       al.flat,
       al.naim_tp,
       al.serial_nbr,
       al.val_date,
       al.val_period,
       al.start_dt,
       al.end_dt,
       al.start_reg_read_id,
       case
         when al.start_read_type_flg != '30' then
           al.start_reg_reading
       end start_reg_reading,
       case
         when al.start_read_type_flg != '30' then
           al.start_read_dttm
       end start_read_dttm,
       al.start_read_type_flg,
       al.start_read_type,
       al.end_reg_read_id,
       case
         when al.end_read_type_flg != '30' then
           al.end_reg_reading
       end end_reg_reading,
       case
         when al.end_read_type_flg != '30' then
           al.end_read_dttm
       end end_read_dttm,
       al.end_read_type_flg,
       al.end_read_type,
       al.koef_trans,
       al.sa_status_flg,
       al.sa_status,
       case
         when al.norm = 'NOTNORM' and al.end_read_type_flg != '30' then
           round(al.final_reg_qty)
       end v_ee_mtr,
       case
         when al.norm = 'NORM' and al.sqi_cd in ('NORMATIV', 'CONST_VO') then
           round(al.v_ee)
       end v_norm,
       case
         when al.norm = 'NOTNORM' and
              al.end_read_type_flg = '30' and
              al.vnorm is null then
           round(al.v_ee)
       end ras_vel_med,
       case
         when al.norm = 'NOTNORM' and
              al.end_read_type_flg = '30' and
              al.vnorm is not null then
           round(al.v_ee)
       end ras_vel_norm,
       round(al.unmet_cons) unmet_cons,
       round(al.v_ee) v_ee_all,
       al.kol_zare,
       al.kol_kom,
       al.tip_plit,
       al.tip_plit_d,
       al.tip_otop,
       al.tip_otop_d,
       al.vodonagr,
       al.vodonagr_d,
       al.tarif_gr,
       al.old_ls,
       al.bill_id,
       al.el_seti,
       al.sp_start_dt,
       al.sp_stop_dt,
       al.sp_start_reg_reading,
       al.sp_stop_reg_reading,
       al.prem_type,
       al.tou_cd,
       al.acct_id,
       al.receive_dt,
       al.retire_dt,
       al.manufacturer,
       al.amperage,
       al.voltage,
       al.precision,
       al.seal_num,
       al.substantion,
       al.sa_id,
       al.tou_d,
       al.unk,
       al.start_mr_source,
       al.end_mr_source,
       al.per_id,
       al.bill_stat,
       al.bseg_stat
  from (select 'NORM' norm,
               trunc(&pdat, 'mm') dttm,
               to_char(trunc(&pdat, 'mm'), 'month') mes,
               to_char(trunc(&pdat, 'mm'), 'yyyy') god,
               substr(ls.ls_shtrih, 2, 6) r_on,
               a.acct_id,
               p.per_id,
               pn.entity_name name_klient,
               sa.sa_id,
               sa.sa_type_cd,
               sa.old_acct_id old_ls,
               sa.cis_division,
               sa.sa_status_flg,
               sa_stat.sa_status,
               ls.ls_shtrih,
               login.unk,
               to_char(null) prem_id,
               to_char(null) prem_type_cd,
              (select pr2.state
                 from rusadm.ci_prem pr2
                where a.mailing_prem_id = pr2.prem_id) state,
              (select s2.descr
                 from rusadm.ci_prem pr2,
                      rusadm.ci_state_l s2
                where a.mailing_prem_id = pr2.prem_id
                  and pr2.state = s2.state
                  and s2.language_cd = 'RUS') state_d,
               to_char(null) city,
               to_char(null) street,
               to_char(null) house,
               to_char(null) flat,
               to_char(null) prem_type,
               to_char(null) kol_kom,
               to_char(null) kol_zare,
               to_char(null) tip_plit,
               to_char(null) tip_plit_d,
               to_char(null) tip_otop,
               to_char(null) tip_otop_d,
               to_char(null) vodonagr,
               to_char(null) vodonagr_d,
               to_date(null) sp_start_dt,
               to_date(null) sp_stop_dt,
               to_number(null) sp_start_reg_reading,
               to_number(null) sp_stop_reg_reading,
               to_char(null) sp_start_mtr_id,
               to_char(null) sp_start_mtr_config_id,
               to_char(null) sp_stop_mtr_id,
               to_char(null) sp_stop_mtr_config_id,
               to_char(null) sp_id,
               to_date(null) abolish_dt,
               to_char(null) substantion,
               to_char(null) el_seti,
               to_char(null) naim_tp,
               to_char(null) tarif_gr,
               to_char(null) tarif_gr_d,
               to_char(null) mtr_config_id,
               to_char(null) mtr_id,
               to_date(null) receive_dt,
               to_date(null) retire_dt,
               to_char(null) manufacturer,
               to_char(null) reg_id,
               to_number(null) koef_trans,
               to_char(null) badge_nbr,
               to_char(null) serial_nbr,
               to_number(null) full_scale,
               to_date(null) val_date,
               to_char(null) val_period,
               to_char(null) amperage,
               to_char(null) voltage,
               to_char(null) precision,
               to_char(null) seal_num,
               bill.v_ee,
               bill.tou_cd,
               bill.tou_d,
               bill.sqi_cd,
               bill.bill_id,
               bill.start_dt,
               bill.end_dt,
               bill.bill_stat,
               bill.bseg_stat,
               to_char(null) start_reg_read_id,
               to_number(null) start_reg_reading,
               to_date(null) start_read_dttm,
               to_char(null) start_read_type_flg,
               to_char(null) start_read_type,
               to_char(null) start_mtr_id,
               to_char(null) start_mtr_config_id,
               to_char(null) start_mr_source,
               to_char(null) end_reg_read_id,
               to_number(null) end_reg_reading,
               to_date(null) end_read_dttm,
               to_char(null) end_read_type_flg,
               to_char(null) end_read_type,
               to_char(null) end_mtr_id,
               to_char(null) end_mtr_config_id,
               to_char(null) end_mr_source,
               to_char(null) vnorm,
               decode(sa.sa_type_cd, 'PROCHEE ', bill.v_ee) unmet_cons,
               to_number(null) final_reg_qty
          from rusadm.ci_acct         a
          left
          join (select ac.acct_id,
                       ac.adhoc_char_val   ls_shtrih
                  from rusadm.ci_acct_char  ac
                 where ac.char_type_cd = 'SHT_KOD'
                   and ac.effdt = (select max(ac2.effdt)
                                     from rusadm.ci_acct_char  ac2
                                    where ac2.acct_id = ac.acct_id
                                      and ac2.char_type_cd = ac.char_type_cd
                                      and ac2.effdt <= last_day(&pdat))) ls on a.acct_id = ls.acct_id
          left
          join (select ac.acct_id,
                       ac.adhoc_char_val   unk
                  from rusadm.ci_acct_char  ac
                 where ac.char_type_cd = 'LKKLOGIN'
                   and ac.effdt = (select max(ac2.effdt)
                                     from rusadm.ci_acct_char  ac2
                                    where ac2.acct_id = ac.acct_id
                                      and ac2.char_type_cd = ac.char_type_cd
                                      and ac2.effdt <= last_day(&pdat))) login on a.acct_id = login.acct_id
          join rusadm.ci_acct_per     ap            on a.acct_id = ap.acct_id
          join rusadm.ci_per          p             on ap.per_id = p.per_id
          join rusadm.ci_per_name     pn            on p.per_id = pn.per_id
          join rusadm.ci_sa           sa            on a.acct_id = sa.acct_id
          join (select lvl.field_value sa_status_flg,
                       lvl.descr       sa_status
                  from rusadm.ci_lookup_val_l   lvl
                 where lvl.field_name = 'SA_STATUS_FLG'
                   and lvl.language_cd = 'RUS') sa_stat          on sa.sa_status_flg = sa_stat.sa_status_flg
          join (select bsq.bill_sq v_ee,
                       bsq.sqi_cd,
                       bsq.tou_cd,
                       t.descr tou_d,
                       b.bill_id,
                       b.acct_id,
                       bs.sa_id,
                       sa.sa_type_cd,
                       bs.prem_id,
                       bs.start_dt,
                       bs.end_dt,
                       bf.bill_stat,
                       bsf.bseg_stat
                  from rusadm.ci_bill        b,
                      (select lv.field_value bill_stat_flg,
                              lv.descr       bill_stat
                         from rusadm.ci_lookup_val_l   lv
                        where lv.field_name = 'BILL_STAT_FLG'
                          and lv.language_cd = 'RUS') bf,
                       rusadm.ci_bseg        bs,
                      (select lv.field_value bseg_stat_flg,
                              lv.descr       bseg_stat
                         from rusadm.ci_lookup_val_l   lv
                        where lv.field_name = 'BSEG_STAT_FLG'
                          and lv.language_cd = 'RUS') bsf,
                       rusadm.ci_bseg_sq     bsq,
                       rusadm.ci_sa          sa,
                       rusadm.ci_tou_l       t
                 where b.bill_id = bs.bill_id
                   and bsq.bseg_id = bs.bseg_id
                   and b.bill_stat_flg = decode(&bill_stat, '-1', b.bill_stat_flg, &bill_stat)
                   and b.bill_stat_flg = bf.bill_stat_flg
                   and bs.bseg_stat_flg = decode(&bseg_stat, '-1', bs.bseg_stat_flg, &bseg_stat)
                   and bs.bseg_stat_flg = bsf.bseg_stat_flg
                   and bsq.sqi_cd in ('NORMATIV', 'CONST_VO', 'AKT')
                   and bsq.tou_cd = t.tou_cd(+)
                   and t.language_cd(+) = 'RUS'
                   and trunc(b.cre_dttm, 'mm') between &pdat and last_day(&pdat)
                   and bs.sa_id = sa.sa_id) bill on bill.acct_id = sa.acct_id and bill.sa_id = sa.sa_id
         where a.cis_division = &cis_division
           and p.per_or_bus_flg = 'P'
           and pn.prim_name_sw = 'Y'
           and sa.sa_type_cd = 'PROCHEE'
           and sa.sa_status_flg != 70
           /*and not (sa.start_dt >= add_months(trunc(&pdat, 'mm'), 1) or
                        nvl(sa.end_dt, to_date('3000', 'yyyy')) <= trunc(&pdat, 'mm'))*/) al
-- where al.unk = '1135488'
;

commit;

select distinct
       al.dttm                                  as "Дата",
       to_char(al.dttm, 'month',
              'NLS_DATE_LANGUAGE=RUSSIAN')      as "месяц",
       to_char(al.dttm, 'yyyy')                 as "год",
       al.r_on,
       al.cis_division,
       al.r_on_text                             as "Район",
       al.ls_shtrih                             as "Штрих код",
       al.old_ls                                as "Старый ЛС",
       al.unk                                   as "УНК",
       al.per_id                                as "ID субъекта",
       al.sp_id                                 as "ID ТУ",
       al.fio                                   as "ФИО",
       al.city                                  as "Нас. пункт",
       al.street                                as "Улица",
       al.house                                 as "Дом",
       al.flat                                  as "Квартира",
       al.serial_nbr                            as "Серийный номер ПУ",
       al.tou_d                                 as "Зонность регистра",
       al.start_read_dttm                       as "Дата пред. показаний ПУ",
       al.start_reg_reading                     as "Пред. показания ПУ",
       al.start_read_type                       as "Тип пред. показаний",
       al.start_mr_source                       as "Источник пред. показаний",
       al.end_read_dttm                         as "Дата посл. показаний ПУ",
       al.end_reg_reading                       as "Посл. показания ПУ",
       al.end_read_type                         as "Тип посл. показаний ПУ",
       al.end_mr_source                         as "Источник посл. показаний",
       al.koef_trans                            as "Коэф. трансформации",
       al.v_ee_mtr                              as "Объём э/э по ПУ",
       al.ras_vel_med                           as "Системный расчёт (средн.)",
       al.ras_vel_norm                          as "Системный расчёт (норм.)",
       al.v_norm                                as "Объём э/э по нормативу",
       al.unmet_cons                            as "Объём по акту безучётного потр",
       round(al.v_ee_all)                       as "Объём э/э ИТОГО",
       al.tarif_gr                              as "Тариф. группа",
       al.prem_type                             as "Тип объекта обслуживания",
       al.kol_zare                              as "Кол. зарегистрированных",
       al.kol_kom                               as "Кол. комнат",
       al.tip_plit                              as "Тип плит",
       al.bill_stat                             as "Статус счёта",
       al.bseg_stat                             as "Статус сегмента счёта"
  from lcmccb.cm_slice_lesk_data al
 where al.dttm = &pdat
   and trim(al.cis_division) = &cis_division;

