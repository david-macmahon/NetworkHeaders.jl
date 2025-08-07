module StructArraysNetworkHeadersExt

import StructArrays: component, createinstance
using NetworkHeaders: AbstractNetworkHeader

component(h::T, key::Symbol) where {T<:AbstractNetworkHeader} = getproperty(h, key)
createinstance(::Type{T}, args...) where {T<:AbstractNetworkHeader} = T(args...)

end # module StructArraysNetworkHeadersExt
