# UX: Mood Flicker

## User Goal
Kullanıcı, gün içindeki ruh halini 2-5 saniye içinde kaydetmek ve zamanla trendlerini görmek istiyor — sürtünme olmadan, suçluluk hissi olmadan.

## Visual Direction

### Tone & Feel
**Sakin, temiz, duygusal ama klinik olmayan, modern ve hafif.**

Uygulama, kullanıcıya "şimdi bir şey yapmalısın" baskısı yapmadan, nazikçe eşlik eden bir arkadaş gibi hissetmeli. Arayüz:
- **Nefes alan boşluklar** — elementler arası geniş, rahatlatıcı mesafe
- **Yumuşak geçişler** — ani hareketler yok, her şey akıcı
- **Duygusal ama kontrollü renkler** — pastel tonlar, aşırı doymamış
- **Minimal metin** — kullanıcıyok etmeyen, sadece yönlendiren kopya
- **Haptic feedback** — görselin ötesinde, dokunsal onay

### Reference Apps
- **Stoic.** — Sade, sakin arayüz; günlük ritüel hissi
- **Bearable** — Sağlık tracking'indeki hafiflik ve renk kullanımı
- **Headspace** — Yumuşak geçişler ve sakinleştirici görsel dil
- **Apple Health** — Native, temiz data görselleştirmesi

### Color Direction

**Primary Colors:**
- **Mutlu (😊)** — Yumuşak sarı `#F5E6A3` / `#E8D48B`
- **Nötr (😐)** — Soluk gri-yeşil `#C5D1C8` / `#A8B5AC`
- **Üzgün (😔)** — Soluk mavi-lavanta `#B8C5E8` / `#9BAAD4`
- **Öfkeli (😤)** — Yumuşak mercan `#E8B8B8` / `#D49A9A`
- **Anksiyeteli (😰)** — Soluk nane `#B8E0D8` / `#9ACDC2`

**Accent:**
- **CTA/Primary Action** — Derin deniz mavisi `#2C5F7C` (güven veren, sakin)
- **Secondary** — Yumuşak beyaz `#FAFAFA` ile cam efektli kartlar

**Semantic:**
- **Success** — Nane yeşili `#7FB8A0`
- **Error** — Yumuşak kiremit `#D4A59A`
- **Info** — Açık mavi `#A8C8E8`

**Neutral:**
- **Background** — `#F8F9FA` (açık tema), `#1C1C1E` (koyu tema)
- **Card Background** — `#FFFFFF` / `#2C2C2E` (cam efekt + blur)
- **Text Primary** — `#1A1A2E` / `#F5F5F7`
- **Text Secondary** — `#6B7280` / `#A1A1AA`
- **Border/Divider** — `#E5E7EB` / `#3A3A3C`

### Typography & Spacing

**Typography:**
- **Font:** SF Pro (system) — native, hafif, okunaklı
- **Headings:** Medium weight, 24-32pt
- **Body:** Regular weight, 16-17pt
- **Labels/Captions:** Medium weight, 13-14pt
- **Emoji:** 40-48pt (mood selector'da büyük, dokunaklı)

**Spacing:**
- **Comfortable density** — ne çok sıkışık ne çok ferah
- **Base unit:** 8pt grid
- **Card padding:** 20-24pt
- **Element spacing:** 12-16pt
- **Section spacing:** 32-40pt

---

## Primary Flows

### Flow 1: Widget'tan Hızlı Check-in
- **User Goal**: Kilit ekranından veya ana ekrandan 2 saniyede mood kaydetmek
- **Trigger**: Kullanıcı widget'a dokunur
- **Steps**:
  1. Widget'ta 5 emoji grid görünür (😊 😐 😔 😤 😰)
  2. Kullanıcı bir emoji'ye dokunur
  3. Widget genişler veya uygulama açılır (intensity + tags için)
  4. Yoğunluk slider'ı varsayılan "orta" değerde görünür
  5. İsteğe bağlı: önerilen etiketlerden seçim yapılır
  6. "Kaydet" butonuna dokunulur veya otomatik kayıt (3 saniye bekleme)
- **Edge Cases**:
  - **Widget sınırlı**: iOS widget'ta sadece emoji seçimi yapılabilir, detaylar uygulamaya yönlendirir
  - **İlk kullanım**: Widget kurulumu gerektiğinde onboarding gösterilir
  - **Offline**: Kayıt local'de tutulur, bağlantı gelince senkronize olur
- **Success State**: Check-in tamamlandı, widget'ta son kayıt zamanı gösterilir, haptic onay verilir
- **PRD Requirement References**:
  - `PR-001` — Emoji grid seçimi
  - `PR-002` — Yoğunluk slider'ı
  - `PR-003` — Opsiyonel etiketler
  - `PR-009` — Widget desteği

### Flow 2: Uygulama Açılışında Mood Kaydı
- **User Goal**: Uygulamayı açar açmaz hızlıca mood kaydetmek
- **Trigger**: Uygulama ikonuna dokunulur
- **Steps**:
  1. Splash/launch screen (yok veya minimal)
  2. Ana ekran: Emoji grid hemen görünür (no loading)
  3. Kullanıcı emoji seçer
  4. Seçilen emoji büyür, altında yoğunluk slider belirir
  5. Yoğunluk sürüklenerek ayarlanır (varsayılan: orta)
  6. Etiket önerileri görünür (mood'e göre akıllı)
  7. Etiket seçilir veya atlanır
  8. "Kaydet" butonuna dokunulur
  9. Başarı animasyonu (checkmark + haptic)
- **Edge Cases**:
  - **Zaten kayıt yapılmış**: "Bugün için kaydın var" mesajı + yeni kayıt ekleme seçeneği
  - **Boş etiket**: Etiketsiz kayıt mümkün
  - **Hızlı çıkış**: Emoji seçildikten sonra background'a atılırsa kayıt tutulmaz
- **Success State**: Kayıt tamamlandı, ana ekran trend görünümüne geçer veya aynı ekranda onay gösterilir
- **PRD Requirement References**:
  - `PR-001` — Emoji grid
  - `PR-002` — Yoğunluk slider
  - `PR-003` — Etiket ekleme
  - `PR-004` — Zaman damgası (otomatik)
  - `PR-006` — Günlük trend (sonraki görünüm)

### Flow 3: Trendler Ekranında Gezinme (Gün/Hafta/Ay)
- **User Goal**: Geçmiş mood verilerini farklı zaman dilimlerinde görüntülemek
- **Trigger**: Ana ekranda "Trendler" sekmesine veya alanına geçiş
- **Steps**:
  1. Segmented control veya tab bar: Gün / Hafta / Ay
  2. Varsayılan: Günlük görünüm (son 24 saat)
  3. Kullanıcı segment değiştirdiğinde:
     - Hafta: 7 günlük özet + ortalama mood
     - Ay: Günlük ortalama çizgi grafiği
  4. Grafiğe dokunulduğunda detay tooltip görünür
  5. Aşağı kaydırıldığında geçmiş kayıtlar listelenir
- **Edge Cases**:
  - **Veri yok**: Boş state gösterilir (illüstrasyon + "İlk kaydını yap" CTA)
  - **Tek kayıt**: Grafiğin yerine tek nokta/büyük emoji gösterilir
  - **Uzun süre kullanılmamış**: Son kayıttan sonraki boşluklar grafiğe yansıtılır
- **Success State**: Kullanıcı istediği zaman diliminde verilerini görüntüler
- **PRD Requirement References**:
  - `PR-006` — Günlük trend
  - `PR-007` — Haftalık trend
  - `PR-008` — Aylık trend

### Flow 4: Etiket Ekleme/Çıkarma
- **User Goal**: Mood kaydına bağlam eklemek veya mevcut kaydı düzenlemek
- **Trigger**: Mood kaydı akışında veya geçmiş kayda düzenleme
- **Steps**:
  1. Etiketler bölümü görünür (başlangıçta boş veya öneriler)
  2. Önerilen etiketler (mood'e göre):
     - 😔/😰 → "yorgun", "anksiyetik", "uykusuz"
     - 😊 → "enerjik", "üretken", "sosyal"
     - 😤 → "stresli", "hayal kırıklığı"
  3. Kullanıcı etikete dokunur (seçilir) veya tekrar dokunur (kaldırılır)
  4. Maksimum 3 etiket seçilebilir
  5. "Özel etiket ekle" (v1.1'de) seçeneği
- **Edge Cases**:
  - **3 etiket limiti**: 4. seçimde uyarı gösterilir ("En fazla 3 etiket")
  - **Eşleşmeyen etiket**: Kullanıcı mutlu mood'da "yorgun" seçebilir (serbest)
  - **Etiketsiz kayıt**: Tamamen opsiyonel, zorunlu değil
- **Success State**: Seçilen etiketler kayıt ile birlikte saklanır, trendlerde görünür
- **PRD Requirement References**:
  - `PR-003` — Opsiyonel etiket ekleme
  - `PR-101` — Akıllı etiket önerileri (P1)

### Flow 5: Veri Dışa Aktarım
- **User Goal**: Tüm mood verilerini sahiplenmek veya başka yerde kullanmak
- **Trigger**: Ayarlar → Veri Yönetimi → Dışa Aktar
- **Steps**:
  1. Kullanıcı "Dışa Aktar" seçeneğine dokunur
  2. Format seçimi: JSON (tam veri) veya CSV (basit analiz)
  3. Tarih aralığı seçimi (varsayılan: tümü)
  4. "Oluştur" butonu
  5. Share Sheet açılır (AirDrop, Dosyalar, Mail, vb.)
  6. Kullanıcı hedef seçer, dosya paylaşılır
- **Edge Cases**:
  - **Boş veri**: "Aktarılacak veri yok" uyarısı
  - **Büyük veri**: 1000+ kayıtta performans göstergesi (progress)
  - **İptal**: Her aşamada vazgeçilebilir
- **Success State**: Dosya başarıyla paylaşıldı, onay mesajı gösterilir
- **PRD Requirement References**:
  - `PR-105` — Veri dışa aktarım (P1)

---

## Screen/Component Breakdown

### Screen: Mood Check-in (Ana Ekran)
- **Purpose**: Kullanıcının mood kaydı yapmasını sağlamak — uygulamanın kalbi
- **Layout**:
  - Üst: Minimal header (sadece ayarlar ikonu)
  - Orta: 5'li emoji grid (2x3 veya tek sıra, büyük dokunma alanları)
  - Alt: Yoğunluk slider (seçim sonrası görünür)
  - Alt: Etiket chip'leri (yatay scroll)
  - En alt: "Kaydet" butonu (büyük, rounded)
- **Key elements**:
  - Emoji grid: 😊 😐 😔 😤 😰 (48pt boyut)
  - Intensity slider: 3 segment (düşük/orta/yüksek) veya sürekli
  - Tag chips: Rounded pill shape, seçili durumda dolgu
  - Save button: Full-width, primary color
- **Primary action**: Mood kaydetmek
- **Edge cases**:
  - **Empty state**: Henüz seçim yok, slider ve etiketler gizli
  - **Loading**: SwiftData write sırasında buton disabled + spinner
  - **Error**: Kayıt başarısızsa retry seçeneği
- **Flow References**:
  - `Flow 2: Uygulama Açılışında Mood Kaydı`
- **PRD Requirement References**:
  - `PR-001`, `PR-002`, `PR-003`, `PR-004`

### Screen: Trendler (Analytics)
- **Purpose**: Kullanıcının mood geçmişini görselleştirmek
- **Layout**:
  - Üst: Segmented control (Gün / Hafta / Ay)
  - Orta: Chart area (Swift Charts)
  - Alt: Özet kartları (ortalama mood, toplam kayıt, streak)
  - Alt: Son kayıtlar listesi (scrollable)
- **Key elements**:
  - Segmented control: iOS native, equal width
  - Charts: Bar chart (gün), Line chart (hafta/ay), renkli
  - Summary cards: Emoji + sayı + label
  - History list: Saat + emoji + yoğunluk + etiketler
- **Primary action**: Farklı zaman dilimlerini görüntülemek
- **Edge cases**:
  - **Empty state**: İlk kullanım — illüstrasyon + "İlk kaydını yap" CTA
  - **Single entry**: Grafik yerine büyük emoji + "Bugün başladın" mesajı
  - **No data for period**: "Bu dönemde kayıt yok" + önceki döneme git
- **Flow References**:
  - `Flow 3: Trendler Ekranında Gezinme`
- **PRD Requirement References**:
  - `PR-006`, `PR-007`, `PR-008`

### Screen: Ayarlar
- **Purpose**: Uygulama tercihleri ve veri yönetimi
- **Layout**:
  - Standard iOS Settings form
  - Bölümler: Tema, Bildirimler, Veri, Hakkında
- **Key elements**:
  - Tema seçimi: Sistem / Açık / Koyu
  - Widget ayarları: Hızlı emoji sayısı (3/5)
  - Dışa aktarım: JSON/CSV seçimi
  - iCloud senkronizasyon: Toggle
- **Primary action**: Tercihleri değiştirmek
- **Edge cases**:
  - **iCloud kapalı**: Bilgilendirme banner'ı
  - **Büyük veri**: Dışa aktarımda progress göster
- **Flow References**:
  - `Flow 5: Veri Dışa Aktarım`
- **PRD Requirement References**:
  - `PR-010` — iCloud senkronizasyonu
  - `PR-104` — Koyu tema (P1)
  - `PR-105` — Veri dışa aktarım (P1)

### Component: Emoji Grid
- **Purpose**: Hızlı duygu seçimi
- **Layout**: 5 emoji, eşit aralıklı, büyük dokunma alanı (min 60x60pt)
- **Interaction**:
  - Dokunulduğunda: Scale up (1.1x) + haptic (light)
  - Seçildiğinde: Scale down + background highlight + border
  - Diğerleri: Slight opacity reduce (0.6)
- **States**: Default, Selected, Disabled

### Component: Intensity Slider
- **Purpose**: Seçilen mood'un yoğunluğunu ayarlamak
- **Layout**: Horizontal bar, 3 bölümlü veya sürekli
- **Interaction**:
  - Sürükleme: Haptic feedback (selection changed)
  - Varsayılan: Orta konum
  - Değerler: 1 (hafif) / 2 (orta) / 3 (yoğun)
- **Visual**: Track (neutral), Fill (mood rengi), Thumb (circle)

### Component: Tag Chips
- **Purpose**: Hızlı etiket seçimi
- **Layout**: Horizontal scroll, pill-shaped buttons
- **Interaction**:
  - Dokunma: Toggle selection
  - Selected: Filled background, white text
  - Unselected: Border only, secondary text
  - Max 3: 4. seçimde shake animation + toast
- **Content**: "yorgun", "enerjik", "anksiyetik", "sakin", "stresli", "üretken", "sosyal", "uykusuz"

### Component: Widget (iOS 17+ Interactive)
- **Purpose**: Kilit/ana ekrandan hızlı check-in
- **Layout**: 
  - Small: Tek emoji (son kayıt veya favori)
  - Medium: 3 emoji yatay
  - Large: 5 emoji + son kayıt bilgisi
- **Interaction**:
  - Emoji dokunulduğunda: App Intent çalıştırır, uygulama açılır veya genişler
  - Background: Mood rengine göre gradient (soluk)
- **States**: Empty (ilk kullanım), Filled (son kayıt gösterir)

---

## Interaction Patterns

### Navigation
- **Tab-based**: Check-in (ana) | Trendler | Ayarlar
- **No deep navigation**: Maksimum 2 seviye (ana → detay)
- **Modal**: Dışa aktarım, onboarding (varsa)
- **Swipe gestures**: Trendler arasında swipe ile geçiş

### Feedback Mechanisms
- **Haptic**:
  - Emoji seçimi: `UIImpactFeedbackGenerator(.light)`
  - Yoğunluk değişimi: `UISelectionFeedbackGenerator()`
  - Kayıt tamamlandı: `UINotificationFeedbackGenerator(.success)`
  - Hata/Limit: `UINotificationFeedbackGenerator(.error)`
- **Visual**:
  - Emoji scale animation (0.2s, easeOut)
  - Button press state (opacity 0.8)
  - Success checkmark (scale + fade)
  - Toast messages (slide in from bottom, 3s duration)

### Loading & Transitions
- **No blocking loaders**: SwiftData işlemleri background'da
- **Skeleton screens**: Yok (veri local, hızlı)
- **Transitions**: 
  - Emoji seçimi → slider appears (fade + slide up, 0.3s)
  - Tab değişimi: Cross-fade (0.2s)
  - Kayıt başarılı: Checkmark overlay (0.5s) → auto dismiss

### Data Persistence
- **Auto-save**: Yok, kullanıcı "Kaydet"e basmalı
- **Draft**: Emoji seçildiğinde memory'de tutulur, app kill olursa kaybolur
- **Sync indicator**: Ayarlar'da son senkronizasyon zamanı

---

## Copy Direction

### Button Labels
- "Kaydet" — Primary CTA
- "Atla" — Etiketleri geç
- "Düzenle" — Mevcut kaydı değiştir
- "Paylaş" — Dışa aktarım
- "Tamam" — Onay/OK

### Empty States
- **İlk kullanım**: "Nasıl hissediyorsun?" (emoji grid üzerinde)
- **Trendler (veri yok)**: "Henüz kaydın yok. İlk adımı atmak için bir emoji seç."
- **Widget (ilk kurulum)**: "Widget'ı ana ekranına ekle, tek dokunuşla kaydet."

### Error Messages
- "Kaydedilemedi. Tekrar dene." (retry button)
- "En fazla 3 etiket seçebilirsin."
- "iCloud senkronizasyonu kapalı. Ayarlar'dan açabilirsin."

### Success Messages
- "Kaydedildi ✓" (toast)
- "Verilerin dışa aktarıldı."
- "X günlük streak!" (P1 — baskısız, sade bilgi)

### Placeholders
- Etiket arama: "Etiket ara..." (P1.1)
- Not ekleme (varsa): "Bir şeyler yaz... (opsiyonel)"

---

## Accessibility

### VoiceOver
- **Emoji grid**: "Mutlu yüz, buton, ruh halini seç" (hint: "Seçmek için çift dokun")
- **Intensity slider**: "Yoğunluk, ayarlanabilir, şu an orta" (hint: "Sürüklemek için yukarı/aşağı kaydır")
- **Tag chips**: "Yorgun etiketi, seçilmedi" / "Yorgun etiketi, seçildi"
- **Charts**: "Günlük trend grafiği, 5 kayıt, ortalama mutlu"

### Dynamic Type
- Tüm metinler `@ScaledMetric` ile desteklenmeli
- Emoji boyutu sabit kalabilir (48pt)
- Layout: Büyük metinlerde stack vertical, küçükte horizontal

### Color & Contrast
- Tüm metinler WCAG AA (4.5:1) kontrast oranına sahip olmalı
- Emoji'ler renk körlüğüne karşı güvenli (şekil farklı)
- Slider track: Kontrastlı border (light/dark mode'da)

### Reduce Motion
- `AccessibilityReduceMotion` kontrolü
- Animasyonlar disable edilir veya anında gerçekleşir
- Transition'lar fade-only olur

### Touch Targets
- Minimum 44x44pt dokunma alanı
- Emoji grid: 60x60pt önerilir
- Slider thumb: 28pt çap

---

## Summary (for downstream agents)

```yaml
feature: "Mood Flicker - Hafif Mood Tracking"
source_artifacts:
  prd: "docs/mood-flicker/prd.md"
  brainstorm: "docs/mood-flicker/brainstorm.md"
  analysis: ""
primary_flows:
  - name: "Widget'tan Hızlı Check-in"
    prd_requirements: ["PR-001", "PR-002", "PR-003", "PR-009"]
  - name: "Uygulama Açılışında Mood Kaydı"
    prd_requirements: ["PR-001", "PR-002", "PR-003", "PR-004", "PR-006"]
  - name: "Trendler Ekranında Gezinme"
    prd_requirements: ["PR-006", "PR-007", "PR-008"]
  - name: "Etiket Ekleme/Çıkarma"
    prd_requirements: ["PR-003", "PR-101"]
  - name: "Veri Dışa Aktarım"
    prd_requirements: ["PR-105"]
screens:
  - name: "Mood Check-in (Ana Ekran)"
    flows: ["Uygulama Açılışında Mood Kaydı"]
  - name: "Trendler (Analytics)"
    flows: ["Trendler Ekranında Gezinme"]
  - name: "Ayarlar"
    flows: ["Veri Dışa Aktarım"]
components:
  - name: "Emoji Grid"
    flows: ["Widget'tan Hızlı Check-in", "Uygulama Açılışında Mood Kaydı"]
  - name: "Intensity Slider"
    flows: ["Widget'tan Hızlı Check-in", "Uygulama Açılışında Mood Kaydı"]
  - name: "Tag Chips"
    flows: ["Etiket Ekleme/Çıkarma"]
  - name: "Widget"
    flows: ["Widget'tan Hızlı Check-in"]
p0_requirements_covered:
  - "PR-001" — Emoji grid
  - "PR-002" — Yoğunluk slider
  - "PR-003" — Opsiyonel etiketler
  - "PR-004" — Zaman damgası
  - "PR-006" — Günlük trend
  - "PR-007" — Haftalık trend
  - "PR-008" — Aylık trend
  - "PR-009" — Widget desteği
  # Not covered in UX flows (technical/backend):
  # "PR-005" — SwiftData persistans (implementation detail)
  # "PR-010" — iCloud senkronizasyonu (implementation detail)
p1_requirements_covered:
  - "PR-101" — Akıllı etiket önerileri
  - "PR-105" — Veri dışa aktarım
key_risks:
  - "Widget interaktivitesi iOS 17+ ile sınırlı — fallback flow gerekli"
  - "2-5 saniye hedefi için animasyonlar çok hızlı olmalı, yavaş hissettirmemeli"
  - "Emoji kültürel yorum farklılıkları — kullanıcı testi önerilir"
  - "SwiftData iCloud sync gecikmesi — UI'da 'senkronize ediliyor' durumu"
open_questions_resolved:
  - "Emoji seti: 😊 😐 😔 😤 😰 (5'li standart)"
  - "Etiket taxonomy: Sabit liste (yorgun, enerjik, anksiyetik, sakin, stresli, üretken, sosyal, uykusuz)"
  - "Widget limitasyonu: Medium size 3 emoji, Large 5 emoji, dokununca uygulama açılır"
  - "Bildirim stratejisi: PRD'de açık değil, P2'de değerlendirilecek (PR-203)"
  - "Veri silme: Ayarlar'dan tek kayıt silme (v1.1), dışa aktarıp silme (P1)"
```

---

## Handoff Contract

**Next Agent:** `user-stories`

**Required Artifacts:**
- `docs/mood-flicker/prd.md`
- `docs/mood-flicker/ux.md` (this document)

**Recommended Artifacts:**
- `docs/mood-flicker/brainstorm.md`

**Critical Inputs:**
- User goal: 2-5 saniyelik mood check-in
- Primary flows: Widget check-in, App check-in, Trends navigation, Tag management, Export
- Screen/component breakdown: Mood Check-in, Trendler, Ayarlar, Emoji Grid, Intensity Slider, Tag Chips, Widget
- Interaction patterns: Haptic feedback, smooth transitions, no blocking loaders
- Copy direction: Minimal, nazik, baskısız
- Accessibility: VoiceOver, Dynamic Type, Reduce Motion, 44pt touch targets

**Sections That Must Not Change:**
- User Goal
- Primary Flows (5 adet)
- Screen/Component Breakdown
- Interaction Patterns
- Visual Direction (sakin, temiz, duygusal ama klinik olmayan)

**Mapping Rules:**
- Every primary flow must map to at least one user story
- Every screen/component referenced by a flow must appear in at least one story
- Every P0 requirement referenced from the PRD must remain covered here
- "2-5 second check-in" constraint must be validated in every story

# ux

kind: let

source:
```prose
let ux_artifact = session: stage-runner
```
