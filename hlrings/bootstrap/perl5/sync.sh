#

qm=$(ipms add -r -Q .)
if ipms files stat --hash /.hlr/bootstrap/perl5 2>/dev/null; then
 ipms files rm -r /.hlr/bootstrap/perl5
else
  ipms files mkdir -p /.hlr/bootstrap
fi
ipms files cp /ipfs/$qm /.hlr/bootstrap/perl5
ipms files stat /.hlr/bootstrap/perl5
exit $?



