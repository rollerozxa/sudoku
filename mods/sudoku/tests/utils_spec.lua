
dofile('utils.lua')

describe("string splitter of doom", function()
	it("works", function()
		local test = "1234\n2345\n3456\n4567"
		local output = {
			{'1','2','3','4'},
			{'2','3','4','5'},
			{'3','4','5','6'},
			{'4','5','6','7'}}

		for i = 1, 10000, 1 do
			assert.same(string_splitter_of_doom(test), output)
		end

	end)
end)

describe("repeats", function()
	it("works", function()
		assert.same(repeats("amanda", "a"), 3)
	end)
end)

describe("itemstring to number", function()
	it("works", function()
		assert.same(itemstring_to_number('sudoku:n_3'), 3)
		assert.same(itemstring_to_number('sudoku:3'), 3)

		assert.same(itemstring_to_number('lolmod:amanda_block'), 0)
	end)
end)
