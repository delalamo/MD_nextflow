#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# Source Conda's shell functions
. /opt/conda/etc/profile.d/conda.sh

# Activate the desired Conda environment
conda activate inverse

# Now, execute the command passed into the Docker container (i.e., the CMD or arguments to docker run)
exec "$@"
