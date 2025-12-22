#!/usr/bin/ruby
# SPDX-License-Identifier: GPL-3.0-or-later

require 'uri'

if ARGV.empty?
   abort 'usage: iwara-dl.rb <url>'
end

url_str = ARGV[0]
url = URI(url_str)

query = url.query
params = URI.decode_www_form(query)
param_map = params.to_h

now = Time.now
time = now.strftime('%y-%m-%d ')

name = param_map['download']
name = name.sub(/( \[[^\]]+\])+(?=.mp4$)/, '')
name = name.gsub('/', '／')
name = time + name

system('aria2c', '--split=16',
       '--max-connection-per-server=16', "--out=#{name}", url_str)
