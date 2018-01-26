utilities
=========

## Overview
Some useful scripts that I've come to rely on

## Setup Links For Login Scripts
```bash
${PWD}/utilities/refreshLoginLinks.sh
```

**NOTE:** If you have any files with the same name already existing in your ${HOME} area then the process will abort.

## Available Scripts
| *Name*                    | *Directory* | *Description*                                            | *Help Message Available* | *Example Usage*                   |
|:--------------------------|:------------|:---------------------------------------------------------|:-------------------------|:----------------------------------|
| _clearUnwantedFiles.sh_   | ./          | Delete a selection of unwanted files (i.e. \*.txt~)      | Yes                      |  ```./clearUnwantedFiles.sh -h``` |
| _copyDirectories.sh_      | ./          | Copy directory structure from one location to another    | Yes                      |  ```./copyDirectories.sh -h```    |
| _countFoldersAndFiles.sh_ | ./          | Count the numbe of files, folders, and links             | Yes                      |  ```countFoldersAndFiles.sh -h``` |
| _duSort.sh_               | ./          | Sort a list of files by size                             | No                       |                                   |
| _grepMissingWord.sh_      | ./          | Grep for all files missing a specific work               | Yes                      |                                   |
| _mcp.sh_                  | ./          |                                                          | Yes                      |                                   |
| _refreshLoginLinks.sh_    | ./          | Setup the links for this package in a users ${HOME} area | No                       |                                   |
| _removeOlderThan.sh_      | ./          | Remove files older than a specific date                  | Yes                      |                                   |
| _renameLinks.sh_          | ./          | Rename a set of links                                    | No                       |                                   |
| _smv_                     | ./          |                                                          | No                       |                                   |
| _TDRCompile.sh_           | ./          | Used after TDRSetup.sh to compile a CMS document         | No                       | ```source TDRCompile.sh```        |
| _TDRSetup.sh_             | ./          | Used to setup ones working area for a CMS document       | No                       | ```source TDRSetup.sh```          |
       