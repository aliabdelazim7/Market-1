from pathlib import Path

ROOT = Path('/home/ubuntu/Market-1/src')

# Standalone receipt printer: no external images, QR services, courier labels, or remote fonts.
receipt = '''import { printDocument } from './printWindow';
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
'''
(ROOT / 'utils/printReceipt.ts').write_text(receipt, encoding='utf-8')

# POS: use local receipt printing and make all checkout pricing retail-only.
pos = ROOT / 'pages/POS.tsx'
s = pos.read_text(encoding='utf-8')
s = s.replace("import { printShippingLabel, type ShippingLabelHeld } from '../utils/printShippingLabel';", "import { printReceipt } from '../utils/printReceipt';")
s = s.replace("import { ShoppingCart, Search, Plus, Minus, Trash2, Banknote, RefreshCcw, Moon, Sun, ArrowRightLeft, ArrowLeft, ArrowRight, X, Printer, CreditCard, Smartphone, Zap, ScanLine, Camera, Box, Check, ChevronRight, ChevronLeft, FileText, MessageSquare, Send, Wallet, Edit2, Eye, HandCoins, UserMinus, Clock, PauseCircle, Undo2, Truck, Hourglass, Play } from 'lucide-react';", "import { ShoppingCart, Search, Plus, Minus, Trash2, Banknote, RefreshCcw, Moon, Sun, ArrowRightLeft, ArrowLeft, ArrowRight, X, Printer, CreditCard, Smartphone, Zap, ScanLine, Camera, Box, Check, ChevronRight, ChevronLeft, FileText, MessageSquare, Send, Wallet, Edit2, Eye, HandCoins, UserMinus, Clock, PauseCircle, Undo2, Hourglass, Play } from 'lucide-react';")
# Remove platform pricing block, retaining retail pricing behavior.
start = s.find("  // ── تحديد منصة / قناة البيع")
end = s.find("  // فتح نافذة الوزن", start)
if start != -1 and end != -1:
    s = s[:start] + "  // مبيعات المحل تستخدم سعر البيع المحلي فقط.\n  const selectedPlatform = 'website';\n\n" + s[end:]
s = s.replace("      if (selectedPlatform !== 'website') {\n        const targetPrice = getTargetPlatformPrice(product, selectedPlatform);\n        updatePrice(product.id, targetPrice);\n      }\n", "")
s = s.replace("    if (selectedPlatform !== 'website') {\n      const targetPrice = getTargetPlatformPrice(weightProduct, selectedPlatform);\n      updatePrice(weightProduct.id, targetPrice);\n    }\n", "")
s = s.replace("    const platformNameForSync = getPlatformDisplayName(selectedPlatform);\n    const invoiceId = await checkout(currentTotal, { name: currentCustomerName, phone: currentCustomerPhone, custom_id: currentCustomId }, effectivePaidAmount, 'sale', primaryMethod as any, finalSplit as any, undefined, deferredNote, currentCouponCode, currentCouponDiscount, undefined, saleDateISO, false, platformNameForSync);", "    const invoiceId = await checkout(currentTotal, { name: currentCustomerName, phone: currentCustomerPhone, custom_id: currentCustomId }, effectivePaidAmount, 'sale', primaryMethod as any, finalSplit as any, undefined, deferredNote, currentCouponCode, currentCouponDiscount, undefined, saleDateISO, false, undefined);")
old = '''  const printInvoice = (invId: string, orderDetails: any) => {
    const currentSettings = { ...storeSettings };
    const heldData: ShippingLabelHeld = {
      id: invId,
      customer_name: orderDetails.customerName || (orderDetails.customer ? orderDetails.customer.name : 'عميل نقدي'),
      customer_phone: orderDetails.customerPhone || (orderDetails.customer ? orderDetails.customer.phone : null),
      customer_address: orderDetails.customerAddress || (orderDetails.customer ? orderDetails.customer.address : null),
      items: orderDetails.cart || [],
      total: orderDetails.total || 0,
      deposit: orderDetails.paidAmount || orderDetails.total || 0,
      created_at: new Date().toISOString(),
      cashier_name: activeCashier?.name || 'مدير النظام'
    };
    void printShippingLabel(heldData, currentSettings);
  };'''
new = '''  const printInvoice = (invId: string, orderDetails: any) => {
    printReceipt({ id: invId, items: orderDetails.cart || [], total: orderDetails.total || 0,
      paidAmount: orderDetails.paidAmount || 0, customerName: orderDetails.customerName,
      cashierName: activeCashier?.name, currency: storeSettings.currency });
  };'''
s = s.replace(old, new)
# Remove platform selector UI block if present.
platform_ui_start = s.find("                  {discountStr || couponInput ? 'خصم / كوبون مفعل 🏷️' : `المنصة:")
if platform_ui_start != -1:
    block_start = s.rfind('<div', 0, platform_ui_start)
    block_end = s.find('</div>', platform_ui_start)
    if block_start != -1 and block_end != -1:
        s = s[:block_start] + s[block_end+6:]
# Remove printShippingLabel call for held invoice; use a receipt-shaped call where possible.
s = s.replace("try { await printShippingLabel(h, storeSettings); } catch (e) { console.error(e); }", "try { printReceipt({ id: h.id, items: h.items || [], total: h.total || 0, paidAmount: h.deposit || 0, customerName: h.customer_name, cashierName: activeCashier?.name, currency: storeSettings.currency }); } catch (e) { console.error(e); }")
pos.write_text(s, encoding='utf-8')

# AddInvoiceModal: convert it to a retail-only invoice and remove platform/shipping fields.
inv = ROOT / 'components/AddInvoiceModal.tsx'
s = inv.read_text(encoding='utf-8')
s = s.replace("import { X, Search, Plus, Trash2, User, Phone, MapPin, Package, Filter, ScanLine, Code, Store, Truck, CreditCard, Save } from 'lucide-react';", "import { X, Search, Plus, Trash2, User, Phone, Package, Filter, ScanLine, Code, CreditCard, Save } from 'lucide-react';")
s = s.replace("    carriers,\n", "")
s = s.replace("    syncInvoiceToPlatformCollection,\n    loadPlatformCollections, \n", "")
s = s.replace("  const defaultBuiltinPlatforms = [\n    'الويب سايت (المتجر الإلكتروني)',\n    'أمازون (Amazon)',\n    'نون (Noon)',\n    'جوميا (Jumia)',\n    'تيك توك شوب (TikTok Shop)',\n    'متجر سلة (Salla)',\n    'متجر زد (Zid)',\n    'المحل الرئيسي'\n  ];\n  const customCarrierNames = (carriers || []).filter((c) => c.status === 'active').map((c) => c.name);\n  const allDynamicPlatforms = Array.from(new Set([...defaultBuiltinPlatforms, ...customCarrierNames]));\n\n", "")
s = s.replace("  const [customerAddress, setCustomerAddress] = useState('');\n", "")
s = s.replace("  const [salesPlatform, setSalesPlatform] = useState<string>('أمازون (Amazon)');\n", "")
s = s.replace("  const [shippingCompany, setShippingCompany] = useState<string>('بوسطة (Bosta)');\n  const [shippingCost, setShippingCost] = useState<number>(0);\n", "")
s = s.replace("  const [deliveryStatus, setDeliveryStatus] = useState<string>('money_pending'); // قيد الانتظار / التحصيل\n", "")
# Remove suggested platform price memo block.
start = s.find("  // Auto-detect & suggest custom platform price")
end = s.find("  // Add selected product", start)
if start != -1 and end != -1:
    s = s[:start] + s[end:]
# Remove address UI, platform row, shipping row, delivery status field.
for marker_start, marker_end in [
    ("          {/* Row 2: Address Textarea */}", "          {/* Row 3: Product Section Header"),
    ("            {/* Sales Platform & Quantity Row */}", "            {/* Custom Price Field"),
    ("          {/* Row 4: Shipping Company & Shipping Cost */}", "          {/* Row 5: Delivery Status & Payment Method */}"),
    ("          {/* Row 5: Delivery Status & Payment Method */}", "\n        </div>")
]:
    a = s.find(marker_start)
    b = s.find(marker_end, a+1) if a != -1 else -1
    if a != -1 and b != -1:
        s = s[:a] + ("          {/* Product Section */}\n" if 'Product Section' in marker_end else '') + s[b:]
# Save handler: remove platform/shipping sync and write a normal retail invoice.
s = s.replace("          customer_address: customerAddress.trim() || null,\n", "")
s = s.replace("          status: deliveryStatus === 'delivered' ? 'delivered' : 'money_pending', // \"تروح ع التحصيلات\"\n          kind: 'online',\n          shipping_note: `${salesPlatform} - ${shippingCompany}`,\n", "          status: 'paid',\n          kind: 'retail',\n")
s = s.replace("          shipping_cost: Number(shippingCost) || 0,\n          notes: `تحصيل منصات: ${salesPlatform}`\n", "          notes: 'بيع محل'\n")
# Remove platform collection sync block and platform loading.
a = s.find("      // 5. 🔥 Sync to Platform Collections")
b = s.find("      // Refresh store states", a)
if a != -1 and b != -1:
    s = s[:a] + s[b:]
s = s.replace("          shipping_cost: Number(shippingCost) || 0,\n          shipping_carrier: shippingCompany,\n", "")
s = s.replace("      await loadPlatformCollections();\n", "")
s = s.replace("      alert(`تم إضافة الفاتورة #${invoiceId} بنجاح وتم توجيهها فوراً إلى قسم (التحصيلات والمنصات)!`);", "      alert(`تم إضافة الفاتورة #${invoiceId} بنجاح`);")
s = s.replace("              <span>العنوان</span>\n", "")
inv.write_text(s, encoding='utf-8')

# Remove logistics routes from the main router and admin navigation if exact route entries exist.
app = ROOT / 'App.tsx'
s = app.read_text(encoding='utf-8')
s = s.replace("  <Route path=\"/admin/logistics\" element={<Logistics />} />\n", "")
s = s.replace("  <Route path=\"/admin/carriers\" element={<CarriersPage />} />\n", "")
s = s.replace("  <Route path=\"/admin/logistics-orders\" element={<LogisticsOrdersPage />} />\n", "")
app.write_text(s, encoding='utf-8')

# Remove product marketplace fields from Inventory state and form payloads; existing DB columns remain harmless.
invp = ROOT / 'pages/admin/Inventory.tsx'
s = invp.read_text(encoding='utf-8')
import re
s = re.sub(r"\n\s*website_ad_cost: 0,\n\s*amazon_price: 0,\n\s*amazon_discount_price: 0,\n\s*amazon_commission: 0,\n\s*amazon_ad_cost: 0,\n\s*amazon_shipping: 0,\n\s*noon_price: 0,\n\s*noon_discount_price: 0,\n\s*noon_commission: 0,\n\s*noon_shipping: 0,\n\s*noon_ad_cost: 0,\n\s*jumia_price: 0,\n\s*jumia_discount_price: 0,\n\s*jumia_commission: 0,\n\s*jumia_shipping: 0,\n\s*jumia_ad_cost: 0,\n\s*custom_stores: .*?\n", "\n", s, flags=re.S)
s = re.sub(r"\n\s*website_ad_cost: product\.website_ad_cost \|\| 0,.*?\n\s*custom_stores: Array\.isArray\(product\.custom_stores\) \? product\.custom_stores : \[\],", "", s, flags=re.S)
s = re.sub(r"\n\s*website_ad_cost: 0,.*?\n\s*custom_stores: \[\],", "", s, flags=re.S)
s = re.sub(r"\n\s*\{\/\*.*?صافي مكسب الموقع.*?\n\s*\}\n", "\n", s, flags=re.S)
invp.write_text(s, encoding='utf-8')

# Admin layout: remove visible logistics/carrier navigation entries.
for p in [ROOT / 'pages/admin/AdminLayout.tsx']:
    s = p.read_text(encoding='utf-8')
    s = re.sub(r".*(?:لوجست|منصات|شحن|Carriers|Logistics|Platform Collections).*(?:\n|$)", "", s, flags=re.I)
    p.write_text(s, encoding='utf-8')
