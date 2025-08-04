@testset "read/write" begin
#---
    pkts_hex = (
        """
        0025 90fb 9215 0cc4 7a8e 0bad 0800 4500
        0038 ec60 0000 4001 7819 0a00 014b 0a00
        0101 0800 bc22 e595 0001 4865 6c6c 6f20
        6672 6f6d 204e 6574 776f 726b 4865 6164
        6572 732e 6a6c
        ""","""
        0cc4 7a8e 0bad 0025 90fb 9215 0800 4500
        0038 7cdf 0000 4001 e79a 0a00 0101 0a00
        014b 0000 c422 e595 0001 4865 6c6c 6f20
        6672 6f6d 204e 6574 776f 726b 4865 6164
        6572 732e 6a6c
        ""","""
        0025 90fb 9215 ac1f 6b48 8e5c 0800 4500
        0039 21c2 0000 4011 427e 0a00 0174 0a00
        0101 86a3 0035 0025 16ab 10d9 0100 0001
        0000 0000 0000 0462 6c61 3002 626c 0370
        7674 0000 0100 01
        """
    )

    pkts = hex2bytes.(filter.(!isspace, pkts_hex))
    ios = IOBuffer.(pkts)
    h1s, h2s, h3s = read_headers.(ios)
    pl1, pl2, pl3 = read.(ios)
#---
    # Recreate packet headers
    e1 = EthernetHeader(dmac=mac"00:25:90:fb:92:15", smac=mac"0c:c4:7a:8e:0b:ad")
    ip1 = IPv4Header(sip=ip"10.0.1.75", dip=ip"10.0.1.1", length=0x0038, id=0xec60, protocol=IPPROTO_ICMP)
    icmp1 = ICMPHeader(ICMP_ECHO, id=0xe595, sequence=0x0001, initcsum=internet_checksum(pl1))

    e2 = EthernetHeader(dmac=mac"0c:c4:7a:8e:0b:ad", smac=mac"00:25:90:fb:92:15")
    ip2 = IPv4Header(sip=ip"10.0.1.1", dip=ip"10.0.1.75", length=0x0038, id=0x7cdf, protocol=IPPROTO_ICMP)
    icmp2 = ICMPHeader(ICMP_ECHOREPLY, id=0xe595, sequence=0x0001, initcsum=internet_checksum(pl2))

    e3 = EthernetHeader(dmac=mac"00:25:90:fb:92:15", smac=mac"ac:1f:6b:48:8e:5c")
    ip3 = IPv4Header(sip=ip"10.0.1.116", dip=ip"10.0.1.1", length=0x0039, id=0x21c2)
    udp3 = UDPHeader(sport=0x86a3, dport=53, length=37, checksum=0x16ab)

    io1, io2, io3 = (IOBuffer() for _=1:3)
    repkts = map(((io1, e1, ip1, icmp1, pl1),
                (io2, e2, ip2, icmp2, pl2),
                (io3, e3, ip3, udp3, pl3))) do (io, eth, ip, proto, pl)
        write(io, eth)
        write(io, ip)
        write(io, proto)
        write(io, pl)
        seekstart(io)
        read(io)
    end
#---
    @testset "rebuilt packets" begin
        for i in eachindex(pkts)
            @test pkts[i] == repkts[i]
        end

        @test pkts[1] == [e1.bytes...; ip1.bytes...; icmp1.bytes...; pl1]
        @test pkts[2] == [e2.bytes...; ip2.bytes...; icmp2.bytes...; pl2]
        @test pkts[3] == [e3.bytes...; ip3.bytes...; udp3.bytes...; pl3]
    end
#---
end
