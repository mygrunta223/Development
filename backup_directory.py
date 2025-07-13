# This is a Python script to back up a directory to a specified backup location.
# My first ever python script, so please be gentle with me.
# -*- coding: utf-8 -*-
"""# backup_directory.py
This script backs up a specified directory to a backup location with a timestamp.
This is a simple utility to create backups of important directories, ensuring that the contents are preserved with a timestamp for easy identification.
"""
import os
import shutil
from datetime import datetime
def backup_directory(source_dir, backup_dir):
"""
Back up the specified directory to a backup location.
:param source_dir: 
:param backup_dir: The directory where backups will be stored.
"""
# Check if the source directory exists
if not os.path.exists(source_dir):
raise Exception(f"The source directory {source_dir} does not exist.")

# Check if the backup directory exists, create it if it doesn't
if not os.path.exists(backup_dir):
    try:
        os.makedirs(backup_dir)
        print(f"Backup directory '{backup_dir}' created.")
    except Exception as e:
        raise Exception(f"Failed to create backup directory '{backup_dir}': {e}")      

# Create a timestamped backup directory
timestamp = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
backup_subdir = os.path.join(backup_dir, f"backup_{timestamp}")
os.makedirs(backup_subdir, exist_ok=True)

# Copy the contents of the source directory to the backup directory
try:
shutil.copytree(source_dir, backup_subdir)
print(f"Backup of '{source_dir}' was successfully created at '{backup_subdir}'.")
except Exception as e:
print(f"Failed to back up '{source_dir}' to '{backup_subdir}': {e}")
# -*- coding: utf-8 -*-
"""# backup_directory.python
# Example usage of the backup_directory function.
"""
# Example usage
#source_directory = 'C:\Users\dhjac\OneDrive\Documents\Development\testing\SourceDIR'
#backup_directory = 'I:\TheHereAndNow\2025'

backup_directory(source_directory, backup_directory)