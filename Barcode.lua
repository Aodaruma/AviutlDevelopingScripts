--[[
�Z�֐��̌`��
������number��string�Ȃǂ̃f�[�^�����͂���܂��B���O�ɂ͔��肳��Ȃ����߁A�֐����Ŕ��f���K�v�ł��B
�Ԃ�l�̓e�[�u���ŕԂ���܂��B�e�[�u���̒��g�͂��Ȃ炸success�L�[�������Ă��܂��B
���������{success=true,data="12341234"}
�ƁAdata�L�[��p����string�f�[�^���n����܂��B
�s���Ȉ����ȂǁA�G���[������΁A{success=false,message="�s���Ȉ������n����܂���:"}
�Ȃǂ�message�L�[��p���ă��b�Z�[�W���Ԃ���܂��B

�Ԃ����data�́A�ꕔ��������string�ŁA1,2,3,4��4�̐����ŕԂ���܂��B
����́A�o�[�ƃX�y�[�X���\�������蕝�̒P�ʗv�f���W���[������A���{�ł��邩����͂ł���悤�ɂ��邽�߂ł��B
�Ȃ��A�X�փo�[�R�[�h�Ȃǂ̃J�X�^�}�o�[�R�[�h�ł́A���̂P�����o�[�R�[�h�Ǝd�l���Ⴄ���߁A���ӂ��K�v�ł��B
�i�ڍׂ͗X�փo�[�R�[�h�ł̃R�����g�Q�Ɓj
�܂��AGS1 DataBar�ł́A1,2,3,4,5,6,7,8��8�̐����ŕԂ���܂��B
�i�ڍׂ�GS1 DataBar�ł̃R�����g�Q�Ɓj

�o�[�R�[�h�̊�{�I�ȍ\���ɂ��ẮA�ȉ����Q�Ƃ��������B
https://www.keyence.co.jp/ss/products/autoid/codereader/basic_mechanism.jsp

- Aodaruma (@Aodaruma_)
]] --
--[[
EAN�R�[�h/JAN�R�[�h
�Q��:
- https://ja.wikipedia.org/wiki/EAN�R�[�h
- https://www.barcode.ne.jp/barcode/291.html
- https://www.keyence.co.jp/ss/products/autoid/codereader/basic-ean.jsp

input: 12���̐���������A�܂��́A7���̐���������@([0-9]*12 or [0-9]*7)
output: 4*13 �܂��� 4*8 ��1-8�̃f�[�^ ([1-8]*13 or [1-8]*8)

input�ɂāA������ł͂Ȃ��A�܂��́A�����ł͂Ȃ�������A�܂��́A12���܂���7���ł͂Ȃ����������񂪓��͂��ꂽ�ꍇ�Aerror��Ԃ��܂��B

- developed by Aodaruma(@Aodaruma_)
]]
local function JAN(data)
    -- =================================
    -- �f�[�^����
    -- =================================

    -- ��p���e�B
    local odd_parity = {
        "0001101",
        "0011001",
        "0010011",
        "0111101",
        "0100011",
        "0110001",
        "0101111",
        "0111011",
        "0110111",
        "0001011"
    }

    -- �����f�[�^�L�����N�^�ɂ���������p���e�B
    local left_even_parity = {
        "0100111",
        "0110011",
        "0011011",
        "0100001",
        "0011101",
        "0111001",
        "0000101",
        "0010001",
        "0001001",
        "0010111"
    }

    -- �E���f�[�^�L�����N�^�ɂ���������p���e�B�A����у��W�����`�F�b�N�L�����N�^�̃p���e�B
    local right_even_parity = {
        "1110010",
        "1100110",
        "1101100",
        "1000010",
        "1011100",
        "1001110",
        "1010000",
        "1000100",
        "1001000",
        "1110100"
    }

    -- �v���t�B�b�N�X�L�����N�^�ɂ��p���e�B�̑g�ݍ��킹
    local parity_combination = {
        "000000",
        "001011",
        "001101",
        "001110",
        "010011",
        "011001",
        "011100",
        "010101",
        "010110",
        "011010"
    }

    -- for v in pairs(right_even_parity) do
    --     for c in v:gmatch "." do
    --         c = tonumber(c)
    --         c = c+4
    --         c
    --     end
    -- end

    -- ================================= --
    -- �f�[�^�`�F�b�N
    -- ================================= --
    if type(data) ~= "string" then
        return {
            success = false,
            message = "�s���ȃf�[�^�^�ł��Bstring�œ��͂��Ă��������B"
        }
    end

    if not data:find("^[0-9]+$") then
        return {
            success = false,
            message = "0-9�̐����݂̂ō\�����ꂽ���������͂��Ă��������B"
        }
    end

    if #data ~= 12 and #data ~= 7 then
        return {
            success = false,
            message = "12���A�܂���7���̐����̕��������͂��Ă��������B"
        }
    end

    -- ================================= --
    -- �R�[�h�ϊ�
    -- ================================= --

    -- add a check charactor to data
    local odd, even = 0, 0
    for i = 1, #data do
        local c = data:sub(i, i)
        if i % 2 == 0 then
            even = even + tonumber(c)
        else
            odd = odd + tonumber(c)
        end
    end
    local sum = even + odd * 3
    local checksum = (10 - sum % 10) % 10
    data = data .. checksum

    -- converting
    local bars = ""
    if #data == 13 then -- 13���̏ꍇ
        local dataL, dataR = data:sub(2, 7), data:sub(8, 14)

        -- left data charactor
        local Lcombi = parity_combination[tonumber(dataL:sub(1, 1)) + 1]
        for i = 1, #Lcombi do
            local c = Lcombi:sub(i, i)
            if c == "0" then
                bars = bars .. odd_parity[tonumber(dataL:sub(i, i)) + 1]
            else
                bars = bars .. left_even_parity[tonumber(dataL:sub(i, i)) + 1]
            end
        end

        -- right data charactor
        local Rcombi = parity_combination[tonumber(dataR:sub(1, 1)) + 1]
        for i = 1, #Rcombi - 1 do
            local c = Rcombi:sub(i, i)
            if c == "0" then
                bars = bars .. odd_parity[tonumber(dataR:sub(i, i)) + 1]
            else
                bars = bars .. right_even_parity[tonumber(dataR:sub(i, i)) + 1]
            end
        end
        bars = bars .. right_even_parity[tonumber(dataR:sub(#Rcombi, #Rcombi)) + 1]

        if #bars ~= 7 * 6 * 2 then
            return {
                success = false,
                message = "���W���[���̑����������܂���B�f�[�^�̋L�^���ԈႦ�Ă���\��������܂��B\nexpected: " .. (7 * 6 * 2) .. ", sum: " .. sum .. ";"
            }
        end
    elseif #data == 8 then -- 8���̏ꍇ
    end

    return {
        success = true,
        bars = bars,
        datalen = #data
    }
end

local function ITF()
    -- body
end

local function CODE39()
    -- body
end

local function CODE128()
end

local function NW7()
end

local function GS1_128()
end

local function UPC()
end

local function Customer()
end

return {
    JAN = JAN
}
