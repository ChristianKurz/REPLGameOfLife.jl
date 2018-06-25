abstract type Preset end

struct Glider <: Preset
    data::Array{Int,2}
    size::Tuple{Int,Int}
end
Glider() = Glider([
    0 1 0
    0 0 1
    1 1 1
], (3,3))

struct BHeptomino <: Preset
    data::Array{Int,2}
    size::Tuple{Int,Int}
end
BHeptomino() = BHeptomino([
    1 0 1 1
    1 1 1 0
    0 1 0 0
], (3,4))