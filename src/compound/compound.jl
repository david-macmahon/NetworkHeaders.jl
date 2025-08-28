module CompoundHeaders

export AbstractCompoundHeader, IPv4ICMPHeader, IPv4UDPHeader

using ..NetworkHeaders

# AbstractCompoundHeader base type for compound header types
abstract type AbstractCompoundHeader end

include("ipv4icmp.jl")
include("ipv4udp.jl")

function Base.propertynames(::T) where T<:AbstractCompoundHeader
    (fieldnames(T)..., :bytes)
end

function Base.getproperty(h::AbstractCompoundHeader, f::Symbol)
    if f === :bytes
        mapreduce(
            i->getproperty(getfield(h,i), :bytes),
            (a,b)->(a..., b...),
            1:fieldcount(typeof(h))
        )
    else
        getfield(h, f)
    end
end

function Base.write(io::IO, h::AbstractCompoundHeader)
    write(io, h.bytes...)
end

function Base.read(io::IO, ::Type{T}) where T <: AbstractCompoundHeader
    T(
        (read(io, fieldtype(T, i)) for i=1:fieldcount(T))...
    )
end

# Base.zero() method for AbstractCompoundHeader types just calls no-arg
# constructor
Base.zero(::Type{T}) where {T<:AbstractCompoundHeader} = T()

function Base.show(io::IO, x::T) where T<:AbstractCompoundHeader
    show(io, Tuple(getfield.(Ref(x), 1:fieldcount(T))))
end

end # module CompoundHeaders
