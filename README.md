<p align="center">
  <img src="assets/images/ege_logo.svg" width="90" alt="logo" />
</p>

<h1 align="center">Yoklama</h1>

<p align="center">
QR kodlu üniversite yoklama sisteminin <b>mobil istemcisi</b> (Flutter) — öğrenci ve hoca tarafı tek uygulamada.
</p>

<p align="center">
  <a href="https://github.com/anileyilmaz/yoklama-app/actions/workflows/test.yml">
    <img src="https://github.com/anileyilmaz/yoklama-app/actions/workflows/test.yml/badge.svg" alt="Test durumu" />
  </a>
</p>

---

## Bu proje ne yapıyor?

Hoca dersin başında ekranda bir QR kod gösterir, öğrenci telefonuyla bu kodu okutur —
yoklama bu kadar basit. Arka planda:

1. Öğrenci QR'ı okutur, uygulama okunan token'ı (ve varsa GPS konumunu) backend'e gönderir.
2. Backend HMAC imzalı token'ı ve (varsa) sınıfa olan mesafeyi doğrular.
3. Öğrenci derse zaten kayıtlıysa yoklama **anında** işlenir.
4. Değilse istek hocaya düşer; hoca onaylar/reddeder, sonuç öğrenciye **socket.io** üzerinden
   anlık olarak ulaşır — sayfa yenilemeye gerek yoktur.

Backend/hoca-admin web paneli ayrı bir repoda: **[yoklama-sistemi](https://github.com/anileyilmaz/yoklama-sistemi)**.
Bu uygulama yalnızca o backend'in mobil API'sini ve socket.io sunucusunu tüketir, kendi sunucu kodu içermez.

## Özellikler

**Öğrenci tarafı**
- Kayıt / giriş, "beni hatırla" seçeneği
- QR okutarak yoklama verme (kamera + opsiyonel GPS mesafe kontrolü)
- Derse kayıtlı değilse hoca onayı bekleyen istek akışı, sonucun anlık bildirimi
- Devam durumu / devamsızlık riski, ders bazlı geçmiş
- Şifre değiştirme, açık/koyu tema

**Hoca tarafı**
- Ders listesi, oturum (QR) başlatma ve bitirme
- Canlı katılım listesi, kayıt onay istekleri
- Geçmiş oturumlar ve devamsızlık raporu

**Ortak**
- Tek giriş ekranı: kullanıcı adının yanındaki domain seçimi (`ogrenci.ege.edu.tr` /
  `ege.edu.tr`) öğrenci mi hoca mı olduğunu belirler — bkz. aşağıdaki not.

> **Not:** Giriş ekranının görünümü Ege Üniversitesi'nin SSO ekranından (kullanıcı adı +
> domain seçici + şifre) esinlenilmiştir; bu **gerçek bir SSO/federasyon entegrasyonu
> değildir**. Kimlik doğrulama tamamen bu projenin kendi backend'inde yapılır.

## Teknolojiler

Flutter / Dart · `mobile_scanner` (QR okuma) · `qr_flutter` (QR üretme) ·
`socket_io_client` (canlı bildirimler) · `geolocator` · `flutter_secure_storage` ·
`shared_preferences` · `google_fonts`

Mimari: `lib/screens` (UI) → `lib/services` (HTTP/socket istemcileri) → `lib/models`
(veri sınıfları), `lib/widgets` altında paylaşılan bileşenler. Harici bir state
management kütüphanesi kullanılmıyor.

## Kurulum

```bash
flutter pub get
flutter run
```

Uygulamanın backend'e bağlanabilmesi için `lib/services/api_config.dart` içindeki
`ApiConfig.baseUrl`'in çalışan `yoklama-sistemi` sunucusunun adresini göstermesi
gerekir (varsayılan olarak geliştirme makinesinin LAN IP'sine göre elle ayarlanır).

Web build üzerinden kamera (QR okuma) testi için telefon tarayıcısının HTTPS/secure
context istemesi nedeniyle backend reposundaki sertifikalarla `node serve_https.js`
kullanılması gerekir.

## Test

```bash
flutter analyze
flutter test
```

Push/PR'da GitHub Actions ile otomatik çalışır (`.github/workflows/test.yml`).
