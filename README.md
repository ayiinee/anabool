# Anabool

## 1. General Information

**Project Name:** Anabool

**Brief Description:** Anabool is a pet care and cat litter waste management application that helps users monitor cats, scan litter waste, learn safe handling practices, request waste pickup, and redeem rewards. The application combines computer vision, a RAG-powered chatbot, and marketplace/pickup features to make cat litter waste handling more practical and environmentally responsible.

## 2. Key Features

- Computer Vision-based cat litter waste image detection using CNN/Roboflow integration.
- RAG chatbot integration through Ana, an assistant for cat care and waste handling guidance.
- Cat litter waste pickup system with pickup agents, tracking, and routing support.
- Cat profile and litter box monitoring for pet activity and status management.
- Education modules, rewards, impact tracking, and marketplace features.
- Firebase-based authentication and notification integration.

## 3. Tech Stack Used

- **Frontend:** Flutter
- **Backend:** Python FastAPI
- **Database & AI:** Supabase, RAG, CNN
- **Additional Integrations:** Firebase, Groq, Roboflow, OSRM

## Project Structure

```text
anabool/
+-- backend/      # FastAPI backend, API routes, services, AI integrations, tests
+-- frontend/     # Flutter mobile/web application
+-- supabase/     # Supabase configuration and database migrations
+-- README.md
```

## 4. Installation & Usage Guide

### a. Prerequisites

Install the following tools before running the project:

- Flutter SDK with Dart SDK support
- Python 3.10+
- pip
- Git
- Supabase CLI
- A Supabase project
- Firebase project credentials
- Optional AI service credentials: Groq API key and Roboflow API key

### b. Clone & Setup

Clone the repository:

```bash
git clone <repository-url>
cd anabool
```

Set up the backend:

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

For local testing, PDF ingestion, local embeddings, and optional maintenance tools, install the local requirements:

```bash
pip install -r requirements-local.txt
```

For macOS/Linux, activate the virtual environment with:

```bash
source .venv/bin/activate
```

Set up the frontend:

```bash
cd ../frontend
flutter pub get
```

### c. Environment Variables

Create a backend environment file:

```bash
cd backend
copy .env.example .env
```

For macOS/Linux:

```bash
cp .env.example .env
```

Example `backend/.env` format:

```env
APP_NAME=ANABOOL
APP_ENV=development
APP_DEBUG=true

API_V1_PREFIX=/api/v1
BACKEND_HOST=0.0.0.0
BACKEND_PORT=8000
FRONTEND_ORIGIN=http://localhost:3000

SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
SUPABASE_PASSWORD=your_supabase_password
DATABASE_URL=your_database_url

FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_CLIENT_EMAIL=your_firebase_client_email
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nyour_private_key\n-----END PRIVATE KEY-----\n"
FIREBASE_PRIVATE_KEY_ID=your_firebase_private_key_id
FIREBASE_CLIENT_ID=your_firebase_client_id

ROBOFLOW_API_URL=https://serverless.roboflow.com
ROBOFLOW_API_KEY=your_roboflow_api_key
ROBOFLOW_MODEL_ID=pet-poop-classifier/1

GROQ_API_KEY=your_groq_api_key
GROQ_CHAT_MODEL=meta-llama/llama-4-scout-17b-16e-instruct

EMBEDDING_PROVIDER=hash
EMBEDDING_MODEL_NAME=intfloat/multilingual-e5-small
EMBEDDING_DIMENSION=384
EMBEDDING_CACHE_DIR=.cache/huggingface

OSRM_BASE_URL=https://router.project-osrm.org

CNN_MODEL_PATH=../ai-model/cnn/models/anabool_cnn_model.h5
CNN_CONFIDENCE_THRESHOLD=0.70
```

The Flutter frontend reads the backend URL from the `ANABOOL_API_BASE_URL` Dart define. If no value is provided, it defaults to `http://127.0.0.1:8000` on most platforms and `http://10.0.2.2:8000` on Android emulator.

### Supabase Setup

The database schema is stored in `supabase/migrations`. After creating or linking a Supabase project, apply the migrations:

```bash
cd supabase
supabase link --project-ref your_supabase_project_ref
supabase db push
```

If you are running Supabase locally:

```bash
cd supabase
supabase start
supabase db reset
```

Use the Supabase project URL, anon key, service role key, and database URL in `backend/.env`.

Optional marketplace seed data can be inserted with:

```bash
cd backend
python scripts/seed_marketplace.py
```

Optional RAG documents can be ingested with:

```bash
cd backend
python scripts/ingest_rag_pdf.py path/to/document.pdf
```

### Firebase Setup

The Flutter app initializes Firebase from `frontend/lib/firebase_options.dart`. If you use a different Firebase project, regenerate this file with FlutterFire CLI:

```bash
cd frontend
flutterfire configure
```

For the backend, provide Firebase service account values in `backend/.env`, especially `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, and `FIREBASE_PRIVATE_KEY`.

### AI Service Notes

- Roboflow credentials are required for remote scan inference.
- Groq credentials are required for live chatbot responses.
- `EMBEDDING_PROVIDER=hash` works without local embedding dependencies and is suitable for lightweight development.
- Local embedding mode requires the additional packages from `requirements-local.txt`.

### d. How to Run

Start the backend server:

```bash
cd backend
.venv\Scripts\activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The backend API will be available at:

- `http://127.0.0.1:8000`
- Swagger UI: `http://127.0.0.1:8000/docs`
- Health check: `http://127.0.0.1:8000/health`

Run the Flutter frontend:

```bash
cd frontend
flutter run --dart-define=ANABOOL_API_BASE_URL=http://127.0.0.1:8000
```

For Android emulator:

```bash
flutter run --dart-define=ANABOOL_API_BASE_URL=http://10.0.2.2:8000
```

For Flutter web:

```bash
flutter run -d chrome --dart-define=ANABOOL_API_BASE_URL=http://127.0.0.1:8000
```

### e. Download or Build APK

If a release APK has already been generated, it can be found from the Flutter project directory at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

From the repository root, that path is usually:

```text
frontend/build/app/outputs/flutter-apk/app-release.apk
```

To build a new release APK:

```bash
cd frontend
flutter build apk --release --dart-define=ANABOOL_API_BASE_URL=http://your-backend-url
```

### f. Testing

Run backend tests:

```bash
cd backend
pytest
```

Run frontend tests:

```bash
cd frontend
flutter test
```
