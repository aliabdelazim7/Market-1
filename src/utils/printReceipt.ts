import { printDocument } from './printWindow';
import { escapeHtml } from './escapeHtml';

export type ReceiptItem = { name?: string; product?: { name?: string }; sale_price?: number; quantity?: number };
export type ReceiptData = {
  id: string;
  items?: ReceiptItem[];
  total?: number;
  paidAmount?: number;
  customerName?: string;
  paymentMethod?: string;
  cashierName?: string;
  currency?: string;
};

export function printReceipt(data: ReceiptData) {
  const currency = escapeHtml(data.currency || 'جنيه');
  const items = (data.items || []).map((item) => {
    const name = item.product?.name || item.name || 'منتج';
    const qty = Number(item.quantity || 0);
    const price = Number(item.sale_price || 0);
    return `<tr><td>${escapeHtml(name)}</td><td>${qty}</td><td>${price.toFixed(2)}</td><td>${(qty * price).toFixed(2)}</td></tr>`;
  }).join('');
  const html = `<!doctype html><html dir="rtl"><head><meta charset="utf-8"><title>فاتورة ${escapeHtml(data.id)}</title>
  <style>@page{size:80mm auto;margin:0}*{box-sizing:border-box}body{margin:0;padding:8mm 5mm;font-family:Arial,sans-serif;color:#111;font-size:12px}h1{font-size:20px;text-align:center;margin:0 0 4px}.meta{text-align:center;color:#444;margin-bottom:10px}.line{border-top:1px dashed #222;margin:8px 0}table{width:100%;border-collapse:collapse}th,td{padding:5px 2px;border-bottom:1px solid #ddd;text-align:right}th{font-size:11px}.total{font-weight:700;font-size:16px;text-align:left;margin-top:10px}.footer{text-align:center;margin-top:14px;font-size:11px;color:#555}</style></head><body>
  <h1>فاتورة بيع</h1><div class="meta">رقم الفاتورة: ${escapeHtml(data.id)}<br>${escapeHtml(data.customerName || 'عميل نقدي')}</div><div class="line"></div>
  <table><thead><tr><th>الصنف</th><th>الكمية</th><th>السعر</th><th>الإجمالي</th></tr></thead><tbody>${items}</tbody></table>
  <div class="line"></div><div class="total">الإجمالي: ${Number(data.total || 0).toFixed(2)} ${currency}</div><div>المدفوع: ${Number(data.paidAmount || 0).toFixed(2)} ${currency}</div>
  <div class="footer">الكاشير: ${escapeHtml(data.cashierName || 'مدير النظام')}<br>شكرًا لتعاملكم معنا</div>${'${AUTO_PRINT_SCRIPT_PLACEHOLDER}'}</body></html>`;
  printDocument('invoice', html.replace('${AUTO_PRINT_SCRIPT_PLACEHOLDER}', ''), 'width=420,height=700');
}
