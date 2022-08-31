# Simple script to extract current Project.toml from a Pluto notebook
function extract_project(filename)
    # Extract the contents of Project.toml
    lines = readlines(filename)
    head = findfirst(startswith("PLUTO_PROJECT_TOML"), lines) + 1
    closestrings = findall(startswith("\"\"\""), lines)
    tail = closestrings[findfirst(x -> x > head, closestrings)] - 1
    contents = lines[head:tail]

    # Save Project.toml
    if isfile("Project.toml")
        println(stderr, "Project.toml already exists. Aborting!")
        exit(1)
    end
    open("Project.toml", "w") do out
        for l in contents
            println(out, l)
        end
    end
end

extract_project(ARGS[1])







