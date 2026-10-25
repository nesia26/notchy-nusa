# Notchy – Nusa Animation Edition 🏝️✨

> **Notchy modded with living notch mascot animation inspired by Nusa!**  
> Dynamic island / notch macOS dengan animasi mata maskot interaktif, real-time cuaca, dan custom animated pet.

---

## 📸 Preview & Screenshots

<div align="center">

### 1. Notch Pill (Compact Mode) dengan Maskot & Cuaca
<img src="assets/preview_0.png" width="750" alt="Notch Pill Compact" />

*Menampilkan album art musik, cuaca live (30°), visualizer audio, dan mata maskot cyan `^^` yang tersenyum.*

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

- 🤖 **Living Mascot Eyes (Nusa Style):**
  - **Blinking:** Berkedip acak secara natural.
  - **Glancing & Look Around:** Melirik ke kiri / kanan mengikuti aktivitas kursor.
  - **Happy Smile (`^^`):** Bereaksi ceria saat hover atau saat musik diputar.
  - **Sleeping Mode:** Maskot tertidur jika notch idle beberapa menit lengkap dengan animasi zzz.
  - **Neon Glow:** Efek visual cyan / blue glow modern khas Nusa notch.
- 🌤️ **Real-Time Weather Overlay:**
  - Menampilkan suhu (misal: `30°`) dan ikon cuaca (awan, hujan, cerah) langsung di samping notch.
- 🐾 **Custom Animated Pets:**
  - 130+ sprite WebP custom untuk karakter/pet di Notchy.
- ⚡ **Zero Bloat & Native Performance:**
  - Berjalan langsung di atas AppKit & SwiftUI tanpa Electron, ringan dan hemat baterai.

---

## 📥 Download & Instalasi (Quick Start)

### Opsi 1: Download Pre-built App (Rekomendasi)
1. Download file zip aplikasi siap pakai dari halaman [**Releases**](https://github.com/nesia26/notchy-nusa/releases).
2. Ekstrak `Notchy-Nusa-macOS.zip` lalu pindahkan `Notchy.app` ke folder `/Applications/`.
3. Buka **Terminal** dan jalankan perintah berikut untuk menghapus proteksi Gatekeeper:
   ```bash
   xattr -cr /Applications/Notchy.app
   ```
4. Buka **Notchy** dari Applications / Spotlight dan nikmati animasi Nusa di notch Mac kamu! 🎉

---

### Opsi 2: Patch Notchy Sendiri (Manual Patching)
Jika kamu sudah memiliki instalasi resmi `Notchy.app`:
1. Clone repo ini:
   ```bash
   git clone https://github.com/nesia26/notchy-nusa.git
   cd notchy-nusa
   ```
2. Jalankan script patcher:
   ```bash
   chmod +x scripts/patch_notchy.sh
   ./scripts/patch_notchy.sh /Applications/Notchy.app
   ```

---

## 🛠️ Bagaimana Mod Ini Bekerja (Architecture)

1. **`NusaNotch.dylib`:** Shared library native SwiftUI/AppKit yang berisi logic overlay living notch, masking eye animations (`HappyArcShape`, `SleepingEyeShape`, `MascotEyeView`), dan `WeatherManager`.
2. **Mach-O Injection:** Binary `Notchy` di-patch dengan load command `@rpath/NusaNotch.dylib`. Saat Notchy dijalankan, dyld otomatis me-load dylib ini.
3. **Window Attachment:** Dylib otomatis menemukan window notch (`NotchWindow`) dan memasang `ClickThroughHostingView` dengan transparan click-through overlay.

---

## 👨‍💻 Credits & Attribution

- **Original App:** [Notchy](https://notchy.dev/) by [Vishva Variya](https://github.com/vishvavariya)
- **Living Notch Concept & Inspiration:** [Nusa](https://rama2555.github.io/nusa) by [Rama (rama2555)](https://github.com/rama2555)
- **Mod & Rebuild:** [Iqbal (@nesia26)](https://github.com/nesia26)
