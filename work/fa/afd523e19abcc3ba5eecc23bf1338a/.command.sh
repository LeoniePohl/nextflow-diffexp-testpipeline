#!/bin/bash -euo pipefail
printf "%s %s\n" WES_LL_T_1_test_1.merged.fastq.gz sample_paired_end_T1_1.gz WES_LL_T_1_test_2.merged.fastq.gz sample_paired_end_T1_2.gz | while read old_name new_name; do
    [ -f "${new_name}" ] || ln -s $old_name $new_name
done

fastqc \
    --quiet \
    --threads 2 \
    sample_paired_end_T1_1.gz sample_paired_end_T1_2.gz

cat <<-END_VERSIONS > versions.yml
"NFCORE_TESTPIPELINE:TESTPIPELINE:FASTQC":
    fastqc: $( fastqc --version | sed -e "s/FastQC v//g" )
END_VERSIONS
