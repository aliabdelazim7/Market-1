-- Fix public invoice lookup for Marker1's text-based IDs.
-- Safe to run repeatedly. It changes only the SECURITY DEFINER read function.

create or replace function public.get_public_invoice(p_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_settings jsonb;
  v_order jsonb;
  v_customer_id text;
  v_appointment jsonb;
  v_subscription_id text;
  v_purchase jsonb;
begin
  select jsonb_build_object(
    'name', s.name,
    'currency', s.currency,
    'logo', s.logo,
    'tax_rate', s.tax_rate,
    'theme_color', s.theme_color,
    'address', s.address,
    'phone', s.phone,
    'phone2', s.phone2,
    'whatsapp_country_code', s.whatsapp_country_code,
    'initial_balance', s.initial_balance,
    'location_url', s.location_url,
    'tax_number', coalesce(s.tax_number, ''),
    'commercial_record', coalesce(s.commercial_record, '')
  )
  into v_settings
  from store_settings s
  limit 1;

  -- Sale invoice: public links use the same text id shown by the app.
  select
    to_jsonb(o) || jsonb_build_object(
      'customers', (
        select to_jsonb(c)
        from customers c
        where c.id::text = o.customer_id::text
      ),
      'order_items', (
        select coalesce(jsonb_agg(
          to_jsonb(oi) || jsonb_build_object(
            'products', (
              select jsonb_build_object(
                'name', p.name,
                'sale_price', p.sale_price,
                'discount_price', p.discount_price
              )
              from products p
              where p.id::text = oi.product_id::text
            )
          )
        ), '[]'::jsonb)
        from order_items oi
        where oi.order_id::text = o.id::text
      )
    ),
    o.customer_id::text
  into v_order, v_customer_id
  from orders o
  where o.id::text = p_id
    and coalesce(o.is_deleted, false) = false;

  if v_order is not null then
    return jsonb_build_object(
      'kind', 'order',
      'settings', v_settings,
      'order', v_order,
      'customer_orders', coalesce((
        select jsonb_agg(
          to_jsonb(o2) || jsonb_build_object(
            'order_items', (
              select coalesce(jsonb_agg(jsonb_build_object(
                'quantity', oi.quantity,
                'sale_price', oi.sale_price,
                'returned_quantity', oi.returned_quantity,
                'refunded_amount', oi.refunded_amount
              )), '[]'::jsonb)
              from order_items oi
              where oi.order_id::text = o2.id::text
            )
          )
        )
        from orders o2
        where o2.customer_id::text = v_customer_id
          and coalesce(o2.is_deleted, false) = false
      ), '[]'::jsonb)
    );
  end if;

  -- Maintenance appointment, when that optional table exists.
  if to_regclass('public.maintenance_appointments') is not null then
    select
      to_jsonb(a) || jsonb_build_object(
        'car_subscriptions', (
          select to_jsonb(cs)
          from car_subscriptions cs
          where cs.id::text = a.subscription_id::text
        )
      ),
      a.subscription_id::text
    into v_appointment, v_subscription_id
    from maintenance_appointments a
    where a.id::text = p_id;

    if v_appointment is not null then
      return jsonb_build_object(
        'kind', 'maintenance',
        'settings', v_settings,
        'appointment', v_appointment,
        'appointment_orders', coalesce((
          select jsonb_agg(
            to_jsonb(o) || jsonb_build_object(
              'order_items', (
                select coalesce(jsonb_agg(
                  to_jsonb(oi) || jsonb_build_object(
                    'products', (
                      select jsonb_build_object(
                        'name', p.name,
                        'sale_price', p.sale_price,
                        'discount_price', p.discount_price
                      )
                      from products p
                      where p.id::text = oi.product_id::text
                    )
                  )
                ), '[]'::jsonb)
                from order_items oi
                where oi.order_id::text = o.id::text
              )
            )
          )
          from orders o
          where o.car_id::text = v_subscription_id
            and coalesce(o.is_deleted, false) = false
        ), '[]'::jsonb)
      );
    end if;
  end if;

  -- Purchase invoice by internal id or displayed invoice number.
  select
    to_jsonb(pi) || jsonb_build_object(
      'suppliers', (
        select to_jsonb(su)
        from suppliers su
        where su.id::text = pi.supplier_id::text
      ),
      'purchase_items', (
        select coalesce(jsonb_agg(
          to_jsonb(it) || jsonb_build_object(
            'products', (
              select jsonb_build_object(
                'name', p.name,
                'sale_price', p.sale_price,
                'discount_price', p.discount_price
              )
              from products p
              where p.id::text = it.product_id::text
            )
          )
        ), '[]'::jsonb)
        from purchase_items it
        where it.invoice_id::text = pi.id::text
      )
    )
  into v_purchase
  from purchase_invoices pi
  where pi.id::text = p_id
     or pi.invoice_number::text = p_id
  limit 1;

  if v_purchase is not null then
    return jsonb_build_object(
      'kind', 'purchase',
      'settings', v_settings,
      'purchase', v_purchase
    );
  end if;

  return null;
end;
$$;

revoke all on function public.get_public_invoice(text) from public;
grant execute on function public.get_public_invoice(text) to anon, authenticated;

comment on function public.get_public_invoice(text) is
'Public invoice lookup compatible with Marker1 text-based IDs; exposes only one requested invoice plus required receipt data.';

select public.get_public_invoice('98') is not null as invoice_98_found;
