process test_abb2 {
    container "file:///${System.getenv('NXF_APPTAINER_CACHEDIR')}/abb2.img"

    output:
    stdout
    
    script:
    """
    python3 -c 'import torch; print("ABB2 GPU detected:", torch.cuda.is_available())'
    """
}

process test_openmm {
    container "file:///${System.getenv('NXF_APPTAINER_CACHEDIR')}/openmm_gpu.img"

    output:
    stdout

    script:
    """
    python -m openmm.testInstallation
    """
}

workflow {
    test_abb2 | view
    test_openmm | view
}