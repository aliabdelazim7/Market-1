import { useState, useMemo } from 'react';
import { useStore, type Product, type Order } from '../store/useStore';
import { X, Search, Plus, Trash2, User, Phone, Package, Filter, ScanLine, Save } from 'lucide-react';
import { supabase } from '../lib/supabase';

interface AddInvoiceModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess?: () => void;
}

export function AddInvoiceModal({ isOpen, onClose, onSuccess }: AddInvoiceModalProps) {
  const { 
    products, 
    categories, 
    customers, 
    activeCashier, 
    orders, 
  } = useStore();

  // Form Fields matching user image
  const [customerName, setCustomerName] = useState('');
  const [customerPhone, setCustomerPhone] = useState('');

  // Product Selection Fields
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [barcodeInput, setBarcodeInput] = useState<string>('');
  const [itemCodeInput, setItemCodeInput] = useState<string>('');
  const [productSearch, setProductSearch] = useState<string>('');
  const [selectedProductId, setSelectedProductId] = useState<string>('');
  const [quantity, setQuantity] = useState<number>(1);
  const [customPriceInput, setCustomPriceInput] = useState<string>('');

  // Added Products List (Cart)
  const [cart, setCart] = useState<{ product: Product; quantity: number; sale_price: number }[]>([]);

  // Payment field for ordinary in-store sales
  const paymentMethod = 'cash';

  const [isSaving, setIsSaving] = useState(false);

  // Next Invoice ID
  const nextInvoiceId = useMemo(() => {
    const existingIds = orders.map(o => parseInt(String(o.id).replace(/\D/g, ''))).filter(n => !isNaN(n));
    const maxId = existingIds.length > 0 ? Math.max(...existingIds) : 1000;
    return String(maxId + 1);
  }, [orders]);

  // Filter products by Category, Barcode, Code, and Search
  const filteredProducts = useMemo(() => {
    let list = products;

    if (selectedCategory !== 'all') {
      list = list.filter(p => p.category_id === selectedCategory);
    }

    if (barcodeInput.trim()) {
      const bc = barcodeInput.trim().toLowerCase();
      list = list.filter(p => p.barcode && p.barcode.toLowerCase().includes(bc));
    }

    if (itemCodeInput.trim()) {
      const code = itemCodeInput.trim().toLowerCase();
      list = list.filter(p => (p.barcode && p.barcode.toLowerCase().includes(code)) || p.name.toLowerCase().includes(code));
    }

    if (productSearch.trim()) {
      const q = productSearch.trim().toLowerCase();
      list = list.filter(p => 
        p.name.toLowerCase().includes(q) || 
        (p.barcode && p.barcode.toLowerCase().includes(q))
      );
    }

    return list.slice(0, 15);
  }, [products, selectedCategory, barcodeInput, itemCodeInput, productSearch]);


  if (!isOpen) return null;

  // Add Product to Cart
  const handleAddProductToInvoice = () => {
    let targetProduct: Product | undefined;

    if (selectedProductId) {
      targetProduct = products.find(p => p.id === selectedProductId);
    } else if (filteredProducts.length > 0) {
      targetProduct = filteredProducts[0];
    }

    if (!targetProduct) {
      alert('الرجاء اختيار منتج من القائمة أولاً');
      return;
    }

    const price = customPriceInput.trim() !== '' && !isNaN(Number(customPriceInput))
      ? Number(customPriceInput)
      : (targetProduct.discount_price && targetProduct.discount_price > 0 ? targetProduct.discount_price : targetProduct.sale_price);

    const qty = Math.max(1, Number(quantity) || 1);

    setCart(prev => {
      const existingIdx = prev.findIndex(item => item.product.id === targetProduct!.id && item.sale_price === price);
      if (existingIdx >= 0) {
        const updated = [...prev];
        updated[existingIdx].quantity += qty;
        return updated;
      }
      return [...prev, { product: targetProduct!, quantity: qty, sale_price: price }];
    });

    // Reset inputs after adding
    setSelectedProductId('');
    setCustomPriceInput('');
    setQuantity(1);
    setProductSearch('');
    setBarcodeInput('');
    setItemCodeInput('');
  };

  const handleRemoveProduct = (index: number) => {
    setCart(prev => prev.filter((_, i) => i !== index));
  };

  // Calculate Subtotal & Total
  const subtotal = cart.reduce((sum, i) => sum + (i.sale_price * i.quantity), 0);
  const grandTotal = subtotal;

  // Save a normal in-store retail invoice.
  const handleSaveInvoice = async () => {
    if (cart.length === 0) {
      alert('الرجاء إضافة منتج واحد على الأقل للفاتورة');
      return;
    }

    setIsSaving(true);
    try {
      const invoiceId = nextInvoiceId;
      const createdIso = new Date().toISOString();

      // 1. Create or Find Customer
      let customerId: string | null = null;
      if (customerName.trim()) {
        const existingCust = customers.find(c => c.phone && customerPhone && c.phone.trim() === customerPhone.trim());
        if (existingCust) {
          customerId = existingCust.id;
        } else {
          const { data: newCustData } = await supabase.from('customers').insert({
            name: customerName.trim(),
            phone: customerPhone.trim() || null,
            address: null
          }).select().single();
          if (newCustData) customerId = newCustData.id;
        }
      }

      // 2. Prepare Items
      const orderItems = cart.map(i => ({
        id: i.product.id,
        name: i.product.name,
        quantity: i.quantity,
        sale_price: i.sale_price,
        purchase_price: i.product.purchase_price || 0,
        unit: i.product.unit || 'قطعة'
      }));

      // 3. Save Order into Supabase (`orders` table)
      const orderRow = {
        id: invoiceId,
        total: grandTotal,
        paid_amount: grandTotal,
        paid_cash: 0,
        type: 'sale',
        customer_id: customerId,
        payment_method: paymentMethod,
        cashier_name: activeCashier?.name || 'مدير النظام',
        notes: 'بيع محل',
        created_at: createdIso
      };

      await supabase.from('orders').insert(orderRow);

      // Save Order Items & Update Stock
      for (const item of cart) {
        await supabase.from('order_items').insert({
          order_id: invoiceId,
          product_id: item.product.id,
          quantity: item.quantity,
          sale_price: item.sale_price,
          unit: item.product.unit || 'قطعة'
        });

        const newStock = Math.max(0, item.product.stock_quantity - item.quantity);
        await supabase.from('products').update({ stock_quantity: newStock }).eq('id', item.product.id);
      }


      // Refresh store states
      useStore.setState(state => ({
        orders: [{
          id: invoiceId,
          total: grandTotal,
          paid_amount: grandTotal,
          type: 'sale',
          cashier_name: activeCashier?.name || 'مدير النظام',
          date: createdIso,
          items: orderItems,
          notes: orderRow.notes
        } as unknown as Order, ...state.orders]
      }));


      alert(`تم إضافة الفاتورة #${invoiceId} بنجاح`);
      if (onSuccess) onSuccess();
      onClose();
    } catch (err: any) {
      console.error(err);
      alert('حدث خطأ أثناء حفظ الفاتورة: ' + (err.message || 'خطأ غير معروف'));
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/70 backdrop-blur-sm overflow-y-auto" dir="rtl">
      <div className="bg-white dark:bg-slate-800 rounded-3xl shadow-2xl border border-slate-200 dark:border-slate-700 w-full max-w-3xl max-h-[95vh] flex flex-col overflow-hidden text-slate-800 dark:text-slate-100">
        
        {/* Header - Identical to Image */}
        <div className="flex items-center justify-between px-6 py-4 bg-[#4a6b82] text-white">
          <div className="flex items-center gap-2 text-lg font-bold">
            <Package size={22} />
            <span>إنشاء فاتورة جديدة</span>
          </div>
          <button 
            onClick={onClose} 
            className="p-1 hover:bg-white/10 rounded-lg transition text-white"
          >
            <X size={20} />
          </button>
        </div>

        {/* Modal Form Body - Identical to Layout in User Image */}
        <div className="p-6 overflow-y-auto space-y-5 flex-1 text-right">
          
          {/* Row 1: Customer Name & Phone */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold text-slate-600 dark:text-slate-300 mb-1 flex items-center justify-end gap-1">
                <span>اسم العميل</span>
                <User size={14} className="text-slate-500" />
              </label>
              <input
                type="text"
                value={customerName}
                onChange={(e) => setCustomerName(e.target.value)}
                placeholder=""
                className="w-full px-3 py-2 bg-slate-50 dark:bg-slate-900 border border-slate-300 dark:border-slate-700 rounded-xl text-sm font-bold text-right"
              />
            </div>

            <div>
              <label className="block text-xs font-bold text-slate-600 dark:text-slate-300 mb-1 flex items-center justify-end gap-1">
                <span>رقم الهاتف</span>
                <Phone size={14} className="text-slate-500" />
              </label>
              <input
                type="text"
                value={customerPhone}
                onChange={(e) => setCustomerPhone(e.target.value)}
                placeholder=""
                className="w-full px-3 py-2 bg-slate-50 dark:bg-slate-900 border border-slate-300 dark:border-slate-700 rounded-xl text-sm font-bold text-right"
                dir="ltr"
              />
            </div>
          </div>

          {/* Product Section */}
          {/* Row 3: Product Section Header & Collection Filter */}
          <div className="pt-2 border-t border-slate-200 dark:border-slate-700 space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-xs font-bold text-slate-500 flex items-center gap-1">
                <Filter size={14} /> فلتر بالكوليكشن
              </span>
              <span className="text-sm font-black flex items-center gap-1 text-slate-800 dark:text-slate-100">
                <Package size={16} /> المنتج
              </span>
            </div>

            <select
              value={selectedCategory}
              onChange={(e) => setSelectedCategory(e.target.value)}
              className="w-full px-3 py-2 bg-slate-50 dark:bg-slate-900 border border-slate-300 dark:border-slate-700 rounded-xl text-sm font-bold text-right"
            >
              <option value="all">كل الكوليكشنز</option>
              {categories.map(cat => (
                <option key={cat.id} value={cat.id}>{cat.name}</option>
              ))}
            </select>

            {/* Product Search Inputs Row matching mockup */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-2">
              <div className="relative">
                <input
                  type="text"
                  value={productSearch}
                  onChange={(e) => setProductSearch(e.target.value)}
                  placeholder="ابحث بالاسم أو الكود..."
                  className="w-full pl-8 pr-3 py-2 bg-slate-50 dark:bg-slate-900 border border-slate-300 dark:border-slate-700 rounded-xl text-xs font-bold text-right"
                />
                <Search size={14} className="absolute left-2.5 top-1/2 -translate-y-1/2 text-slate-400" />
              </div>

              <button
                type="button"
                className="bg-[#5c72e2] text-white px-4 py-2 rounded-xl font-bold text-xs hover:bg-indigo-700 transition"
              >
                بحث
              </button>

              <div>
                <input
                  type="text"
                  value={itemCodeInput}
                  onChange={(e) => setItemCodeInput(e.target.value)}
                  placeholder="كود الصنف"
                  className="w-full px-3 py-2 bg-slate-50 dark:bg-slate-900 border border-slate-300 dark:border-slate-700 rounded-xl text-xs font-bold text-right"
                />
              </div>

              <div className="relative">
                <input
                  type="text"
                  value={barcodeInput}
                  onChange={(e) => setBarcodeInput(e.target.value)}
                  placeholder="سكان الباركود - امسح الباركود"
                  className="w-full pl-7 pr-3 py-2 bg-emerald-50/50 dark:bg-emerald-950/20 border border-emerald-400 dark:border-emerald-700 rounded-xl text-xs font-bold text-right"
                />
                <ScanLine size={14} className="absolute left-2 top-1/2 -translate-y-1/2 text-emerald-600" />
              </div>
            </div>

            {/* Matching Products Select Box */}
            {filteredProducts.length > 0 && (
              <select
                value={selectedProductId}
                onChange={(e) => setSelectedProductId(e.target.value)}
                className="w-full px-3 py-2 bg-indigo-50 dark:bg-indigo-950/40 border border-indigo-200 dark:border-indigo-800 rounded-xl text-xs font-bold text-right"
              >
                <option value="">اختر المنتج المقتنع به من نتائج البحث ({filteredProducts.length})</option>
                {filteredProducts.map(p => (
                  <option key={p.id} value={p.id}>
                    {p.name} - السعر: {p.sale_price} جنيه (المتاح: {p.stock_quantity})
                  </option>
                ))}
              </select>
            )}

            {/* Custom Price Field (Highlighted with Orange border matching mockup) */}
            <div>
              <label className="block text-xs font-bold text-slate-600 dark:text-slate-300 mb-1 flex items-center justify-end gap-1">
                <span>أو أدخل سعر مخصص (اختياري)</span>
              </label>
              <input
                type="text"
                value={customPriceInput}
                onChange={(e) => setCustomPriceInput(e.target.value)}
                placeholder="أدخل السعر يدوياً"
                className="w-full px-4 py-2.5 bg-white dark:bg-slate-900 border-2 border-amber-400 dark:border-amber-500 rounded-xl text-sm font-bold text-right focus:outline-none focus:ring-2 focus:ring-amber-400"
              />
              <span className="text-[11px] text-slate-400 block mt-1 text-right">اترك هذا الحقل فارغاً لاستخدام السعر المحدد أعلاه</span>
            </div>

            {/* Add Product Button */}
            <button
              type="button"
              onClick={handleAddProductToInvoice}
              className="w-full py-2.5 bg-[#4c6bf5] hover:bg-indigo-600 text-white rounded-xl font-black text-sm flex items-center justify-center gap-2 shadow-md transition"
            >
              <Plus size={18} />
              <span>إضافة المنتج للفاتورة</span>
            </button>
          </div>

          {/* Cart Table if Products Added */}
          {cart.length > 0 && (
            <div className="border border-slate-200 dark:border-slate-700 rounded-2xl overflow-hidden mt-4">
              <table className="w-full text-xs text-right">
                <thead className="bg-slate-100 dark:bg-slate-900/60 font-black text-slate-600 dark:text-slate-400 border-b border-slate-200 dark:border-slate-700">
                  <tr>
                    <th className="p-2.5">المنتج</th>
                    <th className="p-2.5 text-center">السعر</th>
                    <th className="p-2.5 text-center">الكمية</th>
                    <th className="p-2.5 text-center">الإجمالي</th>
                    <th className="p-2.5 text-center">حذف</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                  {cart.map((item, idx) => (
                    <tr key={idx}>
                      <td className="p-2.5 font-bold">{item.product.name}</td>
                      <td className="p-2.5 text-center font-bold">{item.sale_price} ج.م</td>
                      <td className="p-2.5 text-center font-bold">{item.quantity}</td>
                      <td className="p-2.5 text-center font-black text-indigo-600">{(item.sale_price * item.quantity).toFixed(2)} ج.م</td>
                      <td className="p-2.5 text-center">
                        <button onClick={() => handleRemoveProduct(idx)} className="text-red-500 hover:text-red-700">
                          <Trash2 size={14} />
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}


        </div>

        {/* Footer Buttons - Identical to Image */}
        <div className="flex items-center justify-center gap-3 px-6 py-4 bg-slate-100 dark:bg-slate-900 border-t border-slate-200 dark:border-slate-700">
          <button
            type="button"
            disabled={isSaving || cart.length === 0}
            onClick={handleSaveInvoice}
            className="px-6 py-2.5 bg-[#425968] hover:bg-slate-700 text-white rounded-xl font-bold text-sm flex items-center gap-2 shadow transition disabled:opacity-50"
          >
            <Save size={16} />
            <span>{isSaving ? 'جارٍ الحفظ...' : 'حفظ الفاتورة'}</span>
          </button>

          <button
            type="button"
            onClick={onClose}
            className="px-6 py-2.5 bg-[#64748b] hover:bg-slate-600 text-white rounded-xl font-bold text-sm flex items-center gap-2 transition"
          >
            <X size={16} />
            <span>إلغاء</span>
          </button>
        </div>

      </div>
    </div>
  );
}
