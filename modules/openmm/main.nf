process system_setup_to_gmx {
    container "file:///${System.getenv('NXF_APPTAINER_CACHEDIR')}/openmm_gpu.img"

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
    container "file:///${System.getenv('NXF_APPTAINER_CACHEDIR')}/openmm_gpu.img"

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