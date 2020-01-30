#

symb=core
core=hlr
set -e
if ! which ipms 1>/dev/null; then
alias ipms=ipfs
fi

qm=$(ipms add -r -Q $core)
echo qm: $qm
if ! ipms key list -l | grep -w -q $symb;  then
  echo \$?: $?
  ipms key gen -t rsa -s 3072 $symb
fi
key=$(ipms key list -l | grep -w $symb | cut -d' ' -f 1)
echo key: $key
ipms name publish --allow-offline --key=$symb /ipfs/$qm
echo 127: http://127.0.0.1:8080/ipfs/$qm
echo webui: http://127.0.0.1:5001/webui/#/explore/ipfs/$qm

echo local: http://127.0.0.1:8199/ipfs/$qm
echo yg_url: http://yoogle.com:8080/ipfs/$qm
echo cf_url: https://cloudflare-ipfs.io/ipfs/$qm
echo br_url: https://ipfs.blockringtm.ml/ipfs/$qm
echo gw_url: https://gateway.ipfs.io/ipfs/$qm
echo ipns: https://gateway.ipfs.io/ipns/$key

exit $?

