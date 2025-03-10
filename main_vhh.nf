#!/usr/bin/env nextflow
include {fold_vhh           } from './modules/immunebuilder'
include {system_setup_to_pdb} from './modules/openmm'
include {run_gamd           } from './modules/gamd'

params.seq = "DVQLQASGGGSVQAGGSLRLSCAASGYTIGPYCMGWFRQAPGKEREGVAAINSGGGSTYYADSVKGRFTISQDNAKNTVYLLMNSLEPEDTAIYYCAADSTIYASYYECGHGLSTGGYGYDSWGQGTQVTVSS"

//this file needs to be static due to gamd's reliance on XML
params.openmm_file = "openmm_out.pdb"

workflow {
    vhh_pdb = fold_vhh(params.seq)
    openmm_pdb = system_setup_to_pdb(vhh_pdb, Channel.fromPath(params.openmm_file))
    run_gamd(openmm_pdb)
}