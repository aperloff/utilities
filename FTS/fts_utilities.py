#!/usr/bin/env python
import argparse, imp, multiprocessing, os, time, subprocess, sys
from itertools import islice
from functools import partial
from contextlib import contextmanager
import getSiteInfo, xrdfs_find
try:
	from tqdm import tqdm
except:
	try:
		sys.path.append("/cvmfs/cms.cern.ch/slc6_amd64_gcc630/external/py2-pippkgs/6.0-omkpbe5/lib/python2.7/site-packages/")
		from tqdm import tqdm
	except ImportError:
		raise ImportError("Could not find tqdm, even in the cvmfs slc6_amd64_gcc630 externals for python2.7")


class col:
	magenta = '\033[96m'
	blue = '\033[94m'
	green = '\033[92m'
	yellow = '\033[93m'
	red = '\033[91m'
	endc = '\033[0m'
	bold = '\033[1m'
	uline = '\033[4m'

def compare_checksum_dicts(args,dict1,dict2):
	header = "Comparing the names and checksums in the dictionaries from " + col.bold + col.blue + args.start + col.endc + " and " + col.bold + col.blue + args.end + col.endc + " ..."
	if args.progress:
		print header
	else:
		print header,
		sys.stdout.flush()
		function_start_time = time.time()

	diff_dict = {key1: dict1[key1] for key1 in tqdm(dict1,ascii=True,desc="",disable=not args.progress,dynamic_ncols=True) if key1 not in dict2 or dict1[key1] != dict2[key1]}

	if not args.progress:
		print_done(function_start_time,time.time())

	if len(diff_dict)>0:
		print col.red + "\tPROBLEM!!! There are either missing files or files with different checksums!" + col.endc
	else:
		print col.green + "\tThe checksums for both lists of files match!" + col.endc

	if args.debug:
		print_partial_list(dict1,"Partial dict of files from " + args.start + ":")
		print_partial_list(dict2,"Partial dict of files from " + args.end + ":")
		print_partial_list(diff_dict,"Partial dict of differences in " + args.start + " and " + args.end +":")

def diff_file_list(args,start_files,end_files):
	print "Comparing the names in the file lists from " + col.bold + col.blue + args.start + col.endc + " and " + col.bold + col.blue + args.end + col.endc + " ...",
	sys.stdout.flush()
	function_start_time = time.time()

	diff_list = list(set(start_files) - set(end_files))

	print_done(function_start_time,time.time())

	if len(diff_list)>0:
		print "\t" + col.bold + col.red + "PROBLEM!!!" + col.endc + " There are missing files at " + col.yellow + args.end + col.endc + "!"
	else:
		print "\tAll files in " + col.yellow + args.indir + col.endc + "at " + col.bold + col.green + args.start + col.endc + \
			  " are in " +col.blue + endslash_check(args.outdir) + args.indir + col.endc +" at " + col.bold + col.red + args.end + col.endc + "."

	if args.debug:
		print_partial_list(start_files,"Partial list of " + str(len(start_files)) + " files from " + args.start + ":")
		print_partial_list(end_files,"Partial list of " + str(len(end_files)) + " files from " + args.end + ":")
		print_partial_list(diff_list,"Partial list of " + str(len(diff_list)) + " differences in " + args.start + " and " + args.end +":")

	return diff_list

def endslash_check(string):
	if string=="" or string[-1]=="/": return string
	else: return string+"/"

def format_and_write_transfer_lines(args,start_site,end_site,start_list):
	print "Formatting and writing the list of files to transfer from " + col.bold + col.blue + start_site.alias + col.endc + " to " + col.bold + col.blue + end_site.alias + col.endc + " ...",
	sys.stdout.flush()
	function_start_time = time.time()

	lines = []
	output_filename = args.listname if args.make else args.missingname
	with open(args.tmp+"/"+output_filename, 'w') as f:
		for item in start_list:
			line = "%s%s/%s %s%s/%s%s\n" % (endslash_check(start_site.pfn),args.user1,item,
											endslash_check(end_site.pfn),args.user2,endslash_check(args.outdir),item)
			f.write(line)
			lines.append(line)

	print_done(function_start_time,time.time())

	if len(lines)>0 and os.path.isfile(args.tmp+"/"+output_filename):
		print "\t" + str(args.listname) + " created " + col.bold + col.green + "successfully!" + col.endc
	elif os.path.isfile(args.tmp+"/"+output_filename) and len(lines)==0:
		print "\t" + str(output_filename) + " created, but it is " + col.bold + col.yellow + "empty!" + col.endc
	else:
		print "\tCreation of " + str(output_filename) + col.bold + col.red +" failed!" + col.endc
	
	return lines

def get_checksum_dict(args=None, site=None, user='', flist=[], quite=False, q=None):
	if not quite:
		header = "Making a dictionary of filenames and checksums for " + col.bold + col.blue + site.alias + col.endc + " ..."
		if args.progress:
			print header
		else:
			print header,
			sys.stdout.flush()
			function_start_time = time.time()

	if args.protocol == "gfal":
		# Example command: gfal-sum gsiftp://cmseos-gridftp.fnal.gov//eos/uscms/store/user/lpcsusyhad/SusyRA2Analysis2015/Run2ProductionV14/PrivateSamples.SVJ_mZprime-1000_mDark-20_rinv-0p3_alpha-0p2_n-1000_0_RA2AnalysisTree.root ADLER32
		# Example output: gsiftp://cmseos-gridftp.fnal.gov//eos/uscms/store/user/lpcsusyhad/SusyRA2Analysis2015/Run2ProductionV14/PrivateSamples.SVJ_mZprime-1000_mDark-20_rinv-0p3_alpha-0p2_n-1000_0_RA2AnalysisTree.root e3b722d9
		cmd = "gfal-sum %s/%s/" % (site.pfn,user)
		split_position = 1;
	elif args.protocol == "xrdfs" and site.alias == "T3_US_FNALLPC":
		# Example command: xrdfs root://cmseos.fnal.gov/ query checksum /store/user/lpcsusyhad/SusyRA2Analysis2015/Run2ProductionV14/PrivateSamples.SVJ_mZprime-1000_mDark-20_rinv-0p3_alpha-0p2_n-1000_0_RA2AnalysisTree.root
		# Example output: adler32 e3b722d9
		cmd = "xrdfs %s query checksum /store/user/%s/" % (site.xrootd_endpoint,user)
		split_position = 1;
	elif args.protocol == "xrdfs":
		# Example command: xrdadler32 root://cmseos.fnal.gov//store/user/lpcsusyhad/SusyRA2Analysis2015/Run2ProductionV14/PrivateSamples.SVJ_mZprime-1000_mDark-20_rinv-0p3_alpha-0p2_n-1000_0_RA2AnalysisTree.root
		# Example output: e3b722d9 root://cmseos.fnal.gov//store/user/lpcsusyhad/SusyRA2Analysis2015/Run2ProductionV14/PrivateSamples.SVJ_mZprime-1000_mDark-20_rinv-0p3_alpha-0p2_n-1000_0_RA2AnalysisTree.root
		cmd = "xrdadler32 %s/store/user/%s/" % (site.xrootd_endpoint,user)
		split_position = 0;
	else:
		raise Exception("get_checksum_dict::Unknown protocol for finding the checksums.")

	csdict = {}

	for file in tqdm(flist,ascii=True,desc="",disable=not args.progress,dynamic_ncols=True):
		cmd_current = cmd + file
		if args.protocol == "gfal": cmd_current += " ADLER32"
		p = subprocess.Popen(cmd_current,shell=True,stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
		out = p.communicate()[0]
		csdict[file] = out.split()[split_position]
		if type(q) != type(None):
			q.put(file)

	if not quite and not args.progress:
		print_done(function_start_time,time.time())

	return csdict

def get_file_list(args,site,user):
	print "Getting file list from " + col.bold + col.blue + site.alias + col.endc + " ...",
	sys.stdout.flush()
	function_start_time = time.time()

	filelist, directories = xrdfs_find.xrdfs_find(site.xrootd_endpoint,"/store/user/%s/%s" % (user,args.indir),
	                                              files_only=True,quiet=True,xurl=True,maxdepth=args.maxdepth,
	                                              skipstat=args.skipstat)
	filelist_stripped = [f[f.find(user)+len(user)+1:] for f in filelist]
	if (args.make or args.compare_names) and args.debug:
		print "\nFound",str(len(filelist)),"at %s/store/user/%s/%s" % (site.xrootd_endpoint,user,args.indir)
		print_partial_list(filelist,"Initial file list:")
		print_partial_list(directories,"Initial directory list:")
		print_partial_list(filelist_stripped,"Stripped file list:")

	if len(args.grep)>0:
		filelist_stripped = [f for f in filelist_stripped if any(g in f for g in args.grep)]
	if len(args.vgrep)>0:
		filelist_stripped = [f for f in filelist_stripped if not any(g in f for g in args.vgrep)]

	print_done(function_start_time,time.time())

	return filelist_stripped

def list_callback(option, opt, value, parser):
    if value is None: return
    setattr(parser.values, option.dest, value.split(','))

def partial_list(lst):
	return "["+str(lst[0:3])[1:-1]+", ... , "+str(lst[-1:])[1:-1]+"]"

@contextmanager
def poolcontext(*args, **kwargs):
    pool = multiprocessing.Pool(*args, **kwargs)
    yield pool
    pool.terminate()

def print_done(start_time=None,end_time=None,prefix="",suffix=""):
	diff = end_time - start_time
	if diff<60.:
		unit = "s"		
	elif diff<3600.:
		unit = "min"
		diff /= 60.
	else:
		unit = "hr"
		diff /= 3600.

	if start_time!=None and end_time!=None:
		print "%s[DONE, %.2f %s]%s" % (prefix,diff,unit,suffix)
	else:
		print "%s[DONE]%s" % (prefix,suffix)

def print_partial_list(lst, header=""):
	if header!="":
		print(header)
	if type(lst)==list or type(lst)==set:
		for l in lst[0:3]:
			print("\t"+l.strip())
		if len(lst)>3:
			print("\t...")
			for l in lst[-1:]:
				print("\t"+l.strip())
	elif type(lst)==dict:
		first_three_keys = list(islice(lst, 3))
		for key in first_three_keys:
			print("\t"+key+": "+str(lst[key]))
		if len(lst)>3:
			print("\t...")
	else:
		raise Exception("ERROR::print_partial_list::Unknown type for lst.")

if __name__ == "__main__":
	# Read parameters
	parser = argparse.ArgumentParser(description="""
Used to format the input file necessary for FTS transfers.

Dependencies:
  - getSiteInfo.py: Python 2.7.11 or higher
  - pyxrootd: Must use CMSSW_9_3_X or higher

Example of how to run:
python fts_utilities.py --help
python fts_utilities.py -s T3_US_FNALLPC -e T3_US_Colorado -i SusyRA2Analysis2015/Run2ProductionV14/ -u1 lpcsusyhad -M
python fts_utilities.py -s T3_US_FNALLPC -e T3_US_Colorado -i SusyRA2Analysis2015/Run2ProductionV14/ -u1 lpcsusyhad -N
python fts_utilities.py -s T3_US_FNALLPC -e T3_US_Colorado -i SusyRA2Analysis2015/Run2ProductionV14/ -u1 lpcsusyhad -C -P -p xrdfs
python fts_utilities.py -s T3_US_FNALLPC -e T3_US_Colorado -i SusyRA2Analysis2015/Run2ProductionV14/ -u1 lpcsusyhad -C -P -p gfal -r None 6 -n 3
python fts_utilities.py -s T3_US_FNALLPC -e T3_US_Colorado -i SusyRA2Analysis2015/Run2ProductionV14/ -u1 lpcsusyhad -C -p gfal -r None None -n 16
	                                 """,
									 epilog="""
To submit the FTS transfer use:
\tfts-transfer-submit -v -s https://cmsfts3.fnal.gov:8446 -f <filelist> -o -K
\t\tYou can overwrite existing files with \"-o\"
\t\tThe \"-K\" is for checksumming
To get the status of your transfer use:
\tfts-transfer-status -v -s https://cmsfts3.fnal.gov:8446 <transfer hex code> -F
Transfers can be monitored at:
\tAll transfers: https://cmsfts3.fnal.gov:8449/fts3/ftsmon/#/
\tSpecific Endpoints: https://cmsfts3.fnal.gov:8449/fts3/ftsmon/#/?vo=&source_se=gsiftp:%2F%2Fcmseos-gridftp.fnal.gov&dest_se=gsiftp:%2F%2Fgridftp-hadoop.colorado.edu&time_window=1
\tSpecific Job: https://cmsfts3.fnal.gov:8449/fts3/ftsmon/#/job/885a78b8-1f69-11e9-9da5-a0369f23d03e
									 """,
									 formatter_class=argparse.RawDescriptionHelpFormatter)
	# Program options
	program_group = parser.add_argument_group(title="Program Options", description="Options that guide the programs flow.")
	program_group.add_argument("-d",	"--debug",													action="store_true",		help="Print debugging information (default = %(default)s)")
	program_group.add_argument("-l",	"--listname",		default="fts_transfer_file_list.txt",								help="The name for the file list (default = %(default)s)")
	program_group.add_argument("-m",	"--missingname",	default="missing_transfer_list.txt",								help="The name of list for the files missing from the destination site (default = %(default)s)")
	program_group.add_argument(			"--maxdepth",		default=9999,							type=int,					help="The maxdepth to use when getting the filelist. See xrdfs_find documentation for more details (default = %(default)s)")
	program_group.add_argument("-n",	"--npool",			default=1,								type=int,					help="The number of simultaneous processes used to process the --compare_checksum option (default = %(default)s)")
	program_group.add_argument("-P",	"--progress",												action="store_true",		help="Displays a progress bar on actions which may take a long time (default = %(default)s)")
	program_group.add_argument("-p",	"--protocol",		default="gfal", 						choices=["gfal","xrdfs"],	help="The protocol to use to get the checksum (default = %(default)s)")
	program_group.add_argument("-r",	"--chk_range",		default=[0,None],						nargs=2,					help="The range of files to checksum from a list (-1 = None) (default = %(default)s)")
	program_group.add_argument(			"--skipstat",		default="",															help="Do not get extra information for files with this key. See xrdfs_find documentation for more details (default = %(default)s)")
	program_group.add_argument("-t",	"--tmp",			default="./",														help="The directory in which to store the file lists (default = %(default)s)")
	program_group_exclusive = program_group.add_mutually_exclusive_group(required=True)
	program_group_exclusive.add_argument("-C",	"--compare_checksum",	action="store_true",	help="Compare the checksums of the files in the input and output directories (default = %(default)s)")
	program_group_exclusive.add_argument("-c",	"--count",				action="store_true",	help="Make and count the file lists, but don't do any copying (default = %(default)s)")
	program_group_exclusive.add_argument("-M",	"--make",				action="store_true",	help="Make the file list needed by FTS (default = %(default)s)")
	program_group_exclusive.add_argument("-N",	"--compare_names",		action="store_true",	help="Compare the file names in the input and output directories to make sure the transfer was successful (default = %(default)s)")

	# FTS options
	endpoint_group = parser.add_argument_group(title="Endpoint Options", description="Options necessary to format the FTS input file and to do the checks after the FTS transfer.")
	endpoint_group.add_argument("-s",	"--start",			default="",					required=True,	help="The starting site (i.e. T3_US_FNALLPC) for the file transfer (default = %(default)s)")
	endpoint_group.add_argument("-e",	"--end",			default="",					required=True,	help="The ending site (i.e. T3_US_FNALLPC) for the file transfer (default = %(default)s)")
	endpoint_group.add_argument("-i",	"--indir",			default="",									help="The EOS directory storing the files to be transfered (default = %(default)s)")
	endpoint_group.add_argument("-o",	"--outdir",			default="",									help="An output directory to contain the input hierarchy (default = %(default)s)")  
	endpoint_group.add_argument("-u1",	"--user1",			default=os.environ["USER"],					help="The username of the input path (default = %(default)s)")
	endpoint_group.add_argument("-u2",	"--user2",			default=os.environ["USER"],					help="The username of the output path (default = %(default)s)")
	endpoint_group.add_argument(		"--start_endpoint",	default="",									help="Override the start site xrootd endpoint (default = %(default)s)")
	endpoint_group.add_argument(		"--end_endpoint",	default="",									help="Override the end site xrootd endpoint (default = %(default)s)")
	endpoint_group.add_argument(		"--start_port",		default="",									help="Override the default start site xrootd endpoint port (default = %(default)s)")
	endpoint_group.add_argument(		"--end_port",		default="",									help="Override the default end site xrootd endpoint port (default = %(default)s)")
	endpoint_group.add_argument("-g",	"--grep",			default=[],					nargs="+",		help="list of patterns in the file list to select for (default = %(default)s)")
	endpoint_group.add_argument("-v",	"--vgrep",			default=[],					nargs="+",		help="list of patterns in the file list to ignore (default = %(default)s)")

	args, unknown = parser.parse_known_args()

	# Must use a python release from CMSSW 93X or higher for the pyxrootd bindings
	min_cmssw_version = (9,3,0)
	try:
		cmssw_version = tuple(os.environ['CMSSW_VERSION'].split('_')[1:4])
	except:
		cmssw_version = (0,0,0)
	if cmssw_version < min_cmssw_version:
		raise RuntimeError("Must be using CMSSW_%s_%s_%s or higher to get the pyxrootd bindings." % min_cmssw_version)

	# If running with npool >1 then can't use a progress bar
	if args.npool > 1: args.progress = False

	# Fix the type of the range option
	for index, value in enumerate(args.chk_range):
		if type(value) == str and value == "None":
			args.chk_range[index] = None
		elif type(value) == str:
			args.chk_range[index] = int(value)
		elif type(value) == int:
			continue

	print "Getting site information for " + col.bold + col.blue + args.start + col.endc + " ...",
	sys.stdout.flush()
	start_site_time = time.time()
	start_site = getSiteInfo.main(site_alias=args.start, debug=False, fast=True, quiet=True)
	print_done(start_site_time,time.time())
	print "Getting site information for " + col.bold + col.blue + args.end + col.endc + " ...",
	sys.stdout.flush()
	end_site_time = time.time()
	end_site = getSiteInfo.main(site_alias=args.end, debug=False, fast=True, quiet=True)
	print_done(end_site_time,time.time())

	if args.start_endpoint!="":
		print "Overriding the xrootd endpoint for " + col.bold + col.blue + args.start + col.endc + " and setting it to " + col.bold + col.yellow + args.start_endpoint + col.endc
		start_site.xrootd_endpoint = args.start_endpoint
	if args.end_endpoint!="":
		print "Overriding the xrootd endpoint for " + col.bold + col.blue + args.end + col.endc + " and setting it to " + col.bold + col.yellow + args.end_endpoint + col.endc
		end_site.xrootd_endpoint = args.end_endpoint
	if args.start_port:
		print "Overriding the default xrootd endpoint port for " + col.bold + col.blue + args.start + col.endc + " and setting it to " + col.bold + col.yellow + args.start_port + col.endc
		if start_site.xrootd_endpoint[-1]=="/":
			start_site.xrootd_endpoint = start_site.xrootd_endpoint[:-1] + ":" + args.start_port + start_site.xrootd_endpoint[-1:]
		else:
			start_site.xrootd_endpoint = start_site.xrootd_endpoint + ":" + args.start_port + "/"
	if args.end_port:
		print "Overriding the default xrootd endpoint port for " + col.bold + col.blue + args.end + col.endc + " and setting it to " + col.bold + col.yellow + args.end_port + col.endc
		if end_site.xrootd_endpoint[-1]=="/":
			end_site.xrootd_endpoint = end_site.xrootd_endpoint[:-1] + ":" + args.end_port + end_site.xrootd_endpoint[-1:]
		else:
			end_site.xrootd_endpoint = end_site.xrootd_endpoint + ":" + args.end_port + "/"

	start_files = get_file_list(args,start_site,args.user1)

	if args.count or args.make:		
		if args.count:
			print "There are",col.bold+col.green+str(len(start_files))+col.endc,"files at the site",col.red+args.start+col.endc,"in the folder",col.yellow+args.indir+col.endc,"and its subfolders"
			if args.debug:
				print_partial_list(start_files)
		elif args.make:
			transfer_lines = format_and_write_transfer_lines(args,start_site,end_site,start_files)
	elif args.compare_checksum or args.compare_names:
		end_files = get_file_list(args,end_site,args.user2)
		if args.compare_checksum:
			print "Will checksum files in the range %s[%s:%s]%s" % (col.magenta,args.chk_range[0],args.chk_range[1],col.endc)
			if args.npool == 1:
				start_checksum_dict = get_checksum_dict(args,start_site,args.user1,start_files[args.chk_range[0]:args.chk_range[1]])
				end_checksum_dict = get_checksum_dict(args,end_site,args.user2,end_files[args.chk_range[0]:args.chk_range[1]])				
			elif args.npool > 1:
				# Based on:
				# https://pythonprogramming.net/values-from-multiprocessing-intermediate-python-tutorial/
				# https://stackoverflow.com/questions/5442910/python-multiprocessing-pool-map-for-multiple-arguments
				# https://docs.python.org/2/library/functools.html
				# https://stackoverflow.com/questions/46739019/is-it-possible-to-pass-the-same-optional-arguments-to-multiple-functions
				# https://stackoverflow.com/questions/13689927/how-to-get-the-amount-of-work-left-to-be-done-by-a-python-multiprocessing-pool
				with poolcontext(processes=args.npool) as pool:
					header = "Making a multiprocessed dictionary of filenames and checksums for " + col.bold + col.blue + start_site.alias + col.endc + " ... "
					print header,
					sys.stdout.flush()
					start_pool_time = time.time()
					m = multiprocessing.Manager()
					q = m.Queue()
					total = len(start_files[args.chk_range[0]:args.chk_range[1]])
					line_running = "\r%sJobs remaining: %i/%i          \r"
					len_line_running = len(line_running)+(2*len(str(total)))-2-6 #2 for \r and 6 for %{i,s}
					start_checksum_dict = pool.map_async(partial(get_checksum_dict, args, start_site, args.user1, quite=True, q=q), [[f] for f in start_files[args.chk_range[0]:args.chk_range[1]]])
					# monitor loop
					while True:
						if start_checksum_dict.ready():
							break
						else:
							size = q.qsize()
							print (line_running % (header,total-size,total)),
							sys.stdout.flush()
							time.sleep(1)
					# multiprocessing actually returns [{u'key1':'value1',...}]
					# must remove the list part of to pass only the dictionary
					start_checksum_dict = start_checksum_dict.get()[0]
					print_done(start_pool_time,time.time(),header," "*(len_line_running-16))
					header = "Making a multiprocessed dictionary of filenames and checksums for " + col.bold + col.blue + end_site.alias + col.endc + " ... "
					print header,
					sys.stdout.flush()
					start_pool_time = time.time()
					q = m.Queue()
					total = len(end_files[args.chk_range[0]:args.chk_range[1]])
					end_checksum_dict = pool.map_async(partial(get_checksum_dict, args, end_site, args.user2, quite=True, q=q), [[f] for f in end_files[args.chk_range[0]:args.chk_range[1]]])
					# monitor loop
					while True:
						if end_checksum_dict.ready():
							break
						else:
							size = q.qsize()
							print (line_running % (header,total-size,total)),
							sys.stdout.flush()
							time.sleep(1)
					# multiprocessing actually returns [{u'key1':'value1',...}]
					# must remove the list part of to pass only the dictionary
					end_checksum_dict = end_checksum_dict.get()[0]
					print_done(start_pool_time,time.time(),header," "*(len_line_running-16))
			else:
				raise ValueError("The --npool argument must be >=1.")
			compare_checksum_dicts(args,start_checksum_dict,end_checksum_dict)
		elif args.compare_names:
			diff_list = diff_file_list(args,start_files,end_files)
			if len(diff_list) > 0:
				# Write a file to transfer the missing lines
				transfer_lines = format_and_write_transfer_lines(args,start_site,end_site,diff_list)
