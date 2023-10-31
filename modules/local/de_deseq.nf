process DESEQ2_DIFFERENTIAL {
    tag "$meta"
    label 'process_medium'

    conda "bioconda::bioconductor-deseq2=1.34.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bioconductor-deseq2:1.34.0--r41hc247a5b_3' :
        'biocontainers/bioconductor-deseq2:1.34.0--r41hc247a5b_3' }"

    input:
    file exprsFile
    file pdatFile
    file fdatFile
    string deMethod
    path outFile
    //tuple val(meta), val(contrast_variable), val(reference), val(target)
    //tuple val(meta2), path(samplesheet), path(counts)
    //tuple val(control_genes_meta), path(control_genes_file)

    output:
    tuple val(meta), path("*.deseq2.results.tsv")              , emit: results

    when:
    task.ext.when == null || task.ext.when

    script:
    'de_deseq.R' ${exprsFile} ${pdatFile} ${fdatFile} ${deMethod} ${outFile}
}