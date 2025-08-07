module StructArraysNetworkHeadersExt

import StructArrays: staticschema, component, createinstance
using NetworkHeaders: AbstractNetworkHeader, IPv4Header
using Sockets: IPv4

component(h::T, key::Symbol) where {T<:AbstractNetworkHeader} = getproperty(h, key)
createinstance(::Type{T}, args...) where {T<:AbstractNetworkHeader} = T(args...)

# Need staticschema for IPv4Header
function staticschema(::Type{IPv4Header{N}}) where N
    NamedTuple{propertynames(IPv4Header())[1:end-1], Tuple{
        UInt8, UInt8, UInt8, UInt8, UInt16, UInt16, UInt8, UInt16, UInt8,
        UInt8, UInt16, IPv4, IPv4, NTuple{N-5,UInt32}
    }}
end

# Need createinstance for IPv4Header{N}
function createinstance(::Type{IPv4Header{N}},
    _version, _ihl, dscp, ecn, length, id, flags, offset,
    ttl, protocol, checksum, sip, dip, options
) where N
    IPv4Header(;
        dscp, ecn, length, id, flags, offset,
        ttl, protocol, checksum, sip, dip, options
    )
end

end # module StructArraysNetworkHeadersExt
