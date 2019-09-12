require 'json'
require 'httparty'
require "sqlite3"

URL = "http://localhost:8000/vec"
EMBEDDINGS = {
  "eng_fiction" => "eng-fiction-all_sgns",
  "eng_all" => "eng-all_sgns",
  "ger_all" => "ger-all_sgns"
}
DB = SQLite3::Database.new "histwords"

begin
  word_count = 0
  json = JSON.parse(File.read("dump3.json"))
  json.each{ |k, v|
    emb = EMBEDDINGS[k]
    v.each{ |word|
      res = {}
      begin
        res = JSON.parse(HTTParty.get("#{URL}?word=#{word}&embedding=#{emb}").body)
      rescue
        next
      end
      vectors = res["vectors"]
      vectors.each{ |vec|
        DB.execute("insert into relations (corpus, word, rel_word, year, x, y) 
          values ('#{k}', '#{word}', '#{vec["word"]}', #{vec["year"]}, 
          #{vec["pos"]["x"]}, #{vec["pos"]["y"]});")
      }
      puts "#{word}: Added #{vectors.size} entries."
    }
  }
end