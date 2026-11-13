rconsolecreate()
rconsolesettitle("subtick.fun")

rconsoleclear()
rconsoleprint("[-] Welcome to subtick.fun\n")
rconsoleprint("[-] Enter your key: ")

local key = rconsoleinput()

if key == "Admin" then
    rconsoleprint("[+] Success!\n") 
    rconsoleprint("[+] Loading script...")
    
else
    rconsoleprint("[-] Incorrect key.\n")
    task.wait(3)
    rconsoledestroy()
end