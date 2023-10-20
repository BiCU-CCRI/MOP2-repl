nextflow.enable.dsl=2

/* 
 * Define the pipeline parameters
 *
 */

// Pipeline version
version = '0.1'


log.info """

███    ███  ██████  ██████  ██████      ██████  ███████ ██████  ██          ██     ██ ██████   █████  ██████  ██████  ███████ ██████  
████  ████ ██    ██ ██   ██      ██     ██   ██ ██      ██   ██ ██          ██     ██ ██   ██ ██   ██ ██   ██ ██   ██ ██      ██   ██ 
██ ████ ██ ██    ██ ██████   █████      ██████  █████   ██████  ██          ██  █  ██ ██████  ███████ ██████  ██████  █████   ██████  
██  ██  ██ ██    ██ ██      ██          ██   ██ ██      ██      ██          ██ ███ ██ ██   ██ ██   ██ ██      ██      ██      ██   ██ 
██      ██  ██████  ██      ███████     ██   ██ ███████ ██      ███████      ███ ███  ██   ██ ██   ██ ██      ██      ███████ ██   ██ 
                                                                                                                                      

                                                                                       
====================================================
maximilian.vonderlinde@ccri.at Wrapper for Master of Pores 2 (BIOCORE@CRG). ~  version ${version}
====================================================

pipeline_path             : ${params.pipeline_path}

samples                   : ${params.samples}

reference                 : ${params.reference}
annotation                : ${params.annotation}

granularity.              : ${params.granularity}

ref_type                  : ${params.ref_type}
pars_tools_preprocess     : ${params.pars_tools_preprocess}
pars_tools_mod            : ${params.pars_tools_mod}

output_preprocess         : ${params.output_preprocess}
output_mod                : ${params.output_mod}
output_consensus          : ${params.output_consensus}

GPU                       : ${params.GPU}

basecalling               : ${params.basecalling} 
demultiplexing            : ${params.demultiplexing} 
demulti_fast5             : ${params.demulti_fast5}

filtering                 : ${params.filtering}
mapping                   : ${params.mapping}

counting                  : ${params.counting}
discovery                 : ${params.discovery}

cram_conv           	  : ${params.cram_conv}
subsampling_cram          : ${params.subsampling_cram}

saveSpace                 : ${params.saveSpace}
email                     : ${params.email}

*************** mop mod Flows ***********
epinano                   : ${params.epinano}
nanocompore               : ${params.nanocompore}
tombo_lsc                 : ${params.tombo_lsc}
tombo_msc                 : ${params.tombo_msc}

"""

// Help and avoiding typos
if (params.help) exit 1
if (params.resume) exit 1, "Are you making the classical --resume typo? Be careful!!!! ;)"

// check multi5 and GPU usage. GPU maybe can be removed as param if there is a way to detect it
if (params.GPU != "ON" && params.GPU != "OFF") exit 1, "Please specify ON or OFF in GPU processors are available"

// // Define a list to store all sample directories
// conditionA_dir = []
// conditionB_dir = []

// Read the path to the JSON file from params.config
def samplesFile = new File(params.samples)
def samplesJson = new groovy.json.JsonSlurper().parse(samplesFile)
// Access the lists from the JSON content
def conditionA_dir = samplesJson.A
def conditionB_dir = samplesJson.B
log.info "Sample directories: \n$conditionA_dir \n$conditionB_dir"

include { RUN_MOP_PREPROCESS } from '../modules/run_mop_preprocess'
include { RUN_MOP_MOD } from '../modules/run_mop_mod'
include { RUN_MOP_CONSENSUS } from '../modules/run_mop_consensus'

// Check if all output folders are present, if not, make new ones, otherwise missing samples will be added to existing folders
def createEmptyDirectory(directoryPath) {
    def directory = new File(directoryPath)
    
    if (!directory.exists()) {
        if (directory.mkdirs()) {
            println "New directory created at: $directoryPath"
        } else {
            println "Failed to create the directory at: $directoryPath"
        }
    } else {
        println "The directory already exists at: $directoryPath, new samples will be added."
    }
}
createEmptyDirectory(params.output_preprocess)
createEmptyDirectory(params.output_mod)
createEmptyDirectory(params.output_consensus)
println(Channel.fromList(conditionA_dir).view { "$it" })
workflow WRAPPER {
    RUN_MOP_PREPROCESS(Channel.fromList(conditionA_dir).mix(Channel.fromList(conditionB_dir)))

    // get the names of the samples and transform them into channels
    ch_conditionA_names = Channel.fromList(conditionA_dir).map { pathStr ->
        folderName = pathStr.tokenize('/').last()
        return folderName
    }    
    ch_conditionB_names = Channel.fromList(conditionB_dir).map { pathStr ->
        folderName = pathStr.tokenize('/').last()
        return folderName
    }    
    // pairing each condition A sample with every condition B sample
    ch_comparisons = ch_conditionA_names.combine(ch_conditionB_names)
    RUN_MOP_MOD(RUN_MOP_PREPROCESS.out, ch_comparisons)

    RUN_MOP_CONSENSUS(RUN_MOP_MOD.out, ch_comparisons)

}
