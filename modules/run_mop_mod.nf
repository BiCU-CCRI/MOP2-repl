// Author: Maximilian von der Linde
// Email: maximilian.vonderlinde@ccri.at
// Date: Oktober 19, 2023
// License: MIT

// Description:
// This module includes a Nextflow process that runs the mod workflow of Master of Pores 2.  
// It was designed to be integrated into the MOP-repl pipeline.

process RUN_MOP_MOD {
    input:
    val ready
    tuple val(sampleA), val(sampleB)

    output:
    val true
    
    script:
    """
    echo "${sampleA}\t${sampleB}" > comparison.tsv
    nextflow run ${params.pipeline_path}/mop_mod/mop_mod.nf --input_path $params.output_preprocess \
        --comparison comparison.tsv --reference $params.reference \
        --pars_tools $params.pars_tools_preprocess --output $params.output_mod \
        --epinano $params.epinano --nanocompore $params.nanocompore \
        --tombo_lsc $param.tombo.lsc --tombo_msc $params.tombo_msc \
        --epinano_plots $params.epinano_plots --email $params.email
    """
}