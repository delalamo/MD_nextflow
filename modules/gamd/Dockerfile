FROM nvidia/cuda:12.0.0-base-ubuntu22.04

WORKDIR /home
# base OS packages
RUN \
        apt-get update \
        && apt-get install -yq \
        build-essential \
        bzip2 \
        wget \
        csh \
        git

# conda
RUN \
        wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
        && bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda \
        && rm -v Miniconda3-latest-Linux-x86_64.sh

ENV PATH="/opt/conda/bin:$PATH"
RUN conda update --quiet --yes conda

RUN \
        . /opt/conda/etc/profile.d/conda.sh \
        && conda config --add channels conda-forge \
        && conda install -c conda-forge openmm cuda-version=12.0\
        && conda install -c conda-forge pdbfixer \
        && conda install -c omnia \
            openmoltools \
            openmmtools \
            parmed \
        && conda clean -afy

RUN git clone https://github.com/MiaoLab20/gamd-openmm-examples.git \
        && git clone https://github.com/MiaoLab20/PyReweighting.git
RUN git clone https://github.com/MiaoLab20/gamd-openmm.git \
        && cd gamd-openmm \
        && python3 setup.py install

ENV PATH="/opt/conda/bin:/home/gamd-openmm:$PATH"

CMD ["/bin/bash"]