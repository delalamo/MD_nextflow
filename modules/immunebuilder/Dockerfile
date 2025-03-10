FROM nvidia/cuda:12.0.0-base-ubuntu22.04

WORKDIR /home
# base OS packages
RUN \
        apt-get update \
        && apt-get install -yq \
        build-essential \
        bzip2 \
        wget \
        csh

# conda
RUN \
        wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
        && bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda \
        && rm -v Miniconda3-latest-Linux-x86_64.sh

ENV PATH="/opt/conda/bin:$PATH"
RUN conda update --quiet --yes conda

RUN \
        . /opt/conda/etc/profile.d/conda.sh \
        && conda config --add channels conda-forge

RUN python3 -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

RUN apt-get update \
        && apt-get install -yq --fix-missing \
        fortran-compiler \
        libopenblas-dev \
        pkg-config

RUN conda install -c conda-forge openmm pdbfixer \
        && conda install -c bioconda anarci \
        && python3 -m pip install ImmuneBuilder \
        && python3 -m pip install biopython

# Roll back to older versions of numpy and scipy for compatibility
RUN python3 -m pip install numpy==1.26.1
RUN conda install scipy==1.13.0 -c conda-forge

# Download NN weights
RUN python3 -c 'from ImmuneBuilder import ABodyBuilder2; predictor = ABodyBuilder2()'
RUN python3 -c 'from ImmuneBuilder import NanoBodyBuilder2; predictor = NanoBodyBuilder2()'

CMD ["/bin/bash"]