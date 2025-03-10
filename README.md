# MD_nextflow
This repo contains a dummy molecular dynamics pipeline stitched together in Nextflow for running MD simulations on VH/VL antibodies. Currently, three Docker containers: one for antibody structure prediction using ABodyBuilder2, one for OpenMM which fixes and solvates the system, and one for GROMACS where an unbiased production run is executed. Each can be built in the `fold/` `openmm/` and `gromacs/` folders, respectively. 

To run:
```bash
# set this to configure where local images should be read from
export NXF_APPTAINER_CACHEDIR="/path/to/containers/directory"
# also set this in .bashrc or .zshrc

cd modules/immunebuilder && docker buildx build . -t abb2
apptainer build ${NXF_APPTAINER_CACHEDIR}/abb2.img docker-daemon://abb2:latest

cd modules/openmm && docker buildx build . -t openmm_gpu
apptainer build ${NXF_APPTAINER_CACHEDIR}/openmm_gpu.img docker-daemon://openmm_gpu:latest

cd modules/gromacs && docker buildx build . -t gromacs_gpu
apptainer build ${NXF_APPTAINER_CACHEDIR}/gromacs_gpu.img docker-daemon://gromacs_gpu:latest

# To run VH/VL antibodies
nextflow run main_vhvl.nf --csv_file <path/to/csv_file.csv>

# To run VHH nanobodies
nextflow run main_vhh.nf --sequence QVQL....VTVSS
```

### TODO
*Last updated 10 March 2025*
* **Model VHHs**: I'd like to start with a simpler use case, VHHs, which don't have as many confounding properties (fewer CDR loops, no CH1).
* **Model full Fab**: ABodyBuilder2 does not model constant regions, and the personal computer I am building this on has insufficient RAM and VRAM to support larger structure prediction models like   
* **Add PLUMED**: The big one is to add steps for PLUMED dihedral angle sampling. Alternatively, since I am having trouble making a docker container that runs PLUMED with GROMACS on GPU, I can instead use Gaussian Accelerated MD with OpenMM, which has a github repo.
