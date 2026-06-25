# Panduan Menghubungkan Olshop ke Supabase

Aplikasi ini sudah terintegrasi penuh dengan Supabase: autentikasi (login/daftar),
katalog produk, keranjang, favorit, alamat, dan pesanan — semuanya tersimpan di
cloud dan tersinkron per pengguna. Ada juga peran **admin** untuk mengelola produk.

## 1. Buat project Supabase
1. Masuk ke <https://supabase.com> → **New Project**.
2. Catat **Project URL** dan **anon key** dari **Project Settings → API**.

## 2. Isi kredensial
Edit file `.env` di root proyek:

```
SUPABASE_URL=https://xxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...   # anon/public key
```

> File `.env` sudah masuk `.gitignore` agar tidak ikut ter-commit.
> Contoh formatnya ada di `.env.example`.

## 3. Buat tabel & kebijakan keamanan
1. Buka **SQL Editor** di dashboard Supabase.
2. Salin seluruh isi [`supabase/schema.sql`](supabase/schema.sql) → **Run**.

Script ini membuat tabel `profiles`, `products`, `cart_items`, `favorites`,
`addresses`, `orders`, `order_items`, mengaktifkan Row Level Security (RLS),
trigger pembuatan profil otomatis saat user mendaftar, serta meng-_insert_
18 produk awal (sama dengan katalog contoh lama).

## 4. (Opsional) Pengaturan verifikasi email
Default Supabase mewajibkan verifikasi email saat mendaftar. Untuk memudahkan
pengujian coursework, matikan lewat **Authentication → Providers → Email →
"Confirm email"** (nonaktifkan) agar akun langsung bisa dipakai setelah daftar.

## 5. Menjadikan akun sebagai admin
1. Jalankan aplikasi, daftar akun (mis. `admin@email.com`).
2. Di **SQL Editor**, jalankan (ganti emailnya):

```sql
update public.profiles set role = 'admin'
where id = (select id from auth.users where email = 'admin@email.com');
```

3. Login ulang. Menu **Kelola Produk** akan muncul di tab Profil — admin bisa
   menambah, mengubah, dan menghapus produk.

## 6. Jalankan aplikasi
```bash
flutter pub get
flutter run
```

## Arsitektur singkat
- `lib/providers/auth_provider.dart` — sesi login + role (admin/customer).
- `lib/providers/products_provider.dart` — katalog produk + CRUD admin.
- `lib/providers/{cart,favorites,orders,address}_provider.dart` — data per-pengguna
  yang tersinkron ke Supabase.
- `lib/screens/auth/auth_gate.dart` — menampilkan login bila belum masuk, atau
  aplikasi utama bila sudah; memuat katalog lalu menyiapkan provider per-pengguna.
- `lib/screens/admin/` — layar manajemen produk khusus admin.
