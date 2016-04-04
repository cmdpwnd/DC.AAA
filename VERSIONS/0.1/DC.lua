term.clear()
term.setCursorPos(1,1)

local _logPath = '/log.dc'
local _dbPath = '/db.dc'
local _debug = true
local command = {}
local console_lvl = 1
local console_prompt = {"#","(config)#"}


local function dprint(str)
	if _debug == true then print('DEBUG: '..str) end
end

local function rawread()
	local input = ""
    while true do
        local sEvent, param = os.pullEvent()
        if (sEvent == 'char') then
			if (param == '?') then
				term.write(param)
				return param
			else
				term.write(param)
				input = input..param
			end
		else
			if (sEvent == 'key' and param == keys.enter) then
				local x,y = term.getCursorPos()
				term.setCursorPos(x,y+1)
				return input 
			end
        end
		if (sEvent == 'key' and param == keys.backspace) then
			local x,y = term.getCursorPos()
			if x-1 > string.len(console_prompt[console_lvl]) then
				term.setCursorPos(x-1,y)
				term.write(" ")
				term.setCursorPos(x-1,y)
			end
		end
    end
end

function command.help() 
	print('\nhelp msg') 
end

function console()
	local x,y = term.getCursorPos()
	term.setCursorPos(1,y+1)
	while true do
		dprint('console')
		term.write(console_prompt[console_lvl])
		local arg = rawread()
		dprint('finished read')
		local parse = {}
		if arg == nil or not arg then dprint('Empty string') print() else
			--separate args
			for i in string.gmatch(arg, "%S+") do parse[#parse+1] = i end
			dprint('parse = '..table.concat(parse))
			--attempt command
			for i=1,#parse+2 do
				dprint('in attempt: '..i)
				if i == #parse+1 then
					print('\n%Ambiguous Command')
					dprint('breaking')
					break
				end
				local ok, err = pcall(command.parse[1](parse[(#parse+1)-i]))
				dprint('pcall: '..tostring(ok))
				if ok then dprint('execute') command.parse[1](parse[(#parse+1)-i]) end
				dprint('looping')
			end
		end
	end
end

local function run()
	dprint('running')
	console()
end

run()