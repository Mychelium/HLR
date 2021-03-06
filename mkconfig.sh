#

if [ "x$HLRBOOT" != 'x' ]; then
  export PATH="$HLRBOOT/bin:$PATH"
else
  if [ -e detect.sh ]; then
    . detect.sh
  else
    echo "// please run the following before"
    echo "source \$HLRBOOT/detect.sh"
    exit -$$
  fi 
fi

core=$(core)
#CORE=${core^^} # bash only
CORE=$(echo $core | sed -e 's/aeiouy//' | tr [a-z] [A-Z] | cut -c-3)

export PROJDIR=$(pwd)
eval "export ${CORE}_HOME=\${${CORE}_HOME:-\$HOME/.$core}"
export IPMS_HOME=${IPMS_HOME:-$HOME/.ipms}
export IPFS_PATH=${IPFS_PATH:-$HOME/.ipfs}
export PERL5LIB=${PERL5LIB:-$HOME/.$core/perl5/lib/perl5}

echo "$0: HoloRing Configuration Script"
echo Booting from HLRBOOT: $HLRBOOT
if test -e config.sh; then
. $(pwd)/config.sh
else # [
 if test -e $HLRBOOT/config.sh; then
 . $HLRBOOT/config.sh
 else # [

# Ask questions ...
# -------------------------------------------
echo where do you want to store $CORE data ?
echo -n "[$HLR_HOME] "
read ans
if [ "x$ans" != 'x' ]; then
export ${CORE}_HOME=$ans
fi
# -------------------------------------------
echo where do you want to install Perl5 local modules ? 
echo -n "[$PERL5LIB] "
read ans
if [ "x$ans" != 'x' ]; then
export PERL5LIB=$ans
fi
# -------------------------------------------
echo where do you want to install IPMS software? 
echo -n "[$IPMS_HOME] "
read ans
if [ "x$ans" != 'x' ]; then
export IPMS_HOME=$ans
fi
# -------------------------------------------
echo where do you want to IPFS repository ?
echo -n "[$IPFS_PATH] "
read ans
if [ "x$ans" != 'x' ]; then
export IPFS_PATH=$ans
fi
# -------------------------------------------
echo "which port you'd like to use for ipfs'gateway ?"
gwport=8080
echo -n "[$gwport] "
read ans
if [ "x$ans" != 'x' ]; then
gwport=$ans
fi
# -------------------------------------------
echo "which port you'd like to use for ipfs'api ?"
apiport=5001
echo -n "[$apiport] "
read ans
if [ "x$ans" != 'x' ]; then
apiport=$ans
fi
# -------------------------------------------
# write out config.yml for next time!
cat > $HLRBOOT/config.sh <<EOF
# ipms config files

export PROJDIR=$PROJDIR
# ------------
apiport=$apiport
gwport=$gwport
# ------------
export ${CORE}_HOME=\${${CORE}__HOME:-$HLR_HOME}
export IPMS_HOME=\${IPMS_HOME:-$IPMS_HOME}
export IPFS_PATH=\${IPFS_PATH:-$IPFS_PATH}
#export MFS_HOME=\${MFS_HOME:-\$PROJDIR/mfs$}

# PERL5LIB=${PERL5LIB:-$HLR_HOME/perl5/lib/perl5}

export PERL5LIB=\${PERL5LIB:-$PERL5LIB}
EOF
chmod a+x $HLRBOOT/config.sh

if false; then
MFS_HOME=${MFS_HOME:-$PROJDIR/mfs}
echo "MFS_HOME: $MFS_HOME"
#PATH="$MFS_HOME/.$core/bin:$PATH"
fi

fi # ]
fi # ]

if [ "xPROJDIR" != 'x' ]; then echo "PROJDIR: $PROJDIR"; fi
# copy envrc to $HLR_HOME/
#HLR_HOME=${HLR_HOME:-$HOME/.$core}
#SRC=$MFS_HOME/$core
#rsync -auv $SRC/envrc.sh $HLR_HOME/

cat > $PROJDIR/envrc.sh <<EOF
# config ($(date +'%D %T'))
if [ "x\$HLRBOOT" != 'x' ]; then
  export PATH="\$HLRBOOT/bin:$PATH"
fi
# source custom setting ...
if test -e \$HLRBOOT/config.sh; then
. $HLRBOOT/config.sh
fi

# IPMS:
export IPMS_HOME="${IPMS_HOME:-$HOME/.ipms}"
if [ -d \$IPMS_MODE ]; then
  export PATH="\$IPMS_MODE/bin:\$PATH"
fi

# $core:
export ${CORE}_HOME="${HLR_HOME:-$HOME/.$core}"
if [ -d \$${CORE}_HOME/bin ]; then
  export PATH="\$${CORE}_HOME/bin:\$PATH"
fi

# Perl: 
if [ -d \$PERL5LIB ]; then
  eval \$(perl -I\$PERL5LIB -Mlocal::lib=\${PERL5LIB%/lib/perl5})
  export PERL5LIB=\${PERL5LIB%%:*}
else
if [ -d \$HOME/.$core/perl5/lib/perl5 ]; then
  PERL5LIB=\$HOME/.$core/perl5/lib/perl5
  eval \$(perl -I\$PERL5LIB -Mlocal::lib=\${PERL5LIB%/lib/perl5})
  export PERL5LIB=\${PERL5LIB%%:*}
else
  echo "PERL5LIB: not properly set (\$PERL5LIB)."
fi
fi

# IPFS:
export IPFS_PATH=\${IPFS_PATH:-\$HOME/.$core/ipfs}

if ! test -e \$IPFS_PATH/config; then
  echo "IPFS_PATH: not properly set (\$IPFS_PATH)."
  return $$
fi

if [ "x\$PROJDIR" = 'x' ]; then
PROJDIR=$(pwd)
fi
if [ -d \$PROJDIR/bin ]; then
  PATH="\$PROJDIR/bin:\$PATH"
fi

if ! ipms swarm addrs local 1>/dev/null 2>&1; then
  echo "WARNING: no ipms daemon running !"
  # ipmsd.sh
else
  echo "ipms already running"
fi

EOF
rsync -au $PROJDIR/envrc.sh $HLR_HOME/ 1>/dev/null 2>&1
echo "please source the $(pwd)/envrc.sh file"
echo " or put . ${HLR_HOME}/envrc.sh in your .bashrc file"


