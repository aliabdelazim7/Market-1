# تشغيل قاعدة البيانات

ابدأ بملف `DATABASE_SETUP_SAFE.sql` في Supabase SQL Editor على مشروع جديد أو قاعدة فارغة. الملف يجمع ملف الإعداد الموحد `setup_new_database.sql` ثم يضيف migrations الإضافية بالترتيب، ويستبعد ملفات reset/clear وملفات التشخيص من التشغيل الآمن.

قبل التشغيل على قاعدة بها بيانات، خذ Backup وتأكد من `Project URL` و`anon key` في ملف `.env`. بعد التشغيل، راجع جداول `store_settings`, `products`, `categories`, `orders`, `order_items`, `customers`, `suppliers`, `expenses`, `employees`, `cashiers`, `warehouses`, و`store_settings`.

الملفات التي تحتوي على حذف أو تصفير بيانات لم تدخل في الحزمة الآمنة، ومنها `db/12_reset_data.sql`, `db/26_clear_invoices_products_categories.sql`, `db/30_clear_manager_withdrawals.sql`, وملفات `reset_and_seed_*.sql`. لا تشغلها إلا على قاعدة تجريبية وبقرار مقصود.

ملف `SQL_SOURCE_MANIFEST.txt` يحتوي على قائمة كل ملفات SQL الأصلية الموجودة في الريبو، لاستخدامها عند الحاجة إلى migration أو إصلاح منفصل. يجب تشغيل ملف `DATABASE_SETUP_SAFE.sql` مرة واحدة على قاعدة جديدة، ثم تشغيل أي migration جديد فقط عند الحاجة وبحسب رقمها.
