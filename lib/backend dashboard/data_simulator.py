import sqlite3
import time
import random

def run_simulator():
    print("🚀 Realistic Simulator Started... (Press Ctrl+C to stop)")

    # 1. Initialize "State" (Where we start)
    current_hr = 75
    current_temp = 37.0
    current_steps = 5200  # Start here

    while True:
        conn = sqlite3.connect("hospital.db")
        c = conn.cursor()

        # --- A. HEART RATE LOGIC (Smooth Wave) ---
        # Change by a small amount (-2 to +3)
        change = random.randint(-2, 3)
        current_hr += change

        # "Clamp" the values so they don't drift too far (Keep between 60 and 100 for normal)
        if current_hr > 100: current_hr -= 3
        if current_hr < 60:  current_hr += 3

        # --- B. STEPS LOGIC (Always Increasing) ---
        # 30% chance to take steps (simulates walking occasionally)
        if random.random() < 0.3:
            current_steps += random.randint(1, 5)

        # --- C. TEMPERATURE LOGIC (Very slow change) ---
        current_temp += random.uniform(-0.1, 0.1)
        current_temp = round(current_temp, 1)

        # --- D. CRITICAL EVENTS (Optional override) ---
        # 5% chance of a short spike, but even spikes should look somewhat connected
        status = "NORMAL"
        risk = "Low Risk"
        conf = 0.1

        if random.random() < 0.05:
            # Force a temporary spike
            current_hr = random.randint(110, 130)
            status = "WARNING"
            risk = "Moderate Risk"
            conf = 0.65

        # Update the database
        c.execute("""
            INSERT INTO vitals (patient_id, heart_rate_bpm, temperature_c, spo2_percent, steps, health_status, risk_level, confidence)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, ('P001', current_hr, current_temp, 98, current_steps, status, risk, conf))

        conn.commit()
        conn.close()

        print(f"Update: HR={current_hr} (Smooth), Steps={current_steps} (Increasing)")
        time.sleep(3)

if __name__ == "__main__":
    run_simulator()