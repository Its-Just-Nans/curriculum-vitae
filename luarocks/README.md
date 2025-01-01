# curriculum-vitae - luarock

This package is available on luarocks. To install it, run:

```sh
luarocks install curriculum_vitae --local
```

## Usage

> As it is a self invoking library, lualaTeX may need the file to be in the same directory as the script that uses it.

```lua
-- export LUA_PATH="$HOME/.luarocks/share/lua/5.3/?.lua"
local libpath = package.searchpath("curriculum_vitae", package.path)
if not libpath then
    error("Failed to find the library")
end
local file = io.open(libpath, "r") -- Open file in read mode
if not file then
    error("Failed to open file")
end
local content = file:read("*a")                       -- Read the entire file
file:close()                                          -- Close the file
local lib_file = io.open("curriculum_vitae.lua", "w") -- Open file in write mode
if not lib_file then
    error("Failed to open file")
end
lib_file:write(content) -- Write the content to the file
lib_file:close()        -- Close the filen

print("Library copied to current directory")

local cv = require("curriculum_vitae")
local path_to_json = "path/to/file.json"
cv.generate_cv_from_json(path_to_json)
```
