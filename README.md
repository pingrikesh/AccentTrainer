# Accent Trainer

A personal iOS app for English pronunciation, accent, rhythm, and fluency practice — inspired by Boldvoice.

## Features

- **13 curated lessons** across sounds, rhythm, sentences, and conversation
- **Record & analyze** your speech with on-device Apple Speech Recognition
- **Word-level scoring** with color-coded feedback
- **Fluency metrics** — words per minute, pause detection, flow score
- **AI coaching** via OpenAI (optional — built-in coaching works for free)
- **Reference audio** using built-in text-to-speech
- **Progress tracking** with session history and streaks

## Requirements

- Mac with **Xcode 15+**
- iPhone running **iOS 17+**
- Apple ID (free tier works for personal device testing)
- OpenAI API key (optional — only for enhanced AI coaching)

## Setup

1. Open the project in Xcode:
   ```
   open AccentTrainer.xcodeproj
   ```

2. Select the **AccentTrainer** target → **Signing & Capabilities**
   - Choose your Team (your Apple ID)
   - Xcode will manage signing automatically

3. Connect your iPhone via USB or Wi-Fi

4. Select your iPhone as the run destination and press **Run** (⌘R)

5. On first launch, allow **Microphone** and **Speech Recognition** permissions

6. **Optional:** Settings tab → paste an OpenAI API key for enhanced coaching. **You can skip this** — built-in coaching is free.

## Cost

| Feature | Cost |
|---------|------|
| Recording, speech recognition, scoring, TTS, progress | **Free** (Apple frameworks, on-device) |
| Built-in coaching tips | **Free** |
| OpenAI coaching | **Optional paid** (~$0.01/session) |

## How to Use

1. **Practice** tab → pick a lesson category (Sounds, Rhythm, Sentences, Conversation)
2. Tap a lesson → read the tip
3. Tap **Hear Reference** to hear the target sentence
4. Tap the **microphone** → speak the sentence → tap again to stop
5. Review your scores and AI coaching
6. Tap **Save** to store the session in **Progress**

## Project Structure

```
AccentTrainer/
├── Models/          # Lesson, PracticeRecord, AnalysisResult
├── Services/        # Audio, Speech, Scoring, AI, TTS
├── ViewModels/      # Practice session logic
├── Views/           # SwiftUI screens
└── Resources/       # lessons.json
```

## Adding Lessons

Edit `AccentTrainer/Resources/lessons.json`:

```json
{
  "id": "unique-id",
  "title": "Lesson Title",
  "category": "Sounds",
  "text": "The sentence to practice.",
  "focusSounds": ["th", "r"],
  "tip": "Coaching tip for this lesson.",
  "difficulty": 1
}
```

Categories: `Sounds`, `Rhythm & Flow`, `Sentences`, `Conversation`

## Privacy

- Speech recognition runs on-device when supported
- Audio recordings are temporary and not uploaded
- OpenAI API key is stored locally in UserDefaults
- Only lesson text, transcript, and scores are sent to OpenAI for coaching

## License

Personal use only.
