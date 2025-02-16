#!/usr/bin/env nextflow

// params.filename = "examples/2o7a.pdb"
params.filename = "my_antibody.pdb"
params.h_seq = "EVQLVESGGGVVQPGGSLRLSCAASGFTFNSYGMHWVRQAPGKGLEWVAFIRYDGGNKYYADSVKGRFTISRDNSKNTLYLQMKSLRAEDTAVYYCANLKDSRYSGSYYDYWGQGTLVTVS"
params.l_seq = "VIWMTQSPSSLSASVGDRVTITCQASQDIRFYLNWYQQKPGKAPKLLISDASNMETGVPSRFSGSGSGTDFTFTISSLQPEDIATYYCQQYDNLPFTFGPGTKVDFK"

process fold_abb {
    container 'abb2'

    input:
    val h_seq
    val l_seq

    output:
    path pdbfile

    script:
    pdbfile = "abb.pdb"
    """
    #!/usr/bin/env python
    from ImmuneBuilder import ABodyBuilder2
    predictor = ABodyBuilder2(numbering_scheme='aho')
    predictor.predict({'H': "${h_seq}", 'L': "${l_seq}"}).save_single_unrefined("${pdbfile}")
    """
}

process get_cdrs {
    container 'abb2'

    input:
    path pdbfile

    output:
    path cdrfile

    script:
    cdrfile = "cdrs.json"
    """
    #!/usr/bin/env python
    from Bio import PDB
    import json

    cdr_dict = {}
    with open("${workflow.projectDir}/assets/cdr_definitions/aho.json") as f:
        cdr_dict_json = json.load(f)
        for chain, cdrs in cdr_dict_json.items():
            cdr_dict[chain] = {int(c): range(int(x[0]), int(x[1])+1) for c, x in cdrs.items()}

    res_idx_dict = {}
    for chain in PDB.PDBParser().get_structure("TEMP", "${pdbfile}").get_chains():
        print(chain.id)
        if chain.id not in cdr_dict.keys():
            continue
        for i, r in enumerate(chain.get_residues(), start=1):
            res_idx = r.get_id()[1]
            for cdr, residues in cdr_dict[chain.id].items():
                if res_idx in residues:
                    res_idx_dict.setdefault(chain.id, {}).setdefault(cdr, []).append(i)
    with open("${cdrfile}", "w") as f:
        json.dump(res_idx_dict, f)
    """

}

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

process system_run {
    container 'gromacs_gpu:latest'

    input:
    path system_gro
    path system_top

    output:
    stdout

    script:
    """
    gmx_mpi grompp -f ${workflow.projectDir}/assets/gromacs/emin.mdp -c ${system_gro} -p ${system_top} -o em.tpr
    gmx_mpi mdrun -deffnm em # -v flag for verbose and isn't necessary
    # gmx_mpi energy -f em.edr -o potential.xvg -xvg none

    # NVT
    gmx_mpi grompp -f ${workflow.projectDir}/assets/gromacs/nvt_equilibration.mdp -c em.gro -r em.gro -p ${system_top} -o nvt.tpr
    gmx_mpi mdrun -deffnm nvt # check out -ntmpi 1 option that doesn't work here
    # there are command line options to plot this. add later

    # NPT
    gmx_mpi grompp -f ${workflow.projectDir}/assets/gromacs/npt_equilibration.mdp -c nvt.gro -r nvt.gro -t nvt.cpt -p ${system_top} -o npt.tpr
    gmx_mpi mdrun -deffnm npt

    gmx_mpi grompp -f ${workflow.projectDir}/assets/gromacs/npt_prod.mdp -c npt.gro -t npt.cpt -p ${system_top} -o md.tpr
    gmx_mpi mdrun -deffnm md
    # there are command line options to plot this. add later

    # extract last frame and convert to pdb
    echo "4\n0" | gmx_mpi trjconv -f md.trr -s md.tpr -o snapshot.pdb -dump 500000 -center -pbc mol
    """
}

workflow {
    fold_abb(params.h_seq, params.l_seq) | system_setup | system_run | view
    //fold_abb(params.h_seq, params.l_seq) | get_cdrs | view

}