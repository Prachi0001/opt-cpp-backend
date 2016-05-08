#!/bin/sh

DN=`dirname $0`

# $1 is a string representing the C/C++ program to be run within Docker
# $2 is either c or cpp, depending on whether to compile C or C++

if [ $2 = "c" ]
then
  CC="gcc"
  FN="usercode.c"
else
  CC="g++"
  FN="usercode.cpp"
fi

rm -f usercode.* # in case there are stray files in the container

# tricky! use a heredoc to pipe the $1 argument into the stdin of cat
# WITHOUT interpreting escape chars such as '\n' ...
# echo doesn't work here since it interprets '\n' and other chars
#
cat <<ENDEND > $DN/$FN
$1
ENDEND

$CC -ggdb -O0 -fno-omit-frame-pointer -o $DN/usercode.exe $DN/$FN 2> $DN/gcc.errs
if [ $? -eq 0 ]
then
  # tricky! --source-filename takes a basename only, not a dirname:
  $DN/valgrind-3.11.0/inst/bin/valgrind --tool=memcheck --source-filename=$FN --trace-filename=$DN/usercode.vgtrace $DN/usercode.exe > /dev/null # silence stdout
  python $DN/vg_to_opt_trace.py --jsondump $DN/usercode
else
  # TODO: report compiler errors gracefully here using $DN/gcc.errs
  echo '{"code": "", "trace": [{"event":"uncaught_exception","exception_msg":"COMPILER ERROR, UGH!"}]}';
fi
