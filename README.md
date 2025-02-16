# MD_nextflow
A dummy molecular dynamics pipeline stitched together in Nextflow for running MD simulations on VH/VL antibodies. This pipeline uses three Docker containers: one for antibody structure prediction using ABodyBuilder2, one for OpenMM which fixes and solvates the system, and one for GROMACS where an unbiased production run is executed. Each can be built in the `fold/` `openmm/` and `gromacs/` folders, respectively.

To run:
```
cd modules/immunebuilder && docker buildx build . -t fold_abb
cd modules/openmm && docker buildx build . -t openmm_gpu
cd modules/gromacs && docker buildx build . -t gromacs_gpu
nextflow run main.nf --filename example.pdb
```

Note that the names of the containers in `main.nf` will need to be updated.
