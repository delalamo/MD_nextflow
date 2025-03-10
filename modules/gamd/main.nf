process run_gamd {
    container "file:///${System.getenv('NXF_APPTAINER_CACHEDIR')}/gamd.img"

    input:
    path pdbfile

    output:
    stdout

    script:
    """
    gamdRunner xml ${workflow.projectDir}/assets/gamd/gamd_test.xml
    python3 ${workflow.projectDir}/assets/gamd/process_traj.py -i ${pdbfile} -t lower-dual/output.dcd -o out
    """
}