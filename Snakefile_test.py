import os
import glob


RAW_DIR = "task1"

# Detect available file types
dzip_files = glob.glob(os.path.join(RAW_DIR, "*.d.zip"))
raw_files = glob.glob(os.path.join(RAW_DIR, "*.raw"))

MSCONVERTOPTS = "docker.io/compomics/msconvert:latest"

# Ensure we only have one file type
if dzip_files and raw_files:
    raise ValueError("Error: Both .d.zip and .raw files detected in the same run!")



# Identify sample names dynamically
if dzip_files:
    SAMPLES = [os.path.basename(f).replace(".d.zip", "") for f in dzip_files]
elif raw_files:
    SAMPLES = [os.path.basename(f).replace(".raw", "") for f in raw_files]
else:
    raise ValueError("No valid input files (.d.zip or .raw) found.")
