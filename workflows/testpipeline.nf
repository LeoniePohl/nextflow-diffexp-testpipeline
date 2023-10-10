/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PRINT PARAMS SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { paramsSummaryLog; paramsSummaryMap } from 'plugin/nf-validation'

def logo = NfcoreTemplate.logo(workflow, params.monochrome_logs)
def citation = '\n' + WorkflowMain.citation(workflow) + '\n'
def summary_params = paramsSummaryMap(workflow)

// Print parameter summary log to screen
log.info logo + paramsSummaryLog(workflow) + citation

WorkflowTestpipeline.initialise(params, log)

ch_genome_fasta = Channel.fromPath(params.fasta) //.map { it -> [[id:it[0].simpleName], it] }.collect()

ch_genome_gtf = Channel.fromPath(params.gtf)//.map { it -> [[id:it[0].simpleName], it] }.collect()


//hisat2_index = Channel.fromPath("/Users/leoniepohl/Desktop/results4/hisat2/hisat2/*.ht2")

/*
ch_genome_splicesites = Channel.fromPath("/Users/leoniepohl/Desktop/results2/hisat2/genes.splice_sites.txt").map { it -> [[id:it[0].simpleName], it] }.collect()
ch_test_fasta = Channel.fromPath(params.wfasta).map { it -> [[id:it[0].simpleName], it] }.collect()
ch_test_genome = Channel.fromPath(params.wgtf).map { it -> [[id:it[0].simpleName], it] }.collect()
ch_test_splice = Channel.fromPath(params.sgtf).map { it -> [[id:it[0].simpleName], it] }.collect() */





/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

ch_multiqc_config          = Channel.fromPath("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
ch_multiqc_custom_config   = params.multiqc_config ? Channel.fromPath( params.multiqc_config, checkIfExists: true ) : Channel.empty()
ch_multiqc_logo            = params.multiqc_logo   ? Channel.fromPath( params.multiqc_logo, checkIfExists: true ) : Channel.empty()
ch_multiqc_custom_methods_description = params.multiqc_methods_description ? file(params.multiqc_methods_description, checkIfExists: true) : file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { INPUT_CHECK } from '../subworkflows/local/input_check'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { FASTQC                      } from '../modules/nf-core/fastqc/main'
include { MULTIQC                     } from '../modules/nf-core/multiqc/main'
include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/custom/dumpsoftwareversions/main'
include { BWA_MEM                     } from '../modules/nf-core/bwa/mem/main'
include { BWA_INDEX                   } from '../modules/nf-core/bwa/index/main'
include { HISAT2_ALIGN                } from '../modules/nf-core/hisat2/align/main'
include { HISAT2_BUILD                } from '../modules/nf-core/hisat2/build/main'
include { HISAT2_EXTRACTSPLICESITES } from '../modules/nf-core/hisat2/extractsplicesites/main'


//
// MODULE: Installed directly locally
//
include { BCFTOOLS_MPILEUP            } from '../modules/local/bcftools_mpileup.nf'






/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Info required for completion email and summary
def multiqc_report = []

workflow TESTPIPELINE {

    ch_versions = Channel.empty()


    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //
    INPUT_CHECK (
        file(params.input)
    )
    ch_versions = ch_versions.mix(INPUT_CHECK.out.versions)
    // TODO: OPTIONAL, you can use nf-validation plugin to create an input channel from the samplesheet with Channel.fromSamplesheet("input")
    // See the documentation https://nextflow-io.github.io/nf-validation/samplesheets/fromSamplesheet/
    // ! There is currently no tooling to help you write a sample sheet schema

    ch_splicesites = HISAT2_EXTRACTSPLICESITES ( ch_genome_gtf.map { [ [:], it ] } ).txt.map { it[1] }


    /* HISAT2_BUILD (
      ch_genome_fasta.map { [ [:], it ] },
     ch_genome_gtf.map { [ [:], it ] },
      ch_splicesites.map { [ [:], it ] }
      )//.index.map { it[1] }
    ch_hisat2_index = HISAT2_BUILD.out.index.map { it[1] } */

    ch_hisat2_index = HISAT2_BUILD ( ch_genome_fasta.map { [ [:], it ] }, ch_genome_gtf.map { [ [:], it ] }, ch_splicesites.map { [ [:], it ] } ).index.collect()

    HISAT2_ALIGN(
        INPUT_CHECK.out.reads,
        ch_hisat2_index, //.map { [ [:], it ] },
        //hisat2_index.map { [ [:], it ] },
        ch_splicesites.map { [ [:], it ] }
   )


}

// TODO define run_diffexp process
/*process CALLSCRIPT {

  script:
  """
  myscript.py
  """
}*/


/*




    HISAT2_BUILD(
        ch_genome_fasta,
        ch_genome_gtf,
        ch_genome_splicesites
   )
    ch_index = HISAT2_BUILD.out.index //.map { it -> [[id:it[0].simpleName], it] }.collect()

    HISAT2_ALIGN(
        INPUT_CHECK.out.reads,
        ch_index,
        ch_genome_splicesites
   )

*/


    //
    // MODULE: Run FastQC
    //
    /*FASTQC (
        INPUT_CHECK.out.reads
    )
    ch_versions = ch_versions.mix(FASTQC.out.versions.first())

    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )



    BWA_INDEX(
        ch_test_fasta
    )
    ch_index = BWA_INDEX.out.index
    ch_versions = ch_versions.mix(BWA_INDEX.out.versions)*/






/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, multiqc_report)
    }
    NfcoreTemplate.summary(workflow, params, log)
    if (params.hook_url) {
        NfcoreTemplate.IM_notification(workflow, params, summary_params, projectDir, log)
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
