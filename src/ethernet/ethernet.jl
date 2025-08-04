module Ethernet

export AbstractEthernetHeader, EthernetHeader, EthernetVlanHeader, Constants
export mac2string, string2mac, @mac_str

using ..NetworkHeaders

include("helpers.jl")
include("enums.jl")
using .Constants

abstract type AbstractEthernetHeader <: AbstractNetworkHeader end

struct EthernetHeader <: AbstractEthernetHeader
    dmac::NTuple{6, UInt8}
    smac::NTuple{6, UInt8}
    ethtype::UInt16

    function EthernetHeader(dmac, smac, ethtype=0x0800)
        new(dmac, smac, hton(Integer(ethtype) % UInt16))
    end
end

function EthernetHeader(;
    dmac=(0xff, 0xff, 0xff, 0xff, 0xff, 0xff),
    smac=(0xff, 0xff, 0xff, 0xff, 0xff, 0xff),
    ethtype=0x0800
)
    EthernetHeader(dmac, smac, ethtype)
end

function Base.propertynames(::EthernetHeader, ::Bool=false)
    (:dmac, :smac, :ethtype, :bytes)
end

function Base.getproperty(x::EthernetHeader, f::Symbol)
    # Integer fields are in network byte order
    # getproperty converts them to host byte order 
    f === :ethtype && return ntoh(getfield(x, f))
    f === :bytes && return reinterpret(NTuple{sizeof(EthernetHeader), UInt8}, x)
    return getfield(x, f)
end

struct EthernetVlanHeader <: AbstractEthernetHeader
    dmac::NTuple{6, UInt8}
    smac::NTuple{6, UInt8}
    tpid::UInt16 # Tag Protocol IDentifier (0x8100)
    vlan::UInt16 # VLAN tag
    ethtype::UInt16

    function EthernetVlanHeader(dmac, smac, vlan, ethtype=0x0800; tpid=0x8100)
        new(
            dmac,
            smac,
            hton(tpid % UInt16),
            hton(vlan % UInt16),
            hton(Integer(ethtype) % UInt16)
        )
    end
end

function EthernetVlanHeader(;
    dmac=(0xff, 0xff, 0xff, 0xff, 0xff, 0xff),
    smac=(0xff, 0xff, 0xff, 0xff, 0xff, 0xff),
    tpid=0x8100,
    vlan=1,
    ethtype=0x0800
)
    EthernetVlanHeader(dmac, smac, vlan, ethtype; tpid)
end

function Base.propertynames(::EthernetVlanHeader, ::Bool=false)
    (:dmac, :smac, :tpid, :vlan, :ethtype, :bytes)
end

function Base.getproperty(x::EthernetVlanHeader, f::Symbol)
    # Integer fields are in network byte order
    # getproperty converts them to host byte order 
    f === :tpid && return ntoh(getfield(x, f))
    f === :vlan && return ntoh(getfield(x, f))
    f === :ethtype && return ntoh(getfield(x, f))
    f === :bytes && return reinterpret(NTuple{sizeof(EthernetVlanHeader), UInt8}, x)
    return getfield(x, f) # for dmac and smac
end

# Special read for AbstractEthernetHeader that peeks at the ethtype field and
# reads EthernetVlanHeader if it is ETH_P_8021Q, otherwise reads EthernetHeader.
function Base.read(io::IO, ::Type{AbstractEthernetHeader})
    T =try
        ethtype = (ntoh(peek(io, UInt128)) >> 16) % UInt16
        ethtype == Integer(ETH_P_8021Q) ? EthernetVlanHeader : EthernetHeader
    catch ex
        ex isa EOFError || rethrow()
        # At EOF hope that we have enough bytes to read an EthernetHeader
        EthernetHeader
    end
    r = Ref{T}()
    read!(io, r)
    r[]
end

function Base.show(io::IO, x::AbstractEthernetHeader)
    compact = get(io, :compact, false)
    print(io, "$(typeof(x))(")
    compact || print(io, "dmac=")
    print(io, mac2string(x.dmac), ", ")
    compact || print(io, "smac=")
    print(io, mac2string(x.smac))
    if x isa EthernetVlanHeader
        if !compact && x.tpid != Integer(ETH_P_8021Q)
            print(io, ", ")
            if x.tpid in Integer.(instances(EtherType))
                print(io, EtherType(x.tpid))
            else
                print(io, repr(x.tpid))
            end
        end
        print(io, ", ", repr(x.vlan))
    end
    print(io, ", ")
    if x.ethtype in Integer.(instances(EtherType))
        print(io, EtherType(x.ethtype))
    else
        print(io, repr(x.ethtype))
    end
    print(io, ")")
end

end # module Ethernet
