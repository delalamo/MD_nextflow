# Base image with CUDA 12.6
FROM nvidia/cuda:12.6.0-base-ubuntu22.04

# Set working directory
WORKDIR /home

# Install base OS packages
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        bzip2 \
        wget \
        csh \
        git \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda \
    && rm Miniconda3-latest-Linux-x86_64.sh

ENV PATH="/opt/conda/bin:$PATH"

# Accept Conda Terms of Service
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main \
    && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Create Conda environment with all packages in one step
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda create -n gamd-env -c conda-forge -c omnia python=3.12 \
        openmm=8.3 pdbfixer openmoltools openmmtools parmed mdanalysis mdaencore cuda-version=12.6 -y && \
    conda clean -afy

# Activate environment by default
ENV PATH="/opt/conda/envs/gamd-env/bin:$PATH"

# Clone required repositories
RUN git clone https://github.com/MiaoLab20/gamd-openmm-examples.git \
    && git clone https://github.com/MiaoLab20/PyReweighting.git \
    && git clone https://github.com/MiaoLab20/gamd-openmm.git \
    && cd gamd-openmm \
    && python3 setup.py install

# Set PATH to include local scripts
ENV PATH="/opt/conda/envs/gamd-env/bin:/home/gamd-openmm:$PATH"

# Default command
CMD ["/bin/bash"]
