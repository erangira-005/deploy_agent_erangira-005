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
# attendance_checker.py
# (Provided file content assumed up to date)
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
