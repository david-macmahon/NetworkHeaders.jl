"""
    internet_checksum(bytes[; init, nprev])
    internet_checksum(bytes, start[; init, nprev])
    internet_checksum(bytes, start, stop[; init, nprev])

Return the 16-bit Internet checksum in host byte order.

The checksum is computed for `bytes` between indices `start` and `stop`,
inclusive, which default to the first and last index of `bytes`.  `bytes` may be
an `AbstractVector{UInt8}` or an `NTuple{N,UInt8}`.

Checksums may be computed over different parts of the overall data by passing
the checksum of previous parts in the `initcsum` keyword argument.  If the total
number of bytes in the previous parts is odd, the `nprev` keyword must be passed
as an odd number (or `true`) to indicate that the first byte in `bytes` should
be considered the least significant byte of the trailing incomplete 16-bit
integer of the previous parts.
"""
function internet_checksum(bytes, start=firstindex(bytes), stop=lastindex(bytes); initcsum=-1, nprev=0)
    csum = 0
    mstart = start + isodd(nprev)
    lstart = start + iseven(nprev)
    # Sum the MSBs
    for i = mstart:2:stop
        csum += bytes[i]
    end
    csum <<= 8
    # Sum the LSBs
    for i = lstart:2:stop
        csum += bytes[i]
    end
    # Sum in the inverted initcsum value
    csum += ~initcsum
    # Fold in the carries
    csum = (csum & 0xffff) + (csum>>16)
    csum = (csum & 0xffff) + (csum>>16)
    # Invert and convert to UInt16
    UInt16((~csum) & 0xffff)
end

function internet_checksum(hdr::AbstractNetworkHeader; initcsum=-1, nprev=0)
    internet_checksum(hdr.bytes; initcsum, nprev)
end
