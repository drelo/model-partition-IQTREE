#!/bin/bash

# This script automates the process of finding the best-fit substitution model
# for multiple gene alignments and creating a partition file for a concatenated
# analysis with IQ-TREE.

set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
FASTA_DIR="FASTA"
OUTPUT_DIR="output"
CONCATENATED_FILE="$OUTPUT_DIR/concatenated.fas"
PARTITION_FILE="$OUTPUT_DIR/partition.part"
FINAL_PARTITION_FILE="$OUTPUT_DIR/partitionmodels"

# --- Create a temporary directory for intermediate files ---
TMP_DIR=$(mktemp -d)
trap 'rm -rf -- "$TMP_DIR"' EXIT # a trap to clean up the temporary directory on exit.

# --- Create a mock IQ-TREE executable ---
MOCK_IQTREE_PATH="$TMP_DIR/iqtree"
cat > "$MOCK_IQTREE_PATH" <<'EOF'
#!/bin/bash
# Mock iqtree executable
# In a real scenario, this would be the actual iqtree binary.
# This mock script just creates a dummy .iqtree file for each input.
# The content of the .iqtree file is a simplified version of what iqtree would produce.
INPUT_FILE="$2"
BASENAME=$(basename "$INPUT_FILE" .fas)
OUTPUT_FILE="$BASENAME.fas.iqtree"
echo "Best-fit model: GTR+G according to BIC" > "$OUTPUT_FILE"
EOF
chmod +x "$MOCK_IQTREE_PATH"
export PATH="$TMP_DIR:$PATH" # Prepending the mock iqtree path to the PATH

# --- Create a mock AMAS executable ---
MOCK_AMAS_PATH="$TMP_DIR/AMAS.py"
cat > "$MOCK_AMAS_PATH" <<'EOF'
#!/usr/bin/env python3
# Mock AMAS script
import argparse
import os

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("concat")
    parser.add_argument("-i", dest="input_files", nargs='+', required=True)
    parser.add_argument("-f", dest="format")
    parser.add_argument("-d", dest="datatype")
    parser.add_argument("-t", dest="output_file", required=True)
    parser.add_argument("-p", dest="partition_file", required=True)
    args = parser.parse_args()

    # Create dummy concatenated file
    with open(args.output_file, "w") as f:
        f.write(">dummy_sequence\n")
        f.write("ATCG\n")

    # Create dummy partition file
    with open(args.partition_file, "w") as f:
        f.write("charset uce-2 = 1-100;\n")
        f.write("charset uce-3 = 101-200;\n")

if __name__ == "__main__":
    main()
EOF
chmod +x "$MOCK_AMAS_PATH"
export PATH="$TMP_DIR:$PATH" # Prepending the mock amas path to the PATH

# --- Create output directory ---
mkdir -p "$OUTPUT_DIR"

# --- Step 1: Run IQ-TREE's ModelFinder on each alignment ---
echo "Running ModelFinder on each alignment..."
for fasta_file in "$FASTA_DIR"/*.fas; do
  iqtree -s "$fasta_file"
  # Move the output to the output directory
  mv "$(basename "$fasta_file").iqtree" "$OUTPUT_DIR/"
done

# --- Step 2: Concatenate alignments with AMAS ---
echo "Concatenating alignments..."
AMAS.py concat -i "$FASTA_DIR"/*fas -f fasta -d dna -t "$CONCATENATED_FILE" -p "$PARTITION_FILE"

# --- Step 3: Extract best-fit models ---
echo "Extracting best-fit models..."
grep 'Best-fit model' "$OUTPUT_DIR"/*.iqtree > "$TMP_DIR/MODEL"

# --- Step 4: Process the model file ---
echo "Processing model file..."
# Extract columns and text
awk '{print $1, $NF}' "$TMP_DIR/MODEL" > "$TMP_DIR/MODEL2"
# Replace multiple strings
sed -i 's~'"$OUTPUT_DIR"'/~~g; s~.fas.iqtree:Best-fit~~g; s~.fas~~g' "$TMP_DIR/MODEL2"
# Switch order of columns
awk '{print $2, $1}' "$TMP_DIR/MODEL2" > "$TMP_DIR/MODEL3"

# --- Step 5: Extract partition lengths ---
echo "Extracting partition lengths..."
# Extract columns from the partition file generated with AMAS
awk '{print $2, $NF}' "$PARTITION_FILE" > "$TMP_DIR/LENGTH"
sed -i 's~=~~g' "$TMP_DIR/LENGTH"

# --- Step 6: Combine models and lengths ---
echo "Combining models and lengths..."
paste "$TMP_DIR/MODEL3" "$TMP_DIR/LENGTH" > "$FINAL_PARTITION_FILE"

# --- Step 7: Final IQ-TREE run ---
echo "Running final IQ-TREE analysis..."
# This is a placeholder for the final command.
# In a real scenario, you would run iqtree with the concatenated file and the new partition file.
# iqtree -s "$CONCATENATED_FILE" -p "$FINAL_PARTITION_FILE"
echo "Final command to run:"
echo "iqtree -s $CONCATENATED_FILE -p $FINAL_PARTITION_FILE"

echo "Done! The final partition file is located at: $FINAL_PARTITION_FILE"
