
require 'net/http'
require 'rubygems'
require 'xmlsimple'
require 'json'
require 'yaml'


wowilist = Net::HTTP.get("www.wowinterface.com", "/rss/author-20806.xml")
wowi_xml = XmlSimple.xml_in(wowilist)['channel'][0]['item']

names = wowi_xml.map {|v| v['title'].first.gsub(/ \(.+\)$/, '')}
names.map! {|v| [v.gsub(/[ ?']/, '').downcase, v]}

wowi_xml.map! {|v| [v['title'].first.gsub(/\(.+\)$/, '').gsub(/[ ?']/, ''), v['link'].first.gsub(/(info\d+).+$/, '\1')]}
wowi_xml += wowi_xml.map {|v| [v[0].downcase, v[1]]}

File.open(File.join("..", "js", "wowi.js"), "w") do |f|
  f << "var wowi_links = " << Hash[*wowi_xml.flatten].to_json << "\n"
  f << "var wowi_names = " << Hash[*names.flatten].to_json << "\n"
end

# p(Hash[*names.flatten])
# .to_json


# def get_wowi_id(name)
#   @@wowi_xml.each do |v|
#     title = $1.gsub(" ", "").downcase if v['title'].first =~ /(.+) \(.+\)/
#     return $1 if !title.nil? and title == name.gsub("_", "").downcase and v['guid'].first =~ /info(\d+)\-/
#   end
#   nil
# end
#
#
# blacklist = ["addonloader", "ouf"]
# data = []
# Net::HTTP.start("github.com") do |http|
#   res = http.get("/api/v1/json/tekkub")
#   data = JSON.parse(res.body)["user"]["repositories"]
#   data.reject! {|r| blacklist.include?(r["name"]) || r["description"].empty? || !(r["description"] =~ /\AWoW Addon - /)}
#   data.sort! {|a,b| a["name"] <=> b["name"]}
#   data.map! {|r| {"name" => r["name"], "description" => r["description"].gsub(/\AWoW Addon - /, ""), "pledgie" => r["pledgie"]}}
#
#   data.map! do |r|
#     reponame = r["name"]
#
#     listing = http.get "/tekkub/#{reponame}.git/"
#     addon_name = $1 if listing.body && listing.body =~ /<a href="(.+).toc">(.+).toc<\/a>/
#     raise "Cannot find addon name for #{reponame}" unless addon_name
#     r["name"] = addon_name
#
#     tocfile = http.get "/tekkub/#{reponame}.git/#{addon_name}.toc"
#     description = $1 if tocfile.body =~ /## Notes: (.+)/
#     raise "Cannot find description for #{reponame}" unless description
#     r["description"] = description
#
#     wowi = get_wowi_id reponame
#     r["wowi"] = wowi if wowi
#
#     r
#   end
# end
#
# puts YAML::dump({"addons" => data})
