module Constants

export EtherType, ETH_P_LOOP, ETH_P_PUP, ETH_P_PUPAT, ETH_P_TSN, ETH_P_IP,
    ETH_P_X25, ETH_P_ARP, ETH_P_BPQ, ETH_P_IEEEPUP, ETH_P_IEEEPUPAT,
    ETH_P_BATMAN, ETH_P_DEC, ETH_P_DNA_DL, ETH_P_DNA_RC, ETH_P_DNA_RT,
    ETH_P_LAT, ETH_P_DIAG, ETH_P_CUST, ETH_P_SCA, ETH_P_TEB, ETH_P_RARP,
    ETH_P_ATALK, ETH_P_AARP, ETH_P_8021Q, ETH_P_IPX, ETH_P_IPV6, ETH_P_PAUSE,
    ETH_P_SLOW, ETH_P_WCCP, ETH_P_MPLS_UC, ETH_P_MPLS_MC, ETH_P_ATMMPOA,
    ETH_P_PPP_DISC, ETH_P_PPP_SES, ETH_P_LINK_CTL, ETH_P_ATMFATE, ETH_P_PAE,
    ETH_P_AOE, ETH_P_8021AD, ETH_P_802_EX1, ETH_P_TIPC, ETH_P_8021AH,
    ETH_P_MVRP, ETH_P_1588, ETH_P_PRP, ETH_P_FCOE, ETH_P_TDLS, ETH_P_FIP,
    ETH_P_80221, ETH_P_LOOPBACK, ETH_P_QINQ1, ETH_P_QINQ2, ETH_P_QINQ3,
    ETH_P_EDSA, ETH_P_AF_IUCV, ETH_P_802_3_MIN, ETH_P_802_3, ETH_P_AX25,
    ETH_P_ALL, ETH_P_802_2, ETH_P_SNAP, ETH_P_DDCMP, ETH_P_WAN_PPP,
    ETH_P_PPP_MP, ETH_P_LOCALTALK, ETH_P_CAN, ETH_P_CANFD, ETH_P_PPPTALK,
    ETH_P_TR_802_2, ETH_P_MOBITEX, ETH_P_CONTROL, ETH_P_IRDA, ETH_P_ECONET,
    ETH_P_HDLC, ETH_P_ARCNET, ETH_P_DSA, ETH_P_TRAILER, ETH_P_PHONET,
    ETH_P_IEEE802154, ETH_P_CAIF, ETH_P_XDSA

@enum EtherType::UInt16 begin
    ETH_P_LOOP        = 0x0060
    ETH_P_PUP         = 0x0200
    ETH_P_PUPAT       = 0x0201
    ETH_P_TSN         = 0x22F0
    ETH_P_ERSPAN2     = 0x22EB
    ETH_P_IP          = 0x0800
    ETH_P_X25         = 0x0805
    ETH_P_ARP         = 0x0806
    ETH_P_BPQ         = 0x08FF
    ETH_P_IEEEPUP     = 0x0a00
    ETH_P_IEEEPUPAT   = 0x0a01
    ETH_P_BATMAN      = 0x4305
    ETH_P_DEC         = 0x6000
    ETH_P_DNA_DL      = 0x6001
    ETH_P_DNA_RC      = 0x6002
    ETH_P_DNA_RT      = 0x6003
    ETH_P_LAT         = 0x6004
    ETH_P_DIAG        = 0x6005
    ETH_P_CUST        = 0x6006
    ETH_P_SCA         = 0x6007
    ETH_P_TEB         = 0x6558
    ETH_P_RARP        = 0x8035
    ETH_P_ATALK       = 0x809B
    ETH_P_AARP        = 0x80F3
    ETH_P_8021Q       = 0x8100
    ETH_P_ERSPAN      = 0x88BE
    ETH_P_IPX         = 0x8137
    ETH_P_IPV6        = 0x86DD
    ETH_P_PAUSE       = 0x8808
    ETH_P_SLOW        = 0x8809
    ETH_P_WCCP        = 0x883E
    ETH_P_MPLS_UC     = 0x8847
    ETH_P_MPLS_MC     = 0x8848
    ETH_P_ATMMPOA     = 0x884c
    ETH_P_PPP_DISC    = 0x8863
    ETH_P_PPP_SES     = 0x8864
    ETH_P_LINK_CTL    = 0x886c
    ETH_P_ATMFATE     = 0x8884
    ETH_P_PAE         = 0x888E
    ETH_P_PROFINET    = 0x8892
    ETH_P_REALTEK     = 0x8899
    ETH_P_AOE         = 0x88A2
    ETH_P_ETHERCAT    = 0x88A4
    ETH_P_8021AD      = 0x88A8
    ETH_P_802_EX1     = 0x88B5
    ETH_P_PREAUTH     = 0x88C7
    ETH_P_TIPC        = 0x88CA
    ETH_P_LLDP        = 0x88CC
    ETH_P_MRP         = 0x88E3
    ETH_P_MACSEC      = 0x88E5
    ETH_P_8021AH      = 0x88E7
    ETH_P_MVRP        = 0x88F5
    ETH_P_1588        = 0x88F7
    ETH_P_NCSI        = 0x88F8
    ETH_P_PRP         = 0x88FB
    ETH_P_CFM         = 0x8902
    ETH_P_FCOE        = 0x8906
    ETH_P_IBOE        = 0x8915
    ETH_P_TDLS        = 0x890D
    ETH_P_FIP         = 0x8914
    ETH_P_80221       = 0x8917
    ETH_P_HSR         = 0x892F
    ETH_P_NSH         = 0x894F
    ETH_P_LOOPBACK    = 0x9000
    ETH_P_QINQ1       = 0x9100
    ETH_P_QINQ2       = 0x9200
    ETH_P_QINQ3       = 0x9300
    ETH_P_EDSA        = 0xDADA
    ETH_P_DSA_8021Q   = 0xDADB
    ETH_P_DSA_A5PSW   = 0xE001
    ETH_P_IFE         = 0xED3E
    ETH_P_AF_IUCV     = 0xFBFB
    ETH_P_802_3_MIN   = 0x0600
    ETH_P_802_3       = 0x0001
    ETH_P_AX25        = 0x0002
    ETH_P_ALL         = 0x0003
    ETH_P_802_2       = 0x0004
    ETH_P_SNAP        = 0x0005
    ETH_P_DDCMP       = 0x0006
    ETH_P_WAN_PPP     = 0x0007
    ETH_P_PPP_MP      = 0x0008
    ETH_P_LOCALTALK   = 0x0009
    ETH_P_CAN         = 0x000C
    ETH_P_CANFD       = 0x000D
    ETH_P_CANXL       = 0x000E
    ETH_P_PPPTALK     = 0x0010
    ETH_P_TR_802_2    = 0x0011
    ETH_P_MOBITEX     = 0x0015
    ETH_P_CONTROL     = 0x0016
    ETH_P_IRDA        = 0x0017
    ETH_P_ECONET      = 0x0018
    ETH_P_HDLC        = 0x0019
    ETH_P_ARCNET      = 0x001A
    ETH_P_DSA         = 0x001B
    ETH_P_TRAILER     = 0x001C
    ETH_P_PHONET      = 0x00F5
    ETH_P_IEEE802154  = 0x00F6
    ETH_P_CAIF        = 0x00F7
    ETH_P_XDSA        = 0x00F8
    ETH_P_MAP         = 0x00F9
    ETH_P_MCTP        = 0x00FA
end

end # module Constants
