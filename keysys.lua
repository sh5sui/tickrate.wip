local name, version = identifyexecutor()
local frames = { "|", "/", "-", "\\" }

rconsolecreate()
rconsolesettitle("subtick.fun")

if name ~= "Potassium" then
    rconsoleprint("\27[38;2;255;160;160m[-] Executor not supported.\27[0m\n")
    task.wait(3)
    rconsoledestroy()
    return
end

rconsoleclear()
rconsoleprint("\27[38;2;173;216;230m[-] Welcome to subtick.fun\27[0m\n")
rconsoleprint("\27[38;2;173;216;230m[-] Enter your key: \27[0m")

local key = rconsoleinput()

if key == "f" then
    rconsoleprint("\27[38;2;152;251;152m[+] Success!\27[0m\n")
    for i = 1, 12 do
        rconsoleprint("\27[38;2;173;216;230m[+] Loading " .. frames[(i - 1) % 4 + 1] .. "\27[0m\r")
        task.wait(0.15)
    end
    local success, err = pcall(function()
        local src = game:HttpGet("https://raw.githubusercontent.com/sh5sui/subtick.fun/main/loader.lua") 
        local func = loadstring(src)

        assert(func, "Failed due to compilation error")
        func()
    end)
    if not success then
        rconsoleprint("\27[38;2;255;160;160m[-] Loader error: " .. tostring(err) .. "\27[0m\n")
        task.wait(3)
    end
    rconsoledestroy()
    return
else
    rconsoleprint("\27[38;2;255;160;160m[-] Incorrect key.\27[0m\n")
    task.wait(3)
    rconsoledestroy()
    return
end