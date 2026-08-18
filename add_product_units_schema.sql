-- ─────────────────────────────────────────────────────────────
-- نظام السوبر ماركت والمواد الغذائية: المنتجات والوحدات والكسور
-- وتطهير قاعدة البيانات من خصائص ومنتجات الملابس السابقة
-- شغّل هذا الملف في Supabase SQL Editor
-- ─────────────────────────────────────────────────────────────

-- 1) إزالة أعمدة الملابس السابقة إن وجدت
alter table products drop column if exists season;
alter table products drop column if exists color;

-- 2) عمود الوحدة على المنتجات (الافتراضي: قطعة)
alter table products
  add column if not exists unit text not null default 'قطعة';

-- 3) السماح بكميات كسرية (وزن/حجم) في المخزون والفواتير
--    تحويل أعمدة الكمية من integer إلى numeric
alter table products
  alter column stock_quantity type numeric using stock_quantity::numeric;

alter table purchase_items
  alter column quantity type numeric using quantity::numeric;

alter table order_items
  alter column quantity type numeric using quantity::numeric,
  alter column returned_quantity type numeric using returned_quantity::numeric;

-- 4) إدراج تصنيفات السوبر ماركت الرئيسية
insert into categories (id, name, image_url) values
  ('cat_dairy',    'ألبان ومجمدات',   'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=500&q=80'),
  ('cat_dry',      'بقالة جافة',     'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500&q=80'),
  ('cat_beverages','مشروبات وحلويات', 'https://images.unsplash.com/photo-1527960471264-932f39eb5846?w=500&q=80'),
  ('cat_cleaning', 'منظفات ورقيات',  'https://images.unsplash.com/photo-1585421514738-01798e348b17?w=500&q=80'),
  ('cat_produce',  'خضار وفواكه',    'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=500&q=80'),
  ('cat_meat',     'لحوم وأسماك',    'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500&q=80')
on conflict (id) do update set name = excluded.name;

-- 5) إدراج منتجات سوبر ماركت ومواد غذائية شاملة
insert into products (
  id, name, barcode, purchase_price, average_purchase_price, sale_price, half_wholesale_price, wholesale_price, discount_price, stock_quantity, display_quantity, category_id, unit, supplier_name, image_url
) values
  -- ألبان ومجمدات
  ('prod_sm_1',  'جبنة بيضاء فلاحي طازجة',        '6221001', 95,  95,  130, 120, 115, 125, 50,  20, 'cat_dairy',     'كيلو', 'مصنع ألبان الهناء',   'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=500&q=80'),
  ('prod_sm_2',  'حليب جهينة كامل الدسم 1 لتر',   '6221002', 34,  34,  42,  39,  38,  40,  100, 40, 'cat_dairy',     'لتر',  'شركة جهينة للأغذية', 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=500&q=80'),
  ('prod_sm_3',  'زبادي جهينة طبيعي 105 جرام',    '6221003', 6.5, 6.5, 8.5, 7.8, 7.5, 8,   200, 80, 'cat_dairy',     'علبة', 'شركة جهينة للأغذية', 'https://images.unsplash.com/photo-1571212515416-fef01fc43637?w=500&q=80'),
  ('prod_sm_4',  'جبنة رومي قديم مبشور',          '6221004', 190, 190, 250, 235, 225, 240, 30,  15, 'cat_dairy',     'كيلو', 'شركة الإخلاص للأجبان','https://images.unsplash.com/photo-1452195100486-9cc805987862?w=500&q=80'),

  -- بقالة جافة
  ('prod_sm_5',  'أرز المطبخ ممتاز 1 كجم',        '6222001', 27,  27,  35,  32,  31,  33,  150, 60, 'cat_dry',       'كيلو', 'مضرب المطبخ للأرز',  'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500&q=80'),
  ('prod_sm_6',  'زيت عباد الشمس كريستال 800 مل', '6222002', 52,  52,  65,  60,  58,  62,  80,  30, 'cat_dry',       'علبة', 'شركة آرما للزيوت',   'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500&q=80'),
  ('prod_sm_7',  'مكرونة حواء قلم 400 جرام',       '6222003', 10.5,10.5,14,  12.5,12,  13.5,200, 90, 'cat_dry',       'باكو', 'شركة المطاحن الحديثة','https://images.unsplash.com/photo-1621996346565-e3def6164286?w=500&q=80'),
  ('prod_sm_8',  'شاي العروسة ناعم 250 جرام',     '6222004', 44,  44,  55,  50,  48,  52,  120, 50, 'cat_dry',       'باكو', 'شركة الفتح للشاي',   'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=500&q=80'),
  ('prod_sm_9',  'سكر كريستال فاخر 1 كجم',        '6222005', 27,  27,  35,  32,  30,  33,  300, 120,'cat_dry',       'كيلو', 'شركة الدلتا للسكر',  'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=500&q=80'),

  -- مشروبات وحلويات
  ('prod_sm_10', 'عصير جهينة مانجو 1 لتر',        '6223001', 21,  21,  28,  25,  24,  26,  90,  35, 'cat_beverages', 'لتر',  'شركة جهينة للأغذية', 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=500&q=80'),
  ('prod_sm_11', 'بسكويت أوريو الأصلي 6 قطع',     '6223002', 7.5, 7.5, 10,  9,   8.5, 9.5, 250, 100,'cat_beverages', 'باكو', 'شركة مونديليز العالمية','https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=500&q=80'),
  ('prod_sm_12', 'مياه معدنية داساني 1.5 لتر',    '6223003', 6.5, 6.5, 9,   7.8, 7.5, 8.5, 180, 70, 'cat_beverages', 'علبة', 'شركة كوكاكولا مصر',  'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=500&q=80'),

  -- منظفات ورقيات
  ('prod_sm_13', 'مسحوق أريال أوتوماتيك 2.5 كجم',   '6224001', 155, 155, 195, 180, 172, 185, 40,  15, 'cat_cleaning',  'علبة', 'شركة بروكتر آند جامبل','https://images.unsplash.com/photo-1585421514738-01798e348b17?w=500&q=80'),
  ('prod_sm_14', 'صابون ديتول الأصلي 125 جرام',    '6224002', 16,  16,  22,  19.5,18.5,20.5,150, 60, 'cat_cleaning',  'قطعة', 'شركة ريكيت بينكيزر', 'https://images.unsplash.com/photo-1600857544200-b2f666a9a2ec?w=500&q=80'),
  ('prod_sm_15', 'مناديل فاين كلاسيك 500 منديل',   '6224003', 24,  24,  32,  29,  28,  30,  110, 45, 'cat_cleaning',  'علبة', 'مجموعة فاين الصحية', 'https://images.unsplash.com/photo-1584556812952-905ffd0c611a?w=500&q=80'),

  -- خضار وفواكه
  ('prod_sm_16', 'طماطم بلدي طازجة',             '6225001', 10,  10,  15,  13,  12,  14,  80,  30, 'cat_produce',   'كيلو', 'مزارع الصالحية',     'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&q=80'),
  ('prod_sm_17', 'بطاطس تحمير فاخرة',             '6225002', 14,  14,  20,  17.5,16.5,18.5,120, 50, 'cat_produce',   'كيلو', 'مزارع البحيرة',      'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500&q=80'),
  ('prod_sm_18', 'تفاح أحمر سكري أمريكي',         '6225003', 48,  48,  65,  58,  55,  60,  60,  25, 'cat_produce',   'كيلو', 'شركة الاستيراد الزراعي','https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500&q=80'),

  -- لحوم وأسماك
  ('prod_sm_19', 'لحم بلدي كابوريا/كندوز',        '6226001', 310, 310, 380, 355, 345, 365, 40,  20, 'cat_meat',      'كيلو', 'جزارة البركة العصرية','https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500&q=80'),
  ('prod_sm_20', 'دجاج كوكي مجمد 1.1 كجم',       '6226002', 115, 115, 145, 134, 128, 138, 50,  20, 'cat_meat',      'قطعة', 'شركة أطياب للأغذية', 'https://images.unsplash.com/photo-1587593810167-a84920ea0781?w=500&q=80')
on conflict (id) do update set
  name = excluded.name,
  sale_price = excluded.sale_price,
  purchase_price = excluded.purchase_price,
  stock_quantity = excluded.stock_quantity,
  display_quantity = excluded.display_quantity,
  category_id = excluded.category_id,
  unit = excluded.unit,
  image_url = excluded.image_url;

-- تم. المنتجات والتصنيفات الخاصة بالسوبر ماركت أصبحت جاهزة ومحينة بالكامل.
