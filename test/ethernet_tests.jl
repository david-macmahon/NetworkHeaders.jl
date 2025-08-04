# Tests for ../src/ethernet.jl

@testset "ethernet" begin
    test_mac_string = (
        (0x11, 0x22, 0x33, 0x44, 0x55, 0x66) => "11:22:33:44:55:66",
    )

    test_string_mac = (
        "11:22:33:44:55:66" => (0x11, 0x22, 0x33, 0x44, 0x55, 0x66),
        "11-22-33-44-55-66" => (0x11, 0x22, 0x33, 0x44, 0x55, 0x66),
        "1122.3344.5566" => (0x11, 0x22, 0x33, 0x44, 0x55, 0x66),
        "112233::445566" => (0x11, 0x22, 0x33, 0x44, 0x55, 0x66)
    )

    test_mac_str = (
        mac"11:22:33:44:55:66" => (0x11, 0x22, 0x33, 0x44, 0x55, 0x66),
        mac"11-22-33-44-55-66" => (0x11, 0x22, 0x33, 0x44, 0x55, 0x66),
        mac"1122.3344.5566" => (0x11, 0x22, 0x33, 0x44, 0x55, 0x66),
        mac"112233::445566" => (0x11, 0x22, 0x33, 0x44, 0x55, 0x66)
    )

    @testset "MAC tests" begin
        for (data, expected) in test_mac_string
            @test mac2string(data) === expected
        end
        for (data, expected) in test_string_mac
            @test string2mac(data) === expected
        end
        for (got, expected) in test_mac_str
            @test got === expected
        end
    end

    @testset "EthernetHeader" begin
        eth = EthernetHeader(mac"ff:ff:ff:ff:ff:ff", mac"11:22:33:44:55:66")
        ethstr = "EthernetHeader(dmac=ff:ff:ff:ff:ff:ff, smac=11:22:33:44:55:66, 0x0800)"
        @test propertynames(eth) == (:dmac, :smac, :ethtype, :bytes)
        @test propertynames(eth, true) == (:dmac, :smac, :ethtype, :bytes)
        @test eth.dmac === mac"ff:ff:ff:ff:ff:ff"
        @test eth.smac === mac"11:22:33:44:55:66"
        @test eth.ethtype === 0x0800
        @test eth.bytes === (
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0x11, 0x22, 0x33, 0x44, 0x55, 0x66,
            0x08, 0x00
        )
        @test repr(eth) == ethstr

        eth = EthernetHeader(mac"11:22:33:44:55:66", mac"ff:ff:ff:ff:ff:ff", 0x1234)
        ethstr = "EthernetHeader(dmac=11:22:33:44:55:66, smac=ff:ff:ff:ff:ff:ff, 0x1234)"
        @test eth.dmac === mac"11:22:33:44:55:66"
        @test eth.smac === mac"ff:ff:ff:ff:ff:ff"
        @test eth.ethtype === 0x1234
        @test eth.bytes === (
            0x11, 0x22, 0x33, 0x44, 0x55, 0x66,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0x12, 0x34
        )
        @test repr(eth) == ethstr
    end

    @testset "EthernetVlanHeader" begin
        eth = EthernetVlanHeader(mac"ff:ff:ff:ff:ff:ff", mac"11:22:33:44:55:66", 0x1234, 0x5678; tpid=0xabcd)
        ethstr = "EthernetVlanHeader(dmac=ff:ff:ff:ff:ff:ff, smac=11:22:33:44:55:66, 0x1234)"
        @test propertynames(eth) == (:dmac, :smac, :tpid, :vlan, :ethtype, :bytes)
        @test propertynames(eth, true) == (:dmac, :smac, :tpid, :vlan, :ethtype, :bytes)
        @test eth.dmac === mac"ff:ff:ff:ff:ff:ff"
        @test eth.smac === mac"11:22:33:44:55:66"
        @test eth.tpid === 0xabcd
        @test eth.vlan === 0x1234
        @test eth.ethtype === 0x5678
        @test eth.bytes === (
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0x11, 0x22, 0x33, 0x44, 0x55, 0x66,
            0xab, 0xcd, 0x12, 0x34,
            0x56, 0x78
        )

        eth = EthernetVlanHeader(mac"11:22:33:44:55:66", mac"ff:ff:ff:ff:ff:ff", 0x1234)
        @test eth.dmac === mac"11:22:33:44:55:66"
        @test eth.smac === mac"ff:ff:ff:ff:ff:ff"
        @test eth.tpid === 0x8100
        @test eth.vlan === 0x1234
        @test eth.ethtype === 0x0800
        @test eth.bytes === (
            0x11, 0x22, 0x33, 0x44, 0x55, 0x66,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0x81, 0x00, 0x12, 0x34,
            0x08, 0x00
        )
    end
end # testset "ethernet"
