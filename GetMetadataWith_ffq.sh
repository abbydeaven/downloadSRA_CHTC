#!/bin/bash

set -euo pipefail

##This script takes an input of SRR accession #s one per line. For each accessiob. Edit last line to include path to your list of accessions.
#Your accession file should include one accession per line with no other information.

echo "===== Fetching metadata for: ${accession} ====="
echo "Host: $(hostname)"
echo "Date: $(date)"

mkdir -p ${outdir}
mkdir -p ${outdir}/${accession}

# Fetch metadata as JSON via ffq (--ftp returns EBI FTP urls suitable for curl)
ffq -o "${outdir}/${accession}/${accession}.json" --ftp "${accession}"

echo "===== Done: ${accession} ====="
