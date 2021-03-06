# MIT License
#
# Copyright (c) 2020 Joshua E Gentry

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
using Blake3Hash

@testset "Hash - standard" begin
    @testset "Length: ($(test["input_len"]))" for test in CASES
        local case = Case(test)

        local hasher = Blake3Hash.Simd128.Blake3Ctx()
        local result = Vector{UInt8}(undef, length(case.hash))

        Blake3Hash.Simd128.update!(hasher, case.input)
        Blake3Hash.Simd128.digest(hasher, result)

        @test case.hash == result
    end
end

@testset "Hash - keyed" begin
    @testset "Length: ($(test["input_len"]))" for test in CASES
        local case = Case(test)

        local hasher = Blake3Hash.Simd128.Blake3Ctx(KEY)
        local result = Vector{UInt8}(undef, length(case.hash))

        Blake3Hash.Simd128.update!(hasher, case.input)
        Blake3Hash.Simd128.digest(hasher, result)

        @test case.keyed == result
    end
end


@testset "Hash - derive" begin
    @testset "Length: ($(test["input_len"]))" for test in CASES
        local case = Case(test)

        local hasher = Blake3Hash.Simd128.Blake3Ctx(CONTEXT)
        local result = Vector{UInt8}(undef, length(case.hash))

        Blake3Hash.Simd128.update!(hasher, case.input)
        Blake3Hash.Simd128.digest(hasher, result)

        @test case.derive == result
    end
end

@testset "Hash - 256" begin
    @testset "Length: ($(test["input_len"]))" for test in CASES
        local case = Case(test)

        local hasher = Blake3Hash.Simd128.Blake3Ctx()

        Blake3Hash.Simd128.update!(hasher, case.input)

        local result = Blake3Hash.Simd128.digest(hasher)

        @test case.hash[1:32] == result
    end
end

@testset "Hash - digest" begin
    @testset "Length: ($(test["input_len"]))" for test in CASES
        local case = Case(test)

        local hasher = Blake3Hash.Simd128.Blake3Ctx()
        Blake3Hash.Simd128.update!(hasher, case.input)

        @test Blake3Hash.Simd128.digest(hasher, 1) == case.hash[1:1]
        @test Blake3Hash.Simd128.digest(hasher, 2) == case.hash[1:2]
        @test Blake3Hash.Simd128.digest(hasher, 3) == case.hash[1:3]
        @test Blake3Hash.Simd128.digest(hasher, 4) == case.hash[1:4]

        @test Blake3Hash.Simd128.digest(hasher, 30) == case.hash[1:30]
        @test Blake3Hash.Simd128.digest(hasher, 31) == case.hash[1:31]
        @test Blake3Hash.Simd128.digest(hasher, 32) == case.hash[1:32]
        @test Blake3Hash.Simd128.digest(hasher, 33) == case.hash[1:33]
        @test Blake3Hash.Simd128.digest(hasher, 34) == case.hash[1:34]
    end
end

@testset "Hash - update" begin
    @testset "Length: ($(test["input_len"]))" for test in CASES
        local case = Case(test)

        local hasher = Blake3Hash.Simd128.Blake3Ctx()
        local result = Vector{UInt8}(undef, length(case.hash))

        local data = case.input

        while length(data) > 0
            local take = min(rand(1:4), length(data))
            Blake3Hash.Simd128.update!(hasher, data[1:take])
            data = data[(take+1):end]
        end

        Blake3Hash.Simd128.digest(hasher, result)

        @test case.hash == result
    end
end

@testset "Hash - stress" begin
    data   = rand(UInt8, TOTAL_SIZE)
    hasher = Blake3Hash.Simd128.Blake3Ctx()
    Blake3Hash.Simd128.update!(hasher, data)
    expected = Blake3Hash.Simd128.digest(hasher)

    for chunks in StressIter(data)
        hasher = Blake3Hash.Simd128.Blake3Ctx()

        for chunk in chunks
            Blake3Hash.Simd128.update!(hasher, chunk)
        end

        @test Blake3Hash.Simd128.digest(hasher) == expected
    end
end
