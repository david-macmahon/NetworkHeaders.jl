# NetworkHeaders.jl

## Network header structures for Julia

`NetworkHeaders.jl` provides *wire compatible* Julia structures representing
network protocol headers for common networking standards.  These are immutable
`isbitstype` structures that store their data in a wire compatible format.  In
other words, their in-memory representations can be sent to (or received from)
the network "wire" (or fiber or WiFi) as is.  `Base.getproperty` property
methods are defined to allow access the individual protocol fields.  This
primarily means:

1. Bit field values are appropriately packed into integer fields rather than
   being stored in separate fields.
2. Multi-byte values are stored in network [byte order][Endianness] (big endian)
   rather than host byte order (little endian for all platforms Julia runs on).
3. `Base.getproperty` (and `Base.propertynames`) methods provide natural access
   to the header values in host byte order using familiar `obj.value` notation
   (with TAB-completion in the REPL).

Structures are defined for the headers of individual network protocols.
Julia does not support [packed][] data structures, so combining header
structures into a higher level "packet" structure can result in extra padding
between headers that causes the in-memory representation of the "packet"
structure to be NOT wire compatible.  *Caveat emptor!*  Future versions of
`NetworkHeaders.jl` will include higher level "compound headers" that will be
wire compatible.

[Endianness]: https://en.wikipedia.org/wiki/Endianness
[packed]: https://en.wikipedia.org/wiki/Data_structure_alignment#Data_structure_padding

## Supported header types

`NetworkHeaders.jl` defines the following abstract types:

- `AbstractNetworkHeader`: Base type for all `NetworkHeaders.jl` structures
- `AbstractEthernerHeader`: Supertype of Ethernet header types

`NetworkHeaders.jl` supports the following network header types:

- `EthernetHeader`
- `EthernetVlanHeader`
- `IPv4Header`
- `ICMPHeader`
- `UDPHeader`

Here is a tree diagram of the type hierarchy:

```plain
AbstractNetworkHeader
├─ AbstractEthernetHeader
│  ├─ EthernetHeader
│  └─ EthernetVlanHeader
├─ ICMPHeader
├─ IPv4Header
└─ UDPHeader
```

## Properties and constructors

The following sections describe the properties and constructors that each header
type supports.  Properties can be thought of as the fields of the network header
even though they may be stored in only part of a field in the Julia structure.
Properties are most commonly accessed using dotted notation such as
`hdr.propname` to get the `propname` property of header `hdr`.  The actual Julia
fields of a `NetworkHeaders.jl` structure are private/internal/opaque values
that should not be accessed directly.

Multi-octet properties are given and returned in host byte order.  All of the
`NetworkHeaders.jl` header types have a `bytes` property which will return the
header contents as an `NTuple{N,UInt8}` containing the byte representation of
the header as it would be seen on the wire.

### [Ethernet](https://en.wikipedia.org/wiki/Ethernet_frame)

#### `EthernetHeader`

`EthernetHeader` structures represent normal/untagged [IEEE 802.3][] Ethernet
headers having these properties:

- `dmac`: destination MAC address as `NTuple{6,UInt8}`
- `smac`: source MAC address as `NTuple{6,UInt8}`
- `ethtype`: [EtherType][] field as `UInt16`

They can be constructed using one of these constructors:

```julia
EthernetHeader(dmac, smac, ethtype=0x0800)

EthernetHeader(;
    dmac=(0xff, 0xff, 0xff, 0xff, 0xff, 0xff),
    smac=(0xff, 0xff, 0xff, 0xff, 0xff, 0xff),
    ethtype=0x0800
)
```

The `@mac_str` macro can be used with literal MAC addresses:

```julia
julia> EthernetHeader(;
           dmac=mac"11:22:33:44:55:66",
           smac=mac"66:55:44:33:22:11",
           ethtype=0x0800
       )
EthernetHeader(dmac=11:22:33:44:55:66, smac=66:55:44:33:22:11, 0x0800)
```

[IEEE 802.3]: https://en.wikipedia.org/wiki/IEEE_802.3
[EtherType]: https://en.wikipedia.org/wiki/EtherType

#### `EthernetVlanHeader`

`EthernetVlanHeader` structures represent [IEEE 802.1Q][] tagged VLAN Ethernet
headers having these properties:

- `dmac`: destination MAC address as `NTuple{6,UInt8}`
- `smac`: source MAC address as `NTuple{6,UInt8}`
- `tpid`: Tag protocol identifier (TPID) as `UInt16`
- `vlan`: VLAN id as `UInt16`
- `ethtype`: [EtherType][] field as `UInt16`

They can be constructed using one of these constructor:

```julia
EthernetVlanHeader(dmac, smac, vlan, ethtype=0x0800; tpid=0x8100)

EthernetVlanHeader(;
    dmac=(0xff, 0xff, 0xff, 0xff, 0xff, 0xff),
    smac=(0xff, 0xff, 0xff, 0xff, 0xff, 0xff),
    tpid=0x8100,
    vlan=1,
    ethtype=0x0800
)
```

The `@mac_str` macro can be used with literal MAC addresses:

```julia
julia> EthernetVlanHeader(;
           dmac=mac"ff:ff:ff:ff:ff:ff",
           smac=mac"ff:ff:ff:ff:ff:ff",
           vlan=1
       )
EthernetVlanHeader(dmac=ff:ff:ff:ff:ff:ff, smac=ff:ff:ff:ff:ff:ff, 0x0001, 0x0800)
```

[IEEE 802.1ad][] tagging (aka "stacked" or "QinQ" tagging) is not currently
supported.

[IEEE 802.1Q]: https://en.wikipedia.org/wiki/802.1Q
[IEEE 802.1ad]: https://en.wikipedia.org/wiki/IEEE_802.1ad

#### Ethernet helpers

`NetworkHeaders.jl` provides some helper functions to facilitate
printing/parsing MAC addresses from/to `NTuple{6,UInt8}` as well as a `@mac_str`
macro that makes it easy to work with MAC address string literals.

- `mac2string(mac::NTuple{6,UInt8}) -> String`
- `string2mac(mac::String) -> NTuple{6,UInt8}`
- `mac"xx:xx:xx:xx:xx:xx" -> NTuple{6,UInt8}` (uses `@mac_str`)

```julia-repl
julia> mac = string2mac("11:22:33:44:55:66")
(0x11, 0x22, 0x33, 0x44, 0x55, 0x66)

julia> mac2string(mac)
"11:22:33:44:55:66"

julia> mac"11:22:33:44:55:66"
(0x11, 0x22, 0x33, 0x44, 0x55, 0x66)
```

### [Internet Protocol version 4](https://en.wikipedia.org/wiki/IPv4)

[IPv4 headers] consist of a between 5 and 15 32-bit words.  Only the first 5
words are required.  The `IPv4Header{N}` structure is a parameterized type where
`N` represents the number of 32-bit words in the header.  These structures
support the properties listed in the table below along with their return types.

`IPv4Header` objects can be constructed using a convenient keyword argument
constructor.  Each property has a corresponding keyword argument except for
`version` (always 4) and `ihl` (internet header length) which is inferred from
`options`.  All of the properties have default values as shown in the table,
but some are required for a meaningful header (e.g. `length`, `sip`, and `dip`).

| Property   | Return type          | Default value        |
|:-----------|:---------------------|:--------------------:|
| `version`  | `UInt8`              | (always `4`)         |
| `ihl`      | `UInt8`              | (always inferred)    |
| `dscp`     | `UInt8`              | `0`                  |
| `ecn`      | `UInt8`              | `0`                  |
| `length`   | `UInt16`             | `4N` (i.e. no data)  |
| `id`       | `UInt16`             | `0`                  |
| `flags`    | `UInt8`              | `0`                  |
| `offset`   | `UInt16`             | `0`                  |
| `ttl`      | `UInt8`              | `64`                 |
| `protocol` | `UInt8`              | `17` (UDP)           |
| `checksum` | `UInt16`             | `nothing` (see text) |
| `sip`      | `Sockets.IPv4`       | `ip"0.0.0.0"`        |
| `dip`      | `Sockets.IPv4`       | `ip"0.0.0.0"`        |
| `options`  | `NTuple{N-5,UInt32}` | `()`                 |
| `bytes`    | `NTuple{4N,UInt8}`   | (N/A)                |

If the `checksum` keyword argument is passed as `checksum=nothing` (the
default), the header's checksum will be calculated using the [Internet
checksum][] formula.  If an explicit value is passed, it will be used as given
without regard for whether it is correct for the header being constructed.  It
may be useful to pass `checksum=0` when the checksum value will be computed
elsewhere (e.g. offloaded to the network interface card).

`IPv4Header` objects also support `Base.getindex` to access the `UInt32` words
of the header in host byte order.

`NetworkHeaders.jl` also provides an `internet_checksum` function that can be
used to calculate the [Internet checksum] of an `AbstractVector` or `Tuple` of
`UInt8` values.

[IPv4 headers]: https://en.wikipedia.org/wiki/IPv4#Header
[Internet checksum]: https://en.wikipedia.org/wiki/Internet_checksum

### [Internet Control Message Protocol][ICMP]

ICMP headers contain 8 bytes.  The first four contain the `type`, `code`, and
`checksum` fields.  The contents of the `code` field and the latter four bytes
of the header are `type` dependent.  The `ICMPHeader` class exposes `type`
dependent properties for any given instance.  The superset of properties exposed
is listed in the table below, but for any given `ICMPHeader` instance only the
ones relevant to that instance's `type` will be exposed:

| Property   | Description                 | Type               |
|------------|-----------------------------|--------------------|
| `type`     | ICMP message type           | `UInt8`            |
| `code`     | ICMP message code           | `UInt8`            |
| `checksum` | ICMP message checksum       | `UInt16`           |
| `id`       | ICMP message identifier     | `UInt16`           |
| `sequence` | ICMP message sequence       | `UInt16`           |
| `length`   | Length of original datagram | `UInt8`            |
| `mtu`      | Maximum transmission Unit   | `UInt16`           |
| `gateway`  | Alternate gateway           | `IPv4`             |
| `pointer`  | Index of first bad value    | `UInt8`            |
| `data`     | Last 4 bytes of header      | `UInt32`           |
| `bytes`    | All bytes of the header     | `NTuple{8, UInt8}` |

`ICMPHeader` structures can be constructed using this constructor:

```julia
ICMPHeader(type=ICMP_ECHO, checksum=nothing; kwargs...)
```

`type` is the ICMP type field of the header.  It may be an `ICMPType` value or
any `Integer` value (only the low 8 bits are used).  If the `checksum` argument
is `nothing` (the default), the checksum field will be computed as the Internet
checksum of the ICMP header (and other data whose Internet checksum is given in
`initcsum`); otherwise the given `checksum` value will be used.  The remaining
contents of the `ICMPHeader` are determined from type-specific keyword arguments
shown in the table below.  Unspecified keyword arguments default to 0, except
for `initcsum` which defaults to `-1`.

| `type`                | Keyword arguments           |
|-----------------------|-----------------------------|
| `ICMP_ECHO` (default) | initcsum, id, sequence      |
| `ICMP_ECHOREPLY`      | initcsum, id, sequence      |
| `ICMP_TIMESTAMP`      | initcsum, id, sequence      |
| `ICMP_TIMESTAMPREPLY` | initcsum, id, sequence      |
| `ICMP_INFO_REQUEST`   | initcsum, id, sequence      |
| `ICMP_INFO_REPLY`     | initcsum, id, sequence      |
| `ICMP_ADDRESS`        | initcsum, id, sequence      |
| `ICMP_ADDRESSREPLY`   | initcsum, id, sequence      |
| `ICMP_DEST_UNREACH`   | initcsum, code, length, mtu |
| `ICMP_REDIRECT`       | initcsum, code, gateway     |
| `ICMP_PARAMETERPROB`  | initcsum, code, pointer     |
| `ICMP_TIME_EXCEEDED`  | initcsum, code              |
| `ICMP_SOURCE_QUENCH`  | initcsum                    |
| other Integer value   | initcsum, code, data        |

When `type` is an `Integer` whose value is equivalent to one of the `ICMPType`
enum values, it will use the corresponding keyword arguments; otherwise it will
be treated as a non-standard ICMP type and the `code` and `data` keyword
arguments will define the rest of the header contents.

[ICMP]: https://en.wikipedia.org/wiki/Internet_Control_Message_Protocol

### [User Datagram Protocol (UDP)][UDP]

[UDP headers][] consist of four 16-bit fields.  The `UDPHeader` structure
exposes these as the four following properties:

- `sport`: source port as `UInt16`
- `dport`: destination port as `UInt16`
- `length`: UDP length as `UInt16`
- `checksum`: UDP checksum as `UInt16`

`UDPHeader` instances can be constructed using one of these constructors:

```julia
UDPHeader(sport, dport, length=8, checksum=0)

UDPHeader(;
    sport,
    dport,
    length=8,
    checksum=0
)
```

The UDP checksum calculation uses not only the UDP header values but also other
values outside the header.  This means that unlike the `IPv4Header` constructor
the `UDPHeader` constructor cannot calculate the UDP checksum value.

[UDP]: https://en.wikipedia.org/wiki/User_Datagram_Protocol
[UDP headers]: https://en.wikipedia.org/wiki/User_Datagram_Protocol#UDP_datagram_structure

## Reading/writing headers

### Reading/writing

All `AbstractNetworkHeader` types support reading and writing from an `IO`
stream (including `IOBuffer`).  Here is a trivial example using `IPv4Header`:

```repl-julia
julia> ip = IPv4Header()
IPv4Header(sip=0.0.0.0, dip=0.0.0.0, length=0x0014, proto=IPPROTO_UDP)

julia> io=IOBuffer();

julia> write(io, ip);

julia> seekstart(io);

julia> read(io, IPv4Header)
IPv4Header(sip=0.0.0.0, dip=0.0.0.0, length=0x0014, proto=IPPROTO_UDP)
```

### Reading packet headers

The `NetworkHeaders.read_headers` function will read network headers from an
`IO` starting with an `AbstractEthernetHeader` (either `EthernetHeader` or
`EthernetVlanHeader`, as appropriate).  If the Ethernet header's `ethtype` field
is `ETH_P_IP`, it will also read an `IPv4Header` from the `IO`.  If the IP
header's `protocol` field is a supported protocol (currently `IPPROTO_ICMP` or
`IPPROTO_UDP`), the corresponding header type will also be read from the `IO`.
The return value is a `NamedTuple` of all the headers that were read.  The keys
of the `NamedTuple` may include, in order, `ethernet`, `ipv4`, and `udp` or
`icmp` depending on the data.  If an unsupported `ethtype` or `protocol` value
is encountered the reading will terminate. The `IO` is left positioned at the
first location not consumed.

## Protocol specific constants

`NetworkHeaders.jl` provides some protocol specific constants for use with
`EthernetHeader`, `IPv4Header`, and `ICMPHeader` (no constants for `UDPHeader`).
To pull in all constants for a given header type, use one of the following:

```julia
using NetworkHeaders
using NetworkHeaders.EthernetConstants
using NetworkHeaders.IPv4Constants
using NetworkHeaders.ICMPConstants
```

To pull in specific constants, use `import` instead of `using` and then specify
the desired constant(s).  For example:

```julia
using NetworkHeaders
import NetworkHeaders.EthernetConstants: ETH_P_IP
import NetworkHeaders.IPv4Constants: IPPROTO_ICMP, IPPROTO_UDP
import NetworkHeaders.ICMPConstants: ICMP_ECHO, ICMP_ECHOREPLY
```

These constants are defined as Julia `Enum` types.  The specific `Enum` type can
be used to convert suitable `Integers` to an instance of the `Enum` type.  The
`Enum` types automatically display as their name rather than their integer value
which can be more informative to the reader.  Here is a table summarizing the
`Enum` types available for each protocol:

| Protocol | `Enum` type             | Description                                 |
|:--------:|-------------------------|---------------------------------------------|
| Ethernet | `EtherType`             | Values for `EthernetHeader` `ethtype` field |
| IPv4     | `IPProtocol`            | Values for `IPv4Header` `protocol` field    |
| ICMP     | `ICMPType`              | Values for `ICMPHeader` `type` field        |
| ICMP     | `ICMPDestUnreachCode`   | ICMP codes for `ICMP_DEST_UNREACH` type     |
| ICMP     | `ICMPRedirectCode`      | ICMP codes for `ICMP_REDIRECT` type         |
| ICMP     | `ICMPParameterprobCode` | ICMP codes for `ICMP_PARAMETERPROB` type    |
| ICMP     | `ICMPTimeExceededCode`  | ICMP codes for `ICMP_TIME_EXCEEDED` type    |

## Hexdump utility

`NetworkHeaders.jl` has a simple and inflexible hexdump function that can be
used to display header objects in a hexadecimal dump format similar to the
`hexdump` utility.  For more fully featured and flexible `hexdump`
functionality, consider using `hexdump` from the [`BasedDumps.jl`][] package.

[`BasedDumps.jl`]: https://github.com/wherrera10/BasedDumps.jl

## [`StructArrays`] extension

`NetworkHeaders.jl` provides an extension that allows a `StructArray` to be
created from an `Array{T<:AbstractNetworkHeader}` when both the `NetworkHeaders`
and `StructArrays` packages are loaded.  This creates a copy of the input data.
The `StructArray` will be "detached" from the input `Array` (i.e. changes to the
input `Array` will not be reflected in the `StructArray` and vice versa).

[`StructArrays`]: https://juliaarrays.github.io/StructArrays.jl/stable/

### Example

```julia
julia> udps = UDPHeader.(rand(UInt16, 4), rand(UInt16, 4), rand(UInt16, 4), rand(UInt16, 4));

julia> hsa = StructArray(udps)
4-element StructArray(::Vector{UInt16}, ::Vector{UInt16}, ::Vector{UInt16}, ::Vector{UInt16}) with eltype UDPHeader:
 UDPHeader(sport=16477, dport=50206, length=34380)
 UDPHeader(sport=23905, dport=43664, length=14348)
 UDPHeader(sport=64686, dport=60442, length=52405)
 UDPHeader(sport=41834, dport=43640, length=25421)

julia> hsa.sport
4-element Vector{UInt16}:
 0x405d
 0x5d61
 0xfcae
 0xa36a
```

## Pointer-friendly

### 🚧 Under construction 🚧

`NetworkHeaders.jl` also provides methods that make it convenient to work with
pointers to network header structures defined in this package.  The use of
pointers can be "unsafe" (i.e. misuse can lead to crashes), but also extremely
performant.  `NetworkHeaders.jl` strives to balance safety with performance and
convenience.  Some, but not all, of the methods defined on `Ptr{T}` or
`Ptr{Ptr{T}}`, where `T` is a network header structure defined by
`NetworkHeaders.jl`, are "unsafe" but do not have `unsafe` in their name.  It is
important to be cognizant of this fact when using a pointer to a network header
structure (or a pointer to such a pointer).
