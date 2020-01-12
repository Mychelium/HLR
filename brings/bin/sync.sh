#
echo PROJDIR: $PROJDIR
export MFS_HOME=${MFS_HOME:-$PROJDIR/mfs}
echo MFS: $MFS_HOME
if [ ! -d $MFS_HOME ]; then
 echo "error: ! -d $MFS_HOME"
 exit $$
fi
if [ "x$BRNG_HOME" = 'x' ]; then
   echo "error: no BRNG_HOME variable"
   exit $$
fi
qm=$(ipms add -Q -r .)
ipms files rm -r /.brings/bin
ipms files cp /ipfs/$qm /.brings/bin
rsync -ua --exclude '*~' --exclude '*.sw*' $MFS_HOME/.brings/bin/ $BRNG_HOME/bin
rsync -uvab $BRNG_HOME/bin/ $MFS_HOME/.brings/bin

