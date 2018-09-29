require 'rubygems'
require 'json'

require 'bunny'
require 'marky_markov'

require './lib/vcap'

def bw(n,m)
  n+rand(1+m-n)
end

def hire(root, style, net)
  Thread.new do
    puts "hiring someone who can write in the style of #{style}..."
    writer = MarkyMarkov::Dictionary.new("#{root}/#{style}")
    puts "#{style} writer is ready to write!"

    ch = net.create_channel
    q = ch.queue("pub.#{style}")
    q.delete
    q = ch.queue("pub.#{style}", :arguments => { 'x-max-length' => 5,
                                                 'x-overfow'    => 'drop-head'})
    loop do
      title = writer.generate_n_words(bw(3, 4))
      text  = (1..bw(1, 4)).map {
        "<p>"+writer.generate_n_sentences(bw(3, 7))+"</p>"
      }.join("")

      q.publish({ :title => title, :text => text }.to_json)
      puts "#{style} desk just popped off another masterpiece..."
    end
    sleep bw(2, 5)
  end
end

###############################################

tag = ENV['RABBITMQ_TAG'] || 'rabbitmq'
rabbit = VCAP.service(tag)
if rabbit.nil?
  STDERR.puts "No RabbitMQ service found in VCAP_SERVICES, for tag '#{tag}'"
  STDERR.puts "You can set the RABBITMQ_TAG env var to change the tag we look for."
  exit(1)
end

net = Bunny.new(rabbit["uri"])
net.start

root = "./styles"
Dir.open(root).each do |dict|
  next unless dict.match(/\.mmd$/)
  hire(root, dict.gsub(/\.mmd$/, ''), net)
end

loop { sleep 5 }
