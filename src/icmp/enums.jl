module Constants

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

"""
ICMP types
"""
@enum ICMPType::UInt8 begin           # Desc                     [data fields]
    ICMP_ECHOREPLY          = 0       # Echo Reply               [id, sequence]
    ICMP_DEST_UNREACH       = 3       # Destination Unreachable  [mtu]
    ICMP_SOURCE_QUENCH      = 4       # Source Quench            [unused]
    ICMP_REDIRECT           = 5       # Redirect (change route)  [gateway]
    ICMP_ECHO               = 8       # Echo Request             [id, sequence]
    ICMP_TIME_EXCEEDED      = 11      # Time Exceeded            [unused]
    ICMP_PARAMETERPROB      = 12      # Parameter Problem        [pointer]
    ICMP_TIMESTAMP          = 13      # Timestamp Request        [id, sequence]
    ICMP_TIMESTAMPREPLY     = 14      # Timestamp Reply          [id, sequence]
    ICMP_INFO_REQUEST       = 15      # Information Request      [id, sequence]
    ICMP_INFO_REPLY         = 16      # Information Reply        [id, sequence]
    ICMP_ADDRESS            = 17      # Address Mask Request     [id, sequence]
    ICMP_ADDRESSREPLY       = 18      # Address Mask Reply       [id, sequence]
end

"""
ICMP codes for ICMP_DEST_UNREACH type
"""
@enum ICMPDestUnreachCode::UInt8 begin
    ICMP_NET_UNREACH        = 0       # Network Unreachable
    ICMP_HOST_UNREACH       = 1       # Host Unreachable
    ICMP_PROT_UNREACH       = 2       # Protocol Unreachable
    ICMP_PORT_UNREACH       = 3       # Port Unreachable
    ICMP_FRAG_NEEDED        = 4       # Fragmentation Needed/DF set
    ICMP_SR_FAILED          = 5       # Source Route failed
    ICMP_NET_UNKNOWN        = 6
    ICMP_HOST_UNKNOWN       = 7
    ICMP_HOST_ISOLATED      = 8
    ICMP_NET_ANO            = 9
    ICMP_HOST_ANO           = 10
    ICMP_NET_UNR_TOS        = 11
    ICMP_HOST_UNR_TOS       = 12
    ICMP_PKT_FILTERED       = 13      # Packet filtered
    ICMP_PREC_VIOLATION     = 14      # Precedence violation
    ICMP_PREC_CUTOFF        = 15      # Precedence cut off
end

"""
ICMP codes for ICMP_REDIRECT type
"""
@enum ICMPRedirectCode::UInt8 begin
    ICMP_REDIR_NET          = 0       # Redirect Net
    ICMP_REDIR_HOST         = 1       # Redirect Host
    ICMP_REDIR_NETTOS       = 2       # Redirect Net for TOS
    ICMP_REDIR_HOSTTOS      = 3       # Redirect Host for TOS
end

"""
ICMP codes for ICMP_PARAMETERPROB type
"""
@enum ICMPParameterprobCode::UInt8 begin
    ICMP_SEE_POINTER        = 0       # Pointer indicates the error
    ICMP_MISSING_OPTION     = 1       # Missing a required option
    ICMP_BAD_LENGTH         = 2       # Bad length
end

"""
ICMP codes for ICMP_TIME_EXCEEDED type
"""
@enum ICMPTimeExceededCode::UInt8 begin
    ICMP_EXC_TTL            = 0       # TTL count exceeded
    ICMP_EXC_FRAGTIME       = 1       # Fragment Reass time exceeded
end

end # module Constants
