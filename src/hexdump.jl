# Simple hexdump function to avoid dependency on BasedDumps.jl

"""
    hexdump([io,] bytes)
    hexdump([io,] hdr::AbstractNetworkHeader)

Dump `bytes` or `hdr.bytes` to `io` (or `stdout`) in hexdump format.
"""
function hexdump(io, bytes::Union{AbstractVector{UInt8}, NTuple{N,UInt8}}) where N
    foreach(enumerate(Iterators.partition(bytes, 16))) do (rownum, row)
        # Print address
        print(io, string(16*(rownum-1), base=16, pad=8))
        # Print bytes
        for (i, b) in enumerate(row)
            i == 9 && print(io, " ")
            print(io, " ")
            print(io, string(b, base=16, pad=2))
        end
        # Print space
        n = length(row)
        print(io, " " ^ (3*(16-n) + (n<9)))
        # Print text
        print(io, " |")
        for b in row
            c = Char(b)
            print(io, isprint(c) && isascii(c) ? c : ".")
        end
        println(io, "|")
    end
    println(io, string(length(bytes), base=16, pad=8))
end

hexdump(bytes::Union{AbstractVector{UInt8}, NTuple{N,UInt8}}) where N = hexdump(stdout, bytes)
hexdump(io, hdr::AbstractNetworkHeader) = hexdump(io, hdr.bytes)
hexdump(hdr::AbstractNetworkHeader) = hexdump(stdout, hdr)