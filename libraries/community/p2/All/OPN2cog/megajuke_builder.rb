# encoding: utf-8
# frozen_string_literal: true

require 'yaml'
require 'zlib'

DIRECTORY = "tunes/"

tracklist = YAML.load(File.read("megajuke_tracks.yml"),symbolize_names:true)

# p tracklist

raise unless tracklist.is_a? Array
raise if tracklist.size > 126

databuffer = String.new # should be ASCII_8BIT

File.open "MEGAJUKE.DAT",'wb' do |f|
    f.write "MEGAJUKE" # Write magic
    tracklist.each_with_index do |track,i|

        offset = databuffer.size
        # Make text first
        databuffer << <<~TEXT
            ----
            Now playing track #{i+1} of #{tracklist.size}!
            #{track[:title]}
            from #{track[:game]}
            by #{track[:composer]}
            #{track[:note]}
        TEXT
        databuffer << ?\0

        # Now put the data
        filedata = File.binread(DIRECTORY+track[:file])

        filedata = Zlib.gunzip filedata if filedata[0..1] == "\x1f\x8b".b # Handle VGZ

        databuffer << filedata
        databuffer << ?\x66 * 8 # Make super sure there actually is a stop command

        # Write offset
        f.write [offset + tracklist.size*4 + 12].pack("L<")

    end
    f.write ?\0*4 # End offset list
    f.write databuffer
end

puts "Built MEGAJUKE.DAT with #{tracklist.size} tracks!"
