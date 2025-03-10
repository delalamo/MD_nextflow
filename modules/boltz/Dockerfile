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
        nano \
        vim \
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
        && conda config --add channels conda-forge

RUN python3 -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

RUN apt-get update \
        && apt-get install -yq --fix-missing \
        fortran-compiler \
        libopenblas-dev \
        pkg-config

RUN pip install boltz -U

# Download NN weights
RUN git clone https://github.com/jwohlwend/boltz.git \
     && cd boltz/ \
     && boltz predict examples/prot.fasta

CMD ["/bin/bash"]