process system_setup {
    container 'openmm_gpu'

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