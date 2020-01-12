#
# merging block :
#  get both current files
#  then get the common ancestor
#  and do a merge (diff3)!
#
#  for this script it is assumed that the mutable for the passed block is available in mfs
#
# vim: sw=3 et ai

if [ "x$1" = 'x-u' ]; then shift; update; fi

block=mhash "$1"
sandbox="/tmp/fetch"; if [ ! -d $sandbox ]; then mkdir -p $sandbox; fi
ipms=is_running
friends=ipms_resolve("self@mfs:/my/friends/peerid.yml")
# friends=addfriend $friends $nickname $peerid

# get peerids.yml
ipms files read /my/friends/peerids.yml > $sandbox/peerids.yml
eval $(cat $sandbox/peerids.yml | eyml)

# dependencies:
if ! release=$(ipms files stat --hash /.brings/system/bin 2>/dev/null); then
  release='QmNWZ5ETgz3yQJeH1RVyeaM9CwaVovSPwtDDNr8J8Nn697'
fi
kwextract="/ipfs/$release/kwextract.pl"
kwsubsti="/ipfs/$release/kwsubsti.pl"

main() {
file="$1"
block="${file##*/}"
ipms files read /.brings/system/bin/kwextract.pl | perl /dev/stdin -yml "$file"
eval $(ipms files read /.brings/system/bin/kwextract.pl | perl /dev/stdin -yml "$file" | eyml)
 if [ "x$mutable" != 'x' ]; then
   if ipms files stat --hash $mutable 1>/dev/null; then
     ipms files read $mutable > $sandbox/mutable.yml
     eval $(ipms files read /.brings/system/bin/kwextract.pl | perl /dev/stdin -yml "$sandbox/mutable.yml" | eyml)
     echo author: $author
     peer=$(cat $sandbox/peerids.yml | xyml $author)
     echo "peer: $peer"
     if [ "x$peer" = 'x' ]; then
	     echo error: in $peer
	     exit $$
     fi
   else
     echo "info: mutable $mutable no found"
     exit $(expr $$ - 1)
   fi

 else
   echo "error: no local mutable for $file"
   exit $(expr $$ - 2)
fi

# resolve author mutable
ipms ping -n 1 $peer


if false; then
qm=$(ipms files stat --hash /my/friends/peerids.yml)
list=$(ipms cat /ipfs/$qm | grep '[a-z].*: '  | cut -d' ' -f 2)
for key in $list; do
  echo "$(fullname $key): $key"
  ipath=$(ipms name resolve $key)
  ipms ping -n 1 $key
  qm=$(ipms cat $ipath/$mutable | grep '^- ' | cut -d' ' -f 2)
  ipms files cp /ipfs/$qm /my/friends/janis/public/test/my-first-block.txt
done
fi
}

# ----------------------------------------------------------------------------
mash() { # add content to ipfs and return hash
  file="$1"
  qm=$(ipms add -Q $file --progess=0 --pin=false)
  echo "qm: $qm"
  return $?
}
# ----------------------------------------------------------------------------
is_running() {
if ! ipms swarm addrs local 1>/dev/null; then
  echo ipms not running
  exit $$
else
  return $(true);
fi
}
# ----------------------------------------------------------------------------
ipms_resolve() {
 auth=${1%:*}
 mut=${1##*:}
 nick=${auth%@*}
 ns=${auth##*@}
 if [ "x$auth" = "x$mut" ]; then auth='self:mfs'; nick='self'; ns='mfs'; fi
 if [ "$nick" = 'self' ] && [ "$ns" = 'mfs' ]; then
	 qm=$(ipms files stat --hash $mut)
	 echo qm: $qm
 else
   if [ "$ns" = 'ipfs' ]; then
      if echo $mut | grep -q '/ipns/'; then
	 ipath=$(ipms name resolve $mut)
      else
	 ipath=$(ipms resolve $mut)
      fi
   else 
      if [ "$ns" eq 'ipms' ]; then
	 key=$(get_peer $nick)
	 ipath=$(ipms name resolve $key)
	 root=${mut%%/*}
	 rootkey=$(ipms resolve $ipath/logs/$root.log)
      fi
   fi
 fi
}
# ----------------------------------------------------------------------------
update() { # update release variable for /system/bin ...
if [ "x$update" = 'x1' ]; then
   key='QmV2TqhdDGw41mnzYZCSBXKcyyqJ1qKfpoHSXWooYm1yNi'
   echo "update from $(fullname $key)"
   if rel_ipath=$(ipms resolve /ipns/$key/bin); then
   echo "rel_ipath: $rel_ipath"
      sed -i -e "s,release='.*'$,release='${rel_ipath#/ipfs/}'," $0
      exit 0;
   else
      echo "error: can find key: $key"
      exit $$;
   fi
fi
}
# ----------------------------------------------------------------------------
main ${@};
exit $?
# ----------------------------------------------------------------------------
true; # $Source /my/shell/script/brfetch.sh$
