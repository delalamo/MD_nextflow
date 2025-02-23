# source: https://gromacs.bioexcel.eu/t/installation-error-with-plumed-v2-9-gromacs-23-2-install/7270
FROM nvidia/cuda:12.0.0-devel-ubuntu22.04
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
       apt-get install -y --no-install-recommends \
            ca-certificates \
            wget \
            cmake \
            protobuf-compiler \
            gawk  \
            libmatheval-dev \
            gnuplot \
            automake \
            autoconf \    
            libtool \
            strace \
            python3 \
            python3-numpy \
            python3-scipy \
            zlib1g-dev \
            libblas-dev \
            liblapack-dev \
            git             \   
            make \
            patch \
    && rm -rf /var/lib/apt/lists/*


# Install MPICH
ARG mpich=4.0.3
ARG mpich_prefix=mpich-$mpich

RUN \
    wget https://www.mpich.org/static/downloads/$mpich/$mpich_prefix.tar.gz && \
    tar xvzf $mpich_prefix.tar.gz                                           && \
    cd $mpich_prefix                                                        && \
    ./configure --prefix=/usr --disable-fortran --enable-fast=all,03        && \
    make -j 4                                                               && \
    make install                                                            && \
    make clean                                                              && \
    cd ..                                                                   && \
    rm -rf $mpich_prefix

RUN /sbin/ldconfig

# Install PLUMED
RUN git clone -b v2.9 https://github.com/plumed/plumed2.git                 && \
    cd plumed2                                                              && \
    git checkout fff0fa526                                                  && \
    ./configure CC=mpicc CXX=mpicxx --prefix=/opt/plumed/install            && \
    make -j 4                                                               && \
    make install

ENV PATH=/opt/plumed/install/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/plumed/install/lib:$LD_LIBRARY_PATH

ENV CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-12.0/
ENV DGMX_CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-12.0/

# Install GROMACS
ARG gromacs=2023.2
ARG gmx_prefix=gromacs-$gromacs
RUN wget -q http://ftp.gromacs.org/pub/gromacs/$gmx_prefix.tar.gz           && \
    tar xf $gmx_prefix.tar.gz                                               && \
    cd $gmx_prefix                                                          && \
    plumed patch -p --runtime -e $gmx_prefix                                && \
    mkdir build && cd build                                                 && \
    cmake -DCMAKE_BUILD_TYPE=Release  \
          -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON \
          -DGMX_MPI=on -DGMX_SIMD=AVX2_256 -DGMX_GPU=CUDA                \   
          -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda/ \
          -DCMAKE_CUDA_COMPILER=/usr/local/cuda/bin/nvcc \
          -DGMX_CUDA_TARGET_COMPUTE=80 ..                                   && \    
    make -j 4                                                               && \
    make install                                                            && \
    cd ../..                                                                && \
    rm -r $gmx_prefix $gmx_prefix.tar.gz

ENV PATH=/usr/local/gromacs/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/gromacs/lib:$LD_LIBRARY_PATH
ENV PKG_CONFIG_PATH=/usr/local/gromacs/lib/pkgconfig:$PKG_CONFIG_PATH
ENV MANPATH=/usr/local/gromacs/share/man/:$MANPATH
