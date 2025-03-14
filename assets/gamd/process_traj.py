#!/usr/bin/env python3

import argparse

import mdaencore
import MDAnalysis as mda

# Load the trajectory and topology
parser = argparse.ArgumentParser()
parser.add_argument("-i", type=str, required=True)
parser.add_argument("-t", type=str, required=True)
parser.add_argument("-o", type=str, required=True)

args = parser.parse_args()
pdbfile = args.i
trajfile = args.t
out_prefix = args.o
universe = mda.Universe(pdbfile, trajfile)

cluster_collection = mdaencore.clustering.cluster.cluster(
    universe, method=mdaencore.clustering.ClusteringMethod.DBSCAN(eps=0.5), n_cores=4)

outfiles = []
for i, cluster in enumerate(cluster_collection):
    center_universe = mda.Universe(pdbfile, trajfile) # Re-load universe to avoid issues
    center_universe.trajectory[cluster.centroid] # Go to the frame of the cluster center
    center_atoms = center_universe.select_atoms('protein') # Select all atoms for saving
    out_filename = f'{out_prefix}_{i+1}.pdb'
    center_atoms.write(out_filename) # Save as PDB with unique name
    outfiles.append(out_filename)

print("Cluster centers saved as PDB files: " + ", ".join(outfiles))