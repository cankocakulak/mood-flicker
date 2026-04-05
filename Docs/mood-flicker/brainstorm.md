# brainstorm

kind: let

source:
```prose
let brainstorm_artifact = session: stage-runner
```

---

# Mood Flicker - Brainstorm

## Analysis

The real problem isn't "how do we track moods" — it's "how do we make mood tracking so effortless that users actually do it consistently." Most mood apps die from friction: too many questions, too much journaling, too much guilt. The 2-5 second check-in is the killer feature.

---

## Ideas

### Idea 1: One-Tap Mood Wheel
**What**: Circular mood selector with 5-6 primary emotions radiating from center; tap to select, drag outward for intensity
**Why it works**: Visual, intuitive, single gesture completes both mood + intensity
**Risk**: May feel too simplistic for users wanting nuance
**Effort**: Low

### Idea 2: Emoji-First Quick Picker
**What**: Grid of expressive emoji faces (😊 😐 😔 😤 😰) with haptic feedback; intensity via vertical swipe on selected emoji
**Why it works**: Universally understood, emotionally resonant, fun to use
**Risk**: Emoji interpretation varies culturally; may feel juvenile to some
**Effort**: Low

### Idea 3: Color Gradient Slider
**What**: Horizontal gradient bar (cool blues → neutral greens → warm reds) representing mood spectrum; tap anywhere to log
**Why it works**: Abstract enough for personal interpretation, visually calming, extremely fast
**Risk**: Less precise emotion mapping; harder to categorize for analytics
**Effort**: Low

### Idea 4: Smart Tag Suggestions
**What**: After mood selection, surface 3-4 contextually relevant tags (e.g., "yorgun" appears after selecting low-energy moods) with one-tap add
**Why it works**: Reduces decision fatigue, learns from patterns, still optional
**Risk**: Needs usage data to become smart; cold start problem
**Effort**: Medium

### Idea 5: Streaks Without Pressure
**What**: Gentle streak visualization that celebrates consistency but hides broken streaks after 24h; no guilt, only positive reinforcement
**Why it works**: Builds habit without the toxic "I failed" feeling that kills most tracking apps
**Risk**: May reduce engagement for competitive users
**Effort**: Low

### Idea 6: Weekly Mood Movie
**What**: Auto-generated animated visualization of week's moods — colors pulse, tags float by; shareable as story/video
**Why it works**: Makes data feel alive, encourages reflection, organic marketing
**Risk**: Video generation complexity; battery/performance concerns
**Effort**: High

### Idea 7: Time-Based Smart Defaults
**What**: App suggests likely mood based on time of day + historical patterns ("Most mornings you're calm — still true?")
**Why it works**: One-tap confirmation vs. selection; gets faster with use
**Risk**: Wrong predictions frustrate; needs significant data first
**Effort**: Medium

### Idea 8: Widget-First Design
**What**: Home screen widget as primary entry point; check-in without opening app
**Why it works**: iOS 17+ interactive widgets make this seamless; zero friction
**Risk**: Limited widget interactions constrain feature depth
**Effort**: Medium

---

## Tech Direction

**Recommended Stack:**
- **SwiftUI** — Native, smooth animations, widget support built-in
- **SwiftData** — Local persistence, iCloud sync, minimal boilerplate
- **Charts framework** — Native iOS 16+ charts for trend visualization
- **WidgetKit** — For lock screen / home screen quick entry

**Key Technical Bets:**
1. **Local-first**: No backend needed for v1; iCloud sync handles multi-device
2. **SwiftData over Core Data**: Modern API, less code, automatic CloudKit
3. **Widget as first-class**: Design the core flow assuming widget entry exists

---

## Recommendation

**Go with Idea 2 (Emoji-First) + Idea 4 (Smart Tags) + Idea 5 (Streaks Without Pressure) + Idea 8 (Widget-First).**

Emoji picker is the fastest emotional input method — universally understood, visually delightful. Smart tags add depth without friction (optional, contextual). Streaks build habit without guilt. Widget-first design means the 2-second check-in is literally possible from the home screen.

Skip the color gradient (less precise) and mood movie (v2 feature). Time-based defaults can be a v1.1 enhancement once there's data.

---

## Combinations

**The "Flicker" Flow:**
1. User taps widget or opens app
2. Emoji grid appears (no loading, no navigation)
3. Tap emoji → intensity slider appears below (default: medium)
4. Optional: tap suggested tags or skip
5. Done. 2-3 seconds total.

This combination delivers on the core promise: "mood tracking that flickers by."

---

## Summary (for downstream agents)

```yaml
feature: Mood Flicker - Lightweight Mood Tracking
selected_direction:
  primary: Emoji-first quick picker with intensity slider
  secondary: Smart contextual tags, guilt-free streaks, widget-first entry
  core_promise: 2-5 second mood check-in from lock/home screen

rejected_directions:
  - Color gradient slider: too abstract, poor analytics
  - Weekly mood movie: high effort, v2 candidate
  - Time-based smart defaults: needs data, v1.1 candidate

constraints:
  platform: iOS (iPhone)
  framework: SwiftUI
  max_checkin_time: 5 seconds
  vibe: light, fast, calm, trackable

technical_bets:
  - SwiftData for local persistence + iCloud sync
  - WidgetKit for primary entry point
  - Native Charts for trend visualization
  - No backend for v1

open_questions_for_prd:
  - Exact emoji set and emotion mapping
  - Tag taxonomy and suggestion algorithm
  - Widget interaction limitations (iOS 17+)
  - Data export format for user ownership
  - Notification strategy (reminders vs. interruptions)
```

---

## Handoff Contract

**Next Agent:** `prd`

**Required Artifacts:**
- `docs/mood-flicker/brainstorm.md` (this document)

**Recommended Artifacts:**
- None (no analysis artifact provided for this run)

**Critical Inputs That Must Remain Stable:**
- 2-5 second check-in time constraint
- SwiftUI + native iPhone stack
- Light, fast, calm product vibe
- Widget-first entry point assumption

**Sections That Must Not Change Before PRD:**
- Selected direction (Emoji-first + Smart Tags + Streaks + Widget)
- Core "Flicker Flow" interaction pattern
- Technical stack decisions (SwiftUI, SwiftData, WidgetKit)
- Constraint on no backend for v1

**Open Questions for PRD to Resolve:**
- Specific emoji-to-mood mapping
- Tag taxonomy structure
- Widget UI limitations and fallbacks
- Notification/reminder strategy
- Data export requirements
