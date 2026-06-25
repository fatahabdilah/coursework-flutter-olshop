-- =====================================================================
--  Olshop — Skema database Supabase (PostgreSQL)
-- ---------------------------------------------------------------------
--  Jalankan seluruh file ini di Supabase Dashboard > SQL Editor.
--  Mencakup: tabel, Row Level Security (RLS), trigger profil otomatis,
--  role admin, dan seed produk awal.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. PROFIL PENGGUNA
--    Satu baris per akun auth.users. Menyimpan nama & role (customer/admin).
-- ---------------------------------------------------------------------
create table if not exists public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  full_name   text not null default '',
  role        text not null default 'customer' check (role in ('customer', 'admin')),
  created_at  timestamptz not null default now()
);

-- Helper: apakah user yang sedang login seorang admin?
-- SECURITY DEFINER agar bisa membaca profiles tanpa terjebak RLS rekursif.
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- Saat user baru mendaftar, buat profil otomatis.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', ''));
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------
-- 2. PRODUK
-- ---------------------------------------------------------------------
create table if not exists public.products (
  id           text primary key default gen_random_uuid()::text,
  name         text not null,
  description  text not null default '',
  price        numeric not null check (price >= 0),
  old_price    numeric,
  category     text not null,
  emoji        text not null default '📦',
  rating       numeric not null default 4.5,
  sold         integer not null default 0,
  stock        integer not null default 0,
  created_at   timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 3. KERANJANG (per pengguna)
-- ---------------------------------------------------------------------
create table if not exists public.cart_items (
  user_id     uuid not null references auth.users (id) on delete cascade,
  product_id  text not null references public.products (id) on delete cascade,
  quantity    integer not null check (quantity > 0),
  updated_at  timestamptz not null default now(),
  primary key (user_id, product_id)
);

-- ---------------------------------------------------------------------
-- 4. FAVORIT / WISHLIST (per pengguna)
-- ---------------------------------------------------------------------
create table if not exists public.favorites (
  user_id     uuid not null references auth.users (id) on delete cascade,
  product_id  text not null references public.products (id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (user_id, product_id)
);

-- ---------------------------------------------------------------------
-- 5. ALAMAT PENGIRIMAN (per pengguna)
-- ---------------------------------------------------------------------
create table if not exists public.addresses (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users (id) on delete cascade,
  label       text not null,
  recipient   text not null,
  phone       text not null,
  detail      text not null,
  is_default  boolean not null default false,
  created_at  timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 6. PESANAN + ITEM PESANAN (per pengguna)
-- ---------------------------------------------------------------------
create table if not exists public.orders (
  id               text primary key,
  user_id          uuid not null references auth.users (id) on delete cascade,
  date             timestamptz not null default now(),
  shipping_cost    numeric not null default 0,
  shipping_method  text not null,
  payment_method   text not null,
  address          text not null,
  status           text not null default 'diproses'
                     check (status in ('menunggu_pembayaran', 'diproses', 'dikirim', 'selesai', 'dibatalkan')),
  payment_proof_url text,
  created_at       timestamptz not null default now()
);

create table if not exists public.order_items (
  id          uuid primary key default gen_random_uuid(),
  order_id    text not null references public.orders (id) on delete cascade,
  product_id  text not null,
  name        text not null,
  emoji       text not null,
  price       numeric not null,
  quantity    integer not null check (quantity > 0)
);

-- =====================================================================
--  ROW LEVEL SECURITY
-- =====================================================================
alter table public.profiles    enable row level security;
alter table public.products    enable row level security;
alter table public.cart_items  enable row level security;
alter table public.favorites   enable row level security;
alter table public.addresses   enable row level security;
alter table public.orders      enable row level security;
alter table public.order_items enable row level security;

-- PROFIL: tiap user membaca/ubah profilnya sendiri; admin boleh baca semua.
create policy "profiles_select_own"  on public.profiles for select using (auth.uid() = id or public.is_admin());
create policy "profiles_update_own"  on public.profiles for update using (auth.uid() = id);

-- PRODUK: semua user login boleh melihat; hanya admin yang boleh ubah.
create policy "products_select_all"  on public.products for select using (auth.role() = 'authenticated');
create policy "products_admin_insert" on public.products for insert with check (public.is_admin());
create policy "products_admin_update" on public.products for update using (public.is_admin());
create policy "products_admin_delete" on public.products for delete using (public.is_admin());

-- KERANJANG: tiap user hanya atas datanya sendiri.
create policy "cart_own" on public.cart_items for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- FAVORIT: tiap user hanya atas datanya sendiri.
create policy "favorites_own" on public.favorites for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ALAMAT: tiap user hanya atas datanya sendiri.
create policy "addresses_own" on public.addresses for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- PESANAN: user atas pesanannya sendiri; admin boleh baca/ubah semua.
create policy "orders_select" on public.orders for select using (auth.uid() = user_id or public.is_admin());
create policy "orders_insert" on public.orders for insert with check (auth.uid() = user_id);
create policy "orders_admin_update" on public.orders for update using (public.is_admin());

-- ITEM PESANAN: ikut izin pesanan induknya.
create policy "order_items_select" on public.order_items for select
  using (exists (select 1 from public.orders o
                 where o.id = order_id and (o.user_id = auth.uid() or public.is_admin())));
create policy "order_items_insert" on public.order_items for insert
  with check (exists (select 1 from public.orders o
                      where o.id = order_id and o.user_id = auth.uid()));

-- =====================================================================
--  SEED PRODUK AWAL  (sinkron dengan lib/data/sample_data.dart)
-- =====================================================================
insert into public.products (id, name, description, price, old_price, category, emoji, rating, sold, stock) values
  ('e1', 'Wireless Headphone Pro', 'Headphone nirkabel dengan active noise cancelling, baterai tahan 30 jam, dan suara bass yang dalam. Cocok untuk kerja maupun mendengarkan musik seharian.', 850000, 1100000, 'Elektronik', '🎧', 4.8, 1243, 80),
  ('e2', 'Smartphone X12 5G', 'Layar AMOLED 6.7", chipset terbaru, kamera 108MP, dan pengisian cepat 67W. Performa kencang untuk multitasking dan gaming.', 4500000, null, 'Elektronik', '📱', 4.7, 856, 35),
  ('e3', 'Laptop UltraSlim 14"', 'Laptop tipis ringan 1.2kg, prosesor Core i7, RAM 16GB, SSD 512GB. Ideal untuk produktivitas dan mobilitas tinggi.', 12500000, 13900000, 'Elektronik', '💻', 4.9, 432, 18),
  ('e4', 'Smartwatch Fit 5', 'Pantau detak jantung, SpO2, dan tidur. Tahan air 5ATM dengan baterai hingga 14 hari. Lebih dari 100 mode olahraga.', 1250000, 1500000, 'Elektronik', '⌚', 4.6, 980, 60),
  ('e5', 'Keyboard Mekanik RGB', 'Keyboard mekanik hot-swappable dengan lampu RGB, switch taktil, dan body aluminium. Pengalaman mengetik yang memuaskan.', 650000, null, 'Elektronik', '⌨️', 4.7, 541, 45),
  ('e6', 'Kamera Mirrorless M50', 'Sensor APS-C 24MP, perekaman video 4K, dan layar putar. Ringan dan ringkas untuk konten kreator pemula maupun profesional.', 8900000, null, 'Elektronik', '📷', 4.8, 213, 12),
  ('f1', 'Kaos Premium Cotton', 'Kaos katun combed 30s yang adem dan nyaman dipakai harian. Jahitan rapi, tidak mudah melar, tersedia berbagai warna.', 120000, 150000, 'Fashion', '👕', 4.5, 3210, 200),
  ('f2', 'Sneakers Run Lite', 'Sepatu lari dengan sol empuk responsif dan upper mesh breathable. Ringan untuk lari maupun aktivitas sehari-hari.', 480000, 599000, 'Fashion', '👟', 4.6, 1502, 90),
  ('f3', 'Hoodie Oversize', 'Hoodie bahan fleece tebal dan hangat dengan potongan oversize kekinian. Cocok untuk gaya kasual maupun santai.', 250000, null, 'Fashion', '🧥', 4.4, 874, 110),
  ('f4', 'Tas Ransel Urban', 'Ransel tahan air dengan kompartemen laptop 15", banyak kantong, dan port USB. Praktis untuk kerja dan traveling.', 320000, 420000, 'Fashion', '🎒', 4.7, 645, 70),
  ('m1', 'Kopi Arabika 250gr', 'Biji kopi arabika single origin, dipanggang medium dengan aroma cokelat dan caramel. Nikmat diseduh manual maupun espresso.', 85000, null, 'Makanan', '☕', 4.9, 2104, 150),
  ('m2', 'Cokelat Premium Bar', 'Dark chocolate 70% cocoa tanpa pemanis berlebih. Lembut, sedikit pahit, dan kaya rasa. Camilan sehat untuk menemani harimu.', 45000, 55000, 'Makanan', '🍫', 4.6, 1820, 300),
  ('h1', 'Lampu Meja Minimalis', 'Lampu LED dengan 3 tingkat kecerahan dan pengaturan warna cahaya. Desain minimalis modern untuk meja kerja atau belajar.', 175000, null, 'Rumah', '💡', 4.5, 523, 85),
  ('h2', 'Kursi Kerja Ergonomis', 'Kursi dengan sandaran mesh, penyangga pinggang, dan tinggi yang dapat diatur. Mendukung postur nyaman saat kerja lama.', 1850000, 2200000, 'Rumah', '🪑', 4.7, 234, 22),
  ('b1', 'Serum Wajah Glow', 'Serum dengan niacinamide dan vitamin C untuk mencerahkan dan meratakan warna kulit. Tekstur ringan, cepat meresap.', 159000, 199000, 'Kecantikan', '🧴', 4.8, 2640, 130),
  ('b2', 'Lipstik Matte Set', 'Set 3 lipstik matte yang tahan lama dan tidak membuat bibir kering. Pigmentasi pekat dengan pilihan warna cantik.', 220000, null, 'Kecantikan', '💄', 4.6, 1408, 95),
  ('s1', 'Matras Yoga Anti-slip', 'Matras yoga tebal 8mm dengan permukaan anti-slip dan empuk di lutut. Dilengkapi tali pengikat untuk dibawa bepergian.', 199000, 249000, 'Olahraga', '🧘', 4.7, 762, 100),
  ('s2', 'Dumbbell Set 10kg', 'Sepasang dumbbell dengan beban yang dapat diatur, lapisan karet anti gores. Cocok untuk latihan kekuatan di rumah.', 350000, null, 'Olahraga', '🏋️', 4.5, 489, 55)
on conflict (id) do nothing;

-- =====================================================================
--  STORAGE: bukti transfer (pembayaran manual)
-- =====================================================================
insert into storage.buckets (id, name, public)
values ('payment-proofs', 'payment-proofs', true)
on conflict (id) do nothing;

drop policy if exists "proof_read_public" on storage.objects;
create policy "proof_read_public" on storage.objects
  for select using (bucket_id = 'payment-proofs');

drop policy if exists "proof_insert_auth" on storage.objects;
create policy "proof_insert_auth" on storage.objects
  for insert to authenticated with check (bucket_id = 'payment-proofs');

drop policy if exists "proof_update_auth" on storage.objects;
create policy "proof_update_auth" on storage.objects
  for update to authenticated using (bucket_id = 'payment-proofs');

-- =====================================================================
--  CARA MENJADIKAN AKUN SEBAGAI ADMIN
--  Daftar dulu lewat aplikasi, lalu jalankan (ganti emailnya):
--
--    update public.profiles set role = 'admin'
--    where id = (select id from auth.users where email = 'admin@email.com');
-- =====================================================================
