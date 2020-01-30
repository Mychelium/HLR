#
# defaults:
core='hlr'
#CORE=${core^^} # bash only
CORE=$(echo $core | tr [a-z] [A-Z])
export PROJDIR=$(pwd)
eval "export ${CORE}_HOME=\${${CORE}_HOME:-\$HOME/.$core}"
export IPMS_HOME=${IPMS_HOME:-$HOME/.ipms}
export IPFS_PATH=${IPFS_PATH:-$HOME/.$core/ipfs}
export PERL5LIB=${PERL5LIB:-$HOME/.$core/perl5/lib/perl5}

echo "$0: HoloRing Configuration Script"
if test -e config.sh; then
	. $(pwd)/config.sh
else

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
# write out config.yml for next time!
cat > config.sh <<EOF
# ipms config files
export PROJDIR=$PROJDIR
# ------------
export ${CORE}_HOME=\${${CORE}__HOME:-$HLR_HOME}
export PERL5LIB=\${PERL5LIB:-$PERL5LIB}
export IPMS_HOME=\${IPMS_HOME:-$IPMS_HOME}
export IPFS_PATH=\${IPFS_PATH:-$IPFS_PATH}
#export MFS_HOME=\${MFS_HOME:-\$PROJDIR/mfs$}
EOF
chmod a+x config.sh

if false; then
MFS_HOME=${MFS_HOME:-$PROJDIR/mfs}
echo "MFS_HOME: $MFS_HOME"
#PATH="$MFS_HOME/.$core/bin:$PATH"
fi

fi

if [ "xPROJDIR" != 'x' ]; then echo "PROJDIR: $PROJDIR"; fi
# copy envrc to $HLR_HOME/
#HLR_HOME=${HLR_HOME:-$HOME/.$core}
#SRC=$MFS_HOME/$core
#rsync -auv $SRC/envrc.sh $HLR_HOME/

cat > $PROJDIR/envrc.sh <<EOF
# config ($(date +'%D %T'))
export ${CORE}_HOME=${HLR_HOME:-$HOME/.$core} 
if [ -d PERL5LIB=\$HOME/.$core/perl5/lib/perl5 ]; then
    export PERL5LIB=\$HOME/.$core/perl5/lib/perl5
else
  echo "PERL5LIB: not properly set (\$PERL5LIB)."
fi
export IPMS_HOME=${IPMS_HOME:-$HOME/.ipms}
export IPFS_PATH=\${IPFS_PATH:-\$HOME/.$core/ipfs}

if ! test -e \$IPFS_PATH/config; then
  echo "IPFS_PATH: not properly set (\$IPFS_PATH)."
  return $$
fi

if test -e \$${CORE}_HOME/envrc.sh; then
. \$${CORE}_HOME/envrc.sh
else
export PATH="\$${CORE}_HOME/bin:\$IPMS_HOME/bin:\$PATH"
fi

if [ "x\$PROJDIR" = 'x' ]; then
PROJDIR=$(pwd)
PATH="\$PROJDIR/bin:\$PATH"
fi

if ! ipms swarm addrs local 1>/dev/null 2>&1; then
  echo "WARNING: no ipms daemon running !"
  ipmsd.sh
else
  echo "ipms already running"
fi

EOF
rsync -au $PROJDIR/envrc.sh $HLR_HOME/ 1>/dev/null 2>&1
echo "please source the $(pwd)/envrc.sh file"
echo " or put . ${HLR_HOME}/envrc.sh in your .bashrc file"


