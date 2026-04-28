---

# 🚀 VOXA

---

## 💡 About VOXA

**VOXA** is a modern voice-based social media platform that allows users to express themselves through text, images, and voice.

The project is designed to evolve into a **full AI-powered social experience**, focusing on authentic communication and voice-first interaction.

---

## 🧠 Idea

VOXA is not just a social media app.

It is built to:

* 🎙 Enable voice-based communication
* 📝 Share thoughts and stories
* 🌍 Build a real expressive community
* 🤖 Integrate AI features in the future

---

## 🏗️ Project Structure

```text
voxa/
├── backend/
│   ├── alembic/
│   ├── app/
│   │   ├── api/
│   │   ├── core/
│   │   ├── models/
│   │   ├── schemas/
│   │   ├── services/
│   │   └── main.py
│   ├── requirements.txt
│   └── .env
│
├── mobile_app/
│   ├── lib/
│   │   ├── core/
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   ├── feed/
│   │   │   └── post/
│   │   ├── shared/
│   │   └── main.dart
│   └── pubspec.yaml
│
├── docker-compose.yml
├── .env.example
├── .gitignore
└── README.md
```

---

## ⚙️ Tech Stack

### 📱 Frontend

* Flutter / Dart
* Material 3

### 🧠 Backend

* Python 3.10
* FastAPI + Uvicorn
* SQLAlchemy
* Alembic

### 🗄️ Database

* PostgreSQL

### 🐳 Infrastructure

* Docker

### 🤖 AI (Future)

* Speech-to-Text
* Text-to-Speech
* Recommendation System

---

## ✨ Current Progress

### ✅ Completed

* Flutter UI Structure
* Authentication Flow (Signup / Login)
* Token-based authentication (JWT + persistence)
* FastAPI Backend Setup
* PostgreSQL Database with Docker
* Alembic Migrations (users & posts)
* Real Posts API (Create + Fetch)
* Flutter ↔ Backend Integration
* Dynamic Feed connected to backend
* Image upload system (end-to-end)
* Audio upload endpoint (voice foundation)

---

### 🔄 In Progress

* Voice post UI integration (recording + upload)
* Displaying audio in feed (player)
* Improving error handling
* UI/UX polishing

---

### 🚀 Planned

* Audio playback in feed (voice posts)
* Likes & comments system
* User profiles
* Notifications
* AI features (STT, TTS, recommendations)

---

## 🎤 Voice Feature Status

VOXA introduces a voice-first direction.

### Current State:

* Audio recording from Flutter
* Audio file upload to backend
* Audio linked to posts (audio_url)

### Next Step:

* Audio playback inside feed
* Voice UI enhancements

> Voice posts are currently in **foundation stage**.

---

## ▶️ How to Run the Project

### 1️⃣ Clone Repository

```bash
git clone https://github.com/Rawan-khaled-AI/Voxa_ai_socialmedia_platform.git
cd Voxa_ai_socialmedia_platform
```

---

### 2️⃣ Setup Environment

```bash
cp .env.example backend/.env
```

Example:

```env
DATABASE_URL=postgresql://postgres:postgres@db:5432/voxa_db
```

---

### 3️⃣ Run Docker

```bash
docker compose up -d
```

---

### 4️⃣ Run Backend

```bash
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt

alembic upgrade head

uvicorn app.main:app --reload
```

Swagger:

```
http://127.0.0.1:8000/docs
```

---

### 5️⃣ Run Flutter App

```bash
cd mobile_app
flutter pub get
flutter run
```

> Android emulator uses:

```
http://10.0.2.2:8000
```

---

## 🔗 API Endpoints

| Method | Endpoint        | Description   |
| ------ | --------------- | ------------- |
| GET    | `/`             | Root          |
| GET    | `/health`       | Health Check  |
| POST   | `/auth/signup`  | Register      |
| POST   | `/auth/login`   | Login         |
| GET    | `/posts/`       | Get all posts |
| POST   | `/posts/`       | Create post   |
| POST   | `/upload/image` | Upload image  |
| POST   | `/upload/audio` | Upload audio  |

---

## 🌱 Development Workflow

```bash
git checkout -b feature/media-posts
git add .
git commit -m "Implement posts, image upload, and voice foundation"
git push -u origin feature/media-posts
```

---

## 👨‍💻 Team

* Rawan Khaled
* Farah Nabil
* Tasneem Elraity
* Omar Mohamed
* Saif Eldin Ibrahim

---

## 🎯 Vision

> Build it like a real product — not just a project.

---

## ⭐ Final Note

VOXA is under active development and evolving into a scalable, AI-powered, voice-first social media platform.

---
