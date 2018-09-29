require 'rubygems'

require 'marky_markov'

root = ARGV[0] || File.dirname(__FILE__)+"/corpii"
Dir.open(root).each do |style|
  next if style.match(/^\./)
  next unless File::Stat.new("#{root}/#{style}").directory?

  markov = MarkyMarkov::Dictionary.new(style)
  Dir.open("#{root}/#{style}").each do |corpus|
    next unless File::Stat.new("#{root}/#{style}/#{corpus}").file?
    puts "parsing #{corpus} into #{style}..."
    markov.parse_file "#{root}/#{style}/#{corpus}"
  end
  markov.save_dictionary!
  puts
end
