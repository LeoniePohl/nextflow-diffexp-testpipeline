#!/bin/bash -euo pipefail
check_samplesheet.py \
    samplesheet_test_illumina_amplicon.csv \
    samplesheet.valid.csv

cat <<-END_VERSIONS > versions.yml
"NFCORE_TESTPIPELINE:TESTPIPELINE:INPUT_CHECK:SAMPLESHEET_CHECK":
    python: $(python --version | sed 's/Python //g')
END_VERSIONS
