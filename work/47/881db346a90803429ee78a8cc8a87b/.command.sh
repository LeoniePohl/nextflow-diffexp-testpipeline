#!/bin/bash -euo pipefail
printf "%s %s\n" sample2_R1.fastq.gz SAMPLE2_PE_T1_1.gz sample2_R2.fastq.gz SAMPLE2_PE_T1_2.gz | while read old_name new_name; do
    [ -f "${new_name}" ] || ln -s $old_name $new_name
done

fastqc \
    --quiet \
    --threads 2 \
    SAMPLE2_PE_T1_1.gz SAMPLE2_PE_T1_2.gz

cat <<-END_VERSIONS > versions.yml
"NFCORE_TESTPIPELINE:TESTPIPELINE:FASTQC":
    fastqc: $( fastqc --version | sed -e "s/FastQC v//g" )
END_VERSIONS
