#!/usr/bin/env python3

"""This module allows one to calculate the size and size per event of a TTree.
It also figures out the size per event of the various branches and of specific groups of branches.
The branch/group information also shows how big, as a percentage, the branch is and keeps a running sum of the fractional size.
"""

from __future__ import print_function
import argparse
from enum import Enum
import os
import subprocess
import sys
try:
    import uproot
except ImportError as imperr:
    raise ImportError("Could not find the module uproot. Check that it is installed on your system.") from imperr

class Unit(Enum):
    """Enum class containing information pertaining ot the units of file/branch/group sizes."""

    # pylint: disable=invalid-name
    Byte = 1024**0
    KiB  = 1024**1
    MiB  = 1024**2
    GiB  = 1024**3
    TiB  = 1024**4

    def __str__(self):
        return self.name

    @staticmethod
    def from_string(s):
        """Return the enum corresponding to a given string name."""
        try:
            return Unit[s]
        except KeyError as keyerr:
            raise ValueError() from keyerr

class TTreeInfo:
    """Contains information pertaining to the entire TTree."""
    def __init__(self, nentries = 0, nbranches=0, sum_of_branch_sizes=0):
        self.nentries = nentries
        self.nbranches = nbranches
        self.sum_of_branch_sizes = sum_of_branch_sizes

    def get_size(self, unit=Unit.Byte):
        """Return the size of the entire TTree."""
        return self.sum_of_branch_sizes / float(unit.value)

    def get_size_per_event(self, unit=Unit.Byte):
        """Return the size of the TTree per event."""
        return self.sum_of_branch_sizes / self.nentries / float(unit.value)

class TBranchInfo:
    """Contains information pertaining to a single branch."""
    def __init__(self, name, size=0):
        self.name = name
        self.size = size

    def get_size_per_event(self, nentries, unit=Unit.Byte):
        """Return the size of the branch per event."""
        return self.size / float(nentries) / float(unit.value)

    def get_fraction(self, den):
        """Return the fractional size, as a percentage, with member 'size' as the numerator and the denominator
        being passed to the function. Usually the denominator is the total size of all branches or all branches
        before a specific index.
        """
        return 100.0 * self.size / float(den)

class GroupInfo:
    """Contains information pertaining to a group of branches."""
    def __init__(self, name):
        self.name = name
        self.size = 0

    def get_size_per_event(self, nentries, unit=Unit.Byte):
        """Return the size of the group per event."""
        return self.size / float(nentries) / float(unit.value)

    def get_fraction(self, den):
        """Return the fractional size, as a percentage, with member 'size' as the numerator and the denominator
        being passed to the function. Usually the denominator is the total size of all branches or all branch
        groups before a specific index.
        """
        return 100.0 * self.size / float(den)

def does_not_contain(find, the_list, the_filter):
    """Return True if  'the_list' does not contain the object 'find'.
    The argument 'the_filter' allows for a function (lambda) to be passed in just in case the type of 'find' is not trivial.
    """
    for list_item in the_list:
        if the_filter(list_item, find):
            return False
    return True

def run_checks(filename):
    """Run some checks to make sure the program will run smoothly.
    This function is just trying to head off errors which might occur later otherwise.
    """
    print("Running sanity checks before proceeding ...")

    # Check that the ROOT file exists
    if 'root://' in filename:
        key = "root://"
        redir = filename[:filename.find('/', filename.find(key) + len(key)) + 1]
        file_portion = filename[filename.find('/', filename.find(key) + len(key)) + 1:]
        with subprocess.Popen(f"xrdfs {redir} stat {file_portion}",
                            shell=True,
                            stdout = subprocess.DEVNULL,
                            stderr = subprocess.DEVNULL) as process:
            if process.poll():
                raise FileNotFoundError("The input file (" + str(filename) + ") does not exist!")
        with subprocess.Popen(f"xrdfs {redir} stat -q IsDir {file_portion}",
                            shell=True,
                            stdout = subprocess.DEVNULL,
                            stderr = subprocess.DEVNULL) as process:
            if process.poll():
                raise IsADirectoryError("The input filename (" + str(filename) + ") is not a file, but a directory!")
    else:
        if not os.path.exists(filename):
            raise FileNotFoundError("The input file (" + str(filename) + ") does not exist!")
        if not os.path.isfile(filename):
            raise IsADirectoryError("The input filename (" + str(filename) + ") is not a file, but a directory!")
    filename, file_extension = os.path.splitext(filename)
    if file_extension != ".root":
        raise TypeError("The input file ("+str(filename)+") is not a ROOT file!")

    return True

def running_total_size(the_list, end_index):
    """Calculate the size taken by all branches from index 0 to end_index."""
    return sum([l.size for l in the_list][:end_index])

def running_total_fraction(the_list, end_index, den):
    """Calculate the fraction of the event size taken by all branches from index 0 to end_index."""
    return 100.00 * running_total_size(the_list, end_index) / float(den)

# pylint: disable=too-many-locals
def analyze_tfile_sizes(filename,
                        branch_unit = Unit.Byte,
                        debug = False,
                        sort = False,
                        tbranch = "",
                        tdirectory = "",
                        ttree = "",
                        uncompressed = False,
                        tree_unit = Unit.Byte):
    """Main function for coordinating the calculation of the branch/group sizes and the output formatting."""
    if not run_checks(filename):
        raise Exception("Unable to pass the basic sanity checks!")

    # Open the file and access the tree
    file = uproot.open(filename)
    treename = ttree
    if tdirectory != "":
        treename = tdirectory + "/" + treename
    tree = file[treename]

    # Show the tree structure
    if debug:
        print("Showing the TTree format:")
        tree.show()

    # Get the sum of all of the branches
    keycache = {}
    ttreeinfo = TTreeInfo(nentries = len(tree), nbranches = len(tree.values()))
    tbranchinfo_list = []
    groupinfo_list = []
    for branch in tree.values():
        if tbranch not in ("", branch.name):
            continue
        size_bytes = branch.uncompressed_bytes if uncompressed else branch.compressed_bytes
        tbranchinfo_list.append(TBranchInfo(branch.name,size_bytes))
        ttreeinfo.sum_of_branch_sizes += tbranchinfo_list[-1].size
        group_name = branch.name[0:branch.name.find("_")] if branch.name.find("_") >= 0 else \
                     branch.name[0:branch.name.find(".")] if branch.name.find("fCoordinates") >= 0 else branch.name
        if does_not_contain(group_name, groupinfo_list, lambda x,y: x.name == y):
            groupinfo_list.append(GroupInfo(group_name))
        groupinfo_list[-1].size += tbranchinfo_list[-1].size

    # Sort the lists if necessary
    if sort:
        tbranchinfo_list.sort(key = lambda x: x.size, reverse = True)
        groupinfo_list.sort(key = lambda x: x.size, reverse = True)

    # Print the information
    wbytes = 10
    wother = 11
    max_length = max(len(tbranchinfo.name) for tbranchinfo in tbranchinfo_list)
    fmt_header = "{0:{1}s} {2:>{3}s} {4:>{5}s} {6:>{7}s}{8:s}{9:{10}s} {11:>{12}s} {13:>{14}s} {15:>{16}s}"
    fmt_total = "{0:{1}s} {2:{3}.2f} {4:>{5}s} {6:>{7}s}"
    fmt = "{0:{1}s} {2:{3}.2f} {4:{5}.2f} {6:{7}.2f}"

    print("\nFile: "+filename)
    print("Tree: {0}".format(treename))
    print("Entries: {0:,d}".format(ttreeinfo.nentries))
    print("Size: {0:0.2f} {1} ({2})".format(ttreeinfo.get_size(tree_unit),
                                            tree_unit.name,
                                            "uncompressed" if uncompressed else "compressed"))
    print("Size/Entry: {0:0.2f} {1} ({2})\n".format(ttreeinfo.get_size_per_event(tree_unit),
                                                    tree_unit.name,
                                                    "uncompressed" if uncompressed else "compressed"))
    print(fmt_header.format("Branch name",
                            max_length,
                            branch_unit.name + "/ev",
                            wbytes,
                            "Frac. [%]",
                            wother,
                            "Cumulative",
                            wother,
                            " "*6,
                            "Branch group name",
                            max_length,
                            branch_unit.name + "/ev",
                            wbytes,
                            "Frac. [%]",
                            wother,
                            "Cumulative",
                            wother))
    print("=" * (max_length + wbytes + 2 * wother + 3) + " " * 6 + "=" * (max_length + wbytes + 2*wother + 3))
    print(fmt_total.format("Total",
                           max_length,
                           ttreeinfo.get_size_per_event(branch_unit),
                           wbytes,
                           "100.00",
                           wother,
                           "-",
                           wother) \
          + " " * 6 + fmt_total.format("Total",
                                       max_length,
                                       ttreeinfo.get_size_per_event(branch_unit),
                                       wbytes,
                                       "100.00",
                                       wother,
                                       "-",
                                       wother))
    for itbi, tbi in enumerate(tbranchinfo_list):
        string_to_print = fmt.format(tbi.name,
                                     max_length,
                                     tbi.get_size_per_event(ttreeinfo.nentries, branch_unit),
                                     wbytes,
                                     tbi.get_fraction(ttreeinfo.sum_of_branch_sizes),
                                     wother,
                                     running_total_fraction(tbranchinfo_list,
                                                            itbi + 1,
                                                            ttreeinfo.sum_of_branch_sizes),
                                     wother)
        string_to_print += " " * 6
        if itbi < len (groupinfo_list):
            string_to_print += fmt.format(groupinfo_list[itbi].name,
                                          max_length,
                                          groupinfo_list[itbi].get_size_per_event(ttreeinfo.nentries, branch_unit),
                                          wbytes,
                                          groupinfo_list[itbi].get_fraction(ttreeinfo.sum_of_branch_sizes),
                                          wother,
                                          running_total_fraction(groupinfo_list, itbi + 1, ttreeinfo.sum_of_branch_sizes),
                                          wother)
        print(string_to_print)

    return ttreeinfo, tbranchinfo_list, groupinfo_list

if __name__ == '__main__':
    #program name available through the %(prog)s command
    parser = argparse.ArgumentParser(description="Return the average size of an event from a ROOT file",
                                     epilog="And those are the options available. Deal with it.")
    parser.add_argument("filename", help="The full path and name of the ROOT file to analyze")
    parser.add_argument("--branch_unit", default=Unit.Byte, type=Unit.from_string, choices=list(Unit),
                        help="The base unit used to return the per event size of a branch (default=%(default)s)")
    parser.add_argument("-d","--debug", action="store_true",
                        help="Shows some extra information in order to debug this program (default=%(default)s)")
    parser.add_argument("-s","--sort", default=False, action="store_true",
                        help="Short the branches and groups by size rather than by name (default=%(default)s)")
    parser.add_argument("--tbranch", default="",
                        help="The name of a specific TBranch to study (default=%(default)s)")
    parser.add_argument("--tdirectory", default="TreeMaker2",
                        help="The TDirectory name within the TFile containing the TTree (default=%(default)s)")
    parser.add_argument("--ttree", default="PreSelection",
                        help="The TTree name within the chosen TFile and TDirectory (default=%(default)s)")
    parser.add_argument("-u","--uncompressed", default=False, action="store_true",
                        help="Return the uncompressed sizes rather than the compressed sizes (default=%(default)s)")
    parser.add_argument("--tree_unit", default=Unit.KiB, type=Unit.from_string, choices=list(Unit),
                        help="The base unit used to return the size of the tree (default=%(default)s)")
    parser.add_argument('--version', action='version', version='%(prog)s v1.0')
    args = parser.parse_args()

    if args.debug:
        print('Number of arguments:', len(sys.argv), 'arguments.')
        print('Argument List:', str(sys.argv))
        print("Argument", args)

    analyze_tfile_sizes(**vars(args))
