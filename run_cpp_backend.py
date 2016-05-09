# Run the Valgrind-based C/C++ backend for OPT and produce JSON to
# stdout for piping to a web app, properly handling errors and stuff

# Created: 2016-05-09

import json
import os
from subprocess import Popen, PIPE
import sys

DN = os.path.dirname(sys.argv[0])
USER_PROGRAM = sys.argv[1] # string containing the program to be run
LANG = sys.argv[2] # 'c' for C or 'cpp' for C++

if LANG == 'c':
    CC = 'gcc'
    FN = 'usercode.c'
else:
    CC = 'g++'
    FN = 'usercode.cpp'

F_PATH = os.path.join(DN, FN)
VGTRACE_PATH = os.path.join(DN, 'usercode.vgtrace')
EXE_PATH = os.path.join(DN, 'usercode.exe')

# get rid of stray files so that we don't accidentally use a stray one
for f in (F_PATH, VGTRACE_PATH, EXE_PATH):
    if os.path.exists(f):
        os.remove(f)

# write USER_PROGRAM into F_PATH
with open(F_PATH, 'w') as f:
    f.write(USER_PROGRAM)

# compile it!
p = Popen([CC, '-ggdb', '-O0', '-fno-omit-frame-pointer', '-o', EXE_PATH, F_PATH],
          stdout=PIPE, stderr=PIPE)
(stdout, stderr) = p.communicate()
retcode = p.returncode

if retcode == 0:
    # run it with Valgrind
    pass
else:
    print '==='
    print stderr
    print '==='
    # compiler error. parse and report gracefully!
    exception_msg = 'boo'
    lineno = 1
    ret = {'code': USER_PROGRAM,
           'trace': [{'event': 'uncaught_exception',
                    'exception_msg': exception_msg,
                    'line': lineno}]}
    print json.dumps(ret)

'''
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
'''
