# Prints "file:line:text" for each C# declaration whose parameter list has
# more than 3 parameters. Only top-level commas are counted: commas nested
# inside <>, (), [] and {} are ignored.
{
    line = $0
    sub(/\/\/.*/, "", line)
    if (line !~ /(public|private|protected|internal)/) next

    n = length(line)
    depth = 0
    start = 0
    commas = 0
    for (i = 1; i <= n; i++) {
        c = substr(line, i, 1)
        if (start == 0) {
            # parameter list opens at the first "(" that follows an identifier or ">"
            if (c == "(") {
                j = i - 1
                while (j > 0 && substr(line, j, 1) == " ") j--
                if (j > 0 && substr(line, j, 1) ~ /[A-Za-z0-9_>]/) { start = i; depth = 1 }
            }
            continue
        }
        if (c ~ /[(<\[{]/) depth++
        else if (c ~ /[)>\]}]/) {
            # "=>" is not a closing angle bracket
            if (c == ">" && substr(line, i - 1, 1) == "=") continue
            depth--
            if (depth == 0) break
        } else if (c == "," && depth == 1) commas++
    }
    if (start > 0 && depth == 0 && commas >= 3) print FILENAME ":" FNR ":" $0
}
