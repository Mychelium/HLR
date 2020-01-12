#

set -ex

main() {
   mutable="$1";
   ipath=$(ipms_resolve $mutable);
   if [ $? -ne 0 ]; then
      echo "error: $ipath $?"
   else
      echo ipath: $ipath
   fi
}

ipms_resolve() {
   auth=${1%:*}
   mut=${1##*:}
   nick=${auth%@*}
   ns=${auth##*@}
   if [ "x$auth" = "x$mut" ]; then auth='self:mfs'; nick='self'; ns='mfs'; fi
   if [ "$nick" != 'self' ]; then
      key=$(get_peer $nick)
      ipath=$(ipms name resolve $key)
      root=${mut%%/*}
      rootkey=$(ipms resolve $ipath/logs/$root.log)
      echo rootkey: $rootkey
   fi
   exit $?;
   if [ "$nick" = 'self' ] && [ "$ns" = 'mfs' ]; then
      log info "local mfs: $mut"
      qm=$(ipms files stat --hash $mut)
      echo /ipfs/$qm
   else
      if [ "$ns" = 'ipfs' ]; then
	 if echo $mut | grep -q '/ipns/'; then
	    log info "ipns: $mut"
	    ipath=$(ipms name resolve $mut)
	 else
	    log info "ipfs: $mut"
	    ipath=$(ipms resolve $mut)
	 fi
      else
	 if [ "$ns" = 'ipms' ]; then
	    log info "ipms: $mut"
	 else
	    log info "nick: $nick; ns: $ns; $mut"
	 fi
      fi
   fi
}
log() {
  echo "$1: $2" 1>&2
}

main ${@};
exit $?;
true; # $Source: /my/shell/scripts/resolve.sh $
