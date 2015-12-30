
delete 
  from lcmccb.cm_slice_match where dttm = &pdat;

insert into lcmccb.cm_slice_match
select q.dttm,
       q.r_on_text,
       q.ls_shtrih,
       q.sp_id,
       q.acct_id,
       q.fio,
       q.city,
       q.street,
       q.house,
       q.flat,
       q.kol_kom,
       q.kol_zare,
       q.tip_plit,
       q.tip_plit_d,
       q.tip_otop,
       q.tip_otop_d,
       q.vodonagr,
       q.vodonagr_d,
       q.start_dt,
       q.end_dt,
       q.start_reg_reading,
       q.start_read_dttm,
       q.end_reg_reading,
       q.end_read_dttm,
       sum(q.v_ee_mtr),
       sum(q.v_norm_lesk),
       q.v_norm_mrsk,
       sum(q.ras_vel_med),
       sum(q.ras_vel_norm),
       sum(q.unmet_cons),
       q.v_ee_lesk,
       q.v_ee_mrsk,
       q.v_ee_mrsk -
       q.v_ee_lesk v_pret,
       case
         when q.v_ee_mrsk - q.v_ee_lesk = 0 then
           'Разногласий нет'
         when q.v_ee_lesk = sum(q.unmet_cons) then
           'Безучётное потребление'
         when q.abolish_dt is not null and
              trunc(q.abolish_dt) between &pdat and last_day(&pdat) then
           'Разногласие из-за ограничения ТУ'
         when sum(q.ras_vel_med) is not null then
           'Расчётный способ (по среднемесячному)'
         when sum(q.ras_vel_norm) is not null then
           'Расчётный способ (по нормативу)'
         when min(q.read_type) != '30' or q.end_reg_reading is not null then
           'Разногласие в показаниях ПУ'
         when sum(q.v_norm_lesk) - sum(q.v_norm_mrsk) != 0
          and q.serial_nbr is null then
           'Разногласие по нормативу'
       end type_raznog,
       (select cv.descr
          from rusadm.ci_char_val_l cv
         where cv.char_type_cd = 'PRICE-1'
           and cv.language_cd = 'RUS'
           and cv.char_val = q.tarif_gr) tarif_gr_lesk,
       case
         when q.klnaprpotu like '%сельское%' then
           'село'
         when q.klnaprpotu like '%городское с эл.плитами%' then
           'город с эл. плитами'
         when q.klnaprpotu like '%городское в домах с газ. и др. плитами%' then
           'город без эл. плит'
         else
           null
       end tarif_gr_mrsk,
       case
         when q.klnaprpotu like '%городское в домах с газ. и др. плитами%' 
          and trim(q.tarif_gr) in ('СЕЛО', 'СЕЛО_ДН', 'СЕЛО_НЧ')
           or q.klnaprpotu like '%городское в домах с газ. и др. плитами%'
          and trim(q.tarif_gr) in ('ГОРОД_ЭЛ_ПЛ', 'ГОР_ДН_ЭП', 'ГОР_НЧ_ЭП') then
             '+'
         when q.klnaprpotu like '%городское с эл.плитами%'
          and trim(q.tarif_gr) not in ('ГОРОД_ЭЛ_ПЛ', 'ГОР_ДН_ЭП', 'ГОР_НЧ_ЭП')
           or q.klnaprpotu like '%сельское%'
          and trim(q.tarif_gr) in ('ГОРОД_ЭЛ_ПЛ', 'ГОР_ДН_ЭП', 'ГОР_НЧ_ЭП') then
             '-'
         else
           null
       end tarif_gr_pret,
       q.serial_nbr,
       q.sernomsch,
       q.prem_type,
       q.el_seti,
       q.sp_stop_dt,
       q.sp_stop_reg_reading,
       q.bill_id,
       q.abolish_dt,
       q.r_on,
       q.cis_division,
       q.aktyneuchpotr,
       q.start_mr_source,
       q.end_mr_source,
       round(fcm_to_number(q.poknachrper)),
       q.datenach,
       round(fcm_to_number(q.pokkonrper)),
       q.dateokonch,
       fcm_to_number(q.raschkoef),
       q.start_read_type,
       q.end_read_type
    from (select decode(row_number() over(partition by iccb.id order by 1),
                      1,
                      1,
                      0) k,
               decode(row_number() over(partition by imrsk.id order by 1),
                      1,
                      1,
                      0) l,
               iccb.*,
               imrsk.*
          from (select distinct
                       ccb.rowid as id,
                       ccb.dttm,
                       ccb.cis_division,
                       ccb.r_on,
                       ccb.sp_id,
                       ccb.acct_id,
                       ccb.fio,
                       ccb.ls_shtrih,
                       ccb.serial_nbr,
                       ccb.r_on_text,
                       ccb.v_ee_mtr,
                       ccb.ras_vel_med,
                       ccb.ras_vel_norm,
                       ccb.start_dt,
                       ccb.end_dt,
                       ccb.start_reg_reading,
                       ccb.start_read_dttm,
                       ccb.start_mr_source,
                       ccb.end_reg_reading,
                       ccb.end_read_dttm,
                       ccb.end_mr_source,
                       sum(nvl(ccb.v_ee_all, 0)) over (partition by ccb.ls_shtrih, ccb.serial_nbr) v_ee_lesk,
                       sum(nvl(ccb.v_norm, 0)) over (partition by ccb.ls_shtrih) v_norm_lesk,
                       ccb.end_read_type_flg read_type,
                       ccb.unmet_cons,
                       ccb.tarif_gr,
                       ccb.kol_kom,
                       ccb.kol_zare,
                       ccb.tip_plit,
                       ccb.tip_plit_d,
                       ccb.tip_otop,
                       ccb.tip_otop_d,
                       ccb.vodonagr,
                       ccb.vodonagr_d,
                       ccb.abolish_dt,
                       ccb.sp_stop_dt,
                       ccb.sp_stop_reg_reading,
                       ccb.prem_type,
                       ccb.el_seti,
                       ccb.bill_id,
                       ccb.start_read_type,
                       ccb.end_read_type
                  from lcmccb.cm_slice_lesk_data    ccb
                 where ccb.dttm = &pdat) iccb,
               (select distinct
                       mrsk.rowid as id,
                       mrsk.shtrihkod,
                       mrsk.sernomsch,
                       mrsk.city,
                       mrsk.street,
                       mrsk.house,
                       mrsk.flat,
                       sum(nvl(fcm_to_number(mrsk.koleevtochpost), 0)) over (partition by mrsk.datezagr,
                                                                                          mrsk.shtrihkod,
                                                                                          mrsk.sernomsch)   v_ee_mrsk,
                       sum(nvl(fcm_to_number(mrsk.rashponormativu), 0)) over (partition by mrsk.datezagr,
                                                                                          mrsk.shtrihkod,
                                                                                          mrsk.sernomsch)  v_norm_mrsk,
                       mrsk.naimgrpotr,
                       mrsk.klnaprpotu,
                       mrsk.aktyneuchpotr,
                       mrsk.poknachrper,
                       mrsk.datenach,
                       mrsk.pokkonrper,
                       mrsk.dateokonch,
                       mrsk.raschkoef
                  from cm_lesk_mrsk_sverka          mrsk
                 where mrsk.datezagr = &pdat) imrsk
         where iccb.ls_shtrih = imrsk.shtrihkod
           and ltrim(nvl(iccb.serial_nbr, '-1'), '0') = nvl(ltrim(ltrim(ltrim(imrsk.sernomsch, '_'), '*'), '0'), '-1')
           ) q
 where k = l
  group by q.dttm,
          q.r_on_text,
          q.ls_shtrih,
          q.sp_id,
          q.acct_id,
          q.fio,
          q.city,
          q.street,
          q.house,
          q.flat,
          q.kol_kom,
          q.kol_zare,
          q.tip_plit,
          q.tip_plit_d,
          q.tip_otop,
          q.tip_otop_d,
          q.vodonagr,
          q.vodonagr_d,
          q.start_dt,
          q.end_dt,
          q.start_reg_reading,
          q.start_read_dttm,
          q.end_reg_reading,
          q.end_read_dttm,
          q.v_norm_mrsk,
          q.v_ee_lesk,
          q.v_ee_mrsk,
          q.v_ee_mrsk - q.v_ee_lesk,
          q.tarif_gr,
          q.tip_plit,
          q.klnaprpotu,
          q.serial_nbr,
          q.sernomsch,
          q.prem_type,
          q.el_seti,
          q.abolish_dt,
          q.sp_stop_dt,
          q.sp_stop_reg_reading,
          q.bill_id,
          q.r_on,
          q.cis_division,
          q.aktyneuchpotr,
          q.start_mr_source,
          q.end_mr_source,
          q.poknachrper,
          q.datenach,
          q.pokkonrper,
          q.dateokonch,
          q.raschkoef,
          q.start_read_type,
          q.end_read_type,
          k,
          l;

delete from lcmccb.cm_slice_notmatch where dttm = &pdat;

insert into lcmccb.cm_slice_notmatch
select 
       q.dttm,
       q.r_on_text,
       q.ls_shtrih,
       q.sp_id,
       q.acct_id,
       q.fio,
       q.city,
       q.street,
       q.house,
       q.flat,
       q.kol_kom,
       q.kol_zare,
       q.tip_plit,
       q.tip_plit_d,
       q.tip_otop,
       q.tip_otop_d,
       q.vodonagr,
       q.vodonagr_d,
       q.start_dt,
       q.end_dt,
       q.start_reg_reading,
       q.start_read_dttm,
       q.end_reg_reading,
       q.end_read_dttm,
       sum(q.v_ee_mtr * k),
       sum(q.v_norm_lesk * k),
       q.v_norm_mrsk * l,
       sum(q.ras_vel_med * k),
       sum(q.ras_vel_norm * k),
       sum(q.unmet_cons * k),
       q.v_ee_lesk * k,
       q.v_ee_mrsk * l,
       q.v_ee_mrsk * l - q.v_ee_lesk * k   v_pret,
       case
         when q.v_ee_mrsk * l - q.v_ee_lesk * k = 0 then
          'Разногласий нет'
         when q.v_ee_lesk = sum(q.unmet_cons) then
          'Безучётное потребление'
         when q.abolish_dt is not null and trunc(q.abolish_dt) between &pdat and
              last_day(&pdat) then
          'Разногласие из-за ограничения ТУ'
         when sum(q.ras_vel_med) is not null then
           'Расчётный способ (по среднемесячному)'
         when sum(q.ras_vel_norm) is not null then
           'Расчётный способ (по нормативу)'
         when min(q.read_type) != '30' or q.end_reg_reading is not null then
           'Разногласие в показаниях ПУ'
         when sum(q.v_norm_lesk * k) - sum(q.v_norm_mrsk * l) != 0 and
              q.serial_nbr is null then
          'Разногласие по нормативу'
       end type_raznog,
       (select cv.descr
          from rusadm.ci_char_val_l cv
         where cv.char_type_cd = 'PRICE-1'
           and cv.language_cd = 'RUS'
           and cv.char_val = q.tarif_gr) tarif_gr_lesk,
       case
         when q.klnaprpotu like '%сельское%' then
           'село'
         when q.klnaprpotu like '%городское с эл.плитами%' then
           'город с эл. плитами'
         when q.klnaprpotu like '%городское в домах с газ. и др. плитами%' then
           'город без эл. плит'
         else
           null
       end tarif_gr_mrsk,
       case
         when q.klnaprpotu like '%городское в домах с газ. и др. плитами%' 
          and trim(q.tarif_gr) in ('СЕЛО', 'СЕЛО_ДН', 'СЕЛО_НЧ')
           or q.klnaprpotu like '%городское в домах с газ. и др. плитами%'
          and trim(q.tarif_gr) in ('ГОРОД_ЭЛ_ПЛ', 'ГОР_ДН_ЭП', 'ГОР_НЧ_ЭП') then
             '+'
         when q.klnaprpotu like '%городское с эл.плитами%'
          and trim(q.tarif_gr) not in ('ГОРОД_ЭЛ_ПЛ', 'ГОР_ДН_ЭП', 'ГОР_НЧ_ЭП')
           or q.klnaprpotu like '%сельское%'
          and trim(q.tarif_gr) in ('ГОРОД_ЭЛ_ПЛ', 'ГОР_ДН_ЭП', 'ГОР_НЧ_ЭП') then
             '-'
         else
           null
       end tarif_gr_pret,
       q.serial_nbr,
       q.sernomsch,
       q.prem_type,
       q.el_seti,
       q.sp_stop_dt,
       q.sp_stop_reg_reading,
       q.bill_id,
       q.abolish_dt,
       q.r_on,
       q.cis_division,
       q.aktyneuchpotr,
       q.start_mr_source,
       q.end_mr_source,
       round(fcm_to_number(q.poknachrper)),
       q.datenach,
       round(fcm_to_number(q.pokkonrper)),
       q.dateokonch,
       fcm_to_number(q.raschkoef),
       q.start_read_type,
       q.end_read_type
  from (select decode(row_number() over(partition by iccb.id order by 1),
                      1,
                      1,
                      0) k,
               decode(row_number() over(partition by imrsk.id order by 1),
                      1,
                      1,
                      0) l,
               iccb.*,
               imrsk.*
          from (select
                       ccb.rowid as id,
                       ccb.dttm,
                       ccb.cis_division,
                       ccb.r_on,
                       ccb.sp_id,
                       ccb.acct_id,
                       ccb.fio,
                       ccb.ls_shtrih,
                       ccb.serial_nbr,
                       ccb.r_on_text,
                       ccb.v_ee_mtr,
                       ccb.ras_vel_med,
                       ccb.ras_vel_norm,
                       ccb.start_dt,
                       ccb.end_dt,
                       ccb.start_reg_reading,
                       ccb.start_read_dttm,
                       ccb.start_mr_source,
                       ccb.end_reg_reading,
                       ccb.end_read_dttm,
                       ccb.end_mr_source,
                       sum(nvl(ccb.v_ee_all, 0)) over(partition by ccb.ls_shtrih, ccb.serial_nbr) v_ee_lesk,
                       sum(nvl(ccb.v_norm, 0)) over(partition by ccb.ls_shtrih) v_norm_lesk,
                       ccb.end_read_type_flg read_type,
                       ccb.unmet_cons,
                       ccb.tarif_gr,
                       ccb.kol_kom,
                       ccb.kol_zare,
                       ccb.tip_plit,
                       ccb.tip_plit_d,
                       ccb.tip_otop,
                       ccb.tip_otop_d,
                       ccb.vodonagr,
                       ccb.vodonagr_d,
                       ccb.abolish_dt,
                       ccb.sp_stop_dt,
                       ccb.sp_stop_reg_reading,
                       ccb.prem_type,
                       ccb.el_seti,
                       ccb.bill_id,
                       ccb.start_read_type,
                       ccb.end_read_type
                  from lcmccb.cm_slice_lesk_data ccb
                 where ccb.dttm = &pdat
                   and not exists (select null
                                     from lcmccb.cm_slice_match m
                                    where m.ls_shtrih = ccb.ls_shtrih
                                      and nvl(m.serial_nbr, '-1') = nvl(ccb.serial_nbr, '-1'))) iccb,
               (select distinct
                       mrsk.rowid as id,
                       mrsk.shtrihkod,
                       mrsk.sernomsch,
                       mrsk.firstname || ' ' || mrsk.secondname || ' ' ||
                       mrsk.otchestvo as mrsk_fio,
                       mrsk.city,
                       mrsk.street,
                       mrsk.house,
                       mrsk.flat,
                       sum(nvl(fcm_to_number(mrsk.koleevtochpost), 0))
                             over(partition by mrsk.datezagr, mrsk.shtrihkod, mrsk.sernomsch) v_ee_mrsk,
                       sum(nvl(fcm_to_number(mrsk.rashponormativu), 0))
                             over(partition by mrsk.datezagr, mrsk.shtrihkod, mrsk.sernomsch) v_norm_mrsk,
                       mrsk.naimgrpotr,
                       mrsk.klnaprpotu,
                       mrsk.aktyneuchpotr,
                       mrsk.poknachrper,
                       mrsk.datenach,
                       mrsk.pokkonrper,
                       mrsk.dateokonch,
                       mrsk.raschkoef
                  from cm_lesk_mrsk_sverka mrsk
                 where mrsk.datezagr = &pdat
                   and not exists (select null
                                     from lcmccb.cm_slice_match m
                                    where m.ls_shtrih = mrsk.shtrihkod
                                      and nvl(m.sernomsch, '-1') = nvl(mrsk.sernomsch, '-1'))) imrsk
         where iccb.ls_shtrih = imrsk.shtrihkod
           and ltrim(nvl(iccb.serial_nbr, '-1'), '0') !=
               nvl(ltrim(ltrim(ltrim(imrsk.sernomsch, '_'), '*'), '0'), '-1')
           and not exists
         (select null
                  from lcmccb.cm_slice_match m
                 where m.ls_shtrih = iccb.ls_shtrih
                   and nvl(m.serial_nbr, '-1') = nvl(iccb.serial_nbr, '-1'))
           and not exists
         (select null
                  from lcmccb.cm_slice_match m
                 where m.ls_shtrih = imrsk.shtrihkod
                   and nvl(m.sernomsch, '-1') = nvl(imrsk.sernomsch, '-1'))) q
 where k = l
 group by q.dttm,
          q.r_on_text,
          q.ls_shtrih,
          q.sp_id,
          q.acct_id,
          q.fio,
          q.city,
          q.street,
          q.house,
          q.flat,
          q.kol_kom,
          q.kol_zare,
          q.tip_plit,
          q.tip_plit_d,
          q.tip_otop,
          q.tip_otop_d,
          q.vodonagr,
          q.vodonagr_d,
          q.start_dt,
          q.end_dt,
          q.start_reg_reading,
          q.start_read_dttm,
          q.end_reg_reading,
          q.end_read_dttm,
          q.v_norm_mrsk,
          q.v_ee_lesk,
          q.v_ee_mrsk,
          q.v_ee_mrsk - q.v_ee_lesk,
          q.tarif_gr,
          q.tip_plit,
          q.klnaprpotu,
          q.serial_nbr,
          q.sernomsch,
          q.prem_type,
          q.el_seti,
          q.abolish_dt,
          q.sp_stop_dt,
          q.sp_stop_reg_reading,
          q.bill_id,
          q.r_on,
          q.cis_division,
          q.aktyneuchpotr,
          q.start_mr_source,
          q.end_mr_source,
          q.poknachrper,
          q.datenach,
          q.pokkonrper,
          q.dateokonch,
          q.raschkoef,
          q.start_read_type,
          q.end_read_type,
          k,
          l;


delete from lcmccb.cm_slice_notfound_in_lesk where dttm = &pdat;

insert into lcmccb.cm_slice_notfound_in_lesk
select &pdat dttm,
       imrsk.district r_on_text,
       imrsk.shtrihkod ls_shtrih,
       el_seti.sp_id,
       case
         when sa.acct_id is null then
           el_seti.acct_id
         else
           sa.acct_id
       end acct_id,
       imrsk.fio,
       imrsk.city,
       imrsk.street,
       imrsk.house,
       imrsk.flat,
       prem.kol_kom,
       prem.kol_zare,
       prem.tip_plit,
       prem.tip_plit_d,
       prem.tip_otop,
       prem.tip_otop_d,
       prem.vodonagr,
       prem.vodonagr_d,
       bill.start_dt,
       bill.end_dt,
       bill.start_reg_reading,
       bill.start_read_dttm,
       bill.end_reg_reading,
       bill.end_read_dttm,
       case
         when bill.end_read_type_flg != '30' then
           nvl(bill.v_ee_mtr, 0)
         else
           0
       end v_ee_mtr,
       nvl(bill.v_norm_lesk, 0) v_norm_lesk,
       imrsk.v_norm_mrsk,
       case
         when bill.end_read_type_flg = '30' and
              bill.vnorm is null then
           round(nvl(bill.v_ee_mtr, 0))
         else
           0
       end ras_vel_med,
       case
         when bill.end_read_type_flg = '30' and
              bill.vnorm is not null then
           round(nvl(bill.v_ee_mtr, 0))
         else
           0
       end ras_vel_norm,
       nvl(bill.unmet_cons, 0) unmet_cons,
       nvl(bill.v_ee_lesk, 0) v_ee_lesk,
       nvl(imrsk.v_ee_mrsk, 0) v_ee_mrsk,
       nvl(imrsk.v_ee_mrsk, 0) -
       nvl(bill.v_ee_lesk, 0) v_pret,
       case
         when imrsk.shtrihkod is null then
           'Невозможно найти абонента (отсутствует штрихкод)'
         when length(imrsk.shtrihkod) != 21 then
           'Невозможно найти абонента (некорректный штрихкод)'
         when bill.bill_id is null then
           case
             when not exists (select null
                                from rusadm.ci_sa    isa
                               where isa.acct_id = el_seti.acct_id
                                 and isa.sa_status_flg = '20') then
               'Отсутствует активный РДО'
             else
               'Не выставлен счёт в ЛЭСК'
           end
         when sa.ls_shtrih is null then
           'Бездоговорное потребление (нет РДО в ЛЭСК)'
         when el_seti.seti_cd != 'TCO' then
           'ТУ не принадлежит сети МРСК'
         when el_seti.sp_id is null then
           'Бездоговорное потребление (нет ТУ в ЛЭСК)'
         else
           'Клиент отсутствует в выгрузке данных ЛЭСК'
       end type_raznog,
       sa.tarif_gr_d tarif_gr_lesk,
       case
         when imrsk.klnaprpotu like '%сельское%' then
           'село'
         when imrsk.klnaprpotu like '%городское с эл.плитами%' then
           'город с эл. плитами'
         when imrsk.klnaprpotu like '%городское в домах с газ. и др. плитами%' then
           'город без эл. плит'
         else
           null
       end tarif_gr_mrsk,
       case
         when imrsk.klnaprpotu like '%городское в домах с газ. и др. плитами%' 
          and trim(sa.tarif_gr) in ('СЕЛО', 'СЕЛО_ДН', 'СЕЛО_НЧ')
           or imrsk.klnaprpotu like '%городское в домах с газ. и др. плитами%'
          and trim(sa.tarif_gr) in ('ГОРОД_ЭЛ_ПЛ', 'ГОР_ДН_ЭП', 'ГОР_НЧ_ЭП') then
             '+'
         when imrsk.klnaprpotu like '%городское с эл.плитами%'
          and trim(sa.tarif_gr) not in ('ГОРОД_ЭЛ_ПЛ', 'ГОР_ДН_ЭП', 'ГОР_НЧ_ЭП')
           or imrsk.klnaprpotu like '%сельское%'
          and trim(sa.tarif_gr) in ('ГОРОД_ЭЛ_ПЛ', 'ГОР_ДН_ЭП', 'ГОР_НЧ_ЭП') then
             '-'
         else
           null
       end tarif_gr_pret,
       bill.serial_nbr,
       imrsk.sernomsch,
       el_seti.prem_type,
       el_seti.seti  el_seti,
       el_seti.sp_stop_dt,
       el_seti.sp_stop_reg_reading,
       bill.bill_id,
       el_seti.abolish_dt,
       prem.state,
       prem.cis_division,
       imrsk.aktyneuchpotr,
       to_char(null),
       to_char(null),
       round(fcm_to_number(imrsk.poknachrper)),
       imrsk.datenach,
       round(fcm_to_number(imrsk.pokkonrper)),
       imrsk.dateokonch,
       fcm_to_number(imrsk.raschkoef),
       bill.start_read_type,
       bill.end_read_type
    from (select distinct
                 mrsk.district,
                 mrsk.shtrihkod,
                 mrsk.sernomsch,
                 mrsk.firstname ||' '|| mrsk.secondname ||' '|| mrsk.otchestvo as fio,
                 mrsk.city,
                 mrsk.street,
                 mrsk.house,
                 mrsk.flat,
                 sum(nvl(fcm_to_number(mrsk.koleevtochpost), 0)) over (partition by mrsk.datezagr,
                                                                                    mrsk.shtrihkod,
                                                                                    mrsk.sernomsch,
                                                                                    mrsk.firstname,
                                                                                    mrsk.secondname,
                                                                                    mrsk.otchestvo)   v_ee_mrsk,
                 sum(nvl(fcm_to_number(mrsk.rashponormativu), 0)) over (partition by mrsk.datezagr,
                                                                                    mrsk.shtrihkod,
                                                                                    mrsk.sernomsch,
                                                                                    mrsk.firstname,
                                                                                    mrsk.secondname,
                                                                                    mrsk.otchestvo)  v_norm_mrsk,
                 mrsk.naimgrpotr,
                 mrsk.klnaprpotu,
                 mrsk.aktyneuchpotr,
                 mrsk.poknachrper,
                 mrsk.datenach,
                 mrsk.pokkonrper,
                 mrsk.dateokonch,
                 mrsk.raschkoef
            from cm_lesk_mrsk_sverka          mrsk
           where mrsk.datezagr = &pdat) imrsk,
         (select distinct
                 substr(ac.srch_char_val, 1, 21) ls_shtrih,
                 ac.effdt,
                 bill.bill_id,
                 bs.start_dt,
                 bs.end_dt,
                 br.start_reg_read_id,
                 br.start_read_dttm,
                 br.start_reg_reading,
                 (select rr.read_type_flg
                    from rusadm.ci_reg_read  rr
                   where rr.reg_read_id = br.start_reg_read_id) start_read_type_flg,
                 (select lvl.descr
                    from rusadm.ci_reg_read  rr,
                         rusadm.ci_lookup_val_l  lvl
                   where rr.reg_read_id = br.start_reg_read_id
                     and lvl.field_name = 'READ_TYPE_FLG'
                     and lvl.language_cd = 'RUS'
                     and lvl.field_value = rr.read_type_flg) start_read_type,
                 br.end_reg_read_id,
                 br.end_read_dttm,
                 br.end_reg_reading,
                 (select rr.read_type_flg
                    from rusadm.ci_reg_read  rr
                   where rr.reg_read_id = br.end_reg_read_id) end_read_type_flg,
                 (select lvl.descr
                    from rusadm.ci_reg_read  rr,
                         rusadm.ci_lookup_val_l  lvl
                   where rr.reg_read_id = br.end_reg_read_id
                     and lvl.field_name = 'READ_TYPE_FLG'
                     and lvl.language_cd = 'RUS'
                     and lvl.field_value = rr.read_type_flg) end_read_type,
                 br.msr_qty  v_ee_mtr,
                 bsq.sqi_cd,
                 case
                   when bsq.sqi_cd not in ('NORMATIV', 'CONST_VO') then
                     br.msr_qty
                   else
                     bsq.bill_sq
                 end v_ee_lesk,
                 case
                   when bsq.sqi_cd in ('NORMATIV', 'CONST_VO') then
                     bsq.bill_sq
                 end v_norm_lesk,
                 tunmet_cons.unmet_cons,
                 tvnorm.vnorm,
                 end_mr.serial_nbr
            from rusadm.ci_acct_char   ac
            join rusadm.ci_bill        bill             on (bill.acct_id = ac.acct_id)
            join rusadm.ci_bseg        bs               on (bill.bill_id = bs.bill_id)
            left join
                 rusadm.ci_bseg_read   br               on (bs.bseg_id = br.bseg_id)
            join rusadm.ci_bseg_sq     bsq              on (bs.bseg_id = bsq.bseg_id)
            left join 
                 (select m.serial_nbr,
                         rr.reg_read_id
                    from rusadm.ci_reg_read   rr,
                         rusadm.ci_mr         mr,
                         rusadm.ci_mtr_config mc,
                         rusadm.ci_mtr        m
                   where rr.mr_id = mr.mr_id
                     and mr.mtr_config_id = mc.mtr_config_id
                     and mc.mtr_id = m.mtr_id) end_mr   on (br.end_reg_read_id = end_mr.reg_read_id)
            left join 
                 (select sum(bsq.bill_sq) unmet_cons,
                         bs.bill_id
                    from rusadm.ci_bseg_sq    bsq,
                         rusadm.ci_bseg       bs,
                         rusadm.ci_sa         sa
                   where bsq.bseg_id = bs.bseg_id
                     and bs.sa_id = sa.sa_id
                     and sa.sa_type_cd = 'PROCHEE'
                     and sa.start_dt between &pdat and add_months(&pdat, 1)
                   group by bs.bill_id) tunmet_cons     on (bill.bill_id = tunmet_cons.bill_id)
            left join
                 (select spc.sp_id,
                         nvl(trim(spc.adhoc_char_val), 'YES') vnorm,
                         spc.effdt
                    from rusadm.ci_sp_char  spc
                   where spc.char_type_cd = 'VNORM') tvnorm on (br.sp_id = tvnorm.sp_id and bs.end_dt = tvnorm.effdt)
           where ac.char_type_cd = 'SHT_KOD'
             and bill.bill_stat_flg = 'C'
             and trunc(bill.bill_dt, 'mm') = &pdat
             and bs.bseg_stat_flg = '50') bill,
         (select 
                 ac.acct_id,
                 sa.sa_id,
                 sa.sa_status_flg,
                 substr(ac.srch_char_val, 1, 21) ls_shtrih,
                 tarif_gr.char_val      tarif_gr,
                 tarif_gr.char_descr    tarif_gr_d
            from rusadm.ci_acct_char   ac,
                 rusadm.ci_sa          sa,
                 (select sac.sa_id,
                         sac.char_val,
                         cvl.descr char_descr
                    from rusadm.ci_sa_char     sac,
                         rusadm.ci_char_val_l  cvl
                   where sac.char_type_cd = 'PRICE-1'
                     and sac.effdt = (select max(sac2.effdt)
                                        from rusadm.ci_sa_char  sac2
                                       where sac.sa_id = sac2.sa_id
                                         and sac.char_type_cd = sac2.char_type_cd
                                         and sac2.effdt < add_months(trunc(&pdat, 'mm'), 1))
                     and sac.char_type_cd = cvl.char_type_cd
                     and sac.char_val = cvl.char_val
                     and cvl.language_cd = 'RUS') tarif_gr
           where ac.char_type_cd = 'SHT_KOD'
             and ac.acct_id = sa.acct_id
             and sa.start_dt < add_months(&pdat, 1)
             and sa.sa_type_cd in ('L_EL_RES', 'L_ELNRES')
             and (sa.end_dt is null or
                  sa.end_dt >= &pdat)
             and sa.sa_id = tarif_gr.sa_id(+)) sa,
         (select distinct
                 substr(ac.srch_char_val, 1, 21) ls_shtrih,
                 ac.acct_id,
                 sp.sp_id,
                 sp.abolish_dt,
                 prem.prem_id,
                 sc.srch_char_val         seti_cd,
                 cl.descr                 seti,
                 ptl.descr                prem_type,
                 sasp.start_dttm          sp_start_dt,
                 sasp.stop_dttm           sp_stop_dt,
                 start_mr.reg_reading     sp_start_reg_reading,
                 stop_mr.reg_reading      sp_stop_reg_reading
            from rusadm.ci_acct_char   ac,
                 rusadm.ci_sa          sa,
                 rusadm.ci_prem        prem,
                 rusadm.ci_prem_type_l ptl,
                 rusadm.ci_sa_sp       sasp,
                 rusadm.ci_sp          sp,
                 rusadm.ci_sp_char     sc,
                 rusadm.ci_char_val_l  cl,
                 (select mr.mr_id,
                         mr.mr_source_cd,
                         mr.read_dttm,
                         rr.reg_reading,
                         rr.read_type_flg
                    from rusadm.ci_mr             mr,
                         rusadm.ci_reg_read       rr
                   where mr.mr_id = rr.mr_id)     start_mr,
                 (select mr.mr_id,
                         mr.mr_source_cd,
                         mr.read_dttm,
                         rr.reg_reading,
                         rr.read_type_flg
                    from rusadm.ci_mr             mr,
                         rusadm.ci_reg_read       rr
                   where mr.mr_id = rr.mr_id)     stop_mr
           where ac.char_type_cd = 'SHT_KOD'
             and ac.acct_id = sa.acct_id
             and sa.char_prem_id = prem.prem_id
             and prem.prem_id = sp.prem_id
             and sasp.sa_id = sa.sa_id
             and sasp.sp_id = sp.sp_id
             and sp.sp_id = sc.sp_id
             and sc.char_type_cd = 'EL_SETI'
             and sc.char_type_cd = cl.char_type_cd
             and sc.char_val = cl.char_val
             and cl.language_cd = 'RUS'
             and prem.prem_type_cd = ptl.prem_type_cd
             and ptl.language_cd = cl.language_cd
             and sc.effdt = (select max(sc2.effdt)
                               from rusadm.ci_sp_char   sc2
                              where sc2.sp_id = sc.sp_id
                                and sc2.char_type_cd = sc.char_type_cd
                                and sc2.effdt < add_months(trunc(&pdat, 'mm'), 1))
             and (sasp.stop_dttm is null
                  or
                  sasp.stop_dttm between trunc(&pdat, 'mm') and last_day(&pdat))
             and sasp.start_mr_id = start_mr.mr_id(+)
             and sasp.stop_mr_id = stop_mr.mr_id(+)) el_seti,
         (select pr.prem_id,
                       l.prem_type_cd,
                       pr.state,
                       pr.city,
                       pr.cis_division,
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
                 where pr.prem_type_cd = l.prem_type_cd
                   and pr.prem_type_cd != 'MNDOM'
                   -- Учатсвуют только частный сектор либо 
                   -- квартиры в МКД без ОДПУ
                   and (trim(pr.prnt_prem_id) is null
                        or exists (select null
                                     from ci_sp  parent
                                    where parent.prem_id = pr.prnt_prem_id))
                   and l.language_cd = 'RUS'
                   and pr.prem_id = kol_kom.prem_id(+)
                   and pr.prem_id = kol_zare.prem_id(+)
                   and pr.prem_id = tip_plit.prem_id(+)
                   and pr.prem_id = tip_otop.prem_id(+)
                   and pr.prem_id = vodonagr.prem_id(+)) prem
   where not exists (select null
                       from lcmccb.cm_slice_lesk_data ld
                      where ld.ls_shtrih = imrsk.shtrihkod)
     and not exists (select null
                       from lcmccb.cm_slice_match m
                      where m.ls_shtrih = imrsk.shtrihkod)
     and not exists (select null
                       from lcmccb.cm_slice_notmatch n
                      where n.ls_shtrih = imrsk.shtrihkod)
     and imrsk.shtrihkod = bill.ls_shtrih(+)
     and imrsk.shtrihkod = sa.ls_shtrih(+)
     and imrsk.shtrihkod = el_seti.ls_shtrih(+)
     and el_seti.prem_id = prem.prem_id(+)
     and nvl(imrsk.sernomsch, '1') = nvl(bill.serial_nbr, '1');


delete from lcmccb.cm_slice_notfound_in_mrsk where dttm = &pdat;

insert into lcmccb.cm_slice_notfound_in_mrsk
select &pdat dttm,
       iccb.r_on_text,
       iccb.ls_shtrih,
       iccb.sp_id,
       iccb.acct_id,
       iccb.fio,
       iccb.city,
       iccb.street,
       iccb.house,
       iccb.flat,
       iccb.kol_kom,
       iccb.kol_zare,
       iccb.tip_plit,
       iccb.tip_plit_d,
       iccb.tip_otop,
       iccb.tip_otop_d,
       iccb.vodonagr,
       iccb.vodonagr_d,
       iccb.start_dt,
       iccb.end_dt,
       iccb.start_reg_reading,
       iccb.start_read_dttm,
       iccb.end_reg_reading,
       iccb.end_read_dttm,
       sum(iccb.v_ee_mtr),
       sum(iccb.v_norm_lesk),
       0,
       sum(iccb.ras_vel_med),
       sum(iccb.ras_vel_norm),
       sum(iccb.unmet_cons),
       iccb.v_ee_lesk,
       0,
       - iccb.v_ee_lesk v_pret,
       'Не найдена ТУ в МРСК' type_raznog,
       (select cv.descr
          from rusadm.ci_char_val_l cv
         where cv.char_type_cd = 'PRICE-1'
           and cv.language_cd = 'RUS'
           and cv.char_val = iccb.tarif_gr) tarif_gr_lesk,
       to_char(null) tarif_gr_mrsk,
       to_char(null) tarif_gr_pret,
       iccb.serial_nbr,
       to_char(null) sernomsch,
       iccb.prem_type,
       iccb.el_seti,
       iccb.sp_stop_dt,
       iccb.sp_stop_reg_reading,
       iccb.bill_id,
       iccb.abolish_dt,
       iccb.r_on,
       iccb.cis_division,
       to_char(null) aktyneuchpotr,
       iccb.start_mr_source,
       iccb.end_mr_source,
       to_char(null) poknachrper,
       to_date(null) datenach,
       to_char(null) pokkonrper,
       to_date(null) dateokonch,
       to_char(null) raschkoef,
       iccb.start_read_type start_read_type,
       iccb.end_read_type end_read_type
    from (select distinct
                 ccb.dttm,
                 ccb.r_on,
                 ccb.cis_division,
                 ccb.sp_id,
                 ccb.acct_id,
                 ccb.fio,
                 ccb.ls_shtrih,
                 ccb.serial_nbr,
                 ccb.r_on_text,
                 ccb.city,
                 ccb.street,
                 ccb.house,
                 ccb.flat,
                 ccb.v_ee_mtr,
                 ccb.ras_vel_med,
                 ccb.ras_vel_norm,
                 ccb.start_dt,
                 ccb.end_dt,
                 ccb.start_reg_reading,
                 ccb.start_read_dttm,
                 ccb.start_mr_source,
                 ccb.end_reg_reading,
                 ccb.end_read_dttm,
                 ccb.end_mr_source,
                 sum(nvl(ccb.v_ee_all, 0)) over (partition by ccb.ls_shtrih, ccb.serial_nbr) v_ee_lesk,
                 sum(nvl(ccb.v_norm, 0)) over (partition by ccb.ls_shtrih) v_norm_lesk,
                 ccb.end_read_type_flg read_type,
                 ccb.unmet_cons,
                 ccb.tarif_gr,
                 ccb.kol_kom,
                 ccb.kol_zare,
                 ccb.tip_plit,
                 ccb.tip_plit_d,
                 ccb.tip_otop,
                 ccb.tip_otop_d,
                 ccb.vodonagr,
                 ccb.vodonagr_d,
                 ccb.sp_stop_dt,
                 ccb.sp_stop_reg_reading,
                 ccb.abolish_dt,
                 ccb.prem_type,
                 ccb.el_seti,
                 ccb.bill_id,
                 ccb.start_read_type,
                 ccb.end_read_type
            from lcmccb.cm_slice_lesk_data    ccb
           where ccb.dttm = &pdat) iccb
   where not exists (select null
                       from lcmccb.cm_slice_lesk_data ld
                      where ld.ls_shtrih = iccb.ls_shtrih)
     and not exists (select null
                       from lcmccb.cm_slice_match m
                      where m.ls_shtrih = iccb.ls_shtrih)
     and not exists (select null
                       from lcmccb.cm_slice_notmatch n
                      where n.ls_shtrih = iccb.ls_shtrih)
  group by iccb.r_on_text,
           iccb.ls_shtrih,
           iccb.sp_id,
           iccb.acct_id,
           iccb.fio,
           iccb.city,
           iccb.street,
           iccb.house,
           iccb.flat,
           iccb.kol_kom,
           iccb.kol_zare,
           iccb.tip_plit,
           iccb.tip_plit_d,
           iccb.tip_otop,
           iccb.tip_otop_d,
           iccb.vodonagr,
           iccb.vodonagr_d,
           iccb.start_dt,
           iccb.end_dt,
           iccb.start_reg_reading,
           iccb.start_read_dttm,
           iccb.end_reg_reading,
           iccb.end_read_dttm,
           iccb.v_ee_lesk,
           iccb.tarif_gr,
           iccb.tip_plit,
           iccb.serial_nbr,
           iccb.prem_type,
           iccb.el_seti,
           iccb.abolish_dt,
           iccb.sp_stop_dt,
           iccb.sp_stop_reg_reading,
           iccb.bill_id,
           iccb.r_on,
           iccb.cis_division,
           iccb.start_mr_source,
           iccb.end_mr_source,
           iccb.start_read_type,
           iccb.end_read_type;

select --@name_sheet Сводная сверка
       distinct
       dttm,
       r_on_text               "Район",
       ls_shtrih               "Штрихкод",
       sp_id                   "ID ТУ",
       fio                     "ФИО",
       city                    "Нас. пункт",
       street                  "Улица",
       house                   "№ дома",
       flat                    "№ кв.",
       min(
         case
           when x.end_read_dttm between trunc(&pdat, 'mm') and trunc(add_months(&pdat, 1), 'mm') then
             v_ee_mtr
         end)                  "Расход по ПУ ЛЭСК",
       min(
         case
           when x.end_read_dttm between trunc(&pdat, 'mm') and trunc(add_months(&pdat, 1), 'mm') then
             v_norm_lesk
         end)                  "Норматив э/э ЛЭСК",
       min(
         case
           when x.end_read_dttm between trunc(&pdat, 'mm') and trunc(add_months(&pdat, 1), 'mm') then
             ras_vel_med
         end)                  "Расчётный способ (среднемес.)",
       min(
         case
           when x.end_read_dttm between trunc(&pdat, 'mm') and trunc(add_months(&pdat, 1), 'mm') then
             ras_vel_norm
         end)                  "Расчётный способ (норматив)",
       min(
         case
           when x.end_read_dttm between trunc(&pdat, 'mm') and trunc(add_months(&pdat, 1), 'mm') then
             unmet_cons
         end)                  "Акт о безучётном потреблении",
       min(
         case
           when x.end_read_dttm not between trunc(&pdat, 'mm') and trunc(add_months(&pdat, 1), 'mm') then
             x.start_read_dttm
         end)                  "Дата нач. пок. за пред. период",
       max(
         case
           when x.end_read_dttm not between trunc(&pdat, 'mm') and trunc(add_months(&pdat, 1), 'mm') then
             x.end_read_dttm
         end)                  "Дата кон. пок. за пред. период",
       sum(
         case
           when x.end_read_dttm not between trunc(&pdat, 'mm') and trunc(add_months(&pdat, 1), 'mm') then
             x.v_ee_mtr
         end)                  "Объём пок. за пред. период",
       v_ee_lesk               "Объём ээ ЛЭСК ВСЕГО",
       v_ee_mrsk               "Объём ээ МРСК ВСЕГО",
       v_pret                  "Объём претензий",
       type_raznog             "Тип разногласий",
       tarif_gr_lesk           "Тариф. группа потреб. ЛЭСК",
       tarif_gr_mrsk           "Тариф. группа потреб. МРСК",
       tarif_gr_pret           "Претензии к тариф. группе",
       prem_type               "Тип объекта обслуживания",
       el_seti                 "Тип электросетей",
       serial_nbr              "Серийный номер ПУ ЛЭСК",
       sernomsch               "Серийный номер ПУ МРСК",
       acct_id                 "ID Лицевого счёта",
       abolish_dt              "Дата остановки ТУ",
       aktyneuchpotr           "Безучётное потребление (МРСК)",
       x.start_reg_reading     "Начальные показания ЛЭСК",
       x.start_read_dttm       "Дата нач. пок. ЛЭСК",
       x.start_mr_source       "Источник нач. пок. ЛЭСК",
       x.start_read_type       "Тип нач. пок. ЛЭСК",
       x.end_reg_reading       "Конечные показания ЛЭСК",
       x.end_read_dttm         "Дата кон. пок. ЛЭСК",
       x.end_mr_source         "Источник кон. пок. ЛЭСК",
       x.end_read_type         "Тип кон. пок. ЛЭСК",
       x.poknachrper           "Начальные показания МРСК",
       x.datenach              "Дата нач. пок. МРСК",
       x.pokkonrper            "Конечные показания МРСК",
       x.dateokonch            "Дата кон. пок. МРСК",
       x.poknachrper - x.start_reg_reading   "Разность нач. показаний",
       x.pokkonrper - x.end_reg_reading      "Разность кон. показаний"
       
  from (select *
           from cm_slice_match 
          where dttm = &pdat
        union all
        select *
           from cm_slice_notmatch 
          where dttm = &pdat
        union all
        select *
           from cm_slice_notfound_in_lesk
          where dttm = &pdat
        union all
        select *
           from cm_slice_notfound_in_mrsk
          where dttm = &pdat) x
 group by dttm,
          r_on_text,
          ls_shtrih,
          sp_id,
          fio,
          city,
          street,
          house,
          flat,
          v_ee_lesk,
          v_ee_mrsk,
          v_pret,
          type_raznog,
          tarif_gr_lesk,
          tarif_gr_mrsk,
          tarif_gr_pret,
          prem_type,
          el_seti,
          serial_nbr,
          sernomsch,
          acct_id,
          abolish_dt,
          aktyneuchpotr,
          x.start_reg_reading,
          x.start_read_dttm,
          x.start_mr_source,
          x.start_read_type,
          x.end_reg_reading,
          x.end_read_dttm,
          x.end_mr_source,
          x.end_read_type,
          x.poknachrper,
          x.datenach,
          x.pokkonrper,
          x.dateokonch;

select --@name_sheet Претензия свод.
       distinct
       dttm,
       r_on_text               "Район",
       ls_shtrih               "Штрихкод",
       sp_id                   "ID ТУ",
       fio                     "ФИО",
       city                    "Нас. пункт",
       street                  "Улица",
       house                   "№ дома",
       flat                    "№ кв.",
       min(
         case
           when x.end_read_dttm between trunc(&pdat, 'mm') and trunc(add_months(&pdat, 1), 'mm') then
             v_ee_mtr
         end)                  "Расход по ПУ ЛЭСК",
       min(
         case
           when x.end_read_dttm between trunc(&pdat, 'mm') and trunc(add_months(&pdat, 1), 'mm') then
             v_norm_lesk
         end)                    "Норматив э/э ЛЭСК",
       min(
         case
           when x.end_read_dttm between trunc(&pdat, 'mm') and trunc(add_months(&pdat, 1), 'mm') then
             ras_vel_med
         end)                    "Расчётный способ (среднемес.)",
       min(
         case
           when x.end_read_dttm between trunc(&pdat, 'mm') and trunc(add_months(&pdat, 1), 'mm') then
             ras_vel_norm
         end)                     "Расчётный способ (норматив)",
       min(
         case
           when x.end_read_dttm between trunc(&pdat, 'mm') and trunc(add_months(&pdat, 1), 'mm') then
             unmet_cons
         end)                    "Акт о безучётном потреблении",
       min(
         case
           when x.end_read_dttm not between trunc(&pdat, 'mm') and trunc(add_months(&pdat, 1), 'mm') then
             x.start_read_dttm
         end)                    "Дата нач. пок. за пред. период",
       max(
         case
           when x.end_read_dttm not between trunc(&pdat, 'mm') and trunc(add_months(&pdat, 1), 'mm') then
             x.end_read_dttm
         end)                    "Дата кон. пок. за пред. период",
       sum(
         case
           when x.end_read_dttm not between trunc(&pdat, 'mm') and trunc(add_months(&pdat, 1), 'mm') then
             x.v_ee_mtr
         end)                    "Объём пок. за пред. период",
       v_ee_lesk               "Объём ээ ЛЭСК ВСЕГО",
       v_ee_mrsk               "Объём ээ МРСК ВСЕГО",
       v_pret                  "Объём претензий",
       type_raznog             "Тип разногласий",
       tarif_gr_lesk           "Тариф. группа потреб. ЛЭСК",
       tarif_gr_mrsk           "Тариф. группа потреб. МРСК",
       tarif_gr_pret           "Претензии к тариф. группе",
       prem_type               "Тип объекта обслуживания",
       el_seti                 "Тип электросетей",
       serial_nbr              "Серийный номер ПУ ЛЭСК",
       sernomsch               "Серийный номер ПУ МРСК",
       acct_id                 "ID Лицевого счёта",
       abolish_dt              "Дата остановки ТУ",
       aktyneuchpotr           "Безучётное потребление (МРСК)",
       x.start_reg_reading     "Начальные показания ЛЭСК",
       x.start_read_dttm       "Дата нач. пок. ЛЭСК",
       x.start_mr_source       "Источник нач. пок. ЛЭСК",
       x.start_read_type       "Тип нач. пок. ЛЭСК",
       x.end_reg_reading       "Конечные показания ЛЭСК",
       x.end_read_dttm         "Дата кон. пок. ЛЭСК",
       x.end_mr_source         "Источник кон. пок. ЛЭСК",
       x.end_read_type         "Тип кон. пок. ЛЭСК",
       x.poknachrper           "Начальные показания МРСК",
       x.datenach              "Дата нач. пок. МРСК",
       x.pokkonrper            "Конечные показания МРСК",
       x.dateokonch            "Дата кон. пок. МРСК",
       x.poknachrper - x.start_reg_reading   "Разность нач. показаний",
       x.pokkonrper - x.end_reg_reading      "Разность кон. показаний"
  from (select *
           from cm_slice_match 
          where dttm = &pdat
        union all
        select *
           from cm_slice_notmatch 
          where dttm = &pdat
        union all
        select *
           from cm_slice_notfound_in_lesk
          where dttm = &pdat
        union all
        select *
           from cm_slice_notfound_in_mrsk
          where dttm = &pdat) x
 where nvl(type_raznog, '-') != 'Разногласий нет'
 group by dttm,
          r_on_text,
          ls_shtrih,
          sp_id,
          fio,
          city,
          street,
          house,
          flat,
          v_ee_lesk,
          v_ee_mrsk,
          v_pret,
          type_raznog,
          tarif_gr_lesk,
          tarif_gr_mrsk,
          tarif_gr_pret,
          prem_type,
          el_seti,
          serial_nbr,
          sernomsch,
          acct_id,
          abolish_dt,
          aktyneuchpotr,
          x.start_reg_reading,
          x.start_read_dttm,
          x.start_mr_source,
          x.start_read_type,
          x.end_reg_reading,
          x.end_read_dttm,
          x.end_mr_source,
          x.end_read_type,
          x.poknachrper,
          x.datenach,
          x.pokkonrper,
          x.dateokonch;

select --@name_sheet Разногласие по показаниям
       distinct
       dttm,
       r_on_text               "Район",
       ls_shtrih               "Штрихкод",
       sp_id                   "ID ТУ",
       fio                     "ФИО",
       city                    "Нас. пункт",
       street                  "Улица",
       house                   "№ дома",
       flat                    "№ кв.",
       sernomsch               "Серийный номер ПУ МРСК",
       min(case amount
         when 1 then
           serial_nbr
       end)                    "Серийный номер ЛЭСК 1",
       min(case amount
         when 1 then
           start_read_dttm
       end)                    "Дата пред. показаний 1",
       min(case amount
         when 1 then
           start_reg_reading
       end)                    "Пред. показания 1",
       min(case amount
         when 1 then
           end_read_dttm
       end)                    "Дата посл. показаний 1",
       min(case amount
         when 1 then
           end_reg_reading
       end)                    "Посл. показания 1",
       min(case amount
         when 1 then
           end_reg_reading - start_reg_reading
       end)                    "Расход по ПУ ЛЭСК 1",
       min(case amount
         when 2 then
           serial_nbr
       end)                    "Серийный номер ЛЭСК 2",
       min(case amount
         when 2 then
           start_read_dttm
       end)                    "Дата пред. показаний 2",
       min(case amount
         when 2 then
           start_reg_reading
       end)                    "Пред. показания 2",
       min(case amount
         when 2 then
           end_read_dttm
       end)                    "Дата посл. показаний 2",
       min(case amount
         when 2 then
           end_reg_reading
       end)                    "Посл. показания 2",
       min(case amount
         when 2 then
           end_reg_reading - start_reg_reading
       end)                    "Расход по ПУ ЛЭСК 2",
       min(case amount
         when 3 then
           serial_nbr
       end)                    "Серийный номер ЛЭСК 3",
       min(case amount
         when 3 then
           start_read_dttm
       end)                    "Дата пред. показаний 3",
       min(case amount
         when 3 then
           start_reg_reading
       end)                    "Пред. показания 3",
       min(case amount
         when 3 then
           end_read_dttm
       end)                    "Дата посл. показаний 3",
       min(case amount
         when 3 then
           end_reg_reading
       end)                    "Посл. показания 3",
       min(case amount
         when 3 then
           end_reg_reading - start_reg_reading
       end)                    "Расход по ПУ ЛЭСК 3",
       min(case amount
         when 4 then
           serial_nbr
       end)                    "Серийный номер ЛЭСК 4",
       min(case amount
         when 4 then
           start_read_dttm
       end)                    "Дата пред. показаний 4",
       min(case amount
         when 4 then
           start_reg_reading
       end)                    "Пред. показания 4",
       min(case amount
         when 4 then
           end_read_dttm
       end)                    "Дата посл. показаний 4",
       min(case amount
         when 4 then
           end_reg_reading
       end)                    "Посл. показания 4",
       min(case amount
         when 4 then
           end_reg_reading - start_reg_reading
       end)                    "Расход по ПУ ЛЭСК 4",
       acct_id                 "ID Лицевого счёта",
       v_pret                  "Объём претензий"
  from (select dttm,
               r_on_text,
               ls_shtrih,
               sp_id,
               acct_id,
               fio,
               city,
               street,
               house,
               flat,
               sernomsch,
               serial_nbr,
               start_read_dttm,
               start_reg_reading,
               end_read_dttm,
               end_reg_reading,
               type_raznog,
               row_number() over (partition by ls_shtrih, serial_nbr order by ls_shtrih) amount,
               v_pret
          from (select *
                  from cm_slice_match
                 where dttm = &pdat
                 union all
                select *
                  from cm_slice_notmatch
                 where dttm = &pdat)
         where type_raznog = 'Разногласие в показаниях ПУ')
 group by dttm,
          r_on_text,
          ls_shtrih,
          sp_id,
          fio,
          city,
          street,
          house,
          flat,
          sernomsch,
          acct_id,
          v_pret;

select --@name_sheet Разногласие по нормативу
       distinct
       dttm,
       r_on_text                      "Район",
       ls_shtrih                      "Штрихкод",
       sp_id                          "ID ТУ",
       acct_id                        "ID Лицевого счёта",
       fio                            "ФИО",
       city                           "Нас. пункт",
       street                         "Улица",
       house                          "№ дома",
       flat                           "№ кв.",
       start_dt + 1                   "Начало расчётного периода",
       end_dt                         "Конец расчётного периода",
       end_dt - start_dt              "Дней при расчёте периода",
       kol_kom                        "Количество комнат",
       kol_zare                       "Количество проживающих",
       tip_otop_d                     "Тип отопления",
       tip_plit_d                     "Тип плиты",
       vodonagr_d                     "Водонагреватель",
       to_number(null)                "Объём начисления (расчётный)",
       v_norm_lesk                    "Объём начисления (по факту)",
       v_pret                         "Объём претензий"
  from (select *
           from cm_slice_match 
          where dttm = &pdat
        union all
        select *
           from cm_slice_notmatch 
          where dttm = &pdat)
 where type_raznog = 'Разногласие по нормативу';



select --@name_sheet Расчётный способ (среднемес.)
       distinct
       dttm,
       r_on_text                            "Район",
       ls_shtrih                            "Штрихкод",
       sp_id                                "ID ТУ",
       acct_id                              "ID Лицевого счёта",
       fio                                  "ФИО",
       city                                 "Нас. пункт",
       street                               "Улица",
       house                                "№ дома",
       flat                                 "№ кв.",
       start_dt + 1                         "Начало расчётного периода",
       end_dt                               "Конец расчётного периода",
       serial_nbr                           "Серийный номер ПУ",
       null                                 "Дата пред. показаний",
       x.start_reg_reading                  "Пред. показания",
       null                                 "Дата посл. показаний",
       x.end_reg_reading                    "Посл. показания",
       null                                 "Дней потребления",
       x.end_reg_reading -
       x.start_reg_reading                  "Объём потребления",
       null                                 "Среднесуточный объём",
       end_dt - start_dt                    "Дней в расчётном периоде",
       v_ee_lesk                            "Объём начисления",
       v_pret                               "Объём претензий"
  from (select *
           from cm_slice_match 
          where dttm = &pdat
        union all
        select *
           from cm_slice_notmatch 
          where dttm = &pdat) x
 where type_raznog = 'Расчётный способ (по среднемесячному)';

select --@name_sheet Расчётный способ (норматив)
       distinct
       dttm,
       r_on_text               "Район",
       ls_shtrih               "Штрихкод",
       sp_id                   "ID ТУ",
       acct_id                 "ID Лицевого счёта",
       fio                     "ФИО",
       city                    "Нас. пункт",
       street                  "Улица",
       house                   "№ дома",
       flat                    "№ кв.",
       serial_nbr              "Серийный номер ПУ ЛЭСК",
       end_read_dttm           "Дата посл. показаний",
       end_reg_reading         "Посл. показания",
       end_dt - start_dt       "Дней при расчёте периода",
       kol_kom                 "Количество комнат",
       kol_zare                "Количество проживающих",
       tip_otop_d              "Тип отопления",
       tip_plit_d              "Тип плиты",
       vodonagr_d              "Водонагреватель",
       prem_type               "Вид жилья",
       to_number(null)         "Объём начисления (расчётный)",
       v_ee_lesk               "Объём начисления (по факту)",
       v_pret                  "Объём претензий"
  from (select *
           from cm_slice_match 
          where dttm = &pdat
        union all
        select *
           from cm_slice_notmatch
          where dttm = &pdat)
 where type_raznog = 'Расчётный способ (по нормативу)';

select --@name_sheet Безучётное потребление
       distinct
       dttm,
       r_on_text               "Район",
       ls_shtrih               "Штрихкод",
       sp_id                   "ID ТУ",
       acct_id                 "ID Лицевого счёта",
       fio                     "ФИО",
       city                    "Нас. пункт",
       street                  "Улица",
       house                   "№ дома",
       flat                    "№ кв.",
       null                    "№ документа",
       null                    "Дата составления документа",
       null                    "Наименование документа",
       null                    "Период, за к-рый нач. объём",
       v_ee_lesk               "Объём э/э ЛЭСК ВСЕГО",
       v_pret                  "Объём претензий",
       abolish_dt              "Дата остановки ТУ",
       aktyneuchpotr           "Безучётное потребление (МРСК)"
  from (select *
           from cm_slice_match 
          where dttm = &pdat
        union all
        select *
           from cm_slice_notmatch
          where dttm = &pdat) x
 where x.type_raznog = 'Безучётное потребление';


select --@name_sheet Разногласие из-за ограничения ТУ
       distinct
       dttm,
       r_on_text               "Район",
       ls_shtrih               "Штрихкод",
       sp_id                   "ID ТУ",
       acct_id                 "ID Лицевого счёта",
       fio                     "ФИО",
       city                    "Нас. пункт",
       street                  "Улица",
       house                   "№ дома",
       flat                    "№ кв.",
       null                    "Ограничение введено",
       sp_stop_dt              "Дата введения ограничения",
       sp_stop_reg_reading     "Показ. на момент введения огр.",
       null                    "№ документа, подтв. введение",
       null                    "Ограничение снято",
       null                    "Дата снятия ограничения",
       null                    "Показ. на момент снятия огр.",
       null                    "№ документа, подтв. снятие",
       v_ee_lesk               "Объём э/э ЛЭСК ВСЕГО",
       v_pret                  "Объём претензий",
       abolish_dt              "Дата остановки ТУ"
  from (select *
           from cm_slice_match 
          where dttm = &pdat
        union all
        select *
           from cm_slice_notmatch
          where dttm = &pdat) x
 where x.type_raznog = 'Разногласие из-за ограничения ТУ';


select --@name_sheet Разногласие тарифных групп
       distinct
       dttm,
       r_on_text               "Район",
       ls_shtrih               "Штрихкод",
       sp_id                   "ID ТУ",
       acct_id                 "ID Лицевого счёта",
       fio                     "ФИО",
       city                    "Нас. пункт",
       street                  "Улица",
       house                   "№ дома",
       flat                    "№ кв.",
       x.v_ee_lesk             "Объём э/э ЛЭСК ВСЕГО",
       x.v_ee_mrsk             "Объём э/э МРСК",
       x.v_pret                "Объём претензий",
       x.tarif_gr_lesk         "Тариф. гр. ЛЭСК",
       x.tarif_gr_mrsk         "Тариф. гр. МРСК",
       x.tarif_gr_pret         "Претензии к тар. гр.",
       v_pret                  "Объём претензий"
  from (select *
           from cm_slice_match 
          where dttm = &pdat
        union all
        select *
           from cm_slice_notmatch
          where dttm = &pdat) x
 where tarif_gr_pret is not null;

select --@name_sheet Без разногласий
       distinct
       dttm,
       r_on_text               "Район",
       ls_shtrih               "Штрихкод",
       sp_id                   "ID ТУ",
       acct_id                 "ID Лицевого счёта",
       fio                     "ФИО",
       city                    "Нас. пункт",
       street                  "Улица",
       house                   "№ дома",
       flat                    "№ кв.",
       x.serial_nbr            "Серийный номер ПУ ЛЭСК",
       x.sernomsch             "Серийный номер ПУ МРСК",
       x.v_ee_lesk             "Объём э/э ЛЭСК",
       x.v_ee_mrsk             "Объём э/э МРСК",
       x.v_pret                "Объём претензий",
       v_pret                  "Объём претензий"
  from (select *
           from cm_slice_match 
          where dttm = &pdat
        union all
        select *
           from cm_slice_notmatch
          where dttm = &pdat) x
 where type_raznog = 'Разногласий нет';

select --@name_sheet Отсутствие в МРСК
       distinct
       dttm,
       r_on_text               "Район",
       ls_shtrih               "Штрихкод",
       sp_id                   "ID ТУ",
       acct_id                 "ID Лицевого счёта",
       fio                     "ФИО",
       city                    "Нас. пункт",
       street                  "Улица",
       house                   "№ дома",
       flat                    "№ кв.",
       x.serial_nbr            "Серийный номер ПУ ЛЭСК",
       x.end_reg_reading -
       x.start_reg_reading     "Расход по ПУ",
       x.v_norm_lesk           "Норматив э/э",
       x.ras_vel_med           "Расчёт по среднемесячному",
       x.ras_vel_norm          "Расчёт по нормативу",
       x.unmet_cons            "Акт о безуч. потреблении",
       x.v_ee_lesk             "Расход э/э ВСЕГО",
       v_pret                  "Объём претензий",
       abolish_dt              "Дата остановки ТУ"
  from cm_slice_notfound_in_mrsk x
 where type_raznog = 'Не найдена ТУ в МРСК'
   and x.dttm = &pdat;

select --@name_sheet Отсутствие в ЛЭСК
       distinct
       dttm,
       r_on_text               "Район",
       ls_shtrih               "Штрихкод",
       sp_id                   "ID ТУ",
       fio                     "ФИО",
       city                    "Нас. пункт",
       street                  "Улица",
       house                   "№ дома",
       flat                    "№ кв.",
       x.sernomsch             "Серийный номер ПУ МРСК",
       decode(x.v_norm_mrsk,
              0,
              x.v_ee_mrsk,
              0)               "Расход по ПУ МРСК",
       x.v_norm_mrsk           "Норматив э/э МРСК",
       x.v_ee_mrsk             "Расход э/э МРСК ВСЕГО",
       x.v_ee_lesk             "Расход э/э ЛЭСК ВСЕГО",
       v_pret                  "Объём претензий",
       abolish_dt              "Дата остановки ТУ",
       acct_id                 "ID лицевого счёта"
  from cm_slice_notfound_in_lesk x
 where type_raznog in ('Невозможно найти абонента (отсутствует штрихкод)',
                       'Невозможно найти абонента (некорректный штрихкод)',
                       'Отсутствует активный РДО',
                       'Не выставлен счёт в ЛЭСК',
                       'Бездоговорное потребление (нет РДО в ЛЭСК)',
                       'ТУ не принадлежит сети МРСК',
                       'Бездоговорное потребление (нет ТУ в ЛЭСК)',
                       'Клиент отсутствует в выгрузке данных ЛЭСК')
   and x.dttm = &pdat;

select --@name_sheet Общие объёмы
       distinct
       dttm,
       r_on_text               "Район",
       ls_shtrih               "Штрихкод",
       sp_id                   "ID ТУ",
       fio                     "ФИО",
       city                    "Нас. пункт",
       street                  "Улица",
       house                   "№ дома",
       flat                    "№ кв.",
       sum(v_ee_lesk)          "Расход ЛЭСК",
       sum(v_ee_mrsk)          "Расход МРСК",
       sum(v_pret)             "Объём претензий"
  from (select dttm,
               r_on_text,
               ls_shtrih,
               sp_id,
               fio,
               city,
               street,
               house,
               flat,
               sum(v_ee_lesk) v_ee_lesk,
               sum(v_ee_mrsk) v_ee_mrsk,
               sum(v_ee_mrsk) - sum(v_ee_lesk) v_pret
          from cm_slice_match
         where dttm = &pdat
         group by dttm,
                  r_on_text,
                  ls_shtrih,
                  sp_id,
                  fio,
                  city,
                  street,
                  house,
                  flat
        union all
        select dttm,
               r_on_text,
               ls_shtrih,
               sp_id,
               fio,
               city,
               street,
               house,
               flat,
               sum(v_ee_lesk) v_ee_lesk,
               sum(v_ee_mrsk) v_ee_mrsk,
               sum(v_ee_mrsk) - sum(v_ee_lesk) v_pret
          from cm_slice_notmatch
         where dttm = &pdat
         group by dttm,
                  r_on_text,
                  ls_shtrih,
                  sp_id,
                  fio,
                  city,
                  street,
                  house,
                  flat
        union all
        select dttm,
               r_on_text,
               ls_shtrih,
               sp_id,
               fio,
               city,
               street,
               house,
               flat,
               sum(v_ee_lesk) v_ee_lesk,
               sum(v_ee_mrsk) v_ee_mrsk,
               sum(v_ee_mrsk) - sum(v_ee_lesk) v_pret
          from cm_slice_notfound_in_lesk
         where dttm = &pdat
         group by dttm,
                  r_on_text,
                  ls_shtrih,
                  sp_id,
                  fio,
                  city,
                  street,
                  house,
                  flat
        union all
        select dttm,
               r_on_text,
               ls_shtrih,
               sp_id,
               fio,
               city,
               street,
               house,
               flat,
               sum(v_ee_lesk) v_ee_lesk,
               sum(v_ee_mrsk) v_ee_mrsk,
               sum(v_ee_mrsk) - sum(v_ee_lesk) v_pret
          from cm_slice_notfound_in_mrsk
         where dttm = &pdat
         group by dttm,
                  r_on_text,
                  ls_shtrih,
                  sp_id,
                  fio,
                  city,
                  street,
                  house,
                  flat) x
 group by dttm,
          r_on_text,
          ls_shtrih,
          sp_id,
          fio,
          city,
          street,
          house,
          flat;