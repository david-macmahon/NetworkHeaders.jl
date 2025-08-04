module NetworkHeaders

using Sockets

# Header exports
export AbstractNetworkHeader, AbstractEthernetHeader
export EthernetHeader, EthernetVlanHeader, IPv4Header, ICMPHeader, UDPHeader

# checksum exports
export internet_checksum

# Ethernet exports
export mac2string, string2mac, @mac_str

# ICMP exports
export ICMPType, ICMP_ECHOREPLY, ICMP_DEST_UNREACH, ICMP_SOURCE_QUENCH,
    ICMP_REDIRECT, ICMP_ECHO, ICMP_TIME_EXCEEDED, ICMP_PARAMETERPROB,
    ICMP_TIMESTAMP, ICMP_TIMESTAMPREPLY, ICMP_INFO_REQUEST, ICMP_INFO_REPLY,
    ICMP_ADDRESS, ICMP_ADDRESSREPLY
export ICMPDestUnreachCode, ICMP_NET_UNREACH, ICMP_HOST_UNREACH,
    ICMP_PROT_UNREACH, ICMP_PORT_UNREACH, ICMP_FRAG_NEEDED, ICMP_SR_FAILED,
    ICMP_NET_UNKNOWN, ICMP_HOST_UNKNOWN, ICMP_HOST_ISOLATED, ICMP_NET_ANO,
    ICMP_HOST_ANO, ICMP_NET_UNR_TOS, ICMP_HOST_UNR_TOS, ICMP_PKT_FILTERED,
    ICMP_PREC_VIOLATION, ICMP_PREC_CUTOFF
export ICMPRedirectCode, ICMP_REDIR_NET, ICMP_REDIR_HOST, ICMP_REDIR_NETTOS,
    ICMP_REDIR_HOSTTOS
export ICMPParameterprobCode, ICMP_SEE_POINTER, ICMP_MISSING_OPTION,
    ICMP_BADE_LENGTH
export ICMPTimeExceededCode, ICMP_EXC_TTL, ICMP_EXC_FRAGTIME

export read_headers

abstract type AbstractNetworkHeader end

# Misc utilities
include("checksum.jl")
include("hexdump.jl")

# Header specific definitions
include("ethernet.jl")
include("ipv4.jl")
include("icmp.jl")
include("udp.jl")

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
    if ethernet.ethtype != Integer(ETH_P_IP)
        return (; ethernet,)
    end
    ipv4 = read(io, IPv4Header)
    if ipv4.protocol == Integer(IPPROTO_ICMP)
        icmp = read(io, ICMPHeader)
        return (; ethernet, ipv4, icmp)
    elseif ipv4.protocol == Integer(IPPROTO_UDP)
        udp = read(io, UDPHeader)
        return (; ethernet, ipv4, udp)
    end

    (; ethernet, ipv4)
end

end  # module NetworkHeaders
