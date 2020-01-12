#

set -e
# this script sync up w/ mfs
# $qm: ~$
#
dir=$(pwd)
name=${dir##*/.brings/}
echo name: $name

qm=$(ipms add -Q -r .)
if pv=$(ipms files stat --hash /.brings/$name); then
 ipms files rm -r /.brings/$name
 ipms files cp /ipfs/$qm /.brings/$name
 ipms files cp /ipfs/$pv /.brings/$name/prev
else
 if ipms files mkdir -p /.brings/$name 1>/dev/null; then true; fi
 ipms files cp /ipfs/$qm /.brings/$name
fi
qm=$(ipms files stat --hash /.brings/$name)
echo bin_url: https://gateway.ipfs.io/ipfs/$qm
if which xdg-open 1>/dev/null; then
  xdg-open https://cloudflare-ipfs.com/ipfs/$qm
fi

# publish system ...
symb=${name%/bin}
if qm=$(ipms files stat --hash /.brings/${symb}); then
  ipms name publish --key=$symb /ipfs/$qm
  echo sys_url: https://127.0.0.1:8080/ipfs/$qm
fi


exit $?;
true; # $Source: /.brings/system/bin/sync.sh$
