local pb = {
    [119587547774646] = true,-- gym
    [118669925076970] = true, -- park
    [104645279125178] = true, -- rec
    [138505112166361] = true, -- blacktop
    [115776365257536] = true, -- plaza
    [80681221431821] = true, -- main menu
    [0] = true, -- league
    [78438427735992] = true, -- blacktop mm
    [79672855812610] = true -- rec mm
}

if game.PlaceId == 9847297509 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/sh5sui/tickrate.wip/refs/heads/main/games/mmp.lua"))()
elseif game.PlaceId == 106371606720521 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/sh5sui/tickrate.wip/refs/heads/main/games/vef.lua"))()
elseif pb[game.PlaceId] then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/sh5sui/tickrate.wip/refs/heads/main/games/pb.lua"))()
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/sh5sui/tickrate.wip/refs/heads/main/games/universal.lua"))()
end