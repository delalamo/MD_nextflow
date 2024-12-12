# MD_nextflow
A dummy molecular dynamics pipeline stitched together in Nextflow. This pipeline uses two Docker containers, one for OpenMM which fixes and solvates the system, and one for GROMACS where an unbiased production run is executed. Each can be built in the `openmm/` and `gromacs/` folders, respectively.

To run:
```
nextflow run main.nf --filename example.pdb
```
