# Tests for ../src/ipv4.jl

# Should create headers matching `test_data`
test_ipv4 = (
    IPv4Header(; length=0x39, id=0xb40b, ttl=64, checksum=0, sip=ip"10.0.1.116", dip=ip"10.0.1.1"),
    IPv4Header(; length=0x39, id=0xb40b, ttl=64,             sip=ip"10.0.1.116", dip=ip"10.0.1.1")
)

# Both test headers "show" the same since checksum is not shown
expected_ipv4_string = "IPv4Header(sip=10.0.1.116, dip=10.0.1.1, length=0x0039, proto=IPPROTO_UDP)"

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

    @testset "ipv4 show" begin
        @test repr(test_ipv4[1]) == expected_ipv4_string
    end
end # testset "ipv4"