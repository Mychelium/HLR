#

set -e
apihost=$(ipms config Addresses.API | cut -d'/' -f 3)
apiport=$(ipms config Addresses.API | cut -d'/' -f 5)
gwhost=$(ipms config Addresses.Gateway | cut -d'/' -f 3)
gwport=$(ipms config Addresses.Gateway | cut -d'/' -f 5)
gwhost=$(ipms config Addresses.Gateway | cut -d'/' -f 3)
gwport=$(ipms config Addresses.Gateway | cut -d'/' -f 5)
peerid=$(ipms config Identity.PeerID)
echo peerid: $peerid
ipath=$(ipms name resolve /ipns/webui.ipfs.io)
xdg-open http://$gwhost:${gwport}$ipath/#/files/
#xdg-open "http://$apihost:$apiport/ipns/webui.ipfs.io/"
ipms --offline name publish --allow-offline $(ipms files stat --hash /.brings) 1>/dev/null
echo  url: http://$gwhost:$gwport/ipns/$peerid
echo  url: http://$apihost:$apiport/webui/#/explore/ipns/$peerid
echo  url: http://$apihost:$apiport/webui/#/files/my


