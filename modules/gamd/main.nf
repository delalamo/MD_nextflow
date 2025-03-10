process run_gamd {
    container "file:///${System.getenv('NXF_APPTAINER_CACHEDIR')}/gamd.img"

    input:
    path pdbfile

    output:
    stdout

    script:
    """
    gamdRunner xml ${workflow.projectDir}/assets/gamd/gamd_test.xml
    """
}