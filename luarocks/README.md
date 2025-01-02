# curriculum-vitae with [luarocks](https://luarocks.org/)

This package is available on luarocks. To install it, run:

```sh
luarocks install curriculum_vitae --local
```

## Usage

```lua
-- export LUA_PATH="$HOME/.luarocks/share/lua/5.3/?.lua"
local cv = require("curriculum_vitae")
local path_to_json = "path/to/file.json"
cv.generate_cv_from_json(path_to_json)
```
