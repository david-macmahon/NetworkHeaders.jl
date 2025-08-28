# IPv4Header and UDP Header are well aligned so we can make a compound struct
# this is still wire-compatible.
struct IPv4UDPHeader{N} <: AbstractCompoundHeader
    ipv4::IPv4Header{N}
    udp::UDPHeader
end

# No-arg constructors
IPv4UDPHeader{N}() where N = IPv4UDPHeader(IPv4Header{N}(), UDPHeader())
IPv4UDPHeader()  = IPv4UDPHeader{5}()

# zeros for parameterized types without type parameters uses default type
# parameter value
Base.zeros(::Type{IPv4UDPHeader}, dims::Base.DimOrInd...) = zeros(IPv4UDPHeader{5}, dims)
