#!/bin/bash -euo pipefail
INDEX=`find -L ./ -name "*.amb" | sed 's/\.amb$//'`

bwa mem \
     \
    -t 2 \
    $INDEX \
    WES_LL_T_1_test_1.merged.fastq.gz WES_LL_T_1_test_2.merged.fastq.gz \
    | samtools sort  --threads 2 -o sample_paired_end_T1.bam -

cat <<-END_VERSIONS > versions.yml
"NFCORE_TESTPIPELINE:TESTPIPELINE:BWA_MEM":
    bwa: $(echo $(bwa 2>&1) | sed 's/^.*Version: //; s/Contact:.*$//')
    samtools: $(echo $(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*$//')
END_VERSIONS
