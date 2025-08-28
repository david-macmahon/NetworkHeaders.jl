# IPv4Header and ICMP Header are well aligned so we can make a compound struct
# this is still wire-compatible.
struct IPv4ICMPHeader{N} <: AbstractCompoundHeader
    ipv4::IPv4Header{N}
    icmp::ICMPHeader
end

# No-arg constructors
IPv4ICMPHeader{N}() where N = IPv4ICMPHeader(IPv4Header{N}(), ICMPHeader())
IPv4ICMPHeader()  = IPv4ICMPHeader{5}()

# zeros for parameterized types without type parameters uses default type
# parameter value
Base.zeros(::Type{IPv4ICMPHeader}, dims::Base.DimOrInd...) = zeros(IPv4ICMPHeader{5}, dims)
