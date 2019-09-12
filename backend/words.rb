require 'json'

begin
  files = %x(cd /home/seims/git/wot/backend/embeddings && find -iname '*vocab*')
  files = files.split("\n").map{ |f| f.sub(".", "/home/seims/git/wot/backend/embeddings") }
  result = files.map{ |f| 
    contents = File.read(f, encoding: 'iso-8859-1').split("\n")
    words = contents.map{ |line|
      l = line[/aV.*/] || ''
      l = '' if l.match(/^\d+$/)
      l = l.sub(/aV/, "").force_encoding('iso-8859-1').encode('UTF-8')
    }.reject{ |w| w=='' }
    [f, words]
  }.to_h
  File.write("dump.json", JSON.generate(result))
end