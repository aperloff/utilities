#!/usr/bin/env python
import argparse, os, subprocess

def partial_list(list):
	return "["+str(list[0:3])[1:-1]+", ... , "+str(list[-1:])[1:-1]+"]"

def endslash_check(string):
	if string=="" or string[-1]=="/": return string
	else: return string+"/"

def make_file_list(args):
	cmd = "eos %s find -f --xurl /store/user/%s/%s | grep -v path=" % (args.redirector,args.user1,args.indir)
	p = subprocess.Popen(cmd,shell=True,stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
	out = p.communicate()[0]
	filelist = out.decode('ascii').split('\n')
	filelist = list(filter(lambda x: x != '', filelist))
	filelist_stripped = [f[f.find(args.user1)+len(args.user1)+1:] for f in filelist]
	lines = []
	with open(args.tmp+"/"+args.listname, 'w') as f:
		for item in filelist_stripped:
			line = "%s%s/%s %s/%s/%s%s\n" % (endslash_check(args.startpoint),args.user1,item,
			                                   endslash_check(args.endpoint),args.user2,endslash_check(args.outdir),item)
			f.write(line)
			lines.append(line)
	return lines

if __name__ == "__main__":
	'''
	Example of how to run:
	python prepare_transfer_file.py -i SusyRA2Analysis2015/Run2ProductionV14/ -u1 lpcsusyhad
	'''

	# Read parameters
	parser = argparse.ArgumentParser(description='Used to format the input file necessary for FTS transfers.',
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
	parser.add_argument("-c",  "--count",      action="store_true",                   									   help="Make and count the file lists, but don't do any copying (default = %(default)s)")
	parser.add_argument("-d",  "--debug",      action="store_true",                   									   help="Print debugging information (default = %(default)s)")
	parser.add_argument("-l",  "--listname",   default="fts_transfer_file_list.txt",  									   help="The name for the file list (default = %(default)s)")
	parser.add_argument("-t",  "--tmp",        default="./",                          									   help="The directory in which to store the file lists (default = %(default)s)")

	# EOS/XRootD options
	parser.add_argument(       "--redirector", default="root://cmseos.fnal.gov/",                                          help="The default EOS redirector or endpoint (default = %(default)s)")

	# FTS options
	parser.add_argument("-s",  "--startpoint", default="gsiftp://cmseos-gridftp.fnal.gov//eos/uscms/store/user/",          help="The starting gridftp pfn (default = %(default)s)")
	parser.add_argument("-e",  "--endpoint",   default="gsiftp://gridftp-hadoop.colorado.edu:2811/mnt/hadoop/store/user/", help="The ending gridftp pfn (default = %(default)s)")
	parser.add_argument("-i",  "--indir",      default="",                                                                 help="The EOS directory storing the files to be transfered (default = %(default)s)")
	parser.add_argument("-o",  "--outdir",     default="",                                                                 help="An output directory to contain the input hierarchy (default = %(default)s)")	
	parser.add_argument("-u1", "--user1",      default=os.environ["USER"],                                                 help="The username of the input path (default = %(default)s)")
	parser.add_argument("-u2", "--user2",      default=os.environ["USER"],                                                 help="The username of the output path (default = %(default)s)")

	args, unknown = parser.parse_known_args()

	files = make_file_list(args)

	if args.count:
		print "Need to process",len(files),"files"
		if args.debug:
			for f in files[0:3]:
				print("\t"+f.strip())
			print "\t..."
			for f in files[-1:]:
				print("\t"+f.strip())
		exit(0)

	print str(args.listname)+" created successfully!"