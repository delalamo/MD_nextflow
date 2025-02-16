# MD_nextflow
This repo contains a dummy molecular dynamics pipeline stitched together in Nextflow for running MD simulations on VH/VL antibodies. Currently, three Docker containers: one for antibody structure prediction using ABodyBuilder2, one for OpenMM which fixes and solvates the system, and one for GROMACS where an unbiased production run is executed. Each can be built in the `fold/` `openmm/` and `gromacs/` folders, respectively. 

To run:
```
cd modules/immunebuilder && docker buildx build . -t abb2
apptainer build abb2.img docker-daemon://abb2:latest

cd modules/openmm && docker buildx build . -t openmm_gpu
apptainer build openmm_gpu.img docker-daemon://openmm_gpu:latest

cd modules/gromacs && docker buildx build . -t gromacs_gpu
apptainer build gromacs_gpu.img docker-daemon://gromacs_gpu:latest

nextflow run main.nf --h_seq <VH sequence> --l_seq <VL sequence>
```

### TODO
* ABodyBuilder2 does not model constant regions, which are important for enhanced sampling simulations - these will either need to be grafted on, or an alternative structure prediction method will need to be used. 
* The big one is to add steps for PLUMED dihedral angle sampling.