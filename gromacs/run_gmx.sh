#!/bin/bash

# E min
gmx_mpi grompp -f ../gromacs_files/emin.mdp -c ../openmm/SYSTEM.gro -p ../openmm/SYSTEM.top -o em.tpr
gmx_mpi mdrun -v -deffnm em # -v flag for verbose and isn't necessary
# gmx_mpi energy -f em.edr -o potential.xvg -xvg none

# NVT
gmx_mpi grompp -f ../gromacs_files/nvt_equilibration.mdp -c em.gro -r em.gro -p ../openmm/SYSTEM.top -o nvt.tpr
gmx_mpi mdrun -v -deffnm nvt # check out -ntmpi 1 option that doesn't work here
# there are command line options to plot this. add later

# NPT
gmx_mpi grompp -f ../gromacs_files/npt_equilibration.mdp -c nvt.gro -r nvt.gro -t nvt.cpt -p ../openmm/SYSTEM.top -o npt.tpr
gmx_mpi mdrun -v -deffnm npt # check out -ntmpi 1 option that doesn't work here
# there are command line options to plot this

gmx_mpi grompp -f ../gromacs_files/npt_prod.mdp -c npt.gro -t npt.cpt -p ../openmm/SYSTEM.top -o md.tpr
gmx_mpi mdrun -v -deffnm md
# there are command line options to plot this. add later

# extract last frame and convert to pdb
gmx_mpi trjconv -f md.trr -s md.tpr -o snapshot.pdb -dump 500000 -center -pbc mol