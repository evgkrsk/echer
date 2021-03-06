#!/usr/bin/env crystal
require "http/server"

server = HTTP::Server.new do |context|
  context.response.content_type = "text/plain"
  context.response.print "#{context.request.method} #{context.request.path} #{context.request.version}\n"
  context.request.headers.each do |header|
    context.response.print "#{header[0]}: #{header[1].join(", ")}\n"
  end
end

address = server.bind_tcp "0.0.0.0", 8080
puts "Listening on http://#{address}"
server.listen
