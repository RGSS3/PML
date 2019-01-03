require 'zlib'
x = IO.binread(ARGV[0])
x = if x.unpack("CCC") == [0xef, 0xbb, 0xbf]
        x.unpack("C*")[3..-1].pack("C*")
    else
        x
    end
script = 
[[0, "", Zlib::Deflate.deflate(x, 9)]]
open(ARGV[1], "wb") do |f| Marshal.dump script, f end