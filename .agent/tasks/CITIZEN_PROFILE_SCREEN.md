# TASK: Implementasi Halaman Profil Warga & Konfirmasi Logout

**Screen**: Profil Warga + Bottom Sheet Konfirmasi Keluar Akun — Pantaura Flutter  
**Stitch Project**: `projects/13707441510623217137`  
**Design lokal**:
- `.stitch_pantaura_flutter/profil_warga_siagakita/code.html` + `screen.png`
- `.stitch_pantaura_flutter/konfirmasi_keluar_akun_siagakita/code.html` + `screen.png`
**Route**: `AppRoutes.profile` (`/profile`) pada `StatefulShellBranch` — menggantikan `_PlaceholderTabScreen(title: 'Profil Warga')`  
**Target file**: `lib/features/profile/`

---

## Fase 0: Persiapan & Desain

- [x] Baca `AGENT.md` dan internalisasi rules (Riverpod 3.5, go_router, WCAG AAA, touch target 48–56dp)
- [x] **Cek design Stitch lokal terlebih dahulu**: kedua `code.html` lalu `screen.png`. **Jangan akses MCP Stitch** kecuali diperintahkan
- [x] Baca `lib/core/routing/app_router.dart` — branch ke-4 `AppRoutes.profile` masih placeholder
- [x] Baca `lib/features/auth/auth_notifier.dart` — `AuthAuthenticated.user`, `logout()`
- [x] Baca `lib/features/home/home_screen.dart` — `_showEmergency112Dialog()` (dialog 112 yang dipakai ulang)
- [x] Baca `lib/features/home/widgets/home_emergency_banner.dart` — callback `onEmergencyCallTap` sebagai pintu masuk dialog 112
- [x] Baca `API.md` — `GET /auth/me`, `POST /auth/logout`
- [x] Baca `lib/core/theme/` — AppColors, AppTypography, AppSpacing, AppRadius, AppShadows
- [x] Cek `pubspec.yaml`: `url_launcher` **belum ada**, perlu ditambahkan untuk membuka PDF BNPB

---

## Fase 1: State & Data Layer

- [x] Gunakan `authNotifierProvider` sebagai sumber data profil (`AuthAuthenticated.user`: name, email, role)
- [x] Tambahkan `url_launcher: ^6.x` ke `pubspec.yaml` dan jalankan `flutter pub get`
- [x] (Opsional) `lib/features/profile/profile_state.dart` bila perlu menyimpan status dialog logout; jika tidak, cukup state lokal di screen
- [x] Ekstrak dialog 112 ke widget bersama `lib/core/widgets/emergency_112_dialog.dart` agar home & profil identik; update `home_screen.dart` untuk memakainya

---

## Fase 2: Screen & Widget (urutan atas → bawah sesuai `code.html`)

- [x] Buat `lib/features/profile/profile_screen.dart` (`ConsumerStatefulWidget` / `ConsumerWidget`)
  - [x] Semua widget turunan di `lib/features/profile/widgets/`
  - [x] Helper `void _showComingSoon(String label)` → `ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label masih dikembangkan')))`

### 2.1 — Header

- [x] Widget `ProfileHeader` — ikon shield di `surfaceTintIce`, judul "Profil Warga", tombol settings (48dp) → snackbar "masih dikembangkan", avatar kanan

### 2.2 — Card Profil

- [x] Widget `ProfileIdentityCard`
  - [x] Avatar inisial nama (atau foto bila tersedia), nama dari `user.name`, email dari `user.email`
  - [x] Baris alamat/RT-RW (bila tidak ada data, tampilkan teks fallback)
  - [x] Chip role warga / relawan (bila `user.role` tersedia)

### 2.3 — Aksesibilitas & Ramah Lansia (pajangan)

- [x] Widget `AccessibilitySection`
  - [x] 3 baris toggle tampilan: "Mode Teks Besar (+20%)", "Kontras Tinggi (Outdoor)", "Panduan Suara / Narasi Cepat"
  - [x] Toggle **tanpa fungsi**, hanya visual (boleh pakai `Switch` dengan `value` tetap dan `onChanged` yang memanggil `_showComingSoon(...)`)
  - [x] Setiap tap → snackbar "fitur masih dikembangkan"

### 2.4 — Pengaturan & Keamanan (pajangan)

- [x] Widget `SecuritySection`
  - [x] Menu: "Radius Pantau Siaga", "Peringatan Dini Bencana", "Keamanan & Kata Sandi"
  - [x] Tap → snackbar "fitur masih dikembangkan", tidak navigasi

### 2.5 — Informasi & Pusat Bantuan

- [x] Widget `HelpSection`
  - [x] "Buku Panduan Tanggap Bencana BNPB" → `launchUrl(Uri.parse('https://www.bnpb.go.id/storage/app/media/Buku%20BNPB/Buku%20Saku%20Bencana%20BNPB.pdf'), mode: LaunchMode.externalApplication)`
  - [x] "Call Center Siaga Darurat 112" → panggil dialog 112 yang sama dengan home (bukan `tel:` langsung)
  - [x] Item lain (kebijakan privasi/versi) bila ada → snackbar "masih dikembangkan"

### 2.6 — Tombol Keluar & Footer

- [x] Widget `LogoutButton` — 56dp, teks "Keluar dari Akun", warna `statusVerified`
  - [x] Tap → tampilkan `LogoutConfirmationSheet` (bukan langsung logout)
  - [x] Teks footer "Seluruh data laporan & riwayat bencana Anda tersimpan aman di server BPBD."

---

## Fase 3: Bottom Sheet Konfirmasi Logout

- [x] Buat `lib/features/profile/widgets/logout_confirmation_sheet.dart`
  - [x] Drag handle + rounded top 24dp, scrim gelap di belakang (`showModalBottomSheet`)
  - [x] Badge "Autentikasi Akun" + ikon logout + tombol close 44×44dp
  - [x] Judul "Konfirmasi Keluar Akun" + pertanyaan keluar dari akun SiagaKita
  - [x] Kotak biru "Data Anda Tetap Aman"
  - [x] Kotak kuning "Peringatan Kewaspadaan" — tidak akan menerima sirene peringatan dini saat logout
  - [x] Tombol merah "Ya, Keluar dari Akun" ≥54dp → `ref.read(authNotifierProvider.notifier).logout()` lalu `context.go(AppRoutes.login)`
  - [x] Tombol abu "Batal, Tetap Masuk" ≥54dp → `Navigator.of(context).pop()`
  - [x] Teks bantuan darurat di footer sheet

---

## Fase 4: Routing

- [x] Di `app_router.dart`, ganti `_PlaceholderTabScreen(title: 'Profil Warga')` dengan `const ProfileScreen()` pada branch profile
- [x] Pastikan tab Profil aktif = index 3 di `PantauraBottomNav`
- [x] Setelah logout, `context.go(AppRoutes.login)` keluar dari shell (bukan `push`)

---

## Fase 5: Validasi & Quality

- [x] Cek ulang kedua design lokal sebelum MCP Stitch (MCP hanya jika diperintahkan)
- [x] `flutter analyze` → 0 error pada file baru & `pubspec.yaml` baru
- [x] Semua opsi aksesibilitas & keamanan memunculkan snackbar, tidak mengubah data
- [x] Buku panduan membuka PDF BNPB di browser eksternal
- [x] Call 112 memunculkan dialog yang sama persis dengan home
- [x] Konfirmasi logout: batal tidak logout; ya logout + kembali ke login
- [x] Touch target ≥ 48dp (CTA logout ≥54/56dp), tidak ada overflow
- [x] Tidak ada bang operator (`!`) di kode baru; widget class terpisah; `const` digunakan

---

## Checklist Progress Ringkas

| Fase | Status |
|------|--------|
| 0 — Persiapan & desain lokal | ✅ Selesai |
| 1 — State & dependency | ✅ Selesai |
| 2 — Screen & widgets | ✅ Selesai |
| 3 — Sheet konfirmasi logout | ✅ Selesai |
| 4 — Routing | ✅ Selesai |
| 5 — Validasi & quality | ✅ Selesai (`flutter analyze` bersih pada file fitur) |

---

## Catatan Implementasi

- Dialog 112 sebenarnya didefinisikan di `home_screen.dart` (`_showEmergency112Dialog`), bukan di `home_emergency_banner.dart` (file itu hanya callback). Ekstrak ke `core/widgets/emergency_112_dialog.dart` agar bisa dipakai dua tempat.
- `url_launcher` belum ada di `pubspec.yaml` — tambahkan sebelum implementasi tautan PDF.
- Semua menu "pajangan" tetap terlihat aktif secara visual tetapi tidak menyimpan preferensi; snackbar harus jelas menyatakan fitur masih dikembangkan.
- Logout memakai `authNotifierProvider.notifier.logout()`, lalu navigasi ke `AppRoutes.login` dengan `go` agar sesi lama tidak bisa di-back.
- `ref.listen` yang dipakai harus berada di dalam `build()` (Riverpod 3).

---

## Catatan Implementasi Aktual

- File dibuat: `lib/features/profile/profile_screen.dart` dan `widgets/{profile_header,profile_identity_card,accessibility_section,security_section,help_section,logout_button,logout_confirmation_sheet}.dart`.
- `url_launcher: ^6.3.3` sudah terpasang di `pubspec.yaml`/lock (tidak perlu ditambah).
- Dialog 112 sudah diekstrak sebelumnya ke `lib/core/widgets/emergency_112_dialog.dart`; profil memakai helper yang sama dengan home & buat laporan.
- `app_router.dart`: branch `/profile` → `const ProfileScreen()`. `_PlaceholderTabScreen` dan `_PlaceholderDetailScreen` sengaja dipertahankan (warning `unused_element`, bukan error).
- Profil mengambil `AuthAuthenticated.user` dari `authNotifierProvider`; nama/email/role punya fallback bila kosong.
- Semua toggle aksesibilitas & menu keamanan bersifat pajangan — `Switch(value: false)` dan snackbar "$label masih dikembangkan".
- Buku panduan BNPB dibuka dengan `launchUrl(..., LaunchMode.externalApplication)`.
- Logout: sheet konfirmasi → `authNotifier.logout()` → `context.go(AppRoutes.login)`.
- `flutter analyze lib/features/profile lib/core/routing/app_router.dart` → 0 error; hanya warning placeholder routing lama.
