#!/bin/env python3

import argparse
import os
import pathlib


def make_link(src, dst, refresh_link):
    """Create a symlink from the source (src) to the destination (dst). Unlink and relink existing symlinks if
    requested. If a symlink already exists and 'refresh_link' is not set to True, a warning will be displayed.
    """

    if os.path.exists(dst) and os.path.islink(dst) and refresh_link:
        os.unlink(dst)
    os.symlink(src, dst)


def print_link(src, dst):
    print(f"Linking {src} ==> {dst}")


class UltimateHelpFormatter(argparse.RawTextHelpFormatter, argparse.ArgumentDefaultsHelpFormatter):
    pass


def main():
    """This program creates symlinks of the oh-my-zsh related files within the utilities repository to the needed
    locations on within the users home area.
    """

    parser = argparse.ArgumentParser(
        description="This program creates symlinks of the oh-my-zsh related files within the utilities repository to\
 the needed locations on within the users home area.",
        epilog="""Example commands:\n\tpython3 %(prog)s -r""",
        formatter_class=UltimateHelpFormatter,
    )

    parser.add_argument('-r', '--refresh_links', action="store_true", default=False,
                        help="If a link exists at the destination, unlink and then re-link it to the relevant source file.")
    parser.add_argument('-v', '--verbose', action='store_true',
                        help="Print out additional information.")
    parser.add_argument('--version', action='version', version='%(prog)s 0.0.1')

    args = parser.parse_args()

    # Setup needed paths
    home = os.environ['HOME']
    if not home:
        raise RuntimeError("Unable to find the users home directory!")

    path_to_ohmyzsh = os.environ['ZSH']
    if not path_to_ohmyzsh or not os.path.exists(path_to_ohmyzsh):
        raise RuntimeError("The oh-my-zsh dotfolder doesn't exist!")

    src_path = str(pathlib.Path(__file__).parent.resolve())

    # Setup the $HOME/.zshrc file
    dot_zshrc_src = src_path + '/.zshrc'
    dot_zshrc_dst = home + '/.zshrc'
    if os.path.exists(dot_zshrc_dst) and not os.path.islink(dot_zshrc_dst):
        raise RuntimeError(f"A non-symlink ${dot_zshrc_dst} already exists!")
    elif os.path.exists(dot_zshrc_dst) and os.path.islink(dot_zshrc_dst):
        if src_path in os.readlink(dot_zshrc_dst):
            if args.refresh_links:
                os.unlink(dot_zshrc_dst)
        else:
            raise RuntimeError(f"The file ${dot_zshrc_dst} links to an unknown directory. You may want to save it before continuing.")
    if args.verbose:
        print_link(dot_zshrc_src, dot_zshrc_dst)
    os.symlink(dot_zshrc_src, dot_zshrc_dst)

    # Setup the custom .zsh files
    custom_dir_src = src_path + "/custom"
    custom_dir_dst = path_to_ohmyzsh + "/custom"
    zsh_files = os.listdir(custom_dir_src)
    zsh_files = [f for f in zsh_files if os.path.isfile(custom_dir_src + '/' + f) and f.endswith(".zsh")]
    for file in zsh_files:
        src = custom_dir_src + '/' + file
        dst = custom_dir_dst + '/' + file
        if args.verbose:
            print_link(src, dst)
        make_link(src, dst, args.refresh_links)

    # Setup the themes
    themes_dir_src = src_path + "/custom/themes"
    themes_dir_dst = path_to_ohmyzsh + "/custom/themes"
    theme_dirs = os.listdir(themes_dir_src)
    theme_dirs = [dir for dir in theme_dirs if os.path.isdir(themes_dir_src + '/' + dir)]
    for dir in theme_dirs:
        src = themes_dir_src + '/' + dir
        dst = themes_dir_dst + '/' + dir
        if args.verbose:
            print_link(src, dst)
        make_link(src, dst, args.refresh_links)

    # Setup the plugins
    plugins_dir_src = src_path + "/custom/plugins"
    plugins_dir_dst = path_to_ohmyzsh + "/custom/plugins"
    plugin_dirs = os.listdir(plugins_dir_src)
    plugin_dirs = [dir for dir in plugin_dirs if os.path.isdir(plugins_dir_src + '/' + dir)]
    for dir in plugin_dirs:
        src = plugins_dir_src + '/' + dir
        dst = plugins_dir_dst + '/' + dir
        if args.verbose:
            print_link(src, dst)
        make_link(src, dst, args.refresh_links)


if __name__ == '__main__':
    main()
