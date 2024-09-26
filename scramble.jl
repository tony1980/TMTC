# 定义常量，表示序列重复的周期
const PRBS_PERIOD = 255

# 定义伪随机序列生成器
# seed: 初始种子值，用于生成序列
# n: 需要生成的序列长度
function prbs_generator(seed::UInt8, n::Int)
    poly = 0x67  # 定义多项式，二进制表示为 0b11000111
    prbs = UInt8[]  # 初始化序列数组

    # 循环生成序列，直到达到所需的长度
    while length(prbs) < n
        register = seed
        for _ in 1:PRBS_PERIOD  # 每PRBS_PERIOD位重复一次
            push!(prbs, register)
            output = register & 1
            register = register >>> 1
            if output != (register & 1)
                register = register ⊻ poly
            end
        end
    end

    return prbs[1:n]  # 返回所需的序列部分
end

# 加扰函数
# data: 需要加扰的数据，类型为 UInt8 的数组
# seed: 初始种子值
function scramble(data::Vector{UInt8}, seed::UInt8)
    bit_length = length(data) * 8  # 计算数据的总位数
    prbs = prbs_generator(seed, bit_length)  # 生成伪随机序列
    scrambled = similar(data)  # 创建相同大小的数组用于存储加扰后的数据

    # 对数据进行加扰处理
    for i in 1:length(data)
        scrambled[i] = data[i] ⊻ prbs[i]
    end
    scrambled
end

# 解扰函数
# scrambled_data: 需要解扰的数据，类型为 UInt8 的数组
# seed: 初始种子值
function descramble(scrambled_data::Vector{UInt8}, seed::UInt8)
    bit_length = length(scrambled_data) * 8  # 计算数据的总位数
    prbs = prbs_generator(seed, bit_length)  # 生成伪随机序列
    descrambled = similar(scrambled_data)  # 创建相同大小的数组用于存储解扰后的数据

    # 对数据进行解扰处理
    for i in 1:length(scrambled_data)
        descrambled[i] = scrambled_data[i] ⊻ prbs[i]
    end
    descrambled
end
