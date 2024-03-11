### A Pluto.jl notebook ###
# v0.19.39

using Markdown
using InteractiveUtils

# ╔═╡ 5a491971-f15a-45d9-a5ea-4dcfda6a1dbd
begin
	using MKL
	using LinearAlgebra
end

# ╔═╡ 68e30962-c114-11ee-0bb4-0bcc86e07482
md"# Uma rápida introdução à linguagem Julia

Lembre-se que para executar esse caderno em sua máquina é preciso primeiro instalar a linguagem Julia e o pacote Pluto.

Esse tutorial está fortemente baseado no [tutorial do Martin Mass](https://www.matecdev.com/posts/julia-tutorial-science-engineering.html) que é mais completo. Se você sabe bem inglês também é uma boa fonte de informação.

Ele é apenas uma introdução bem rápida à Julia para quem nunca viu a linguagem. Ele não tenta de fato ensiná-la, apenas faz um sobrevoo panorâmico. Para aprender Julia sugiro fortemente que você procure um texto introdutório completo ou mesmo um livro.

Uma boa opção, em português, é o capítulo 1 do [texto do Leandro Martínez](http://leandro.iqm.unicamp.br/m3g/main/didatico/simulacoes2/simulacoes2.pdf), do IQ. Um bom livro é o [Julia 1.0 Programming](https://www.packtpub.com/product/julia-1-0-programming-second-edition/9781788999090) do Balbert.

Outra ótima fonte de informação é o [manual da linguagem](https://docs.julialang.org/en/v1/).
"

# ╔═╡ 0a76ed15-2d8d-4dc1-a844-81855915619a
md"
## Por que Julia?

* É uma linguagem de propósito geral.
* Sintaxe moderna e ágil.
* Sintaxe adequada para matemática e ciências.
* Julia é compilada, gerando código assembler. Júlia é rápida!
* Resolve o **problema de dois idiomas**.
* Paradigma moderno: hierarquias de tipos e despacho múltiplo.
* Um ecossistema científico incrível: `NLPModels.jl`, `JuMP.jl`, `Convex.jl`, `Plots.jl`, `DifferentialEquations.jl`, `ForwardDiff.jl`, `Unitful.jl`, `IJulia.jl`, `Pluto.jl`, e muito mais.
* Gerenciamento de pacotes integrado.

Por falar em pacotes, vamos começar carregando alguns pacotes. Pacotes são o nome das biblitecas de Julia. A linguagem vem com um sistema de gerencialmento de pacotes embutido e estimula que você crie ambientes únicos para cada projeto. Pluto, que cuida dos nossos cadernos, leva isso a um extremo. Ele cria um ambiente separado para cada caderno e guarda nele a informação para recriar esse ambiente em outras máquinas, garantindo assim que o código irá sempre funcionar tendo acesso às bibliotecas necessárias nas versões corretas.

Vamos começar carregando alguns pacotes.
"

# ╔═╡ b21168c0-10fd-4791-b995-54a3c645350c
# Standard numerical linear algebra
function try_lu(reps)
    n = 1000
    A = rand(n, n)
    luA = lu(A)
    maxres = 0.0
    for i = 1:reps
        b = rand(n)
        x = luA \ b
        maxres = max(norm(A*x - b), maxres)
    end
    return maxres
end

# ╔═╡ 59c0e855-2535-493c-923c-d1c18ddde93c
@time try_lu(10_000)

# ╔═╡ fdb914af-f7a2-4e8e-b5ac-e1cabc71e175
# Naive projection onto a a Box - You would never want to do this in Matlab or Python
function projB!(x, lb, ub)
    n = length(x)
    for i ∈ 1:n
        x[i] = min(ub[i], max(x[i], lb[i]))
    end
end

# ╔═╡ b6573693-3bab-4fbf-8f5b-8d891b6e0bc1
function try_proj(reps, n = 1000, projB! =projB!)
    lb, ub = rand(n), 100 .+ rand(n) 
    for i ∈ 1:reps
		x = 1000*rand(n)
        projB!(x, lb, ub)
    end
end

# ╔═╡ 59917d7d-c36d-4e6a-9c22-3c1b542390d4
md"Note que precisamos separar o `!` do `=` acima para que o compilador não tentasse interpretar o texto como o operador 'diferente': `!=`."

# ╔═╡ 0e321fe1-4e48-4ff9-b85d-ee08c5748c39
@time try_proj(10_000)

# ╔═╡ ef1137fe-9a90-41ba-ad35-68377c0d67b2
# Automatic vectorization
function projB2!(x, lb, ub)
    x .= min.(ub, max.(x, lb))
end

# ╔═╡ 9e872e03-f021-439c-957b-034d1b4a50ad
@time try_proj(10_000, 1000, projB2!)

# ╔═╡ 0250ffb7-bb19-4ec3-b724-bd6f64483aa7
begin
	# Are the resulsts the same?
	
	# Create a random Box
	n = 1000
	lb, ub = rand(n), 100 .+ rand(n)

	# Create a random starting point
	x1 = 1000*(rand(n) .- 0.5)
	x2 = copy(x1)

	# Project with both functions and 
	projB!(x1, lb, ub)
	projB2!(x2, lb, ub)
	x2 == x1
end

# ╔═╡ e54193ca-9385-4d9e-a8dc-38548832c0a9
md"## Primeiros passos

## Variáveis em Julia
"

# ╔═╡ d51b1a60-ce1f-4cf0-a50b-57d981415b1a
a = 1

# ╔═╡ 8d4e7f36-72c0-49d7-903c-9a85f71b6b5b
name = "João"

# ╔═╡ bba0cfca-8885-47e9-a7c8-585fc28afad0
pi

# ╔═╡ aa4cdbf0-bd3e-47a6-bed8-55fe3902a1a2
Float64(pi)

# ╔═╡ 29bb30f0-154a-4d7c-872a-07f4302b5877
BigFloat(pi)

# ╔═╡ 61386d0c-9bca-47d2-9893-a9dff6f1f0c2
typeof(a), typeof(name), typeof(pi), typeof(Float64(pi))

# ╔═╡ c39c0df0-dd13-425b-94bf-a760f86bf910
# It has rational numbers too.
1 // 2 + 3 // 5

# ╔═╡ d14e7b8f-bc33-4b43-b028-6f6bd1860f43
# Division operator returns floats
5 / 5, div(5, 5), 5 % 4, mod(5, 4), 5 ÷ 5

# ╔═╡ a64867b9-6f80-46af-ae37-b65cb2752077
# Automatic conversion when needed.
1 + 2.3, 1/2^64, 1//2 + 0.7, 1 + pi

# ╔═╡ ad3caf7b-6e93-4611-bf8e-380d86bcd3a3
md"## Atividade

1. Escreva um código para calcular a área de um círculo de raio 2.
1. Defina uma variável `r`, defina-a como `2.0`, calcule a área de um círculo de raio `r`. Altere `r` e use a mesma expressão para calcular a nova área.

Obs: As setas para cima e para baixo são suas amigas.
"

# ╔═╡ 2341fd39-1974-48ed-a657-71a4e7e1da97
# Put code here or create more cells if necessary

# ╔═╡ 9679ad35-5c71-4421-a2ef-ca63bd8e6175
md"## Operações lógicas e `if-then-else`"

# ╔═╡ 0d05dd12-19a6-41ba-9d9f-54129abdba7b
# Comparisons return Boolean values
4 > 5, 1 / 0 == Inf, 1 / 0 >= 5, NaN > 5, NaN < 5

# ╔═╡ 975e3a76-c4be-4300-ba04-72ba9fb93bf0
# They can be used in if-then-else statements
if name == "Joazinho"
    println("Hi, João!")
else
    println("I don't know you...")

# Julia close blocks with an end
end

# ╔═╡ d2ce5b58-467f-4e58-9e87-3bd6ab45bf37
# There is also the ternary operator from C
5 > 4 ? println("Bigger") : println("Smaller or equal")

# ╔═╡ 9d4608d1-765d-4f46-83c2-68d641c5dcf4
# Booleans operators come from C
5 > 4 && 2 >= 5

# ╔═╡ 908def08-772f-4e20-9408-3e2348e230ad
5 > 4 || 2 > 5

# ╔═╡ 2cef1f21-5265-47f2-87cc-0231a1b153c7
!(5 > 4)

# ╔═╡ 8c7aa7ce-c1d0-47b6-beea-6eb3db8564f5
md"""## Atividades

1. Experimente diferentes operadores booleanos com strings (texto entre aspas duplas). Por exemplo, `"abc" <= "abcd"`.
2. Tenha cuidado com os operadores booleanos `||` e `&&` que usam caracteres repetidos. Experimente `1 | 2`, você consegue adivinhar o que é `|`?
"""

# ╔═╡ 0005817d-8e28-459e-8512-10886eed581a
# Put code here or create more cells if necessary

# ╔═╡ de9c9bcf-a0bd-485b-9e36-c37ec96c2e2c
md"## Laços

Julia tem dois laços principais:
```Julia

for i in iterator
    # Body
end

while condition
    # Body
end
```
"

# ╔═╡ f32f0d1e-8316-42cd-bf72-3bd0fb2f583c
steps = 10_000_000   

# ╔═╡ d5b09999-f8aa-4727-b178-cd76059ed57a
begin
	acc = 0.0f0
	for k in 1:steps
	    acc += 1.0f0 / (k * k)
	end
	acc
end

# ╔═╡ e3af9d60-089d-4e2f-a45e-51ab91d9a2aa
acc ≈ pi^2 / 6.0

# ╔═╡ 07ea57a0-0994-4387-a07c-71ad4ac4393f
isapprox(acc, pi^2 / 6.0, rtol=eps(1.0f0))

# ╔═╡ b0aaba1f-48b4-4369-b6ca-552b59dfa399
begin
	# Ops... wrong way
	acc2 = 0.0f0
	for k ∈ steps:-1:1
	    acc2 += 1.0f0 / (k * k)
	end
end

# ╔═╡ 673e6f33-a246-4cb4-820b-b4669ae9985a
acc2 ≈ pi^2 / 6.0

# ╔═╡ 4d8194db-2692-47ad-89a2-8f68a3f80cbc
isapprox(acc2, pi^2 / 6, rtol=eps(1.0f0))

# ╔═╡ b36f25f6-ae7f-4965-97dc-c00ff06550d0
begin
	tries = 1
	while rand() < 0.9
    	println("Try again!")
		tries += 1
	end
	tries
end

# ╔═╡ 11a6da77-bec3-45d7-bd9a-a5ffb7b14101
begin
	# There is also break and continue statements
	k = 0
	while true
	    k += 1
	    if k % 2 != 0
	        continue
	    end
	    println("$k is even.")
	    if k > 6
	        break
	    end
	end
end

# ╔═╡ 2a1011ba-53cc-4e01-9709-d53b8c8ab7d5
# You can nest loops
for i ∈ 1:3
    for j ∈ 1:2
        print("($i,$j) ")
    end
end

# ╔═╡ 60784f5e-7776-45a1-be7e-b0b60d27b9d0
# If the index don't depend on each other you have a shorter version.
for i ∈ 1:3, j ∈ 1:2
    print("($i,$j) ")
end

# ╔═╡ 56ac40ac-8d7a-4b39-81cc-8c8c51279cc2
md"## Atividade

1. Escreva um loop infinito (com `while true`) que selecione um número aleatório de 1 a 10 (usando `rand(1:10)`) e pare se for maior que 8. Faça o loop contar quantas tentativas foram necessárias.
"

# ╔═╡ 19a3d326-7688-459b-828e-ee76f296bd86
# Put code here or create more cells if necessary

# ╔═╡ 1b36bb7e-2172-47f6-9b54-6237c489b243
md"## Funções"

# ╔═╡ a1d6c6d4-9b86-4aef-a58a-255f1c10a96b
begin 
	# For simple functions you can use mathematical notation
	foo(x) = x + 1

	# Functions can have different signatures
	foo(x, y) = x + y
end

# ╔═╡ 669f1391-ec62-4450-b51a-5ba30a026405
begin
	# Functions (and code) can be stored in files
	include("functions.jl")

	foo(13, 3)
end

# ╔═╡ 31f61d5b-35ae-4986-a543-c8c1fcf27ed5
foo(1)

# ╔═╡ 6465ba3e-43ec-49d1-a166-b01a64efc120
foo(2, 3)

# ╔═╡ 68662eed-b3a2-4adf-9e78-c820f25e5817
# For more complicated functions, there is a long form
function sumeven(n)
    acc = zero(n)
    for i = 1:n
        if i % 2 == 0
            acc += i
        end
    end
    return acc 
end 

# ╔═╡ 4c2f1002-6880-433f-b8b0-8fb9f4f4af08
# Integer is faster
@time sumeven(100_000_000)

# ╔═╡ 6dad9963-11d9-4e54-8746-2f1ce7265fe2
# If you change the input types, a new version of the function
# is compiled and executed
@time sumeven(100_000_000.0)

# ╔═╡ f14c981c-6a61-4c22-b8a9-8ad69d1ae9a4
# Function parameters can have default values 
inc(x, step = 1) = x + step 

# ╔═╡ ebc6d944-9e6b-409a-a14e-9a047c02511c
inc(1)

# ╔═╡ 20c74bb5-2693-49eb-b064-882dd5b250ec
inc(1, 5)

# ╔═╡ e6019850-3b41-43f9-9f29-3b4095375587
# Functions can have keyword arguments
my_norm(x; p = 2) = sum(abs(x[i])^p for i = 1:length(x))^(1/p)

# ╔═╡ 9be073f8-d60f-4618-a313-4c114ec27c1d
my_norm([1, 2])

# ╔═╡ ecb71d78-3fcd-457b-bc77-d553bd44ca0a
my_norm([1, 2], 1)

# ╔═╡ ed80c992-f4ae-4b8a-9129-a109fa9e43d5
my_norm([1, 2], p = 1)

# ╔═╡ 383a64b0-bcd7-455e-bd83-b14e1cf72cbf
# A function can return multiple values
function divmod(a, b)
    return a ÷ b, a % b
end

# ╔═╡ 9b20ecb7-1f63-4410-8a76-913599b0ec44
begin
	quoc, remainder = divmod(5, 2)
	print("Quotient = $quoc, remainder = $remainder.")
end

# ╔═╡ 26c0f5a5-dbcc-45e8-a0de-ef20613fc4e3
# Functions that change paramaters inplace have, conventionally, a ! at the end of the name
function vecinc!(x) 
    x .= inc.(x, 1)
end

# ╔═╡ 99e9a000-6ea0-4139-96fc-95cec4b4998a
# ╠═╡ disabled = true
#=╠═╡
begin
	x = [1 ,2]
	vecinc!(x)
	x
end
  ╠═╡ =#

# ╔═╡ 696cde3f-b88b-4ec4-977e-3038b0c21271
bar(13, 3)

# ╔═╡ f9ac430c-942c-41c7-8471-31dc10010a26
md"# Atividade

1. Lembra-se da fórmula da área do círculo? Escreva uma função que calcule a área dada `r`.
1. Experimente a função com `2`, `2.0`, `2.0f0` e `BigFloat(2.0)`. Veja que chamadas diferentes possuem tipos de retorno diferentes. Você pode explicá-los?
"

# ╔═╡ c159f276-4bcf-4f81-90b4-37c54b2241f4
# Put code here or create more cells if necessary

# ╔═╡ 7109b12f-ca39-46d6-bf9c-3c2fd05b68ba
md"# Vetores e matrizes

* Em Julia, vetores e matrizes são estruturas de dados indexáveis ​​homogêneas.
* Os índices começam em 1 e terminam em `length(x)`.
* As matrizes são armazenadas por coluna (estilo Fortran).
* Existe uma sintaxe especial para criar e manipular vetores e matrizes.
* Eles podem crescer e aceitar novos valores.
* Se você agora dimensiona no momento da criação, poderá se beneficiar do `StaticArrays.jl`
"

# ╔═╡ 8d6e7a4f-5d7f-4f94-abc1-3113f10c7171
# Create a vector
x = [1, 2, 3]

# ╔═╡ 4ab388f8-2281-4a2e-807c-97ae3ac2b9e7
typeof(x)

# ╔═╡ 47ea0a4c-b824-42df-a590-e89dcd55e22c
# Create a matrix
# Whitespaces separe values, new lines are for convenience
A = [1.0 2.0 3.0;
     4.0 5.0 6.0;
     7.0 8.0 9.0]

# ╔═╡ ee91ec53-7d30-4c1a-bbdc-7c8eb4990e32
A*x

# ╔═╡ 6da67a71-420c-4419-8613-0f246d914e8b
begin
	# You can create an empty vector and build from it
	y = Float64[]
	@show y
	append!(y, 1)
	@show y
	append!(y, 3.0)
	@show y
	y = vcat([5, 6, 7], y)
	@show y
end

# ╔═╡ 9b5e6abc-9af3-4649-9634-7152e02b6400
# The dot notation is inspired in the .* operator from Matlab
# It can be used to apply any operation on a vector
# It can be used to avoid creating intermediaries
sin.(y)

# ╔═╡ 768b8be6-6fd2-4aed-a314-1c54c2f5dca2
sin_plus_cos(x) = sin(x) + cos(x)

# ╔═╡ b340b38a-5dcd-42b7-b334-af92c4a5c330
sin_plus_cos.(y)

# ╔═╡ cdbb1022-68d0-4ec3-abe2-21ee40683670
begin
	y2 = copy(y)
	y2 .= y2 .+ sin.(y2) .+ 5
	# Sometimes there are too many dots.
	# @. apply the dot whenever possible
	y3 = copy(y)
	@. y3 = y3 + sin(y3) + 5 
	
	y2 == y3
end

# ╔═╡ efe174c9-c6df-4582-992a-67f803a27eb7
begin
	y4 = copy(y3)
	y4[end] = 5.0
	y4 == y3
end

# ╔═╡ 1b6730d0-50be-4bae-a4e5-1be32deb7474
begin
	# There are many helper functions to create vectors and matrices
	B = zeros(3, 3)
	B[3, 3] = 10.0
	B
end

# ╔═╡ d2e5a2e2-dcdb-4a86-badc-d5f3ce0e4ae8
zero(A)

# ╔═╡ ae0f0f10-c637-4055-9e0d-e40e981d1f4f
# Same shape and type but undefined
similar(A)

# ╔═╡ 6709f679-fe20-4fdb-9a75-1c305fcbfa55
# Dimension related functions
size(A)

# ╔═╡ 9cc77dea-94c9-4d9b-ac03-7da6bf10baf8
length(A)

# ╔═╡ 2f9711c9-8e2b-4625-80e5-e9d4cf0763a0
# Shares the same data as A
vec(A)

# ╔═╡ 02f4f85d-277f-47af-bdd0-4b7e521e59c8
# Vector and matrix indexing
# They create copies and not views (different from Python and maybe Matlab)
y5 = vcat(y, 2*y, 3*y)

# ╔═╡ e144452a-5585-4c5a-b9c8-623bc780b551
y5[1:2:end]

# ╔═╡ 10a849be-cd6e-4006-9110-13764d8fcc7f
y[end: -1: end - 5]

# ╔═╡ bc14c603-a31e-486a-8215-a19ed38a84b1
C = A + rand(3, 3)

# ╔═╡ f5db6498-3864-4ea0-83de-31933637253c
A[1:2:end, 2:end]

# ╔═╡ acaa2047-c87e-4fd1-9332-7a398aaa4b2e
md"""
# Atividades

1. Escreva uma função que receba dois vetores `x` e `y` e retorne um vetor cujas entradas são as entradas de `x` e `y` multiplicadas. Tente escrevê-lo primeiro usando um operador "pontilhado" e depois um loop explícito.
"""

# ╔═╡ 5b027021-5061-4529-b40d-561260a3c5ab
# Put code here or create more cells if necessary

# ╔═╡ 4d8d4342-adca-491e-aa71-cf15cfcc0a05
md"# Estruturas de dados (contêineres)

Julia tem duas estruturas de dados usuais além de arrays:

1. Tuplas: lista imutável de elementos
1. Dicionários: mapeia chaves para valores

Também é possível definir novos tipos combinando tipos existentes"

# ╔═╡ eae70dad-eb70-4f6f-9d24-0ed8b8baa46d
md"# Tuplas"

# ╔═╡ 48c07054-33ab-4f11-9560-5e27a2e5ff6b
# ╠═╡ disabled = true
#=╠═╡
# Tuples are single list of elements that are immutable
t = (1, 2, 3)
  ╠═╡ =#

# ╔═╡ 2d04c4c1-67e6-46cb-bfd1-f3ff6e0819a3
# The parenthesis are actually optional
t = 1, 2, 3

# ╔═╡ 4f0ebfe0-bf39-41b6-8945-b9e6ec3450c7
# You access them with indexes
t[1], t[3]

# ╔═╡ ac5a8fa5-1647-4216-84a3-6e7234116ae9
begin
	# They can be destructured (you did this when receiving multiple output values)
	first, second, third = t
	print("First = $first, second = $second, third = $third")
end

# ╔═╡ f166a4bc-aefa-4b2a-8316-82c7c615bfc3
# You can convert them to arrays with
v1 = collect(t)

# ╔═╡ 629ce257-ec35-4921-a673-4a5064ffd5c5
v2 = [i for i ∈ t]

# ╔═╡ 8731aeaf-a9b9-4542-960a-438c58c1207f
v3 = [t...]

# ╔═╡ a761dc45-8b46-40cb-998c-22d5435ddbe5
md"# Tuplas nomeadas

Julia nomeou tuplas, elas funcionam como tuplas, mas possuem uma sintaxe alternativa para acessá-las."

# ╔═╡ d78f98fd-f27f-4c4f-b817-a7b15e4f7745
nt = (x = 1.0, y = 1.0, z = 2.5, t = 0.1)

# ╔═╡ 323b82c9-e82a-4639-83c1-4f51cfee756a
nt.x

# ╔═╡ 7768d591-e160-4ed7-8c25-60518c7ba0fe
nt.t

# ╔═╡ 9bc138e6-01b6-4574-8bda-9133b65ff0eb
md"Você pode usar isso para agrupar dados em um único objeto e ainda ter uma maneira natural de acessá-los."

# ╔═╡ b50fc8ea-61dd-4f0e-8842-999a5a659b84
md"# Dicionários

Eles são um pouco como tuplas nomeadas, mas podem ser modificados"

# ╔═╡ 5e642c93-e478-472f-902c-f1023528e6ff
begin
	d = Dict("a" => 1.0, "b" => 2.0, 2 => 3.0)
	@show d
	# You can add to it, or change a value
	d["c"] = 4.0
	d["a"] = 0.0
	@show d
	# You can remove elements
	delete!(d, "a")
	@show d
end

# ╔═╡ f83c8861-ccc8-4ab1-8977-b65e3e460ce7
# To access elements you use the keys
d["c"], d[2]

# ╔═╡ e8cf39a5-1d94-4c0a-b832-610aa5f47d69
md"""
# Iterando

* Você pode iterar em contêineres, se implementar a interface *iterator*.
* Todos os tipos de contêiner que vimos implementá-lo.
"""

# ╔═╡ 67e6cbdf-f257-4362-91b7-08fec1f4e040
# In vectors you iterate values
for e ∈ y
    print("$e ")
end

# ╔═╡ a3dfcb00-4ccb-47d5-9050-b980c1e12e8a
# As in tuples
for e ∈ t
    print("$e ")
end

# ╔═╡ 277f923c-6e63-46c9-ba53-b0d6444d21d3
# As in named tuples
for e in nt
    print("$e ")
end

# ╔═╡ f9331cf7-70f9-4415-a851-fe7ca99bc46f
# But in dictionaries you iterate in (key, value) pairs 
for k in d
    println(k[1], " => ", k[2])
end

# ╔═╡ 217493f0-7062-4d65-a953-e4bcf446db7a
keys(d)

# ╔═╡ 77bf3e56-4f84-40c9-8277-8aedd0ab055f
md"# Atividade

1. Escreva uma função que recebe uma lista e retorna um dicionário que mapeia as entradas da lista de acordo com o número de vezes que elas aparecem (na lista). Você pode achar o `haskey` útil. Você pode consultar seu manual digitando `?` seguido de `haskey`."

# ╔═╡ db736d47-86cb-47b3-aa18-e1126aba2a78
# Put code here or create more cells if necessary

# ╔═╡ 2500b191-f72b-4151-a197-0aae3cc9f214
md"# Estruturas

Em Julia você usa `struct` para definir novos tipos compostos (como em C).
"

# ╔═╡ c422115a-9e1d-43e9-97de-d233a0d267b5
# Note that we define the type of the fields (not mandatory)
struct Student
    id::Int
    name::String
    course::String
end

# ╔═╡ e5ba35f9-f4fe-48e5-8d3a-6d085fbb083b
# You create a new Student calling its default constructor
s1 = Student(123, "Mary Jane", "Applied Math")

# ╔═╡ 28804e83-5f6f-4f5c-9ae7-cf5f7035466c
# Access of fields use the usual dot notation
s1.name

# ╔═╡ 6ee8ec25-19d6-45fb-b30d-d7a3cca0ddf2
begin
	# Student is a new type you can create vectors of it
	vs = Student[]
	push!(vs, s1)
	push!(vs, Student(1234, "Peter John", "Biology"))
	vs
end

# ╔═╡ fa572974-ff1b-4eb7-a332-890f57d5e5db
md"# Mutável vs imutável

Você não pode alterar os valores de uma estrutura (imutável).
"

# ╔═╡ e867f254-5ff9-45a8-98d1-5022214a475b
s1.name = "Maria João"

# ╔═╡ 8db7ae76-46a0-4c67-af49-42d448e4309d
# You need to declare the struct as muttable
mutable struct Point
    x::Float64
    y::Float64
end

# ╔═╡ 8d4f5080-32d6-48fd-bdf0-b0f1266d0fd4
begin
	p = Point(1.0, 2.0)
	@show p
	p.x = 0.0
	@show p
end

# ╔═╡ 5aadb9fe-6ffc-4421-aae2-fe3612344499
md"# Mutável vs imutável

Contêineres são objetos mutáveis, portanto atribuição é apenas criar um apelido"

# ╔═╡ c41fc440-e51f-4f62-a0b2-052935c9b0cc
y

# ╔═╡ 4a96d8fd-b641-4baf-bc11-612d0a0b003b
begin
	z = copy(y)
	z[1:2:end] .= 1.0
end

# ╔═╡ 35d6005a-22f3-4d63-8180-e8d329f8a669
y

# ╔═╡ a844ca05-7bce-4f03-9fd2-e76a1654d121
z

# ╔═╡ 6824c20b-3c65-4a02-a4b6-bfe492489056
md"# Anotação de tipo

Em Julia os tipos das variáveis são definidos de forma implícita por atribuição. O compilador da linguagem tentar manter a informação sobre os tipos e inferir tipos que não estejam tão explícitos. Como por exemplo o que é devolvido ao chamar uma função ou uma seqüência delas.

Você pode anotar o tipo de variável ou argumentos de funções para fornecer dicas ao compilador e impor tipos.
"

# ╔═╡ f8734983-5c25-44fa-8ceb-92e7d66cd90e


# ╔═╡ 05e615d3-4a8c-44d5-a4ce-23aaf58bb307
# At variable definition it works like an assertion/convertion
ann::Int = 1.5

# ╔═╡ b6c607dc-6cb4-40eb-8d75-c65f58d7187f
ann2::Int = 1.0

# ╔═╡ 89b03e8a-8c72-40d7-b04b-5735dd619b8c
# At function definition, declares that function only for that type (or subtypes)
function add_vec(v1::Vector, v2::Vector)
    w = similar(v1)
    for i in eachindex(v1)
        w[i] = v1[i] + v2[i]
    end
    return w
end

# ╔═╡ f14adefd-f50e-43a5-a0c3-cb5eebef8c4e
add_vec([1, 2, 3], [4, 5, 6])

# ╔═╡ a6456f07-a4a0-433e-aa8b-8e0b94bb9f63
# It does not work for matrices
add_vec([1 2; 3 4], [5 6; 7 8])

# ╔═╡ a67ee68e-df1e-4b3b-8538-b37341b84513
md"Esse tipo de uso pode ser importante em *pontos quentes* do código em que a performance é fundamental. Essas porções de programa podem ser **encapsuladas em um função que anota os tipos de entrada e os tipos de outras variáveis para dar informação suficiente para o compilador otimizar o código ao máximo.**
"

# ╔═╡ e678956b-5d63-4557-909c-444f18f15b40
md"# Atividade

1. Escreva dois métodos com o mesmo nome foo:
2. Se receber dois Ints retorna a diferença.
3. Se receber dois Float64 ele retorna a soma deles.
"

# ╔═╡ a6c2e6be-9646-448c-84f4-ab830e8e0533


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
MKL = "33e6dc65-8f57-5167-99aa-e5a354878fb2"

[compat]
MKL = "~0.6.2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.1"
manifest_format = "2.0"
project_hash = "0b3f3dbbe8e7ad52198cfec554fee9d8486acfec"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.0+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ad37c091f7d7daf900963171600d7c1c5c3ede32"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2023.2.0+0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MKL]]
deps = ["Artifacts", "Libdl", "LinearAlgebra", "MKL_jll"]
git-tree-sha1 = "0e25aae49a4a43b3a03eb7ac7aba8473c60a87d2"
uuid = "33e6dc65-8f57-5167-99aa-e5a354878fb2"
version = "0.6.2"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "eb006abbd7041c28e0d16260e50a24f8f9104913"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2023.2.0+0"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─68e30962-c114-11ee-0bb4-0bcc86e07482
# ╟─0a76ed15-2d8d-4dc1-a844-81855915619a
# ╠═5a491971-f15a-45d9-a5ea-4dcfda6a1dbd
# ╠═b21168c0-10fd-4791-b995-54a3c645350c
# ╠═59c0e855-2535-493c-923c-d1c18ddde93c
# ╠═fdb914af-f7a2-4e8e-b5ac-e1cabc71e175
# ╠═b6573693-3bab-4fbf-8f5b-8d891b6e0bc1
# ╟─59917d7d-c36d-4e6a-9c22-3c1b542390d4
# ╠═0e321fe1-4e48-4ff9-b85d-ee08c5748c39
# ╠═ef1137fe-9a90-41ba-ad35-68377c0d67b2
# ╠═9e872e03-f021-439c-957b-034d1b4a50ad
# ╠═0250ffb7-bb19-4ec3-b724-bd6f64483aa7
# ╟─e54193ca-9385-4d9e-a8dc-38548832c0a9
# ╠═d51b1a60-ce1f-4cf0-a50b-57d981415b1a
# ╠═8d4e7f36-72c0-49d7-903c-9a85f71b6b5b
# ╠═bba0cfca-8885-47e9-a7c8-585fc28afad0
# ╠═aa4cdbf0-bd3e-47a6-bed8-55fe3902a1a2
# ╠═29bb30f0-154a-4d7c-872a-07f4302b5877
# ╠═61386d0c-9bca-47d2-9893-a9dff6f1f0c2
# ╠═c39c0df0-dd13-425b-94bf-a760f86bf910
# ╠═d14e7b8f-bc33-4b43-b028-6f6bd1860f43
# ╠═a64867b9-6f80-46af-ae37-b65cb2752077
# ╟─ad3caf7b-6e93-4611-bf8e-380d86bcd3a3
# ╠═2341fd39-1974-48ed-a657-71a4e7e1da97
# ╟─9679ad35-5c71-4421-a2ef-ca63bd8e6175
# ╠═0d05dd12-19a6-41ba-9d9f-54129abdba7b
# ╠═975e3a76-c4be-4300-ba04-72ba9fb93bf0
# ╠═d2ce5b58-467f-4e58-9e87-3bd6ab45bf37
# ╠═9d4608d1-765d-4f46-83c2-68d641c5dcf4
# ╠═908def08-772f-4e20-9408-3e2348e230ad
# ╠═2cef1f21-5265-47f2-87cc-0231a1b153c7
# ╟─8c7aa7ce-c1d0-47b6-beea-6eb3db8564f5
# ╠═0005817d-8e28-459e-8512-10886eed581a
# ╟─de9c9bcf-a0bd-485b-9e36-c37ec96c2e2c
# ╠═f32f0d1e-8316-42cd-bf72-3bd0fb2f583c
# ╠═d5b09999-f8aa-4727-b178-cd76059ed57a
# ╠═e3af9d60-089d-4e2f-a45e-51ab91d9a2aa
# ╠═07ea57a0-0994-4387-a07c-71ad4ac4393f
# ╠═b0aaba1f-48b4-4369-b6ca-552b59dfa399
# ╠═673e6f33-a246-4cb4-820b-b4669ae9985a
# ╠═4d8194db-2692-47ad-89a2-8f68a3f80cbc
# ╠═b36f25f6-ae7f-4965-97dc-c00ff06550d0
# ╠═11a6da77-bec3-45d7-bd9a-a5ffb7b14101
# ╠═2a1011ba-53cc-4e01-9709-d53b8c8ab7d5
# ╠═60784f5e-7776-45a1-be7e-b0b60d27b9d0
# ╟─56ac40ac-8d7a-4b39-81cc-8c8c51279cc2
# ╠═19a3d326-7688-459b-828e-ee76f296bd86
# ╟─1b36bb7e-2172-47f6-9b54-6237c489b243
# ╠═a1d6c6d4-9b86-4aef-a58a-255f1c10a96b
# ╠═31f61d5b-35ae-4986-a543-c8c1fcf27ed5
# ╠═6465ba3e-43ec-49d1-a166-b01a64efc120
# ╠═68662eed-b3a2-4adf-9e78-c820f25e5817
# ╠═4c2f1002-6880-433f-b8b0-8fb9f4f4af08
# ╠═6dad9963-11d9-4e54-8746-2f1ce7265fe2
# ╠═f14c981c-6a61-4c22-b8a9-8ad69d1ae9a4
# ╠═ebc6d944-9e6b-409a-a14e-9a047c02511c
# ╠═20c74bb5-2693-49eb-b064-882dd5b250ec
# ╠═e6019850-3b41-43f9-9f29-3b4095375587
# ╠═9be073f8-d60f-4618-a313-4c114ec27c1d
# ╠═ecb71d78-3fcd-457b-bc77-d553bd44ca0a
# ╠═ed80c992-f4ae-4b8a-9129-a109fa9e43d5
# ╠═383a64b0-bcd7-455e-bd83-b14e1cf72cbf
# ╠═9b20ecb7-1f63-4410-8a76-913599b0ec44
# ╠═26c0f5a5-dbcc-45e8-a0de-ef20613fc4e3
# ╠═99e9a000-6ea0-4139-96fc-95cec4b4998a
# ╠═669f1391-ec62-4450-b51a-5ba30a026405
# ╠═696cde3f-b88b-4ec4-977e-3038b0c21271
# ╟─f9ac430c-942c-41c7-8471-31dc10010a26
# ╠═c159f276-4bcf-4f81-90b4-37c54b2241f4
# ╟─7109b12f-ca39-46d6-bf9c-3c2fd05b68ba
# ╠═8d6e7a4f-5d7f-4f94-abc1-3113f10c7171
# ╠═4ab388f8-2281-4a2e-807c-97ae3ac2b9e7
# ╠═47ea0a4c-b824-42df-a590-e89dcd55e22c
# ╠═ee91ec53-7d30-4c1a-bbdc-7c8eb4990e32
# ╠═6da67a71-420c-4419-8613-0f246d914e8b
# ╠═9b5e6abc-9af3-4649-9634-7152e02b6400
# ╠═768b8be6-6fd2-4aed-a314-1c54c2f5dca2
# ╠═b340b38a-5dcd-42b7-b334-af92c4a5c330
# ╠═cdbb1022-68d0-4ec3-abe2-21ee40683670
# ╠═efe174c9-c6df-4582-992a-67f803a27eb7
# ╠═1b6730d0-50be-4bae-a4e5-1be32deb7474
# ╠═d2e5a2e2-dcdb-4a86-badc-d5f3ce0e4ae8
# ╠═ae0f0f10-c637-4055-9e0d-e40e981d1f4f
# ╠═6709f679-fe20-4fdb-9a75-1c305fcbfa55
# ╠═9cc77dea-94c9-4d9b-ac03-7da6bf10baf8
# ╠═2f9711c9-8e2b-4625-80e5-e9d4cf0763a0
# ╠═02f4f85d-277f-47af-bdd0-4b7e521e59c8
# ╠═e144452a-5585-4c5a-b9c8-623bc780b551
# ╠═10a849be-cd6e-4006-9110-13764d8fcc7f
# ╠═bc14c603-a31e-486a-8215-a19ed38a84b1
# ╠═f5db6498-3864-4ea0-83de-31933637253c
# ╟─acaa2047-c87e-4fd1-9332-7a398aaa4b2e
# ╠═5b027021-5061-4529-b40d-561260a3c5ab
# ╟─4d8d4342-adca-491e-aa71-cf15cfcc0a05
# ╟─eae70dad-eb70-4f6f-9d24-0ed8b8baa46d
# ╠═48c07054-33ab-4f11-9560-5e27a2e5ff6b
# ╠═4f0ebfe0-bf39-41b6-8945-b9e6ec3450c7
# ╠═2d04c4c1-67e6-46cb-bfd1-f3ff6e0819a3
# ╠═ac5a8fa5-1647-4216-84a3-6e7234116ae9
# ╠═f166a4bc-aefa-4b2a-8316-82c7c615bfc3
# ╠═629ce257-ec35-4921-a673-4a5064ffd5c5
# ╠═8731aeaf-a9b9-4542-960a-438c58c1207f
# ╟─a761dc45-8b46-40cb-998c-22d5435ddbe5
# ╠═d78f98fd-f27f-4c4f-b817-a7b15e4f7745
# ╠═323b82c9-e82a-4639-83c1-4f51cfee756a
# ╠═7768d591-e160-4ed7-8c25-60518c7ba0fe
# ╟─9bc138e6-01b6-4574-8bda-9133b65ff0eb
# ╟─b50fc8ea-61dd-4f0e-8842-999a5a659b84
# ╠═5e642c93-e478-472f-902c-f1023528e6ff
# ╠═f83c8861-ccc8-4ab1-8977-b65e3e460ce7
# ╟─e8cf39a5-1d94-4c0a-b832-610aa5f47d69
# ╠═67e6cbdf-f257-4362-91b7-08fec1f4e040
# ╠═a3dfcb00-4ccb-47d5-9050-b980c1e12e8a
# ╠═277f923c-6e63-46c9-ba53-b0d6444d21d3
# ╠═f9331cf7-70f9-4415-a851-fe7ca99bc46f
# ╠═217493f0-7062-4d65-a953-e4bcf446db7a
# ╟─77bf3e56-4f84-40c9-8277-8aedd0ab055f
# ╠═db736d47-86cb-47b3-aa18-e1126aba2a78
# ╟─2500b191-f72b-4151-a197-0aae3cc9f214
# ╠═c422115a-9e1d-43e9-97de-d233a0d267b5
# ╠═e5ba35f9-f4fe-48e5-8d3a-6d085fbb083b
# ╠═28804e83-5f6f-4f5c-9ae7-cf5f7035466c
# ╠═6ee8ec25-19d6-45fb-b30d-d7a3cca0ddf2
# ╟─fa572974-ff1b-4eb7-a332-890f57d5e5db
# ╠═e867f254-5ff9-45a8-98d1-5022214a475b
# ╠═8db7ae76-46a0-4c67-af49-42d448e4309d
# ╠═8d4f5080-32d6-48fd-bdf0-b0f1266d0fd4
# ╟─5aadb9fe-6ffc-4421-aae2-fe3612344499
# ╠═c41fc440-e51f-4f62-a0b2-052935c9b0cc
# ╠═4a96d8fd-b641-4baf-bc11-612d0a0b003b
# ╠═35d6005a-22f3-4d63-8180-e8d329f8a669
# ╠═a844ca05-7bce-4f03-9fd2-e76a1654d121
# ╟─6824c20b-3c65-4a02-a4b6-bfe492489056
# ╟─f8734983-5c25-44fa-8ceb-92e7d66cd90e
# ╠═05e615d3-4a8c-44d5-a4ce-23aaf58bb307
# ╠═b6c607dc-6cb4-40eb-8d75-c65f58d7187f
# ╠═89b03e8a-8c72-40d7-b04b-5735dd619b8c
# ╠═f14adefd-f50e-43a5-a0c3-cb5eebef8c4e
# ╠═a6456f07-a4a0-433e-aa8b-8e0b94bb9f63
# ╟─a67ee68e-df1e-4b3b-8538-b37341b84513
# ╟─e678956b-5d63-4557-909c-444f18f15b40
# ╟─a6c2e6be-9646-448c-84f4-ab830e8e0533
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
