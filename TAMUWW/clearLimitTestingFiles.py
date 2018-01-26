#!/bin/env python
import sys, argparse, fnmatch
from os import listdir, environ, remove, unlink
from os.path import isfile, islink, join

file_extensions = ["txt","C","hh","cc","py","sh","csh","cfg","xml","jdl","pbs"]
default_patterns = ["roostats-","mlfit.root","higgsCombineTest."]

def ignore_patterns(patterns):
	"""Function that can be used as copytree() ignore parameter.

	Patterns is a sequence of glob-style patterns
	that are used to exclude files"""
	def _ignore_patterns(path, names):
		ignored_names = []
		for pattern in patterns:
			if len(fnmatch.filter([path],'*'+pattern+'*')) > 0:
				ignored_names.extend(names)
			else:
				ignored_names.extend(fnmatch.filter(names, '*'+pattern+'*'))
		return set(ignored_names)
	return _ignore_patterns

def main(PATH, ADDITIONAL, IGNORE, DRY_RUN, VERBOSE):
	files_in_path = [f for f in listdir(PATH) if isfile(join(PATH, f))]
	if VERBOSE:
		print "Files in Path:\n\t",files_in_path

	global default_patterns
	default_patterns += ADDITIONAL
	if VERBOSE:
		print "File Patterns:\n\t",default_patterns

	ignore=ignore_patterns(IGNORE)
	if ignore is not None:
		ignored_names = ignore(PATH, files_in_path)
	else:
		ignored_names = set()
	if VERBOSE:
		print "Ignored Names:\n\t",ignored_names,"\n\n"

	for f in files_in_path:
		if f in ignored_names:
			continue
		for ext in file_extensions:
			if f.endswith("."+ext+"~"):
				print "Removing the file",join(PATH,f)
				if not DRY_RUN:
					remove(join(PATH,f))
		for pat in default_patterns:
			if pat in f:
				print "Removing the file",join(PATH,f)
				if not DRY_RUN:
					if islink(join(PATH,f)):
						unlink(join(PATH,f))
					else:
						remove(join(PATH,f))

if __name__ == '__main__':
	#program name available through the %(prog)s command
	parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
									 description="""
This script will clear backup files and the usual suspects created when testing limits.
The patterns being removed are "roostats-", "mlfit.root", and "higgsCombineTest.".
This program only works on files, for now, and is not recurssive.""",
									 epilog="""
And those are the options available. Deal with it.""")
	parser.add_argument("-a","--additional", help="Any additional file patters to clean (default=())",
						nargs='+', type=str, default=())
	parser.add_argument("-d","--dry_run", help="Do not perform any action, just print what would be done.",
						action="store_true")
	parser.add_argument("-i","--ignore", help="Patterns of files/folders to ignore. (default=())",
						nargs='+', type=str, default=())
	parser.add_argument("-p", "--path", help="The path to the files to be deleted (default=os.environ[\'PWD\'])",
						default=environ['PWD'])
	parser.add_argument("-v", "--verbose", help="Increase output verbosity",
						action="store_true")
	parser.add_argument('--version', action='version', version='%(prog)s 1.0')
	args = parser.parse_args()

	if(args.verbose):
		print "Argparse Information:"
		print '\tNumber of arguments:', len(sys.argv), 'arguments.'
		print '\tArgument List:', str(sys.argv)
		print "\tArgument ", args
	
	main(PATH=args.path, ADDITIONAL=tuple(args.additional),
		 IGNORE=tuple(args.ignore), DRY_RUN=args.dry_run, VERBOSE=args.verbose)



