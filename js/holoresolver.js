// glocal wikilink resolver ...

const maps_hash = 'QmNpBWwGCmWfVMYVL5wrEAyEfJtoFLZNteeiVs3fXdzbJc';
const map_url = 'https://ipfs.blockring™.ml/ipns/' + maps_hash + '/wikimap.json';
// the wikimap is posted using the command:
// ipms --offline name publish --key=wikimap --allow-offline /ipfs/$(ipms add -w -Q test/wikimap.json)

e = document.getElementById('wiki');
get_url(e,map_url);

function get_url(e,u) { // e=elements, u=url
   fetch(u, { mode:'cors' })
     .then(status)
     .then( resp => resp.json() )
     .then( map => {
        buf = e.innerHTML;
        let orig = buf;
        // links : [text info](url)
        let rex = RegExp('\\[([^\\]]+)\\]\\(([^\\)]+)\\)(?!\')','g')
        buf = buf.replace(rex,'<a href="'+"$2"+'">'+"$1"+'</a>');
        for (let key in map) {
          let href = map[key];
          // negative lookahead for ' ; [[keyword]]
          rex = RegExp('\\[\\['+key+'\\]\\](?!\')','g')
          buf = buf.replace(rex,'<a href="'+href+'">'+key+'</a>');
          // links : [text info][keyword]
          rex = RegExp('\\[([^\\]]+)\\]\\['+key+'\\](?!\')','g')
          buf = buf.replace(rex,'<a href="'+href+'">'+"$1"+'</a>');
        }
        // links : [text info][keyref]
        rex = RegExp('\\[([^\\]]+)\\]\\[([^\\]]+)\\](?!\')','g')
        buf = buf.replace(rex,"<a target=_blank href=\"https://duckduckgo.com/?q=!g+$2+%2B%23mychelium\">$1</a>");
        // links : [[keyref]]
        rex = RegExp('\\[\\[([^\\]]+)\\]\\](?!\')','g')
        buf = buf.replace(rex,"<a target=_blank href=\"https://duckduckgo.com/?q=!g+$1+%2B%22%23mychelium%22\">$1</a>");
        // links : #hashtag
        rex = RegExp('#([a-z][\\S]+)','ig')
        buf = buf.replace(rex,"<a target=_blank href=\"https://duckduckgo.com/?q=!g+%2B%22%23$1%22\">#$1</a>");
        // links : <url>
        rex = RegExp('<([a-z][\\S]+)>','ig')
        if (match = buf.match(rex)) { console.log(match) }
        buf = buf.replace(rex,"&lt;<a href=\"$1\">$1</a>&gt;");
        e.innerHTML = buf;
        if (o = document.getElementById('orig')) {
          o.innerHTML = orig;
        }  
      } 
     )
   .catch(function(error) {
      console.log('catch: '+error)
   });

}

function status(resp) {
  if (resp.status >= 200 && resp.status < 300) {
    return Promise.resolve(resp)
  }
  return Promise.reject(new Error(resp.statusText))
}
 
true; 
