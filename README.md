# Frigate

Network Processing/API Library for Roblox. Provides many utilites for creating/managing game network objects and also helps with parsing external 3rd-party API's.

Some features include:

- NeoShift/Technified API Parsing
- Network Object Management (Remotes/Functions etc.)

> [!WARNING]
> Frigate is heavily WIP. Expect some bugs and or instabilites when using Frigate. Some Documentation may also be unfinished/not implemented yet!

## Get Started

To quickly start:

- Drop the Frigate.rbxmx into your game and parent it under ReplicatedStorage for client/server access.

> [!WARNING]
> The Frigate.rbxmx file is a build artifact that may not be always up to date. You are heavily advised to build the project manually.

---

To build the project manually:

- Have a IDE such as VScode and ensure that the Argon extension (Dervex.argon) is installed.
- Open the Argon menu with CTRL+P > "Argon: Open Menu" or use the button near the bottom-left of your screen.
- Build > default.project.json > Frigate > All settings except "Use XML Format" unchecked > OK
- A Frigate.rbxmx file will appear, drop it into your game and parent it under ReplicatedStorage for client/server access.

## Using the Library

Some examples of the library:

```lua
local Net = require(game.ReplicatedStorage.Frigate.FrigateSrc).Net

local success, data = Net.CreateNetworkUnitAsync("AUnit"):await()

if success then
    Net.CreateRemote("AUnit", "CoolRemote")
end
```

---

```lua
local NeoShift = require(game.ReplicatedStorage.Frigate.FrigateSrc).WebAPIs.NeoShift

local YourUserAuth = game.HttpService:GetSecret("MyLocalAuth")

print(NeoShift.Volatile.V1_Me(YourUserAuth))
```

## Credits/Licensing

Frigate is licensed under Apache-2.0. A copy of the license is provided under the FrigateSrc file.

---

Frigate additionally uses 3rd party packages such as:

- LemonSignal by Data Oriented House
- Promise by Evaera

Their licenses may be viewed under the Packages folder.

---
