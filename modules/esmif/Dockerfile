# Base image with CUDA 12.0
FROM nvidia/cuda:12.0.0-base-ubuntu22.04

# Set the working directory
WORKDIR /home

# Install base OS packages and essential build tools
RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
    build-essential \
    bzip2 \
    wget \
    csh \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O Miniconda3.sh && \
    bash Miniconda3.sh -b -p /opt/conda && \
    rm -v Miniconda3.sh

# Add Conda to PATH
ENV PATH="/opt/conda/bin:$PATH"

# Update Conda
RUN conda update --quiet --yes conda

# Create the Conda environment "inverse" with Python 3.9
RUN conda create -n inverse python=3.9 -y

# Install system-level dependencies required for some Python packages (e.g., ESM compilation)
# This should be done before pip installing packages that might compile code.
RUN apt-get update && \
    apt-get install -yq --no-install-recommends --fix-missing \
    fortran-compiler \
    libopenblas-dev \
    pkg-config \
    git && \
    rm -rf /var/lib/apt/lists/*

# Install Python packages into the "inverse" environment
# Using a single RUN command with conda activation for this block
# This helps in reducing Docker image layers and ensures all commands run in the activated environment.
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda activate inverse && \
    echo "INFO: Activated conda environment 'inverse'"
    # Install PyTorch 1.11.0 with specific torchvision, torchaudio, and CUDA 11.3 from the pytorch channel
RUN . /opt/conda/etc/profile.d/conda.sh && \
    echo "INFO: Installing PyTorch==1.11.0, torchvision==0.12.0, torchaudio==0.11.0 with CUDA 11.3..." && \
    conda activate inverse && \
    conda install pytorch==1.11.0 torchvision==0.12.0 torchaudio==0.11.0 cudatoolkit=11.3 -c pytorch -y
    # Install PyG from pyg and conda-forge channels
    # It's often better to also include the pytorch channel here if pyg has direct dependencies on specific pytorch builds.
RUN . /opt/conda/etc/profile.d/conda.sh && \
    echo "INFO: Installing PyG..." && \
    conda activate inverse && conda install pyg==2.1.0 -c pyg -c pytorch -c conda-forge -y
    # Install Biotite using pip
RUN . /opt/conda/etc/profile.d/conda.sh && \
    echo "INFO: Installing Biotite..." && \
    conda activate inverse && pip install --no-cache-dir biotite
    # Install ESM from the Facebook Research GitHub repository using pip
RUN . /opt/conda/etc/profile.d/conda.sh && \
    echo "INFO: Installing ESM from GitHub..." && \
    conda activate inverse && pip install --no-cache-dir git+https://github.com/facebookresearch/esm.git && \
    rm -rf ~/.cache/pip

RUN . /opt/conda/etc/profile.d/conda.sh && conda activate inverse && python3 -m pip install numpy==1.26.1 python-dateutil biopython pandas
RUN . /opt/conda/etc/profile.d/conda.sh && conda activate inverse && conda install scipy==1.13.0 -c conda-forge

# Download pre-trained ESM model weights
# This command needs to run within the 'inverse' conda environment
RUN mkdir -p /dl_model_cache
RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda activate inverse && \
    echo "INFO: Downloading ESM pre-trained model..." && \
    python -c 'import esm, torch; torch.hub.set_dir("/dl_model_cache"); esm.pretrained.esm_if1_gvp4_t16_142M_UR50()'

# Configure bash to automatically activate the "inverse" conda environment upon login
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate inverse" >> ~/.bashrc

# Set the default command to bash
# The .bashrc modifications above will ensure the "inverse" environment is active.
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate inverse" >> ~/.bashrc

RUN cd / && git clone https://github.com/varun-shanker/structural-evolution.git
RUN chmod 755 /structural-evolution/bin/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh


ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Define a default command (e.g., start a bash shell)
# This will be passed as "$@" to the entrypoint.sh script
CMD ["/bin/bash"]
