#!/usr/bin/env python
import argparse, os, subprocess
from multiprocessing import Pool

def partial_list(list):
	return "["+str(list[0:3])[1:-1]+", ... , "+str(list[-1:])[1:-1]+"]"

def make_file_lists(args):
	cmd = ("eos %s " % args.redirector) + ("find --xurl " if args.find else "ls ") + ("/store/user/%s/%s" % (args.user1,args.indir))
	p = subprocess.Popen(cmd,shell=True,stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
	out = p.communicate()[0]
	filelist = out.decode('ascii').split('\n')
	filelist = list(filter(lambda x: x != '', filelist))
	n=100
	list_of_filelist = [filelist[i:i + n] for i in range(0, len(filelist), n)]
	names = []
	for il, l in enumerate(list_of_filelist):
		name = "%s%i.txt"%(args.prefix,il)
		with open(name, 'w') as f:
			for item in l:
				if args.find:
					f.write(item)
				else:
					f.write("%s/store/user/%s/%s%s\n" % (args.redirector,args.user1,args.indir,item))
		names.append(name)
	return names,list_of_filelist

def do_copy(optlist):
	args = optlist[0]
	filelist_name = optlist[1]
	out = open(os.path.splitext(filelist_name)[0]+".log","w")
	cmd = "gfal-copy -r " + ("--dry-run " if args.dryrun else "") + "--from-file transfer_file_0.txt %s%s/%s" %(args.endpoint,args.user2,args.outdir)
	p = subprocess.Popen(cmd,shell=True,stdout=out, stderr=subprocess.STDOUT)
	p.wait()
	stdout,stderr = p.communicate()
	if stderr:
		print("Filelist "+filelist_name+" had an ERROR")
	else:
		print("Filelist "+filelist_name+" completed successfully")
	out.close()

if __name__ == "__main__":
	'''
	Example of how to run:
	python gfal-copy-fork.py -i SusyRA2Analysis2015/Run2ProductionV14/ -o SusyRA2Analysis2015/Run2ProductionV14/ -u1 lpcsusyhad
	'''

	# Read parameters
	parser = argparse.ArgumentParser(description='Used to transfer files using gfal-copy, but running multiple forks at once.')
	parser.add_argument("-c", "--count",    action="store_true",                   help="Make and count the file lists, but don't do any copying (default = %(default)s)")
	parser.add_argument("-d", "--debug",    action="store_true",                   help="Print debugging information (default = %(default)s)")
	parser.add_argument("--dryrun",         action="store_true",                   help="Use the gfal-copy --dry-run option (default = %(default)s)")
	parser.add_argument("-e", "--endpoint", default="gsiftp://gridftp-hadoop.colorado.edu:2811/mnt/hadoop/store/user/", help="The endpoint at which to save the files (default = %(default)s)")
	parser.add_argument("-f", "--find",     action="store_true",                   help="Use 'eos find' rather than 'eos ls' (default = %(default)s)")
	parser.add_argument("-i", "--indir",    default="",                            help="The EOS directory storing the files to be transfered (default = %(default)s)")
	parser.add_argument("-n", "--npool",    default=12,                            help="The number of processes to run (default = %(default)s)")
	parser.add_argument("-o", "--outdir",   default="",                            help="The output directory (default = %(default)s)")
	parser.add_argument("--redirector",     default="root://cmseos.fnal.gov/",     help="The default EOS redirector or endpoint (default = %(default)s)")
	parser.add_argument("-s", "--prefix",   default="transfer_file_",              help="The prefix for the file lists (default = %(default)s)")
	parser.add_argument("-t", "--tmp",      default="./",                          help="The directory in which to store the file lists (default = %(default)s)")
	parser.add_argument("-u1", "--user1",   default=os.environ["USER"],            help="The username of the input path (default = %(default)s)")
	parser.add_argument("-u2", "--user2",   default=os.environ["USER"],            help="The username of the output path (default = %(default)s)")

	args, unknown = parser.parse_known_args()

	filelist_names, list_of_filelist = make_file_lists(args)

	if args.count:
		print("Need to process",len(filelist_names),"files")
		if args.debug:
			for ifln, fln in enumerate(filelist_names):
				print("\t"+fln+":"+partial_list(list_of_filelist[ifln]))
		exit(0)

	optlist = [[args,x] for x in filelist_names]
	p = Pool(int(args.npool))
	p.map(do_copy,optlist)