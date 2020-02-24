# HoloRing 

Holoring is a new kind of blockchain, part of the [Planetary OS for Consciousness Evolution][PCE],
and is the backbone 
[P2P Collective intelligence][P2PCI] toolkit.

[PCE]: https://duckduckgo.com/?q=Planetary+OS+for=consciousness+evolution
[P2PCI]: https://github.com/P2PCI-project/P2PCI-Platform/wiki
[hlring]: https://github.com/P2PCI-project/holoRing

Holorings are comprise of 3 modules:

 - IPFS: immutable content addressable store
 - IPMS: mutable key values store (permissionned)
 - CRDT: indepotent merge

# Software folders organization; MutableFileSystem (MFS)

* hlrings (holoring software)
* ipms (mutable system)
* etc (miscellaneous)

====

## INSTALLATION

### Computers w/o bash:

 1. install [ipfs-desktop][1] (<https://github.com/ipfs-shipyard/ipfs-desktop>)
 2. [if necessay (i.e. not included w/ ipfs-desktop above) install [go-ipfs][2] ]
    (<http://127.0.0.1:8080/ipns/dist.ipfs.io/#go-ipfs>)
 3. optionally install a browzer extension [ipfs-companion][3] ([firefox](https://addons.mozilla.org/en-US/firefox/addon/ipfs-companion/) or [chrome](https://chrome.google.com/webstore/detail/ipfs-companion/nibjojkomfdiaoajekhjakgkdhaomnch))

 4. IPFS Tutorial :
    create your holoring identity (holoID)

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
