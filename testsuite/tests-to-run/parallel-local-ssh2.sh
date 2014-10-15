#!/bin/bash

cat <<'EOF' | sed -e s/\$SERVER1/$SERVER1/\;s/\$SERVER2/$SERVER2/ | stdout parallel -vj8 -k -L1
echo '### --filter-hosts --slf <()'
  parallel --nonall --filter-hosts --slf <(echo localhost) echo OK

echo '### --wd no-such-dir - csh'
  stdout parallel --wd /no-such-dir -S csh@localhost echo ::: "ERROR IF PRINTED"; echo Exit code $?
echo '### --wd no-such-dir - tcsh'
  stdout parallel --wd /no-such-dir -S tcsh@localhost echo ::: "ERROR IF PRINTED"; echo Exit code $?
echo '### --wd no-such-dir - bash'
  stdout parallel --wd /no-such-dir -S parallel@localhost echo ::: "ERROR IF PRINTED"; echo Exit code $?

echo '### bug #42725: csh with \n in variables'
  not_csh() { echo This is not csh/tcsh; }; 
  export -f not_csh; 
  parallel --env not_csh -S csh@lo not_csh ::: 1; 
  parallel --env not_csh -S tcsh@lo not_csh ::: 1; 
  parallel --env not_csh -S parallel@lo not_csh ::: 1

echo '### bug #43358: shellshock breaks exporting functions using --env'
  echo shellshock-hardened to shellshock-hardened; 
  funky() { echo Function $1; }; 
  export -f funky; 
  parallel --env funky -S parallel@localhost funky ::: shellshock-hardened

echo '2bug #43358: shellshock breaks exporting functions using --env'
  echo shellshock-hardened to non-shellshock-hardened; 
  funky() { echo Function $1; }; 
  export -f funky; 
  parallel --env funky -S centos3.tange.dk funky ::: non-shellshock-hardened

EOF
