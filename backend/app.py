import os
import pyodbc
from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS

app = Flask(__name__)
CORS(app, origins=["*", "null"], supports_credentials=True, methods=["GET", "POST", "OPTIONS"], allow_headers=["Content-Type"])

# ─── Database connection ──────────────────────────────────────────────
import sys
SERVER = ".\\SQLEXPRESS"
DATABASE = "PulseDB"

def get_db():
    # Use lpc: (Shared Memory) protocol — fastest for local connections.
    # Named Pipes and TCP/IP are not configured on this SQL Server instance.
    conn = pyodbc.connect(
        "DRIVER={ODBC Driver 17 for SQL Server};"
        "SERVER=lpc:" + SERVER + ";"
        f"DATABASE={DATABASE};"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=Yes;"
    )
    return conn

# ─── GET /api/songs  —  Browse Library (Q1) ──────────────────────────
@app.route("/api/songs")
def get_songs():
    conn = get_db()
    rows = conn.execute("""
        SELECT s.SongID, s.Title, a.StageName AS Artist, a.Genre
        FROM Song s
        JOIN Artist a ON s.ArtistID = a.ArtistID
        ORDER BY a.StageName, s.Title
    """).fetchall()
    conn.close()
    return jsonify([
        {"id": r.SongID, "title": r.Title, "artist": r.Artist, "genre": r.Genre}
        for r in rows
    ])

# ─── GET /api/trending  —  Top 5 Songs (Q2) ──────────────────────────
@app.route("/api/trending")
def get_trending():
    conn = get_db()
    rows = conn.execute("""
        SELECT TOP 5 s.Title, a.StageName AS Artist, a.Genre, COUNT(*) AS TotalStreams
        FROM StreamHistory sh
        JOIN Song s   ON sh.SongID = s.SongID
        JOIN Artist a ON s.ArtistID = a.ArtistID
        GROUP BY s.Title, a.StageName, a.Genre
        ORDER BY TotalStreams DESC
    """).fetchall()
    conn.close()
    return jsonify([
        {"title": r.Title, "artist": r.Artist, "genre": r.Genre, "streams": r.TotalStreams}
        for r in rows
    ])

# ─── GET /api/fans  —  Power Listeners (Q3) ──────────────────────────
@app.route("/api/fans")
def get_fans():
    conn = get_db()
    rows = conn.execute("""
        SELECT u.Username, u.Email, u.Country, u.PlanType, COUNT(*) AS StreamCount
        FROM StreamHistory sh
        JOIN [User] u ON sh.UserID = u.UserID
        GROUP BY u.Username, u.Email, u.Country, u.PlanType
        HAVING COUNT(*) >= 3
        ORDER BY StreamCount DESC
    """).fetchall()
    conn.close()
    return jsonify([
        {"username": r.Username, "email": r.Email, "country": r.Country, "plan": r.PlanType, "streams": r.StreamCount}
        for r in rows
    ])

# ─── GET /api/users  —  full list (for management) ───────────────────
@app.route("/api/users")
def get_users():
    conn = get_db()
    rows = conn.execute("SELECT UserID, Username, Email, Country, PlanType FROM [User] ORDER BY UserID").fetchall()
    conn.close()
    return jsonify([{"id": r.UserID, "name": r.Username, "email": r.Email, "country": r.Country, "plan": r.PlanType} for r in rows])

# ─── POST /api/users  —  add a new user ──────────────────────────────
@app.route("/api/users", methods=["POST"])
def add_user():
    data = request.get_json()
    username = data["username"]
    email = data["email"]
    country = data["country"]
    plan = data.get("plan", "Free")
    conn = get_db()
    cur = conn.execute("SELECT ISNULL(MAX(UserID), 0) + 1 FROM [User]")
    next_id = cur.fetchone()[0]
    conn.execute(
        "INSERT INTO [User] (UserID, Username, Email, Country, PlanType, JoinDate) VALUES (?, ?, ?, ?, ?, GETDATE())",
        next_id, username, email, country, plan
    )
    conn.commit()
    conn.close()
    return jsonify({"status": "ok", "id": next_id})

# ─── DELETE /api/users/<id>  —  delete a user ───────────────────────
@app.route("/api/users/<int:uid>", methods=["DELETE"])
def delete_user(uid):
    conn = get_db()
    conn.execute("DELETE FROM StreamHistory WHERE UserID = ?", uid)
    conn.execute("DELETE FROM Playlist WHERE UserID = ?", uid)
    conn.execute("DELETE FROM [User] WHERE UserID = ?", uid)
    conn.commit()
    conn.close()
    return jsonify({"status": "ok"})

# ─── PUT /api/users/<id>  —  update a user ──────────────────────────
@app.route("/api/users/<int:uid>", methods=["PUT"])
def update_user(uid):
    data = request.get_json()
    conn = get_db()
    conn.execute(
        "UPDATE [User] SET Username=?, Email=?, Country=?, PlanType=? WHERE UserID=?",
        data["username"], data["email"], data["country"], data.get("plan", "Free"), uid
    )
    conn.commit()
    conn.close()
    return jsonify({"status": "ok"})

# ─── GET /api/artists  —  full list (for management) ────────────────
@app.route("/api/artists")
def get_artists():
    conn = get_db()
    rows = conn.execute("SELECT ArtistID, StageName, Genre, Country, MonthlyListeners FROM Artist ORDER BY ArtistID").fetchall()
    conn.close()
    return jsonify([{"id": r.ArtistID, "name": r.StageName, "genre": r.Genre, "country": r.Country, "listeners": r.MonthlyListeners} for r in rows])

# ─── POST /api/artists  —  add an artist ────────────────────────────
@app.route("/api/artists", methods=["POST"])
def add_artist():
    data = request.get_json()
    conn = get_db()
    cur = conn.execute("SELECT ISNULL(MAX(ArtistID), 0) + 1 FROM Artist")
    next_id = cur.fetchone()[0]
    conn.execute(
        "INSERT INTO Artist (ArtistID, StageName, Genre, Country, MonthlyListeners) VALUES (?, ?, ?, ?, ?)",
        next_id, data["name"], data["genre"], data["country"], data.get("listeners", 0)
    )
    conn.commit()
    conn.close()
    return jsonify({"status": "ok", "id": next_id})

# ─── PUT /api/artists/<id>  —  update an artist ─────────────────────
@app.route("/api/artists/<int:aid>", methods=["PUT"])
def update_artist(aid):
    data = request.get_json()
    conn = get_db()
    conn.execute(
        "UPDATE Artist SET StageName=?, Genre=?, Country=?, MonthlyListeners=? WHERE ArtistID=?",
        data["name"], data["genre"], data["country"], data.get("listeners", 0), aid
    )
    conn.commit()
    conn.close()
    return jsonify({"status": "ok"})

# ─── DELETE /api/artists/<id>  —  delete an artist ──────────────────
@app.route("/api/artists/<int:aid>", methods=["DELETE"])
def delete_artist(aid):
    conn = get_db()
    conn.execute("DELETE FROM StreamHistory WHERE SongID IN (SELECT SongID FROM Song WHERE ArtistID = ?)", aid)
    conn.execute("DELETE FROM Song WHERE ArtistID = ?", aid)
    conn.execute("DELETE FROM Artist WHERE ArtistID = ?", aid)
    conn.commit()
    conn.close()
    return jsonify({"status": "ok"})

# ─── GET /api/songs/list  —  dropdown list ──────────────────────────
@app.route("/api/songs/list")
def get_song_list():
    conn = get_db()
    rows = conn.execute("""
        SELECT s.SongID, s.Title, a.StageName
        FROM Song s
        JOIN Artist a ON s.ArtistID = a.ArtistID
        ORDER BY s.Title
    """).fetchall()
    conn.close()
    return jsonify([{"id": r.SongID, "title": r.Title, "artist": r.StageName} for r in rows])

# ─── POST /api/stream  —  record a stream ────────────────────────────
@app.route("/api/stream", methods=["POST"])
def record_stream():
    data = request.get_json()
    uid = data["userId"]
    sid = data["songId"]
    device = data["deviceType"]

    conn = get_db()
    cur = conn.execute("SELECT ISNULL(MAX(StreamID), 0) + 1 FROM StreamHistory")
    next_id = cur.fetchone()[0]
    conn.execute(
        "INSERT INTO StreamHistory (StreamID, UserID, SongID, StreamedAt, DeviceType) VALUES (?, ?, ?, GETDATE(), ?)",
        next_id, uid, sid, device
    )
    conn.commit()
    conn.close()
    return jsonify({"status": "ok", "streamId": next_id})

# Serve the frontend at / so file:// CORS issues are avoided
FRONTEND_DIR = os.path.join(os.path.dirname(__file__), "..", "frontend")

@app.route("/")
def index():
    return send_from_directory(FRONTEND_DIR, "index.html")

@app.errorhandler(500)
def handle_500(e):
    return jsonify({"error": str(e.original_exception if hasattr(e, 'original_exception') else e)}), 500

if __name__ == "__main__":
    app.run(port=5000, debug=True)