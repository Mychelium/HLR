# 
export BRNG_HOME=${BRNG_HOME:-$HOME/.brings}
qm=$(ipms add -r -Q ../../bootstrap)
ipms name publish --allow-offline --key=bootstrap /ipfs/$qm
exit $?
