### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 97e807b2-9237-11eb-31ef-6fe0d4cc94d3
begin
	using Plots
	using PlutoUI
	using BenchmarkTools
end


# ╔═╡ c05b483f-17d3-4603-8270-bd15ddfcc370
md"Tradução livre de [random_walks.jl](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week7/random_walks.jl)"

# ╔═╡ 5f0d7a44-91e0-11eb-10ae-d73156f965e6
TableOfContents(aside=true)

# ╔═╡ 9647147a-91ab-11eb-066f-9bc190368fb2
md"""
# Conceitos de Julia e programação

- Benchmark: BenchmarkTools.jl.
- Desenhando com loops.
- Programação genérica
- Estruturas mutáveis vs imutáveis.
- Vetores de vetores.
- `cumsum`
"""

# ╔═╡ ff1aca1e-91e7-11eb-343e-0f89d9570b06
md"""
# Motivatição: Dinâmicas de discos rígidos
"""

# ╔═╡ 66a2f510-9232-11eb-3be9-131febc0039f
md"""
Brown observou o **movimento browniano** em 1827: grandes partículas como poeira ou pollen se movimentam na água de maneira aparentemente aleatória. Einstein explicou isso em 1905 como o resultado dos repetidos choques entre as moléculas de água. 

Nós podemos visualizar esse fenômeno com uma simulação de discos rígidos chocando-se uns contra os outros. Apesar da dinâmica não ser aleatória -- já que cada disco segue as leis de Newton -- ao olharmos cada um deles isoladamente o movimento de fato "parece" aleatório.
"""

# ╔═╡ bd3170e6-91ae-11eb-06f8-ebb6b2e7869f
md"""
## Visualizando passeis aleatórios
"""

# ╔═╡ a304c842-91df-11eb-3fac-6dd63087f6de
md"""
Um **passeio aleatório** modela um movimento aleatório no tempo e espaço. A cada passo de tempo o objeto se move em uma direção aleatória. 

Vamos visualisar uma dessas simulações ocorrendo no plano.
"""

# ╔═╡ 798507d6-91db-11eb-2e4a-3ba02f12ba65
md"""
N = $(@bind N Slider(1:6, show_value=true, default=1))
"""

# ╔═╡ 3504168a-91de-11eb-181d-1d580d5dc071
md"""
t = $(@bind t Slider(1:10^N, show_value=true, default=1))

$t \in [1, 10^N]$
"""

# ╔═╡ b62c4af8-9232-11eb-2f66-dd27dcb87d20
md"""
Esse tipo de dinâmica lembra, do ponto de vista qualitativo, a trajetória de
um disco rígido. 

Veremos abaixo como fazer essa simulação de maneira simples e eficiente em Julia.
"""

# ╔═╡ 905379ce-91ad-11eb-295d-8354ecf5c5b1
md"""
# Por que usar passeios aleatórios?

#### Porque devemos fazer modelagem baseada em processos aleatórios?

- Por vezes o processo é tão complexo que não conseguimos levantar todos os dados para sua caracterização completa e nessa situação a hipótese de aleatoridade pode ser uma saída.

- Mesmo que seja _possível_ levantar todos os detalhes, o uso de um modelo simplificado que use aleatoridade pode ajudar na compreesão do processo.

#### Exemplos:


- Preços de ações que sobem e descem.


- Poluentes se dispersando no ar.


- Genes neutros se movendo (transmitindo) numa população.
"""

# ╔═╡ 5c4f0f26-91ad-11eb-033b-2bd221f0bdba
md"""
# Passeio aleatório simples

A versão mais simples é chamado de **passeio aleatório simples**: um objeto "salta" entre inteiros. A cada tempo movendo-se para esquerda e direita.

Cada um desses saltos é uma nova variável aleatória, tomando valores $\pm 1$ a cada passo de tempo, com probabilidades iguais (a $1/2$) nesse caso mais simples. Em outros casos podemos usar uma Bernoulli mais geral.

Para simular isso, precisamos pensar como gerar os saltos.
"""

# ╔═╡ da98b676-91e0-11eb-0d97-57b8a8aadf2a
md"""
## Julia: Avaliação de desempenho (Benchmarking)
"""

# ╔═╡ e0b607c0-91e0-11eb-10aa-53ec33570e59
md"""
Há várias maneira de gerar valores aleatórios $\pm 1$. Vamos aproveitar essa oportunidade para ver mais as técnicas de avaliação de desempenho (benchmarking) medindo o tempo necessário para execução de diferentes soluções e comparar a performance. Nesse caso faremos "micro-benchmarks", em que iremos comparar pequenos trechos de códigos que irão rodar, potencialmente, milhões de vezes. Deste modo pequenas diferenças podem ser importantes.

Vamos, mais uma vez, usar de novo o pacote `BenchmarkTools.jl` que disponibiliza ferrementas simples para fazer essas medidas de tempo e colecionar estatísticas. Um exemplo é a macro `@btime` que ajuda a estimar o tempo real de execução. Para evitar o problema de performance associado a variáveis globais, todos os trechos que serão avaliados serão encapsulados em funções.
"""

# ╔═╡ fa1635d4-91e3-11eb-31bd-cf61c502ad35
md"""
Aqui estão algumas formas diferentes de gerar os passos aleatórios:
"""

# ╔═╡ f7f9e4c6-91e3-11eb-1a56-8b98f0b09b46
begin
	step1() = rand( (-1, +1) )
	
	step2() = 2 * (rand() < 0.5) - 1
	
	step3() = 2 * rand(Bool) - 1
	
	step4() = sign(randn())
end

# ╔═╡ 5da7b076-91b4-11eb-3eba-b3f5849efabb
with_terminal() do
	@btime step1()
	@btime step2()
	@btime step3()
	@btime step4()
end

# ╔═╡ ea9e77e2-91b1-11eb-185d-cd006db11f60
md"""
## Trajetória de um passeio aleatório
"""

# ╔═╡ 12b4d528-9239-11eb-2824-8ddb5e2ba892
md"""
Pronto, agora sabemos como gerar os saltos e até a forma mais eficiente de fazê-lo. Podemos calcular a **trajetória** de um passeio aleatório 1D ao longo de vários passos. A partícula começa em algum ponto, por exemplo no 0, e partir daí inicia os seus saltos.
"""

# ╔═╡ 2f525796-9239-11eb-1865-9b01eadcf548
function walk1D(N)
	x = 0
	xs = [x]
	
	for i in 1:N
		x += step1()
		push!(xs, x)
	end
	
	return xs
end

# ╔═╡ 51abfe6e-9239-11eb-362a-259570250663
begin
	plot()
	
	for i in 1:10
		plot!(walk1D(100), leg=false, size=(500, 300), lw=2, alpha=0.5)
	end
	
	plot!()
end

# ╔═╡ b847b5ca-9239-11eb-02fe-db4d9625bc5f
md"""
Mas como de fato essa simulação é feita? Vamos ver isso abaixo.

# Vamos fazer isso de forma genérica: passeios aleatórios usando tipos
"""

# ╔═╡ c2deb090-9239-11eb-0739-a74379c15ce6
md"""
Sabemos que vamos começar com simulações de passeios aleatórios 1D, mas que depois vamos querer nos mover para simulações no plano, ou mesmo no espaço.

Nesse sentido, já vimos que pode ser uma boa ideia organizar o nosso código em torno de tipos, identificando as operações fundamentais e como elas se combinam para gerar a simulação completa. Vamos fazer isso abaixo.

## O caso unidimensional
"""

# ╔═╡ d420d492-91d9-11eb-056d-33cc8f0aed74
# First we create an abstrct type to allow for general coding when possible.
abstract type Walker end

# ╔═╡ ad2d4dd8-91d5-11eb-27af-6f0c6e61a86a
# A type to represent a walker (a particule) on the line.
struct Walker1D <: Walker
	pos::Int
end

# ╔═╡ d0f81f28-91d9-11eb-2e79-61461ef5b132
# Walkers should be able to tell where they are.
position(w::Walker) = w.pos

# ╔═╡ b8f2c508-91d5-11eb-31b5-61810f171270
# Model a jump, a step, in the random process. Note that we use the
# fastest option from our micro-benchmark.
step(w::Walker1D) = rand( (-1, +1) )

# ╔═╡ 3c3971e2-91da-11eb-384c-01c627318bdc
# Update the Walker position, since Walker is immutable, we opt to create a new Walker representing it in the new position
update(w::W, step) where{W <: Walker} = W(position(w) .+ step)  # W is a type parameter, explain

# ╔═╡ c9228413-1c5b-4ab4-b8d0-dfbbb300bd48
md"### O caso bidimensional

Podemos agora preparar o caso bidimensional, aproveitando a interface descrita acima.
"

# ╔═╡ 23b84ce2-91da-11eb-01f8-c308ac4d1c7a
begin
	struct Walker2D <: Walker
		pos::Tuple{Int64, Int64}
	end
	
	Walker2D(x, y) = Walker2D( (x, y) )
end

# ╔═╡ 5b972296-91da-11eb-29b1-074f3926181e
step(w::Walker2D) = rand( ( (1, 0), (0, 1), (-1, 0), (0, -1) ) )

# ╔═╡ cb0ef266-91d5-11eb-314b-0545c0c817d0
# Run a simulation with N time steps. Note that the code is fully generic using
# only methods associate with Walker types
function trajectory(w::Walker, N)
	ws = [position(w)]

	for i in 1:N
		w = update(w, step(w))
		push!(ws, position(w))
	end
	
	return ws
end

# ╔═╡ 048fac02-91da-11eb-0d26-4f258b4cd043
trajectory(Walker1D(0), 10)

# ╔═╡ 74182fe0-91da-11eb-219a-01f13b86406d
traj = trajectory(Walker2D(0, 0), 10^N)

# ╔═╡ 4c8d8294-91db-11eb-353d-c3696c615b3d
begin
	plot(traj[1:t], ratio=1, leg=false, alpha=0.5, lw=2)
	scatter!([ traj[1], traj[t] ], c=[:red, :green])
	
	xlims!(minimum(first.(traj)) - 1, maximum(first.(traj)) + 1)
	ylims!(minimum(last.(traj)) - 1, maximum(last.(traj)) + 1)
	
end

# ╔═╡ 57972a32-91e5-11eb-1d62-fbc22c494db9
md"""
## Passeios aleatórios como soma de variáveis (aleatórias)
"""

# ╔═╡ 63122dd0-91e5-11eb-34c3-b1b5c87809b8
md"""
Podemos achar mais uma conexão com o assunto da última aula sobre soma de variáveis aleatórias: a posição $S_n$ de um passeio aleatório no instante $n$ é uma variável aleatória que pode ser entendida como a soma de $n$ variáveis aleatórias que são, tipicamente, independentes e identicamente distribuídas (IID):

$$S_n = X_1 + \cdots + X_n,$$

em que cada $X_i$ é uma variável aleatória modelando o $i$-ésimo passo (ou salto) do passeio.

Em princípio, nós podemos usar o método da última aula para modelar esse conceito. Por outro lado isso pode trazer dificuldades, pois estamos interessandos em todos os passos intermediários. 

Note que o valores $S_n$ e $S_{n - 1}$ não são independentes, apesar dos saltos $X_i$ serem. Por exemplo se $S_{n - 1}$ é um inteiro grande, $S_{n}$ também o será. Mas, pelo menos, a dependência não se estende no tempo. Para saber quais os possíveis valores e a distribuição de probabilidade de $S_{n}$, basta conhecer $S_{n - 1}$. O processo é estocástico.
"""

# ╔═╡ bd013582-91e7-11eb-2d79-e18e45f6d639
md"""
## Somas acumuladas
"""

# ╔═╡ c092ab72-91e7-11eb-2bd1-13c8c8bb30e4
md"""
Suponha que geramos os passos $X_i$, ou sejae
"""

# ╔═╡ cfb0f9ba-91e7-11eb-26b5-5f0f59d03cff
steps = rand( (-1, +1), 10 )

# ╔═╡ d6edb326-91e7-11eb-03b1-d93e3bc83ca6
md"""
A trajetória, ou caminho amostrado, do passeio aleatório, é a coleção de posições ao longo to tempo obtidas a partir das _somas parciais_ (estamos considerando que $S_0 = 0$):

$$\begin{align}
S_1 & = X_1 \\
S_2 &= X_1 + X_2 \\
S_3 &= X_1 + X_2 + X_3
\end{align}$$

etc.
"""

# ╔═╡ 4ef42cec-91e8-11eb-2976-0950ffe5de6c
md"""
Nós podemos calcular esses valores através da função `cumsum` (soma acumulada, você terá que escrever sua própria versão dessa função na lista):
"""

# ╔═╡ ace8658e-91e8-11eb-0b9d-4b759635e417
cumsum(steps)

# ╔═╡ b049ff58-91e8-11eb-203b-4f4b5ee5f01f
md"""
Vamos graficar isso:
"""

# ╔═╡ b6775d3a-91e8-11eb-0187-618cb538d142
plot(cumsum(steps), m=:o, leg=false, size=(500, 300))

# ╔═╡ 8b1441b6-91e4-11eb-16b2-d7eadd3fd69c
md"""
# Trajetórias versus evolução de distribuições de probabilidade
"""

# ╔═╡ d1315f94-91e4-11eb-1076-81156e24d2f1
md"""
Até o momento observamos trajetórias individuais de passeios aleatórios. Nós podemos pensar que isso é equivalente a amostrar usando `rand`. Suponha que amostramos milhões ou bilhões de trajetórias do passeio aleatório. A _cada passo do tempo_ podemos pensar na distribuição de probabilidade no _espaço_ considerando todas essas trajetórias. Uma forma de fazer isso é de fato computar todas as trajetórias e calcular histogramas. Outra forma é tentar pensar conceitualmenmte de como as probabilidades se propagam.

Vamos chamar de $p_i^t$ a probabilidade de se estar na posição $i$ no instante $t$. Podemos então nos perguntar qual é a probabilidade de se estar na posição $i$ no instante $t + 1$. Para isso é preciso que no instante anterior a partícula estivesse em uma das posições vizinhas, no caso 1D isso diz que:

$$p_i^{t+1} = \textstyle \frac{1}{2} (p_{i-1}^{t} + p_{i+1}^{t}).$$

Esse tipo de recorrência é por fazes chamada de **equação mestre** (apesar de ser um nome que não explica muito). Ela descreve como a distribuição de probabilidade se propaga no tempo. 

No tempo $t$ podemos pensar que temos toda a distribuição de probabilidade em um vetor $p^t$. Podemos assim escrever uma função que evolui esse vetor de probabilidade no tempo para o próximo instante.
"""

# ╔═╡ b7a98dba-91eb-11eb-3c78-074aa835b5fb
function evolve(p)
	p′ = similar(p)   # make a vector of the same length and type
	                  # to store the probability vector at the next time step
	
	for i in 2:length(p)-1
		p′[i] = 0.5 * (p[i-1] + p[i+1])
	end
	
	p′[1] = 0
	p′[end] = 0
	
	return p′
	
end

# ╔═╡ f7f17c0c-91eb-11eb-3fa5-3bd90bb7044e
md"""
Ops...  você reconhece isso?

Já vimos isso antes! Isso é uma **convolução**, como um núcleo desfocagem unidimensional (com a diferença é que nesse modelo o  `p[i]` não contribui para o valor na mesma posição para o `p′[i]`).
"""

# ╔═╡ f0aed302-91eb-11eb-13fb-d9418ef327a8
md"""
Note que há o mesmo problema das imagens: o que fazer com as bordas? Precisamos especificar **condições de contorno**. No caso acima colocamos 0s na fronteira. Isso corresponde a considerar que qualquer partícula que chega na fronteira em um certo instante do tempo irá escapar do sistema. _Em algumas situações químicas isso está relacionado com um químico que desaparece._ Obs: eu não tenho ideia do que essa frase quer dizer, fica para os nossos colegas químicos esclarecer. 
"""

# ╔═╡ c1062e00-922b-11eb-1f31-ddbd03f8f986
md"""
Também precisamos especificar a condição inicial do sistema $\mathbf{p}_0$. Isso nos diz onde o andarilho está no instante $0$. Vamos colocá-lo no meio do nosso vetor com probabilidade 1 e 0 nas outras posições.
"""

# ╔═╡ 547188ea-9233-11eb-1a89-5ff9468b31f7
function initial_condition(n)
	p0 = zeros(n)
	p0[n ÷ 2 + 1] = 1
	
	return p0
end

# ╔═╡ 2920abfe-91ec-11eb-19bc-935fa1ba0a96
md"""
Vamos tentar visualizar a evolução temporal.
"""

# ╔═╡ 3fadf88c-9236-11eb-19fa-d191ac5a6191
function time_evolution(p0, N)
	ps = [p0]
	p = p0
	
	for i in 1:N
		p = evolve(p)
		push!(ps, copy(p))
	end
	
	return ps
end

# ╔═╡ 58653a70-9236-11eb-3dae-47adc2a77cb4
p0 = initial_condition(101)

# ╔═╡ 5d02f21e-9236-11eb-26ea-6593aa80a2eb
ps = time_evolution(p0, 100)

# ╔═╡ b803406e-9236-11eb-3aad-056b7f2c9b4b
md"""
t = $(@bind tt Slider(1:length(ps), show_value=true, default=1))
"""

# ╔═╡ cc7aaeea-9236-11eb-3fad-2b5ad3962ec1
plot(ps[tt], ylim=(0, 1), xlim=(1, 100), leg=false, size=(500, 300))

# ╔═╡ dabb5766-9236-11eb-3be9-9b33ba5af68a
ps[tt]

# ╔═╡ 8fa1651a-4723-4841-94f2-954dbd9b94eb
sum(ps[tt])

# ╔═╡ 6cde6ef4-9236-11eb-219a-4d20adaf9988
M = reduce(hcat, ps)'

# ╔═╡ 7e8c1a2a-9236-11eb-20e9-57f6601f5472
heatmap(M, yflip=true)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
BenchmarkTools = "~1.2.0"
Plots = "~1.22.3"
PlutoUI = "~0.7.12"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "61adeb0823084487000600ef8b1c00cc2474cd47"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.2.0"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f2202b55d816427cd385a9a4f3ffb226bee80f99"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+0"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "31d0151f5716b655421d9d75b7fa74cc4e744df2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.39.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "dba1e8614e98949abfa60480b13653813d8f0157"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+0"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "c2178cfbc0a5a552e16d097fae508f2024de61a3"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.59.0"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "ef49a187604f865f4708c90e3f431890724e9012"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.59.0+0"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "7bf67e9a481712b3dbe9cb3dac852dc4b1162e02"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+0"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "14eece7a3308b4d8be910e265c724a6ba51a9798"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.16"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "8a954fed8ac097d5be04921d595f741115c1b2ad"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+0"

[[HypertextLiteral]]
git-tree-sha1 = "72053798e1be56026b81d4e2682dbe58922e5ec9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.0"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "c7f1c695e06c01b95a67f0cd1d34994f3e7db104"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.2.1"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a4b12a1bd2ebade87891ab7e36fdbce582301a92"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.6"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "761a393aeccd6aa92ec3515e428c26bf99575b3b"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+0"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "5a5bc6bf062f0f95e62d0fe0a2d99699fed82dd9"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.8"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7937eda4681660b4d6aeeecc2f7e1c81c8ee4e2f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+0"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "a8709b968a1ea6abc2dc1967cb1db6ac9a00dfb6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.5"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "2537ed3c0ed5e03896927187f5f2ee6a4ab342db"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.14"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs"]
git-tree-sha1 = "cfbd033def161db9494f86c5d18fbf874e09e514"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.22.3"

[[PlutoUI]]
deps = ["Base64", "Dates", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "d1fb76655a95bf6ea4348d7197b22e889a4375f4"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.14"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RecipesBase]]
git-tree-sha1 = "44a75aa7a527910ee3d1751d1f0e4148698add9e"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.2"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "7ad0dfa8d03b7bcf8c597f59f5292801730c55b8"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.4.1"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "8cbbc098554648c84f79a463c9ff0fd277144b6c"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.10"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "1162ce4a6c4b7e31e0e6b14486a6986951c73be9"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.5.2"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll"]
git-tree-sha1 = "2839f1c1296940218e35df0bbb220f2a79686670"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.18.0+4"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "c45f4e40e7aafe9d086379e5578947ec8b95a8fb"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+0"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─c05b483f-17d3-4603-8270-bd15ddfcc370
# ╠═97e807b2-9237-11eb-31ef-6fe0d4cc94d3
# ╠═5f0d7a44-91e0-11eb-10ae-d73156f965e6
# ╟─9647147a-91ab-11eb-066f-9bc190368fb2
# ╟─ff1aca1e-91e7-11eb-343e-0f89d9570b06
# ╟─66a2f510-9232-11eb-3be9-131febc0039f
# ╟─bd3170e6-91ae-11eb-06f8-ebb6b2e7869f
# ╟─a304c842-91df-11eb-3fac-6dd63087f6de
# ╟─798507d6-91db-11eb-2e4a-3ba02f12ba65
# ╟─3504168a-91de-11eb-181d-1d580d5dc071
# ╟─4c8d8294-91db-11eb-353d-c3696c615b3d
# ╟─b62c4af8-9232-11eb-2f66-dd27dcb87d20
# ╟─905379ce-91ad-11eb-295d-8354ecf5c5b1
# ╟─5c4f0f26-91ad-11eb-033b-2bd221f0bdba
# ╟─da98b676-91e0-11eb-0d97-57b8a8aadf2a
# ╟─e0b607c0-91e0-11eb-10aa-53ec33570e59
# ╟─fa1635d4-91e3-11eb-31bd-cf61c502ad35
# ╠═f7f9e4c6-91e3-11eb-1a56-8b98f0b09b46
# ╠═5da7b076-91b4-11eb-3eba-b3f5849efabb
# ╟─ea9e77e2-91b1-11eb-185d-cd006db11f60
# ╟─12b4d528-9239-11eb-2824-8ddb5e2ba892
# ╠═2f525796-9239-11eb-1865-9b01eadcf548
# ╠═51abfe6e-9239-11eb-362a-259570250663
# ╟─b847b5ca-9239-11eb-02fe-db4d9625bc5f
# ╟─c2deb090-9239-11eb-0739-a74379c15ce6
# ╠═d420d492-91d9-11eb-056d-33cc8f0aed74
# ╠═ad2d4dd8-91d5-11eb-27af-6f0c6e61a86a
# ╠═d0f81f28-91d9-11eb-2e79-61461ef5b132
# ╠═b8f2c508-91d5-11eb-31b5-61810f171270
# ╠═3c3971e2-91da-11eb-384c-01c627318bdc
# ╠═cb0ef266-91d5-11eb-314b-0545c0c817d0
# ╠═048fac02-91da-11eb-0d26-4f258b4cd043
# ╟─c9228413-1c5b-4ab4-b8d0-dfbbb300bd48
# ╠═23b84ce2-91da-11eb-01f8-c308ac4d1c7a
# ╠═5b972296-91da-11eb-29b1-074f3926181e
# ╟─74182fe0-91da-11eb-219a-01f13b86406d
# ╟─57972a32-91e5-11eb-1d62-fbc22c494db9
# ╟─63122dd0-91e5-11eb-34c3-b1b5c87809b8
# ╟─bd013582-91e7-11eb-2d79-e18e45f6d639
# ╟─c092ab72-91e7-11eb-2bd1-13c8c8bb30e4
# ╠═cfb0f9ba-91e7-11eb-26b5-5f0f59d03cff
# ╟─d6edb326-91e7-11eb-03b1-d93e3bc83ca6
# ╟─4ef42cec-91e8-11eb-2976-0950ffe5de6c
# ╠═ace8658e-91e8-11eb-0b9d-4b759635e417
# ╟─b049ff58-91e8-11eb-203b-4f4b5ee5f01f
# ╠═b6775d3a-91e8-11eb-0187-618cb538d142
# ╟─8b1441b6-91e4-11eb-16b2-d7eadd3fd69c
# ╟─d1315f94-91e4-11eb-1076-81156e24d2f1
# ╠═b7a98dba-91eb-11eb-3c78-074aa835b5fb
# ╟─f7f17c0c-91eb-11eb-3fa5-3bd90bb7044e
# ╟─f0aed302-91eb-11eb-13fb-d9418ef327a8
# ╟─c1062e00-922b-11eb-1f31-ddbd03f8f986
# ╠═547188ea-9233-11eb-1a89-5ff9468b31f7
# ╟─2920abfe-91ec-11eb-19bc-935fa1ba0a96
# ╠═3fadf88c-9236-11eb-19fa-d191ac5a6191
# ╠═58653a70-9236-11eb-3dae-47adc2a77cb4
# ╠═5d02f21e-9236-11eb-26ea-6593aa80a2eb
# ╟─b803406e-9236-11eb-3aad-056b7f2c9b4b
# ╠═cc7aaeea-9236-11eb-3fad-2b5ad3962ec1
# ╠═dabb5766-9236-11eb-3be9-9b33ba5af68a
# ╠═8fa1651a-4723-4841-94f2-954dbd9b94eb
# ╠═6cde6ef4-9236-11eb-219a-4d20adaf9988
# ╠═7e8c1a2a-9236-11eb-20e9-57f6601f5472
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
