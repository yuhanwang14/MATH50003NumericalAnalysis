module MATH50003NumericalAnalysis

using Weave

export compilenotes, compilesheet, compilesheetsolution, compilelab, compilelabsolution, compilelabdemo


#####
# notes
#####



function replacetheorem(path, thrm, Thrm)
    str = read(path, String)
    str = replace(str, Regex("\\\\textbf{$Thrm \\(([^}]*)\\)}(.*?)\\\\textbf{Proof}", "s") => SubstitutionString("\\\\begin{$thrm}[\\1]\\2\\\\end{$thrm}\\n\\\\textbf{Proof}"))
    write(path, str)
end

function replacedefinition(path, thrm, Thrm)
    str = read(path, String)
    str = replace(str, Regex("\\\\textbf{$Thrm \\(([^}]*)\\)}(.*?)\\\\ensuremath{\\\\QED}", "s") => SubstitutionString("\\\\begin{$thrm}[\\1]\\2\\\\end{$thrm}"))
    write(path, str)
end

function fixwhitespace(path)
    write(path, replace(read(path, String), "\n\n\\[" => "\n\\["))
    write(path, replace(read(path, String), "\n\n\n\\begin{align" => "\n\\begin{align"))
end

function fixunderbars(path)
    write(path, replace(read(path, String), "f\\ensuremath{\\underbar}" => "\\underline{f}"))
    write(path, replace(read(path, String), "g\\ensuremath{\\underbar}" => "\\underline{g}"))
    write(path, replace(read(path, String), "M\\ensuremath{\\tilde}" => "\\tilde{M}"))
    write(path, replace(read(path, String), "L\\ensuremath{\\tilde}" => "\\tilde{L}"))
    write(path, replace(read(path, String), "U\\ensuremath{\\tilde}" => "\\tilde{U}"))
    write(path, replace(read(path, String), "P\\ensuremath{\\tilde}" => "\\tilde{P}"))
    write(path, replace(read(path, String), "Q\\ensuremath{\\hat}" => "\\hat{Q}"))
    write(path, replace(read(path, String), "R\\ensuremath{\\hat}" => "\\hat{R}"))
end

function compilenotes(filename) 
    weave("src/notes/$filename.jmd"; out_path="notes/", doctype="md2tex", template="src/notes/template.tpl")
    path = "notes/$filename.tex"
    replacetheorem(path, "theorem", "Theorem")
    replacetheorem(path, "lemma", "Lemma")
    replacetheorem(path, "proposition", "Proposition")
    replacetheorem(path, "corollary", "Corollary")
    replacedefinition(path, "example", "Example")
    replacedefinition(path, "definition", "Definition")
    # work around double newline before equation
    fixwhitespace(path)
    fixunderbars(path)
    # work around meeq 
    write(path, replace(read(path, String), r"\\\[\n\\meeq\{(.*?)\}\n\\\]"s => s"\\meeq{\1}"))
end




###
# sheets
###

function compilesheet(k)
    filename = "sheet$k"
    write("sheets/$filename.jmd", replace(read("src/sheets/$(filename)s.jmd", String), r"\*\*SOLUTION\*\*(.*?)\*\*END\*\*"s => ""))
    weave("sheets/$filename.jmd"; out_path="sheets/", doctype="md2tex", template="src/sheets/template.tpl")
    path = "sheets/$filename.tex"
    # work around double newline before equation
    fixwhitespace(path)
    fixunderbars(path)
    # work around meeq 
    write(path, replace(read(path, String), r"\\\[\n\\meeq\{(.*?)\}\n\\\]"s => s"\\meeq{\1}"))
end


function compilesheetsolution(k)
    filename = "sheet$k"
    weave("src/sheets/$(filename)s.jmd"; out_path="sheets/", doctype="md2tex", template="src/sheets/template.tpl")
    path = "sheets/$(filename)s.tex"
    # work around double newline before equation
    fixwhitespace(path)
    fixunderbars(path)
    # work around meeq 
    write(path, replace(read(path, String), r"\\\[\n\\meeq\{(.*?)\}\n\\\]"s => s"\\meeq{\1}"))
end




# notebook("sheets/sheet1.jmd"; pkwds...)
# notebook("src/sheets/sheet1s.jmd"; pkwds...)


#####
# labs
#####

import Literate

function compilelab(k)
    str = replace(read("src/labs/lab$(k)s.jl", String), r"## SOLUTION(.*?)## END"s => "")
    write("labs/lab$k.jl", replace(str, r"## DEMO(.*?)## END"s => s"\1"))
    Literate.notebook("labs/lab$k.jl", "labs/"; execute=false)
end

function compilelabdemo(k)
    str = replace(read("src/labs/lab$(k)s.jl", String), r"## SOLUTION(.*?)## END"s => "")
    write("slides/lab$(k)d.jl", replace(str, r"## DEMO(.*?)## END"s => "##"))
    Literate.notebook("slides/lab$(k)d.jl", "slides/"; execute=false)
end

function compilelabsolution(k)
    str = read("src/labs/lab$(k)s.jl", String)
    write("labs/lab$(k)s.jl", replace(str, r"## DEMO(.*?)## END"s => s"\1"))
    Literate.notebook("labs/lab$(k)s.jl", "labs/"; execute=false)
end

end # module