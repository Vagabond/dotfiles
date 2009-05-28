#! /usr/bin/env ruby

begin
	load File.join(File.dirname(__FILE__), '..', 'x2any.conf')
rescue LoadError
	puts '<openbox_pipe_menu>'
	puts '<item label="Not configured" />'
	puts '</openbox_pipe_menu>'
	exit
rescue SyntaxError
	puts '<openbox_pipe_menu>'
	puts '<item label="Configuration Error" />'
	puts '</openbox_pipe_menu>'
	exit
end

puts '<openbox_pipe_menu>'

running = {}
ids = []
{:x2x=>$x2x, :x2vnc=>$x2vnc}.each do |type, hosts|
	hosts.each do |host|
		pid = `pgrep -f '^#{type}.*#{host[:host]}'`.strip
		unless pid.empty?
			
			# test the PID is valid
			begin
				Process.kill(0, pid.to_i)
			rescue Errno::ESRCH # invalid PID
				next
			else
				running[host[:host]] = {:type=>type, :pid=>pid}
				ids << host[:id] if host[:id]
			end
		end
	end

end
#Dir.chdir path
#Dir["pids/*"].each do |pidfile|
	#File.open(pidfile) do |f|
		#pid = f.read
		#begin
			#Process.kill(0, pid.to_i)
		#rescue Errno::ESRCH # invalid PID
			#File.delete(pidfile)
		#else
			#type, host = pidfile.split('-', 2)
			#type = type.split('/')[-1]
			#running[host] = type
		#end
	#end
#end

validx2x = $x2x.select{|x| !(running[x[:host]] or (x[:id] and ids.include? x[:id])) }
if validx2x.length > 0
	puts '<menu id="x2x" label="x2x">'
	validx2x.each do |mach|
		host = mach[:host]
		puts "<item label=\"#{host}\"><action name=\"Execute\"><execute>x2x -#{mach[:side]} -to #{host}:0</execute></action></item>"
	end
	puts '</menu>'
end

validx2vnc = $x2vnc.select{|x| !(running[x[:host]] or (x[:id] and ids.include? x[:id])) }
if validx2vnc.length > 0
	puts '<menu id="x2vnc" label="x2vnc">'
	validx2vnc.each do |mach|
		host = mach[:host]
		puts "<item label=\"#{host}\"><action name=\"Execute\"><execute>x2vnc -#{mach[:side]} #{host}:0</execute></action></item>"
	end
	puts '</menu>'
end

unless running.empty?
	puts '<menu id="Running" label="Running">'
	running.each do |k, v|
		puts "<item label=\"Kill #{v[:type]} #{k}\"><action name=\"Execute\"><execute>kill #{v[:pid]}</execute></action></item>"
	end
	puts '</menu>'
end

puts '</openbox_pipe_menu>'
