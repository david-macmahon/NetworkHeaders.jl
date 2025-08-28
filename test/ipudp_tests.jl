# Tests for ../src/compound/ipv4udp.jl

@testset "ipv4/udp" begin
    @testset "headers" begin
        @test IPv4UDPHeader() == IPv4UDPHeader(IPv4Header(), UDPHeader())
        @test IPv4UDPHeader() == IPv4UDPHeader(IPv4Header{5}(), UDPHeader())
        @test IPv4UDPHeader{5}() == IPv4UDPHeader(IPv4Header(), UDPHeader())
        @test IPv4UDPHeader{5}() == IPv4UDPHeader(IPv4Header{5}(), UDPHeader())
        @test IPv4UDPHeader{8}() == IPv4UDPHeader(IPv4Header{8}(), UDPHeader())
    end

    @testset "zeros" begin
        @test zero(IPv4UDPHeader) === IPv4UDPHeader()
        @test zero(IPv4UDPHeader) === IPv4UDPHeader{5}()
        @test zero(IPv4UDPHeader{5}) === IPv4UDPHeader()
        @test zero(IPv4UDPHeader{5}) === IPv4UDPHeader{5}()
        @test zero(IPv4UDPHeader{8}) === IPv4UDPHeader{8}()
        @test all(zeros(IPv4UDPHeader, 2) .=== [IPv4UDPHeader(), IPv4UDPHeader{5}()])
        @test all(zeros(IPv4UDPHeader{5}, 2) .=== [IPv4UDPHeader{5}(), IPv4UDPHeader()])
        @test all(zeros(IPv4UDPHeader{8}, 2) .=== [IPv4UDPHeader{8}(), IPv4UDPHeader{8}()])
        @test zeros(IPv4UDPHeader, 2)|>eltype|>sizeof == 28
        @test zeros(IPv4UDPHeader{8}, 2)|>eltype|>sizeof == 40
    end

    @testset "show" begin
        # Test whether {N} appears when N!=5 and does not appear when N==5
        @test repr(IPv4UDPHeader()) == "(IPv4Header(sip=0.0.0.0, dip=0.0.0.0, length=0x0014, proto=IPPROTO_UDP), UDPHeader(sport=0, dport=0, length=8))"
        @test repr(IPv4UDPHeader{5}()) == "(IPv4Header(sip=0.0.0.0, dip=0.0.0.0, length=0x0014, proto=IPPROTO_UDP), UDPHeader(sport=0, dport=0, length=8))"
        @test repr(IPv4UDPHeader{8}()) == "(IPv4Header{8}(sip=0.0.0.0, dip=0.0.0.0, length=0x0020, proto=IPPROTO_UDP), UDPHeader(sport=0, dport=0, length=8))"
    end

    @testset "properties" begin
        ipudp = IPv4UDPHeader()
        @test ipudp.ipv4 === IPv4Header{5}()
        @test ipudp.udp === UDPHeader()
        @test ipudp.bytes === (ipudp.ipv4.bytes..., ipudp.udp.bytes...)

        ipudp5 = IPv4UDPHeader{5}()
        @test ipudp5.ipv4 === IPv4Header()
        @test ipudp5.udp === UDPHeader()
        @test ipudp5.bytes === (ipudp5.ipv4.bytes..., ipudp5.udp.bytes...)

        ipudp8 = IPv4UDPHeader{8}()
        @test ipudp8.ipv4 === IPv4Header{8}()
        @test ipudp8.udp ===UDPHeader() 
        @test ipudp8.bytes === (ipudp8.ipv4.bytes..., ipudp8.udp.bytes...)
    end

end # testset "ipv4/udp"
