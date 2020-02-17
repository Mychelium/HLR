#
# defaults:
if [ -f bin/core ]; then
eval "$(bin/core -k)"
else 
 if which core 1>/dev/null; then
   eval "$(core -k)"
 fi
fi

if [ -d $HLRBOOT/bin ]; then
 export PATH="$HLRBOOT/bin:$PATH"
fi
core=$(core)

#CORE=${core^^} # bash only
CORE=$(echo $core | sed -e 's/aeiouy//' | tr [a-z] [A-Z] | cut -c-3)
export PROJDIR=$(pwd)


echo core: $core
echo PROJIR: $PROJDIR
echo HLRBOOT: $HLRBOOT
