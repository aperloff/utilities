#!/usr/bin/env python3

"""This module allows one to calculate the size and <size per event> of an entire dataset.
For simplicity, we are forgoing the calculation of the size per event per branch calculation.
"""

from __future__ import print_function
import argparse
import dask
from dask.diagnostics import ProgressBar
import distributed
import importlib.util
import os
import subprocess
import sys
try:
    import uproot
except ImportError as imperr:
    raise ImportError("Could not find the module uproot. Check that it is installed on your system.") from imperr

from AnalyzeTFileSizes import TTreeInfo, Unit

HOME = os.environ["HOME"]
spec = importlib.util.spec_from_file_location("xrdfs_find", f"{HOME}/Scripts/utilities/XRootD/xrdfs_find.py")
xrdfs_find = importlib.util.module_from_spec(spec)
spec.loader.exec_module(xrdfs_find)

def get_file_list(path):
    print("Retrieving file list ... ", end = '')
    file_list = []
    if 'root://' in path:
        key = "root://"
        redir = path[:path.find('/', path.find(key) + len(key)) + 1]
        path_portion = path[path.find('/', path.find(key) + len(key)) + 1:]
        file_list, _ = xrdfs_find.xrdfs_find(xrootd_endpoint = redir, path = path_portion, files_only = True, fullpath = True, quiet = True, xurl = True)
    else:
        _, _, file_list = next(walk(path), (None, None, []))
    print("DONE")
    return file_list

def get_results_string(path, nfiles, treename, ttreeinfo, dataset_unit, entry_unit, uncompressed):
    output_string = f"Basepath for files: {path}\n"
    output_string += f"Number of files in sample: {nfiles}"
    output_string += f"Tree: {treename}\n"
    output_string += f"Entries: {ttreeinfo.nentries:,d}\n"
    output_string += "Size: {0:0.2f} {1} ({2})\n".format(ttreeinfo.get_size(dataset_unit),
                                                         dataset_unit.name,
                                                         "uncompressed" if uncompressed else "compressed")
    output_string += "<Size/Entry>: {0:0.2f} {1} ({2})\n".format(ttreeinfo.get_size_per_event(entry_unit),
                                                                 entry_unit.name,
                                                                 "uncompressed" if uncompressed else "compressed")
    return output_string

def open_file_get_tree(filename, ttree, tdirectory):
    with uproot.open(filename) as file:
        treename = ttree
        if tdirectory != "":
            treename = tdirectory + "/" + treename
        tree = file[treename]
        return treename, tree

def run_checks(path, quiet):
    """Run some checks to make sure the program will run smoothly.
    This function is just trying to head off errors which might occur later otherwise.
    """
    if not quiet:
        print("Running sanity checks before proceeding ... ", end = '')

    # Check that the ROOT file exists
    if 'root://' in path:
        key = "root://"
        redir = path[:path.find('/', path.find(key) + len(key)) + 1]
        path_portion = path[path.find('/', path.find(key) + len(key)) + 1:]
        with subprocess.Popen(f"xrdfs {redir} stat {path_portion}",
                            shell=True,
                            stdout = subprocess.DEVNULL,
                            stderr = subprocess.DEVNULL) as process:
            if process.wait():
                raise FileNotFoundError("The input path (" + str(path) + ") does not exist!")
        with subprocess.Popen(f"xrdfs {redir} stat -q IsDir {path_portion}",
                            shell=True,
                            stdout = subprocess.DEVNULL,
                            stderr = subprocess.DEVNULL) as process:
            if process.wait():
                raise IsADirectoryError("The input path (" + str(path) + ") is not a directory, but a file!")
    else:
        if not os.path.exists(path):
            raise FileNotFoundError("The input path (" + str(path) + ") does not exist!")
        if not os.path.isdirectory(path):
            raise IsADirectoryError("The input path (" + str(path) + ") is not a directory, but a file!")

    if not quiet:
        print("DONE\n")

    return True

# From https://examples.dask.org/delayed.html
@dask.delayed
def sum_ttreeinfo_list(delayed_list):
    ttreeinfo_sum = delayed_list[0]
    for delayed_item in delayed_list[1:]:
        ttreeinfo_sum += delayed_item
    return ttreeinfo_sum

def analyze_dataset_sizes(path,
                          debug = False,
                          dataset_unit = Unit.Byte,
                          entry_unit = Unit.Byte,
                          output = "",
                          quiet = False,
                          tdirectory = "",
                          ttree = "",
                          uncompressed = False):

    """Main function for coordinating the calculation of the tree sizes and the output formatting."""
    if not run_checks(path, quiet):
        raise Exception("Unable to pass the basic sanity checks!")

    # Get a list of files to open
    file_list = get_file_list(path)
    
    if len(file_list) == 0:
        raise RuntimeError(f"Unable to find any files at {path}")

    if debug:
        file_list = file_list[0:10]
    print(f"Number of files to process: {len(file_list)}\n")

    #Open the first file to set the initial tree values
    treename, tree = open_file_get_tree(file_list[0], ttree, tdirectory)
    ttreeinfo = dask.delayed(TTreeInfo)(nentries = tree.num_entries, nbranches = len(tree.values()), sum_of_branch_sizes = tree.uncompressed_bytes if uncompressed else tree.compressed_bytes)
    ttreeinfo_list = [ttreeinfo]

    # Open the remaining files and add the tree values
    for filename in file_list[1:]:
        res = dask.delayed(open_file_get_tree)(filename, ttree, tdirectory)
        _, tree = res[0], res[1]
        ttree_per_file_len = dask.delayed(len)(tree.values())
        ttreeinfo_per_file = dask.delayed(TTreeInfo)(nentries = tree.num_entries, nbranches = ttree_per_file_len, sum_of_branch_sizes = tree.uncompressed_bytes if uncompressed else tree.compressed_bytes)
        ttreeinfo_list.append(ttreeinfo_per_file)

    ttreeinfo_sum = sum_ttreeinfo_list(ttreeinfo_list)
    ttreeinfo_sum.persist()
    distributed.progress(ttreeinfo_sum)
    ttreeinfo_sum_computed = ttreeinfo_sum.compute()
    print(ttreeinfo_sum_computed)

    # Format the output string
    output_string = get_results_string(path, len(file_list), treename, ttreeinfo_sum_computed, dataset_unit, entry_unit, uncompressed)
    
    # Print the output to a text file
    if output != "":
        with open(output, 'w') as ofile:
            ofile.write(output_string)

    # Print the information to standard output
    if not quiet:
        print(output_string)

    return ttreeinfo_sum

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description = "Return the average size of an event from a list of files",
                                     epilog = "And those are the options available. Deal with it.")
    parser.add_argument("path", help = "The base path to the list of files to use")
    parser.add_argument("-d","--debug", action = "store_true",
                        help = "Shows some extra information in order to debug this program (default = %(default)s)")
    parser.add_argument("--dataset_unit", default = Unit.TiB, type = Unit.from_string, choices = list(Unit),
                        help = "The base unit used to return the size of the entire dataset (default = %(default)s)")
    parser.add_argument("--entry_unit", default = Unit.KiB, type = Unit.from_string, choices = list(Unit),
                        help = "The base unit used to return the size of an entry in the tree (default = %(default)s)")
    parser.add_argument("-o", "--output", default = "",
                        help = "If provided, writes the output to a file with the given filename (default = %(default)s)")
    parser.add_argument("-q","--quiet", action = "store_true",
                        help = "Do not print to the console (default = %(default)s)")
    parser.add_argument("--tdirectory", default = "TreeMaker2",
                        help = "The TDirectory name within the TFile containing the TTree (default = %(default)s)")
    parser.add_argument("--ttree", default = "PreSelection",
                        help = "The TTree name within the chosen TFile and TDirectory (default = %(default)s)")
    parser.add_argument("-u","--uncompressed", default = False, action = "store_true",
                        help = "Return the uncompressed sizes rather than the compressed sizes (default = %(default)s)")
    parser.add_argument('--version', action = 'version', version = '%(prog)s v1.0')
    args = parser.parse_args()

    if args.debug:
        print('Number of arguments:', len(sys.argv), 'arguments.')
        print('Argument List:', str(sys.argv))
        print("Argument", args)

    analyze_dataset_sizes(**vars(args))

# singularity shell -B ${PWD}:/work /cvmfs/unpacked.cern.ch/registry.hub.docker.com/coffeateam/coffea-dask:latest/
# python3 ~/Scripts/utilities/ROOT/AnalyzeDatasetSizes.py root://cmseos.fnal.gov//store/user/lpcsusyhad/SusyRA2Analysis2015/Run2ProductionV20/Run2018D-UL2018-v2/EGamma/