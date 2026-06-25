-- =====================================================================
--  Migrasi: Pembayaran manual (transfer) + bukti transfer.
-- ---------------------------------------------------------------------
--  Jalankan di SQL Editor SETELAH schema.sql untuk project yang sudah ada.
--  Untuk project baru, schema.sql sudah memuat perubahan ini.
-- =====================================================================

-- 1. Tambah status "menunggu_pembayaran" & kolom URL bukti transfer.
alter table public.orders drop constraint if exists orders_status_check;
alter table public.orders add constraint orders_status_check
  check (status in ('menunggu_pembayaran','diproses','dikirim','selesai','dibatalkan'));

alter table public.orders add column if not exists payment_proof_url text;

-- 2. Bucket Storage publik untuk menyimpan gambar bukti transfer.
insert into storage.buckets (id, name, public)
values ('payment-proofs', 'payment-proofs', true)
on conflict (id) do nothing;

-- 3. Policy Storage: semua orang boleh melihat (bucket publik), user login
--    boleh upload & memperbarui bukti miliknya.
drop policy if exists "proof_read_public" on storage.objects;
create policy "proof_read_public" on storage.objects
  for select using (bucket_id = 'payment-proofs');

drop policy if exists "proof_insert_auth" on storage.objects;
create policy "proof_insert_auth" on storage.objects
  for insert to authenticated with check (bucket_id = 'payment-proofs');

drop policy if exists "proof_update_auth" on storage.objects;
create policy "proof_update_auth" on storage.objects
  for update to authenticated using (bucket_id = 'payment-proofs');
