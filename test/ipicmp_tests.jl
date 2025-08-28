# Tests for ../src/compound/ipicmp.jl

@testset "ipv4/icmp" begin
    @testset "headers" begin
        @test IPv4ICMPHeader() == IPv4ICMPHeader(IPv4Header(), ICMPHeader())
        @test IPv4ICMPHeader() == IPv4ICMPHeader(IPv4Header{5}(), ICMPHeader())
        @test IPv4ICMPHeader{5}() == IPv4ICMPHeader(IPv4Header(), ICMPHeader())
        @test IPv4ICMPHeader{5}() == IPv4ICMPHeader(IPv4Header{5}(), ICMPHeader())
        @test IPv4ICMPHeader{8}() == IPv4ICMPHeader(IPv4Header{8}(), ICMPHeader())
    end

    @testset "zeros" begin
        @test zero(IPv4ICMPHeader) === IPv4ICMPHeader()
        @test zero(IPv4ICMPHeader) === IPv4ICMPHeader{5}()
        @test zero(IPv4ICMPHeader{5}) === IPv4ICMPHeader()
        @test zero(IPv4ICMPHeader{5}) === IPv4ICMPHeader{5}()
        @test zero(IPv4ICMPHeader{8}) === IPv4ICMPHeader{8}()
        @test all(zeros(IPv4ICMPHeader, 2) .=== [IPv4ICMPHeader(), IPv4ICMPHeader{5}()])
        @test all(zeros(IPv4ICMPHeader{5}, 2) .=== [IPv4ICMPHeader{5}(), IPv4ICMPHeader()])
        @test all(zeros(IPv4ICMPHeader{8}, 2) .=== [IPv4ICMPHeader{8}(), IPv4ICMPHeader{8}()])
        @test zeros(IPv4ICMPHeader, 2)|>eltype|>sizeof == 28
        @test zeros(IPv4ICMPHeader{8}, 2)|>eltype|>sizeof == 40
    end

    @testset "show" begin
        # Test whether {N} appears when N!=5 and does not appear when N==5
        @test repr(IPv4ICMPHeader()) == "(IPv4Header(sip=0.0.0.0, dip=0.0.0.0, length=0x0014, proto=IPPROTO_UDP), ICMPHeader(ICMP_ECHO; id=0x0000, sequence=0x0000))"
        @test repr(IPv4ICMPHeader{5}()) == "(IPv4Header(sip=0.0.0.0, dip=0.0.0.0, length=0x0014, proto=IPPROTO_UDP), ICMPHeader(ICMP_ECHO; id=0x0000, sequence=0x0000))"
        @test repr(IPv4ICMPHeader{8}()) == "(IPv4Header{8}(sip=0.0.0.0, dip=0.0.0.0, length=0x0020, proto=IPPROTO_UDP), ICMPHeader(ICMP_ECHO; id=0x0000, sequence=0x0000))"
    end

    @testset "properties" begin
        ipicmp = IPv4ICMPHeader()
        @test ipicmp.ipv4 === IPv4Header{5}()
        @test ipicmp.icmp === ICMPHeader()
        @test ipicmp.bytes === (ipicmp.ipv4.bytes..., ipicmp.icmp.bytes...)

        ipicmp5 = IPv4ICMPHeader{5}()
        @test ipicmp5.ipv4 === IPv4Header()
        @test ipicmp5.icmp === ICMPHeader()
        @test ipicmp5.bytes === (ipicmp5.ipv4.bytes..., ipicmp5.icmp.bytes...)

        ipicmp8 = IPv4ICMPHeader{8}()
        @test ipicmp8.ipv4 === IPv4Header{8}()
        @test ipicmp8.icmp === ICMPHeader()
        @test ipicmp8.bytes === (ipicmp8.ipv4.bytes..., ipicmp8.icmp.bytes...)
    end

end # testset "ipv4/icmp"
