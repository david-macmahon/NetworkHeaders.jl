"""
    mac2string(m::NTuple{6, UInt8})::String
    mac2string(m::AbstractString)::String

Return the string representation of MAC address `m`.

The method taking an `AbstractString` will canonicalize the MAC address string
by first converting `m` to an `NTuple` and then back to a String.
"""
mac2string(m::NTuple{6, UInt8})::String = join(bytes2hex.(m), ':')
mac2string(m::AbstractString)::String = mac2string(mac2mac(m))

"""
    mac2mac(m::AbstractString)::NTuple{6, UInt8}
    mac2mac(m::NTuple{6, UInt8})::NTuple{6, UInt8}

Return an `NTuple{6, UInt8}` for the MAC address given by 'm'.
"""
mac2mac(m::AbstractString)::NTuple{6, UInt8} = Tuple(hex2bytes(join(split(m, r"[-:.]"))))
mac2mac(m::NTuple{6, UInt8})::NTuple{6, UInt8} = m

# Deprecate string2mac
@deprecate string2mac(m::AbstractString) mac2mac(m)

"""
    @mac_str(s) -> NTuple{6, UInt8}

Create an `NTuple{6, UInt8}` corresponding to the given String literal.

    mac"11:22:33:44:55:66" -> (0x11, 0x22, 0x33, 0x44, 0x55, 0x66)
"""
macro mac_str(s)
    string2mac(s)
end
