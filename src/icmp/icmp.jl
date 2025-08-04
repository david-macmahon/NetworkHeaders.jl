include("enums.jl")

struct ICMPHeader <: AbstractNetworkHeader
    type::UInt8
    code::UInt8
    checksum::UInt16
    data::UInt32

    function ICMPHeader(type, code, checksum, data)
        new(
            type % UInt8, code % UInt8, hton(checksum % UInt16),
            hton(data % UInt32)
        )
    end
end

# TODO Make req/rep headers not have a code.  Move code to kwargs for other types.

"""
    ICMPHeader(type=ICMP_ECHO, checksum=nothing; kwargs...)

Construct an `ICMPHeader` of the given the given `type`.

`type` is the ICMP type field of the header.  It may be an `ICMPType` value or
any `Integer` value (only the low 8 bits are used).  If the `checksum` argument
is `nothing` (the default), the checksum field will be computed as the Internet
checksum of the ICMP header (and other data whose Internet checksum is given in
`initcsum`); otherwise the given `checksum` value will be used.  The remaining
contents of the `ICMPHeader` are determined from type-specific keyword arguments
shown in the table below.  Unspecified keyword arguments default to 0, except
for `initcsum` which defaults to `-1`.

| `type`                | Keyword arguments           |
|-----------------------|-----------------------------|
| `ICMP_ECHO` (default) | initcsum, id, sequence      |
| `ICMP_ECHOREPLY`      | initcsum, id, sequence      |
| `ICMP_TIMESTAMP`      | initcsum, id, sequence      |
| `ICMP_TIMESTAMPREPLY` | initcsum, id, sequence      |
| `ICMP_INFO_REQUEST`   | initcsum, id, sequence      |
| `ICMP_INFO_REPLY`     | initcsum, id, sequence      |
| `ICMP_ADDRESS`        | initcsum, id, sequence      |
| `ICMP_ADDRESSREPLY`   | initcsum, id, sequence      |
| `ICMP_DEST_UNREACH`   | initcsum, code, length, mtu |
| `ICMP_REDIRECT`       | initcsum, code, gateway     |
| `ICMP_PARAMETERPROB`  | initcsum, code, pointer     |
| `ICMP_TIME_EXCEEDED`  | initcsum, code              |
| `ICMP_SOURCE_QUENCH`  | initcsum                    |
| other Integer value   | initcsum, code, data        |

When `type` is an `Integer` whose value is equivalent to one of the `ICMPType`
enum values, it will use the corresponding keyword arguments; otherwise it will
be treated as a non-standard ICMP type and the `code` and `data` keyword
arguments will define the rest of the header contents.
"""
function ICMPHeader(type::ICMPType=ICMP_ECHO, checksum=nothing;
    initcsum=-1, id=0, sequence=0, code=0, length=0, mtu=0, gateway=0, pointer=0
)
    if type in (
        ICMP_ECHO,
        ICMP_ECHOREPLY,
        ICMP_TIMESTAMP,
        ICMP_TIMESTAMPREPLY,
        ICMP_INFO_REQUEST,
        ICMP_INFO_REPLY,
        ICMP_ADDRESS,
        ICMP_ADDRESSREPLY
    )
        code8 = UInt8(0)
        data32 = ((id % UInt32) << 16) | (sequence % UInt16)
    elseif type === ICMP_DEST_UNREACH
        code8 = Integer(code) % UInt8
        data32 = (((length & 0xff) % UInt32) << 16) | (mtu % UInt16)
    elseif type === ICMP_REDIRECT
        code8 = Integer(code) % UInt8
        data32 = UInt32(gateway)
    elseif type === ICMP_PARAMETERPROB
        code8 = Integer(code) % UInt8
        data32 = (((pointer & 0xff) % UInt32) << 24)
    elseif type === ICMP_TIME_EXCEEDED
        code8 = Integer(code) % UInt8
        data32 = UInt32(0)
    else
        code8 = UInt8(0)
        data32 = UInt32(0)
    end

    if checksum === nothing
        csum = (Int(type) << 8) + (code8) + (data32 >> 16) + (data32 & 0xffff)
        # Sum in the inverted init value
        csum += ~initcsum
        # Fold in the carries
        csum = (csum & 0xffff) + (csum>>16)
        csum16 = ~csum % UInt16
    else
        csum16 = checksum % UInt16
    end

    ICMPHeader(Integer(type), code8, csum16, data32)
end

function ICMPHeader(type::Integer, checksum=nothing; data=0, code=0, initcsum=-1, kwargs...)
    type8 = type % UInt8

    if type8 in Integer.(instances(ICMPType))
        ICMPHeader(ICMPType(type8), checksum; code, initcsum, kwargs...)
    else
        code8 = Integer(code) % UInt8
        data32 = data % UInt32

        if checksum === nothing
            csum = (Int(type8) << 8) + code8 + sum(reinterpret(NTuple{2,UInt16}, data32))
            # Sum in the inverted init value
            csum += ~initcsum
            # Fold in the carries
            csum = (csum & 0xffff) + (csum>>16)
            csum16 = ~csum % UInt16
        else
            csum16 = checksum % UInt16
        end

        ICMPHeader(type8, code8, csum16, data32)
    end
end

function Base.propertynames(x::ICMPHeader, ::Bool=false)
    type = getfield(x, :type)
    (:type, :code, :checksum, :bytes,
        if type in Integer.((
            ICMP_ECHOREPLY,
            ICMP_ECHO,
            ICMP_TIMESTAMP,
            ICMP_TIMESTAMPREPLY,
            ICMP_INFO_REQUEST,
            ICMP_INFO_REPLY,
            ICMP_ADDRESS,
            ICMP_ADDRESSREPLY
        ))
            (:id, :sequence)
        elseif type === Integer(ICMP_DEST_UNREACH)
            (:length, :mtu)
        elseif type === Integer(ICMP_REDIRECT)
            (:gateway,)
        elseif type === Integer(ICMP_PARAMETERPROB)
            (:pointer,)
        elseif type === Integer(ICMP_SOURCE_QUENCH)
            ()
        elseif type === Integer(ICMP_SOURCE_QUENCH)
            ()
        else
            (:data,)
        end...
    )
end

function Base.getproperty(x::ICMPHeader, f::Symbol)
    # TODO Validate `f` against `x.type`?
    # getproperty converts them to host byte order 
    f === :id && return (ntoh(getfield(x, :data)) >> 16) % UInt16
    f === :sequence && return ntoh(getfield(x, :data)) % UInt16
    f === :gateway && return IPv4(ntoh(getfield(x, :data)))
    f === :length && return (getfield(x, :data) >> 16) % UInt8
    f === :mtu && return ntoh(getfield(x, :data)) % UInt16
    f === :pointer && return (ntoh(getfield(x, :data)) >> 24) % UInt8
    f === :data && return ntoh(getfield(x, :data))
    f === :bytes && return reinterpret(NTuple{sizeof(ICMPHeader), UInt8}, x)
    return ntoh(getfield(x, f))
end

function Base.show(io::IO, x::ICMPHeader)
    print(io, "ICMPHeader(")
    if x.type in Integer.(instances(ICMPType))
        print(io, ICMPType(x.type))
    else
        print(io, repr(x.type), ", ", repr(x.code))
    end
    # Checksum
    print(io, ", ", repr(x.checksum))
    # Code
    if x.type === Integer(ICMP_DEST_UNREACH)
        print(io, ", code=")
        if x.code in Integer.(instances(ICMPDestUnreachCode))
            print(io, ICMPDestUnreachCode(x.code))
        else
            print(io, repr(x.code))
        end
    elseif x.type === Integer(ICMP_REDIRECT)
        print(io, ", code=")
        if x.code in Integer.(instances(ICMPRedirectCode))
            print(io, ICMPRedirectCode(x.code))
        else
            print(io, repr(x.code))
        end
    elseif x.type === Integer(ICMP_PARAMETERPROB)
        print(io, ", code=")
        if x.code in Integer.(instances(ICMPParameterprobCode))
            print(io, ICMPParameterprobCode(x.code))
        else
            print(io, repr(x.code))
        end
    elseif x.type === Integer(ICMP_TIME_EXCEEDED)
        print(io, ", code=")
        if x.code in Integer.(instances(ICMPTimeExceededCode))
            print(io, ICMPTimeExceededCode(x.code))
        else
            print(io, repr(x.code))
        end
    end

    if x.type in Integer.((
        ICMP_ECHOREPLY,
        ICMP_ECHO,
        ICMP_TIMESTAMP,
        ICMP_TIMESTAMPREPLY,
        ICMP_INFO_REQUEST,
        ICMP_INFO_REPLY,
        ICMP_ADDRESS,
        ICMP_ADDRESSREPLY
    ))
        print(io, ", id=")
        print(io, repr(x.id))
        print(io, ", sequence=")
        print(io, repr(x.sequence))
    elseif x.type === Integer(ICMP_DEST_UNREACH)
        print(io, ", length=")
        print(io, repr(x.length))
        print(io, ", mtu=")
        print(io, repr(x.mtu))
    elseif x.type === Integer(ICMP_REDIRECT)
        print(io, ", gateway=")
        print(io, repr(x.gateway))
    elseif x.type === Integer(ICMP_PARAMETERPROB)
        print(io, ", pointer=")
        print(io, repr(x.pointer))
    elseif ! (x.type in Integer.(instances(ICMPType)))
        print(io, ", ", repr(x.data))
    end
    print(io, ")")
end
