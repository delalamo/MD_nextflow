#!/usr/bin/env nextflow
include {fold_vhh    } from './modules/immunebuilder'
include {get_cdrs    } from './modules/immunebuilder'
include {system_setup} from './modules/openmm'

params.seq = "DVQLQASGGGSVQAGGSLRLSCAASGYTIGPYCMGWFRQAPGKEREGVAAINSGGGSTYYADSVKGRFTISQDNAKNTVYLLMNSLEPEDTAIYYCAADSTIYASYYECGHGLSTGGYGYDSWGQGTQVTVSS"
params.openmm_file = "openmm_out.pdb"

workflow {
    vhh_pdb = fold_vhh(params.seq)
    system_setup(vhh_pdb, Channel.fromPath(params.openmm_file))
    
}