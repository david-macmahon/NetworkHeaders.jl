# Tests for ../src/icmp.jl

@testset "icmp" begin
    bytes_headers = (
        (0x08, 0x00, 0x8f, 0x53, 0x12, 0x34, 0x56, 0x78) => ICMPHeader(ICMP_ECHO; id=0x1234, sequence=0x5678),
        (0x00, 0x00, 0x97, 0x53, 0x12, 0x34, 0x56, 0x78) => ICMPHeader(ICMP_ECHOREPLY; id=0x1234, sequence=0x5678),
        (0x0d, 0x00, 0x8a, 0x53, 0x12, 0x34, 0x56, 0x78) => ICMPHeader(ICMP_TIMESTAMP; id=0x1234, sequence=0x5678),
        (0x0e, 0x00, 0x89, 0x53, 0x12, 0x34, 0x56, 0x78) => ICMPHeader(ICMP_TIMESTAMPREPLY; id=0x1234, sequence=0x5678),
        (0x0f, 0x00, 0x88, 0x53, 0x12, 0x34, 0x56, 0x78) => ICMPHeader(ICMP_INFO_REQUEST; id=0x1234, sequence=0x5678),
        (0x10, 0x00, 0x87, 0x53, 0x12, 0x34, 0x56, 0x78) => ICMPHeader(ICMP_INFO_REPLY; id=0x1234, sequence=0x5678),
        (0x11, 0x00, 0x86, 0x53, 0x12, 0x34, 0x56, 0x78) => ICMPHeader(ICMP_ADDRESS; id=0x1234, sequence=0x5678),
        (0x12, 0x00, 0x85, 0x53, 0x12, 0x34, 0x56, 0x78) => ICMPHeader(ICMP_ADDRESSREPLY; id=0x1234, sequence=0x5678),
        (0x03, 0x01, 0xa6, 0x52, 0x00, 0x34, 0x56, 0x78) => ICMPHeader(ICMP_DEST_UNREACH; code=ICMP_HOST_UNREACH, length=0x34, mtu=0x5678),
        (0x05, 0x01, 0xe4, 0xe6, 0x0a, 0x0b, 0x0c, 0x0d) => ICMPHeader(ICMP_REDIRECT; code=ICMP_REDIR_HOST, gateway=ip"10.11.12.13"),
        (0x0c, 0x01, 0xe1, 0xfe, 0x12, 0x00, 0x00, 0x00) => ICMPHeader(ICMP_PARAMETERPROB, code=ICMP_MISSING_OPTION, pointer=0x12),
        (0x0b, 0x01, 0xf4, 0xfe, 0x00, 0x00, 0x00, 0x00) => ICMPHeader(ICMP_TIME_EXCEEDED; code=ICMP_EXC_FRAGTIME),
        (0x04, 0x00, 0xfb, 0xff, 0x00, 0x00, 0x00, 0x00) => ICMPHeader(ICMP_SOURCE_QUENCH),
        (0xab, 0xcd, 0xeb, 0x85, 0x12, 0x34, 0x56, 0x78) => ICMPHeader(0xab; code=0xcd, data=0x12345678)
    )

    property_names = (
        (:type, :code, :checksum, :bytes, :id, :sequence), # ICMPHeader(ICMP_ECHO; id=0x1234, sequence=0x5678),
        (:type, :code, :checksum, :bytes, :id, :sequence), # ICMPHeader(ICMP_ECHOREPLY; id=0x1234, sequence=0x5678),
        (:type, :code, :checksum, :bytes, :id, :sequence), # ICMPHeader(ICMP_TIMESTAMP; id=0x1234, sequence=0x5678),
        (:type, :code, :checksum, :bytes, :id, :sequence), # ICMPHeader(ICMP_TIMESTAMPREPLY; id=0x1234, sequence=0x5678),
        (:type, :code, :checksum, :bytes, :id, :sequence), # ICMPHeader(ICMP_INFO_REQUEST; id=0x1234, sequence=0x5678),
        (:type, :code, :checksum, :bytes, :id, :sequence), # ICMPHeader(ICMP_INFO_REPLY; id=0x1234, sequence=0x5678),
        (:type, :code, :checksum, :bytes, :id, :sequence), # ICMPHeader(ICMP_ADDRESS; id=0x1234, sequence=0x5678),
        (:type, :code, :checksum, :bytes, :id, :sequence), # ICMPHeader(ICMP_ADDRESSREPLY; id=0x1234, sequence=0x5678),
        (:type, :code, :checksum, :bytes, :length, :mtu), # ICMPHeader(ICMP_DEST_UNREACH; code=ICMP_HOST_UNREACH, length=0x34, mtu=0x5678),
        (:type, :code, :checksum, :bytes, :gateway), # ICMPHeader(ICMP_REDIRECT; code=ICMP_REDIR_HOST, gateway=ip"10.11.12.13"),
        (:type, :code, :checksum, :bytes, :pointer), # ICMPHeader(ICMP_PARAMETERPROB, code=ICMP_MISSING_OPTION, pointer=0x12),
        (:type, :code, :checksum, :bytes), # ICMPHeader(ICMP_TIME_EXCEEDED; code=ICMP_EXC_FRAGTIME),
        (:type, :code, :checksum, :bytes), # ICMPHeader(ICMP_SOURCE_QUENCH),
        (:type, :code, :checksum, :bytes, :data), # ICMPHeader(0xab; code=0xcd, data=0x12345678)
    )

    property_values = (
        (; type=0x08, code=0x00, checksum=0x8f53, id=0x1234, sequence=0x5678), # ICMPHeader(ICMP_ECHO; id=0x1234, sequence=0x5678),
        (; type=0x00, code=0x00, checksum=0x9753, id=0x1234, sequence=0x5678), # ICMPHeader(ICMP_ECHOREPLY; id=0x1234, sequence=0x5678),
        (; type=0x0d, code=0x00, checksum=0x8a53, id=0x1234, sequence=0x5678), # ICMPHeader(ICMP_TIMESTAMP; id=0x1234, sequence=0x5678),
        (; type=0x0e, code=0x00, checksum=0x8953, id=0x1234, sequence=0x5678), # ICMPHeader(ICMP_TIMESTAMPREPLY; id=0x1234, sequence=0x5678),
        (; type=0x0f, code=0x00, checksum=0x8853, id=0x1234, sequence=0x5678), # ICMPHeader(ICMP_INFO_REQUEST; id=0x1234, sequence=0x5678),
        (; type=0x10, code=0x00, checksum=0x8753, id=0x1234, sequence=0x5678), # ICMPHeader(ICMP_INFO_REPLY; id=0x1234, sequence=0x5678),
        (; type=0x11, code=0x00, checksum=0x8653, id=0x1234, sequence=0x5678), # ICMPHeader(ICMP_ADDRESS; id=0x1234, sequence=0x5678),
        (; type=0x12, code=0x00, checksum=0x8553, id=0x1234, sequence=0x5678), # ICMPHeader(ICMP_ADDRESSREPLY; id=0x1234, sequence=0x5678),
        (; type=0x03, code=0x01, checksum=0xa652, length=0x34, mtu=0x5678), # ICMPHeader(ICMP_DEST_UNREACH; code=ICMP_HOST_UNREACH, length=0x34, mtu=0x5678),
        (; type=0x05, code=0x01, checksum=0xe4e6, gateway=ip"10.11.12.13"), # ICMPHeader(ICMP_REDIRECT; code=ICMP_REDIR_HOST, gateway=ip"10.11.12.13"),
        (; type=0x0c, code=0x01, checksum=0xe1fe, pointer=0x12), # ICMPHeader(ICMP_PARAMETERPROB, code=ICMP_MISSING_OPTION, pointer=0x12),
        (; type=0x0b, code=0x01, checksum=0xf4fe), # ICMPHeader(ICMP_TIME_EXCEEDED; code=ICMP_EXC_FRAGTIME),
        (; type=0x04, code=0x00, checksum=0xfbff), # ICMPHeader(ICMP_SOURCE_QUENCH),
        (; type=0xab, code=0xcd, checksum=0xeb85, data=0x12345678), # ICMPHeader(0xab; code=0xcd, data=0x12345678)
    )

    hdrs = last.(bytes_headers)
    repr_expected = (
        "ICMPHeader(ICMP_ECHO, 0x8f53, id=0x1234, sequence=0x5678)",
        "ICMPHeader(ICMP_ECHOREPLY, 0x9753, id=0x1234, sequence=0x5678)",
        "ICMPHeader(ICMP_TIMESTAMP, 0x8a53, id=0x1234, sequence=0x5678)",
        "ICMPHeader(ICMP_TIMESTAMPREPLY, 0x8953, id=0x1234, sequence=0x5678)",
        "ICMPHeader(ICMP_INFO_REQUEST, 0x8853, id=0x1234, sequence=0x5678)",
        "ICMPHeader(ICMP_INFO_REPLY, 0x8753, id=0x1234, sequence=0x5678)",
        "ICMPHeader(ICMP_ADDRESS, 0x8653, id=0x1234, sequence=0x5678)",
        "ICMPHeader(ICMP_ADDRESSREPLY, 0x8553, id=0x1234, sequence=0x5678)",
        "ICMPHeader(ICMP_DEST_UNREACH, 0xa652, code=ICMP_HOST_UNREACH, length=0x34, mtu=0x5678)",
        "ICMPHeader(ICMP_REDIRECT, 0xe4e6, code=ICMP_REDIR_HOST, gateway=10.11.12.13)",
        "ICMPHeader(ICMP_PARAMETERPROB, 0xe1fe, code=ICMP_MISSING_OPTION, pointer=0x12)",
        "ICMPHeader(ICMP_TIME_EXCEEDED, 0xf4fe, code=ICMP_EXC_FRAGTIME)",
        "ICMPHeader(ICMP_SOURCE_QUENCH, 0xfbff)",
        "ICMPHeader(0xab, 0xcd, 0xeb85, 0x12345678)"
    )

    @testset "icmp bytes" begin
        for (bytes, hdr) in bytes_headers
            @test bytes == hdr.bytes
            @test internet_checksum(hdr) === 0x000
        end
    end

    @testset "icmp show" begin
        for (hdr, exp) in zip(hdrs, repr_expected)
            @test repr(hdr) == exp
        end
    end

    @testset "icmp ctors" begin
        # Test that inner constructor works with ICMPType etc constants.
        # NB: `icmp` is malformed because an incorrect checksum value explicitly
        # given.
        icmp = ICMPHeader(ICMP_TIME_EXCEEDED, ICMP_EXC_TTL, 0x0001, Int32(0))
        icmpstr = "ICMPHeader(ICMP_TIME_EXCEEDED, 0x0001, code=ICMP_EXC_TTL)"
        # NB: `icmp1` should be well formed, i.e. with correct checksum
        icmp1 = ICMPHeader(icmp)
        icmpstr1 = "ICMPHeader(ICMP_TIME_EXCEEDED, 0xf4ff, code=ICMP_EXC_TTL)"
        # NB: `icmp2` should be well formed, i.e. with correct checksum
        icmp2 = ICMPHeader(icmp; code=ICMP_EXC_FRAGTIME)
        icmpstr2 = "ICMPHeader(ICMP_TIME_EXCEEDED, 0xf4fe, code=ICMP_EXC_FRAGTIME)"

        @test repr(icmp) == icmpstr
        @test repr(icmp1) == icmpstr1
        @test repr(icmp2) == icmpstr2
        @test internet_checksum(icmp1) === 0x0000
        @test internet_checksum(icmp2) === 0x0000
    end

    @testset "icmp properties" begin
        @test property_names == propertynames.(hdrs)

        for (propvals, h) in zip(property_values, hdrs)
            for (prop, val) in pairs(propvals)
                @test val == getproperty(h, prop)
            end
        end
    end
end # testset "ICMP"
