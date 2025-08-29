module UDPHeaders

export UDPHeader

using ..NetworkHeaders

struct UDPHeader <: AbstractNetworkHeader
    sport::UInt16
    dport::UInt16
    length::UInt16
    checksum::UInt16

    function UDPHeader(sport, dport, length=8, checksum=0)
        new(
            hton(sport % UInt16), hton(dport % UInt16),
            hton(length % UInt16), hton(checksum % UInt16)
        )
    end
end

function UDPHeader(; sport=0, dport=0, length=8, checksum=0)
    UDPHeader(sport, dport, length, checksum)
end

function Base.propertynames(::UDPHeader, ::Bool=false)
    (:sport, :dport, :length, :checksum, :bytes)
end

function Base.getproperty(x::UDPHeader, f::Symbol)
    # Integer fields are in network byte order
    # getproperty converts them to host byte order 
    f === :bytes && return reinterpret(NTuple{sizeof(UDPHeader), UInt8}, x)
    return ntoh(getfield(x, f))
end

function Base.show(io::IO, x::UDPHeader)
    print(io, "UDPHeader(sport=", x.sport,
        ", dport=", x.dport,
        ", length=", x.length,
        ")"
    )
end

end # module UDPHeaders
