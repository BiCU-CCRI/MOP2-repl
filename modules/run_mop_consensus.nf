// Author: Maximilian von der Linde
// Email: maximilian.vonderlinde@ccri.at
// Date: Oktober 19, 2023
// License: MIT

// Description:
// This module includes a Nextflow process that runs the consensus workflow of Master of Pores 2.  
// It was designed to be integrated into the MOP-repl pipeline.

process RUN_MOP_CONSENSUS {
    input:
    val ready
    tuple val(sampleA), val(sampleB)
    
    output:
    val true
    
    script:
    """
    echo "${sampleA}\t${sampleB}" > comparison.tsv
    nextflow run ${params.pipeline_path}/mop_consensus/mop_consensus.nf --input_path $params.output_mod \
        --comparison comparison.tsv --reference $params.reference \
        --padsize $params.padsize --output $params.output_consensus \
        --email $params.email
    """
}