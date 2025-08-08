using NetworkHeaders
using NetworkHeaders.EthernetConstants
using NetworkHeaders.IPv4Constants
using NetworkHeaders.ICMPConstants

using Sockets
using StructArrays
using Test

test_data = (
    # Internet checksum is 0xb034
    iphdr_sans_cksum = (
        0x45, 0x00, 0x00, 0x39, 0xb4, 0x0b, 0x00, 0x00,
        0x40, 0x11, 0x00, 0x00, 0x0a, 0x00, 0x01, 0x74,
        0x0a, 0x00, 0x01, 0x01
    ),

    # Internet checksum is 0x0000
    iphdr_with_cksum = (
        0x45, 0x00, 0x00, 0x39, 0xb4, 0x0b, 0x00, 0x00,
        0x40, 0x11, 0xb0, 0x34, 0x0a, 0x00, 0x01, 0x74,
        0x0a, 0x00, 0x01, 0x01
    )
)

cksum_expected = (
    0xb034, # Internet checksum = 0xb034
    0x0000  # Internet checksum = 0xb0, 0x34]
)

hexdump_expected = (
    raw"""
    00000000 45 00 00 39 b4 0b 00 00  40 11 00 00 0a 00 01 74 |E..9....@......t|
    00000010 0a 00 01 01                                      |....|
    00000014
    """,

    raw"""
    00000000 45 00 00 39 b4 0b 00 00  40 11 b0 34 0a 00 01 74 |E..9....@..4...t|
    00000010 0a 00 01 01                                      |....|
    00000014
    """
)

@testset verbose=true "All tests" begin
    @testset "utilities" begin
        @testset "internet_checksum" begin
            for (data, expected) in zip(test_data, cksum_expected)
                @test internet_checksum(data) == expected
            end
        end

        @testset "hexdump" begin
            for (data, expected) in zip(test_data, hexdump_expected)
                io = IOBuffer()
                NetworkHeaders.hexdump(io, data)        
                got = read(seekstart(io), String)
                @test got == expected
            end
        end
    end

    function nothrow(f, args...)
        try
            f(args...)
            true
        catch
            false
        end
    end

    @testset "zero" begin
        for T in (EthernetHeader, IPv4Header, ICMPHeader, UDPHeader)
            @test nothrow(Base.zero, T)
        end
    end

    include("ethernet_tests.jl")
    include("ipv4_tests.jl")
    include("icmp_tests.jl")
    include("udp_tests.jl")
    include("readwrite_tests.jl")
    include("structarrays_tests.jl")

end
