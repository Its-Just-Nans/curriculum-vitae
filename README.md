# curriculum-vitae

Generate curriculum vitæ from json using lua and lualatex

## How to use

```sh
# create the cv_data.json
FILENAME=CV
for onel in "en" "fr";do CV_JSON=data/cv/cv_data.json CV_LANG=$onel lualatex --jobname=${FILENAME}_${onel} main.tex; done
```
