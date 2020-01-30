#

tic=$(date +%s)
file="$1"
fname="${file%.*}"

if test -e "$fname.html"; then
qm=$(ipms add -Q -w "$fname.html" "$file" "$0")
echo qm: $qm
fi
pandoc -f markdown -t html -o "$fname.htm" $file 

if [ "x$qm" != 'x' ]; then
sed -e "s,tic: [0-9][0-9]*,tic: $tic," \
    -e "s,previous: <a href=\"\(.*\)/ipfs/.*\">.*</a>,previous: <a href=\"\1/ipfs/$qm/$fname.html\">$qm</a>," \
    "$fname.htm" > "$fname.html"
else
 # no previous: keep as is...
 mv "$fname.htm" "$fname.html"
fi
qm=$(ipms add -Q -w "$fname.html" "$file" "$0")
echo "url: http://127.0.0.1:8080/ipfs/$qm/$fname.html"

exit $?

true; # $Source: /my/shell/script/hladd.sh$

