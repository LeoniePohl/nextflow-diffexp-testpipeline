#!/bin/bash -euo pipefail
INDEX=`find -L ./ -name "*.amb" | sed 's/\.amb$//'`

bwa mem \
     \
    -t 2 \
    $INDEX \
    sample2_R1.fastq.gz \
    | samtools sort  --threads 2 -o SAMPLE3_SE_T2.bam -

cat <<-END_VERSIONS > versions.yml
"NFCORE_TESTPIPELINE:TESTPIPELINE:BWA_MEM":
    bwa: $(echo $(bwa 2>&1) | sed 's/^.*Version: //; s/Contact:.*$//')
    samtools: $(echo $(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*$//')
END_VERSIONS
