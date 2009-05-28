#!/usr/bin/env ruby

unless ARGV.length > 0
	puts '<openbox_pipe_menu>'
	puts '<item label="No wallpaper directories set" />'
	puts '</openbox_pipe_menu>'
	exit
end

puts '<openbox_pipe_menu>'

if File.file?(File.join(ENV['HOME'], '.fehbg'))
	$currentbg = File.read(File.join(ENV['HOME'], '.fehbg')).split(' ').detect{|x| File.file? x}
end

$wallpapers = []

ARGV.each do |dir|
	next unless File.directory? dir
	$wallpapers.concat Dir.entries(dir).map{|x| File.join(dir, x)}.select{|x| File.file? x}
end

if $wallpapers.length < 1
	puts '<item label="No valid wallpapers found"/>'
else
	random = $wallpapers[rand($wallpapers.length)]
	puts "<item label='Random'><action name='Execute'><execute>feh --bg-scale #{random}</execute></action></item>"
	$wallpapers.sort.each do |file|
		puts "<item label='#{File.basename(file, '.*')}#{$currentbg == file ?' *':''}' ><action name='Execute'><execute>feh --bg-scale #{file}</execute></action></item>"
	end
end

puts '</openbox_pipe_menu>'
