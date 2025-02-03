from pathlib import Path


# Constants
RAW_DIR = Path("task2_raw")
MSCONVERT_OPTS = "docker.io/compomics/msconvert:latest"

# Detect available file types
dzip_files = list(RAW_DIR.glob("*.d.zip"))
raw_files = list(RAW_DIR.glob("*.raw"))

# Ensure we only have one file type
if dzip_files and raw_files:
    raise ValueError("Error: Both .d.zip and .raw files detected in the same run!")

# Identify sample names dynamically
if dzip_files:
    SAMPLES = [f.stem.removesuffix(".d") for f in dzip_files]
elif raw_files:
    SAMPLES = [f.stem for f in raw_files]
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
        raw_file=RAW_DIR / "{sample}.d.zip"
    output:
        raw_file=RAW_DIR / "{sample}.d"
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
        raw_file=RAW_DIR / "{sample}.raw"
    output:
        raw_file=RAW_DIR / "{sample}.mzML"
    params:
        msconvert=MSCONVERT_OPTS
    shell:
        """
        echo "Extracting {input.raw_file} -> {output.raw_file}"
        cp {input.raw_file} {output.raw_file}
        """


###############################################################################
# Helper functions: Determine which input file to use
###############################################################################
def get_converted_file(sample : str):
    """Returns the formatted output file path for a given sample."""
    print(f"Checking for sample: {sample}")

    if dzip_files:
        return rules.convert_d_zip.output.raw_file.format(sample=sample)
    return rules.convert_raw.output.raw_file.format(sample=sample)

rule downstream_analysis:
    input:
        [get_converted_file(sample) for sample in SAMPLES]
    output:
        "results.txt"
    shell:
        """
        echo "Running analysis on {input} -> {output}"
        touch {output}
        """