# MD_nextflow
This repo contains a dummy molecular dynamics pipeline stitched together in Nextflow for running MD simulations on VH/VL antibodies. Currently, three Docker containers: one for antibody structure prediction using ABodyBuilder2, one for OpenMM which fixes and solvates the system, and one for GROMACS where an unbiased production run is executed. Each can be built in the `fold/` `openmm/` and `gromacs/` folders, respectively. 

To run:
```bash
cd modules/gamd && docker buildx build . -t gamd
cd modules/immunebuilder && docker buildx build . -t abb2
cd modules/openmm && docker buildx build . -t openmm_gpu
cd modules/gromacs && docker buildx build . -t gromacs_gpu

# To run VH/VL antibodies
nextflow run main_vhvl.nf --csv_file <path/to/csv_file.csv>

# To run VHH nanobodies
nextflow run main_vhh.nf --sequence QVQL....VTVSS
```

### TODO
*Last updated 16 March 2025*
* Remove HMR after enhanced sampling and clustering
* Add independent MD runs after clustering
