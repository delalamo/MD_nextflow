#!/usr/bin/env nextflow
include {fold_abb    } from './modules/immunebuilder'
include {get_cdrs    } from './modules/immunebuilder'
include {system_setup} from './modules/openmm'
include {system_run  } from './modules/gromacs'

params.csv_file = "example.csv"

workflow {
    sequences = Channel.fromPath(params.csv_file)
        .splitCsv(header: true, sep: ',')
        .map { row -> tuple(row.heavy_chain, row.light_chain) }
    fold_abb(sequences) | system_setup | system_run | view

}