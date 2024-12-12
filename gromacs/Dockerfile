FROM takedomikei/gromacs_plumed_v3:gromacs2024.2_plumed2.10

WORKDIR /home
ENV PATH="$PATH:/home/gromacs/2024.2/bin/:/home/plumed/2.10/bin"
ENV PKG_CONFIG_PATH="/home/plumed/2.10/lib/pkgconfig"
ENV LD_LIBRARY_PATH="/home/plumed/2.10/lib:$LD_LIBRARY_PATH"

CMD ["/bin/bash"]