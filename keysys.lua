rconsolecreate()
rconsolesettitle("subtick.fun")

rconsoleclear()
rconsoleprint("\27[38;2;173;216;230m[-] Welcome to subtick.fun\27[0m\n")
rconsoleprint("\27[38;2;173;216;230m[-] Enter your key: \27[0m")

local key = rconsoleinput()

if key == "Admin" then
    rconsoleprint("\27[38;2;152;251;152m[+] Success!\27[0m\n")
    rconsoleprint("\27[38;2;173;216;230m[+] Loading script...\27[0m")
    task.wait(3)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/sh5sui/subtick.fun/refs/heads/main/loader.lua?token=GHSAT0AAAAAAELXDMD3KWXJL5HKHKEI6WXQ2XXGAVQ"))()
    rconsoledestroy()

else
    rconsoleprint("\27[38;2;255;160;160m[-] Incorrect key.\27[0m\n")
    task.wait(3)
    rconsoledestroy()
end