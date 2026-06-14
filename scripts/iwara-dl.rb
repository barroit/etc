#!/usr/bin/ruby
# SPDX-License-Identifier: GPL-3.0-or-later

require 'uri'

def parse_name(str)
	url = URI(str)
	param_map = URI.decode_www_form(url.query).to_h
	time = Time.now.strftime('%y-%m-%d ')
	name = param_map['download'].sub(/( \[[^\]]+\])+(?=.mp4$)/, '')
				    .gsub('/', '／')

	time + name
end

def download(name, str)
	success = system('aria2c', '--split=16',
			 '--max-connection-per-server=16', '--timeout=10',
			 "--out=#{name}", str, out: File::NULL, err: File::NULL)

	if !success
		$stderr.puts "error: #{name}"
		File.write('.err', "#{name}\n#{str}\n\n", mode: 'a')
	end
end

queue = Queue.new

workers = Array.new(4) do
	Thread.new do
		loop do
			task = queue.pop

			if task.nil?
				break
			end

			download(task[0], task[1])
		end
	end
end

$stdin.each_line do |line|
	str = line.strip
	name = parse_name(str)

	puts name
	queue.push([ name, str ])
end

queue.close

workers.each(&:join)
