# Pantaura REST API Documentation

Dokumentasi resmi REST API v1 untuk platform pelaporan dan pemantauan kejadian bencana **Pantaura**.

- **Base URL (Production)**: `https://pantaura.mizaru.my.id/api/v1`
- **Base URL (Local Docker)**: `http://localhost:8080/api/v1`
- **Format Data**: JSON (`application/json`) dan Multipart Form (`multipart/form-data` untuk upload media)
- **Autentikasi**: Laravel Sanctum Personal Access Token via header:
  ```http
  Authorization: Bearer <token>
  ```
- **Tipe Bencana yang Didukung**:
  - `flood` (Banjir)
  - `earthquake` (Gempa Bumi)
  - `landslide` (Tanah Longsor)
  - `fire` (Kebakaran)
- **Status Insiden**:
  - `unverified` (Belum terverifikasi)
  - `verified` (Terverifikasi)
  - `resolution_submitted` (Pengajuan resolusi)
  - `resolved` (Selesai/Tertangani)
  - `rejected` (Ditolak - disembunyikan dari publik)

---

## Daftar Endpoint API

### 1. Autentikasi (`Auth`)

| Method | Endpoint | Akses | Deskripsi |
| :--- | :--- | :--- | :--- |
| `POST` | `/auth/register` | Publik | Registrasi akun warga baru |
| `POST` | `/auth/login` | Publik | Login pengguna |
| `POST` | `/auth/logout` | `Bearer` | Logout dan menghapus token aktif |
| `GET` | `/auth/me` | `Bearer` | Mengambil profil pengguna saat ini |

#### Request & Response Contoh:
* **POST `/auth/register`**:
  * **Content-Type**: `application/json`
  * **Body**:
    ```json
    {
      "name": "Budi Santoso",
      "email": "budi@example.com",
      "password": "password123", // minimal 12 karakter dengan setidaknya 1 huruf kapital, 1 huruf kecil, dan 1 karakter khusus
      "password_confirmation": "password123", // harus sama dengan password
      "device_name": "Redmi Note 10" // opsional
    }
    ```
  * **Response 201**: Schema `AuthResponse`

* **POST `/auth/login`**:
  * **Content-Type**: `application/json`
  * **Body**:
    ```json
    {
      "email": "budi@example.com",
      "password": "password123",
      "device_name": "Flutter App" // opsional
    }
    ```
  * **Response 200**: Schema `AuthResponse`

* **GET `/auth/me`**:
  * **Response 200**: Schema `User` (dalam wrapper `{"data": ...}`)

---

### 2. Insiden Bencana (`Incidents`)

| Method | Endpoint | Akses | Parameter Query / Path | Deskripsi |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/incidents` | Publik | `status`, `type`, `page` | Daftar insiden bencana publik (terpaginasi) |
| `GET` | `/incidents/map` | Publik | `status`, `type` | Daftar marker insiden untuk peta |
| `GET` | `/incidents/{incident}` | Publik | `incident` (UUID) | Detail lengkap insiden bencana |
| `GET` | `/incidents/nearby` | Publik | `lat*`, `lng*`, `type`, `radius` | Deteksi insiden terdekat (auto-suggest duplikat) |
| `POST` | `/incidents/{incident}/confirm` | `Bearer` | `incident` (UUID) | Toggle konfirmasi warga (Crowd-Confirmation) |

#### Catatan:
* **GET `/incidents`**:
  * Filter `type`: `flood`, `earthquake`, `landslide`, `fire`.
  * Filter `status`: `unverified`, `verified`, `resolution_submitted`, `resolved`.
* **GET `/incidents/nearby`**:
  * Parameter wajib: `lat` (latitude) dan `lng` (longitude).
  * Opsional: `type`, `radius` (dalam meter).

---

### 3. Laporan Bencana (`Reports`)

| Method | Endpoint | Akses | Parameter / Body | Deskripsi |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/reports` | `Bearer` | `multipart/form-data` | Kirim laporan bencana baru |
| `GET` | `/reports/my` | `Bearer` | `page` | Riwayat laporan milik pengguna saat ini |
| `POST` | `/incidents/{incident}/reports` | `Bearer` | `multipart/form-data` | Tambah laporan pada insiden yang sudah ada |

#### Request Payload:
* **POST `/reports`**:
  * `disaster_type` (string, required untuk insiden baru): `flood` | `earthquake` | `landslide` | `fire`
  * `latitude` (float, required): -90 s/d 90
  * `longitude` (float, required): -180 s/d 180
  * `description` (string, required)
  * `address` (string, optional)
  * `media[]` (file array, required): File foto/video pendukung (jpeg, png, jpg, mp4)

---

### 4. Resolusi Insiden (`Resolutions`)

| Method | Endpoint | Akses | Parameter / Body | Deskripsi |
| :--- | :--- | :--- | :--- | :--- |
| `POST` | `/incidents/{incident}/resolutions` | `Bearer` | `multipart/form-data` | Ajukan bukti penyelesaian (resolusi) insiden |

#### Request Payload:
* **POST `/incidents/{incident}/resolutions`**:
  * `description` (string, required): Keterangan penanganan/penyelesaian bencana.
  * `media[]` (file array, required): Bukti foto/video bahwa bencana sudah tertangani.

---

### 5. Titik Aman & Posko (`SafeZones`)

| Method | Endpoint | Akses | Deskripsi |
| :--- | :--- | :--- | :--- |
| `GET` | `/safe-zones` | Publik | Mengambil daftar titik evakuasi, posko siaga, pos kesehatan, dan dapur umum aktif. |

---

### 6. Area Pantauan & Notifikasi (`WatchAreas`)

| Method | Endpoint | Akses | Parameter / Body | Deskripsi |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/watch-areas` | `Bearer` | - | Daftar area pantauan pribadi (maks 5 lokasi) |
| `POST` | `/watch-areas` | `Bearer` | `application/json` | Simpan area pantauan baru (geofence) |
| `DELETE` | `/watch-areas/{watchArea}` | `Bearer` | `watchArea` (UUID) | Hapus area pantauan pribadi |
| `GET` | `/alerts` | `Bearer` | - | Daftar notifikasi bencana terverifikasi di area pantauan |
| `POST` | `/alerts/{alert}/read` | `Bearer` | `alert` (UUID) | Tandai notifikasi alert sudah dibaca |

#### Request Payload:
* **POST `/watch-areas`**:
  ```json
  {
    "label": "Rumah Orang Tua",
    "latitude": -6.208763,
    "longitude": 106.845599,
    "radius_meters": 2000 // default/opsional
  }
  ```

---

## Semua Schema Data (Components Schemas)

Berikut adalah seluruh skema objek model yang tertera pada Swagger / OpenAPI Pantaura:

### 1. `User`
Representasi data akun pengguna.
* **Tipe**: `object`
* **Required**: `id`, `name`, `email`, `role`
* **Properti**:
  | Kolom | Tipe | Format / Enum | Keterangan / Contoh |
  | :--- | :--- | :--- | :--- |
  | `id` | `string` | `uuid` | ID unik pengguna |
  | `name` | `string` | - | `"Budi Santoso"` |
  | `email` | `string` | `email` | `"budi@example.com"` |
  | `role` | `string` | `citizen`, `admin` | Peran pengguna (default: `"citizen"`) |

---

### 2. `AuthResponse`
Struktur kembalian saat registrasi atau login berhasil.
* **Tipe**: `object`
* **Required**: `token`, `token_type`, `user`
* **Properti**:
  | Kolom | Tipe | Contoh |
  | :--- | :--- | :--- |
  | `token` | `string` | `"1\|abcdef1234567890abcdef..."` |
  | `token_type` | `string` | `"Bearer"` |
  | `user` | `User` | Schema `User` |

---

### 3. `Media`
Metadata berkas media (foto/video) lampiran laporan atau resolusi.
* **Tipe**: `object`
* **Required**: `id`, `url`, `file_type`, `original_filename`, `file_size`, `created_at`
* **Properti**:
  | Kolom | Tipe | Format / Enum | Keterangan / Contoh |
  | :--- | :--- | :--- | :--- |
  | `id` | `string` | `uuid` | ID file |
  | `url` | `string` | `uri` | URL akses file publik |
  | `file_type` | `string` | `image`, `video` | Jenis file |
  | `original_filename` | `string` | - | `"banjir-depan-rumah.jpg"` |
  | `file_size` | `integer` | - | Ukuran dalam bytes (contoh: `245760`) |
  | `created_at` | `string` (nullable) | `date-time` | Waktu upload |

---

### 4. `Report`
Model laporan kejadian bencana individual.
* **Tipe**: `object`
* **Required**: `id`, `incident_id`, `description`, `latitude`, `longitude`, `submitted_at`, `moderation_status`
* **Properti**:
  | Kolom | Tipe | Format / Enum | Keterangan |
  | :--- | :--- | :--- | :--- |
  | `id` | `string` | `uuid` | ID laporan |
  | `incident_id` | `string` | `uuid` | ID insiden yang berelasi |
  | `description` | `string` | - | Deskripsi kejadian dari pelapor |
  | `latitude` | `number` | `float` | Koordinat lintang |
  | `longitude` | `number` | `float` | Koordinat bujur |
  | `submitted_at` | `string` (nullable) | `date-time` | Waktu submit |
  | `moderation_status` | `string` | `pending`, `verified`, `rejected` | Status moderasi laporan |
  | `rejection_reason` | `string` (nullable) | - | Alasan jika ditolak |
  | `reporter` | `User` (optional) | - | Relasi ke schema `User` |
  | `media` | `array[Media]` | - | Daftar lampiran foto/video |
  | `incident` | `IncidentSummary` (optional) | - | Relasi ke schema `IncidentSummary` |

---

### 5. `ResolutionSubmission`
Bukti penanganan atau penyelesaian bencana yang diajukan warga/relawan.
* **Tipe**: `object`
* **Required**: `id`, `incident_id`, `description`, `status`, `created_at`
* **Properti**:
  | Kolom | Tipe | Format / Enum | Keterangan |
  | :--- | :--- | :--- | :--- |
  | `id` | `string` | `uuid` | ID resolusi |
  | `incident_id` | `string` | `uuid` | ID insiden |
  | `description` | `string` | - | Keterangan penanganan |
  | `status` | `string` | `pending`, `approved`, `rejected` | Status verifikasi resolusi |
  | `rejection_reason` | `string` (nullable) | - | Alasan jika pengajuan ditolak |
  | `reviewed_at` | `string` (nullable) | `date-time` | Waktu peninjauan admin |
  | `created_at` | `string` (nullable) | `date-time` | Waktu dibuat |
  | `submitter` | `User` (optional) | - | Pengguna yang mengajukan |
  | `media` | `array[Media]` | - | Foto/video bukti pemulihan |

---

### 6. `IncidentStatusHistory`
Catatan riwayat pergantian status pada suatu insiden.
* **Tipe**: `object`
* **Required**: `id`, `new_status`, `created_at`
* **Properti**:
  | Kolom | Tipe | Enum | Keterangan |
  | :--- | :--- | :--- | :--- |
  | `id` | `string` | `uuid` | ID riwayat |
  | `previous_status` | `string` (nullable) | `unverified`, `verified`, `resolution_submitted`, `resolved`, `rejected` | Status sebelumnya |
  | `new_status` | `string` | `unverified`, `verified`, `resolution_submitted`, `resolved`, `rejected` | Status baru |
  | `reason` | `string` (nullable) | - | Alasan perubahan |
  | `changed_by` | `User` (optional) | - | Admin yang mengubah status |
  | `created_at` | `string` (nullable) | `date-time` | Waktu perubahan |

---

### 7. `IncidentSummary`
Data ringkas insiden bencana untuk listing dan feed.
* **Tipe**: `object`
* **Required**: `id`, `title`, `disaster_type`, `disaster_type_label`, `description`, `latitude`, `longitude`, `status`, `status_label`, `created_at`
* **Properti**:
  | Kolom | Tipe | Format / Enum | Keterangan |
  | :--- | :--- | :--- | :--- |
  | `id` | `string` | `uuid` | ID unik insiden |
  | `title` | `string` | - | Judul insiden bencana |
  | `disaster_type` | `string` | `flood`, `earthquake`, `landslide`, `fire` | Kode tipe bencana |
  | `disaster_type_label`| `string` | - | Label bahasa Indonesia (e.g. `"Banjir"`) |
  | `description` | `string` | - | Ringkasan kondisi bencana |
  | `latitude` | `number` | `float` | Titik koordinat lintang |
  | `longitude` | `number` | `float` | Titik koordinat bujur |
  | `address` | `string` (nullable) | - | Alamat lokasi bencana |
  | `status` | `string` | `unverified`, `verified`, `resolution_submitted`, `resolved` | Kode status aktif |
  | `status_label` | `string` | - | Label status (e.g. `"Terverifikasi"`) |
  | `reports_count` | `integer` (optional) | - | Jumlah laporan yang tergabung |
  | `verified_at` | `string` (nullable) | `date-time` | Waktu terverifikasi |
  | `resolved_at` | `string` (nullable) | `date-time` | Waktu selesai ditangani |
  | `created_at` | `string` (nullable) | `date-time` | Waktu pertama dibuat |

---

### 8. `IncidentDetail`
Data detail lengkap suatu insiden.
* **Tipe**: Menggabungkan seluruh field dari `IncidentSummary` (`allOf`) ditambah properti:
  | Kolom | Tipe | Keterangan |
  | :--- | :--- | :--- |
  | `reports` | `array[Report]` | Daftar semua laporan terkait insiden ini |
  | `resolutions` | `array[ResolutionSubmission]` | Daftar pengajuan bukti resolusi |
  | `status_histories` | `array[IncidentStatusHistory]` | Riwayat perubahan status insiden |

---

### 9. `PaginationLinks`
Link navigasi pagination Laravel.
* **Tipe**: `object`
* **Properti**:
  - `first` (`string`, nullable)
  - `last` (`string`, nullable)
  - `prev` (`string`, nullable)
  - `next` (`string`, nullable)

---

### 10. `PaginationMeta`
Informasi metadata paginasi data.
* **Tipe**: `object`
* **Properti**:
  | Kolom | Tipe | Contoh |
  | :--- | :--- | :--- |
  | `current_page` | `integer` | `1` |
  | `from` | `integer` (nullable) | `1` |
  | `last_page` | `integer` | `5` |
  | `path` | `string` | `"http://.../api/v1/incidents"` |
  | `per_page` | `integer` | `15` |
  | `to` | `integer` (nullable) | `15` |
  | `total` | `integer` | `65` |

---

### 11. `MessageResponse`
Response umum untuk pesan status aksi berhasil.
* **Tipe**: `object`
* **Required**: `message`
* **Properti**:
  - `message` (`string`, contoh: `"Berhasil."`)

---

### 12. `ValidationError`
Struktur error saat validasi input form gagal (HTTP 422).
* **Tipe**: `object`
* **Required**: `message`, `errors`
* **Properti**:
  - `message` (`string`, contoh: `"The given data was invalid."`)
  - `errors` (`object`): Map field error ke array of string pesan error:
    ```json
    {
      "email": ["The email field is required."],
      "password": ["The password must be at least 8 characters."]
    }
    ```
