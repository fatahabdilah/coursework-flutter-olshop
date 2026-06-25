-- =====================================================================
--  Seed akun ADMIN langsung dari SQL (untuk testing / coursework).
-- ---------------------------------------------------------------------
--  Jalankan di Supabase Dashboard > SQL Editor SETELAH schema.sql.
--  Login pakai:  email = admin@olshop.com   password = 12345678
--
--  PERINGATAN: password ini lemah, hanya untuk pengembangan lokal.
-- =====================================================================

do $$
declare
  v_email    text := 'admin@olshop.com';
  v_password text := '12345678';
  v_user_id  uuid;
begin
  -- Jika akun sudah ada, cukup pastikan rolenya admin lalu keluar.
  select id into v_user_id from auth.users where email = v_email;
  if v_user_id is not null then
    update public.profiles set role = 'admin', full_name = 'Admin'
      where id = v_user_id;
    raise notice 'Akun % sudah ada — role diset admin.', v_email;
    return;
  end if;

  v_user_id := gen_random_uuid();

  -- Buat user di sistem auth Supabase (email langsung terkonfirmasi).
  insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    raw_app_meta_data, raw_user_meta_data,
    confirmation_token, recovery_token, email_change_token_new, email_change
  ) values (
    '00000000-0000-0000-0000-000000000000',
    v_user_id, 'authenticated', 'authenticated',
    v_email, crypt(v_password, gen_salt('bf')),
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Admin"}',
    '', '', '', ''
  );

  -- Identity provider email (diperlukan agar login email/password jalan).
  insert into auth.identities (
    id, user_id, identity_data, provider, provider_id,
    last_sign_in_at, created_at, updated_at
  ) values (
    gen_random_uuid(), v_user_id,
    jsonb_build_object('sub', v_user_id::text, 'email', v_email),
    'email', v_user_id::text,
    now(), now(), now()
  );

  -- Trigger handle_new_user sudah membuat baris profiles; jadikan admin.
  update public.profiles set role = 'admin', full_name = 'Admin'
    where id = v_user_id;

  raise notice 'Akun admin % berhasil dibuat.', v_email;
end $$;
