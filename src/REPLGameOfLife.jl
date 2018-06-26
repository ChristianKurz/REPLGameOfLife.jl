__precompile__()
module REPLGameOfLife

using Compat
export gol, gameoflife

include("../Terminal.jl/Terminal.jl")
using .Terminal

include("braille_hd.jl")
include("presets.jl")

function next_gen!(board::Array{Int,2}, survive::Vector{Int}, birth::Vector{Int})
    newboard = copy(board)
    dx, dy = size(board)
    for i in 1:dx, j in 1:dy
        live_cells = live_neighbors(board, i, j)
        if board[i,j] == 0
            live_cells ∈ birth && (newboard[i,j] = 1)
        else
            live_cells ∈ survive ? (newboard[i,j] += 1) : (newboard[i,j] = 0)
        end
    end
    board[:,:] = newboard
end

function live_neighbors(board, i, j)
    dy, dx = size(board)
    wrap(idx,range,size) = (idx + range + size - 1) % size + 1
    sum(board[wrap.(i, -1:1, dy), wrap.(j, -1:1, dx)] .> 0) - (board[i,j] > 0)
end

function gol(board = rand([1,0,0,0,0,0,0,0,0,0,0], 80, 80); pause=0.1, survive=[2,3], birth=[3])
    rawmode() do
        abort=[false]
        clear_screen()
        update_board!(arr2braille(zeros(board)), arr2braille(board))
        sleep(pause)
        generation = 0
        @async while !abort[1]
            clear_screen()
            old = copy(board)
            next_gen!(board, survive, birth)
            generation += 1
            update_board!(arr2braille(old), arr2braille(board))
            sleep(pause)
        end
        while !abort[1]
            c = readKey()
            c in ["Ctrl-C"]     && (abort[1]=true)
        end
    end
end

function gol(preset::Preset, size, args...; kwargs...)
    x, y = Int.(floor.(size ./2))
    dy, dx = preset.size .- 1
    board = zeros(Int, (2y,2x))
    board[y:y+dy, x:x+dx] = preset.data
    gol(board, args...; kwargs...)
end

gameoflife(args...; kwargs...) = gol(args...; kwargs...)

end # module
