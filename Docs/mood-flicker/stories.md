# stories

kind: let

source:
```prose
let stories_artifact = session: stage-runner
```

---

# User Stories: Mood Flicker

## Epic Summary
Hafif, hızlı ve sürtünmesiz bir mood tracking deneyimi — kullanıcılar 2-5 saniyede ruh hallerini kaydeder, zamanla trendlerini görür.

---

## Stories

### P0 MF-001: Emoji ile Mood Seçimi
**As a** kullanıcı  
**I want** uygulamayı açar açmaz emoji grid üzerinden ruh halimi seçebilmek  
**So that** kayıt işlemine anında başlayabilirim

**PRD Requirement References:** `PR-001`  
**UX Flow References:** `Uygulama Açılışında Mood Kaydı`  
**Dependencies:** None  
**Implementation Boundary:** Sadece emoji grid UI ve seçim mekanizması. SwiftData kaydı MF-002'de.

**Acceptance Criteria:**
- [ ] Given uygulama açıldığında, when ana ekran görünürse, then 5 emoji (😊 😐 😔 😤 😰) grid halinde görünür
- [ ] Given emoji grid görünürken, when bir emoji'ye dokunursam, then seçilen emoji büyür (scale 1.1x) ve visual highlight alır
- [ ] Given bir emoji seçildiğinde, when seçim yapılırsa, then haptic feedback (light) verilir
- [ ] Given emoji seçildiğinde, when diğer emoji'lere bakılırsa, then seçilmeyenler opacity 0.6 olur
- [ ] Given VoiceOver aktifken, when emoji grid'e odaklanırsam, then "Mutlu yüz, buton, ruh halini seç" duyurusu yapılır

**Notes:** Emoji boyutu 48pt, dokunma alanı minimum 60x60pt. Accessibility hint: "Seçmek için çift dokun"

---

### P0 MF-002: Yoğunluk Slider'ı
**As a** kullanıcı  
**I want** seçtiğim mood'un yoğunluğunu ayarlayabilmek  
**So that** duygunun şiddetini de kaydedebilirim

**PRD Requirement References:** `PR-002`  
**UX Flow References:** `Uygulama Açılışında Mood Kaydı`, `Widget'tan Hızlı Check-in`  
**Dependencies:** MF-001 (emoji seçimi öncelikli)  
**Implementation Boundary:** Slider UI, değer tutma, görsel feedback. SwiftData entegrasyonu MF-005'te.

**Acceptance Criteria:**
- [ ] Given emoji seçildiğinde, when seçim tamamlanırsa, then yoğunluk slider'ı fade + slide up animasyonuyla görünür
- [ ] Given slider görünürken, when varsayılan değere bakılırsa, then "orta" konumda olduğu görülür
- [ ] Given slider kullanılırken, when değer değiştirilirse, then haptic feedback (selection changed) verilir
- [ ] Given slider kullanılırken, when sürükleme yapılırsa, then track'in dolu kısmı mood rengiyle doldurulur
- [ ] Given VoiceOver aktifken, when slider'a odaklanırsam, then "Yoğunluk, ayarlanabilir, şu an orta" duyurusu yapılır

**Notes:** 3-seviyeli (düşük/orta/yüksek) veya sürekli slider. Thumb 28pt çap.

---

### P0 MF-003: Opsiyonel Etiket Ekleme
**As a** kullanıcı  
**I want** mood kaydına isteğe bağlı olarak etiketler ekleyebilmek  
**So that** kayda daha fazla bağlam katabilirim

**PRD Requirement References:** `PR-003`  
**UX Flow References:** `Uygulama Açılışında Mood Kaydı`, `Etiket Ekleme/Çıkarma`  
**Dependencies:** MF-001 (emoji seçimi)  
**Implementation Boundary:** Etiket chip UI, seçim mekanizması, maksimum 3 limiti. Akıllı öneriler MF-006'da (P1).

**Acceptance Criteria:**
- [ ] Given emoji seçildiğinde, when yoğunluk slider görünürse, then etiket chip'leri yatay scroll olarak görünür
- [ ] Given etiketler görünürken, when bir etikete dokunursam, then toggle selection yapılır (filled vs border)
- [ ] Given 3 etiket seçildiğinde, when 4. etikete dokunulmaya çalışılırsa, then shake animation + "En fazla 3 etiket seçebilirsin" toast gösterilir
- [ ] Given etiket seçilmemişken, when "Kaydet" butonuna basılırsa, then etiketsiz kayıt başarıyla tamamlanır
- [ ] Given VoiceOver aktifken, when etiket chip'e odaklanırsam, then "Yorgun etiketi, seçilmedi" veya "seçildi" duyurusu yapılır

**Notes:** Sabit etiket listesi: yorgun, enerjik, anksiyetik, sakin, stresli, üretken, sosyal, uykusuz

---

### P0 MF-004: Zaman Damgalı Kayıt
**As a** kullanıcı  
**I want** her mood kaydının otomatik olarak zaman damgası almasını istiyorum  
**So that** geçmişte ne zaman nasıl hissettiğimi görebilirim

**PRD Requirement References:** `PR-004`  
**UX Flow References:** `Uygulama Açılışında Mood Kaydı`  
**Dependencies:** None  
**Implementation Boundary:** Otomatik timestamp oluşturma. SwiftData modelinde Date alanı.

**Acceptance Criteria:**
- [ ] Given "Kaydet" butonuna basıldığında, when kayıt oluşturulursa, then otomatik olarak current timestamp (saat + tarih) kaydedilir
- [ ] Given kayıt oluşturulduğunda, when veri görüntülenirse, then saat:dakika ve tarih bilgisi doğru şekilde görünür
- [ ] Given cihaz saat dilimi değiştiğinde, when mevcut kayıtlar görüntülenirse, then kayıtlar orijinal timestamp'i korur (dönüşüm yapılmaz)

**Notes:** Timestamp UTC olarak saklanabilir, görüntüleme local timezone'da yapılır.

---

### P0 MF-005: SwiftData ile Yerel Persistans
**As a** kullanıcı  
**I want** uygulamayı kapatıp açtığımda verilerimin korunmasını istiyorum  
**So that** mood geçmişim kaybolmaz

**PRD Requirement References:** `PR-005`  
**UX Flow References:** Tüm kayıt akışları  
**Dependencies:** MF-001, MF-002, MF-003, MF-004 (kayır verisi oluştuktan sonra)  
**Implementation Boundary:** SwiftData model, CRUD operasyonları, background write.

**Acceptance Criteria:**
- [ ] Given mood kaydı yapıldığında, when "Kaydet" butonuna basılırsa, then veri SwiftData'ya background thread'de yazılır
- [ ] Given uygulama kapatılıp açıldığında, when ana ekran yüklenirse, then önceki kayıtlar görünür
- [ ] Given kayıt yazılırken, when işlem devam ederse, then UI blocking olmaz (spinner gösterilebilir)
- [ ] Given write operation başarısız olursa, when hata oluşursa, then kullanıcıya "Kaydedilemedi. Tekrar dene." mesajı + retry butonu gösterilir

**Notes:** SwiftData model: MoodEntry (id, emoji, intensity, tags[], timestamp)

---

### P0 MF-006: Günlük Trend Görünümü
**As a** kullanıcı  
**I want** son 24 saatin mood dağılımını grafikle görmek istiyorum  
**So that** gün içindeki duygu değişimlerimi anlayabilirim

**PRD Requirement References:** `PR-006`  
**UX Flow References:** `Trendler Ekranında Gezinme`  
**Dependencies:** MF-005 (veri persistansı)  
**Implementation Boundary:** Günlük chart UI, Swift Charts kullanımı, veri aggregation.

**Acceptance Criteria:**
- [ ] Given "Trendler" sekmesine geçildiğinde, when günlük görünüm seçiliyse, then son 24 saatin mood dağılımı bar chart olarak görünür
- [ ] Given chart görünürken, when bir bar'a dokunulursa, then tooltip ile o saatteki kayıt sayısı ve detayları görünür
- [ ] Given veri yokken, when günlük görünüm açılırsa, then boş state gösterilir (illüstrasyon + "Henüz kaydın yok" mesajı)
- [ ] Given VoiceOver aktifken, when chart'a odaklanırsam, then "Günlük trend grafiği, 5 kayıt, ortalama mutlu" duyurusu yapılır

**Notes:** Swift Charts (iOS 16+), bar chart renkleri mood'lara göre.

---

### P0 MF-007: Haftalık Trend Görünümü
**As a** kullanıcı  
**I want** son 7 günün mood özetini görmek istiyorum  
**So that** haftalık duygu pattern'lerimi görebilirim

**PRD Requirement References:** `PR-007`  
**UX Flow References:** `Trendler Ekranında Gezinme`  
**Dependencies:** MF-005  
**Implementation Boundary:** Haftalık chart UI, 7 günlük aggregation, ortalama hesaplama.

**Acceptance Criteria:**
- [ ] Given "Trendler" sekmesindeyken, when "Hafta" segmenti seçilirse, then son 7 günün günlük ortalama mood'u line chart olarak görünür
- [ ] Given haftalık görünüm açıkken, when özet kartları görünürse, then haftalık ortalama mood ve toplam kayıt sayısı gösterilir
- [ ] Given chart'ta bir noktaya dokunulduğunda, when o günün detayları istenirse, then tooltip ile o günün ortalaması ve kayıt sayısı görünür

**Notes:** Line chart, x-axis gün isimleri (Pzt, Sal, ...), y-axis mood skoru (1-5)

---

### P0 MF-008: Aylık Trend Görünümü
**As a** kullanıcı  
**I want** aylık mood trendlerimi görmek istiyorum  
**So that** uzun vadeli duygu pattern'lerimi anlayabilirim

**PRD Requirement References:** `PR-008`  
**UX Flow References:** `Trendler Ekranında Gezinme`  
**Dependencies:** MF-005  
**Implementation Boundary:** Aylık chart UI, günlük ortalama aggregation, scrollable timeline.

**Acceptance Criteria:**
- [ ] Given "Trendler" sekmesindeyken, when "Ay" segmenti seçilirse, then mevcut ayın günlük ortalama mood'u line chart olarak görünür
- [ ] Given aylık görünüm açıkken, when kullanıcı scroll yaparsa, then önceki aylara gidilebilir
- [ ] Given aylık chart'ta bir güne dokunulduğunda, when detay istenirse, then o günün tüm kayıtları listelenir

**Notes:** Line chart, x-axis gün numaraları (1-31), zoom/pan desteği opsiyonel

---

### P0 MF-009: Widget Desteği
**As a** kullanıcı  
**I want** ana ekran veya kilit ekranından hızlıca mood kaydı yapabilmek  
**So that** uygulamayı açmadan 2 saniyede check-in yapabilirim

**PRD Requirement References:** `PR-009`  
**UX Flow References:** `Widget'tan Hızlı Check-in`  
**Dependencies:** MF-001, MF-005  
**Implementation Boundary:** WidgetKit entegrasyonu, App Intents, widget UI (small/medium/large).

**Acceptance Criteria:**
- [ ] Given kullanıcı widget eklediğinde, when widget görünürse, then 3 veya 5 emoji yatay olarak görünür (boyuta göre)
- [ ] Given widget'ta bir emoji'ye dokunulduğunda, when App Intent çalıştırılırsa, then uygulama açılır ve seçilen emoji önceden seçili olarak gelir
- [ ] Given widget aktifken, when son kayıt zamanı varsa, then widget'ta "Son kayıt: 2 saat önce" gibi bilgi gösterilir
- [ ] Given iOS 17+ cihazda, when widget kullanılırken, then interaktivite desteklenir (dokununca uygulama açılır)

**Notes:** Small widget: 1 emoji, Medium: 3 emoji, Large: 5 emoji + son kayıt bilgisi

---

### P0 MF-010: iCloud Senkronizasyonu
**As a** kullanıcı  
**I want** aynı Apple ID ile farklı cihazlarımda verilerimin senkronize olmasını istiyorum  
**So that** iPhone'umda kaydettiğim mood'ları iPad'imde de görebilirim

**PRD Requirement References:** `PR-010`  
**UX Flow References:** Tüm akışlar  
**Dependencies:** MF-005  
**Implementation Boundary:** SwiftData CloudKit entegrasyonu, sync durum göstergesi.

**Acceptance Criteria:**
- [ ] Given iCloud aktifken, when yeni kayıt oluşturulursa, then veri otomatik olarak CloudKit'e senkronize edilir
- [ ] Given ikinci cihazda uygulama açıldığında, when senkronizasyon tamamlanırsa, then ilk cihazdaki kayıtlar görünür
- [ ] Given iCloud kapalıyken, when kullanıcı uygulamayı açarsa, then Ayarlar'da bilgilendirme banner'ı gösterilir
- [ ] Given senkronizasyon gecikirse, when kullanıcı beklerken, then "Senkronize ediliyor..." durumu gösterilir (blocking değil)

**Notes:** SwiftData'nın otomatik CloudKit sync'i kullanılacak. Minimum iOS 17.

---

### P1 MF-011: Akıllı Etiket Önerileri
**As a** kullanıcı  
**I want** seçtiğim mood'e göre ilgili etiketlerin önerilmesini istiyorum  
**So that** daha hızlı etiket seçebilirim

**PRD Requirement References:** `PR-101`  
**UX Flow References:** `Etiket Ekleme/Çıkarma`  
**Dependencies:** MF-003  
**Implementation Boundary:** Mood-etiket mapping, öneri algoritması (basit rule-based).

**Acceptance Criteria:**
- [ ] Given 😔 veya 😰 seçildiğinde, when etiketler görünürse, then "yorgun", "anksiyetik", "uykusuz" öncelikli olarak gösterilir
- [ ] Given 😊 seçildiğinde, when etiketler görünürse, then "enerjik", "üretken", "sosyal" öncelikli olarak gösterilir
- [ ] Given 😤 seçildiğinde, when etiketler görünürse, then "stresli", "hayal kırıklığı" öncelikli olarak gösterilir
- [ ] Given kullanıcı belirli etiketleri sık seçtiyse, when öneriler oluşturulursa, then kullanım pattern'ine göre kişiselleştirilmiş öneriler gösterilir (v1.1)

**Notes:** V1'de rule-based, v1.1'de kullanım pattern'i öğrenme

---

### P1 MF-012: Streak Görselleştirmesi (Baskısız)
**As a** kullanıcı  
**I want** ardışık gün sayısını nazikçe görmek istiyorum  
**So that** motivasyonum artsın ama kırılan streakler suçluluk hissettirmesin

**PRD Requirement References:** `PR-102`  
**UX Flow References:** `Trendler Ekranında Gezinme`  
**Dependencies:** MF-005  
**Implementation Boundary:** Streak hesaplama, UI gösterimi, 24h gizleme mantığı.

**Acceptance Criteria:**
- [ ] Given kullanıcı ardışık günlerde kayıt yaptığında, when trendler ekranı açılırsa, then "X günlük streak" nazikçe gösterilir
- [ ] Given streak kırıldığında, when 24 saat geçerse, then streak göstergesi gizlenir (sıfırlanmaz ama görünmez)
- [ ] Given streak kırıldığında, when kullanıcı yeni kayıt yaparsa, then streak 1'den devam eder (sıfırlama yok, sadece sayaç)
- [ ] Given streak gösterimi aktifken, when kullanıcı görürse, then "X gündür kendini takip ediyorsun" gibi pozitif mesaj görülür

**Notes:** Streak = son 24 saat içinde en az 1 kayıt. 48+ saat boşluk = streak duraklar.

---

### P1 MF-013: Haptic Feedback
**As a** kullanıcı  
**I want** dokunmatik geri bildirim almak istiyorum  
**So that** etkileşimlerim onaylanmış hissetsin

**PRD Requirement References:** `PR-103`  
**UX Flow References:** Tüm akışlar  
**Dependencies:** None  
**Implementation Boundary:** UIImpactFeedbackGenerator, UISelectionFeedbackGenerator, UINotificationFeedbackGenerator kullanımı.

**Acceptance Criteria:**
- [ ] Given emoji seçildiğinde, when dokunma gerçekleşirse, then `UIImpactFeedbackGenerator(.light)` çalışır
- [ ] Given yoğunluk değiştirildiğinde, when değer değişirse, then `UISelectionFeedbackGenerator()` çalışır
- [ ] Given kayıt tamamlandığında, when başarı durumu oluşursa, then `UINotificationFeedbackGenerator(.success)` çalışır
- [ ] Given hata veya limit aşıldığında, when uyarı durumu oluşursa, then `UINotificationFeedbackGenerator(.error)` çalışır

**Notes:** Reduce Motion ayarı aktifse haptic'ler de devre dışı bırakılabilir veya azaltılabilir.

---

### P1 MF-014: Koyu Tema Desteği
**As a** kullanıcı  
**I want** koyu temayı kullanabilmek istiyorum  
**So that** gece kullanımda rahatsız olmayayım

**PRD Requirement References:** `PR-104`  
**UX Flow References:** Tüm ekranlar  
**Dependencies:** None  
**Implementation Boundary:** Color asset'ler, dark mode palette, sistem temasına uyum.

**Acceptance Criteria:**
- [ ] Given sistem teması koyu olduğunda, when uygulama açılırsa, then otomatik olarak koyu tema uygulanır
- [ ] Given kullanıcı Ayarlar'dan tema seçtiğinde, when açık/koyu/sistem seçilirse, then seçilen tema uygulanır
- [ ] Given koyu tema aktifken, when tüm ekranlar görüntülenirse, then WCAG AA kontrast oranı sağlanır (4.5:1)
- [ ] Given koyu tema aktifken, when emoji grid görünürse, then emoji'ler aynı kalır (emoji'ler tema bağımsız)

**Notes:** Background: `#1C1C1E`, Card: `#2C2C2E`, Text Primary: `#F5F5F7`

---

### P1 MF-015: Veri Dışa Aktarım
**As a** kullanıcı  
**I want** tüm verilerimi JSON veya CSV olarak dışa aktarabilmek  
**So that** verilerimi sahiplenebilirim veya başka uygulamalarda kullanabilirim

**PRD Requirement References:** `PR-105`  
**UX Flow References:** `Veri Dışa Aktarım`  
**Dependencies:** MF-005  
**Implementation Boundary:** Export UI, JSON/CSV generation, Share Sheet entegrasyonu.

**Acceptance Criteria:**
- [ ] Given Ayarlar → Veri Yönetimi açıldığında, when "Dışa Aktar" seçilirse, then format seçimi (JSON/CSV) ve tarih aralığı seçimi görünür
- [ ] Given format ve tarih aralığı seçildiğinde, when "Oluştur" basılırsa, then dosya oluşturulur ve Share Sheet açılır
- [ ] Given veri yokken, when dışa aktarma denenirse, then "Aktarılacak veri yok" uyarısı gösterilir
- [ ] Given 1000+ kayıt varsa, when dışa aktarma yapılırsa, then progress indicator gösterilir
- [ ] Given JSON formatı seçildiğinde, when dosya oluşturulursa, then tüm alanlar (id, emoji, intensity, tags, timestamp) dahil edilir
- [ ] Given CSV formatı seçildiğinde, when dosya oluşturulursa, then kolonlar: timestamp, emoji, intensity, tags (comma-separated) olur

**Notes:** JSON = tam veri, CSV = basit analiz için. Dosya adı: mood-flicker-export-YYYY-MM-DD.json

---

## Coverage Map

### PRD Requirement Coverage
| PRD ID | Story ID | Notes |
|--------|----------|-------|
| PR-001 | MF-001 | Emoji grid seçimi |
| PR-002 | MF-002 | Yoğunluk slider'ı |
| PR-003 | MF-003 | Opsiyonel etiket ekleme |
| PR-004 | MF-004 | Zaman damgası |
| PR-005 | MF-005 | SwiftData persistans |
| PR-006 | MF-006 | Günlük trend |
| PR-007 | MF-007 | Haftalık trend |
| PR-008 | MF-008 | Aylık trend |
| PR-009 | MF-009 | Widget desteği |
| PR-010 | MF-010 | iCloud senkronizasyonu |
| PR-101 | MF-011 | Akıllı etiket önerileri (P1) |
| PR-102 | MF-012 | Streak görselleştirmesi (P1) |
| PR-103 | MF-013 | Haptic feedback (P1) |
| PR-104 | MF-014 | Koyu tema (P1) |
| PR-105 | MF-015 | Veri dışa aktarım (P1) |

### UX Flow Coverage
| UX Flow | Story ID(s) |
|---------|-------------|
| Widget'tan Hızlı Check-in | MF-002, MF-009 |
| Uygulama Açılışında Mood Kaydı | MF-001, MF-002, MF-003, MF-004, MF-005 |
| Trendler Ekranında Gezinme | MF-006, MF-007, MF-008, MF-012 |
| Etiket Ekleme/Çıkarma | MF-003, MF-011 |
| Veri Dışa Aktarım | MF-015 |

---

## Summary (for downstream agents)

```yaml
feature: "Mood Flicker - Hafif Mood Tracking"
source_artifacts:
  prd: "docs/mood-flicker/prd.md"
  ux: "docs/mood-flicker/ux.md"
  brainstorm: "docs/mood-flicker/brainstorm.md"
story_ids:
  p0:
    - MF-001  # Emoji seçimi
    - MF-002  # Yoğunluk slider
    - MF-003  # Etiket ekleme
    - MF-004  # Zaman damgası
    - MF-005  # SwiftData persistans
    - MF-006  # Günlük trend
    - MF-007  # Haftalık trend
    - MF-008  # Aylık trend
    - MF-009  # Widget
    - MF-010  # iCloud sync
  p1:
    - MF-011  # Akıllı etiket önerileri
    - MF-012  # Streak görselleştirmesi
    - MF-013  # Haptic feedback
    - MF-014  # Koyu tema
    - MF-015  # Veri dışa aktarım
coverage:
  prd_requirements:
    PR-001: [MF-001]
    PR-002: [MF-002]
    PR-003: [MF-003]
    PR-004: [MF-004]
    PR-005: [MF-005]
    PR-006: [MF-006]
    PR-007: [MF-007]
    PR-008: [MF-008]
    PR-009: [MF-009]
    PR-010: [MF-010]
    PR-101: [MF-011]
    PR-102: [MF-012]
    PR-103: [MF-013]
    PR-104: [MF-014]
    PR-105: [MF-015]
  ux_flows:
    "Widget'tan Hızlı Check-in": [MF-002, MF-009]
    "Uygulama Açılışında Mood Kaydı": [MF-001, MF-002, MF-003, MF-004, MF-005]
    "Trendler Ekranında Gezinme": [MF-006, MF-007, MF-008, MF-012]
    "Etiket Ekleme/Çıkarma": [MF-003, MF-011]
    "Veri Dışa Aktarım": [MF-015]
dependencies:
  MF-002: [MF-001]  # Yoğunluk için emoji seçimi gerekli
  MF-003: [MF-001]  # Etiket için emoji seçimi gerekli
  MF-004: []         # Zaman damgası bağımsız
  MF-005: [MF-001, MF-002, MF-003, MF-004]  # Persistans için veri modeli gerekli
  MF-006: [MF-005]   # Trend için veri gerekli
  MF-007: [MF-005]   # Trend için veri gerekli
  MF-008: [MF-005]   # Trend için veri gerekli
  MF-009: [MF-001, MF-005]  # Widget için emoji UI ve persistans gerekli
  MF-010: [MF-005]   # Sync için persistans gerekli
  MF-011: [MF-003]   # Akıllı öneriler için etiket sistemi gerekli
  MF-012: [MF-005]   # Streak için veri gerekli
  MF-013: []         # Haptic bağımsız
  MF-014: []         # Tema bağımsız
  MF-015: [MF-005]   # Export için veri gerekli
implementation_order:
  - "MF-001, MF-002, MF-003, MF-004 (bağımsız, paralel)"
  - "MF-005 (persistans, önceki story'lere bağımlı)"
  - "MF-006, MF-007, MF-008, MF-009, MF-010 (veriye bağımlı)"
  - "MF-011, MF-012, MF-013, MF-014, MF-015 (P1, sonraki iterasyon)"
implementation_risks:
  - "MF-009 Widget: iOS 17+ interaktivite limitasyonları, fallback flow gerekli"
  - "MF-010 iCloud: SwiftData CloudKit sync ilk başta sorunlu olabilir, conflict resolution gerekli"
  - "MF-005 SwiftData: Model migration stratejisi v1'den v2'ye planlanmalı"
  - "MF-011 Akıllı öneriler: Cold start problemi (ilk kullanımda veri yok)"
```

---

## Handoff Contract

**Next Agent:** `task-planner`

**Required Artifacts:**
- `docs/mood-flicker/stories.md` (this document)
- `docs/mood-flicker/prd.md`
- `docs/mood-flicker/ux.md`

**Recommended Artifacts:**
- `docs/mood-flicker/brainstorm.md`

**Critical Inputs:**
- Story ordering (P0 önce, P1 sonra)
- Story IDs (MF-001'den MF-015'e kadar stable)
- Acceptance criteria (Given/When/Then formatında)
- Dependencies (her story'nin ön koşulları)
- Implementation boundaries (scope sınırları)
- Coverage map (PRD ve UX flow eşleşmeleri)

**Sections That Must Not Change:**
- Story IDs
- Acceptance criteria intent
- Dependencies
- Implementation boundaries

**Mapping Rules:**
- Every P0 requirement must map to at least one story (✓ Coverage Map'te doğrulandı)
- Every primary UX flow must map to at least one story (✓ Coverage Map'te doğrulandı)
- Every story must be independently implementable veya dependency açıkça belirtilmiş
- Implementation order dependency'leri takip etmeli

**Recommended Implementation Order:**
1. MF-001, MF-002, MF-003, MF-004 (UI foundation, bağımsız)
2. MF-005 (SwiftData persistans, önceki UI story'lere bağımlı)
3. MF-006, MF-007, MF-008 (Trend charts, veriye bağımlı)
4. MF-009, MF-010 (Widget ve iCloud, persistans'a bağımlı)
5. MF-011 - MF-015 (P1 features, sonraki iterasyon)
