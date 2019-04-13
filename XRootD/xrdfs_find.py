#!/usr/bin/env python
import argparse, itertools, os, re
from operator import ior

# Must use a python release from CMSSW 93X or higher for the pyxrootd bindings
min_cmssw_version = (9,3,0)
try:
	cmssw_version = tuple(os.environ['CMSSW_VERSION'].split('_')[1:4])
except:
	cmssw_version = (0,0,0)
if cmssw_version < min_cmssw_version:# and not kwargs['ignore_cmssw']:
	raise RuntimeError("Must be using CMSSW_%s_%s_%s or higher to get the pyxrootd bindings. You are currently using CMSSW_%s_%s_%s or some variant." % (min_cmssw_version+cmssw_version))
else:
	from XRootD import client
	from XRootD.client.flags import DirListFlags, StatInfoFlags, OpenFlags, MkDirFlags, QueryCode

# pyxrootd does not tell you what flags the or'ed value to which they correspond.
# Thus we need to form a mappign between the or'ed values and the flags they represent.
# This will be used by the isdir() function and need only be computed onece.
BitwiseOrOfStatInfoFlags = {0:[0]}
for n in range(1,8):
	for n_combination in itertools.combinations(StatInfoFlags.reverse_mapping.keys(), n):
		BitwiseOrOfStatInfoFlags[reduce(ior,list(n_combination))] = list(n_combination)


def endslash_check(string):
	"""
	Check if a path has a trailing '/' for safety purposes.
	"""
	if string!="" and string[-1]=="/": return string
	else: return string+"/"

def isdir(flag):
	"""
	Returns True if the flag indicates the entry is a director and False otherwise.
	"""
	return StatInfoFlags.IS_DIR in BitwiseOrOfStatInfoFlags[flag]

def startslash_check(string):
	"""
	On some servers xrdfs.dirlist returns a filename with a starting '/'. This prevents os.path.join from working as it things the item is an absolute path.
	This function will remove the starting slash if necessary.
	"""
	if string!="" and string[0]=="/": return string[1:]
	else: return string

def walk(xrdfs, top, depth=1, topdown=True, onerror=None, maxdepth=9999, filename_filter="", fullpath=False, xurl=False, skipstat=''):
	"""Directory tree generator for an XRootD file system.

	For each directory in the directory tree rooted at top (including top
	itself, but excluding '.' and '..'), yields a 3-tuple

		dirpath, dirnames, filenames

	dirpath is a string, the path to the directory.  dirnames is a list of
	the names of the subdirectories in dirpath (excluding '.' and '..').
	filenames is a list of the names of the non-directory files in dirpath.
	Note that by default the names in the lists are just names, with no path
	components.	To get a full path (which begins with top) to a file or directory
	in dirpath, do os.path.join(dirpath, name) or run with fullpath=True.

	If optional arg 'topdown' is true or not specified, the triple for a
	directory is generated before the triples for any of its subdirectories
	(directories are generated top down).  If topdown is false, the triple
	for a directory is generated after the triples for all of its
	subdirectories (directories are generated bottom up).

	When topdown is true, the caller can modify the dirnames list in-place
	(e.g., via del or slice assignment), and walk will only recurse into the
	subdirectories whose names remain in dirnames; this can be used to prune the
	search, or to impose a specific order of visiting.  Modifying dirnames when
	topdown is false is ineffective, since the directories in dirnames have
	already been generated by the time dirnames itself is generated. No matter
	the value of topdown, the list of subdirectories is retrieved before the
	tuples for the directory and its subdirectories are generated.

	By default errors from the xrdls() call are ignored.  If
	optional arg 'onerror' is specified, it should be a function; it
	will be called with one argument, an os.error instance.  It can
	report the error to continue with the walk, or raise the exception
	to abort the walk.  Note that the filename is available as the
	filename attribute of the exception object.

	Caution:  if you pass a relative pathname for top, don't change the
	current working directory between resumptions of walk.  walk never
	changes the current directory, and assumes that the client doesn't
	either.

	Example:

	from xrdfs_find import walk
	from XRootD import client
	xrdfs = client.FileSystem(<xrootd_endpoint>)
	for root, dirs, files in walk(xrdfs,<path>,fullpath=True):
		print root
		print dirs
		print files
		if 'noreplica' in dirs:
			dirs.remove('noreplica') # don't visit noreplica directories
	"""

	join = os.path.join

	# We may not have read permission for top, in which case we can't
	# get a list of the files the directory contains.  os.path.walk
	# always suppressed the exception then, rather than blow up for a
	# minor reason when (say) a thousand readable directories are still
	# left to visit.  That logic is copied here.
	try:
		# Note that listdir and error are globals in this module due
		# to earlier import-*.
		names = xrdls(xrdfs,top,False,skipstat)
	except OSError: #error, err:
		if onerror is not None:
			onerror(OSError)
		return

	dirs, nondirs = [], []
	for name in names:
		if isdir(names[name]):
			dirs.append(endslash_check(name))
		else:
			# filter filenames based on pattern
			if len(re.findall(filename_filter,name))>=1:
				nondirs.append(join(str(xrdfs.url)+top,name) if xurl else join(top,name) if fullpath else name)
			else:
				continue

	if topdown:
		yield str(xrdfs.url)+top if xurl else top, dirs, [join(str(xrdfs.url)+top,d) if xurl else join(top,d) if fullpath else d for d in dirs], nondirs
	for name in dirs:
		new_path = join(top, name)
		if depth<maxdepth:
			for x in walk(xrdfs, new_path, topdown=topdown, depth=depth+1, onerror=onerror, maxdepth=maxdepth, fullpath=fullpath, xurl=xurl, skipstat=skipstat):
				yield x
	if not topdown:
		yield str(xrdfs.url)+top if xurl else top, dirs, [join(str(xrdfs.url)+top,d) if xurl else join(top,d) if fullpath else d for d in dirs], nondirs

def xrdls(xrdfs, directory, fullpath=True, skipstat=''):
	"""
	Takes in an XRootD file system object and a directory path.
	Returns a dictionary of files inside the directory and their or'ed statinfo flags (an integer).
	If fullpath is set to True then the filenames include the directory path.
	"""

	prefix = directory+"/" if fullpath else ""

	if skipstat!='':
		status, listing = xrdfs.dirlist(directory)
		if status.status != 0:
			raise Exception("XRootD failed to stat %s%s" % (str(xrdfs.url),directory))
		return {("%s%s" % (prefix, startslash_check(entry.name))) : xrdfs.stat(endslash_check(directory)+entry.name)[1].flags if skipstat not in entry.name else not StatInfoFlags.IS_DIR for entry in listing}
	else:
		status, listing = xrdfs.dirlist(directory,DirListFlags.STAT)
		if status.status != 0:
			raise Exception("XRootD failed to stat %s%s" % (str(xrdfs.url),directory))
		# listing object has more metadata than name and statinfo.flags
		return {("%s%s" % (prefix, startslash_check(entry.name))) : entry.statinfo.flags for entry in listing}

def locate_disk_server(xrdfs,path,debug=False):
	"""
	Takes in an XRootD file system object and a directory path.
	Returns an XRootD file system object
	"""
        if debug: print "xrdfs_find::locate_disk_server Finding list of path locations ... "
	status, locations = xrdfs.deeplocate(path, OpenFlags.NOWAIT)
        if debug: print "xrdfs_find::locate_disk_server List of locations found."
	if status.status != 0:
		raise Exception("XRootD failed to locate %s%s" % (str(xrdfs.url),path))
	for location in locations:
                if debug: print "\tTrying location root://"+str(location.address)+"/"
		xrdfs_tmp = client.FileSystem("root://"+location.address+"/")
		status, listing = xrdfs_tmp.dirlist(path)
		if status.code == 0:
                        if debug: print "xrdfs_find::locate_disk_server Valid address is root://"+str(location.address)+"/"
			return xrdfs_tmp
	raise Exception("XRootD failed to locate any valid disk servers for %s%s" % (str(xrdfs.url),path))

def xrdfs_find(xrootd_endpoint, path, bottomup=False, childcount=False, count=False, debug=False, directories_only=False, files_only=False, \
               fullpath=False, grep=[], ignore=[], ignore_cmssw=False, maxdepth=9999, name='', quiet=False, skipstat='', vgrep=[], xurl=False):
	"""
	Returns a list of files and directories found within <xrootd_enpoint>/path/.
	This is the XRootD equivalent to the 'eos <xrootd_endpoint> find' command.
	"""
	
	xrdfs = client.FileSystem(xrootd_endpoint)

	# In case the user passed in a redirector, rather than an XRootD endpoint, we need to do a deeplocate to find the actual file server
	# The file servers will be looped over in the order they are returned. The first one able to return a valid dirlist will be used.
	# The validity check is to make sure that the server we will use is actually working and not just a black hole.
	xrdfs = locate_disk_server(xrdfs,path,debug)

	all_files = []
	all_directories = []

	for root, walkdirs, dirs, files in walk(xrdfs,path,topdown=not bottomup, maxdepth=maxdepth, filename_filter=name, fullpath=fullpath, xurl=xurl, skipstat=skipstat):
		if debug:
			print root
			print dirs
			print files

		# Filter files by grep and vgrep
		if len(grep)>0:
			files = [f for f in files if any(g in os.path.join(root,f) for g in grep)]
		if len(vgrep)>0:
			files = [f for f in files if not any(g in os.path.join(root,f) for g in vgrep)]

		# Append the files to the found list
		if files_only or not (files_only or directories_only):
			all_files += files

		if directories_only or not (files_only or directories_only):
			# Add in the fullpath or xurl if necessary
			current_dir = endslash_check(root) if xurl or fullpath else endslash_check(root.replace(path,''))

			# Filter directories by grep and vgrep
			pass_grep = len(grep) == 0 or any(g in current_dir for g in grep)
			pass_vgrep = len(vgrep) == 0 or not any(g in current_dir for g in vgrep)

			# Append the directories to the found list
			if pass_grep and pass_vgrep:
				all_directories.append((current_dir,len(dirs),len(files)))

		# Ignore a given path during future recursion
		if len(ignore)>0:
			walkdirs[:] = [d for d in walkdirs if not any(i in d for i in ignore)]

	if count:
		# If the count option is set, return the number of files and folders found
		if not quiet:
			print "nfiles="+str(len(all_files))+" ndirectories="+str(len(all_directories))
		return len(all_files), len(all_directories)
	else:
		# If not count, then return the list of files and the list of folders
		if not quiet:
			if len(all_files) > 0:
				print '\n'.join(map(str,all_files))
			if len(all_directories) > 0:
				if childcount:
					print '\n'.join("%s ndir=%i nfiles=%i" % tup for tup in all_directories)
				else:
					print '\n'.join("%s" % tup[0] for tup in all_directories)
		return all_files, [tup[0] for tup in all_directories]

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="""
Recursively find files and folders in an XRootD based file system.

Dependencies:
=============
  - pyxrootd: Must use CMSSW_9_3_X or higher. Can get around this using something like LCG_94.

Examples of how to run as a CLI:
================================
xrdfs_find.py --help
xrdfs_find.py root://cmseos.fnal.gov/ /store/user/<user>/<path>/
xrdfs_find.py root://cmseos.fnal.gov/ -p /store/user/<user>/<path>/ -n \\bTTJets

Example of how to run as interactive python:
============================================
source /cvmfs/sft.cern.ch/lcg/views/LCG_95apython3/x86_64-centos7-gcc8-opt/setup.sh
python
from XRootD import client
from XRootD.client.flags import DirListFlags, StatInfoFlags, OpenFlags, MkDirFlags, QueryCode

xrdfs = client.FileSystem("<xrootd_endpoint>")
status, listing = xrdfs.dirlist("/store/user/<path>",DirListFlags.STAT)
print status

xrdfs = client.FileSystem("<xrootd_endpoint>")
status, locations = xrdfs.deeplocate("/store/user/<path>", OpenFlags.NOWAIT)
print locations
print locations.__dict__['locations'][0].address
xrdfs2 = client.FileSystem("root://"+locations.__dict__['locations'][0].address)
status, listing = xrdfs2.dirlist("/store/user/<path>",DirListFlags.STAT)
print status
print listing

xrdfs = client.FileSystem("<xrootd_endpoint>")
status, locations = xrdfs.deeplocate("/store/user/<path>", OpenFlags.NOWAIT)
print locations

import xrdfs_find
xrdfs_find.xrdls(xrdfs,"/store/user/<path>")
xrdfs_find.xrdfs_find("<xrootd_endpoint>","/store/user/<path>", maxdepth=1)

Examples of how to run as a python module:
==========================================
import xrdfs_find
args = {'count': False, 'files_only': False, 'ignore_cmssw': False, 'name': '', 'xurl': False, \
		'directories_only': False, 'maxdepth': 9999, 'path': '<path>', 'debug': False, 'quiet': True, \
		'fullpath': False, 'bottomup': False, 'childcount': False, 'xrootd_endpoint': '<endpoint>'}
xrdfs_find.xrdfs_find(**args)
xrdfs_find.xrdfs_find(<xrootd_endpoint>,<path>)
""",
									 epilog="",
									 formatter_class=argparse.RawDescriptionHelpFormatter)
	parser.add_argument("xrootd_endpoint",			metavar='mgm-url',									help="XRootD URL of the management server e.g. root://<hostname>[:<port>]")
	parser.add_argument("-b",	"--bottomup",		action="store_true",								help="The default for walk is to go from top down. This replaces that with a bottom \
	                    																					  up approach. (default = %(default)s)")
	parser.add_argument("-c",	"--count",			action="store_true",								help="Just print global counters for files/dirs found (default = %(default)s)")
	parser.add_argument(		"--childcount",		action="store_true",								help="Print the number of children in each directory (default = %(default)s)")
	parser.add_argument("-D",	"--debug",			action="store_true",								help="Print debugging information (default = %(default)s)")
	parser.add_argument("-d",	"--directories",	action="store_true",	dest="directories_only",	help="Find directories in <path> (default = %(default)s)")
	parser.add_argument("-f",	"--files",			action="store_true",	dest="files_only",			help="Find files in <path> (default = %(default)s)")
	parser.add_argument("-F",	"--fullpath",		action="store_true",								help="Return the full path of the file/folder (default = %(default)s)")
	parser.add_argument("-g",	"--grep",			default=[],				nargs="+",					help="List of patterns to select for in both file and directory names (default = %(default)s)")
	parser.add_argument("-i",	"--ignore",			default=[],				nargs="+",					help="List of patterns to ignore for folder names. Unlike vgrep, which is a mask, ignore will \
	                    																					  stop the recursion from going down any path which matches on of these patterns. (default = %(default)s)")
	parser.add_argument("-I",	"--ignore_cmssw",	action="store_true",								help="Ignore the CMSSW dependency in case using some other source for python with \
	                    																					  the necessary libraries (default = %(default)s)")
	parser.add_argument("-m",	"--maxdepth",		default=9999, 			type=int,					help="Descend only <maxdepth> levels (default = %(default)s)")
	parser.add_argument("-n",	"--name",			default="",											help="Find filename by regex (default = %(default)s)")
	parser.add_argument("-q",	"--quiet",			action="store_true",								help="Supress all printouts (default = %(default)s)")
	parser.add_argument("-s",	"--skipstat",		default="",											help="If this is set, do not automatically get the stat information for a directory. Only stat the \
	                    																					  files/folders with this key. A good choice would be a period. This is useful for very large \
	                    																					  directories. (default = $(default)s)")
	parser.add_argument("-x",	"--xurl",			action="store_true",								help="Print the XRootD URL instead of the path name (default = %(default)s)")
	parser.add_argument("-v",	"--vgrep",			default=[],				nargs="+",					help="List of patterns to ignore in both file and directory names (default = %(default)s)")
	parser.add_argument("path",																			help="The path in which to search for files and directories")

	args = parser.parse_args()

	xrdfs_find(**vars(args))
