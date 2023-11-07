/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PRINT PARAMS SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { paramsSummaryLog; paramsSummaryMap } from 'plugin/nf-validation'

def logo = NfcoreTemplate.logo(workflow, params.monochrome_logs)
def citation = '\n' + WorkflowMain.citation(workflow) + '\n'
def summary_params = paramsSummaryMap(workflow)
def exp_meta = [ "id": params.study_name  ]
if (params.input) { ch_input = Channel.of([ exp_meta, params.input ]) } else { exit 1, 'Input samplesheet not specified!' }




// Print parameter summary log to screen
log.info logo + paramsSummaryLog(workflow) + citation

WorkflowTestpipeline.initialise(params, log)

ch_genome_fasta = Channel.fromPath(params.fasta) //.map { it -> [[id:it[0].simpleName], it] }.collect()

ch_genome_gtf = Channel.fromPath(params.gtf)//.map { it -> [[id:it[0].simpleName], it] }.collect()

ch_contrasts_file = Channel.from([[exp_meta, file(params.contrasts)]])

ch_control_features = [[],[]]





//hisat2_index = Channel.fromPath("/Users/leoniepohl/Desktop/results4/hisat2/hisat2/*.ht2")
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
include { DESEQ2 } from '../subworkflows/local/deseq2.nf'

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
include { SUBREAD_FEATURECOUNTS } from '../modules/nf-core/subread/featurecounts/main'
include { DESEQ2_DIFFERENTIAL } from '../modules/nf-core/deseq2/differential/main'
include { SHINYNGS_VALIDATEFOMCOMPONENTS as VALIDATOR       } from '../modules/nf-core/shinyngs/validatefomcomponents/main'



//
// MODULE: Installed directly locally
//
include { BCFTOOLS_MPILEUP            } from '../modules/local/bcftools_mpileup.nf'
include { SUBREAD_FLATTENGTF    } from '../modules/local/flatten_gtf.nf'
include { COMBINE_FEATURECOUNTS    } from '../modules/local/combine_featurecounts.nf'






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

     // check gtf
    SUBREAD_FLATTENGTF(
        ch_genome_gtf,
        params.gtf_feature_type
    )


   /*FASTQC (
       INPUT_CHECK.out.reads
    )

   // create hisat2 index
   ch_splicesites = HISAT2_EXTRACTSPLICESITES ( ch_genome_gtf.map { [ [:], it ] } ).txt.map { it[1] }
   ch_hisat2_index = HISAT2_BUILD ( ch_genome_fasta.map { [ [:], it ] }, ch_genome_gtf.map { [ [:], it ] }, ch_splicesites.map { [ [:], it ] } ).index.collect()

    // hisat2 alignment
   HISAT2_ALIGN(
        INPUT_CHECK.out.reads,
        ch_hisat2_index,
        //hisat2_index.map { [ [:], it ] },
        ch_splicesites.map { [ [:], it ] }.collect()
   )

    // subread feauture counts
    //HISAT2_ALIGN.out.bam.view()
    ch_feature_counts = HISAT2_ALIGN.out.bam.combine(ch_genome_gtf)


    // [ meta, [ ip_bams ], saf/gtf ]
   SUBREAD_FEATURECOUNTS(
       ch_feature_counts,
       params.gtf_feature_type
       //ch_featurecounts
    )


    //SUBREAD_FEATURECOUNTS.out.counts.view()

     SUBREAD_FEATURECOUNTS.out.counts.collect({it[1]}).view()

    COMBINE_FEATURECOUNTS(
          SUBREAD_FEATURECOUNTS.out.counts.collect({it[1]})

    )

    ch_in_raw = COMBINE_FEATURECOUNTS.out.tsv.map { [ exp_meta, it ] }
   //.collect()
    ch_in_raw.view()



// here:ch_control_features?? todo check
// deseq2 subworkflow
// input: all SUBREAD_FEATURECOUNTS *featureCounts.txt files combined to one matrix tsv with header: gene_id	sample1	sample2 ...
  DESEQ2 (
   COMBINE_FEATURECOUNTS.out.tsv,
   ch_in_raw,
   ch_feature
   )
   */
    def customPath1 = '/home/p/pohll/Desktop/rubrum_nextflow/results/combine/merged_feature_counts.tsv'
    def customPath2 = '/home/p/pohll/Desktop/rubrum_nextflow/results/combine/merged_feature_counts2.tsv'
   //test deseq2 based on previously counts -> paths
    ch_in_raw = customPath1.map { [ exp_meta, it ] }
    ch_feature = customPath2.map { [ exp_meta, it ] }

   DESEQ2 (
    path('/home/p/pohll/Desktop/rubrum_nextflow/results/combine/merged_feature_counts.tsv'),
    ch_in_raw,
    ch_feature
   )



}


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
