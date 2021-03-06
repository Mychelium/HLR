#
# This script either
# ... publish a hlrings folder (if it exits)
#     and/or sync'd up the mfs version of it
core=hlrings
set -e
if echo "$0" | grep -q '^/'; then
  rootdir="${0%/bin/*}"
else
  rootdir="$(pwd)/$0"; rootdir="${rootdir%/bin}"
fi
echo "rootdir: $rootdir"
symb="${rootdir##*/}"
# ----------------------------------------------------------------
if ipms key list | grep -q -w $symb; then
 key=$(ipms key list -l | grep -w $symb | cut -d' ' -f 1)
 echo key: $key
 if test -d $rootdir; then
   qm=$(ipms add -r -Q $rootdir)
   sed -i -e "s/qm='.*'$/qm='$qm'/" \
          -e "s,ipath='/ipfs/.*'$,ipath='/ipfs/$qm'," \
          -e "s/key='.*'$/key='$key'/" $0 # $'s are important /!\
   ipms name publish --allow-offline --key=$symb /ipfs/$qm
 fi
else # for others ...
 key='QmVdu2zd1B8VLn3R8xTMoD2yBVScQ1w9UMbW7CR1EJTVYw'
 qm='QmVEwqUqoS6CkoEafHtmduUp1gsMGbsyY6fy1mtNwHVddS'
fi
# ----------------------------------------------------------------
# update $symb folder (Pablo O. Haggar)
if ipath=$(ipms --timeout 5s resolve /ipns/$key 2>/dev/null); then
 echo "$symb: $ipath # (global)"
else
  # default to Elvis C. Lagoo
  # ipms add -r -Q $PROJDIR/.$core/$symb
  if [ "x$qm" = 'x' ]; then
  ipath='/ipfs/QmVEwqUqoS6CkoEafHtmduUp1gsMGbsyY6fy1mtNwHVddS'
  else 
  ipath="/ipfs/$qm"
  fi
  echo "$symb: ${ipath#/ipfs/}"
fi
if ipms files stat --hash /.$core 1>/dev/null 2>&1; then
  if pv=$(ipms files stat --hash /.$core/$symb 2>/dev/null); then
    ipms files rm -r /.$core/$symb
    ipms files cp $ipath /.$core/$symb
    if [ "${ipath#/ipfs/}" != "$pv" ]; then
      if ipms files rm -r /.$core/$symb/prev 2>/dev/null; then true; fi
      ipms files cp /ipfs/$pv /.$core/$symb/prev
      ipath=/ipfs/$(ipms files stat --hash /.$core/$symb)
      echo "$symb: ${ipath#/ipfs/} # (new)"
    fi
  else
    ipms files cp $ipath /.$core/$symb
  fi
else
  ipms files mkdir /.$core
  ipms files cp $ipath /.$core/$symb
fi
# ---------------------------------------------------------------------

