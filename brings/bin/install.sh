#

export BRNG_HOME=${BRNG_HOME:-$HOME/.brings}
export IPMS_HOME=${IPMS_HOME:-$HOME/.ipms}
export IPFS_PATH=${IPFS_PATH:-$BRNG_HOME/ipfs}
export PATH="$IPMS_HOME/bin:$BRNG_HOME/bin:$PATH"

#export LC_TIME='fr_FR.UTF-8'
if [ "$0" = "/dev/stdin" ]; then
# ----------------------------------------------------------------
# update $symb folder for others ... (Jose S. Furutani)
 symb='minimal'
 key='QmVQd43Y5DQutAbgqiQkZtKJNd8mJiZr9Eq8D7ac2PeSL1'
 qm='QmPpnzb4jqJqqDbNNgnRDzMTyMBT4TYCfybVSuY5w86XHk'
if ipath=$(ipms --timeout 5s resolve /ipns/$key 2>/dev/null); then
 echo "$symb: $ipath # (global)"
else
  # default to ...
  ipath="/ipfs/$qm"
  echo "$symb: ${qm} # (default)"
fi
# copy resolved minimal folder to /.brings
if ipms files stat --hash /.brings 1>/dev/null 2>&1; then
  if pv=$(ipms files stat --hash /.brings/$symb 2>/dev/null); then
    ipms files mv /.brings/$symb /.brings/${symb}~
    if ipms files rm -r /.brings/${symb}~/prev 2>/dev/null; then true; fi
    npv=$(ipms files stat --hash /.brings/${symb}~) # w/o prev
    ipms files rm -r /.brings/${symb}~
    ipms files cp $ipath /.brings/$symb
    if ipms files rm -r /.brings/$symb/prev 2>/dev/null; then true; fi
    nqm=$(ipms files stat --hash /.brings/${symb}) # w/o prev
    if [ "$nqm" != "$npv" ]; then 
      ipms files cp /ipfs/$pv /.brings/$symb/prev
      ipath=/ipfs/$(ipms files stat --hash /.brings/$symb)
      echo "$symb: ${ipath#/ipfs/} # (new)"
    fi
  else
    ipms files cp $ipath /.brings/$symb
  fi
else
  ipms files mkdir /.brings
  ipms files cp $ipath /.brings/$symb
fi
# ---------------------------------------------------------------------
else
 echo "no bootstrap install allowed unless remotely ..."
fi

export BRNG_HOME=${BRNG_HOME:-$HOME/.brings}
if ! test -d $BRNG_HOME/bin; then
ipms get $ipath/bin -o $BRNG_HOME/bin
chmod a+x $BRNG_HOME/bin/*
fi
if ! test -d $BRNG_HOME/etc; then
ipms get $ipath/etc -o $BRNG_HOME/etc
fi
#ipfs cat $ipath/envrc.sh | sed -e "s|^PWD=/.brings$|PWD=$(pwd)|" > $BRNG_HOME/envrc.sh
ipms get $ipath/envrc.sh -o $BRNG_HOME/envrc.sh

exit $?

