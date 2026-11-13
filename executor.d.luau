-- Console functions
declare function rconsolecreate(): ()
declare function rconsoleprint(message: string): ()
declare function rconsoleinput(): string
declare function rconsoleclear(): ()
declare function rconsolesettitle(title: string): ()
declare function rconsoledestroy(): ()

-- Environment
declare function getgenv(): {[string]: any}
declare function getrenv(): {[string]: any}

-- File functions
declare function readfile(path: string): string
declare function writefile(path: string, content: string): ()
declare function appendfile(path: string, content: string): ()
declare function isfile(path: string): boolean
declare function isfolder(path: string): boolean
declare function makefolder(path: string): ()
declare function delfile(path: string): ()
declare function delfolder(path: string): ()

-- Hook functions
declare function hookfunction(old: (...any) -> any, new: (...any) -> any): (...any) -> any
declare function restorefunction(func: (...any) -> any): ()