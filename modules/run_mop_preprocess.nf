// Author: Maximilian von der Linde
// Email: maximilian.vonderlinde@ccri.at
// Date: Oktober 19, 2023
// License: MIT

// Description:
// This module includes a Nextflow process that runs the preprocess workflow of Master of Pores 2.  
// It was designed to be integrated into the MOP-repl pipeline.

process RUN_MOP_PREPROCESS {
    input:
    path replicate

    output:
    val true
    
    script:
    """
    nextflow run ${params.pipeline_path}/mop_preprocess/mop_preprocess.nf --fast5 ${replicate}/*.fast5 \
        --reference $params.reference --annotation $params.annotation \
        --granularity $params.granularity --ref_type $params.ref_type \
        --pars_tools $params.pars_tools_preprocess --output $params.output_preprocess \
        --GPU $params.GPU --basecalling $params.basecalling \
        --demultiplexing $params.demultiplexing --demulti_fast5 $params.demulti_fast5 \
        --filtering $params.filtering --mapping $params.mapping \
        --counting $params.counting --discovery $params.discovery \
        --cram_conv $params.cram_conv --subsampling_cram $params.subsampling_cram \
        --saveSpace $params.saveSpace --email $params.email
    """
}