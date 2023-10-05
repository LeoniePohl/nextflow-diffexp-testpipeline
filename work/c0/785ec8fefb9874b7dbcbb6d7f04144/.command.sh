#!/bin/bash -euo pipefail
bcftools \
    mpileup \
    --fasta-ref genome.fa \
    -Oz \
    sample_paired_end_T1.bam \
    | bcftools call --output-type v -mv -Oz \
    | bcftools view --output-file sample_paired_end_T1.vcf.gz --output-type z

tabix -p vcf -f sample_paired_end_T1.vcf.gz

bcftools stats sample_paired_end_T1.vcf.gz > sample_paired_end_T1.bcftools_stats.txt

cat <<-END_VERSIONS > versions.yml
"NFCORE_TESTPIPELINE:TESTPIPELINE:BCFTOOLS_MPILEUP":
    bcftools: $(bcftools --version 2>&1 | head -n1 | sed 's/^.*bcftools //; s/ .*$//')
END_VERSIONS
