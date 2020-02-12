#

# usage: 
#  brcreateid [peerkey]

if [ "x$1" = "x--offline" ]; then
  option="$1"
  shift
fi
PATH=${0%/*}:$PATH
if which core 1>/dev/null; then
  eval "$(core -a | eyml)"
else
  core=hlrings
fi
echo core: $core

main(){

peerid=$(ipms --offline config Identity.PeerID)
peerkey="${1:-$peerid}"
create_identity $peerkey

mpath="/my/identity/./public.yml"
parent=${mpath%%/./*}
if qm=$(ipms files stat --hash $parent 2>/dev/null); then true; fi
if [ "x$qm" != 'x' ]; then
record="$qm: $parent";
echo record: $record
ipms_append_of_text_of_file "$record" "/.$core/published/brindex.log";

# POR: plan of record (akashic public view)
por=$(ipms files stat --hash /.$core)
ipms $option name publish --allow-offline /ipfs/$por
ipms cat /ipfs/$por/published/brindex.log | tail -1
fi
echo url: http://127.0.0.1:8080/ipfs/$qm/public.yml
echo url: http://127.0.0.1:5001/webui/#/files/my/identity/

}

create_identity() {
   userid=$1;
   eval $(perl -S hip6.pl -a $userid 2>/dev/null | eyml)
   eval "$(perl -S fullname.pl -a $userid 2>/dev/null | eyml)"
   eval "$(perl -S spot.pl -a $userid 2>/dev/null | eyml)"
   uniq="${hipq:-cadavre exquis}"
   date=$(date +"%D")
   tic=$(date +"%s")
   if ! ipms files stat --hash /my/identity/attr 1>/dev/null 2>&1; then
     ipms files mkdir -p /my/identity/attr
   tofu=$(echo "tofu: $date ($tic)" | ipms add -Q --pin=false --hash sha1 --cid-base base58btc)
   type=$(echo "is an early adopter" | ipms add -Q --pin=false --hash sha1 --cid-base base58btc)
   status=$(echo "is alive" | ipms add -Q --pin=false --hash sha1 --cid-base base58btc)
   human=$(echo "is a robot" | ipms add -Q --pin=false --hash sha1 --cid-base base58btc)
   ipms files cp /ipfs/$tofu /my/identity/attr/tofu
   ipms files cp /ipfs/$type /my/identity/attr/type
   ipms files cp /ipfs/$status /my/identity/attr/status
   ipms files cp /ipfs/$human /my/identity/attr/botonot
   fi
   attr=$(ipms files stat --hash /my/identity/attr)
   if ! ipms files stat --hash /my/identity/public.yml 1>/dev/null 2>&1; then
      ipms files write --create --truncate /my/identity/public.yml <<EOF
--- # This is my blockRing™ Sovereign identity
name: "$fullname"
uniq: "$uniq"
date: $date
exp: never
hip6: $hip6
attr: $attr
EOF
   fi

}

ipms_append_of_text_of_file() {
    text="$1";
    file="$2";
    fname="${2##*/}"
    ipms files read "${file}" > /tmp/${fname}
    echo "$text" >> /tmp/${fname}
    ipms files write --create  --truncate "${file}" < /tmp/${fname}
    rm -f /tmp/${fname}
}

main ${@}
exit $?;

true; # $Source: /my/shell/scripts/brindex.sh$
