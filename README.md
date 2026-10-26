# Notchy – Nusa Animation Edition 🏝️✨

> **Notchy modded with living notch mascot animation inspired by Nusa & Live Animated Weather!**  
> Dynamic Island / Notch macOS dengan animasi mata maskot interaktif, animasi cuaca hidup (matahari berputar, rintik hujan, petir, angin, mendung), dan proteksi anti-update permanen.

---

## 📸 Preview & Screenshots

<div align="center">

### 1. Notch Pill (Compact Mode) dengan Maskot & Cuaca Hidup
<img src="assets/preview_0.png" width="750" alt="Notch Pill Compact" />

*Menampilkan album art musik, cuaca real-time dengan animasi (28°), visualizer audio, dan mata maskot cyan `^^` yang tersenyum.*

<br/>

### 2. Expanded Notch saat Hover / Playback
<img src="assets/preview_1.png" width="750" alt="Expanded Notch Happy" />

*Mata maskot Nusa merespon hover & playback musik.*

<br/>

### 3. Normal Eye State
<img src="assets/preview_2.png" width="750" alt="Normal Eye State" />

*Mata maskot `··` berkedip secara natural, melihat ke arah kursor, dan tertidur saat idle.*

</div>

---

## 🎥 Video Demo

Cuplikan rekaman layar demo tersimpan di [`assets/demo.mov`](assets/demo.mov).  
Kamu dapat melihat langsung animasi live di folder ini atau mendownloadnya dari repository.

---

## ✨ Fitur Utama (Features)

### 🌤️ 1. Animated Weather di Dynamic Island (Ukuran Kecil)
- ☀️ **Cerah (Sunny):** Inti matahari kuning-oranye dengan berkas sinar matahari (*sun rays*) yang berputar halus secara kontinu 360°.
- 🌧️ **Hujan (Rain / Drizzle):** Awan lembut dengan titik rintik-rintik hujan (*staggered falling raindrops*) berjatuhan ke bawah. Jika berangin, sudut rintik hujan miring dinamis.
- ⚡ **Petir (Thunderstorm):** Awan badai gelap dengan sambaran petir listrik (*electric yellow lightning bolt*) yang berkedip dan menyambar secara periodik.
- 💨 **Angin (Wind / Breeze):** Tiga garis hembusan angin dinamis yang melintas perlahan dari kiri ke kanan.
- ☁️ **Mendung (Overcast / Cloudy):** Lapisan ganda awan mendung yang mengapung dan bergeser perlahan secara horizontal dan vertikal.
- 🌙 **Malam Cerah (Clear Night):** Bulan sabit bercahaya lembut dengan bintang-bintang kecil yang berkelap-kelip (*twinkling stars*).
- 🌡️ **Suhu Akurat & Real-Time:** Tersinkronisasi langsung dengan aplikasi Cuaca resmi macOS (Apple Weather database & Accessibility UI) tanpa ketergantungan IP yang salah.

### 🤖 2. Living Mascot Eyes (Nusa Style)
- **Blinking:** Berkedip acak secara natural.
- **Glancing & Look Around:** Melirik ke kiri / kanan mengikuti aktivitas kursor.
- **Happy Smile (`^^`):** Bereaksi ceria saat hover atau saat musik diputar.
- **Sleeping Mode:** Maskot tertidur jika notch idle beberapa menit lengkap dengan partikel animasi huruf "z".
- **Neon Glow:** Efek visual cyan / blue glow modern khas Nusa notch.

### 🛡️ 3. Permanent Anti-Update & Lifetime Mod
- **Sparkle Auto-Update Dinonaktifkan:** `SUEnableAutomaticChecks` & `SUAutomaticallyUpdate` dikunci ke `false`.
- **Bypass Forced Update Gate:** Versi internal dinaikkan ke build `999999` sehingga tidak akan pernah diblokir oleh kebijakan update server.
- **Neutralized Endpoints:** Endpoint update GitHub dinetralkan ke `127.0.0.1:0` pada binary.
- **Aman Dipasang di Mac Lain:** Modifikasi ini tidak akan pernah terhapus atau meminta pembaruan saat dipasang di Mac mana pun.

### 🐾 4. Custom Animated Pets & Performance
- 130+ sprite WebP custom untuk karakter/pet di Notchy.
- **Zero CPU Overhead:** Render vektor murni SwiftUI dengan akselerasi GPU macOS (*WindowServer*), hemat baterai.

---

## 📥 Download & Cara Pasang (Installation)

### 💻 Cara Pasang di Mac Baru / Mac Lain (1-Click Script):
Jika kamu ingin memasang Notchy Nusa Edition di Mac lain atau fresh install:

```bash
# 1. Clone repository
git clone https://github.com/nesia26/notchy-nusa.git
cd notchy-nusa

# 2. Beri izin eksekusi script
chmod +x scripts/install.sh scripts/patch_notchy.sh

# 3. Jalankan installer otomatis
./scripts/install.sh
```

Script installer otomatis akan:
1. Memeriksa file `Notchy.app` dan menyalinnya ke `/Applications/Notchy.app`.
2. Menerapkan konfigurasi anti-update permanen ke `UserDefaults` macOS.
3. Menghapus karantina Gatekeeper (`xattr -cr`).
4. Melakukan *ad-hoc codesign* ulang agar aplikasi diizinkan berjalan di macOS modern.
5. Membuka Notchy secara langsung.

---

### 🔧 Opsi: Patch Notchy Resmi Sendiri
Jika kamu sudah memiliki instalasi resmi `Notchy.app`:
```bash
./scripts/patch_notchy.sh /Applications/Notchy.app
```

---

### 🔄 Reset Izin macOS (Jika Diperlukan)
Jika setelah pemasangan kamu ingin mereset ulang seluruh izin privasi (Aksesibilitas, Lokasi, Layar, dll):
```bash
tccutil reset All dev.notchy.app
```

---

### 📱 iPadOS Edition (.ipa):
1. Download file `.ipa` dari halaman [**Releases**](https://github.com/nesia26/notchy-nusa/releases):
   - `Notchy_iPad.ipa`
2. Install ke iPad menggunakan salah satu installer:
   - **TrollStore:** Langsung install tanpa revoke (Recommended).
   - **Sideloadly / AltStore / Scarlet:** Drag `Notchy_iPad.ipa` dan install.

---

## 🛠️ Arsitektur & Cara Kerja (Architecture)

```
Notchy.app
├── Contents/MacOS/Notchy        <- Patched Mach-O (LC_LOAD_DYLIB @rpath/NusaNotch.dylib)
├── Contents/Frameworks/
│   ├── NusaNotch.dylib         <- Universal Shared Library (x86_64 + arm64)
│   └── Sparkle.framework       <- Disabled update framework
└── Contents/Info.plist          <- Build 999999, SUFeedURL = 127.0.0.1:0
```

1. **`NusaNotch.dylib`:** Shared library native SwiftUI/AppKit yang berisi logic overlay living notch, masking eye animations (`HappyArcShape`, `SleepingEyeShape`, `MascotEyeView`), `AnimatedWeatherIconView`, serta `WeatherManager`.
2. **Mach-O Injection:** Binary `Notchy` di-patch dengan load command `@rpath/NusaNotch.dylib`. Saat Notchy dijalankan, dyld otomatis me-load dylib ini.
3. **Window Attachment:** Dylib otomatis menemukan window notch (`NotchWindow`) dan memasang `ClickThroughHostingView` dengan transparan click-through overlay di posisi compact notch.

---

## 🔨 Kompilasi Ulang dylib dari Source (Opsional)
Jika kamu ingin mengubah kode SwiftUI di `src/NusaNotch.swift`:
```bash
chmod +x scripts/build_dylib.sh
./scripts/build_dylib.sh
```

---

## 👨‍💻 Credits & Attribution

- **Original App:** [Notchy](https://notchy.dev/) by [Vishva Variya](https://github.com/vishvavariya)
- **Living Notch Concept & Inspiration:** [Nusa](https://rama2555.github.io/nusa) by [Rama (rama2555)](https://github.com/rama2555)
- **Mod, Weather Animation & Anti-Update:** [Iqbal (@nesia26)](https://github.com/nesia26)
