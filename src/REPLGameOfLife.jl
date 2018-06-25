__precompile__()
module REPLGameOfLife

using Compat
export gol, gameoflife
export Glider, BHeptomino

include("../Terminal.jl/Terminal.jl")
using .Terminal

include("braille_hd.jl")
include("presets.jl")

function next_gen!(board::Array{Int,2}, survive=[2,3], birth=[3])
    newboard = copy(board)
    dx, dy = size(board)
    for i in 1:dx
        for j in 1:dy
            live_cells = live_neighbors(board, i, j)
            board[i,j] == 1 &&  live_cells ∉ survive && (newboard[i,j] = 0)
            board[i,j] == 0 &&  live_cells ∈ birth   && (newboard[i,j] = 1)
        end
    end
    board[:,:] = newboard
end

function live_neighbors(board, i, j)
    dy, dx = size(board)
    wrap_idx(i,di,s) = (i+di+s-1)%s+1
    return sum(board[wrap_idx.(i, -1:1, dy), wrap_idx.(j, -1:1, dx)]) - board[i,j]
end

function gol(board = rand([1,0,0,0,0,0,0,0,0,0,0], 80, 80); pause=0.5)
    rawmode() do
        abort=[false]
        clear_screen()
        update_board!(arr2braille(zeros(board)), arr2braille(board))
        sleep(pause)
        i = 0
        @async while !abort[1]
            clear_screen()
            old = copy(board)
            next_gen!(board)
            i += 1
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
