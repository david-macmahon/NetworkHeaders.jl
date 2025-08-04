# Tests for ../src/udp.jl

@testset "udp" begin

    test_udp_hdrs = (
        UDPHeader(1234, 4567, 4321),
        UDPHeader(sport=0x86a3, dport=53, length=37, checksum=0x16ab)
    )

    expected_udp_strings = (
        "UDPHeader(sport=1234, dport=4567, length=4321)",
        "UDPHeader(sport=34467, dport=53, length=37)"
    )

    @testset "udp show" begin
        for (hdr, str) in zip(test_udp_hdrs, expected_udp_strings)
            @test repr(hdr) == str
        end
    end
end # @testset "udp"
