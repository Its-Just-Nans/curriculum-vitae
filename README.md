# curriculum-vitae

Generate curriculum vitæ from json using lua and lualatex.

A single lua script which autoload itself into lualatex to generate a cv from a json file.

## How to use

```sh
# create the cv_data.json
# load env (and export variables)
source .env
lua cv_renderer.lua
```
