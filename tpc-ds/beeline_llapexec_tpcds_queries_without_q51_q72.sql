set hive.tez.exec.print.summary=true;

-- query12.sql
select  i_item_desc -- query12.sql
      ,i_category 
      ,i_class 
      ,i_current_price
      ,i_item_id
      ,sum(ws_ext_sales_price) as itemrevenue 
      ,sum(ws_ext_sales_price)*100/sum(sum(ws_ext_sales_price)) over
          (partition by i_class) as revenueratio
from	
	web_sales
    	,item 
    	,date_dim
where 
	web_sales.ws_item_sk = item.i_item_sk 
  	and item.i_category in ('Jewelry', 'Sports', 'Books')
  	and web_sales.ws_sold_date_sk = date_dim.d_date_sk
	and date_dim.d_date between '2001-01-12' and '2001-02-11'
group by 
	i_item_id
        ,i_item_desc 
        ,i_category
        ,i_class
        ,i_current_price
order by 
	i_category
        ,i_class
        ,i_item_id
        ,i_item_desc
        ,revenueratio
limit 100;



-- query15.sql
select  ca_zip -- query15.sql
       ,sum(cs_sales_price)
 from catalog_sales
     ,customer
     ,customer_address
     ,date_dim
 where catalog_sales.cs_bill_customer_sk = customer.c_customer_sk
 	and customer.c_current_addr_sk = customer_address.ca_address_sk 
 	and ( substr(ca_zip,1,5) in ('85669', '86197','88274','83405','86475',
                                   '85392', '85460', '80348', '81792')
 	      or customer_address.ca_state in ('CA','WA','GA')
 	      or catalog_sales.cs_sales_price > 500)
 	and catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
 	and date_dim.d_qoy = 2 and date_dim.d_year = 2000
 group by ca_zip
 order by ca_zip
 limit 100;



-- query17.sql
select  i_item_id -- query17.sql
       ,i_item_desc
       ,s_state
       ,count(ss_quantity) as store_sales_quantitycount
       ,avg(ss_quantity) as store_sales_quantityave
       ,stddev_samp(ss_quantity) as store_sales_quantitystdev
       ,stddev_samp(ss_quantity)/avg(ss_quantity) as store_sales_quantitycov
       ,count(sr_return_quantity) as_store_returns_quantitycount
       ,avg(sr_return_quantity) as_store_returns_quantityave
       ,stddev_samp(sr_return_quantity) as_store_returns_quantitystdev
       ,stddev_samp(sr_return_quantity)/avg(sr_return_quantity) as store_returns_quantitycov
       ,count(cs_quantity) as catalog_sales_quantitycount ,avg(cs_quantity) as catalog_sales_quantityave
       ,stddev_samp(cs_quantity)/avg(cs_quantity) as catalog_sales_quantitystdev
       ,stddev_samp(cs_quantity)/avg(cs_quantity) as catalog_sales_quantitycov
 from store_sales
     ,store_returns
     ,catalog_sales
     ,date_dim d1
     ,date_dim d2
     ,date_dim d3
     ,store
     ,item
 where d1.d_quarter_name = '2000Q1'
   and d1.d_date_sk = store_sales.ss_sold_date_sk
   and item.i_item_sk = store_sales.ss_item_sk
   and store.s_store_sk = store_sales.ss_store_sk
   and store_sales.ss_customer_sk = store_returns.sr_customer_sk
   and store_sales.ss_item_sk = store_returns.sr_item_sk
   and store_sales.ss_ticket_number = store_returns.sr_ticket_number
   and store_returns.sr_returned_date_sk = d2.d_date_sk
   and d2.d_quarter_name in ('2000Q1','2000Q2','2000Q3')
   and store_returns.sr_customer_sk = catalog_sales.cs_bill_customer_sk
   and store_returns.sr_item_sk = catalog_sales.cs_item_sk
   and catalog_sales.cs_sold_date_sk = d3.d_date_sk
   and d3.d_quarter_name in ('2000Q1','2000Q2','2000Q3')
 group by i_item_id
         ,i_item_desc
         ,s_state
 order by i_item_id
         ,i_item_desc
         ,s_state
limit 100;


-- query18.sql
select  i_item_id, -- query18.sql
        ca_country,
        ca_state, 
        ca_county,
        avg( cast(cs_quantity as decimal(12,2))) agg1,
        avg( cast(cs_list_price as decimal(12,2))) agg2,
        avg( cast(cs_coupon_amt as decimal(12,2))) agg3,
        avg( cast(cs_sales_price as decimal(12,2))) agg4,
        avg( cast(cs_net_profit as decimal(12,2))) agg5,
        avg( cast(c_birth_year as decimal(12,2))) agg6,
        avg( cast(cd1.cd_dep_count as decimal(12,2))) agg7
 from catalog_sales, date_dim, customer_demographics cd1, item, customer, customer_address, 
      customer_demographics cd2
 where catalog_sales.cs_sold_date_sk = date_dim.d_date_sk and
       catalog_sales.cs_item_sk = item.i_item_sk and
       catalog_sales.cs_bill_cdemo_sk = cd1.cd_demo_sk and
       catalog_sales.cs_bill_customer_sk = customer.c_customer_sk and
       cd1.cd_gender = 'M' and 
       cd1.cd_education_status = 'College' and
       customer.c_current_cdemo_sk = cd2.cd_demo_sk and
       customer.c_current_addr_sk = customer_address.ca_address_sk and
       c_birth_month in (9,5,12,4,1,10) and
       d_year = 2001 and
       ca_state in ('ND','WI','AL'
                   ,'NC','OK','MS','TN')
 group by i_item_id, ca_country, ca_state, ca_county with rollup
 order by ca_country,
        ca_state, 
        ca_county,
	i_item_id
 limit 100;

-- query19.sql
select  i_brand_id brand_id, i_brand brand, i_manufact_id, i_manufact, -- query19.sql
 	sum(ss_ext_sales_price) ext_price
 from date_dim, store_sales, item,customer,customer_address,store
 where date_dim.d_date_sk = store_sales.ss_sold_date_sk
   and store_sales.ss_item_sk = item.i_item_sk
   and i_manager_id=7
   and d_moy=11
   and d_year=1999
   and store_sales.ss_customer_sk = customer.c_customer_sk 
   and customer.c_current_addr_sk = customer_address.ca_address_sk
   and substr(ca_zip,1,5) <> substr(s_zip,1,5) 
   and store_sales.ss_store_sk = store.s_store_sk 
 group by i_brand
      ,i_brand_id
      ,i_manufact_id
      ,i_manufact
 order by ext_price desc
         ,i_brand
         ,i_brand_id
         ,i_manufact_id
         ,i_manufact
limit 100 ;

-- query20.sql
select  i_item_desc -- query20.sql
       ,i_category 
       ,i_class 
       ,i_current_price
       ,i_item_id
       ,sum(cs_ext_sales_price) as itemrevenue 
       ,sum(cs_ext_sales_price)*100/sum(sum(cs_ext_sales_price)) over
           (partition by i_class) as revenueratio
 from catalog_sales
     ,item 
     ,date_dim
 where catalog_sales.cs_item_sk = item.i_item_sk 
   and i_category in ('Jewelry', 'Sports', 'Books')
   and catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
 and d_date between '2001-01-12' and '2001-02-11'
 group by i_item_id
         ,i_item_desc 
         ,i_category
         ,i_class
         ,i_current_price
 order by i_category
         ,i_class
         ,i_item_id
         ,i_item_desc
         ,revenueratio
limit 100;

-- query21.sql
select  * -- query21.sql
 from(select w_warehouse_name
            ,i_item_id
            ,sum(case when (cast(d_date as date) < cast ('1998-04-08' as date))
	                then inv_quantity_on_hand 
                      else 0 end) as inv_before
            ,sum(case when (cast(d_date as date) >= cast ('1998-04-08' as date))
                      then inv_quantity_on_hand 
                      else 0 end) as inv_after
   from inventory
       ,warehouse
       ,item
       ,date_dim
   where i_current_price between 0.99 and 1.49
     and item.i_item_sk          = inventory.inv_item_sk
     and inventory.inv_warehouse_sk   = warehouse.w_warehouse_sk
     and inventory.inv_date_sk    = date_dim.d_date_sk
     and d_date between '1998-03-09' and '1998-05-07'
   group by w_warehouse_name, i_item_id) x
 where (case when inv_before > 0 
             then inv_after / inv_before 
             else null
             end) between 2.0/3.0 and 3.0/2.0
 order by w_warehouse_name
         ,i_item_id
 limit 100;


-- query22.sql
select  i_product_name -- query22.sql
             ,i_brand
             ,i_class
             ,i_category
             ,avg(inv_quantity_on_hand) qoh
       from inventory
           ,date_dim
           ,item
           ,warehouse
       where inventory.inv_date_sk=date_dim.d_date_sk
              and inventory.inv_item_sk=item.i_item_sk
              and inventory.inv_warehouse_sk = warehouse.w_warehouse_sk
              and date_dim.d_month_seq between 1193 and 1193 + 11
       group by i_product_name
                       ,i_brand
                       ,i_class
                       ,i_category with rollup
order by qoh, i_product_name, i_brand, i_class, i_category
limit 100;



-- query25.sql
select -- query25.sql
 i_item_id
 ,i_item_desc
 ,s_store_id
 ,s_store_name
 ,sum(ss_net_profit) as store_sales_profit
 ,sum(sr_net_loss) as store_returns_loss
 ,sum(cs_net_profit) as catalog_sales_profit
 from
 store_sales
 ,store_returns
 ,catalog_sales
 ,date_dim d1
 ,date_dim d2
 ,date_dim d3
 ,store
 ,item
 where
 d1.d_moy = 4
 and d1.d_year = 1998
 and d1.d_date_sk = ss_sold_date_sk
 and i_item_sk = ss_item_sk
 and s_store_sk = ss_store_sk
 and ss_customer_sk = sr_customer_sk
 and ss_item_sk = sr_item_sk
 and ss_ticket_number = sr_ticket_number
 and sr_returned_date_sk = d2.d_date_sk
 and d2.d_moy               between 4 and  10
 and d2.d_year              = 1998
 and sr_customer_sk = cs_bill_customer_sk
 and sr_item_sk = cs_item_sk
 and cs_sold_date_sk = d3.d_date_sk
 and d3.d_moy               between 4 and  10
 and d3.d_year              = 1998
 group by
 i_item_id
 ,i_item_desc
 ,s_store_id
 ,s_store_name
 order by
 i_item_id
 ,i_item_desc
 ,s_store_id
 ,s_store_name
 limit 100;



-- query26.sql
select  i_item_id, -- query26.sql
        avg(cs_quantity) agg1,
        avg(cs_list_price) agg2,
        avg(cs_coupon_amt) agg3,
        avg(cs_sales_price) agg4 
 from catalog_sales, customer_demographics, date_dim, item, promotion
 where catalog_sales.cs_sold_date_sk = date_dim.d_date_sk and
       catalog_sales.cs_item_sk = item.i_item_sk and
       catalog_sales.cs_bill_cdemo_sk = customer_demographics.cd_demo_sk and
       catalog_sales.cs_promo_sk = promotion.p_promo_sk and
       cd_gender = 'F' and 
       cd_marital_status = 'W' and
       cd_education_status = 'Primary' and
       (p_channel_email = 'N' or p_channel_event = 'N') and
       d_year = 1998
 group by i_item_id
 order by i_item_id
 limit 100;

-- query27.sql
select  i_item_id, -- query27.sql
        s_state,
        avg(ss_quantity) agg1,
        avg(ss_list_price) agg2,
        avg(ss_coupon_amt) agg3,
        avg(ss_sales_price) agg4
 from store_sales, customer_demographics, date_dim, store, item
 where store_sales.ss_sold_date_sk = date_dim.d_date_sk and
       store_sales.ss_item_sk = item.i_item_sk and
       store_sales.ss_store_sk = store.s_store_sk and
       store_sales.ss_cdemo_sk = customer_demographics.cd_demo_sk and
       customer_demographics.cd_gender = 'F' and
       customer_demographics.cd_marital_status = 'D' and
       customer_demographics.cd_education_status = 'Unknown' and
       date_dim.d_year = 1998 and
       store.s_state in ('KS','AL', 'MN', 'AL', 'SC', 'VT')
 group by i_item_id, s_state
 order by i_item_id
         ,s_state
 limit 100;


-- query3.sql
select  dt.d_year -- query3.sql
       ,item.i_brand_id brand_id 
       ,item.i_brand brand
       ,sum(ss_ext_sales_price) sum_agg
 from  date_dim dt 
      ,store_sales
      ,item
 where dt.d_date_sk = store_sales.ss_sold_date_sk
   and store_sales.ss_item_sk = item.i_item_sk
   and item.i_manufact_id = 436
   and dt.d_moy=12
 group by dt.d_year
      ,item.i_brand
      ,item.i_brand_id
 order by dt.d_year
         ,sum_agg desc
         ,brand_id
 limit 100;


-- query31.sql
with ss as -- query31.sql
 (select ca_county,d_qoy, d_year,sum(ss_ext_sales_price) as store_sales
 from store_sales,date_dim,customer_address
 where ss_sold_date_sk = d_date_sk
  and ss_addr_sk=ca_address_sk
 group by ca_county,d_qoy, d_year),
 ws as
 (select ca_county,d_qoy, d_year,sum(ws_ext_sales_price) as web_sales
 from web_sales,date_dim,customer_address
 where ws_sold_date_sk = d_date_sk
  and ws_bill_addr_sk=ca_address_sk
 group by ca_county,d_qoy, d_year)
 select
        ss1.ca_county
       ,ss1.d_year
       ,ws2.web_sales/ws1.web_sales web_q1_q2_increase
       ,ss2.store_sales/ss1.store_sales store_q1_q2_increase
       ,ws3.web_sales/ws2.web_sales web_q2_q3_increase
       ,ss3.store_sales/ss2.store_sales store_q2_q3_increase
 from
        ss ss1
       ,ss ss2
       ,ss ss3
       ,ws ws1
       ,ws ws2
       ,ws ws3
 where
    ss1.d_qoy = 1
    and ss1.d_year = 1998
    and ss1.ca_county = ss2.ca_county
    and ss2.d_qoy = 2
    and ss2.d_year = 1998
 and ss2.ca_county = ss3.ca_county
    and ss3.d_qoy = 3
    and ss3.d_year = 1998
    and ss1.ca_county = ws1.ca_county
    and ws1.d_qoy = 1
    and ws1.d_year = 1998
    and ws1.ca_county = ws2.ca_county
    and ws2.d_qoy = 2
    and ws2.d_year = 1998
    and ws1.ca_county = ws3.ca_county
    and ws3.d_qoy = 3
    and ws3.d_year =1998
    and case when ws1.web_sales > 0 then ws2.web_sales/ws1.web_sales else null end 
       > case when ss1.store_sales > 0 then ss2.store_sales/ss1.store_sales else null end
    and case when ws2.web_sales > 0 then ws3.web_sales/ws2.web_sales else null end
       > case when ss2.store_sales > 0 then ss3.store_sales/ss2.store_sales else null end
 order by web_q1_q2_increase;


-- query32.sql
SELECT sum(cs1.cs_ext_discount_amt) as excess_discount_amount -- query32.sql
FROM (SELECT cs.cs_item_sk as cs_item_sk,
                             cs.cs_ext_discount_amt as cs_ext_discount_amt
             FROM catalog_sales cs
             JOIN date_dim d ON (d.d_date_sk = cs.cs_sold_date_sk)
             WHERE d.d_date between '2000-01-27' and '2000-04-27') cs1
JOIN item i ON (i.i_item_sk = cs1.cs_item_sk)
JOIN (SELECT cs2.cs_item_sk as cs_item_sk,
                          1.3 * avg(cs_ext_discount_amt) as avg_cs_ext_discount_amt
           FROM (SELECT cs.cs_item_sk as cs_item_sk,
                                        cs.cs_ext_discount_amt as cs_ext_discount_amt
                        FROM catalog_sales cs
                        JOIN date_dim d ON (d.d_date_sk = cs.cs_sold_date_sk)
                        WHERE d.d_date between '2000-01-27' and '2000-04-27') cs2
                        GROUP BY cs2.cs_item_sk) tmp1
ON (i.i_item_sk = tmp1.cs_item_sk)
WHERE i.i_manufact_id = 436 and
               cs1.cs_ext_discount_amt > tmp1.avg_cs_ext_discount_amt;


-- query34.sql
select c_last_name -- query34.sql
       ,c_first_name
       ,c_salutation
       ,c_preferred_cust_flag
       ,ss_ticket_number
       ,cnt from
   (select ss_ticket_number
          ,ss_customer_sk
          ,count(*) cnt
    from store_sales,date_dim,store,household_demographics
    where store_sales.ss_sold_date_sk = date_dim.d_date_sk
    and store_sales.ss_store_sk = store.s_store_sk  
    and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    and (date_dim.d_dom between 1 and 3 or date_dim.d_dom between 25 and 28)
    and (household_demographics.hd_buy_potential = '1001-5000' or
         household_demographics.hd_buy_potential = '5001-10000')
    and household_demographics.hd_vehicle_count > 0
    and (case when household_demographics.hd_vehicle_count > 0 
	then household_demographics.hd_dep_count/ household_demographics.hd_vehicle_count 
	else null 
	end)  > 1.2
    and date_dim.d_year in (1998,1998+1,1998+2)
    and store.s_county in ('Kittitas County','Adams County','Richland County','Furnas County',
                           'Orange County','Appanoose County','Franklin Parish','Tehama County')
    group by ss_ticket_number,ss_customer_sk) dn,customer
    where dn.ss_customer_sk = customer.c_customer_sk
      and cnt between 15 and 20
    order by c_last_name,c_first_name,c_salutation,c_preferred_cust_flag desc;


-- query39a.sql
with inv as -- query39.sql
(select w_warehouse_name,w_warehouse_sk,i_item_sk,d_moy
       ,stdev,mean, case mean when 0 then null else stdev/mean end cov
 from(select w_warehouse_name,w_warehouse_sk,i_item_sk,d_moy
            ,stddev_samp(inv_quantity_on_hand) stdev,avg(inv_quantity_on_hand) mean
      from inventory
          ,item
          ,warehouse
          ,date_dim
      where inv_item_sk = i_item_sk
        and inv_warehouse_sk = w_warehouse_sk
        and inv_date_sk = d_date_sk
        and d_year =1999
      group by w_warehouse_name,w_warehouse_sk,i_item_sk,d_moy) foo
 where case mean when 0 then 0 else stdev/mean end > 1)
select inv1.w_warehouse_sk,inv1.i_item_sk,inv1.d_moy,inv1.mean, inv1.cov
        ,inv2.w_warehouse_sk,inv2.i_item_sk,inv2.d_moy,inv2.mean, inv2.cov
from inv inv1,inv inv2
where inv1.i_item_sk = inv2.i_item_sk
  and inv1.w_warehouse_sk =  inv2.w_warehouse_sk
  and inv1.d_moy=3
  and inv2.d_moy=3+1
order by inv1.w_warehouse_sk,inv1.i_item_sk,inv1.d_moy,inv1.mean,inv1.cov
        ,inv2.d_moy,inv2.mean, inv2.cov
;

-- query39b.sql
with inv as -- query39b.sql
(select w_warehouse_name,w_warehouse_sk,i_item_sk,d_moy
       ,stdev,mean, case mean when 0 then null else stdev/mean end cov
 from(select w_warehouse_name,w_warehouse_sk,i_item_sk,d_moy
            ,stddev_samp(inv_quantity_on_hand) stdev,avg(inv_quantity_on_hand) mean
      from inventory
          ,item
          ,warehouse
          ,date_dim
      where inv_item_sk = i_item_sk
        and inv_warehouse_sk = w_warehouse_sk
        and inv_date_sk = d_date_sk
        and d_year =1999
      group by w_warehouse_name,w_warehouse_sk,i_item_sk,d_moy) foo
 where case mean when 0 then 0 else stdev/mean end > 1)
select inv1.w_warehouse_sk,inv1.i_item_sk,inv1.d_moy,inv1.mean, inv1.cov
        ,inv2.w_warehouse_sk,inv2.i_item_sk,inv2.d_moy,inv2.mean, inv2.cov
from inv inv1,inv inv2
where inv1.i_item_sk = inv2.i_item_sk
  and inv1.w_warehouse_sk =  inv2.w_warehouse_sk
  and inv1.d_moy=3
  and inv2.d_moy=3+1
  and inv1.cov > 1.5
order by inv1.w_warehouse_sk,inv1.i_item_sk,inv1.d_moy,inv1.mean,inv1.cov
        ,inv2.d_moy,inv2.mean, inv2.cov
;


-- query40.sql
select  -- query40.sql
   w_state
  ,i_item_id
  ,sum(case when (cast(d_date as date) < cast ('1998-04-08' as date)) 
 		then cs_sales_price - coalesce(cr_refunded_cash,0) else 0 end) as sales_before
  ,sum(case when (cast(d_date as date) >= cast ('1998-04-08' as date)) 
 		then cs_sales_price - coalesce(cr_refunded_cash,0) else 0 end) as sales_after
 from
   catalog_sales left outer join catalog_returns on
       (catalog_sales.cs_order_number = catalog_returns.cr_order_number 
        and catalog_sales.cs_item_sk = catalog_returns.cr_item_sk)
  ,warehouse 
  ,item
  ,date_dim
 where
     i_current_price between 0.99 and 1.49
 and item.i_item_sk          = catalog_sales.cs_item_sk
 and catalog_sales.cs_warehouse_sk    = warehouse.w_warehouse_sk 
 and catalog_sales.cs_sold_date_sk    = date_dim.d_date_sk
 and date_dim.d_date between '1998-03-09' and '1998-05-08'
 group by
    w_state,i_item_id
 order by w_state,i_item_id
limit 100;


-- query42.sql
select  dt.d_year -- query42.sql
 	,item.i_category_id
 	,item.i_category
 	,sum(ss_ext_sales_price) as s
 from 	date_dim dt
 	,store_sales
 	,item
 where dt.d_date_sk = store_sales.ss_sold_date_sk
 	and store_sales.ss_item_sk = item.i_item_sk
 	and item.i_manager_id = 1  	
 	and dt.d_moy=12
 	and dt.d_year=1998
 group by 	dt.d_year
 		,item.i_category_id
 		,item.i_category
 order by       s desc,dt.d_year
 		,item.i_category_id
 		,item.i_category
limit 100 ;


-- query43.sql
select  s_store_name, s_store_id, -- query43.sql
        sum(case when (d_day_name='Sunday') then ss_sales_price else null end) sun_sales,
        sum(case when (d_day_name='Monday') then ss_sales_price else null end) mon_sales,
        sum(case when (d_day_name='Tuesday') then ss_sales_price else  null end) tue_sales,
        sum(case when (d_day_name='Wednesday') then ss_sales_price else null end) wed_sales,
        sum(case when (d_day_name='Thursday') then ss_sales_price else null end) thu_sales,
        sum(case when (d_day_name='Friday') then ss_sales_price else null end) fri_sales,
        sum(case when (d_day_name='Saturday') then ss_sales_price else null end) sat_sales
 from date_dim, store_sales, store
 where date_dim.d_date_sk = store_sales.ss_sold_date_sk and
       store.s_store_sk = store_sales.ss_store_sk and
       s_gmt_offset = -6 and
       d_year = 1998
 group by s_store_name, s_store_id
 order by s_store_name, s_store_id,sun_sales,mon_sales,tue_sales,wed_sales,thu_sales,fri_sales,sat_sales
 limit 100;

-- query45.sql
select  ca_zip, ca_county, sum(ws_sales_price) -- query45.sql
 from
    web_sales
    JOIN customer ON web_sales.ws_bill_customer_sk = customer.c_customer_sk
    JOIN customer_address ON customer.c_current_addr_sk = customer_address.ca_address_sk 
    JOIN date_dim ON web_sales.ws_sold_date_sk = date_dim.d_date_sk
    JOIN item ON web_sales.ws_item_sk = item.i_item_sk 
 where
        ( item.i_item_id in (select i_item_id
                             from item i2
                             where i2.i_item_sk in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29)
                             )
            )
        and d_qoy = 2 and d_year = 2000
 group by ca_zip, ca_county
 order by ca_zip, ca_county
 limit 100;


-- query46.sql
select  c_last_name -- query46.sql
       ,c_first_name
       ,ca_city
       ,bought_city
       ,ss_ticket_number
       ,amt,profit 
 from
   (select ss_ticket_number
          ,ss_customer_sk
          ,ca_city bought_city
          ,sum(ss_coupon_amt) amt
          ,sum(ss_net_profit) profit
    from store_sales,date_dim,store,household_demographics,customer_address 
    where store_sales.ss_sold_date_sk = date_dim.d_date_sk
    and store_sales.ss_store_sk = store.s_store_sk  
    and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    and store_sales.ss_addr_sk = customer_address.ca_address_sk
    and (household_demographics.hd_dep_count = 4 or
         household_demographics.hd_vehicle_count= 2)
    and date_dim.d_dow in (6,0)
    and date_dim.d_year in (1998,1998+1,1998+2) 
    and store.s_city in ('Rosedale','Bethlehem','Clinton','Clifton','Springfield') 
    group by ss_ticket_number,ss_customer_sk,ss_addr_sk,ca_city) dn,customer,customer_address current_addr
    where dn.ss_customer_sk = customer.c_customer_sk
      and customer.c_current_addr_sk = current_addr.ca_address_sk
      and current_addr.ca_city <> bought_city
  order by c_last_name
          ,c_first_name
          ,ca_city
          ,bought_city
          ,ss_ticket_number
  limit 100;


-- query50.sql
select  -- query50.sql
   s_store_name
  ,s_company_id
  ,s_street_number
  ,s_street_name
  ,s_street_type
  ,s_suite_number
  ,s_city
  ,s_county
  ,s_state
  ,s_zip
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk <= 30 ) then 1 else 0 end)  as 30days 
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk > 30) and 
                 (sr_returned_date_sk - ss_sold_date_sk <= 60) then 1 else 0 end )  as 3160days 
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk > 60) and 
                 (sr_returned_date_sk - ss_sold_date_sk <= 90) then 1 else 0 end)  as 6190days 
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk > 90) and
                 (sr_returned_date_sk - ss_sold_date_sk <= 120) then 1 else 0 end)  as 91120days 
  ,sum(case when (sr_returned_date_sk - ss_sold_date_sk  > 120) then 1 else 0 end)  as 120days 
from
   store_sales
  ,store_returns
  ,store
  ,date_dim d1
  ,date_dim d2
where
    d2.d_year = 2000
and d2.d_moy  = 9
and store_sales.ss_ticket_number = store_returns.sr_ticket_number
and store_sales.ss_item_sk = store_returns.sr_item_sk
and store_sales.ss_sold_date_sk   = d1.d_date_sk
and sr_returned_date_sk   = d2.d_date_sk
and store_sales.ss_customer_sk = store_returns.sr_customer_sk
and store_sales.ss_store_sk = store.s_store_sk
group by
   s_store_name
  ,s_company_id
  ,s_street_number
  ,s_street_name
  ,s_street_type
  ,s_suite_number
  ,s_city
  ,s_county
  ,s_state
  ,s_zip
order by s_store_name
        ,s_company_id
        ,s_street_number
        ,s_street_name
        ,s_street_type
        ,s_suite_number
        ,s_city
        ,s_county
        ,s_state
        ,s_zip
limit 100;


-- query52.sql

select  dt.d_year -- query52.sql
 	,item.i_brand_id brand_id
 	,item.i_brand brand
 	,sum(ss_ext_sales_price) ext_price
 from date_dim dt
     ,store_sales
     ,item
 where dt.d_date_sk = store_sales.ss_sold_date_sk
    and store_sales.ss_item_sk = item.i_item_sk
    and item.i_manager_id = 1
    and dt.d_moy=12
    and dt.d_year=1998
	 group by dt.d_year
 	,item.i_brand
 	,item.i_brand_id
 order by dt.d_year
 	,ext_price desc
 	,brand_id
limit 100 ;

-- query54.sql
with my_customers as ( -- query54.sql
 select  c_customer_sk
        , c_current_addr_sk
 from   
        ( select cs_sold_date_sk sold_date_sk,
                 cs_bill_customer_sk customer_sk,
                 cs_item_sk item_sk
          from   catalog_sales
          union all
          select ws_sold_date_sk sold_date_sk,
                 ws_bill_customer_sk customer_sk,
                 ws_item_sk item_sk
          from   web_sales
         ) cs_or_ws_sales,
         item,
         date_dim,
         customer
 where   sold_date_sk = d_date_sk
         and item_sk = i_item_sk
         and i_category = 'Jewelry'
         and i_class = 'football'
         and c_customer_sk = cs_or_ws_sales.customer_sk
         and d_moy = 3
         and d_year = 2000
         group by  c_customer_sk
        , c_current_addr_sk
 )
 , my_revenue as (
 select c_customer_sk,
        sum(ss_ext_sales_price) as revenue
 from   my_customers,
        store_sales,
        customer_address,
        store,
        date_dim
 where  c_current_addr_sk = ca_address_sk
        and ca_county = s_county
        and ca_state = s_state
        and ss_sold_date_sk = d_date_sk
        and c_customer_sk = ss_customer_sk
        and d_month_seq between (1203)
                           and  (1205)
 group by c_customer_sk
 )
 , segments as
 (select cast((revenue/50) as int) as segment
  from   my_revenue
 )
  select  segment, count(*) as num_customers, segment*50 as segment_base
 from segments
 group by segment
 order by segment, num_customers
 limit 100;


-- query55.sql
select  i_brand_id brand_id, i_brand brand, -- query55.sql
 	sum(ss_ext_sales_price) ext_price
 from date_dim, store_sales, item
 where date_dim.d_date_sk = store_sales.ss_sold_date_sk
 	and store_sales.ss_item_sk = item.i_item_sk
 	and i_manager_id=36
 	and d_moy=12
 	and d_year=2001
 group by i_brand, i_brand_id
 order by ext_price desc, i_brand_id
limit 100 ;

-- query56.sql
with ss as ( -- query56.sql
 select i_item_id,sum(ss_ext_sales_price) total_sales
 from
        store_sales,
        date_dim,
         customer_address,
         item
 where item.i_item_id in (select
     i.i_item_id
from item i
where i_color in ('purple','burlywood','indian'))
 and     ss_item_sk              = i_item_sk
 and     ss_sold_date_sk         = d_date_sk
 and     d_year                  = 2001
 and     d_moy                   = 1
 and     ss_addr_sk              = ca_address_sk
 and     ca_gmt_offset           = -6 
 group by i_item_id),
 cs as (
 select i_item_id,sum(cs_ext_sales_price) total_sales
 from
        catalog_sales,
        date_dim,
         customer_address,
         item
 where
         item.i_item_id               in (select
  i.i_item_id
from item i
where i_color in ('purple','burlywood','indian'))
 and     cs_item_sk              = i_item_sk
 and     cs_sold_date_sk         = d_date_sk
 and     d_year                  = 2001
 and     d_moy                   = 1
 and     cs_bill_addr_sk         = ca_address_sk
 and     ca_gmt_offset           = -6 
 group by i_item_id),
 ws as (
 select i_item_id,sum(ws_ext_sales_price) total_sales
 from
        web_sales,
        date_dim,
         customer_address,
         item
 where
         item.i_item_id               in (select
  i.i_item_id
from item i
where i_color in ('purple','burlywood','indian'))
 and     ws_item_sk              = i_item_sk
 and     ws_sold_date_sk         = d_date_sk
 and     d_year                  = 2001
 and     d_moy                   = 1
 and     ws_bill_addr_sk         = ca_address_sk
 and     ca_gmt_offset           = -6
 group by i_item_id)
  select  i_item_id ,sum(total_sales) total_sales
 from  (select * from ss 
        union all
        select * from cs 
        union all
        select * from ws) tmp1
 group by i_item_id
 order by total_sales
 limit 100;


-- query58.sql
  select  ss_items.item_id -- query58.sql
       ,ss_item_rev
       ,ss_item_rev/(ss_item_rev+cs_item_rev+ws_item_rev)/3 * 100 ss_dev
       ,cs_item_rev
       ,cs_item_rev/(ss_item_rev+cs_item_rev+ws_item_rev)/3 * 100 cs_dev
       ,ws_item_rev
       ,ws_item_rev/(ss_item_rev+cs_item_rev+ws_item_rev)/3 * 100 ws_dev
       ,(ss_item_rev+cs_item_rev+ws_item_rev)/3 average
FROM
( select i_item_id item_id ,sum(ss_ext_sales_price) as ss_item_rev 
 from store_sales
     JOIN item ON store_sales.ss_item_sk = item.i_item_sk
     JOIN date_dim ON store_sales.ss_sold_date_sk = date_dim.d_date_sk
     JOIN (select d1.d_date
                 from date_dim d1 JOIN date_dim d2 ON d1.d_week_seq = d2.d_week_seq
                 where d2.d_date = '1998-08-04') sub ON date_dim.d_date = sub.d_date
 group by i_item_id ) ss_items
JOIN
( select i_item_id item_id ,sum(cs_ext_sales_price) as cs_item_rev 
 from catalog_sales
     JOIN item ON catalog_sales.cs_item_sk = item.i_item_sk
     JOIN date_dim ON catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
     JOIN (select d1.d_date
                 from date_dim d1 JOIN date_dim d2 ON d1.d_week_seq = d2.d_week_seq
                 where d2.d_date = '1998-08-04') sub ON date_dim.d_date = sub.d_date
 group by i_item_id ) cs_items
ON ss_items.item_id=cs_items.item_id
JOIN
( select i_item_id item_id ,sum(ws_ext_sales_price) as ws_item_rev 
 from web_sales
     JOIN item ON web_sales.ws_item_sk = item.i_item_sk
     JOIN date_dim ON web_sales.ws_sold_date_sk = date_dim.d_date_sk
     JOIN (select d1.d_date
                 from date_dim d1 JOIN date_dim d2 ON d1.d_week_seq = d2.d_week_seq
                 where d2.d_date = '1998-08-04') sub ON date_dim.d_date = sub.d_date
 group by i_item_id ) ws_items
ON ss_items.item_id=ws_items.item_id 
 where
       ss_item_rev between 0.9 * cs_item_rev and 1.1 * cs_item_rev
   and ss_item_rev between 0.9 * ws_item_rev and 1.1 * ws_item_rev
   and cs_item_rev between 0.9 * ss_item_rev and 1.1 * ss_item_rev
   and cs_item_rev between 0.9 * ws_item_rev and 1.1 * ws_item_rev
   and ws_item_rev between 0.9 * ss_item_rev and 1.1 * ss_item_rev
   and ws_item_rev between 0.9 * cs_item_rev and 1.1 * cs_item_rev
 order by item_id ,ss_item_rev
 limit 100;



-- query60.sql
with ss as ( -- query60.sql
 select
          i_item_id,sum(ss_ext_sales_price) total_sales
 from
        store_sales,
        date_dim,
         customer_address,
         item
 where
         item.i_item_id in (select
  i.i_item_id
from
 item i
where i_category in ('Children'))
 and     ss_item_sk              = i_item_sk
 and     ss_sold_date_sk         = d_date_sk
 and     d_year                  = 1999
 and     d_moy                   = 9
 and     ss_addr_sk              = ca_address_sk
 and     ca_gmt_offset           = -6 
 group by i_item_id),
 cs as (
 select
          i_item_id,sum(cs_ext_sales_price) total_sales
 from
        catalog_sales,
        date_dim,
         customer_address,
         item
 where
         item.i_item_id               in (select
  i.i_item_id
from
 item i
where i_category in ('Children'))
 and     cs_item_sk              = i_item_sk
 and     cs_sold_date_sk         = d_date_sk
 and     d_year                  = 1999
 and     d_moy                   = 9
 and     cs_bill_addr_sk         = ca_address_sk
 and     ca_gmt_offset           = -6 
 group by i_item_id),
 ws as (
 select
          i_item_id,sum(ws_ext_sales_price) total_sales
 from
        web_sales,
        date_dim,
         customer_address,
         item
 where
         item.i_item_id               in (select
  i.i_item_id
from
 item i
where i_category in ('Children'))
 and     ws_item_sk              = i_item_sk
 and     ws_sold_date_sk         = d_date_sk
 and     d_year                  = 1999
 and     d_moy                   = 9
 and     ws_bill_addr_sk         = ca_address_sk
 and     ca_gmt_offset           = -6
 group by i_item_id)
  select   
  i_item_id
,sum(total_sales) total_sales
 from  (select * from ss 
        union all
        select * from cs 
        union all
        select * from ws) tmp1
 group by i_item_id
 order by i_item_id
      ,total_sales
 limit 100;


-- query66.sql
select   -- query66.sql
         w_warehouse_name
 	,w_warehouse_sq_ft
 	,w_city
 	,w_county
 	,w_state
 	,w_country
        ,ship_carriers
        ,year
 	,sum(jan_sales) as jan_sales
 	,sum(feb_sales) as feb_sales
 	,sum(mar_sales) as mar_sales
 	,sum(apr_sales) as apr_sales
 	,sum(may_sales) as may_sales
 	,sum(jun_sales) as jun_sales
 	,sum(jul_sales) as jul_sales
 	,sum(aug_sales) as aug_sales
 	,sum(sep_sales) as sep_sales
 	,sum(oct_sales) as oct_sales
 	,sum(nov_sales) as nov_sales
 	,sum(dec_sales) as dec_sales
 	,sum(jan_sales/w_warehouse_sq_ft) as jan_sales_per_sq_foot
 	,sum(feb_sales/w_warehouse_sq_ft) as feb_sales_per_sq_foot
 	,sum(mar_sales/w_warehouse_sq_ft) as mar_sales_per_sq_foot
 	,sum(apr_sales/w_warehouse_sq_ft) as apr_sales_per_sq_foot
 	,sum(may_sales/w_warehouse_sq_ft) as may_sales_per_sq_foot
 	,sum(jun_sales/w_warehouse_sq_ft) as jun_sales_per_sq_foot
 	,sum(jul_sales/w_warehouse_sq_ft) as jul_sales_per_sq_foot
 	,sum(aug_sales/w_warehouse_sq_ft) as aug_sales_per_sq_foot
 	,sum(sep_sales/w_warehouse_sq_ft) as sep_sales_per_sq_foot
 	,sum(oct_sales/w_warehouse_sq_ft) as oct_sales_per_sq_foot
 	,sum(nov_sales/w_warehouse_sq_ft) as nov_sales_per_sq_foot
 	,sum(dec_sales/w_warehouse_sq_ft) as dec_sales_per_sq_foot
 	,sum(jan_net) as jan_net
 	,sum(feb_net) as feb_net
 	,sum(mar_net) as mar_net
 	,sum(apr_net) as apr_net
 	,sum(may_net) as may_net
 	,sum(jun_net) as jun_net
 	,sum(jul_net) as jul_net
 	,sum(aug_net) as aug_net
 	,sum(sep_net) as sep_net
 	,sum(oct_net) as oct_net
 	,sum(nov_net) as nov_net
 	,sum(dec_net) as dec_net
 from (
    select 
 	w_warehouse_name
 	,w_warehouse_sq_ft
 	,w_city
 	,w_county
 	,w_state
 	,w_country
 	,concat('DIAMOND', ',', 'AIRBORNE') as ship_carriers
        ,d_year as year
 	,sum(case when d_moy = 1 
 		then ws_sales_price* ws_quantity else 0 end) as jan_sales
 	,sum(case when d_moy = 2 
 		then ws_sales_price* ws_quantity else 0 end) as feb_sales
 	,sum(case when d_moy = 3 
 		then ws_sales_price* ws_quantity else 0 end) as mar_sales
 	,sum(case when d_moy = 4 
 		then ws_sales_price* ws_quantity else 0 end) as apr_sales
 	,sum(case when d_moy = 5 
 		then ws_sales_price* ws_quantity else 0 end) as may_sales
 	,sum(case when d_moy = 6 
 		then ws_sales_price* ws_quantity else 0 end) as jun_sales
 	,sum(case when d_moy = 7 
 		then ws_sales_price* ws_quantity else 0 end) as jul_sales
 	,sum(case when d_moy = 8 
 		then ws_sales_price* ws_quantity else 0 end) as aug_sales
 	,sum(case when d_moy = 9 
 		then ws_sales_price* ws_quantity else 0 end) as sep_sales
 	,sum(case when d_moy = 10 
 		then ws_sales_price* ws_quantity else 0 end) as oct_sales
 	,sum(case when d_moy = 11
 		then ws_sales_price* ws_quantity else 0 end) as nov_sales
 	,sum(case when d_moy = 12
 		then ws_sales_price* ws_quantity else 0 end) as dec_sales
 	,sum(case when d_moy = 1 
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as jan_net
 	,sum(case when d_moy = 2
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as feb_net
 	,sum(case when d_moy = 3 
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as mar_net
 	,sum(case when d_moy = 4 
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as apr_net
 	,sum(case when d_moy = 5 
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as may_net
 	,sum(case when d_moy = 6 
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as jun_net
 	,sum(case when d_moy = 7 
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as jul_net
 	,sum(case when d_moy = 8 
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as aug_net
 	,sum(case when d_moy = 9 
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as sep_net
 	,sum(case when d_moy = 10 
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as oct_net
 	,sum(case when d_moy = 11
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as nov_net
 	,sum(case when d_moy = 12
 		then ws_net_paid_inc_tax * ws_quantity else 0 end) as dec_net
     from
          web_sales
         ,warehouse
         ,date_dim
         ,time_dim
 	  ,ship_mode
     where
            web_sales.ws_warehouse_sk =  warehouse.w_warehouse_sk
        and web_sales.ws_sold_date_sk = date_dim.d_date_sk
        and web_sales.ws_sold_time_sk = time_dim.t_time_sk
 	and web_sales.ws_ship_mode_sk = ship_mode.sm_ship_mode_sk
        and d_year = 2002
 	and t_time between 49530 and 49530+28800 
 	and sm_carrier in ('DIAMOND','AIRBORNE')
     group by 
        w_warehouse_name
 	,w_warehouse_sq_ft
 	,w_city
 	,w_county
 	,w_state
 	,w_country
       ,d_year
 union all
    select 
 	w_warehouse_name
 	,w_warehouse_sq_ft
 	,w_city
 	,w_county
 	,w_state
 	,w_country
        ,concat('DIAMOND', ',', 'AIRBORNE') as ship_carriers
       ,d_year as year
 	,sum(case when d_moy = 1 
 		then cs_ext_sales_price* cs_quantity else 0 end) as jan_sales
 	,sum(case when d_moy = 2 
 		then cs_ext_sales_price* cs_quantity else 0 end) as feb_sales
 	,sum(case when d_moy = 3 
 		then cs_ext_sales_price* cs_quantity else 0 end) as mar_sales
 	,sum(case when d_moy = 4 
 		then cs_ext_sales_price* cs_quantity else 0 end) as apr_sales
 	,sum(case when d_moy = 5 
 		then cs_ext_sales_price* cs_quantity else 0 end) as may_sales
 	,sum(case when d_moy = 6 
 		then cs_ext_sales_price* cs_quantity else 0 end) as jun_sales
 	,sum(case when d_moy = 7 
 		then cs_ext_sales_price* cs_quantity else 0 end) as jul_sales
 	,sum(case when d_moy = 8 
 		then cs_ext_sales_price* cs_quantity else 0 end) as aug_sales
 	,sum(case when d_moy = 9 
 		then cs_ext_sales_price* cs_quantity else 0 end) as sep_sales
 	,sum(case when d_moy = 10 
 		then cs_ext_sales_price* cs_quantity else 0 end) as oct_sales
 	,sum(case when d_moy = 11
 		then cs_ext_sales_price* cs_quantity else 0 end) as nov_sales
 	,sum(case when d_moy = 12
 		then cs_ext_sales_price* cs_quantity else 0 end) as dec_sales
 	,sum(case when d_moy = 1 
 		then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as jan_net
 	,sum(case when d_moy = 2 
 		then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as feb_net
 	,sum(case when d_moy = 3 
 		then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as mar_net
 	,sum(case when d_moy = 4 
 		then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as apr_net
 	,sum(case when d_moy = 5 
 		then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as may_net
 	,sum(case when d_moy = 6 
 		then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as jun_net
 	,sum(case when d_moy = 7 
 		then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as jul_net
 	,sum(case when d_moy = 8 
 		then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as aug_net
 	,sum(case when d_moy = 9 
 		then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as sep_net
 	,sum(case when d_moy = 10 
 		then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as oct_net
 	,sum(case when d_moy = 11
 		then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as nov_net
 	,sum(case when d_moy = 12
 		then cs_net_paid_inc_ship_tax * cs_quantity else 0 end) as dec_net
     from
          catalog_sales
         ,warehouse
         ,date_dim
         ,time_dim
 	 ,ship_mode
     where
            catalog_sales.cs_warehouse_sk =  warehouse.w_warehouse_sk
        and catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
        and catalog_sales.cs_sold_time_sk = time_dim.t_time_sk
 	and catalog_sales.cs_ship_mode_sk = ship_mode.sm_ship_mode_sk
        and d_year = 2002
 	and t_time between 49530 AND 49530+28800 
 	and sm_carrier in ('DIAMOND','AIRBORNE')
     group by 
        w_warehouse_name
 	,w_warehouse_sq_ft
 	,w_city
 	,w_county
 	,w_state
 	,w_country
       ,d_year
 ) x
 group by 
        w_warehouse_name
 	,w_warehouse_sq_ft
 	,w_city
 	,w_county
 	,w_state
 	,w_country
 	,ship_carriers
       ,year
 order by w_warehouse_name
 limit 100;

-- query67.sql
select  * -- query67.sql
from (select i_category
            ,i_class
            ,i_brand
            ,i_product_name
            ,d_year
            ,d_qoy
            ,d_moy
            ,s_store_id
            ,sumsales
            ,rank() over (partition by i_category order by sumsales desc) rk
      from (select i_category
                  ,i_class
                  ,i_brand
                  ,i_product_name
                  ,d_year
                  ,d_qoy
                  ,d_moy
                  ,s_store_id
                  ,sum(coalesce(ss_sales_price*ss_quantity,0)) sumsales
            from store_sales
                ,date_dim
                ,store
                ,item
       where  store_sales.ss_sold_date_sk=date_dim.d_date_sk
          and store_sales.ss_item_sk=item.i_item_sk
          and store_sales.ss_store_sk = store.s_store_sk
          and d_month_seq between 1193 and 1193+11
       group by i_category, i_class, i_brand, i_product_name, d_year, d_qoy, d_moy,s_store_id with rollup)dw1) dw2
where rk <= 100
order by i_category
        ,i_class
        ,i_brand
        ,i_product_name
        ,d_year
        ,d_qoy
        ,d_moy
        ,s_store_id
        ,sumsales
        ,rk
limit 100;

-- query68.sql
select  c_last_name -- query68.sql
       ,c_first_name
       ,ca_city
       ,bought_city
       ,ss_ticket_number
       ,extended_price
       ,extended_tax
       ,list_price
 from (select ss_ticket_number
             ,ss_customer_sk
             ,ca_city bought_city
             ,sum(ss_ext_sales_price) extended_price 
             ,sum(ss_ext_list_price) list_price
             ,sum(ss_ext_tax) extended_tax 
       from store_sales
           ,date_dim
           ,store
           ,household_demographics
           ,customer_address 
       where store_sales.ss_sold_date_sk = date_dim.d_date_sk
         and store_sales.ss_store_sk = store.s_store_sk  
        and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
        and store_sales.ss_addr_sk = customer_address.ca_address_sk
        and date_dim.d_dom between 1 and 2 
        and (household_demographics.hd_dep_count = 4 or
             household_demographics.hd_vehicle_count= 2)
        and date_dim.d_year in (1998,1998+1,1998+2)
        and store.s_city in ('Rosedale','Bethlehem')
       group by ss_ticket_number
               ,ss_customer_sk
               ,ss_addr_sk,ca_city) dn
      ,customer
      ,customer_address current_addr
 where dn.ss_customer_sk = customer.c_customer_sk
   and customer.c_current_addr_sk = current_addr.ca_address_sk
   and current_addr.ca_city <> bought_city
 order by c_last_name
         ,ss_ticket_number
 limit 100;

-- query7.sql
select  i_item_id, -- query7.sql
        avg(ss_quantity) agg1,
        avg(ss_list_price) agg2,
        avg(ss_coupon_amt) agg3,
        avg(ss_sales_price) agg4 
 from store_sales, customer_demographics, date_dim, item, promotion
 where store_sales.ss_sold_date_sk = date_dim.d_date_sk and
       store_sales.ss_item_sk = item.i_item_sk and
       store_sales.ss_cdemo_sk = customer_demographics.cd_demo_sk and
       store_sales.ss_promo_sk = promotion.p_promo_sk and
       cd_gender = 'F' and 
       cd_marital_status = 'W' and
       cd_education_status = 'Primary' and
       (p_channel_email = 'N' or p_channel_event = 'N') and
       d_year = 1998 
 group by i_item_id
 order by i_item_id
 limit 100;

-- query70.sql
select  -- query70.sql
    sum(ss_net_profit) as total_sum
   ,s_state
   ,s_county
   ,grouping__id as lochierarchy
   , rank() over(partition by grouping__id, case when grouping__id == 2 then s_state end order by sum(ss_net_profit)) as rank_within_parent
from
    store_sales ss join date_dim d1 on d1.d_date_sk = ss.ss_sold_date_sk
    join store s on s.s_store_sk  = ss.ss_store_sk
 where
    d1.d_month_seq between 1193 and 1193+11
 and s.s_state in
             ( select s_state
               from  (select s_state as s_state, sum(ss_net_profit),
                             rank() over ( partition by s_state order by sum(ss_net_profit) desc) as ranking
                      from   store_sales, store, date_dim
                      where  d_month_seq between 1193 and 1193+11
                            and date_dim.d_date_sk = store_sales.ss_sold_date_sk
                            and store.s_store_sk  = store_sales.ss_store_sk
                      group by s_state
                     ) tmp1 
               where ranking <= 5
             )
 group by s_state,s_county with rollup
order by
   lochierarchy desc
  ,case when lochierarchy = 0 then s_state end
  ,rank_within_parent
 limit 100;



-- query71.sql
select i_brand_id brand_id, i_brand brand,t_hour,t_minute, -- query71.sql
 	sum(ext_price) ext_price
 from item JOIN (select ws_ext_sales_price as ext_price, 
                        ws_sold_date_sk as sold_date_sk,
                        ws_item_sk as sold_item_sk,
                        ws_sold_time_sk as time_sk  
                 from web_sales,date_dim
                 where date_dim.d_date_sk = web_sales.ws_sold_date_sk
                   and d_moy=12
                   and d_year=2001
                 union all
                 select cs_ext_sales_price as ext_price,
                        cs_sold_date_sk as sold_date_sk,
                        cs_item_sk as sold_item_sk,
                        cs_sold_time_sk as time_sk
                 from catalog_sales,date_dim
                 where date_dim.d_date_sk = catalog_sales.cs_sold_date_sk
                   and d_moy=12
                   and d_year=2001
                 union all
                 select ss_ext_sales_price as ext_price,
                        ss_sold_date_sk as sold_date_sk,
                        ss_item_sk as sold_item_sk,
                        ss_sold_time_sk as time_sk
                 from store_sales,date_dim
                 where date_dim.d_date_sk = store_sales.ss_sold_date_sk
                   and d_moy=12
                   and d_year=2001
                 ) tmp ON tmp.sold_item_sk = item.i_item_sk
 JOIN time_dim ON tmp.time_sk = time_dim.t_time_sk
 where
       i_manager_id=1
   and (t_meal_time = 'breakfast' or t_meal_time = 'dinner')
 group by i_brand, i_brand_id,t_hour,t_minute
 order by ext_price desc, i_brand_id
 ;


-- query73.sql
select c_last_name -- query73.sql
       ,c_first_name
       ,c_salutation
       ,c_preferred_cust_flag 
       ,ss_ticket_number
       ,cnt from
   (select ss_ticket_number
          ,ss_customer_sk
          ,count(*) cnt
    from store_sales,date_dim,store,household_demographics
    where store_sales.ss_sold_date_sk = date_dim.d_date_sk
    and store_sales.ss_store_sk = store.s_store_sk  
    and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    and date_dim.d_dom between 1 and 2 
    and (household_demographics.hd_buy_potential = '1001-5000' or
         household_demographics.hd_buy_potential = '5001-10000')
    and household_demographics.hd_vehicle_count > 0
    and case when household_demographics.hd_vehicle_count > 0 then 
             household_demographics.hd_dep_count/ household_demographics.hd_vehicle_count else null end > 1
    and date_dim.d_year in (1998,1998+1,1998+2)
    and store.s_county in ('Kittitas County','Adams County','Richland County','Furnas County')
    group by ss_ticket_number,ss_customer_sk) dj,customer
    where dj.ss_customer_sk = customer.c_customer_sk
      and cnt between 1 and 5
    order by cnt desc;


-- query75.sql
WITH all_sales AS ( -- query75.sql
 SELECT d_year
       ,i_brand_id
       ,i_class_id
       ,i_category_id
       ,i_manufact_id
       ,SUM(sales_cnt) AS sales_cnt
       ,SUM(sales_amt) AS sales_amt
 FROM (SELECT d_year
             ,i_brand_id
             ,i_class_id
             ,i_category_id
             ,i_manufact_id
             ,cs_quantity - COALESCE(cr_return_quantity,0) AS sales_cnt
             ,cs_ext_sales_price - COALESCE(cr_return_amount,0.0) AS sales_amt
       FROM catalog_sales JOIN item ON i_item_sk=cs_item_sk
                          JOIN date_dim ON d_date_sk=cs_sold_date_sk
                          LEFT JOIN catalog_returns ON (cs_order_number=cr_order_number 
                                                    AND cs_item_sk=cr_item_sk)
       WHERE i_category='Sports'
       UNION ALL
       SELECT d_year
             ,i_brand_id
             ,i_class_id
             ,i_category_id
             ,i_manufact_id
             ,ss_quantity - COALESCE(sr_return_quantity,0) AS sales_cnt
             ,ss_ext_sales_price - COALESCE(sr_return_amt,0.0) AS sales_amt
       FROM store_sales JOIN item ON i_item_sk=ss_item_sk
                        JOIN date_dim ON d_date_sk=ss_sold_date_sk
                        LEFT JOIN store_returns ON (ss_ticket_number=sr_ticket_number 
                                                AND ss_item_sk=sr_item_sk)
       WHERE i_category='Sports'
       UNION ALL
       SELECT d_year
             ,i_brand_id
             ,i_class_id
             ,i_category_id
             ,i_manufact_id
             ,ws_quantity - COALESCE(wr_return_quantity,0) AS sales_cnt
             ,ws_ext_sales_price - COALESCE(wr_return_amt,0.0) AS sales_amt
       FROM web_sales JOIN item ON i_item_sk=ws_item_sk
                      JOIN date_dim ON d_date_sk=ws_sold_date_sk
                      LEFT JOIN web_returns ON (ws_order_number=wr_order_number 
                                            AND ws_item_sk=wr_item_sk)
       WHERE i_category='Sports') sales_detail
 GROUP BY d_year, i_brand_id, i_class_id, i_category_id, i_manufact_id)
 SELECT  prev_yr.d_year AS prev_year
                          ,curr_yr.d_year AS year
                          ,curr_yr.i_brand_id
                          ,curr_yr.i_class_id
                          ,curr_yr.i_category_id
                          ,curr_yr.i_manufact_id
                          ,prev_yr.sales_cnt AS prev_yr_cnt
                          ,curr_yr.sales_cnt AS curr_yr_cnt
                          ,curr_yr.sales_cnt-prev_yr.sales_cnt AS sales_cnt_diff
                          ,curr_yr.sales_amt-prev_yr.sales_amt AS sales_amt_diff
 FROM all_sales curr_yr, all_sales prev_yr
 WHERE curr_yr.i_brand_id=prev_yr.i_brand_id
   AND curr_yr.i_class_id=prev_yr.i_class_id
   AND curr_yr.i_category_id=prev_yr.i_category_id
   AND curr_yr.i_manufact_id=prev_yr.i_manufact_id
   AND curr_yr.d_year=2002
   AND prev_yr.d_year=2002-1
   AND CAST(curr_yr.sales_cnt AS DECIMAL(17,2))/CAST(prev_yr.sales_cnt AS DECIMAL(17,2))<0.9
 ORDER BY sales_cnt_diff
 limit 100;

-- query76.sql
select  channel, col_name, d_year, d_qoy, i_category, COUNT(*) sales_cnt, SUM(ext_sales_price) sales_amt FROM ( -- query76.sql
        SELECT 'store' as channel, 'ss_addr_sk' col_name, d_year, d_qoy, i_category, ss_ext_sales_price ext_sales_price
         FROM store_sales, item, date_dim
         WHERE ss_addr_sk IS NULL
           AND store_sales.ss_sold_date_sk=date_dim.d_date_sk
           AND store_sales.ss_item_sk=item.i_item_sk
        UNION ALL
        SELECT 'web' as channel, 'ws_web_page_sk' col_name, d_year, d_qoy, i_category, ws_ext_sales_price ext_sales_price
         FROM web_sales, item, date_dim
         WHERE ws_web_page_sk IS NULL
           AND web_sales.ws_sold_date_sk=date_dim.d_date_sk
           AND web_sales.ws_item_sk=item.i_item_sk
        UNION ALL
        SELECT 'catalog' as channel, 'cs_warehouse_sk' col_name, d_year, d_qoy, i_category, cs_ext_sales_price ext_sales_price
         FROM catalog_sales, item, date_dim
         WHERE cs_warehouse_sk IS NULL
           AND catalog_sales.cs_sold_date_sk=date_dim.d_date_sk
           AND catalog_sales.cs_item_sk=item.i_item_sk) foo
GROUP BY channel, col_name, d_year, d_qoy, i_category
ORDER BY channel, col_name, d_year, d_qoy, i_category
limit 100;


-- query79.sql
select  -- query79.sql
  c_last_name,c_first_name,substr(s_city,1,30) sub,ss_ticket_number,amt,profit
  from
   (select ss_ticket_number
          ,ss_customer_sk
          ,store.s_city
          ,sum(ss_coupon_amt) amt
          ,sum(ss_net_profit) profit
    from store_sales,date_dim,store,household_demographics
    where store_sales.ss_sold_date_sk = date_dim.d_date_sk
    and store_sales.ss_store_sk = store.s_store_sk  
    and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
    and (household_demographics.hd_dep_count = 8 or household_demographics.hd_vehicle_count > 0)
    and date_dim.d_dow = 1
    and date_dim.d_year in (1998,1998+1,1998+2) 
    and store.s_number_employees between 200 and 295
    group by ss_ticket_number,ss_customer_sk,ss_addr_sk,store.s_city) ms,customer
    where ms.ss_customer_sk = customer.c_customer_sk
 order by c_last_name,c_first_name,sub, profit
limit 100;


-- query80.sql
with ssr as -- query80.sql
 (select  s_store_id as store_id,
          sum(ss_ext_sales_price) as sales,
          sum(coalesce(sr_return_amt, 0)) as returns,
          sum(ss_net_profit - coalesce(sr_net_loss, 0)) as profit
  from store_sales left outer join store_returns on
         (ss_item_sk = sr_item_sk and ss_ticket_number = sr_ticket_number),
     date_dim,
     store,
     item,
     promotion
 where ss_sold_date_sk = d_date_sk
       and d_date between cast('1998-08-04' as date) 
                  and (cast('1998-09-04' as date))
       and ss_store_sk = s_store_sk
       and ss_item_sk = i_item_sk
       and i_current_price > 50
       and ss_promo_sk = p_promo_sk
       and p_channel_tv = 'N'
 group by s_store_id)
 ,
 csr as
 (select  cp_catalog_page_id as catalog_page_id,
          sum(cs_ext_sales_price) as sales,
          sum(coalesce(cr_return_amount, 0)) as returns,
          sum(cs_net_profit - coalesce(cr_net_loss, 0)) as profit
  from catalog_sales left outer join catalog_returns on
         (cs_item_sk = cr_item_sk and cs_order_number = cr_order_number),
     date_dim,
     catalog_page,
     item,
     promotion
 where cs_sold_date_sk = d_date_sk
       and d_date between cast('1998-08-04' as date)
                  and (cast('1998-09-04' as date))
        and cs_catalog_page_sk = cp_catalog_page_sk
       and cs_item_sk = i_item_sk
       and i_current_price > 50
       and cs_promo_sk = p_promo_sk
       and p_channel_tv = 'N'
group by cp_catalog_page_id)
 ,
 wsr as
 (select  web_site_id,
          sum(ws_ext_sales_price) as sales,
          sum(coalesce(wr_return_amt, 0)) as returns,
          sum(ws_net_profit - coalesce(wr_net_loss, 0)) as profit
  from web_sales left outer join web_returns on
         (ws_item_sk = wr_item_sk and ws_order_number = wr_order_number),
     date_dim,
     web_site,
     item,
     promotion
 where ws_sold_date_sk = d_date_sk
       and d_date between cast('1998-08-04' as date)
                  and (cast('1998-09-04' as date))
        and ws_web_site_sk = web_site_sk
       and ws_item_sk = i_item_sk
       and i_current_price > 50
       and ws_promo_sk = p_promo_sk
       and p_channel_tv = 'N'
group by web_site_id)
  select  channel
        , id
        , sum(sales) as sales
        , sum(returns) as returns
        , sum(profit) as profit
 from 
 (select 'store channel' as channel
        , concat('store', store_id) as id
        , sales
        , returns
        , profit
 from   ssr
 union all
 select 'catalog channel' as channel
        , concat('catalog_page', catalog_page_id) as id
        , sales
        , returns
        , profit
 from  csr
 union all
 select 'web channel' as channel
        , concat('web_site', web_site_id) as id
        , sales
        , returns
        , profit
 from   wsr
 ) x
 group by channel, id with rollup
 order by channel
         ,id
 limit 100;


-- query82.sql
select  i_item_id -- query82.sql
       ,i_item_desc
       ,i_current_price
 from item, inventory, date_dim, store_sales
 where i_current_price between 30 and 30+30
 and inv_item_sk = i_item_sk
 and d_date_sk=inv_date_sk
 and d_date between '2002-05-30' and '2002-07-30'
 and i_manufact_id in (437,129,727,663)
 and inv_quantity_on_hand between 100 and 500
 and ss_item_sk = i_item_sk
 group by i_item_id,i_item_desc,i_current_price
 order by i_item_id
 limit 100;


-- query84.sql
select  c_customer_id as customer_id -- query84.sql
       ,concat(c_last_name, ', ', c_first_name) as customername
 from customer
     ,customer_address
     ,customer_demographics
     ,household_demographics
     ,income_band
     ,store_returns
 where ca_city	        =  'Hopewell'
   and customer.c_current_addr_sk = customer_address.ca_address_sk
   and ib_lower_bound   >=  32287
   and ib_upper_bound   <=  32287 + 50000
   and income_band.ib_income_band_sk = household_demographics.hd_income_band_sk
   and customer_demographics.cd_demo_sk = customer.c_current_cdemo_sk
   and household_demographics.hd_demo_sk = customer.c_current_hdemo_sk
   and store_returns.sr_cdemo_sk = customer_demographics.cd_demo_sk
 order by customer_id
 limit 100;


-- query85.sql
select  substr(r_reason_desc,1,20) as r -- query85.sql
       ,avg(ws_quantity) wq
       ,avg(wr_refunded_cash) ref
       ,avg(wr_fee) fee
 from web_sales, web_returns, web_page, customer_demographics cd1,
      customer_demographics cd2, customer_address, date_dim, reason 
 where web_sales.ws_web_page_sk = web_page.wp_web_page_sk
   and web_sales.ws_item_sk = web_returns.wr_item_sk
   and web_sales.ws_order_number = web_returns.wr_order_number
   and web_sales.ws_sold_date_sk = date_dim.d_date_sk and d_year = 1998
   and cd1.cd_demo_sk = web_returns.wr_refunded_cdemo_sk 
   and cd2.cd_demo_sk = web_returns.wr_returning_cdemo_sk
   and customer_address.ca_address_sk = web_returns.wr_refunded_addr_sk
   and reason.r_reason_sk = web_returns.wr_reason_sk
   and
   (
    (
     cd1.cd_marital_status = 'M'
     and
     cd1.cd_marital_status = cd2.cd_marital_status
     and
     cd1.cd_education_status = '4 yr Degree'
     and 
     cd1.cd_education_status = cd2.cd_education_status
     and
     ws_sales_price between 100.00 and 150.00
    )
   or
    (
     cd1.cd_marital_status = 'D'
     and
     cd1.cd_marital_status = cd2.cd_marital_status
     and
     cd1.cd_education_status = 'Primary' 
     and
     cd1.cd_education_status = cd2.cd_education_status
     and
     ws_sales_price between 50.00 and 100.00
    )
   or
    (
     cd1.cd_marital_status = 'U'
     and
     cd1.cd_marital_status = cd2.cd_marital_status
     and
     cd1.cd_education_status = 'Advanced Degree'
     and
     cd1.cd_education_status = cd2.cd_education_status
     and
     ws_sales_price between 150.00 and 200.00
    )
   )
   and
   (
    (
     ca_country = 'United States'
     and
     ca_state in ('KY', 'GA', 'NM')
     and ws_net_profit between 100 and 200  
    )
    or
    (
     ca_country = 'United States'
     and
     ca_state in ('MT', 'OR', 'IN')
     and ws_net_profit between 150 and 300  
    )
    or
    (
     ca_country = 'United States'
     and
     ca_state in ('WI', 'MO', 'WV')
     and ws_net_profit between 50 and 250  
    )
   )
group by r_reason_desc
order by r, wq, ref, fee
limit 100;


-- query87.sql
select count(*) -- query87.sql
from (select distinct c_last_name as l1, c_first_name as f1, d_date as d1
       from store_sales
        JOIN date_dim ON store_sales.ss_sold_date_sk = date_dim.d_date_sk
        JOIN customer ON store_sales.ss_customer_sk = customer.c_customer_sk
       where 
         d_month_seq between 1193 and 1193+11
	) t1
      LEFT OUTER JOIN
      ( select distinct c_last_name as l2, c_first_name as f2, d_date as d2
       from catalog_sales
        JOIN date_dim ON catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
        JOIN customer ON catalog_sales.cs_bill_customer_sk = customer.c_customer_sk
       where 
         d_month_seq between 1193 and 1193+11
	) t2
      ON t1.l1 = t2.l2 and
       t1.f1 = t2.f2 and
       t1.d1 = t2.d2
      LEFT OUTER JOIN
      (select distinct c_last_name as l3, c_first_name as f3, d_date as d3
       from web_sales
        JOIN date_dim ON web_sales.ws_sold_date_sk = date_dim.d_date_sk
        JOIN customer ON web_sales.ws_bill_customer_sk = customer.c_customer_sk
       where 
         d_month_seq between 1193 and 1193+11
	) t3
      ON t1.l1 = t3.l3 and
       t1.f1 = t3.f3 and
       t1.d1 = t3.d3
WHERE
    l2 is null and
    l3 is null ;


-- query88.sql
select  * -- query88.sql
from
 (select count(*) h8_30_to_9
 from store_sales, household_demographics , time_dim, store
 where store_sales.ss_sold_time_sk = time_dim.t_time_sk   
     and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk 
     and store_sales.ss_store_sk = store.s_store_sk
     and time_dim.t_hour = 8
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2)) 
     and store.s_store_name = 'ese') s1,
 (select count(*) h9_to_9_30 
 from store_sales, household_demographics , time_dim, store
 where store_sales.ss_sold_time_sk = time_dim.t_time_sk
     and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
     and store_sales.ss_store_sk = store.s_store_sk 
     and time_dim.t_hour = 9 
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2))
     and store.s_store_name = 'ese') s2,
 (select count(*) h9_30_to_10 
 from store_sales, household_demographics , time_dim, store
 where store_sales.ss_sold_time_sk = time_dim.t_time_sk
     and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
     and store_sales.ss_store_sk = store.s_store_sk
     and time_dim.t_hour = 9
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2))
     and store.s_store_name = 'ese') s3,
 (select count(*) h10_to_10_30
 from store_sales, household_demographics , time_dim, store
 where store_sales.ss_sold_time_sk = time_dim.t_time_sk
     and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
     and store_sales.ss_store_sk = store.s_store_sk
     and time_dim.t_hour = 10 
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2))
     and store.s_store_name = 'ese') s4,
 (select count(*) h10_30_to_11
 from store_sales, household_demographics , time_dim, store
 where store_sales.ss_sold_time_sk = time_dim.t_time_sk
     and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
     and store_sales.ss_store_sk = store.s_store_sk
     and time_dim.t_hour = 10 
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2))
     and store.s_store_name = 'ese') s5,
 (select count(*) h11_to_11_30
 from store_sales, household_demographics , time_dim, store
 where store_sales.ss_sold_time_sk = time_dim.t_time_sk
     and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
     and store_sales.ss_store_sk = store.s_store_sk 
     and time_dim.t_hour = 11
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2))
     and store.s_store_name = 'ese') s6,
 (select count(*) h11_30_to_12
 from store_sales, household_demographics , time_dim, store
 where store_sales.ss_sold_time_sk = time_dim.t_time_sk
     and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
     and store_sales.ss_store_sk = store.s_store_sk
     and time_dim.t_hour = 11
     and time_dim.t_minute >= 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2))
     and store.s_store_name = 'ese') s7,
 (select count(*) h12_to_12_30
 from store_sales, household_demographics , time_dim, store
 where store_sales.ss_sold_time_sk = time_dim.t_time_sk
     and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
     and store_sales.ss_store_sk = store.s_store_sk
     and time_dim.t_hour = 12
     and time_dim.t_minute < 30
     and ((household_demographics.hd_dep_count = 3 and household_demographics.hd_vehicle_count<=3+2) or
          (household_demographics.hd_dep_count = 0 and household_demographics.hd_vehicle_count<=0+2) or
          (household_demographics.hd_dep_count = 1 and household_demographics.hd_vehicle_count<=1+2))
     and store.s_store_name = 'ese') s8
;

-- query89.sql

select  * -- query89.sql
from(
select i_category, i_class, i_brand,
       s_store_name, s_company_name,
       d_moy,
       sum(ss_sales_price) sum_sales,
       avg(sum(ss_sales_price)) over
         (partition by i_category, i_brand, s_store_name, s_company_name)
         avg_monthly_sales
from item, store_sales, date_dim, store
where store_sales.ss_item_sk = item.i_item_sk and
      store_sales.ss_sold_date_sk = date_dim.d_date_sk and
      store_sales.ss_store_sk = store.s_store_sk and
      d_year in (2000) and
        ((i_category in ('Home','Books','Electronics') and
          i_class in ('wallpaper','parenting','musical')
         )
      or (i_category in ('Shoes','Jewelry','Men') and
          i_class in ('womens','birdal','pants') 
        ))
group by i_category, i_class, i_brand,
         s_store_name, s_company_name, d_moy) tmp1
where case when (avg_monthly_sales <> 0) then (abs(sum_sales - avg_monthly_sales) / avg_monthly_sales) else null end > 0.1
order by sum_sales - avg_monthly_sales, s_store_name
limit 100;


-- query90.sql

select  cast(amc as decimal(15,4))/cast(pmc as decimal(15,4)) am_pm_ratio -- query90.sql
 from ( select count(*) amc
       from web_sales, household_demographics , time_dim, web_page
       where ws_sold_time_sk = time_dim.t_time_sk
         and ws_ship_hdemo_sk = household_demographics.hd_demo_sk
         and ws_web_page_sk = web_page.wp_web_page_sk
         and time_dim.t_hour between 6 and 6+1
         and household_demographics.hd_dep_count = 8
         and web_page.wp_char_count between 5000 and 5200) at,
      ( select count(*) pmc
       from web_sales, household_demographics , time_dim, web_page
       where ws_sold_time_sk = time_dim.t_time_sk
         and ws_ship_hdemo_sk = household_demographics.hd_demo_sk
         and ws_web_page_sk = web_page.wp_web_page_sk
         and time_dim.t_hour between 14 and 14+1
         and household_demographics.hd_dep_count = 8
         and web_page.wp_char_count between 5000 and 5200) pt
 order by am_pm_ratio
 limit 100;

-- query91.sql
select   -- query91.sql
        cc_call_center_id Call_Center,
        cc_name Call_Center_Name,
        cc_manager Manager,
        sum(cr_net_loss) Returns_Loss
from
        call_center,
        catalog_returns,
        date_dim,
        customer,
        customer_address,
        customer_demographics,
        household_demographics
where
        catalog_returns.cr_call_center_sk       = call_center.cc_call_center_sk
and     catalog_returns.cr_returned_date_sk     = date_dim.d_date_sk
and     catalog_returns.cr_returning_customer_sk= customer.c_customer_sk
and     customer_demographics.cd_demo_sk              = customer.c_current_cdemo_sk
and     household_demographics.hd_demo_sk              = customer.c_current_hdemo_sk
and     customer_address.ca_address_sk           = customer.c_current_addr_sk
and     d_year                  = 1999 
and     d_moy                   = 11
and     ( (cd_marital_status       = 'M' and cd_education_status     = 'Unknown')
        or(cd_marital_status       = 'W' and cd_education_status     = 'Advanced Degree'))
and     hd_buy_potential like '0-500%'
and     ca_gmt_offset           = -7
group by cc_call_center_id,cc_name,cc_manager,cd_marital_status,cd_education_status
order by Returns_Loss desc;


-- query92.sql
SELECT sum(case when ssci.customer_sk is not null and csci.customer_sk is null then 1 -- query92.sql
                                 else 0 end) as store_only,
               sum(case when ssci.customer_sk is null and csci.customer_sk is not null then 1
                                else 0 end) as catalog_only,
               sum(case when ssci.customer_sk is not null and csci.customer_sk is not null then 1 
                                 else 0 end) as store_and_catalog
FROM (SELECT ss.ss_customer_sk as customer_sk,
                             ss.ss_item_sk as item_sk
             FROM store_sales ss
             JOIN date_dim d1 ON (ss.ss_sold_date_sk = d1.d_date_sk)
             WHERE d1.d_month_seq >= 1206 and
                            d1.d_month_seq <= 1217
             GROUP BY ss.ss_customer_sk, ss.ss_item_sk) ssci
FULL OUTER JOIN (SELECT cs.cs_bill_customer_sk as customer_sk,
                                                   cs.cs_item_sk as item_sk
                                   FROM catalog_sales cs
                                   JOIN date_dim d2 ON (cs.cs_sold_date_sk = d2.d_date_sk)
                                   WHERE d2.d_month_seq >= 1206 and
                                                  d2.d_month_seq <= 1217
                                   GROUP BY cs.cs_bill_customer_sk, cs.cs_item_sk) csci
ON (ssci.customer_sk=csci.customer_sk and
        ssci.item_sk = csci.item_sk);


-- query93.sql

select  ss_customer_sk -- query93.sql
            ,sum(act_sales) sumsales
      from (select ss_item_sk
                  ,ss_ticket_number
                  ,ss_customer_sk
                  ,case when sr_return_quantity is not null then (ss_quantity-sr_return_quantity)*ss_sales_price
                                                            else (ss_quantity*ss_sales_price) end act_sales
            from store_sales left outer join store_returns on (store_returns.sr_item_sk = store_sales.ss_item_sk
                                                               and store_returns.sr_ticket_number = store_sales.ss_ticket_number)
                ,reason
            where store_returns.sr_reason_sk = reason.r_reason_sk
              and r_reason_desc = 'Did not like the warranty') t
      group by ss_customer_sk
      order by sumsales, ss_customer_sk
limit 100;

-- query94.sql
SELECT count(distinct ws_order_number) as order_count, -- query94.sql
               sum(ws_ext_ship_cost) as total_shipping_cost,
               sum(ws_net_profit) as total_net_profit
FROM web_sales ws1
JOIN customer_address ca ON (ws1.ws_ship_addr_sk = ca.ca_address_sk)
JOIN web_site s ON (ws1.ws_web_site_sk = s.web_site_sk)
JOIN date_dim d ON (ws1.ws_ship_date_sk = d.d_date_sk)
LEFT SEMI JOIN (SELECT ws2.ws_order_number as ws_order_number
                               FROM web_sales ws2 JOIN web_sales ws3
                               ON (ws2.ws_order_number = ws3.ws_order_number)
                               WHERE ws2.ws_warehouse_sk <> ws3.ws_warehouse_sk
			) ws_wh1
ON (ws1.ws_order_number = ws_wh1.ws_order_number)
LEFT OUTER JOIN web_returns wr1 ON (ws1.ws_order_number = wr1.wr_order_number)
WHERE d.d_date between '1999-05-01' and '1999-07-01' and
               ca.ca_state = 'TX' and
               s.web_company_name = 'pri' and
               wr1.wr_order_number is null
limit 100;

-- query95.sql
SELECT count(distinct ws1.ws_order_number) as order_count, -- query95.sql
               sum(ws1.ws_ext_ship_cost) as total_shipping_cost,
               sum(ws1.ws_net_profit) as total_net_profit
FROM web_sales ws1
JOIN customer_address ca ON (ws1.ws_ship_addr_sk = ca.ca_address_sk)
JOIN web_site s ON (ws1.ws_web_site_sk = s.web_site_sk)
JOIN date_dim d ON (ws1.ws_ship_date_sk = d.d_date_sk)
LEFT SEMI JOIN (SELECT ws2.ws_order_number as ws_order_number
                               FROM web_sales ws2 JOIN web_sales ws3
                               ON (ws2.ws_order_number = ws3.ws_order_number)
                               WHERE ws2.ws_warehouse_sk <> ws3.ws_warehouse_sk
			) ws_wh1
ON (ws1.ws_order_number = ws_wh1.ws_order_number)
LEFT SEMI JOIN (SELECT wr_order_number
                               FROM web_returns wr
                               JOIN (SELECT ws4.ws_order_number as ws_order_number
                                          FROM web_sales ws4 JOIN web_sales ws5
                                          ON (ws4.ws_order_number = ws5.ws_order_number)
                                         WHERE ws4.ws_warehouse_sk <> ws5.ws_warehouse_sk
				) ws_wh2
                               ON (wr.wr_order_number = ws_wh2.ws_order_number)) tmp1
ON (ws1.ws_order_number = tmp1.wr_order_number)
WHERE d.d_date between '2002-05-01' and '2002-06-30' and
               ca.ca_state = 'GA' and
               s.web_company_name = 'pri';
-- query96.sql

select  count(*) as c -- query96.sql
from store_sales
    ,household_demographics 
    ,time_dim, store
where store_sales.ss_sold_time_sk = time_dim.t_time_sk   
    and store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk 
    and store_sales.ss_store_sk = store.s_store_sk
    and time_dim.t_hour = 8
    and time_dim.t_minute >= 30
    and household_demographics.hd_dep_count = 5
    and store.s_store_name = 'ese'
order by c
limit 100;

-- query97.sql
select sum(case when ssci.customer_sk is not null and csci.customer_sk is null then 1 else 0 end) store_only -- query97.sql
      ,sum(case when ssci.customer_sk is null and csci.customer_sk is not null then 1 else 0 end) catalog_only
      ,sum(case when ssci.customer_sk is not null and csci.customer_sk is not null then 1 else 0 end) store_and_catalog
from 
( select ss_customer_sk customer_sk
      ,ss_item_sk item_sk
from store_sales
JOIN date_dim ON store_sales.ss_sold_date_sk = date_dim.d_date_sk
where
  d_month_seq between 1193 and 1193 + 11
group by ss_customer_sk ,ss_item_sk) ssci
full outer join
( select cs_bill_customer_sk customer_sk
      ,cs_item_sk item_sk
from catalog_sales
JOIN date_dim ON catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
where
  d_month_seq between 1193 and 1193 + 11
group by cs_bill_customer_sk ,cs_item_sk) csci
on (ssci.customer_sk=csci.customer_sk and ssci.item_sk = csci.item_sk)
limit 100;


-- query98.sql

select i_item_desc -- query98.sql
      ,i_category 
      ,i_class 
      ,i_current_price
      ,i_item_id
      ,sum(ss_ext_sales_price) as itemrevenue 
      ,sum(ss_ext_sales_price)*100/sum(sum(ss_ext_sales_price)) over
          (partition by i_class) as revenueratio
from	
	store_sales
    	,item 
    	,date_dim
where 
	store_sales.ss_item_sk = item.i_item_sk 
  	and i_category in ('Jewelry', 'Sports', 'Books')
  	and store_sales.ss_sold_date_sk = date_dim.d_date_sk
	and d_date between cast('2001-01-12' as date) 
				and (cast('2001-02-11' as date))
group by 
	i_item_id
        ,i_item_desc 
        ,i_category
        ,i_class
        ,i_current_price
order by 
	i_category
        ,i_class
        ,i_item_id
        ,i_item_desc
        ,revenueratio;


