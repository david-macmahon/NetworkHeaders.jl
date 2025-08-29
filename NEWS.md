# NEWS

## Changes in v0.2.1

* Export `@ip_str` and `IPv4` from `Sockets`

## Changes in v0.2.0

* Cleanup output of show(::ICMPHeader)
* Add hexdump to String capability
* Add ICMPHeader "copy constructor" with overrides
* Tweak ICMPHeader doc string
* Improve MAC/String interop, add mac2mac, deprecate string2mac

## Changes in v0.1.0

* Add `bytes` property for compound headers
* Add more IPv4Header tests
* Add compound header tests
* Fix zeros problem (eltype has no known size)
