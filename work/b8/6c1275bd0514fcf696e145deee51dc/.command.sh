#!/bin/bash -euo pipefail
multiqc \
    --force \
     \
    --config multiqc_config.yml \
     \
    .

cat <<-END_VERSIONS > versions.yml
"NFCORE_TESTPIPELINE:TESTPIPELINE:MULTIQC":
    multiqc: $( multiqc --version | sed -e "s/multiqc, version //g" )
END_VERSIONS
