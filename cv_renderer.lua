require("lualibs.lua")
if tex == nil
then
    tex = {}
    utilities = {}
    texio = {}
end
-- for debugging
-- tex.print = texio.write_nl
Lang = os.getenv("CV_LANG") or "en"
texio.write_nl("Lang is: " .. Lang)

local function read_json(file)
    local handler = io.open(file, "rb")
    if handler == nil
    then
        texio.write_nl("File not found: " .. file)
        return "{}"
    end
    local content = handler:read("*a")
    handler:close()
    return content
end

Data = utilities.json.tolua(read_json('cv_data.json'))


local function g(value)
    if type(value) == "table" then
        if value[Lang] ~= nil then
            return value[Lang]
        end
        if value["optionnal"] == true then
            return nil
        end
        local text = "Value not found for '" .. Lang .. "' in " .. utilities.json.tostring(value) .. "\n"
        texio.write_nl(text)
        return nil
    end
    return value
end

function Write_metadata()
    local me = Data.me
    if me == nil
    then
        return
    end
    tex.print("\\title{CV - " .. me.firstname .. me.lastname .. "}")
    tex.print("\\author{" .. me.firstname .. me.lastname .. "}")
    tex.print("\\date{" .. os.date("%Y-%m-%d") .. "}")
end

local function print_title_section(dataText)
    tex.print("{")
    tex.print("\\vspace{0.5em}")
    tex.print("\\normalfont\\Large\\bfseries")
    tex.print("{" .. g(dataText) .. "~\\xrfill[.7ex]{1pt}} \\newline")
    tex.print("}")
end

local function print_education()
    local data = Data.school
    if data == nil
    then
        return
    end
    print_title_section(data.title)
    local educationData = data.data
    tex.print("\\newline")
    tex.print("\\begin{tabular}{r| p{1.15\\paracolwidth}}")
    for nameCount = 1, #educationData do
        tex.print(
            '{' ..
            g(educationData[nameCount].date) ..
            '} & \\textbf{ ' .. g(educationData[nameCount].name) ..
            ' }' .. '\\newline{\\color{cvaltcolour}\\faMapMarker~\\color{black!70} ' ..
            g(educationData[nameCount].location) ..
            " }" .. "\\newline{\\color{black!70} " .. g(educationData[nameCount].description) .. " } \\vspace{0.5em}"
        )
        tex.print("\\\\")
    end
    tex.print("\\end{tabular}")
    tex.print("\\newline")
end

local function print_experience()
    local data = Data.work
    if data == nil
    then
        return
    end
    print_title_section(data.title)
    local workData = data.data
    tex.print("\\newline")
    tex.print("\\begin{tabular}{r> {}p{1.15\\paracolwidth} }")
    for nameCount = 1, #workData do
        if workData[nameCount].name[Lang] ~= nil then
            tex.print(
                g(workData[nameCount].date) ..
                ' & ' ..
                g(workData[nameCount].name) ..
                ' \\newline ' ..
                g(workData[nameCount].description)
            )
            tex.print(" \\vspace{0.4em} \\\\")
        end
    end
    tex.print("\\end{tabular}")
end

local function print_table(personalData)
    if personalData == nil
    then
        return
    end
    tex.print("\\begin{itemize}")
    tex.print("\\setlength\\itemsep{0.1em}")
    for nameCount = 1, #personalData do
        if personalData[nameCount].description[Lang] then
            tex.print(
                '\\item ' ..
                g(personalData[nameCount].description)
            )
        end
    end
    tex.print("\\end{itemize}")
end

local function print_personal()
    local data = Data.personal
    if data == nil
    then
        return
    end
    print_title_section(data.title)
    print_table(data.data)
end

local function print_project()
    local data = Data.personal
    if data == nil
    then
        return
    end
    print_title_section(data.title)
    print_table(data.data)
end

local function header()
    local me = Data.me
    if me == nil
    then
        return
    end
    tex.print("\\begin{center}")
    tex.print("\\huge \\textbf{" .. g(me.title) .. "}\\\\ \\normalsize " .. g(me.subtitle) .. "\\\\")
    if me.subsubtitle[Lang] ~= nil
    then
        tex.print("\\textbf{\\textit{" .. g(me.subsubtitle) .. "}}")
    end
    tex.print("\\end{center}")
    tex.print("\\fontsize{11.3pt}{11.3pt}\\selectfont")
end

function Render_content()
    header()
    print_education()
    print_experience()
    print_project()
    print_personal()
end

local function print_head()
    local i = Data.me
    if i == nil
    then
        return
    end
    if Lang == "en"
    then
        tex.print("\\vspace*{\\fill}")
    end
    tex.print("{")
    tex.print("\\centering")
    tex.print("\\Large")
    tex.print("\\textbf{" .. i.firstname .. " " .. i.lastname .. "}")
    tex.print("\\\\")
    tex.print("}")
    if Lang == "en"
    then
        tex.print("\\vspace{0.5cm}")
        tex.print("\\begin{center}")
        tex.print(i.bio[Lang])
        tex.print("\\end{center}")
    else
        if i.picture ~= nil
        then
            tex.print(
                "\\begin{figure}[H]\\centering\\tikz  \\draw [path picture={ \\node at (path picture bounding box.center){\\includegraphics[height=4cm]{" ..
                i.picture .. "}} ;}] (0,1) circle (1.8) ;\\end{figure}")
        end
    end
    tex.print("\\fontfamily{\\sfdefault}\\selectfont \\color{black!70}")
end

local function print_info()
    local i = Data.me
    if i == nil
    then
        return
    end
    tex.print("\\section{\\textbf{" .. g(i.sidebar) .. "}}{")
    tex.print("\\large")
    tex.print("{")
    tex.print("    \\fontsize{10pt}{10pt}\\selectfont")
    tex.print("    \\href{mailto:" .. i.mail .. "}{" .. i.mail .. "}\\\\")
    tex.print("}")
    tex.print(g(i.location) .. "~\\faMapMarker\\\\")
    tex.print("\\href{tel:" .. i.phone:gsub(" ", "") .. "}{" .. i.phone .. "}~\\faPhone\\\\")
    if i.driving
    then
        tex.print("Driving licence~\\faWpforms")
    end
    tex.print("\\\\")
    tex.print("\\href{" .. i.website .. "}{" .. i.website .. "}~\\faHome")
    tex.print("\\\\")
    tex.print("\\href{" ..
        i.linkedin.link .. "}{" .. i.linkedin.name .. "}~{\\color{linkedinblue}\\faLinkedinSquare}")
    tex.print("\\\\")
    tex.print("\\href{" .. i.github.link .. "}{" .. i.github.name .. "}~{\\color{black}\\faGithub}")
    tex.print("\\\\")
    tex.print("}")
end

local function print_dev_languages()
    local p = Data.languages
    if p == nil
    then
        return
    end
    tex.print("\\section{\\textbf{" .. g(p.title) .. "}}")
    tex.print("{")
    tex.print("\\footnotesize")
    tex.print("\\begin{tabular}{>{\\ssmall}rp{\\onefifthwidth}}")
    for nameCount, _ in ipairs(p.data) do
        local item = "&"
        if nameCount % 2 == 0
        then
            item = "\\\\"
        end
        tex.print("{\\large " ..
            g(p.data[nameCount].name) .. "}" .. item)
    end
    tex.print("\\end{tabular}")
    tex.print("}")
end

local function print_tools()
    local p = Data.tools
    if p == nil
    then
        return
    end
    tex.print("\\section{\\textbf{" .. g(p.title) .. "}}")
    tex.print("\\begin{center}")
    tex.print("\\begin{tabular}{>{\\ssmall}rp{\\onefifthwidth}}")
    for nameCount, _ in ipairs(p.data) do
        local item = "&"
        if nameCount % 2 == 0
        then
            item = "\\\\"
        end
        tex.print("{\\large " ..
            g(p.data[nameCount].name) .. "}" .. item)
    end
    tex.print("\\end{tabular}")
    tex.print("\\end{center}")
end

local function print_languages()
    local p = Data.langs
    if p == nil
    then
        return
    end
    tex.print("\\section{\\textbf{" .. g(p.title) .. "}}")
    tex.print("\\begin{center}")
    tex.print("\\begin{tabular}{>{\\ssmall}rp{0.3\\textwidth}}")
    for nameCount = 1, #p.data do
        tex.print("{\\large " ..
            g(p.data[nameCount].name) .. "} & {\\large " .. g(p.data[nameCount].level) .. "}\\vspace{0.5em}")
        tex.print("\\\\")
    end
    tex.print("\\end{tabular}")
    tex.print("\\end{center}")
end

local function print_hobbies()
    local p = Data.hobbies
    if p == nil
    then
        return
    end
    tex.print("\\section{\\textbf{" .. g(p.title) .. "}}")
    local total = #p.data
    for nameCount, obj in ipairs(p.data) do
        if nameCount == total and nameCount % 2 ~= 0 then
            tex.print("\\begin{center}")
        end
        tex.print("\\hobbyicon{\\color{white} " ..
            g(obj.ico) .. "}{"
            .. g(obj.name) .. "}{cvcolour}{\\Large}{1.5em}")

        if nameCount == total and nameCount % 2 ~= 0 then
            tex.print("\\end{center}")
        end
        if nameCount ~= total and nameCount % 2 == 0 then
        else
            tex.print("\\hfill")
        end
    end
end

function Write_sidebar()
    tex.print("\\fontsize{11.5pt}{11.5pt}\\selectfont")
    tex.print("\\begin{navbar}")
    print_head()
    print_info()
    print_dev_languages()
    print_tools()
    print_languages()
    print_hobbies()
    tex.print("\\vspace*{\\fill}")
    tex.print("\\end{navbar}")
end
