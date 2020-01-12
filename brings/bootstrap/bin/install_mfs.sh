# 

# this script updates /.brings while preserving mutables

set -e
MFS_SRC=${MFS_SRC:-$(pwd)/mfs}
if [ -d $MFS_SRC ]; then
  echo mfs: $MFS_SRC
  mfs=$(ipms add -Q -r -w $MFS_SRC/.brings)
else
  if key=$(ipms key list -l | grep -w MFS | cut -d' ' -f 1); then
	ipath=$(ipms name resolve $key)
	mfs=${ipath#/ipfs/}
  else # default MFS key
    mfs='QmcSsSV9z16ynPWp4W7o4JTbztQV49hFVPU5Uktic9Swad'
  fi
fi
if ipms files stat --hash /.brings 1>/dev/null; then
   if ! mt=$(ipms files stat --hash /.brings/mutables); then
     mt='QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn'
   fi
   if ! logs=$(ipms files stat --hash /.brings/logs); then
     logs='QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn'
   fi
   ipms files rm -r /.brings
   ipms files cp /ipfs/$mfs/.brings /.brings
   ipms files cp /ipfs/$mt /.brings/mutables
   ipms files cp /ipfs/$logs /.brings/logs
else
   ipms files cp /ipfs/$mfs/.brings /.brings
fi
if ipms ping -n 1 Qmd2iHMauVknbzZ7HFer7yNfStR4gLY1DSiih8kjquPzWV; then true; fi
qm=$(ipms files stat --hash /.brings)
echo mfs: $mfs
echo qm: $qm
ipms $offline name publish --allow-offline /ipfs/$qm | sed -e 's/^/info: /'
peerid=$(ipms config Identity.PeerID)
echo url: http://gateway.ipfs.io/ipns/$peerid
echo url: http://127.0.0.1:8080/ipfs/$qm
exit $?

true; # $Source: ~$
