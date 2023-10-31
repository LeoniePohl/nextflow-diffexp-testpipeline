// combine all featurecounts.txt file (output of subread featurecounts into one file --> input for deseq2)
process COMBINE_FEATURECOUNTS {
    tag "$samplesheet"
    label 'process_single'

    conda "conda-forge::python=3.8.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.8.3' :
        'biocontainers/python:3.8.3' }"

    input:
    //tuple val(meta), path(counts)
    path (counts)


    output:
    path "merged_feature_counts.tsv", emit: tsv
    path "merged_feature_counts2.tsv" , emit: tsv2

    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    echo ${counts.join(' ')}
    combine_feature_counts.py merged_feature_counts.tsv merged_feature_counts2.tsv ${counts.join(' ')}


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
