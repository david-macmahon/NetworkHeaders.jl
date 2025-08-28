# Tests for ../src/ipv4/ipv4.jl

# Should create headers matching `test_data`
test_ipv4 = (
    IPv4Header(; length=0x39, id=0xb40b, ttl=64, checksum=0, sip=ip"10.0.1.116", dip=ip"10.0.1.1"),
    IPv4Header(; length=0x39, id=0xb40b, ttl=64,             sip=ip"10.0.1.116", dip=ip"10.0.1.1")
)

# Both test headers "show" the same since checksum is not shown
expected_ipv4_string = "IPv4Header(sip=10.0.1.116, dip=10.0.1.1, length=0x0039, proto=IPPROTO_UDP)"

ipv4_properties = IPv4Header(;
    #version=4, #ihl
    dscp=1, ecn=2, id=3, flags=4, offset=5, ttl=6, protocol=7, checksum=8,
    sip=9, dip=10, options=(11,), length=12
)

@testset "ipv4" begin
    @testset "ipv4 header" begin
        for (data, hdr) in zip(test_data, test_ipv4)
            @test data === hdr.bytes
            @test hdr.length === 0x0039
            @test hdr.id === 0xb40b
        end
    end

    @testset "ipv4 hexdump" begin
        for (data, expected) in zip(test_ipv4, hexdump_expected)
            io = IOBuffer()
            NetworkHeaders.hexdump(io, data)        
            got = read(seekstart(io), String)
            @test got == expected
        end
    end

    @testset "ipv4 zeros" begin
        @test zero(IPv4Header) === IPv4Header()
        @test zero(IPv4Header) === IPv4Header{5}()
        @test zero(IPv4Header{5}) === IPv4Header()
        @test zero(IPv4Header{5}) === IPv4Header{5}()
        @test zero(IPv4Header{8}) === IPv4Header{8}()
        @test all(zeros(IPv4Header, 2) .=== [IPv4Header(), IPv4Header{5}()])
        @test all(zeros(IPv4Header{5}, 2) .=== [IPv4Header{5}(), IPv4Header()])
        @test all(zeros(IPv4Header{8}, 2) .=== [IPv4Header{8}(), IPv4Header{8}()])
        @test zeros(IPv4Header, 2)|>eltype|>sizeof == 20
        @test zeros(IPv4Header{8}, 2)|>eltype|>sizeof == 32
    end

    @testset "ipv4 show" begin
        @test repr(test_ipv4[1]) == expected_ipv4_string
        # Test whether {N} appears when N!=5 and does not appear when N==5
        @test repr(IPv4Header()) == "IPv4Header(sip=0.0.0.0, dip=0.0.0.0, length=0x0014, proto=IPPROTO_UDP)"
        @test repr(IPv4Header{5}()) == "IPv4Header(sip=0.0.0.0, dip=0.0.0.0, length=0x0014, proto=IPPROTO_UDP)"
        @test repr(IPv4Header{8}()) == "IPv4Header{8}(sip=0.0.0.0, dip=0.0.0.0, length=0x0020, proto=IPPROTO_UDP)"
    end

    @testset "ipv4 properties" begin
        @test ipv4_properties.version == 4
        @test ipv4_properties.ihl == 6
        @test ipv4_properties.dscp == 1
        @test ipv4_properties.ecn == 2
        @test ipv4_properties.id == 3
        @test ipv4_properties.flags == 4
        @test ipv4_properties.offset == 5
        @test ipv4_properties.ttl == 6
        @test ipv4_properties.protocol == 7
        @test ipv4_properties.checksum == 8
        @test ipv4_properties.sip == ip"0.0.0.9"
        @test ipv4_properties.dip == ip"0.0.0.10"
        @test ipv4_properties.options === (0x0000_000b,)
        @test ipv4_properties.length == 12
    end

end # testset "ipv4"
