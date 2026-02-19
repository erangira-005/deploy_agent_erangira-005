#!/bin/bash

# Ask the user for project name
read -p "Enter project name: " INPUT

if [ -z "$INPUT" ]; then
    echo "You must provide a project name."
    exit 1
fi

PROJECT_DIR="attendance_tracker_${INPUT}"

echo "Project directory will be: $PROJECT_DIR"


# Cleanup function (Ctrl + C protection)
cleanup() {
    echo ""
    echo "Interrupted! Cleaning up..."

    if [ -d "$PROJECT_DIR" ]; then
        tar -czf "${PROJECT_DIR}_archive.tar.gz" "$PROJECT_DIR"
        rm -rf "$PROJECT_DIR"
        echo "Project archived and removed."
    else
        echo "No project directory to clean."
    fi

    exit 1
}

trap cleanup SIGINT


# Prevent overwrite
if [ -d "$PROJECT_DIR" ]; then
    echo "Error: Project already exists."
    exit 1
fi


# Create folder structure
mkdir "$PROJECT_DIR"
mkdir "$PROJECT_DIR/Helpers"
mkdir "$PROJECT_DIR/reports"

echo "Project structure created successfully."


# ✅ Correct CSV Format (Comma-separated)
cat << EOF > "$PROJECT_DIR/Helpers/assets.csv"
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF


# Create config.json
cat << EOF > "$PROJECT_DIR/Helpers/config.json"
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF


# Create attendance_checker.py (provided content assumed)
cat << EOF > "$PROJECT_DIR/attendance_checker.py"

import csv
import json
import os
from datetime import datetime
def run_attendance_check():
# 1. Load Config
with open('Helpers/config.json', 'r') as f:
config = json.load(f)
# 2. Archive old reports.log if it exists
if os.path.exists('reports/reports.log'):
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
os.rename('reports/reports.log',
f'reports/reports_{timestamp}.log.archive')
# 3. Process Data
with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log',
'w') as log:
reader = csv.DictReader(f)
total_sessions = config['total_sessions']
log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
for row in reader:
name = row['Names']
email = row['Email']
attended = int(row['Attendance Count'])
# Simple Math: (Attended / Total) * 100
attendance_pct = (attended / total_sessions) * 100
message = ""
if attendance_pct < config['thresholds']['failure']:
message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}
%. You will fail this class."
elif attendance_pct < config['thresholds']['warning']:
message = f"WARNING: {name}, your attendance is
{attendance_pct:.1f}%. Please be careful."
if message:
if config['run_mode'] == "live":
log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}
\n")
print(f"Logged alert for {name}")
else:
print(f"[DRY RUN] Email to {email}: {message}")
if __name__ == "__main__":
run_attendance_check()

EOF


touch "$PROJECT_DIR/reports/reports.log"


# Threshold configuration
read -p "Do you want to change thresholds? (y/n): " choice

if [ "$choice" == "y" ]; then

    # Safe numeric validation for Warning
    while true; do
        read -p "Enter new Warning threshold (1-100): " new_warning

        if [[ "$new_warning" =~ ^[0-9]+$ ]]; then
            if [ "$new_warning" -ge 1 ] && [ "$new_warning" -le 100 ]; then
                break
            fi
        fi

        echo "Please enter a valid number between 1 and 100."
    done

    # Safe numeric validation for Failure
    while true; do
        read -p "Enter new Failure threshold (must be less than Warning): " new_failure

        if [[ "$new_failure" =~ ^[0-9]+$ ]]; then
            if [ "$new_failure" -ge 1 ] && [ "$new_failure" -lt "$new_warning" ]; then
                break
            fi
        fi

        echo "Failure must be a valid number less than Warning threshold."
    done

    sed -i "s/\"warning\": [0-9]*/\"warning\": $new_warning/" "$PROJECT_DIR/Helpers/config.json"
    sed -i "s/\"failure\": [0-9]*/\"failure\": $new_failure/" "$PROJECT_DIR/Helpers/config.json"

    echo "Thresholds updated successfully."
fi


# Simple Environment Health Check
echo ""
echo "===== ENVIRONMENT HEALTH CHECK ====="
echo ""

echo "[1] Checking Python installation..."

if command -v python3 > /dev/null; then
    echo "Python is installed "
else
    echo "Python is NOT installed "
fi

echo ""

echo "[2] Checking project structure..."

items=(
"$PROJECT_DIR"
"$PROJECT_DIR/attendance_checker.py"
"$PROJECT_DIR/Helpers"
"$PROJECT_DIR/Helpers/assets.csv"
"$PROJECT_DIR/Helpers/config.json"
"$PROJECT_DIR/reports"
"$PROJECT_DIR/reports/reports.log"
)

all_ok=true

for item in "${items[@]}"; do
    if [ -e "$item" ]; then
        echo "Found: $item"
    else
        echo "Missing: $item"
        all_ok=false
    fi
done

echo ""

if [ "$all_ok" = true ]; then
    echo "Health Check Passed "
else
    echo "Health Check Finished With Warnings "
fi
