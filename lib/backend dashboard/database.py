# database.py - UPDATED VERSION WITH STEPS
import sqlite3

def create_db():
    conn = sqlite3.connect("hospital.db")
    c = conn.cursor()

    # Drop old tables to ensure a fresh start
    c.executescript("""
        DROP TABLE IF EXISTS vitals;
        DROP TABLE IF EXISTS patients;

        CREATE TABLE patients (
            patient_id TEXT PRIMARY KEY,
            full_name TEXT
        );

        CREATE TABLE vitals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            patient_id TEXT,
            heart_rate_bpm INTEGER,
            temperature_c REAL,
            spo2_percent INTEGER,
            steps INTEGER,              -- ✅ THIS IS THE MISSING COLUMN
            health_status TEXT,
            risk_level TEXT,
            confidence REAL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        );
    """)

    # Insert Patient P001
    c.execute("INSERT INTO patients VALUES ('P001', 'John Doe')")

    # Insert initial dummy data
    c.execute("""
        INSERT INTO vitals (patient_id, heart_rate_bpm, temperature_c, spo2_percent, steps, health_status, risk_level, confidence)
        VALUES ('P001', 72, 36.5, 98, 5000, 'NORMAL', 'Low Risk', 0.1)
    """)

    conn.commit()
    conn.close()
    print("✅ Database created successfully with 'steps' column.")

if __name__ == "__main__":
    create_db()