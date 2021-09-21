# re-extractor
### Usages
A simple script that extracts various types of compressions.

Supported compressions :
KGB, ARJ, PPMD, ZIP, RZIP, GZIP, BZIP2, TAR, CAB, ARC, XZ, 7z, ZOO, RAR
s
```
Usage: ./extract.sh <filename> [-d|--directory <arg>] [-e|--exclude <arg>] [-h|--help] 
        <filename>: Compressed filename
        -d, --directory: Specify output directory (default: '_extracted')
        -e, --exclude: Exclude <FILE EXTENSION> from decompressing (empty by default)
        -h, --help: Prints help
```


### pre-requirements
``` bash
$ sudo apt-get install ppmd kgb arj rzip bzip2 cabextract nomarch zoo
```
**Note**: You may need to install [ppmd](https://launchpad.net/ubuntu/utopic/+package/ppmd) and [zoo](https://debian.pkgs.org/9/debian-main-amd64/zoo_2.10-28_amd64.deb.html) packages manually.



### Examples

As use cases, we can refer to 
+ [Tootsie Pop (H@cktivityCon CTF 2020)](https://ctftime.org/task/12577)
+ [Like 1000 (picoCTF 2019)](https://ctftime.org/task/9551)
+ [Can you find me? (cybertalents)](https://cybertalents.com/challenges/forensics/can-you-find-me)


##### Tootsie Pop (H@cktivityCon CTF 2020):
        
Simply give the filename and output directory name.

```bash
$ ./extract.sh pop.zip -d output-dir/
$ ls output-dir/
filler.txt  flag.png
```
---

##### Like 1000 (picoCTF 2019):

Exclude option is for ignoring side files in extraction and preventing errors in decompressing them.

```bash
$ ./extract.sh 1000.tar -d output-dir/ -e txt
$ ls output-dir/
8c4be4.gz
$ file 8c4be4.gz
8c4be4.gz: ASCII text
```
