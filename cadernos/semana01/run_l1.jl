# Simple script to run l1.jl

import Pkg
Pkg.activate(".")
Pkg.add("ImageMagick")
Pkg.add("Images")
Pkg.add("PlutoUI")
Pkg.add("HypertextLiteral")
include("l1.jl")
