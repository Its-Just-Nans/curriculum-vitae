local function read_file(file)
    local handler = io.open(file, "rb")
    if handler == nil
    then
        print("File not found: " .. file)
        return "{}"
    end
    local content = handler:read("*a")
    handler:close()
    return content
end



local function TableConcat(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end
    return t1
end

-- limited by technologies of my time
-- Variable Number of Arguments is not supported

local function TableConcat3(t1, t2, t3)
    return TableConcat(TableConcat(t1, t2), t3)
end

local function TableConcat4(t1, t2, t3, t4)
    return TableConcat(TableConcat3(t1, t2, t3), t4)
end

local function TableConcat5(t1, t2, t3, t4, t5)
    return TableConcat(TableConcat4(t1, t2, t3, t4), t5)
end

local function TableConcat6(t1, t2, t3, t4, t5, t6)
    return TableConcat(TableConcat5(t1, t2, t3, t4, t5), t6)
end

local function TableConcat7(t1, t2, t3, t4, t5, t6, t7)
    return TableConcat(TableConcat6(t1, t2, t3, t4, t5, t6), t7)
end


local function Latex_Block(arr1, data)
    local head_block = "\\begin"
    for i, v in ipairs(arr1)
    do
        head_block = head_block .. "{" .. v .. "}"
    end
    return TableConcat3(
        { head_block },
        data,
        { "\\end{" .. arr1[1] .. "}" }
    )
end


local function g(value)
    if type(value) == "table" then
        if value[Lang] ~= nil then
            return value[Lang]
        end
        if value["optionnal"] == true then
            return nil
        end
        local text = "Value not found for '" .. Lang .. "' in " .. utilities.json.tostring(value) .. "\n"
        print(text)
        return nil
    end
    return value
end

local function Metadata()
    local me = Data.me
    if me == nil
    then
        return {}
    end
    return {
        "\\title{CV - " .. me.firstname .. ' ' .. me.lastname .. "}",
        "\\author{" .. me.firstname .. ' ' .. me.lastname .. "}",
        "\\date{" .. os.date("%Y-%m-%d") .. "}",
        '\\hypersetup{' ..
        'pdftitle={CV - ' .. me.firstname .. ' ' .. me.lastname .. '},' ..
        'pdfsubject={curriculum vitae' .. ' of ' .. me.firstname .. ' ' .. me.lastname .. '},' ..
        'pdfauthor={' .. me.firstname .. ' ' .. me.lastname ..
        ' (created with https://github.com/Its-Just-Nans/curriculum-vitae)},' ..
        'pdfkeywords={' .. table.concat(me.keywords, ", ") .. '}',
        '}'
    }
end

local function print_title_section(dataText)
    return {
        ("{\\vspace{0.5em}"),
        ("\\normalfont\\Large\\bfseries"),
        ("{" .. g(dataText) .. "~\\xrfill[.7ex]{1pt}} \\newline"),
        ("}"),
    }
end

local function Education()
    local data = Data.school
    local buf = {}
    if data == nil
    then
        return buf
    end
    buf = TableConcat(buf, print_title_section(data.title))
    local educationData = data.data
    table.insert(buf, "\\newline")
    table.insert(buf, "\\begin{tabular}{r> {}p{1.1\\paracolwidth}}")
    for nameCount = 1, #educationData do
        table.insert(buf,
            '{' .. g(educationData[nameCount].date) .. '}' ..
            ' & \\textbf{ ' .. g(educationData[nameCount].name) .. ' }' ..
            '\\newline{\\color{cvaltcolour}\\faMapMarker~\\color{black!70} ' ..
            g(educationData[nameCount].location) .. " }" ..
            "\\newline{\\color{black!70} " .. g(educationData[nameCount].description) .. " } \\vspace{0.5em}"
        )
        table.insert(buf, "\\\\")
    end
    table.insert(buf, "\\end{tabular}")
    table.insert(buf, "\\newline")
    return buf
end

local function Experience()
    local data = Data.work
    local buf = {}
    if data == nil
    then
        return buf
    end
    buf = TableConcat(buf, print_title_section(data.title))
    local workData = data.data
    table.insert(buf, "\\newline")
    table.insert(buf, "\\begin{tabular}{r> {}p{1.1\\paracolwidth}}")
    for nameCount = 1, #workData do
        if workData[nameCount].optionnal ~= true then
            if workData[nameCount].name[Lang] ~= nil then
                table.insert(buf,
                    g(workData[nameCount].date) ..
                    ' & ' ..
                    g(workData[nameCount].name) ..
                    ' \\newline ' ..
                    g(workData[nameCount].description)
                )
                table.insert(buf, " \\vspace{0.4em} \\\\")
            end
        end
    end
    table.insert(buf, "\\end{tabular}")
    table.insert(buf, "\\newline")
    return buf
end

local function print_table(personalData)
    local buf = {}
    if personalData == nil
    then
        return buf
    end
    table.insert(buf, "\\begin{itemize}")
    table.insert(buf, "\\setlength\\itemsep{0.4em}")
    for nameCount = 1, #personalData do
        if personalData[nameCount].description[Lang] then
            table.insert(buf,
                '\\item ' ..
                g(personalData[nameCount].description)
            )
        end
    end
    table.insert(buf, "\\end{itemize}")
    return buf
end

local function Personal()
    local data = Data.personal
    if data == nil
    then
        return {}
    end
    return TableConcat(
        print_title_section(data.title),
        print_table(data.data)
    )
end

local function Project()
    local data = Data.project
    if data == nil
    then
        return {}
    end
    return TableConcat(
        print_title_section(data.title),
        print_table(data.data)
    )
end

local function Header()
    local me = Data.me
    local buf = {}
    if me == nil
    then
        return buf
    end
    return Latex_Block({ "center" },
        {
            "\\huge \\textbf{" .. g(me.title) .. "}\\\\",
            "\\normalsize " .. g(me.subtitle) .. "\\\\",
            (me.subsubtitle[Lang] ~= nil and table.insert(buf, "\\textbf{\\textit{" .. g(me.subsubtitle) .. "}}") or "")
        }
    )
end

local function Content()
    return TableConcat6(
        Header(),
        { "\\fontsize{11.3pt}{11.3pt}\\selectfont" },
        Education(),
        Experience(),
        Project(),
        Personal()
    )
end

local function Head()
    local i = Data.me
    local buf = {}
    if i == nil
    then
        return buf
    end
    if Lang == "en"
    then
        table.insert(buf, "\\vspace*{\\fill}")
    end
    table.insert(buf, "{")
    table.insert(buf, "\\centering")
    table.insert(buf, "\\Large")
    table.insert(buf, "\\textbf{" .. i.firstname .. " " .. i.lastname .. "}")
    table.insert(buf, "\\\\")
    table.insert(buf, "}")
    if Lang == "en"
    then
        table.insert(buf, "\\vspace{0.5cm}")
        table.insert(buf, "\\begin{center}")
        table.insert(buf, i.bio[Lang])
        table.insert(buf, "\\end{center}")
    else
        if i.picture ~= nil
        then
            table.insert(buf,
                "\\begin{figure}[H]\\centering\\tikz  \\draw [path picture={ \\node at (path picture bounding box.center){\\includegraphics[height=4cm]{" ..
                i.picture .. "}} ;}] (0,1) circle (1.8) ;\\end{figure}")
        end
    end
    table.insert(buf, "\\fontfamily{\\sfdefault}\\selectfont \\color{black!70}")
    return buf
end

local function Info()
    local i = Data.me
    local buf = ""
    if i == nil
    then
        return buf
    end
    return {
        ("\\section{\\textbf{" .. g(i.sidebar) .. "}}{"),
        ("\\large"),
        ("{"),
        ("    \\fontsize{10pt}{10pt}\\selectfont"),
        ("    \\href{mailto:" .. i.mail .. "}{" .. i.mail .. "}\\\\"),
        ("}"),
        (g(i.location) .. "~\\faMapMarker\\\\"),
        ("\\href{tel:" .. i.phone:gsub(" ", "") .. "}{" .. i.phone .. "}~\\faPhone\\\\"),

        (g(i.driving) .. "~\\faWpforms"),
        ("\\\\"),
        ("\\href{" .. i.website .. "}{" .. i.website .. "}~\\faHome"),
        ("\\\\"),
        ("\\href{" ..
            i.linkedin.link .. "}{" .. i.linkedin.name .. "}~{\\color{linkedinblue}\\faLinkedinSquare}"),
        ("\\\\"),
        ("\\href{" .. i.github.link .. "}{" .. i.github.name .. "}~{\\color{black}\\faGithub}"),
        ("\\\\"),
        ("}"),
    }
end

local function print_dev_languages()
    local p = Data.languages
    local buf = {}
    if p == nil
    then
        return buf
    end
    table.insert(buf, "\\section{\\textbf{" .. g(p.title) .. "}}")
    table.insert(buf, "{")
    table.insert(buf, "\\footnotesize")
    table.insert(buf, "\\begin{tabular}{>{\\ssmall}rp{\\onefifthwidth}}")
    for nameCount, _ in ipairs(p.data) do
        local item = "&"
        if nameCount % 2 == 0
        then
            item = "\\\\"
        end
        table.insert(buf, "{\\large " ..
            g(p.data[nameCount].name) .. "}" .. item)
    end
    table.insert(buf, "\\end{tabular}")
    table.insert(buf, "}")
    return buf
end

local function print_tools()
    local p = Data.tools
    local buf = {}
    if p == nil
    then
        return buf
    end
    table.insert(buf, "\\begin{tabular}{>{\\ssmall}rp{\\onefifthwidth}}")
    for nameCount, _ in ipairs(p.data) do
        local item = "&"
        if nameCount % 2 == 0
        then
            item = "\\\\"
        end
        table.insert(buf, "{\\large " .. g(p.data[nameCount].name) .. "}" .. item)
    end
    table.insert(buf, "\\end{tabular}")
    return TableConcat(
        { "\\section{\\textbf{" .. g(p.title) .. "}}" },
        Latex_Block({ "center" }, buf)
    )
end

local function print_languages()
    local p = Data.langs
    local buf = {}
    if p == nil
    then
        return buf
    end
    table.insert(buf, "\\begin{tabular}{>{\\ssmall}rp{0.3\\textwidth}}")
    for nameCount = 1, #p.data do
        table.insert(buf, "{\\large \\textbf{" ..
            g(p.data[nameCount].name) .. "}} & {\\normalsize " .. g(p.data[nameCount].level) .. "}\\vspace{0.5em}\\\\")
    end
    table.insert(buf, "\\end{tabular}")
    return TableConcat(
        { "\\section{\\textbf{" .. g(p.title) .. "}}" },
        Latex_Block({ "center" }, buf)

    )
end

local function print_hobbies()
    local p = Data.hobbies
    local buf = {}
    if p == nil
    then
        return buf
    end
    table.insert(buf, "\\section{\\textbf{" .. g(p.title) .. "}}")
    local total = #p.data
    for nameCount, obj in ipairs(p.data) do
        if nameCount == total and nameCount % 2 ~= 0 then
            table.insert(buf, "\\begin{center}")
        end
        table.insert(buf, "\\hobbyicon{\\color{white} " ..
            g(obj.ico) .. "}{"
            .. g(obj.name) .. "}{cvcolour}{\\Large}{1.5em}")

        if nameCount == total and nameCount % 2 ~= 0 then
            table.insert(buf, "\\end{center}")
        end
        if nameCount ~= total and nameCount % 2 == 0 then
        else
            table.insert(buf, "\\hfill")
        end
    end
    return buf
end


local function Headers()
    return { '\\usepackage{xcolor}',
        '\\usepackage[T1]{fontenc}',
        '\\usepackage[french]{babel}',
        '\\usepackage[familydefault,light]{Chivo}',
        '\\usepackage[default]{raleway}',
        '\\usepackage{anyfontsize}',
        '\\usepackage{fontawesome}',
        '\\usepackage{hyperref}',
        '\\setlength{\\parindent}{0cm}',
        '\\usepackage{paracol}',
        '\\usepackage{ifthen}',
        '\\usepackage{tikz}',
        '\\usepackage{tikz-3dplot}',
        '\\usepackage{smartdiagram}',
        '\\usepackage{float}',
        '\\usepackage{moresize}',
        '\\usepackage{array}',
        '\\usetikzlibrary{decorations.text}',
        '\\usetikzlibrary{fadings}',
        '\\usetikzlibrary{calc}',
        '\\usetikzlibrary{shapes.misc,positioning}',
        '\\usetikzlibrary{arrows}',
        '\\usetikzlibrary{arrows.meta}',
        '\\usetikzlibrary{backgrounds}',
        '\\usetikzlibrary{shadings}',
        '\\usetikzlibrary{calendar}',
        '\\usetikzlibrary{er}',
        '\\usetikzlibrary{patterns}',
        '\\usetikzlibrary{shapes}',
        '\\usetikzlibrary{shapes.geometric}',
        '\\usetikzlibrary{decorations}',
        '\\usetikzlibrary{topaths}',
        '\\usepackage{graphicx}',
        '\\usepackage{atveryend}',
        '\\usepackage{lastpage}',
        '\\usepackage{fancyhdr}',
        '\\usepackage{xhfill}',
        '\\usepackage{titlesec}', -- Allows creating custom \\sections
        '\\titleformat{\\section}{',
        '\\scshape\\Large\\raggedright}{}{0em}{}[\\color{black!70}{\\titlerule}] ',
        '\\titlespacing{\\section}{0pt}{5pt}{0.2cm}', -- Spacing around titles {<left spacing>}{<before spacing>}{<after spacing>}
        '\\titleformat{\\subsection}{',
        '\\scshape\\large\\raggedright}{}{0em}{}[] ',
        '\\usepackage{smartdiagram}',
        '\\newcommand{\\hobbyicon}[5]{' ..
        '\\begin{tikzpicture}' ..
        '\\draw[draw=none,fill=#3] (0,0) circle (0.5);' ..
        '\\node[](icon) at (0,0) {\\hspace{-0.5em}#4 #1};' ..
        '\\node[below=#5,align=center] at (icon) {#2};' ..
        '\\end{tikzpicture}' .. '}',
        '\\renewcommand{\\headrulewidth}{0pt}', --  get rid of the headrule
        '\\fancyhf{}',                          -- clear space at the header and footer
        '\\newenvironment{navbar}{' ..
        '\\switchcolumn*' ..
        '\\begin{flushright}' ..
        '\\small' ..
        '}{' ..
        '\\end{flushright}' .. '}',
        '\\definecolor{linkedinblue}{HTML}{2977c9}',
        '\\definecolor{lightcol}{RGB}{245,245,245}',
        '\\definecolor{cvblue}{HTML}{5499C7}',
        '\\definecolor{cvgrey}{HTML}{CFCFCF}',
        '\\colorlet{cvcolour}{cvblue}',
        '\\colorlet{cvaltcolour}{cvgrey}',
        '\\newcommand{\\customHeight}{1.7cm}',
        '\\usepackage[right=0.8cm, left=0.8cm, top=\\customHeight, bottom=\\customHeight, a4paper]{geometry}',
        '\\newlength{\\paracolwidth}',
        '\\newlength{\\onefifthwidth}',
        '\\setlength{\\paracolwidth}{0.50\\textwidth}',
        '\\setlength{\\onefifthwidth}{0.23\\textwidth}',
        '\\pagestyle{fancy}',
        '\\usepackage[none]{hyphenat}',
    }
end

local function Sidebar()
    return TableConcat(
        { "\\fontsize{11.5pt}{11.5pt}\\selectfont", },
        Latex_Block({ "navbar" },
            TableConcat7(
                Head(),
                Info(),
                print_dev_languages(),
                print_tools(),
                print_languages(),
                print_hobbies(),
                { "\\vspace*{\\fill}", }
            )
        )
    )
end


local function TexLines(arr)
    for i, v in ipairs(arr)
    do
        tex.print(v)
    end
end



local function Write_Document()
    TexLines(
        Latex_Block({ "document" },
            TableConcat(
                {
                    '\\setlength{\\columnsep}{0.75cm}',
                    '\\columnratio{0.27}',
                    '\\setlength{\\columnseprule}{4pt}',
                    '\\colseprulecolor{lightcol}',
                    '\\hbadness5000',
                },
                Latex_Block({ "paracol", "2" },
                    TableConcat4(
                        { '\\switchcolumn*' },
                        Sidebar(),
                        { '\\switchcolumn\\color{black!80}' },
                        Content()
                    )
                )
            )
        )
    )
end

local function Write_Head()
    TexLines(Headers())
    TexLines(Metadata())
end

function Write_CV()
    Write_Head()
    Write_Document()
end

local function self_invoke()
    local file = io.open("main.tex", "w")
    if file == nil then
        print("Error: Cannot open file")
        return
    end
    local tex_file = "\\documentclass[10pt]{article}" .. "\n" ..
        "\\usepackage{luacode}" .. "\n" ..
        "\\begin{luacode}" .. "\n" ..
        "require('cv_renderer')" .. "\n" ..
        "\\end{luacode}" .. "\n" ..
        "\\directlua{Write_CV()}"

    file:write(tex_file)
    file:close()
    local FILENAME = os.getenv("FILENAME") or "en"
    local lang = Data.cv_langs
    for i, one_lang in ipairs(lang) do
        local full_filename = FILENAME .. "_" .. one_lang
        os.execute("CV_LANG=" .. one_lang .. " lualatex --jobname=" .. full_filename .. " main.tex")
        for index, ext in ipairs({ "aux", "log", "out" }) do
            os.remove(full_filename .. "." .. ext)
        end
    end
    os.remove("main.tex")
end

-- start variables
Is_lib = pcall(debug.getlocal, 4, 1) or false
Json_path = os.getenv("CV_JSON") or "cv_data.json"



if Is_lib then
    require("lualibs.lua")
    if tex == nil
    then
        tex = {}
        texio = {}
        utilities = {}
    end
    print = texio.write_nl
    -- for debugging
    -- tex.print = texio.write_nl
    Lang = os.getenv("CV_LANG") or "en"
    print("Lang is: " .. Lang)
    Data = utilities.json.tolua(read_file(Json_path))
else
    local json = require "json"
    Data = json.decode(read_file(Json_path))
    self_invoke()
end
