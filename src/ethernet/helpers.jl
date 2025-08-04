"""
    mac2string(m::NTuple{6, UInt8})::String

Return a string representation of MAC `m`.
"""
mac2string(m::NTuple{6, UInt8})::String = join(bytes2hex.(m), ':')

"""
    string2mac(s::AbstractString)::NTuple{6, UInt8}

Return an `NTuple{6, UInt8}` for the MAC address tring `s`.
"""
string2mac(s::AbstractString)::NTuple{6, UInt8} = Tuple(hex2bytes(join(split(s, r"[-:.]"))))

"""
    @mac_str(s) -> NTuple{6, UInt8}

Create an `NTuple{6, UInt8}` corresponding to the given String literal.

    mac"11:22:33:44:55:66" -> (0x11, 0x22, 0x33, 0x44, 0x55, 0x66)
"""
macro mac_str(s)
    string2mac(s)
end
