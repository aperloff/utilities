utilities
=========
<!-- MarkdownTOC -->

- [Overview](#overview)
- [Setup Links For Login Scripts](#setup-links-for-login-scripts)
- [Available Scripts](#available-scripts)

<!-- /MarkdownTOC -->

<a name="overview"></a>
## Overview
Some useful scripts that I've come to rely on

<details><summary>Directory Tree</summary>
<p>

```bash
utilities/
|-- EOS
|   \`-- eosCount.sh
|-- Git
|   |-- .gitconfig
|   \`-- .gitignore_global
|-- Login
|   |-- .bash_profile
|   |-- .bash_ps1
|   |-- .bashrc
|   |-- .cshrc
|   |-- .emacs
|   |-- .forward
|   |-- .k5login
|   |-- .login
|   |-- .profile
|   |-- .tcshrc.complete
|   \`-- .tcshrc.logout
|-- README.md
|-- ROOT
|   |-- .rootrc
|   |-- ahadd.py
|   \`-- rootlogon.C
|-- Setup
|   |-- DASSetup.csh
|   |-- FPGASetup.csh
|   |-- HATSSetup.csh
|   |-- JECSetup.csh
|   |-- JECSetup.sh
|   |-- MatrixElementSetup.csh
|   |-- MatrixElementSetup.sh
|   |-- Setup.sh
|   \`-- VHbbSetup.csh
|-- TAMUWW
|   |-- clearLimitTestingFiles.py
|   |-- renameLimitRootFiles.sh
|   |-- submitLimitHistograms.sh
|   \`-- submitSysHistograms.sh
|-- TDRCompile.sh
|-- TDRSetup.sh
|-- clearUnwantedFiles.sh
|-- copyDirectories.sh
|-- countFoldersAndFiles.sh
|-- duSort.sh
|-- grepMissingWord.sh
|-- mcp.sh
|-- refreshLoginLinks.sh
|-- removeOlderThan.sh
|-- renameLinks.sh
|-- smv
```
</p>
</details>

<a name="setup-links-for-login-scripts"></a>
## Setup Links For Login Scripts
```bash
${PWD}/utilities/refreshLoginLinks.sh
```

**NOTE:** If you have any files with the same name already existing in your ${HOME} area then the process will abort.

<a name="available-scripts"></a>
## Available Scripts
| *Name*                    | *Directory* | *Description*                                            | *Help Message Available* | *Example Usage*                   |
|:--------------------------|:------------|:---------------------------------------------------------|:-------------------------|:----------------------------------|
| _clearUnwantedFiles.sh_   | ./          | Delete a selection of unwanted files (i.e. \*.txt~)      | Yes                      |  ```./clearUnwantedFiles.sh -h``` |
| _copyDirectories.sh_      | ./          | Copy directory structure from one location to another    | Yes                      |  ```./copyDirectories.sh -h```    |
| _countFoldersAndFiles.sh_ | ./          | Count the numbe of files, folders, and links             | Yes                      |  ```countFoldersAndFiles.sh -h``` |
| _duSort.sh_               | ./          | Sort a list of files by size                             | No                       |                                   |
| _grepMissingWord.sh_      | ./          | Grep for all files missing a specific work               | Yes                      |                                   |
| _mcp.sh_                  | ./          |                                                          | Yes                      |                                   |
| _refreshLoginLinks.sh_    | ./          | Setup the links for this package in a users ${HOME} area | No                       | ```./refreshLoginLinks.sh```      |
| _removeOlderThan.sh_      | ./          | Remove files older than a specific date                  | Yes                      |                                   |
| _renameLinks.sh_          | ./          | Rename a set of links                                    | No                       |                                   |
| _smv_                     | ./          |                                                          | No                       |                                   |
| _TDRCompile.sh_           | ./          | Used after TDRSetup.sh to compile a CMS document         | No                       | ```source TDRCompile.sh```        |
| _TDRSetup.sh_             | ./          | Used to setup ones working area for a CMS document       | No                       | ```source TDRSetup.sh```          |
| _eosCount.sh_             | EOS/        | Counts or lists all files using "eos find"               | Yes                      | ```./eosCount.sh <path>```        |
| _.gitconfig_              | Git/        | Git global configuration file                            | No                       | <N/A>                             |
| _.gitignore\_global_      | Git/        | Git global ignore list                                   | No                       | <N/A>                             |
| _.bash\_profile_          | Login/      | bash login script                                        | No                       | <N/A>                             |
| _.bash\_ps1_              | Login/      | pack prompt script                                       | No                       | <N/A>                             |
| _.bashrc_                 | Login/      | bash login script                                        | No                       | <N/A>                             |
| _.cshrc_                  | Login/      | (t)csh login script                                      | No                       | <N/A>                             |
| _.emacs_                  | Login/      | emacs configuration                                      | No                       | <N/A>                             |
| _.forward_                | Login/      | Email forwarding                                         | No                       | <N/A>                             |
| _.k5login_                | Login/      | Kerberos configuration                                   | No                       | <N/A>                             |
| _.login_                  | Login/      | iterm2 login script                                      | No                       | <N/A>                             |
| _.profile_                | Login/      | Login script                                             | No                       | <N/A>                             |
| _.tcshrc.complete_        | Login/      | tcsh script                                              | No                       | <N/A>                             |
| _.tcshrc.logout_          | Login/      | tcsh logout script                                       | No                       | <N/A>                             |
| _ahadd.py_                | ROOT/       | Parallelizes the hadd process for ROOT files             | Yes                      | ```python ahadd.py```             |
| _.rootrc_                 | ROOT/       | ROOT setup script                                        | No                       | <N/A>                             |
| _rootlogon.C_             | ROOT/       | Global ROOT logon script                                 | No                       | <N/A>                             |
| _FPGASetup.csh_           | Setup/      | Setup/login to the computer with an Xilinx FPGA          | No                       | ```source FPGASetup.csh```        |
| _Setup.sh_                | Setup/      | Setup a CMSSW/CRAB environment for a given project       | No                       | ```source Setup.sh```             |

<details><summary>Obsolete Scripts</summary>
<p>

| *Name*                      | *Directory* | *Description*                                            | *Help Message Available* | *Example Usage*                        |
|:----------------------------|:------------|:---------------------------------------------------------|:-------------------------|:---------------------------------------|
| _DASSetup.csh_              | Setup/      | Old DAS setup script                                     | No                       | ```source DASSetup.csh```              |
| _HATSSetup.csh_             | Setup/      | Old HATS setup script                                    | No                       | ```source HATSSetup.csh```             |
| _JECSetup.csh_              | Setup/      | Old JEC setup script                                     | No                       | ```source JECSetup.csh```              |
| _JECSetup.sh_               | Setup/      | Old JEC setup script                                     | No                       | ```source JECSetup.sh```               |
| _MatrixElementSetup.csh_    | Setup/      | Old TAMUWW setup script                                  | No                       | ```source MatrixElement.csh```         |
| _MatrixElementSetup.sh_     | Setup/      | Old TAMUWW setup script                                  | No                       | ```source MatrixElement.sh```          |
| _VHbbSetup.csh_             | Setup/      | Old VHbb setup script                                    | No                       | ```source VHbbSetup.csh```             |
| _clearLimitTestingFiles.py_ | TAMUWW/     | Clears the files created by combine                      | No                       | ```python clearLimitTestingFiles.py``` |
| _renameLimitRootFiles.sh_   | TAMUWW/     | Rename some ROOT files for use by combine                | No                       | ```source renameLimitRootFiles.sh```   |
| _submitLimitHistograms.sh_  | TAMUWW/     | Submit condor jobs to make the templates used by combine | No                       | ```source submitLimitHistograms.sh```  |
| _submitSysHistograms.sh_    | TAMUWW/     | Submit condor jobs to make the systematic templates      | No                       | ```source submitSysHistograms.sh```    |
</p>
</details>