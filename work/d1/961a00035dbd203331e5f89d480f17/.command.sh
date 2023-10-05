#!/bin/bash -euo pipefail
mkdir bwa
bwa \
    index \
     \
    -p bwa/genome \
    genome.fa

cat <<-END_VERSIONS > versions.yml
"NFCORE_TESTPIPELINE:TESTPIPELINE:BWA_INDEX":
    bwa: $(echo $(bwa 2>&1) | sed 's/^.*Version: //; s/Contact:.*$//')
END_VERSIONS
