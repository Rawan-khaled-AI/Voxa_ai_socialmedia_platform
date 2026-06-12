# 🚀 VOXA

---

## 💡 About VOXA

**VOXA** is a modern voice-first social media platform that enables users to communicate through text, images, and voice content.

The platform combines traditional social networking features with voice-based interaction to create a more expressive and authentic user experience. VOXA is designed with scalability in mind and aims to evolve into an AI-powered social platform.

---

## 🧠 Vision

VOXA is built to:

* 🎙 Enable voice-based communication
* 📝 Share thoughts, stories, and experiences
* 📸 Support multimedia content creation
* 🤝 Build an expressive social community
* 🤖 Integrate AI-powered features in future releases

---

## 🏗️ Project Structure

```text
Voxa_ai_socialmedia_platform/
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
│   │   │   ├── post/
│   │   │   ├── profile/
│   │   │   ├── notifications/
│   │   │   └── settings/
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

* Flutter
* Dart
* Material 3

### 🧠 Backend

* Python 3.10
* FastAPI
* Uvicorn
* SQLAlchemy
* Alembic

### 🗄️ Database

* PostgreSQL

### 🐳 Infrastructure

* Docker
* Docker Compose

### 🤖 AI (Future Scope)

* Speech-to-Text (STT)
* Text-to-Speech (TTS)
* Recommendation System
* AI-Powered Feed Personalization

---

## ✨ Features

### Authentication

* User Registration
* User Login
* JWT Authentication
* Persistent Login Sessions
* Password Recovery Flow

### Social Features

* Dynamic Social Feed
* Create Text Posts
* Create Image Posts
* Create Voice Posts
* Like / Unlike Posts
* Comment on Posts
* Post Details Screen
* User Profiles
* Profile Navigation
* Notifications System

### Media Support

* Image Upload
* Voice Recording
* Audio Upload
* Audio Post Support

### Backend Features

* RESTful API Architecture
* PostgreSQL Integration
* Dockerized Environment
* Alembic Database Migrations
* Secure Authentication System

---

## 🚀 Current Progress

### ✅ Completed

* Flutter Application Architecture
* FastAPI Backend Architecture
* User Authentication System
* JWT Token Management
* PostgreSQL Database Integration
* Docker Environment Setup
* Alembic Migrations
* Create & Fetch Posts
* Dynamic Feed Integration
* Image Upload System
* Voice Upload System
* Likes System
* Comments System
* User Profiles
* Notifications
* Post Details Screen
* Flutter ↔ Backend Integration

---

### 🔄 In Progress

* Voice and Image Comments
* Enhanced Error Handling
* Loading State Improvements
* UI/UX Refinements
* Performance Optimization

---

### 🚀 Planned

* AI Recommendations
* Speech-to-Text Features
* Text-to-Speech Features
* Smart Content Suggestions
* AI-Powered Moderation
* Voice Analytics

---

## 🎤 Voice Feature

VOXA follows a voice-first approach.

### Current Capabilities

* Voice Recording
* Audio Upload
* Audio Post Creation
* Audio Storage & Retrieval

### Upcoming Enhancements

* Advanced Voice Experience
* AI Voice Processing
* Voice Analytics
* Accessibility Improvements

---

## ▶️ Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/Rawan-khaled-AI/Voxa_ai_socialmedia_platform.git
cd Voxa_ai_socialmedia_platform
```

---

### 2. Configure Environment

Create:

```bash
backend/.env
```

Example:

```env
DATABASE_URL=postgresql://postgres:postgres@db:5432/voxa_db
```

---

### 3. Start Docker Services

```bash
docker compose up -d
```

---

### 4. Run Backend

```bash
cd backend

python -m venv venv

venv\Scripts\activate

pip install -r requirements.txt

alembic upgrade head

uvicorn app.main:app --reload
```

Swagger Documentation:

```text
http://127.0.0.1:8000/docs
```

---

### 5. Run Flutter Application

```bash
cd mobile_app

flutter pub get

flutter run
```

For Android Emulator:

```text
http://10.0.2.2:8000
```

For Physical Device:

```text
http://YOUR_LOCAL_IP:8000
```

---

## 🔗 Core API Endpoints

| Method | Endpoint            | Description    |
| ------ | ------------------- | -------------- |
| POST   | /auth/signup        | Register User  |
| POST   | /auth/login         | Login User     |
| GET    | /posts/             | Get All Posts  |
| POST   | /posts/             | Create Post    |
| POST   | /likes/post/{id}    | Toggle Like    |
| GET    | /comments/post/{id} | Get Comments   |
| POST   | /comments/          | Create Comment |
| POST   | /upload/image       | Upload Image   |
| POST   | /upload/audio       | Upload Audio   |

---

## 🌱 Development Workflow

```bash
git checkout -b feature/new-feature

git add .

git commit -m "Implement new feature"

git push -u origin feature/new-feature
```

---

## 👨‍💻 Team

* Rawan Khaled
* Farah Nabil
* Tasneem Elraity
* Omar Mohamed
* Saif Eldin Ibrahim

---

## 🎯 Project Goal

> Build a production-inspired social media platform that combines voice communication, multimedia content sharing, and future AI capabilities into a unified user experience.

---

## ⭐ Final Note

VOXA is an actively evolving graduation project focused on delivering a scalable, voice-first social media experience powered by modern technologies including Flutter, FastAPI, PostgreSQL, Docker, and future AI integrations.
