-- EAMIN TOP-UP: initial Free Fire catalog
-- Safe to run more than once: existing category + package_label pairs are not duplicated.
insert into public.products (name, category, description, package_label, price_bdt, active, sort_order)
select 'Free Fire', v.category, null, v.package_label, v.price_bdt, true, v.sort_order
from (values
('Free Fire Diamond','20 Diamond',20::numeric,10),
('Free Fire Diamond','50 Diamond',35,20),
('Free Fire Diamond','115 Diamond',77,30),
('Free Fire Diamond','240 Diamond',153,40),
('Free Fire Diamond','355 Diamond',230,50),
('Free Fire Diamond','480 Diamond',305,60),
('Free Fire Diamond','505 Diamond',325,70),
('Free Fire Diamond','610 Diamond',385,80),
('Free Fire Diamond','850 Diamond',540,90),
('Free Fire Diamond','1090 Diamond',685,100),
('Free Fire Diamond','1240 Diamond',765,110),
('Free Fire Diamond','2530 Diamond',1540,120),
('Free Fire Diamond','5060 Diamond',3080,130),
('Free Fire Diamond','10120 Diamond',6160,140),
('Weekly / Monthly','1x Weekly 🔰',153,10),
('Weekly / Monthly','2x Weekly 🔰',305,20),
('Weekly / Monthly','3x Weekly 🔰',460,30),
('Weekly / Monthly','4x Weekly 🔰',610,40),
('Weekly / Monthly','5x Weekly 🔰',765,50),
('Weekly / Monthly','6x Weekly 🔰',920,60),
('Weekly / Monthly','1x Monthly 🔰',750,70),
('Weekly / Monthly','2x Monthly 🔰',1500,80),
('Weekly / Monthly','3x Monthly 🔰',2250,90),
('Weekly / Monthly','4x Monthly 🔰',3000,100),
('Weekly / Monthly','5x Monthly 🔰',3750,110),
('Weekly / Monthly','6x Monthly 🔰',4500,120),
('Level Up Pass (BD Server)','Level Up Pass - Level 6 🔰',39,10),
('Level Up Pass (BD Server)','Level Up Pass - Level 10 🔰',69,20),
('Level Up Pass (BD Server)','Level Up Pass - Level 15 🔰',69,30),
('Level Up Pass (BD Server)','Level Up Pass - Level 20 🔰',69,40),
('Level Up Pass (BD Server)','Level Up Pass - Level 25 🔰',69,50),
('Level Up Pass (BD Server)','Level Up Pass - Level 30 🔰',99,60)
) as v(category, package_label, price_bdt, sort_order)
where not exists (
 select 1 from public.products p
 where p.category = v.category and p.package_label = v.package_label
);
