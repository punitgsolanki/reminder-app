# ⏰ Reminder App (Flutter)

A simple and clean **Reminder Application** built using **Flutter**, with support for offline data storage and real-time Firebase sync. This app helps users create, update, and delete reminders, with local notifications and network-aware syncing.

---

## 🚀 Overview

This project was developed in:

- **Flutter**: 3.29.3 (channel stable)
- **Dart SDK**: 3.7.2
- **Gradle**: 8.10.2
- **IDE**: Android Studio Giraffe | 2022.3.1 Patch 4

### 🔧 Key Features

- ✅ Add, Update, Delete Reminder
- 📅 Store reminders locally using [Hive](https://pub.dev/packages/hive)
- ☁️ Sync with Firebase Firestore when network is available
- 📶 Network connectivity check for online/offline logic
- 🔔 Schedule local notifications for reminders
- 🧠 Clean Architecture using [GetX](https://pub.dev/packages/get) for state management

---

## 🗃️ Architecture

- **Local DB**: Hive for offline-first experience
- **Cloud DB**: Firebase Firestore
- **State Management**: GetX
- **Architecture Pattern**: Clean Architecture
- **Connectivity**: Network status monitored to sync data accordingly

---

## 📲 APK & Source

- 🔗 [**Download APK**](https://github.com/punitgsolanki/reminder-app/blob/main/assets/app-release.apk)
- 📁 [**View Source Code**](https://github.com/punitgsolanki/reminder-app/tree/main/source)

---

## 📸 Screenshots

| Home | Reminder Details |
|------|------------------|
| ![Home](https://github.com/punitgsolanki/reminder-app/blob/main/assets/Screenshot_20250623_195603.png) | ![Details](https://github.com/punitgsolanki/reminder-app/blob/main/assets/Screenshot_20250623_195624.png) |

---

## 🛠️ Getting Started

To run this project locally:

1. Clone the repo:
   ```bash
   git clone https://github.com/punitgsolanki/reminder-app.git
   cd reminder-app/source
