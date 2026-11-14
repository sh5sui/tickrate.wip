local name, version = identifyexecutor()
local frames = { "|", "/", "-", "\\" }

rconsolecreate()
rconsolesettitle("tickrate.wip")

if name ~= "Potassium" then
    rconsoleprint("\27[38;2;255;160;160m[-] Executor not supported.\27[0m\n")
    task.wait(3)
    rconsoledestroy()
    return
end

rconsoleclear()
rconsoleprint("\27[38;2;233;160;202m[+] tickrate.wip\27[0m\n")
rconsoleprint("\27[38;2;244;241;245m[*] Executor: " .. name .. "\27[0m\n")
rconsoleprint("\27[38;2;244;241;245m[*] Version: 1.00\27[0m\n")
rconsoleprint("\27[38;2;233;160;202m[?] Enter key: \27[0m")

local key = rconsoleinput()

if key == "f" then
    rconsoleprint("\27[38;2;233;160;202m[+] Authenticated.\27[0m\n")
    for i = 1, 12 do
        rconsoleprint("\27[38;2;233;160;202m[+] Loading " .. frames[(i - 1) % 4 + 1] .. "\27[0m\r")
        task.wait(0.15)
    end
    rconsoleprint("\n")
    local success, err = pcall(function()
        local src = game:HttpGet("https://raw.githubusercontent.com/sh5sui/subtick.fun/main/loader.lua") 
        local func = loadstring(src)

        assert(func, "Failed due to compilation error")
        func()
    end)
    if not success then
        rconsoleprint("\27[38;2;217;142;187m[-] Loader error: " .. tostring(err) .. "\27[0m\n")
        task.wait(3)
    end
    rconsoledestroy()
    return
else
    rconsoleprint("\27[38;2;217;142;187m[-] Incorrect key.\27[0m\n")
    task.wait(3)
    rconsoledestroy()
    return
end