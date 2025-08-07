eth1 = EthernetHeader(; ethtype=0x0001)
eth2 = EthernetHeader(; ethtype=0x0002)
eths = [eth1, eth2]
ethsa = StructArray(eths)

#---
ip1 = IPv4Header()
ip2 = IPv4Header(; dip=2)
ips = [ip1, ip2]
ipsa = StructArray(ips)
#---

ic1 = ICMPHeader()
ic2 = ICMPHeader(ICMP_ECHOREPLY)
ics = [ic1, ic2]
icsa = StructArray(ics)

ud1 = UDPHeader()
ud2 = UDPHeader(sport=2)
uds = [ud1, ud2]
udsa = StructArray(uds)

@testset "StructArrays" begin
    @test ethsa.ethtype == [0x0001, 0x0002]
    @test ethsa[1] == eth1
    @test ethsa[2] == eth2

    @test ipsa.dip == [ip"0.0.0.0", ip"0.0.0.2"]
    @test ipsa[1] == ip1
    @test ipsa[2] == ip2

    @test icsa.type == Integer.([ICMP_ECHO, ICMP_ECHOREPLY])
    @test icsa[1] == ic1
    @test icsa[2] == ic2

    @test udsa.sport == [0x0000, 0x0002]
    @test udsa[1] == ud1
    @test udsa[2] == ud2
end
