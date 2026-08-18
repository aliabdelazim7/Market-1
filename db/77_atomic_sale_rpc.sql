-- Market 1 — atomic sale transaction
-- Applies the order header, order items, and stock changes in one PostgreSQL transaction.
-- Safe to run repeatedly.

create or replace function public.create_sale_atomic(
  p_order jsonb,
  p_items jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_ref text := nullif(p_order->>'client_ref', '');
  v_order_id text;
  v_item jsonb;
  v_product_id uuid;
  v_product products%rowtype;
  v_qty numeric;
  v_items_count integer := coalesce(jsonb_array_length(p_items), 0);
  v_existing orders%rowtype;
  v_order orders%rowtype;
begin
  if v_items_count = 0 and coalesce(p_order->>'type', 'sale') not in ('payment', 'previous_debt') then
    raise exception using errcode = '22023', message = 'لا يمكن حفظ فاتورة بدون أصناف';
  end if;

  -- Idempotency: a retry with the same client_ref returns the already-created order.
  if v_ref is not null then
    select * into v_existing from orders where client_ref = v_ref limit 1;
    if found then
      return jsonb_build_object('duplicate', true, 'order', to_jsonb(v_existing));
    end if;
  end if;

  v_order_id := nullif(p_order->>'id', '');
  if v_order_id is null then
    v_order_id := next_invoice_number()::text;
  end if;

  insert into orders (
    id, total, paid_amount, paid_cash, paid_visa, paid_wallet,
    paid_instapay, paid_method5, paid_method6, type, customer_id,
    payment_method, cashier_name, salesperson_id, salesperson_name,
    notes, coupon_code, discount_amount, car_id, created_at, client_ref
  ) values (
    v_order_id,
    coalesce((p_order->>'total')::numeric, 0),
    coalesce((p_order->>'paid_amount')::numeric, 0),
    coalesce((p_order->>'paid_cash')::numeric, 0),
    coalesce((p_order->>'paid_visa')::numeric, 0),
    coalesce((p_order->>'paid_wallet')::numeric, 0),
    coalesce((p_order->>'paid_instapay')::numeric, 0),
    coalesce((p_order->>'paid_method5')::numeric, 0),
    coalesce((p_order->>'paid_method6')::numeric, 0),
    coalesce(nullif(p_order->>'type', ''), 'sale'),
    nullif(p_order->>'customer_id', '')::uuid,
    coalesce(nullif(p_order->>'payment_method', ''), 'cash'),
    coalesce(nullif(p_order->>'cashier_name', ''), 'مدير النظام'),
    nullif(p_order->>'salesperson_id', '')::uuid,
    nullif(p_order->>'salesperson_name', ''),
    nullif(p_order->>'notes', ''),
    nullif(p_order->>'coupon_code', ''),
    coalesce((p_order->>'discount_amount')::numeric, 0),
    nullif(p_order->>'car_id', '')::uuid,
    coalesce((p_order->>'created_at')::timestamptz, now()),
    v_ref
  ) returning * into v_order;

  for v_item in select value from jsonb_array_elements(p_items)
  loop
    v_product_id := (v_item->>'product_id')::uuid;
    v_qty := coalesce((v_item->>'quantity')::numeric, 0);
    if v_qty <= 0 then
      raise exception using errcode = '22023', message = 'كمية صنف غير صحيحة';
    end if;

    select * into v_product from products where id = v_product_id for update;
    if not found then
      raise exception using errcode = '23503', message = 'الصنف غير موجود';
    end if;

    insert into order_items (
      order_id, product_id, product_name, barcode, quantity,
      returned_quantity, sale_price, purchase_price
    ) values (
      v_order_id, v_product_id,
      coalesce(nullif(v_item->>'product_name', ''), v_product.name, 'صنف'),
      nullif(v_item->>'barcode', ''),
      v_qty, 0,
      coalesce((v_item->>'sale_price')::numeric, 0),
      coalesce((v_item->>'purchase_price')::numeric, v_product.average_purchase_price, v_product.purchase_price, 0)
    );

    update products
       set stock_quantity = greatest(0, coalesce(v_product.stock_quantity, 0) - v_qty),
           display_quantity = least(
             coalesce(v_product.display_quantity, 0),
             greatest(0, coalesce(v_product.stock_quantity, 0) - v_qty)
           )
     where id = v_product_id;
  end loop;

  return jsonb_build_object('duplicate', false, 'order', to_jsonb(v_order));
exception
  when unique_violation then
    if v_ref is not null then
      select * into v_existing from orders where client_ref = v_ref limit 1;
      if found then
        return jsonb_build_object('duplicate', true, 'order', to_jsonb(v_existing));
      end if;
    end if;
    raise;
end;
$$;

grant execute on function public.create_sale_atomic(jsonb, jsonb) to anon, authenticated;
notify pgrst, 'reload schema';
