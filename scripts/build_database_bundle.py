from pathlib import Path

ROOT = Path('/home/ubuntu/Market-1')
OUT = ROOT / 'database_bundle'
OUT.mkdir(exist_ok=True)

# The repository's unified setup is the primary starting point.
primary = ROOT / 'setup_new_database.sql'
# These files intentionally mutate/delete data or are diagnostics; they are not
# included in the safe install bundle.
dangerous = {
    '12_reset_data.sql',
    '26_clear_invoices_products_categories.sql',
    '30_clear_manager_withdrawals.sql',
}
diagnostic = {
    '47_diagnose_main_treasury.sql',
    '56_diagnose_savings_methods.sql',
    '58_fix_orphan_supplier_after_treasury_delete.sql',
    '61_health_check.sql',
    '65_diagnose_opening_balance.sql',
    '66_find_orphan_salary_rows.sql',
    '68_diagnose_inventory_gap.sql',
    '69_inventory_gap_by_product.sql',
    '70_reconcile_opening_stock.sql',
}

def section(path: Path, label: str) -> str:
    return (
        '\n\n' + '-- ' + '=' * 74 + '\n'
        + f'-- SOURCE: {label}\n'
        + '-- ' + '=' * 74 + '\n\n'
        + path.read_text(encoding='utf-8')
        + '\n'
    )

parts = [
    '-- CRM-MOB-Market / Market-1 database installation bundle\n',
    '-- Generated from the repository SQL files.\n',
    '-- Run in Supabase SQL Editor on a new project.\n',
    '-- Do not run this bundle against a production database without a backup.\n',
    "create extension if not exists pgcrypto;\ncreate extension if not exists \"uuid-ossp\";\n",
]

# The reconciliation baseline must run first. It creates foundational tables
# such as car_subscriptions before later migrations alter them.
master = ROOT / 'db' / '00_MASTER_SCHEMA_RECONCILIATION.sql'
if master.exists():
    parts.append(section(master, 'db/00_MASTER_SCHEMA_RECONCILIATION.sql'))
if primary.exists():
    parts.append(section(primary, primary.name))

# Add ordered numbered migrations that extend the primary setup.
for path in sorted((ROOT / 'db').glob('[0-9][0-9]_*.sql')):
    name = path.name
    if name in dangerous or name in diagnostic or name == '00_MASTER_SCHEMA_RECONCILIATION.sql':
        continue
    parts.append(section(path, f'db/{name}'))

# Include root-level additive schema fixes, excluding alternate full setups and
# destructive demo seed/reset scripts to avoid duplicate or destructive execution.
root_excluded = {
    'setup_new_database.sql', 'supabase_schema.sql', 'full_database_setup.sql',
    'reset_and_seed_auto_parts.sql', 'reset_and_seed_hances_pro.sql',
}
for path in sorted(ROOT.glob('*.sql')):
    if path.name in root_excluded:
        continue
    text = path.read_text(encoding='utf-8').lower()
    if any(token in text for token in ('truncate table', 'delete from')):
        continue
    parts.append(section(path, path.name))

(OUT / 'DATABASE_SETUP_SAFE.sql').write_text(''.join(parts), encoding='utf-8')

# Preserve every original SQL file in a separate source archive for reference.
manifest = []
for path in sorted(list(ROOT.glob('*.sql')) + list((ROOT / 'db').glob('*.sql'))):
    rel = path.relative_to(ROOT).as_posix()
    manifest.append(rel)
(OUT / 'SQL_SOURCE_MANIFEST.txt').write_text('\n'.join(manifest) + '\n', encoding='utf-8')

instructions = '''# تشغيل قاعدة البيانات

ابدأ بملف `DATABASE_SETUP_SAFE.sql` في Supabase SQL Editor على مشروع جديد أو قاعدة فارغة. الملف يجمع ملف الإعداد الموحد `setup_new_database.sql` ثم يضيف migrations الإضافية بالترتيب، ويستبعد ملفات reset/clear وملفات التشخيص من التشغيل الآمن.

قبل التشغيل على قاعدة بها بيانات، خذ Backup وتأكد من `Project URL` و`anon key` في ملف `.env`. بعد التشغيل، راجع جداول `store_settings`, `products`, `categories`, `orders`, `order_items`, `customers`, `suppliers`, `expenses`, `employees`, `cashiers`, `warehouses`, و`store_settings`.

الملفات التي تحتوي على حذف أو تصفير بيانات لم تدخل في الحزمة الآمنة، ومنها `db/12_reset_data.sql`, `db/26_clear_invoices_products_categories.sql`, `db/30_clear_manager_withdrawals.sql`, وملفات `reset_and_seed_*.sql`. لا تشغلها إلا على قاعدة تجريبية وبقرار مقصود.

ملف `SQL_SOURCE_MANIFEST.txt` يحتوي على قائمة كل ملفات SQL الأصلية الموجودة في الريبو، لاستخدامها عند الحاجة إلى migration أو إصلاح منفصل. يجب تشغيل ملف `DATABASE_SETUP_SAFE.sql` مرة واحدة على قاعدة جديدة، ثم تشغيل أي migration جديد فقط عند الحاجة وبحسب رقمها.
'''
(OUT / 'README_AR.md').write_text(instructions, encoding='utf-8')
print(f'created {OUT / "DATABASE_SETUP_SAFE.sql"}')
print(f'lines={sum(1 for _ in (OUT / "DATABASE_SETUP_SAFE.sql").open(encoding="utf-8"))}')
print(f'bytes={(OUT / "DATABASE_SETUP_SAFE.sql").stat().st_size}')
print(f'manifest_entries={len(manifest)}')
