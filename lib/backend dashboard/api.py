from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import sqlite3
import uvicorn

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/patients")
def get_patient_status():
    conn = sqlite3.connect("hospital.db")
    conn.row_factory = sqlite3.Row
    c = conn.cursor()

    c.execute("""
        SELECT p.full_name, p.patient_id, v.* FROM patients p 
        JOIN vitals v ON p.patient_id = v.patient_id 
        ORDER BY v.id DESC LIMIT 1
    """)
    row = c.fetchone()
    conn.close()

    if row:
        return [{
            "patient_id": row["patient_id"],
            "full_name": row["full_name"],
            "heart_rate_bpm": row["heart_rate_bpm"],
            "temperature_c": row["temperature_c"],
            "spo2_percent": row["spo2_percent"],
            "steps": row["steps"],  # ✅ SEND STEPS TO APP
            "health_status": row["health_status"],
            "risk_level": row["risk_level"],
            "confidence": row["confidence"]
        }]
    return []

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)