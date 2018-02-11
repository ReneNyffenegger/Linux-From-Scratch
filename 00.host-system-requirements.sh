# vi: set ft=sh

#
#   http://www.linuxfromscratch.org/lfs/view/stable/chapter02/hostreqs.html
#

export LC_ALL=C


MYSH=$(readlink -f /bin/sh)

echo $MYSH | grep -q bash || echo "ERROR: /bin/sh does not point to bash, it points to $MYSH"
unset MYSH


if [ -h /usr/bin/yacc ]; then
  echo "/usr/bin/yacc -> `readlink -f /usr/bin/yacc`";
elif [ -x /usr/bin/yacc ]; then
  echo yacc is `/usr/bin/yacc --version | head -n1`
else
  echo "yacc not found" 
fi


if [ -h /usr/bin/awk ]; then
  echo "/usr/bin/awk -> `readlink -f /usr/bin/awk`";
elif [ -x /usr/bin/awk ]; then
  echo awk is `/usr/bin/awk --version | head -n1`
else 
  echo "awk not found" 
fi

echo
echo Is gawk available?
echo 


check_version() {
  local cmd=$1
  local expected=$2

  local version=$(eval "$cmd")

  local  cmd_1st_word=$(echo $cmd | awk '{print $1}')

  printf "  %-5s :  %-7s | %-5s\n" $cmd_1st_word $expected $version

}

check_version  "bash  --version | head -n1 | sed 's/^[^[:digit:]]\\+\\([[:digit:]]\\+\\.[[:digit:]]\\+\\).*/\\1/'"  3.2
check_version  "bison --version | head -n1 | sed 's/^.* //'"                                                        2.3
check_version  "bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d\" \" -f8"                                      1.0.4
check_version  "chown --version | head -n1 | sed 's/^.* //'"                                                        6.9     # coreutils
check_version  "diff  --version | head -n1 | sed 's/^.* //'"                                                        2.8
check_version  "find  --version | head -n1 | sed 's/^.* //'"                                                        4.2.31
check_version  "ld    --version | head -n1 | sed 's/^.* //'"                                                        2.17    # binutils
check_version  "gawk  --version | head -n1 | sed 's/^.* //'"                                                        4.7     
check_version  "gcc   --version | head -n1 | sed 's/^.* //'"                                                        4.7     
check_version  "g++   --version | head -n1 | sed 's/^.* //'"                                                        4.7   
check_version  "ldd   --version | head -n1 | sed 's/^.* //'"                                                        2.11 
check_version  "grep  --version | head -n1 | sed 's/^.* //'"                                                        2.5.1a
check_version  "gzip  --version | head -n1 | sed 's/^.* //'"                                                        1.3.12
check_version  "m4    --version | head -n1 | sed 's/^.* //'"                                                        1.4.10
check_version  "make  --version | head -n1 | sed 's/^.* //'"                                                        3.8.1
#? makeinfo --version | head -n1
check_version  "patch --version | head -n1 | sed 's/^.* //'"                                                        2.5.4
check_version  "perl -V:version |           cut -d\"'\" -f2"                                                        5.8.8
check_version  "sed   --version | head -n1 | sed 's/^.* //'"                                                        4.1.5
check_version  "tar   --version | head -n1 | sed 's/^.* //'"                                                        1.22
check_version  "xz    --version | head -n1 | sed 's/^.* //'"                                                        5.0.0


echo "Linux   : " $(cat /proc/version | cut -d" " -f 3)


echo 'int main(){}' > dummy.c && g++ -o dummy dummy.c
if [ -x dummy ]
  then echo "g++ compilation OK";
  else echo "g++ compilation failed"; fi
rm -f dummy.c dummy
