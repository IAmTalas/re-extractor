#!/bin/bash

die()
{
	local _ret="${2:-1}"
	test "${_PRINT_HELP:-no}" = yes && print_help >&2
	echo "$1" >&2
	exit "${_ret}"
}


begins_with_short_option()
{
	local first_option all_short_options='deh'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - POSITIONALS
_positionals=()
# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_directory="_extracted"
_arg_exclude=()


print_help()
{
	printf 'Usage: %s <filename> [-d|--directory <arg>] [-e|--exclude <arg>] [-h|--help] \n' "$0"
	printf '\t%s\n' "<filename>: Compressed filename"
	printf '\t%s\n' "-d, --directory: Specify output directory (default: '_extracted')"
	printf '\t%s\n' "-e, --exclude: Exclude <FILE EXTENSION> from decompressing (empty by default)"
	printf '\t%s\n' "-h, --help: Prints help"
}


parse_commandline()
{
	_positionals_count=0
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			-d|--directory)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_directory="$2"
				shift
				;;
			--directory=*)
				_arg_directory="${_key##--directory=}"
				;;
			-d*)
				_arg_directory="${_key##-d}"
				;;
			-e|--exclude)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_exclude+=("$2")
				shift
				;;
			--exclude=*)
				_arg_exclude+=("${_key##--exclude=}")
				;;
			-e*)
				_arg_exclude+=("${_key##-e}")
				;;
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			*)
				_last_positional="$1"
				_positionals+=("$_last_positional")
				_positionals_count=$((_positionals_count + 1))
				;;
		esac
		shift
	done
}


handle_passed_args_count()
{
	local _required_args_string="'filename'"
	test "${_positionals_count}" -ge 1 || _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require exactly 1 (namely: $_required_args_string), but got only ${_positionals_count}." 1
	test "${_positionals_count}" -le 1 || _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect exactly 1 (namely: $_required_args_string), but got ${_positionals_count} (the last one was: '${_last_positional}')." 1
}


assign_positional_args()
{
	local _positional_name _shift_for=$1
	_positional_names="_arg_filename "

	shift "$_shift_for"
	for _positional_name in ${_positional_names}
	do
		test $# -gt 0 || break
		eval "$_positional_name=\${1}" || die "Error during argument parsing, possibly an Argbash bug." 1
		shift
	done
}

parse_commandline "$@"
handle_passed_args_count
assign_positional_args 1 "${_positionals[@]}"


mkdir $_arg_directory
cp $_arg_filename $_arg_directory
cd $_arg_directory

if [[ -e $_arg_directory ]]; then
    printf '%s\n' "This directory already exists"
    exit 2
fi

if [[ -n $_arg_exclude ]]; then
    exclude="-not -name *.$_arg_exclude"
fi

iter=0

while true; do


    file_name="$(find . -not -type d $exclude)";

    file_exec="$(file -b $file_name)";

    if [[  "$file_exec" =~ "KGB Archiver file with compression".*  ]] ; then
        
        mv $file_name $file_name.kgb && kgb $file_name.kgb && rm $file_name.kgb

    elif [[  "$file_exec" =~ "ARJ archive data".*  ]] ; then
        
        mv $file_name $file_name.arj && arj e $file_name.arj && rm $file_name.arj

    elif [[  "$file_exec" =~ "PPMD archive data".*  ]] ; then
        
        mv $file_name $file_name.ppmd && ppmd d $file_name.ppmd && rm $file_name.ppmd

    elif [[  "$file_exec" =~ "rzip compressed data".*  ]] ; then
        
        mv $file_name $file_name.rz && rzip -d $file_name.rz

    elif [[  "$file_exec" =~ "gzip compressed data".*  ]] ; then
        
        mv $file_name $file_name.gz && gzip -d $file_name.gz

    elif [[  "$file_exec" =~ "POSIX tar archive (GNU)".*  ]] ; then
        
        mv $file_name $file_name.tar && tar -xvf $file_name.tar && rm $file_name.tar

    elif [[  "$file_exec" =~ "Zip archive data".*  ]] ; then
        
        mv $file_name $file_name.zip && unzip $file_name.zip && rm $file_name.zip

    elif [[  "$file_exec" =~ "Microsoft Cabinet archive data".*  ]] ; then
        
        mv $file_name $file_name.cab && cabextract $file_name.cab && rm $file_name.cab

    elif [[  "$file_exec" =~ "bzip2 compressed data".*  ]] ; then
        
        mv $file_name $file_name.bz2 && bzip2 -d $file_name.bz2

    elif [[  "$file_exec" =~ "ARC archive data".*  ]] ; then
        
        mv $file_name $file_name.arc && nomarch $file_name.arc && rm $file_name.arc

    elif [[  "$file_exec" =~ "XZ compressed data".*  ]] ; then
        
        mv $file_name $file_name.xz && xz -d $file_name.xz

    elif [[  "$file_exec" =~ "7".*  ]] ; then
        
        mv $file_name $file_name.7z && p7zip -d $file_name.7z

    elif [[  "$file_exec" =~ "Zoo archive data".*  ]] ; then
        
        mv $file_name $file_name.zoo && zoo -e $file_name.zoo && rm $file_name.zoo

    elif [[  "$file_exec" =~ "RAR archive data".*  ]] ; then
        
        mv $file_name $file_name.rar && unrar e $file_name.rar && rm $file_name.rar
    else
        break
    fi
	if [[ $? -ne 0 ]];then
        printf "An error occurred when extracting : %s\nyou may have not installed requirements properly" "$file_name";
        exit 1;        
    fi
    
    iter=$((iter+1))

done

printf "Finished after %d iterations" "$iter"
