#!/usr/bin/env crystal
require "http/server"

whitelist = %w(host user-agent accept connection)

server = HTTP::Server.new do |context|
  context.response.content_type = "text/plain"
  context.response.print "#{context.request.method} #{context.request.path} #{context.request.version}\n"
  context.request.headers.each do |header|
    if header[0].downcase.in?(whitelist)
      context.response.print "#{header[0]}: #{header[1].join(", ")}\n"
    end
  end
end

address = server.bind_tcp "0.0.0.0", 8080
puts "Listening on http://#{address}"
server.listen
