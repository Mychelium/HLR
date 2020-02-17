## README for MutableFileSystem (MFS)

* hlrings (holoring software)
* ipms (mutable system)
* etc (miscellaneous)

### Computers w/o bash:

 1. install [ipfs-desktop][1] (<https://github.com/ipfs-shipyard/ipfs-desktop>)
 2. [if necessay (i.e. not included w/ ipfs-desktop above) install [go-ipfs][2] ]
    (<http://127.0.0.1:8080/ipns/dist.ipfs.io/#go-ipfs>)
 3. optionally install a browzer extension [ipfs-companion][3] ([firefox](https://addons.mozilla.org/en-US/firefox/addon/ipfs-companion/) or [chrome](https://chrome.google.com/webstore/detail/ipfs-companion/nibjojkomfdiaoajekhjakgkdhaomnch))

[1]: https://duckduckgo.com=!g+ipfs-desktop
[2]: https://duckduckgo.com=!g+go-ipfs
[3]: https://github.com/ipfs-shipyard/ipfs-companion


### Computers w/ bash :

### pre-install

 1. start a bash command shell
 2. git clone https://github.com/michel47/HLR.git
 3. cd HLR
 4. source detect.sh # detect distrib. and set boot directory
 5. sh mkconfig.sh # create congig.sh and envrc.sh

### install 
 
 0. source $HLRBOOT/envrc.sh
 1. install ipms:
   sh $HLRBOOT/ipms/bin/install_ipms.sh 

 2. install perl modules
    sh $HLRBOOT/hlrings/bootstrap/perl5/install_local-lib.sh
    sh $HLRBOOT/hlrings/bootstrap/perl5/install_modules.sh


 3. 

    
  

### utils

* share.sh
