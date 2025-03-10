#!/usr/bin/env nextflow
include {fold_abb           } from './modules/immunebuilder'
include {get_cdrs           } from './modules/immunebuilder'
include {system_setup_to_gmx} from './modules/openmm'
include {system_run         } from './modules/gromacs'

params.csv_file = "example_single.csv"
params.openmm_file = "openmm_out.pdb"

process run_plumed {
    maxForks 1
    container "file:///${System.getenv('NXF_APPTAINER_CACHEDIR')}/gromacs_gpu.img"

    input:
    path system_tpr

    output:
    stdout

    script:
    """
    gmx_mpi mdrun -s ${system_tpr.baseName} -nsteps 5000000 -plumed ${workflow.projectDir}/assets/plumed/plumed.dat
    """
}

workflow {
    sequences = Channel.fromPath(params.csv_file)
        .splitCsv(header: true, sep: ',')
        .map { row -> tuple(row.heavy_chain, row.light_chain) }
    abb2_pdb = fold_abb(sequences)
    system_setup_to_gmx(abb2_pdb, Channel.fromPath(params.openmm_file))
    system_run(system_setup_to_gmx.out[0], system_setup_to_gmx.out[1])
    gmx_tpr = system_run.out[0]
    run_plumed(gmx_tpr) | view

}