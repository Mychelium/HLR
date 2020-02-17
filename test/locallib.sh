#

if ! which core 1>/dev/null; then
export PATH="$HLR_HOME/bin:$PATH"
fi
if ! which core 1>/dev/null; then
echo "can't detect install"
exit -$$;
fi

PERL5LIB=${PERL5LIB:-$HLR_HOME/perl5/lib/perl5}
if [ -d $PERL5LIB ]; then
  eval $(perl -I$PERL5LIB -Mlocal::lib=${PERL5LIB%/lib/perl5})
  export PERL5LIB=${PERL5LIB%%:*}
fi
