-- Mido Market — atomic day closing
-- Applies one closing transfer as a single PostgreSQL transaction.
-- Safe to run more than once.

create or replace function public.create_day_closing_atomic(
  p_day text,
  p_split jsonb,
  p_note text default null
)
returns jsonb
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_day date;
  v_hour integer;
  v_start timestamptz;
  v_end timestamptz;
  v_group uuid := gen_random_uuid();
  v_total numeric := 0;
  v_primary text := 'cash';
  v_best numeric := -1;
  v_method text;
  v_amount numeric;
  v_note text;
begin
  if p_day is null or p_day !~ '^\d{4}-\d{2}-\d{2}$' then
    raise exception 'invalid accounting day';
  end if;
  v_day := p_day::date;
  select greatest(0, least(23, coalesce(day_start_hour, 3)))
    into v_hour
    from store_settings
   order by id
   limit 1;
  v_hour := coalesce(v_hour, 3);
  v_start := ((v_day::timestamp + make_interval(hours => v_hour)) at time zone 'Africa/Cairo');
  v_end := v_start + interval '1 day';

  -- Serializes two cashiers trying to close the same accounting day.
  perform pg_advisory_xact_lock(hashtext('mido-market-day-closing:' || p_day));

  if exists (
    select 1 from expenses
     where category = 'تحويل للخزنة الرئيسية'
       and created_at >= v_start and created_at < v_end
  ) then
    raise exception 'day_already_closed';
  end if;

  v_note := coalesce(nullif(trim(p_note), ''), 'تقفيل يوم ' || p_day);

  foreach v_method in array array['cash','visa','wallet','instapay','method5','method6'] loop
    v_amount := greatest(0, coalesce((p_split ->> v_method)::numeric, 0));
    if v_amount > 0 then
      insert into savings_transactions(direction, amount, method, source, note, group_id)
      values ('in', v_amount, v_method, 'day_closing', v_note, v_group);
      v_total := v_total + v_amount;
      if v_amount > v_best then
        v_best := v_amount;
        v_primary := v_method;
      end if;
    end if;
  end loop;

  if v_total <= 0 then
    raise exception 'closing_amount_must_be_positive';
  end if;

  insert into expenses(
    category, amount, payment_method,
    paid_cash, paid_visa, paid_wallet, paid_instapay, paid_method5, paid_method6,
    note, created_at
  ) values (
    'تحويل للخزنة الرئيسية', v_total, v_primary,
    greatest(0, coalesce((p_split ->> 'cash')::numeric, 0)),
    greatest(0, coalesce((p_split ->> 'visa')::numeric, 0)),
    greatest(0, coalesce((p_split ->> 'wallet')::numeric, 0)),
    greatest(0, coalesce((p_split ->> 'instapay')::numeric, 0)),
    greatest(0, coalesce((p_split ->> 'method5')::numeric, 0)),
    greatest(0, coalesce((p_split ->> 'method6')::numeric, 0)),
    '[SVG:' || v_group::text || '] ' || v_note,
    v_start + interval '12 hours'
  );

  return jsonb_build_object('ok', true, 'day', p_day, 'group_id', v_group, 'amount', v_total);
exception
  when unique_violation then
    raise exception 'day_already_closed';
end;
$$;

grant execute on function public.create_day_closing_atomic(text, jsonb, text) to anon, authenticated;
