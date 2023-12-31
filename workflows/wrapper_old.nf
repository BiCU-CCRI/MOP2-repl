nextflow.enable.dsl=2

/* 
 * Define the pipeline parameters
 *
 */

// Pipeline version
version = '0.1'

params.help            = false
params.resume          = false

log.info """

 __  __   ___   ____   __        __ ____      _     ____   ____   _____  ____  
|  \/  | / _ \ |  _ \  \ \      / /|  _ \    / \   |  _ \ |  _ \ | ____||  _ \ 
| |\/| || | | || |_) |  \ \ /\ / / | |_) |  / _ \  | |_) || |_) ||  _|  | |_) |
| |  | || |_| ||  __/    \ V  V /  |  _ <  / ___ \ |  __/ |  __/ | |___ |  _ < 
|_|  |_| \___/ |_|        \_/\_/   |_| \_\/_/   \_\|_|    |_|    |_____||_| \_\
                                                                               

                                                                                       
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



// include { RUN as MOP_PREPROCESS } from "${baseDir}/MOP2/mop_preprocess/mop_preprocess" addParams(reference: params.reference, annotation: paramns.annotation, granularity: params.granularity, ref_type: ref_type, pars_tools: params.pars_tools_preprocess, output: params.output_preprocess, GPU: params.GPU, basecalling: params.basecalling, demultiplexing: params.demultiplexing, demulti_fast5: params.demulti_fast5, filtering: params.filtering, mapping: params.mapping, counting: params.counting, discovery: params.discovery, cram_conv: params.cram_conv, subsampling_cram: params.subsampling_cram, saveSpace: params.saveSpace, email: params.email)
// include { RUN as MOP_MOD } from "${baseDir}/MOP2/mop_mod/mop_mod" addParams(GPU_OPTION: gpu)
// include { RUN as MOP_CONSENSUS } from "${baseDir}/MOP2/mop_consensus/mop_consensus" addParams(GPU_OPTION: gpu)


// Define a list to store all comparisons
comparisons = []
replicates = []

// Iterate through NT and DOX samples and create comparisons
for (ntSample in params.samples.NT) {
    replicates.add(ntSample)
    for (doxSample in params.samples.DOX) {
        comparison = [ntSample.value, doxSample.value]
        comparisons.add(comparison)
    }
}
for (doxSample in params.samples.DOX) {
    replicates.add(doxSample)
}

process run_mop_preprocess {
    input:
    path replicate

    output:
    path out_*

    script:
    """
    repl_dir=\$(basename $replicate)
    out_dir="out_\${repl_dir}"
    mkdir \$out_dir
    nextflow run ${params.pipeline_path}/mop_preprocess/mop_preprocess.nf --fast5 ${replicate}/*.fast5 \
        --reference $params.reference --annotation $params.annotation \
        --granularity $params.granularity --ref_type $params.ref_type \
        --pars_tools $params.pars_tools_preprocess --output \$out_dir \
        --GPU $params.GPU --basecalling $params.basecalling \
        --demultiplexing $params.demultiplexing --demulti_fast5 $params.demulti_fast5 \
        --filtering $params.filtering --mapping $params.mapping \
        --counting $params.counting --discovery $params.discovery \
        --cram_conv $params.cram_conv --subsampling_cram $params.subsampling_cram \
        --saveSpace $params.saveSpace --email $params.email
    """
}

process run_mop_mod {
    input:
    val comparison

    output:
    path out_*

    script:
    """

    nextflow run something
    """
}


workflow {
    replicates_preprocessed = []
    run_mop_preprocess(Channel.of(replicates))
    ????

}
