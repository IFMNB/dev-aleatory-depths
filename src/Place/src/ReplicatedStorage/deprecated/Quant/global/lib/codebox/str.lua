--!strict

local private = {}


private.c = {}
private.c.num = {
	[1] = "0",
	[2] = "1",
	[3] = "2",
	[4] = "3",
	[5] = "4",
	[6] = "5",
	[7] = "6",
	[8] = "7",
	[9] = "8",
	[10] = "9"
}
private.c.spec ={
	[1] = " ",
	[2] = "!",
	[3] = '"',
	[4] = "#",
	[5] = "$",
	[6] = "%",
	[7] = "&",
	[8] = "'",
	[9] = "(",
	[10] = ")",
	[11] = "*",
	[12] = "+",
	[13] = ",",
	[14] = "-",
	[15] = ".",
	[16] = "/",
	[17] = ":",
	[18] = ";",
	[19] = "<",
	[20] = "=",
	[21] = ">",
	[22] = "?",
	[23] = "@",
	[24] = "[",
	[25] = [[\]],
	[26] = "]",
	[27] = "^",
	[28] = "_",
	[29] = "`",
	[30] = "{",
	[31] = "|",
	[32] = "}",
	[33] = "~"
}
private.c.low = {
	[1] = "a",
	[2] = "b",
	[3] = "c",
	[4] = "d",
	[5] = "e",
	[6] = "f",
	[7] = "g",
	[8] = "h",
	[9] = "i",
	[10] = "j",
	[11] = "k",
	[12] = "l",
	[13] = "m",
	[14] = "n",
	[15] = "o",
	[16] = "p",
	[17] = "q",
	[18] = "r",
	[19] = "s",
	[20] = "t",
	[21] = "u",
	[22] = "v",
	[23] = "w",
	[24] = "x",
	[25] = "y",
	[26] = "z"
}
private.c.upp = {
	[1] = "A",
	[2] = "B",
	[3] = "C",
	[4] = "D",
	[5] = "E",
	[6] = "F",
	[7] = "G",
	[8] = "H",
	[9] = "I",
	[10] = "J",
	[11] = "K",
	[12] = "L",
	[13] = "M",
	[14] = "N",
	[15] = "O",
	[16] = "P",
	[17] = "Q",
	[18] = "R",
	[19] = "S",
	[20] = "T",
	[21] = "U",
	[22] = "V",
	[23] = "W",
	[24] = "X",
	[25] = "Y",
	[26] = "Z"
}
private.c.let = {
	[1] = "a",
	[2] = "b",
	[3] = "c",
	[4] = "d",
	[5] = "e",
	[6] = "f",
	[7] = "g",
	[8] = "h",
	[9] = "i",
	[10] = "j",
	[11] = "k",
	[12] = "l",
	[13] = "m",
	[14] = "n",
	[15] = "o",
	[16] = "p",
	[17] = "q",
	[18] = "r",
	[19] = "s",
	[20] = "t",
	[21] = "u",
	[22] = "v",
	[23] = "w",
	[24] = "x",
	[25] = "y",
	[26] = "z",
	[27] = "A",
	[28] = "B",
	[29] = "C",
	[30] = "D",
	[31] = "E",
	[32] = "F",
	[33] = "G",
	[34] = "H",
	[35] = "I",
	[36] = "J",
	[37] = "K",
	[38] = "L",
	[39] = "M",
	[40] = "N",
	[41] = "O",
	[42] = "P",
	[43] = "Q",
	[44] = "R",
	[45] = "S",
	[46] = "T",
	[47] = "U",
	[48] = "V",
	[49] = "W",
	[50] = "X",
	[51] = "Y",
	[52] = "Z"
}
private.c.all = {
	[1] = "a",
	[2] = "b",
	[3] = "c",
	[4] = "d",
	[5] = "e",
	[6] = "f",
	[7] = "g",
	[8] = "h",
	[9] = "i",
	[10] = "j",
	[11] = "k",
	[12] = "l",
	[13] = "m",
	[14] = "n",
	[15] = "o",
	[16] = "p",
	[17] = "q",
	[18] = "r",
	[19] = "s",
	[20] = "t",
	[21] = "u",
	[22] = "v",
	[23] = "w",
	[24] = "x",
	[25] = "y",
	[26] = "z",
	[27] = "A",
	[28] = "B",
	[29] = "C",
	[30] = "D",
	[31] = "E",
	[32] = "F",
	[33] = "G",
	[34] = "H",
	[35] = "I",
	[36] = "J",
	[37] = "K",
	[38] = "L",
	[39] = "M",
	[40] = "N",
	[41] = "O",
	[42] = "P",
	[43] = "Q",
	[44] = "R",
	[45] = "S",
	[46] = "T",
	[47] = "U",
	[48] = "V",
	[49] = "W",
	[50] = "X",
	[51] = "Y",
	[52] = "Z",
	[53] = " ",
	[54] = "!",
	[55] = '"',
	[56] = "#",
	[57] = "$",
	[58] = "%",
	[59] = "&",
	[60] = "'",
	[61] = "(",
	[62] = ")",
	[63] = "*",
	[64] = "+",
	[65] = ",",
	[66] = "-",
	[67] = ".",
	[68] = "/",
	[69] = ":",
	[70] = ";",
	[71] = "<",
	[72] = "=",
	[73] = ">",
	[74] = "?",
	[75] = "@",
	[76] = "[",
	[77] = [[\]],
	[78] = "]",
	[79] = "^",
	[80] = "_",
	[81] = "`",
	[82] = "{",
	[83] = "|",
	[84] = "}",
	[85] = "~",
	[86] = "0",
	[87] = "1",
	[88] = "2",
	[89] = "3",
	[90] = "4",
	[91] = "5",
	[92] = "6",
	[93] = "7",
	[94] = "8",
	[95] = "9"
}

private.mt = {}
private.mt.spec = {__index=private.c.spec}
private.mt.num = {__index=private.c.num}
private.mt.low = {__index=private.c.low}
private.mt.upp = {__index=private.c.upp}
private.mt.let = {__index=private.c.let}
private.mt.all = {__index=private.c.all}
-- Returns all ASCII numbers in array as a proxy.
function private.getnumstr ()
	--local r = {}
	--for i= 48, 57 do table.insert(r,string.char(i)) end
	--return r
	return setmetatable({}, private.mt.num)
end
-- Returns all ASCII special characters in array as a proxy.
function private.getspecstr ()
--	local r = {}

--	for i= 32, 47 do table.insert(r, string.char(i)) end
--	for i= 58, 64 do table.insert(r, string.char(i)) end
--	for i= 91, 96 do table.insert(r, string.char(i)) end
--	for i= 123, 126 do table.insert(r, string.char(i)) end

--	return r

	return setmetatable({}, private.mt.spec)
end
-- Returns all ASCII lowercase letters in array as a proxy.
function private.getlower ()
	--local r = {}
	--for i = 97, 122 do table.insert(r, string.char(i)) end
	--return r
	return setmetatable({}, private.mt.low)
end
-- Returns all ASCII uppercase letters in array as a proxy.
function private.getupper ()
	--local r = {}
	--for i = 65, 90 do table.insert(r, string.char(i)) end
	--return r
	return setmetatable({}, private.mt.upp)
end
-- Returns all ASCII letters in array as a proxy.
function private.getletters ()
	--local l = private.getlower()
	--local u = private.getupper()

	--table.move(u,1,#u,#l+1,l)

	--return l
	return setmetatable({}, private.mt.let)
end
-- Returns all ASCII characters in array as a proxy.
function private.getall ()
	--local l = private.getletters()
	--local sp = private.getspecstr()
	--local nm = private.getnumstr()

	--table.move(sp,1,#sp,#l+1,l)
	--table.move(nm,1,#nm,#l+1,l)

	--return l
	return setmetatable({}, private.mt.all)
end

-- Returns true if string is ASCII as a proxy.
function private.isascii (self: string)
	for i = 1, #self do
		if string.byte(self, i) >= 128 then
			return false
		end
	end

	return true
end
-- Returns a array of all ASCII numbers in a string.
function private.CloneNums ()
	return table.clone(private.c.num)
end
-- Returns a array of all ASCII special characters in a string.
function private.CloneSpecs ()
	return table.clone(private.c.spec)
end
-- Returns a array of all ASCII lowercase letters in a string.
function private.CloneLows ()
	return table.clone(private.c.low)
end
-- Returns a array of all ASCII uppercase letters in a string.
function private.CloneUpps ()
	return table.clone(private.c.upp)
end
-- Returns a array of all ASCII letters in a string.
function private.CloneLetters ()
	return table.clone(private.c.let)
end
-- Returns a array of all ASCII characters in a string.
function private.CloneAll ()
	return table.clone(private.c.all)
end



local public = {}

public.IsASCII = private.isascii
public.GetStringNums = private.getnumstr
public.GetStringSpecs = private.getspecstr
public.GetLowerLetters = private.getlower
public.GetUpperLetters = private.getupper
public.GetLetters = private.getletters
public.GetAllChars = private.getall
public.GetCloneStringNums = private.CloneNums
public.GetCloneSpecs = private.CloneSpecs
public.GetCloneLowerLetters = private.CloneLows
public.GetCloneUpperLetters = private.CloneUpps
public.GetCloneLetters = private.CloneLetters
public.GetCloneAllChars = private.CloneAll
table.freeze(public)
table.freeze(private)

return public