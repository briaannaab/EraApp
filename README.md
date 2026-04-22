# Era 👑

> The platform where creators reign.

Era is a public, mixed-media social platform built for creators who are done being buried by algorithms, exploited by ads, and underpaid for their work. Chronological. Creator-first. AI-powered. Built to take over.

---

## ✨ Why Era?

| The Problem | The Era Fix |
|---|---|
| Algorithms bury your posts | Chronological feed — everyone sees everything |
| You create, platforms profit | Built-in tips, subscriptions & creator payouts |
| One content type fits all | Mixed media — text, photos, video, audio in one post |
| Discoverability is dead | Interest tags + AI-powered content suggestions |
| Writing content is hard | AI caption & post assistant built right in |

---

## 🚀 Core Features

**For Creators**
- 📸 Mixed media posts (text, image, video, audio)
- 💸 Tips & paid subscriptions from day one
- 🤖 AI writing assistant for captions & posts
- 📊 Real analytics — who's actually seeing your work
- 🏷️ Interest tags to find your audience organically

**For Everyone**
- 📅 Chronological feed — no algorithm, no manipulation
- 🔍 Smart search across posts, people & tags
- 🌐 Public profiles — your content, your brand
- 💬 Comments, reposts & reactions
- 🔔 Real-time notifications

---

## 🏗️ Architecture

```
era/
├── mobile/                   # React Native + Expo (iOS & Android)
│   ├── app/                  # Expo Router screens
│   │   ├── (tabs)/           # Feed, Explore, Create, Notifications, Profile
│   │   ├── post/[id].tsx     # Single post view
│   │   └── profile/[id].tsx  # User profile
│   ├── src/
│   │   ├── components/       # PostCard, MediaUploader, AICaptionBar, CreatorBadge
│   │   ├── hooks/            # useFeed, usePost, useAuth, useAI
│   │   └── api/              # Backend client
├── backend/                  # Python / FastAPI
│   ├── routers/              # /posts, /users, /feed, /ai, /payments
│   ├── services/             # feed.py, ai.py, media.py, payments.py
│   ├── models/               # Post, User, Subscription, Transaction
│   └── db/                   # PostgreSQL + Redis
└── infra/                    # Docker Compose, env config
```

---

## 🛠️ Tech Stack

**Mobile**
![React Native](https://img.shields.io/badge/React_Native-20232A?style=flat&logo=react&logoColor=61DAFB)
![Expo](https://img.shields.io/badge/Expo-000020?style=flat&logo=expo&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=flat&logo=typescript&logoColor=white)

**Backend**
![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=flat&logo=fastapi&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=flat&logo=postgresql&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=flat&logo=redis&logoColor=white)

**AI & Payments**
![OpenAI](https://img.shields.io/badge/OpenAI-412991?style=flat&logo=openai&logoColor=white)
![Stripe](https://img.shields.io/badge/Stripe-626CD9?style=flat&logo=stripe&logoColor=white)

---

## 🚀 Getting Started

### Backend
```bash
cd backend
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn main:app --reload
```

### Mobile
```bash
cd mobile
npm install
npx expo start --tunnel
```

---

## 📍 Roadmap

- [x] Chronological feed
- [x] Mixed media posts
- [x] AI caption assistant
- [x] Creator profiles
- [ ] Tips & subscriptions (Stripe)
- [ ] Live streaming
- [ ] Desktop web app
- [ ] Creator analytics dashboard

---

## 📄 License

MIT — build on it, learn from it, make it yours.
