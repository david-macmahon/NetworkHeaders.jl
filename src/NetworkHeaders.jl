module NetworkHeaders

using Sockets

# Header exports
export AbstractNetworkHeader, AbstractEthernetHeader, AbstractCompoundHeader
export EthernetHeader, EthernetVlanHeader, IPv4Header, ICMPHeader, UDPHeader,
       IPv4ICMPHeader, IPv4UDPHeader

# Export renamed constants modules
export EthernetConstants, IPv4Constants, ICMPConstants

# checksum exports
export internet_checksum

# Ethernet exports
export mac2string, string2mac, @mac_str

export read_headers

# All AbstractNetworkHeader types must have a no-arg constructor
abstract type AbstractNetworkHeader end

# Base.zero() method for AbstractNetworkHeader types just calls no-arg constructor
Base.zero(::Type{T}) where {T<:AbstractNetworkHeader} = T()

# Misc utilities
include("checksum.jl")
include("hexdump.jl")

# Header specific definitions
include("ethernet/ethernet.jl")
using .Ethernet
const EthernetConstants = Ethernet.Constants

include("ipv4/ipv4.jl")
using .IPv4
const IPv4Constants = IPv4.Constants

include("icmp/icmp.jl")
using .ICMP
const ICMPConstants = ICMP.Constants

include("udp/udp.jl")
using .UDP

include("compound.jl")

function Base.write(io::IO, h::AbstractNetworkHeader)
    write(io, h.bytes...)
end

function Base.read(io::IO, ::Type{T}) where T <: AbstractNetworkHeader
    r = Ref{T}()
    read!(io, r)
    r[]
end

function read_headers(io::IO)
    ethernet = read(io, AbstractEthernetHeader)
    if ethernet.ethtype != Integer(Ethernet.Constants.ETH_P_IP)
        return (; ethernet,)
    end
    ipv4 = read(io, IPv4Header)
    if ipv4.protocol == Integer(IPv4.Constants.IPPROTO_ICMP)
        icmp = read(io, ICMPHeader)
        return (; ethernet, ipv4, icmp)
    elseif ipv4.protocol == Integer(IPv4.Constants.IPPROTO_UDP)
        udp = read(io, UDPHeader)
        return (; ethernet, ipv4, udp)
    end

    (; ethernet, ipv4)
end

end  # module NetworkHeaders
