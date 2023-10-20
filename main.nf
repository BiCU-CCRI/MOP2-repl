/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    MOP2-repl
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/max-vdL/MOP2-repl
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

// ENABLE DSL2
nextflow.enable.dsl=2

// PRINT HELP AND EXIT
if(params.help){
    println """\

    """
    ["bash", "${baseDir}/bin/clean.sh", "${workflow.sessionId}"].execute()
    exit 0
}

// PRINT VERSION AND EXIT
if(params.version){
    println """\
    MOP2-repl Version 0.1
    """
    ["bash", "${baseDir}/bin/clean.sh", "${workflow.sessionId}"].execute()
    exit 0
}


// PRINT STANDARD LOGGING INFO
log.info ""
log.info ""


include { WRAPPER } from './workflows/wrapper.nf'

workflow {
    WRAPPER()
}