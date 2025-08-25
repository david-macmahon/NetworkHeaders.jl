# AbstractCompoundHeader base type for compound header types
abstract type AbstractCompoundHeader end

# IPv4Header and ICMP Header are well aligned so we can make a compound struct
# this is still wire-compatible.
struct IPv4ICMPHeader <: AbstractCompoundHeader
    ipv4::IPv4Header
    icmp::ICMPHeader
end

# IPv4Header and UDP Header are well aligned so we can make a compound struct
# this is still wire-compatible.
struct IPv4UDPHeader <: AbstractCompoundHeader
    ipv4::IPv4Header
    udp::UDPHeader
end

function Base.show(io::IO, x::T) where T<:AbstractCompoundHeader
    show(io, Tuple(getfield.(Ref(x), 1:fieldcount(T))))
end
