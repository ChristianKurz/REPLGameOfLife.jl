const braille_signs = ['⠁' '⠂' '⠄' '⡀';
                              '⠈' '⠐' '⠠' '⢀']

function tobraille(a::BitArray{2})
    res = UInt16(0x2800)
    for x in 1:2, y in 1:4
        a[y, x] && (res |= UInt16(braille_signs[x,y]))
    end
    return Char(res)
end

tobraille(a::AbstractArray) = tobraille(Bool.(a))

function arr2braille(arr)
    dy1, dx1 = size(arr)
    dx = Int(ceil(dx1/2))
    dy = Int(ceil(dy1/4))
    a = zeros(Int, dy*4, dx*2)
    a[1:dy1, 1:dx1] = arr
    res = fill(Char(0x2800), (dy, dx))
    for y in 1:dy, x in 1:dx
        y1 = 1+(y-1)*4
        y2 = y1+3
        x1 = 1+(x-1)*2
        x2 = x1+1
        res[y,x] = tobraille(a[y1:y2, x1:x2])
    end
    return res
end

@compat function update_board!(old::Array{Char}, arr::Array{Char})
    buf = IOBuffer()
    for i in findall(old .!= arr)
        if VERSION < v"0.7.0-DEV.3025"
            y,x = ind2sub(size(arr), i)
        else
            y,x = Tuple(i)
        end
        put(buf, [x, y], string(arr[y,x]))
    end
    print(String(take!(buf)))
end