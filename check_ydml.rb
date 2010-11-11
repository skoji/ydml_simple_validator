$KCODE='u'
require 'rubygems'
require 'nokogiri'
require 'kconv'

here = File.dirname(__FILE__)
schema = Nokogiri::XML::RelaxNG(File.open("#{here}/ydml.rng"))

def usage
  STDERR.print "check_ydml.rb <source-directory>\r\n"
  exit 1
end

tags = ['left','/left', 'center','/center', 'right', '/right', 'large', '/large','small','/small', 'bold', '/bold', 'bouten', '/bouten', 'ruby', '/ruby', 'quote', '/quote', 'newpage', 'img=".+?"','hasen']
$reg_tags = Regexp.new('<((' + tags.join(')|(') + '))>')

def to_valid_ydml(str)

  tagstart = '::::thisistagstart::::'
  tagend = '::::thisistagend::::'
  str.gsub!($reg_tags, tagstart + '\1' + tagend)
  str.gsub!('<', '&lt;')
  str.gsub!('>', '&gt;')
  str.gsub!(tagstart, '<')
  str.gsub!(tagend, '>')
  str.gsub!('&', '&amp;')

  str.gsub!(/<sonomama>(.*?)<\/sonomama>/m) { |s| $1.gsub('<','&lt;').gsub('>', '&gt;') }
  str.gsub!(/<hasen>/, '<hasen /')
  str.gsub!(/<img="(.*?)"(.*?)>/, '<image src="\1" \2 />')
  '<ydml>' + str + '</ydml>'
end

usage if ARGV.length < 1

dir = ARGV[0]

Dir[File.join(dir, "[0-9]*.txt")].each {
  |f|
  File.open(f) {
    |io|
    doc = Nokogiri::XML(to_valid_ydml(Kconv.toutf8(io.read).gsub(/\r\n?/, "\n")))
    doc.errors.each {
      |e|
      puts "#{f}, #{e.line},  #{e.message}"
    }
    schema.validate(doc).each {
      |e|
      puts "#{f}, #{e.line},  #{e.message}"
    }
  }
}
