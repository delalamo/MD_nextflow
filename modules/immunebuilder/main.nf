process fold_abb {
    container "abb2:latest"

    input:
    tuple val(h_seq), val(l_seq)

    output:
    path pdbfile

    script:
    idx = String.format("%06d", task.index)
    pdbfile = "${idx}.pdb"
    """
    #!/usr/bin/env python
    from ImmuneBuilder import ABodyBuilder2
    predictor = ABodyBuilder2(numbering_scheme='aho')
    predictor.predict({'H': "${h_seq}", 'L': "${l_seq}"}).save_single_unrefined("${pdbfile}")
    """
}

process fold_vhh {
    container "file:///${System.getenv('NXF_APPTAINER_CACHEDIR')}/abb2.img"

    input:
    val(h_seq)

    output:
    path pdbfile

    script:
    //idx = String.format("%06d", task.index)
    //pdbfile = "${idx}.pdb"
    pdbfile = "vhh_out.pdb"
    """
    #!/usr/bin/env python
    from ImmuneBuilder import NanoBodyBuilder2
    predictor = NanoBodyBuilder2(numbering_scheme='aho')
    predictor.predict({'H': "${h_seq}"}).save_single_unrefined("${pdbfile}")
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