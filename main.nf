#!/usr/bin/env nextflow

params.filename = "examples/2o7a.pdb"

process system_setup {
    container 'openmm_gpu'

    input:
    path inpath

    output:
    path "SYSTEM.gro", emit: system_gro
    path "SYSTEM.top", emit: system_top

    script:
    """
    system_setup.py -i ${inpath}
    """
}

process system_run {
    container 'gromacs_gpu:latest'

    input:
    path system_gro
    path system_top

    output:
    stdout

    script:
    """
    gmx_mpi grompp -f /home/delalamo/md_nf_example/gromacs/emin.mdp -c ${system_gro} -p ${system_top} -o em.tpr
    gmx_mpi mdrun -deffnm em # -v flag for verbose and isn't necessary
    # gmx_mpi energy -f em.edr -o potential.xvg -xvg none

    # NVT
    gmx_mpi grompp -f /home/delalamo/md_nf_example/gromacs/nvt_equilibration.mdp -c em.gro -r em.gro -p ${system_top} -o nvt.tpr
    gmx_mpi mdrun -deffnm nvt # check out -ntmpi 1 option that doesn't work here
    # there are command line options to plot this. add later

    # NPT
    gmx_mpi grompp -f /home/delalamo/md_nf_example/gromacs/npt_equilibration.mdp -c nvt.gro -r nvt.gro -t nvt.cpt -p ${system_top} -o npt.tpr
    gmx_mpi mdrun -deffnm npt

    gmx_mpi grompp -f /home/delalamo/md_nf_example/gromacs/npt_prod.mdp -c npt.gro -t npt.cpt -p ${system_top} -o md.tpr
    gmx_mpi mdrun -deffnm md
    # there are command line options to plot this. add later

    # extract last frame and convert to pdb
    echo "4\n0" | gmx_mpi trjconv -f md.trr -s md.tpr -o snapshot.pdb -dump 500000 -center -pbc mol
    """
}

workflow {
    system_setup(params.filename) | system_run | view
}