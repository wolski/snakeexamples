import os
import glob

RAW_DIR = "task2_raw"

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


rule all:
    input:
        "results.txt"


###############################################################################
# Rule convert_d_zip: Extracts .d.zip into a .d folder
###############################################################################
rule convert_d_zip:
    input:
        raw_file = os.path.join(RAW_DIR, "{sample}.d.zip")
    output:
        raw_file = os.path.join(RAW_DIR, "{sample}.d")
    shell:
        """
        echo "Extracting {input.raw_file} -> {output.raw_file}"
        cp {input.raw_file} {output.raw_file}
        """

###############################################################################
# Rule convert_raw: Converts .raw to .mzML
###############################################################################

rule convert_raw:
    """
    Convert *.raw -> *.mzML using the 'convert_raw_to_format' command.
    """
    input:
        raw_file = os.path.join(RAW_DIR, "{sample}.raw")
    output:
        raw_file = os.path.join(RAW_DIR, "{sample}.mzML")
    params:
        msconvert = MSCONVERTOPTS
    shell:
        """
        echo "Extracting {input.raw_file} -> {output.raw_file}"
        cp {input.raw_file} {output.raw_file}
        """


###############################################################################
# Helper function: Determine which input file to use
###############################################################################
def get_converted_file(wc):
    """Returns the appropriate input file for downstream analysis."""
    print("Checking for sample:", wc.sample)
    print(dzip_files)
    print(rules.convert_d_zip.output.raw_file)
    if wc.sample in [os.path.basename(f).replace(".d.zip", "") for f in dzip_files]:
        return rules.convert_d_zip.output.raw_file  # Reference the .d folder
    else:
        return rules.convert_raw.output.raw_file  # Reference the .mzML file

def get_converted_file2(sample):
    print("Checking for sample:", sample)
    # Ensure that dzip_files is defined and accessible here.
    if sample in [os.path.basename(f).replace(".d.zip", "") for f in dzip_files]:
        # Format the output file name with the sample value.
        return rules.convert_d_zip.output.raw_file.format(sample=sample)
    else:
        return rules.convert_raw.output.raw_file.format(sample=sample)

rule downstream_analysis:
    input:
        [get_converted_file2(sample) for sample in SAMPLES]
        # get_converted_file  # Dynamically determines input
    output:
        "results.txt"
        #"results/{sample}.analysis"
    shell:
        """
        echo "Running analysis on {input} -> {output}"
        touch {output}
        """

