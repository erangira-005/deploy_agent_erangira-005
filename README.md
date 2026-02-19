
     Video Link: https://drive.google.com/file/d/1dkGwtwTcPUzkor3ornKN-biIMnUpsOnB/view?usp=sharing
     
     
                                     Attendance Tracker System

This approach demonstrates Infrastructure as Code (IaC) principles by automating reproducible environment setup.

An automated attendance tracking setup script that initializes a structured project workspace, generates configuration files and CSV datasets, and validates the environment. Includes safe interruption handling with archiving of incomplete projects.

Project Structure

attendance_tracker_<PROJECT_NAME>/
├── attendance_checker.py          # Main Python script (provided)
├── Helpers/
│   ├── assets.csv                 # Student attendance data
│   └── config.json                # Thresholds and configuration
└── reports/
    └── reports.log                # Attendance reports log

        Components

  Python Application

attendance_checker.py — Provided Python script that processes attendance data and generates alerts.

  Bash Script

setup_project.sh — Interactive setup script that:

Creates project structure

Generates required files

Allows threshold customization

Validates environment and Python availability

Handles interruptions safely (trap with SIGINT)

        Setup and Usage

   1. Make Script Executable

chmod +x setup_project.sh


This ensures the script can be run in the terminal.

   2. Initialize Project

Run the script with a project/environment name:

./setup_project.sh dev


dev is the project/environment name.

Creates a folder named attendance_tracker_dev.

     3. Optional: Change Thresholds

During setup, you may update:

Warning threshold

Failure threshold

Input is validated to ensure numeric values and failure < warning.
Updated values are saved in Helpers/config.json.

      4. Trigger Archive Feature

To test safe interruption:

Run:

./setup_project.sh dev


Press Ctrl + C before the script completes (for example, immediately after running it).

       Observe:

An archive file is created: attendance_tracker_dev_archive.tar.gz

Naming convention: attendance_tracker_<PROJECT_NAME>_archive.tar.gz

The incomplete project directory is removed

      Explanation:
The trap command captures the SIGINT signal (Ctrl + C) to ensure the workspace remains clean even if execution is interrupted.

   5. Environment Health Check

The script performs:

Python availability check:

python3 --version


The script runs python3 --version and evaluates its exit status to determine if Python is installed.

      Directory and file verification:
Ensures all required files and folders exist:

attendance_checker.py

Helpers/assets.csv

Helpers/config.json

reports/reports.log

CSV & Configuration Files

            assets.csv
  
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0

config.json
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}

  Features

Error Handling
Safe interruption handling (trap SIGINT)
Numeric validation for thresholds
Checks for missing files/directories
Automation
Automatic folder structure creation
Automatic CSV and config generation
Automatic creation of reports.log
Threshold Management
Warning and Failure thresholds configurable
Simple but safe input validation
Updated config saved automatically

    Usage Examples

Change Thresholds

$ ./setup_project.sh dev
Do you want to change thresholds? (y/n): y
Enter new Warning threshold (1-100): 80
Enter new Failure threshold (must be less than Warning): 60
Thresholds updated successfully.

Trigger Archive Feature

$ ./setup_project.sh dev 
Press Ctrl + c before the script completes


        Observe:

attendance_tracker_dev_archive.tar.gz created

Incomplete project removed

            Objectives Achieved

Shell Scripting Proficiency

Interactive prompts and loops

File operations (mkdir, touch, cat, sed)

Safe interrupt handling (trap)

Automation & Project Initialization

Structured folder creation

Automatic generation of CSV and JSON files

Configurable thresholds

Environment Validation

Python availability check

Directory and file integrity verification

Safe archival of incomplete projects

Infrastructure as Code

Reproducible, automated environment setup

Version-controllable folder and file structure


