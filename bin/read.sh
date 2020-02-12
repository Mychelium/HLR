#

mpath="$1"
qm=$(ipms files stat --hash "$mpath")
echo "$qm: $mpath"
ipms files read "$mpath"
echo "."
