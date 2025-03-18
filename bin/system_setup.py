#!/usr/bin/env python3

import argparse
import logging
import os
import sys
from sys import stdout

import openmm
import parmed
from openmm import app
from pdbfixer import PDBFixer

logging.basicConfig(level=logging.DEBUG)


def parse_args():
    """
    Parse command line arguments.

    Returns:
        argparse.Namespace: Parsed command line arguments.
    """
    argparser = argparse.ArgumentParser()
    argparser.add_argument("-i", "--input_pdb", required=True, type=str)
    argparser.add_argument("-o", "--output_pdb", default="openmm_out.pdb", type=str)
    argparser.add_argument("-v", "--verbose", action="store_true")
    return argparser.parse_args()


def fix_structure(pdbfile_in: str, pdbfile_out: str):
    """
    Fix PDB by adding loops and replacing nonstandard amino acids with standard
    equivalents (e.g., selenomethionine to methionine). Does not add hydrogens;
    this is done later.

    Args:
        pdbfile_in (str): Input PDB file path.
        pdbfile_out (str): Output PDB file path.
    """
    fixer = PDBFixer(filename=pdbfile_in)
    fixer.findMissingResidues()
    fixer.findNonstandardResidues()
    fixer.replaceNonstandardResidues()
    fixer.removeHeterogens(False)
    fixer.findMissingAtoms()
    fixer.addMissingAtoms()
    app.PDBFile.writeFile(fixer.topology, fixer.positions, open(pdbfile_out, "w"))


def solvate_protein(
    pdbfile_in: str,
    pdbfile_out: str,
    gmx_prefix: str = "SYSTEM",
    forcefield: str = "amber14-all.xml",
    water_model: str = "amber14/tip3pfb.xml",
    ion_strength: float = 0.15,
    positive_ion: str = "K+",
    negative_ion: str = "Cl-",
    padding: float = 1.0,
    temperature: float = 300.0,
    time_step_fs: float = 2.0,
):
    """
    Solvate model and add ions.

    Args:
        pdbfile_in (str): Input PDB file path.
        pdbfile_out (str): Output PDB file path.
        gmx_prefix (str): Prefix for GROMACS files.
        forcefield (str): Forcefield file path.
        water_model (str): Water model file path.
        ion_strength (float): Ionic strength in molar.
        positive_ion (str): Positive ion type.
        negative_ion (str): Negative ion type.
        padding (float): Padding distance in nanometers.
        temperature (float): Simulation temperature in Kelvin.
        time_step_fs (float): Time step in femtoseconds.
    """
    pdb = app.PDBFile(pdbfile_in)
    forcefield = app.ForceField(forcefield, water_model)
    modeller = app.Modeller(pdb.topology, pdb.positions)
    modeller.addHydrogens(forcefield, pH=7.0)

    modeller.addSolvent(
        forcefield,
        padding=padding * openmm.unit.nanometers,
        ionicStrength=ion_strength * openmm.unit.molar,
        positiveIon=positive_ion,
        negativeIon=negative_ion,
    )

    system = forcefield.createSystem(
        modeller.topology,
        nonbondedMethod=app.PME,
        nonbondedCutoff=1 * openmm.unit.nanometer,
        constraints=app.HBonds,
        rigidWater=False,
    )  # required to convert to gromacs

    integrator = openmm.LangevinMiddleIntegrator(
        temperature * openmm.unit.kelvin,
        1 / openmm.unit.picosecond,
        time_step_fs * openmm.unit.femtoseconds,
    )

    simulation = app.Simulation(modeller.topology, system, integrator)
    simulation.context.setPositions(modeller.positions)
    simulation.minimizeEnergy()
    positions = simulation.context.getState(getPositions=True).getPositions()

    app.PDBFile.writeFile(
        simulation.topology, positions, open(os.path.basename(pdbfile_out), "w")
    )

    pmd_structure = parmed.openmm.load_topology(
        simulation.topology, system=system, xyz=positions
    )

    pmd_structure.save(f"{gmx_prefix}.top", overwrite=True)
    pmd_structure.save(f"{gmx_prefix}.gro", overwrite=True)


def main():
    """
    Main function to execute the script.
    """
    args = parse_args()
    pdbfile, out_filename = args.input_pdb, args.output_pdb
    if args.verbose:
        logging.basicConfig(level=logging.DEBUG)

    temp_pdb_filename = f"fixed_{os.path.basename(pdbfile)}"
    fix_structure(pdbfile, temp_pdb_filename)
    simulation = solvate_protein(temp_pdb_filename, out_filename)


if __name__ == "__main__":
    main()
