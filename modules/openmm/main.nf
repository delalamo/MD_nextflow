process system_setup {
    container "file:///${System.getenv('NXF_APPTAINER_CACHEDIR')}/openmm_gpu.img"

    input:
    path inpath

    output:
    path "SYSTEM.gro", emit: system_gro
    path "SYSTEM.top", emit: system_top

    script:
    """
    system_setup.py -i ${inpath}
    """
}