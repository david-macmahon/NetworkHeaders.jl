module IPv4

export IPv4Header, Constants

using Sockets
using ..NetworkHeaders

include("enums.jl")
using .Constants

struct IPv4Header{N} <: AbstractNetworkHeader
    data::NTuple{N, UInt32}

    function IPv4Header{N}(data::NTuple{N, UInt32}) where N
        N <  5 && error("IPv4Header cannot have fewer than 20 bytes")
        N > 15 && error("IPv4Header cannot have more than 60 bytes")
        new{N}(data)
    end

    IPv4Header(data::NTuple{N, UInt32}) where N = IPv4Header{N}(data)
end

function IPv4Header(data::NTuple{N, T}) where {N, T<:Integer}
    data32 = reinterpret(NTuple{N*sizeof(T)÷sizeof(UInt32), UInt32}, data)
    IPv4Header(data32)
end

function IPv4Header(;
    #version=4,
    #ihl
    dscp=0,
    ecn=0,
    id=0,
    flags=0,
    offset=0,
    ttl=64,
    protocol=17, # UDP
    checksum=nothing, # nothing means calculate, otherwise use given value
    sip=0,
    dip=0,
    options=(),
    length=20+4*sizeof(options)÷sizeof(UInt32)
)
    # These two fields cannot be overridden
    version = 4
    ihl = 5 + sizeof(options)÷sizeof(UInt32)

    # Build up words in host byte order

    word1 = UInt32(
        (UInt32(version &   0x0f) << 28) |
        (UInt32(ihl     &   0x0f) << 24) |
        (UInt32(dscp    &   0x3f) << 18) |
        (UInt32(ecn     &   0x03) << 16) |
        (UInt32(length) & 0xffff       )
    )

    word2 = UInt32(
        (UInt32(id     & 0xffff) << 16) |
        (UInt32(flags  &   0x07) << 13) |
        (UInt32(offset & 0x1fff)      )
    )

    word3 = UInt32(
        (UInt32(ttl              &   0xff) << 24) |
        (UInt32(Integer(protocol) &   0xff) << 16) 
    )

    if checksum === nothing
        # Calculate checksum
        halfwords = reinterpret(NTuple{2ihl, UInt16},
            UInt32.((word1, word2, word3, sip, dip, options...))
        )
        #@show halfwords
        cksum = sum(halfwords)
        cksum = (cksum >> 16) + (cksum & 0xffff)
        cksum = (cksum >> 16) + (cksum & 0xffff)
        word3 |= UInt32((~cksum) & 0xffff)
    else
        # Use value given
        word3 |= UInt32((checksum) & 0xffff)
    end

    sip32 = UInt32(sip)
    dip32 = UInt32(dip)
    opt32 = UInt32.(options)
    IPv4Header(hton.((word1, word2, word3, sip32, dip32, opt32...)))
end

function Base.getindex(ip::IPv4Header, i)
    ntoh.(ip.data[i])
end

function Base.propertynames(::IPv4Header, private::Bool=false)
    (:version, :ihl, :dscp, :ecn, :length, :id, :flags, :offset,
        :ttl, :protocol, :checksum, :sip, :dip, :options, :bytes,
            if private
                (:data,)
            else
                ()
            end...
    )
end

function Base.getproperty(x::IPv4Header{N}, f::Symbol) where N
    # words are in network byte order, getindex returns them in host byte order
    # multi-byte values returned in host byte order
    # Word 1 fields
    f === :version && return UInt8((x[1]>>28) & 0x0f)
    f === :ihl && return UInt8((x[1]>>24) & 0x0f)
    f === :dscp && return UInt8((x[1]>>18) & 0c3f)
    f === :ecn && return UInt8((x[1]>>16) & 0x03)
    f === :length && return UInt16(x[1] & 0xffff)
    # Word 2 fields
    f === :id && return  UInt16((x[2]>>16) & 0xffff)
    f === :flags && return UInt8((x[2]>>13) & 0x07)
    f === :offset && return UInt16(x[2] & 0x1fff)
    # Word 3 fields
    f === :ttl && return UInt8((x[3]>>24) & 0xff)
    f === :protocol && return UInt8((x[3]>>16) & 0xff)
    f === :checksum && return UInt16(x[3] & 0xffff)
    # Other fields
    f === :sip && return Sockets.IPv4(x[4])
    f === :dip && return Sockets.IPv4(x[5])
    # TODO options!
    # generic
    f === :bytes && return reinterpret(NTuple{4N, UInt8}, x)
    return getfield(x, f)
end

# Special read! for IPv4 that checks ihl field to size header appropraiately
function Base.read(io::IO, ::Type{IPv4Header})
    ihl = Int(peek(io, UInt8) & 0x0f)
    r = Ref{NTuple{ihl, UInt32}}()
    read!(io, r)
    reinterpret(IPv4Header{ihl}, r[])
end

function Base.show(io::IO, x::IPv4Header)
    print(io, "IPv4Header(sip=", string(x.sip),
        ", dip=", string(x.dip),
        ", length=", repr(x.length),
        ", proto="
    )
    if x.protocol in Integer.(instances(IPProtocol))
        print(io, IPProtocol(x.protocol))
    else
        print(io, repr(x.protocol))
    end
    print(io, ")")
end

end # module IPv4
