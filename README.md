# PulseDB — Music Streaming Platform

[![CI](https://github.com/Huzaifa-zuberi/PulseDB/actions/workflows/ci.yml/badge.svg)](https://github.com/Huzaifa-zuberi/PulseDB/actions/workflows/ci.yml)
[![Python](https://img.shields.io/badge/Python-3.8%2B-blue?logo=python)](https://python.org)
[![License](https://img.shields.io/badge/License-MIT-success)](LICENSE)
![Last Commit](https://img.shields.io/github/last-commit/Huzaifa-zuberi/PulseDB)
![Stars](https://img.shields.io/github/stars/Huzaifa-zuberi/PulseDB?style=social)

**Repo:** [Huzaifa-zuberi/PulseDB](https://github.com/Huzaifa-zuberi/PulseDB)

## Screenshots

*(Add a screenshot of the dashboard here)*

Full-stack database project: SQL Server backend + Python Flask API + browser dashboard.

## Project Structure

```
PulseDB/
├── backend/
│   ├── app.py              # Flask REST API (6 endpoints)
│   └── requirements.txt    # Python dependencies
├── database/
│   └── project.sql         # SQL Server schema, data, queries & views
├── frontend/
│   └── index.html          # Single-page dashboard (calls the API)
└── README.md
```

---

## Setup

### 1. Database

1. Open **SQL Server Management Studio**
2. Run `database/project.sql` to create the `PulseDB` database with all tables, seed data, queries, and views

### 2. Backend API

```bash
cd PulseDB/backend
pip install -r requirements.txt
python app.py
```

The API starts at **http://localhost:5000**.

If your SQL Server instance is not `localhost`, edit the `SERVER` variable in `app.py`.

### 3. Frontend

Open `frontend/index.html` in any browser. It connects to the running API at `http://localhost:5000`.

---

## API Endpoints

| Method | Path | Description | SQL Ref |
|--------|------|-------------|---------|
| GET | `/api/songs` | All songs with artist & genre | Q1 |
| GET | `/api/trending` | Top 5 most-streamed songs | Q2 |
| GET | `/api/fans` | Users with 3+ streams | Q3 |
| GET | `/api/users` | User list for dropdown | — |
| GET | `/api/songs/list` | Song list for dropdown | — |
| POST | `/api/stream` | Record a new stream | INSERT |

---

## Dashboard Tabs

| Tab | Description |
|-----|-------------|
| **Browse Library** | Table of all songs loaded from the database |
| **Trending & Analytics** | Top 5 songs + power users with live counts |
| **User Activity Simulator** | Record a stream via the API and watch rankings update in real time |
"# Matchine-Learning" 
"# Matchine-Learning" 
