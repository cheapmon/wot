require 'json'
require 'httparty'

dump = JSON.parse(File.read("dump.json"))

hash = {
  "eng_fiction" => [],
  "eng_all" => [],
  "ger_all" => []
}

corpus_dict = {
  "eng-fiction-all_sgns" => "eng_fiction",
  "eng-all_sgns" => "eng_all",
  "ger-all_sgns" => "ger_all"
}

dump.each{ |k,v|
  corpus = k[/(eng-fiction-all_sgns)|(eng-all_sgns)|(ger-all_sgns)/]
  corpus = corpus_dict[corpus]
  hash[corpus].push(*v)
}

hash.each{ |k,v|
  hash[k] = v.uniq
}

File.write("dump2.json", JSON.generate(hash))