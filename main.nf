#!/usr/bin/env nextflow
include {fold_abb    } from './modules/immunebuilder'
include {get_cdrs    } from './modules/immunebuilder'
include {system_setup} from './modules/openmm'
include {system_run  } from './modules/gromacs'

params.h_seq = "EVQLVESGGGVVQPGGSLRLSCAASGFTFNSYGMHWVRQAPGKGLEWVAFIRYDGGNKYYADSVKGRFTISRDNSKNTLYLQMKSLRAEDTAVYYCANLKDSRYSGSYYDYWGQGTLVTVS"
params.l_seq = "VIWMTQSPSSLSASVGDRVTITCQASQDIRFYLNWYQQKPGKAPKLLISDASNMETGVPSRFSGSGSGTDFTFTISSLQPEDIATYYCQQYDNLPFTFGPGTKVDFK"

workflow {
    fold_abb(params.h_seq, params.l_seq) | system_setup | system_run | view
    //fold_abb(params.h_seq, params.l_seq) | get_cdrs | view

}