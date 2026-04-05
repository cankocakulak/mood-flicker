# PRD: Mood Flicker

## Problem

Kullanıcılar ruh hallerini takip etmek istiyor, ancak mevcut mood tracking uygulamaları çok ağır: uzun formlar, detaylı journaling, sürekli hatırlatma bildirimleri. Sonuç? Kullanıcılar birkaç gün kullanıp bırakıyor. Mood Flicker, "nasıl hissediyorum?" sorusunu 2-5 saniyede cevaplanabilecek kadar hafif hale getirmeyi hedefliyor.

## Solution

Emoji-tabanlı, tek dokunuşla mood seçimi + sürükle-bırak yoğunluk ayarı + isteğe bağlı etiketler. Widget desteği ile kilit ekranından giriş. SwiftData ile yerel depolama ve iCloud senkronizasyonu. Trendler için Charts framework ile görselleştirme.

## Requirements

### Must Have (P0)

- [ ] `PR-001` Emoji grid ile 5-6 temel duygu seçimi (😊 😐 😔 😤 😰 + opsiyonel)
  - Acceptance: Kullanıcı tek dokunuşla mood seçebilir, seçim anında görsel geri bildirim alır
- [ ] `PR-002` Yoğunluk slider'ı (düşük → orta → yüksek)
  - Acceptance: Seçilen emoji altında 3-seviyeli veya sürekli slider görünür, varsayılan değer "orta"dır
- [ ] `PR-003` Opsiyonel etiket ekleme (anksiyetik, yorgun, sakin, enerjik, vs.)
  - Acceptance: Kullanıcı 0-3 etiket seçebilir, etiketler mood'e göre önerilir
- [ ] `PR-004` Her kaydın zaman damgası (saat + gün)
  - Acceptance: Tüm kayıtlar otomatik timestamp alır, saat/dakika ve tarih bilgisi saklanır
- [ ] `PR-005` SwiftData ile yerel persistans
  - Acceptance: Uygulama kapatılıp açıldığında tüm veriler korunur
- [ ] `PR-006` Günlük trend görünümü (grafik)
  - Acceptance: Ana ekranda son 24 saatin mood dağılımı görselleştirilir
- [ ] `PR-007` Haftalık trend görünümü
  - Acceptance: Haftalık görünümde 7 günlük mood ortalaması ve değişimi görülür
- [ ] `PR-008` Aylık trend görünümü
  - Acceptance: Aylık görünümde günlük ortalama mood skoru grafikte izlenebilir
- [ ] `PR-009` Widget desteği (iOS 17+ interaktiv widget)
  - Acceptance: Kullanıcı widget üzerinden doğrudan mood kaydı yapabilir
- [ ] `PR-010` iCloud senkronizasyonu
  - Acceptance: Aynı Apple ID ile farklı cihazlarda veriler senkronize olur

### Should Have (P1)

- [ ] `PR-101` Akıllı etiket önerileri (mood bazlı)
  - Acceptance: Düşük enerji mood'lerinde "yorgun", anksiyete mood'lerinde "anksiyetik" önerilir
- [ ] `PR-102` Streak görselleştirmesi (baskı yapmayan)
  - Acceptance: Ardışık gün sayısı gösterilir ama kırılan streakler 24h sonra gizlenir
- [ ] `PR-103` Haptic feedback
  - Acceptance: Mood seçimi, yoğunluk ayarı ve kayıt tamamlandığında farklı haptic pattern'ler
- [ ] `PR-104` Koyu tema desteği
  - Acceptance: Sistem temasına otomatik uyum veya manuel seçim
- [ ] `PR-105` Veri dışa aktarım (JSON/CSV)
  - Acceptance: Kullanıcı tüm verilerini JSON veya CSV olarak paylaşabilir

### Nice to Have (P2)

- [ ] `PR-201` Zaman bazlı akıllı varsayılanlar (sabah/öğlen/akşam pattern'leri)
  - Acceptance: Yeterli veri biriktikten sonra uygulama olası mood'ü önerir
- [ ] `PR-202` Özel etiket oluşturma
  - Acceptance: Kullanıcı kendi etiketlerini ekleyebilir ve renk atayabilir
- [ ] `PR-203` Haftalık mood özeti bildirimi
  - Acceptance: Hafta sonu otomatik özet bildirimi (kapatılabilir)
- [ ] `PR-204` Apple Health entegrasyonu (Mindful Minutes)
  - Acceptance: Her mood check-in Mindful Minutes olarak HealthKit'e yazılır

## Tech Stack

| Layer | Choice | Reasoning |
|-------|--------|-----------|
| UI Framework | SwiftUI | Native iOS, animasyon desteği, WidgetKit uyumluluğu |
| Persistence | SwiftData | Modern API, otomatik CloudKit, az boilerplate |
| Charts | Swift Charts (iOS 16+) | Native, performanslı, SwiftUI ile seamless |
| Widgets | WidgetKit + App Intents | iOS 17 interaktiv widget desteği |
| Sync | CloudKit (via SwiftData) | Apple ekosisteminde ücretsiz, güvenilir |
| Minimum iOS | iOS 17 | SwiftData + interaktiv widgetler için gerekli |

## Out of Scope

- Backend/API (v1'de yok, iCloud yeterli)
- Sosyal paylaşım özellikleri
- Mood journaling (uzun yazılar)
- Fotoğraf/audio ekleme
- AI-driven insights (v2'de değerlendirilebilir)
- Android versiyonu
- iPad optimizasyonu (v1'de iPhone only)
- Apple Watch uygulaması (v1.1'de değerlendirilebilir)

## Success Criteria

- [ ] Kullanıcı ortalama 3 saniyede mood check-in tamamlayabilmeli
- [ ] İlk hafta retention oranı %50+ olmalı
- [ ] Günlük aktif kullanıcıların %60+ en az bir mood kaydı girmeli
- [ ] App Store rating 4.5+ olmalı
- [ ] Widget kullanımı toplam girişlerin %30+'unu oluşturmalı

## Open Questions

1. Emoji seti: Standart 5'li (mutlu, nötr, üzgün, öfkeli, anksiyeteli) mi yoksa genişletilmiş mi?
2. Etiket taxonomy'si: Sabit liste mi, kullanıcı tanımlı mı, yoksa ikisi mi?
3. Widget limitasyonları: iOS 17 interaktiv widgetlerde kaç emoji gösterilebilir?
4. Bildirim stratejisi: Günlük hatırlatma mı, yoksa sadece opsiyonel mi?
5. Veri silme: Kullanıcı tek kayıt silebilmeli mi, sadece dışa aktarıp silme mi?

## Summary (for downstream agents)

```yaml
feature: "Mood Flicker - Hafif Mood Tracking"
source_artifacts:
  brainstorm: "docs/mood-flicker/brainstorm.md"
  analysis: ""
primary_user_problem: "Mevcut mood tracking uygulamaları çok ağır, kullanıcılar sürekli takip yapamıyor"
solution_shape: "Emoji-first, 2-5 saniyelik widget destekli mood check-in uygulaması"
p0_requirements:
  - id: "PR-001"
    summary: "Emoji grid ile 5-6 temel duygu seçimi"
  - id: "PR-002"
    summary: "Yoğunluk slider'ı (düşük → orta → yüksek)"
  - id: "PR-003"
    summary: "Opsiyonel etiket ekleme"
  - id: "PR-004"
    summary: "Her kaydın zaman damgası"
  - id: "PR-005"
    summary: "SwiftData ile yerel persistans"
  - id: "PR-006"
    summary: "Günlük trend görünümü"
  - id: "PR-007"
    summary: "Haftalık trend görünümü"
  - id: "PR-008"
    summary: "Aylık trend görünümü"
  - id: "PR-009"
    summary: "Widget desteği (iOS 17+)"
  - id: "PR-010"
    summary: "iCloud senkronizasyonu"
p1_requirements:
  - id: "PR-101"
    summary: "Akıllı etiket önerileri"
  - id: "PR-102"
    summary: "Streak görselleştirmesi (baskısız)"
  - id: "PR-103"
    summary: "Haptic feedback"
  - id: "PR-104"
    summary: "Koyu tema desteği"
  - id: "PR-105"
    summary: "Veri dışa aktarım"
primary_flows_expected:
  - "Widget'tan hızlı check-in"
  - "Uygulama açılışında mood kaydı"
  - "Trendler ekranında gezinme (gün/hafta/ay)"
  - "Etiket ekleme/çıkarma"
  - "Veri dışa aktarım"
key_risks:
  - "Widget interaktivitesi iOS 17+ gerektirir, kullanıcı kitlesi sınırlı olabilir"
  - "SwiftData iCloud sync ilk başta sorunlu olabilir"
  - "2-5 saniye hedefi UI animasyonları ile zorlanabilir"
open_questions:
  - "Emoji seti kararı"
  - "Etiket taxonomy yapısı"
  - "Bildirim stratejisi"
  - "Veri silme politikası"
```

## Handoff Contract

Next Agent: `ux-designer`

Required Artifacts:
- `docs/mood-flicker/prd.md` (this document)

Recommended Artifacts:
- `docs/mood-flicker/brainstorm.md`

Critical Inputs:
- Problem: Mevcut mood tracking uygulamaları çok ağır
- Solution: Emoji-first, 2-5 saniyelik widget destekli check-in
- P0 requirements: PR-001 through PR-010
- Tech stack: SwiftUI, SwiftData, WidgetKit, iOS 17+
- Constraints: No backend, iPhone only, light/fast/calm vibe

Sections That Must Not Change:
- Problem
- Solution
- P0 requirements (PR-001 to PR-010)
- Out of Scope

Mapping Rules:
- Every P0 requirement must map to at least one UX flow
- Primary flows expected: Widget check-in, App check-in, Trends navigation, Tag management, Export
- Open questions must be resolved or carried forward to UX
- "2-5 second check-in" constraint must be validated in every flow

# prd

kind: let

source:
```prose
let prd_artifact = session: stage-runner
```
