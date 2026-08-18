from pathlib import Path

src = Path('/home/ubuntu/Market-1/database_bundle/DATABASE_ALL_IN_ONE.sql')
dst = Path('/home/ubuntu/Market-1/database_bundle/DATABASE_ALL_IN_ONE_DEBUGGED.sql')
text = src.read_text(encoding='utf-8')

# The master schema creates employees.id and employee-related foreign-key columns as text.
# Align all attendance/employee function parameters and function grants with that schema.
replacements = {
    'p_employee_id uuid': 'p_employee_id text',
    'public.get_attendance_status(uuid)': 'public.get_attendance_status(text)',
    'public.record_attendance(uuid, text, text)': 'public.record_attendance(text, text, text)',
}
for old, new in replacements.items():
    text = text.replace(old, new)

header = """-- DEBUGGED CONSOLIDATED DATABASE SCRIPT\n-- Employee identifiers are consistently treated as text, matching the master schema.\n-- Main fix: p_employee_id text so comparisons such as employee_attendance.employee_id = p_employee_id are text = text.\n\n"""
dst.write_text(header + text, encoding='utf-8')
print(dst)
print('p_employee_id uuid remaining:', text.count('p_employee_id uuid'))
print('get_attendance_status(uuid) remaining:', text.count('public.get_attendance_status(uuid)'))
print('record_attendance(uuid, text, text) remaining:', text.count('public.record_attendance(uuid, text, text)'))
print('bytes:', dst.stat().st_size)
