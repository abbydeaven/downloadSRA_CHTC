#!/bin/bash
# downloadFastq.sh  –  Download fastq.gz files using URLs from ffq JSON metadata
# CHTC/HTCondor version; replaces curlFastq.sh (UGA)
#
# Variables injected by HTCondor via downloadFastq.sub:
#   accession  – SRR accession number (e.g. SRR5177530)
#   outdir     – path to FastqFiles directory on /staging
 
set -euo pipefail
 
echo "===== Downloading fastq for: ${accession} ====="
echo "Host: $(hostname)"
echo "Date: $(date)"
 
json="${outdir}/${accession}/${accession}.json"
 
# Confirm metadata file exists before proceeding
if [[ ! -f "${json}" ]]; then
    echo "ERROR: JSON metadata file not found at ${json}" >&2
    echo "Run getMetadata.sub first." >&2
    exit 1
fi
 
cd "${outdir}/${accession}"
 
# Extract FTP urls from JSON and download each one
# Retries up to 3 times on failure, resuming partial downloads with -C -
urls=$(grep -Eo '"url": "[^"]*"' "${json}" | grep -o '"[^"]*"$' | tr -d '"')
 
if [[ -z "$urls" ]]; then
    echo "ERROR: No URLs found in ${json}" >&2
    exit 1
fi
 
for url in $urls; do
    echo "Downloading: ${url}"
 
    # Attempt 1
    curl -sS -C - -O "${url}" && continue
 
    echo "Attempt 1 failed for ${url}, retrying..."
 
    # Attempt 2
    curl -sS -C - -O "${url}" && continue
 
    echo "Attempt 2 failed for ${url}, retrying..."
 
    # Attempt 3
    curl -sS -C - -O "${url}"
 
    if [[ $? -ne 0 ]]; then
        echo "ERROR: All 3 download attempts failed for ${url}" >&2
        exit 1
    fi
done
 
echo "===== Finished: ${accession} ====="
 
