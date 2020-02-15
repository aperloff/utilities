#!/usr/bin/env python
from __future__ import print_function
import argparse,os,pkgutil,sys
try:
    import uproot
except ImportError:
    raise ImportError("Could not find the module uproot. Check that it is installed on your system.")

def does_not_contain(find, list, filter):
    for x in list:
        if filter(x,find):
            return False
    return True

class TFileInfo:
    def __init__(self, nentries = 0, nbranches=0, sum_of_branch_sizes=0):
        self.nentries = nentries
        self.nbranches = nbranches
        self.sum_of_branch_sizes = sum_of_branch_sizes

    def get_size_kb(self):
        return self.sum_of_branch_sizes/1024.

    def get_size_per_event(self):
        return self.sum_of_branch_sizes/self.nentries

    def get_size_per_event_kb(self):
        return self.sum_of_branch_sizes/1024./self.nentries

class TBranchInfo:
    def __init__(self, name, size=0):
        self.name = name
        self.size = size
        self.running_total = 0

    def get_size_per_event(self, nentries):
        return self.size/float(nentries)

    def get_fraction(self, den):
        return 100.0*self.size/float(den)

    def get_running_total_fraction(self, den):
        return 100.0*self.running_total/float(den)

class GroupInfo:
    def __init__(self, name):
        self.name = name
        self.size = 0

    def get_size_per_event(self, nentries):
        return self.size/float(nentries)

    def get_fraction(self, den):
        return 100.0*self.size/float(den)

def run_checks(filename):
    print("Running sanity checks before proceeding ...")

    # Check that the ROOT file exists
    if not os.path.exists(filename):
        raise FileNotFoundError("The input file ("+str(filename)+") does not exist!")
    if not os.path.isfile(filename):
        raise IsADirectoryError("The input filename ("+str(filename)+") is not a file, but a directory!")
    filename, file_extension = os.path.splitext(filename)
    if file_extension != ".root":
        raise TypeError("The input file ("+str(filename)+") is not a ROOT file!")

    return True

def analyzeTFileSizes(filename, debug=False, tbranch="", tdirectory="", ttree="", uncompressed=False):
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
    tfileinfo = TFileInfo()
    tfileinfo.nentries = len(tree)
    tfileinfo.nbranches = len(tree.values())
    tbranchinfo_list = []
    groupinfo_list = []
    for branch in tree.values():
        if tbranch!="" and branch.name != tbranch: continue
        size_bytes = branch.uncompressedbytes(keycache=keycache) if uncompressed else branch.compressedbytes(keycache=keycache)
        tbranchinfo_list.append(TBranchInfo(branch.name,size_bytes))
        tfileinfo.sum_of_branch_sizes += tbranchinfo_list[-1].size
        tbranchinfo_list[-1].running_total = tfileinfo.sum_of_branch_sizes
        group_name = branch.name[0:branch.name.find("_")] if branch.name.find("_")>=0 else branch.name
        if does_not_contain(group_name, groupinfo_list, lambda x,y: x.name == y):
            groupinfo_list.append(GroupInfo(group_name))
        groupinfo_list[-1].size += tbranchinfo_list[-1].size

    # Print the information
    wbytes = 10
    wother = 11
    max_length = max(len(tbranchinfo.name) for tbranchinfo in tbranchinfo_list)
    fmt_header = "{0:{1}s} {2:>{3}s} {4:>{5}s} {6:>{7}s}{8:s}{9:{10}s} {11:>{12}s} {13:>{14}s} {15:>{16}s}"
    fmt_total = "{0:{1}s} {2:{3}.2f} {4:>{5}s} {6:>{7}s}"
    fmt = "{0:{1}s} {2:{3}.2f} {4:{5}.2f} {6:{7}.2f}"

    print("\nFile: "+filename)
    print("Tree: {0}".format(treename))
    print("Entries: {0:,d}".format(tfileinfo.nentries))
    print("Size: {0:0.2f} kB ({1})".format(tfileinfo.get_size_kb(),"uncompressed" if uncompressed else "compressed"))
    print("Size/Entry: {0:0.2f} kB ({1})\n".format(tfileinfo.get_size_per_event_kb(),"uncompressed" if uncompressed else "compressed"))
    print(fmt_header.format("Branch name",max_length,"Byte/ev",wbytes,"Frac. [%]",wother,"Cumulative",wother," "*6,"Branch group name",max_length,"Byte/ev",wbytes,"Frac. [%]",wother,"Cumulative",wother))
    print("="*(max_length+wbytes+2*wother+3)+" "*6+"="*(max_length+wbytes+2*wother+3))
    print(fmt_total.format("Total",max_length,tfileinfo.get_size_per_event(),wbytes,"100.00",wother,"-",wother) \
          + " "*6 + \
          fmt_total.format("Total",max_length,tfileinfo.get_size_per_event(),wbytes,"100.00",wother,"-",wother))
    for itbi, tbi in enumerate(tbranchinfo_list):
        s  = fmt.format(tbi.name,max_length,tbi.get_size_per_event(tfileinfo.nentries),wbytes, \
                        tbi.get_fraction(tfileinfo.sum_of_branch_sizes), \
                        wother,tbi.get_running_total_fraction(tfileinfo.sum_of_branch_sizes),wother)
        s += " "*6
        if itbi < len (groupinfo_list):
            s += fmt.format(groupinfo_list[itbi].name,max_length,groupinfo_list[itbi].get_size_per_event(tfileinfo.nentries),wbytes, \
                            groupinfo_list[itbi].get_fraction(tfileinfo.sum_of_branch_sizes),wother, \
                            100.00*sum([gi.size for gi in groupinfo_list][:itbi+1])/tfileinfo.sum_of_branch_sizes,wother)
        print(s)

    return tfileinfo

if __name__ == '__main__':
    #program name available through the %(prog)s command
    parser = argparse.ArgumentParser(description="Return the average size of an event from a ROOT file",
                                     epilog="And those are the options available. Deal with it.")
    parser.add_argument("filename", help="The full path and name of the ROOT file to analyze")
    parser.add_argument("-d","--debug", action="store_true", help="Shows some extra information in order to debug this program (default=%(default)s)")
    parser.add_argument("--tbranch", default="", help="The name of a specific TBranch to study (default=%(default)s)")
    parser.add_argument("--tdirectory", default="TreeMaker2", help="The TDirectory name within the TFile containing the TTree (default=%(default)s)")
    parser.add_argument("--ttree", default="PreSelection", help="The TTree name within the chosen TFile and TDirectory (default=%(default)s)")
    parser.add_argument("-u","--uncompressed", default=False, action="store_true", help="Return the uncompressed sizes rather than the compressed sizes (default=%(default)s)")
    parser.add_argument('--version', action='version', version='%(prog)s v1.0')
    args = parser.parse_args()

    if(args.debug):
         print('Number of arguments:', len(sys.argv), 'arguments.')
         print('Argument List:', str(sys.argv))
         print("Argument", args)

    analyzeTFileSizes(**vars(args))