# 🚀 VOXA

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Python](https://img.shields.io/badge/Python-3.10-yellow?logo=python)
![FastAPI](https://img.shields.io/badge/FastAPI-Backend-green?logo=fastapi)
![Status](https://img.shields.io/badge/Status-In%20Development-orange)

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
├── mobile_app/        # Flutter Application
│   ├── assets/
│   ├── lib/
│   │   ├── core/
│   │   │   ├── constants/
│   │   │   ├── routes/
│   │   │   ├── services/
│   │   │   └── theme/
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   ├── feed/
│   │   │   ├── home/
│   │   │   └── post/
│   │   ├── shared/
│   │   │   └── widgets/
│   │   └── main.dart
│   └── pubspec.yaml
│
├── backend/           # FastAPI Backend
│   ├── app/
│   │   ├── api/
│   │   ├── core/
│   │   ├── schemas/
│   │   └── main.py
│   ├── requirements.txt
│   └── .env
│
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

* Python
* FastAPI
* Uvicorn

### 🗄️ Database (Planned)

* PostgreSQL

### ☁️ Deployment (Planned)

* Railway

### 🤖 AI (Future)

* Speech-to-Text
* Text-to-Speech
* Recommendation System
* Content Moderation

---

## ✨ Current Progress

### ✅ Completed

* Flutter UI Structure
* Authentication Screens:

  * Splash Screen
  * Welcome Screen
  * Sign In
  * Sign Up
  * Code Verification
  * New Password
* Feed UI
* Create Post UI
* Reusable UI Components
* FastAPI Backend Setup
* Auth APIs:

  * `POST /auth/signup`
  * `POST /auth/login`
* Flutter ↔ Backend Integration

---

### 🔄 In Progress

* Connecting Sign In to backend
* Improving error handling
* UI polishing

---

### 🚀 Planned

* Database integration
* Real user storage
* Posts API
* Feed from backend
* Voice recording & playback
* Notifications
* AI features

---

## ▶️ How to Run the Project

---

### 1️⃣ Clone Repository

```bash
git clone https://github.com/Rawan-khaled-AI/Voxa_ai_socialmedia_platform.git
cd Voxa_ai_socialmedia_platform
```

---

### 2️⃣ Run Backend

```bash
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

📍 Backend runs on:

```text
http://127.0.0.1:8000
```

📍 Swagger Docs:

```text
http://127.0.0.1:8000/docs
```

---

### 3️⃣ Run Flutter App

```bash
cd mobile_app
flutter pub get
flutter run
```

---

## ⚠️ Important Note (Emulator)

When running on Android Emulator:

```dart
http://10.0.2.2:8000
```

❌ NOT:

```dart
http://127.0.0.1:8000
```

---

## 🔗 API Endpoints

### Root

```http
GET /
```

### Health Check

```http
GET /health
```

### Sign Up

```http
POST /auth/signup
```

```json
{
  "name": "Rawan",
  "email": "rawan@example.com",
  "password": "123456"
}
```

### Login

```http
POST /auth/login
```

```json
{
  "email": "rawan@example.com",
  "password": "123456"
}
```

---

## 🌱 Development Workflow

### Branches

* `main` → Stable version
* `dev` → Development

### Work on dev

```bash
git checkout dev
```

### Save changes

```bash
git add .
git commit -m "your message"
git push
```

---

## 👨‍💻 Team

* **Rawan Khaled**
* Farah Nabil
* Tasneem Elraity
* Omar Mohamed
* Saif Eldin Ibrahim

---

## 🎯 Vision

VOXA is built with a clear goal:

> **Build it like a real product — not just a project.**

---

## ⭐ Final Note

This project is under active development and will evolve into a scalable, AI-powered voice-first social media platform.
