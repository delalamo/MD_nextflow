process system_setup_to_gmx {
    container "openmm_gpu:latest"

    input:
    path inpath
    path pdbpath

    output:
    path "SYSTEM.gro", emit: system_gro
    path "SYSTEM.top", emit: system_top

    script:
    """
    system_setup.py -i ${inpath} -o ${pdbpath}
    """
}

process system_setup_to_pdb {
    container "openmm_gpu:latest"

    input:
    path inpath
    path pdbpath

    output:
    path pdbpath

    script:
    """
    system_setup.py -i ${inpath} -o ${pdbpath}
    """
}