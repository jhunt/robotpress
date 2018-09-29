require 'rubygems'
require 'json'

require 'sinatra'
require 'bunny'

require './lib/vcap'

tag = ENV['RABBITMQ_TAG'] || 'rabbitmq'
rabbit = VCAP.service(tag)
if rabbit.nil?
  STDERR.puts "No RabbitMQ service found in VCAP_SERVICES, for tag '#{tag}'"
  STDERR.puts "You can set the RABBITMQ_TAG env var to change the tag we look for."
  exit(1)
end
RMQ_ENDPOINT = rabbit["uri"]

set :public_folder, File.dirname(__FILE__)+'/htdocs'
set :port, ENV['PORT'] || '4567'

puts
puts
puts "RobotPress web application starting up on port *:#{ENV['PORT'] || '4567'}"
puts
puts

get '/' do
  File.read('htdocs/index.html')
end

get '/story/:style' do
  # input: ?style=x
  style = params['style']

  # connect to rabbitmq
  net = Bunny.new(RMQ_ENDPOINT)
  net.start
  ch = net.create_channel
  x = ch.default_exchange

  _, _, msg = ch.basic_get("pub.#{style}", :manual_ack => true)

  content_type :json
  msg
end
