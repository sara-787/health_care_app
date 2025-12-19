import subprocess
import time
import sys
import os
#cd "lib\backend dashboard"
# Ensure we are in the correct directory
os.chdir(os.path.dirname(os.path.abspath(__file__)))

print("--- HEALTHCARE BACKEND STARTING ---")

# 1. Create DB
subprocess.run([sys.executable, "database.py"])

# 2. Start Simulator (in background)
sim_process = subprocess.Popen([sys.executable, "data_simulator.py"])

# 3. Start API (in background)
api_process = subprocess.Popen([sys.executable, "api.py"])

print("✅ Backend Running!")
print("   API: http://127.0.0.1:8000/patients")
print("   Press Ctrl+C to stop.")

try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    print("\nStopping services...")
    sim_process.terminate()
    api_process.terminate()
