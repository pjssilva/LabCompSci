### A Pluto.jl notebook ###
# v0.19.13

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 85b45a43-d7bf-4597-a1a6-329b41dce20d
begin
    using LinearAlgebra
    using SparseArrays
    using Random
    using PlutoUI
    using Plots
    using PlotThemes
    using BenchmarkTools
	using Folds
	using FLoops
end

# ╔═╡ e46441c4-97bd-11eb-330c-97bd5ac41f9e
md"Tradução livre de [random\_walks\_ii.jl](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week8/random_walks_II.jl) + a parte de computação paralela."

# ╔═╡ 85c26eb4-c258-4a8b-9415-7b5f7ddff02a
TableOfContents(aside = true)

# ╔═╡ 2d48bfc6-9617-11eb-3a85-279bebd21332
md"""
# Conceitos de Julia

- Computação paralela.
- Visão customizada de objetos.
- Matrizes estruturadas em Julia.
- `heatmap` (Plots.jl)
- `surface` (Plots.jl)
- Animações (Plots.jl)
"""

# ╔═╡ abbc1d4f-a6d5-444c-a3b0-148979e42ba9
md"""
# Introdução à computação paralela

Nesse cadernos vamos ver uma introdução rápida à computação paralela usando o pacote [`Folds.jl`](https://github.com/JuliaFolds/Folds.jl).

A ideia básica desse pacote é encapsular alguns padrões típicos de paralelismo e disponibilizá-los com uma sintaxe simples e familiar na linguagem. Mas antes disso, vamos ver os três tipos principais de paralelismo:

1. Memória compartilhada: o programa roda em paralelo em múltiplos núcleos (que nada mais são que processadores independentes em uma CPU) que compartilham um mesmo espaço de memória. Isso simplifica muito o processo porque esses processos independentes podem se comunicar simples alterado o valor de variáveis comuns.

2. Memória distribuída: o programa roda em paralelo em nós computacionais distintos, cada um com sua memória. Aqui já é necessário ter ferramentas explícitas para que os vários processos se comuniquem entre si enviando "mensagens" uns para os outros.

3. GPU: o programa roda em um co-processador vetorial que é muito rápido, tem um número enorme de cores, mas não consegue executar instruções complexas, com desvios condicionais, naturalmente. Esse tipo de paralelismo também é conhecido como _vetorial_, já que uma mesma operação é aplicada a um vetor (conjunto grande) de dados ao mesmo tempo (de forma síncrona).

Nessa primeira introdução, vamos focar em operações que são naturalmente paralelas. Isso ocorre quando você tem que fazer várias operações que são independentes entre si o que possuem uma dependência "fraca", que pode ser explorada. A ideia do pacote `Folds.jl` é justamente essa: apresentar ferramentas que permitam explorar situações de paralelismo típica de maneira transparente.

Para isso vamos retomar a ideia de passeios aleatórios da última aula.
"""

# ╔═╡ 3895ae97-9d1d-4ecd-89cf-de4809a3273a
# First we create an abstrct type to allow for general coding when possible.
abstract type Walker end

# ╔═╡ 8e4294f0-a6a9-467b-b9d6-e3facf1d03bd
# A type to represent a walker (a particule) on the line.
struct Walker1D <: Walker
	pos::Int
end

# ╔═╡ 4e0b3cf4-f9a8-4f77-92bd-cd5f1a39e92a
# Walkers should be able to tell where they are.
position(w::Walker) = w.pos

# ╔═╡ 8f4b6cee-b2ec-4c96-9992-0057d35be32a
# Model a jump, a step, in the random process. Note that we use the
# fastest option from our micro-benchmark.
step(w::Walker1D) = rand( (-1, +1) )

# ╔═╡ f0d716f0-2724-4e9c-8868-cdec3dba5b02
# Update the Walker position, since Walker is immutable, we opt to create a new Walker representing it in the new position
update(w::W, step) where{W <: Walker} = W(position(w) .+ step)  # W is a type parameter, explain

# ╔═╡ 689959aa-6548-453f-a631-6abe76d26b40
begin
	struct Walker2D <: Walker
		pos::Tuple{Int64, Int64}
	end
	
	Walker2D(x, y) = Walker2D( (x, y) )
end

# ╔═╡ 42accec8-4db0-4bf1-a1da-9ec07dbee499
step(w::Walker2D) = rand( ( (1, 0), (0, 1), (-1, 0), (0, -1) ) )

# ╔═╡ c361320c-c5a3-44ff-9933-44bb1d82fc62
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

# ╔═╡ c2c27c13-4621-469d-8f42-340d665de687
md"""
Agora, imagine que vamos tentar fazer passeios muito longos e depois calcular estatísticas. Algo como:
"""

# ╔═╡ 6b2d3e1b-2f96-4af3-a116-bce6a8cf8580
T, N = 100_000, 1000

# ╔═╡ b04d3912-8c04-4642-8409-a245f8fb8a0b
ws = trajectory(Walker2D(0, 0), T)

# ╔═╡ c4edc5a6-ccc0-40bc-96f2-c17b7f25dc10
md"""
Mas isso calcula apenas um desses passeios longos. E se precisássemos de mil deles?
"""

# ╔═╡ 4523623e-39ad-44f3-96af-1dfc32d69517
wss = [trajectory(Walker2D(0, 0), T) for i = 1:N]

# ╔═╡ 0c9d5a88-fc7a-4c26-a899-5a9a94f5c940
md"""Quanto tempo isso demora?"""

# ╔═╡ 345c8f7d-649d-4e56-8bc5-c0cab17827ab
@btime wss = [trajectory(Walker2D(0, 0), T) for i = 1:N]

# ╔═╡ d595c3de-851e-4acd-8d74-89d9d5dbcc50
md"""
Vamos pensar um pouco na operação principal executada acima.

`wss = [trajectory(Walker2D(0, 0), T) for i = 1:N]`

Isso gera `N` passeios aleatórios 2D independentes. Esse é o exemplo típico de uma operação massivamente paralela. 

De uma maneira mais geral, vamos pensar em operações do tipo

`v = [f(i) for i in iterador]`

Esse tipo de operação é chamado de **mapeamento**, já que mapeia a função `f` sobre todos os elementos do iterador. Julia possui uma função que faz isso, que servirá de ponto de partida para as nossas paralelizações.

`v = map(f, iterador)`. 

Vamos reescrever o código acima usando essa variação e medir o tempo.
"""

# ╔═╡ 4ce4f93b-86d4-45ed-92a7-59eac9f79c47
a_trajectory(T) =  trajectory(Walker2D(0, 0), T)

# ╔═╡ 8480cc51-83a0-4875-ae0f-4a417a70d0f7
times = fill(T, N)

# ╔═╡ 67b16340-f0f1-40e4-a0ec-16fd45ca97a4
@btime wss = map(a_trajectory, times)

# ╔═╡ 53c31918-b9a5-4caf-95f7-5ea07f05a91b
md"""
Um pouco mais lento, mas vamos relevar. Vamos compensar isso já.

A mágica do `Folds.jl` é que ele implementa uma versão da função `map` que faz o mesmo serviço só que em paralelo, usando múltiplas threads. Primeiro vamos ver quantas threads temos à nossa disposição nesse computador.
"""

# ╔═╡ ee27d51a-f277-4d06-b5a6-f473866c9053
Threads.nthreads()

# ╔═╡ 33f4bbfe-62b3-4182-b1a3-3fdb5fedbaad
md"""E agora vamos fazer o nosso trabalho em paralelo."""

# ╔═╡ 419f6a67-69f8-49fa-9092-8d9f4568d507
pwss = Folds.map(a_trajectory, times)

# ╔═╡ 287300d0-8cbe-48d3-bf26-f0625f3f3874
@btime pwss = Folds.map(a_trajectory, times)

# ╔═╡ 6e29c993-6ca7-4224-b069-4691a2d48284
md"""
Bem melhor!

Uma outra operação que é "fácil" de paralelizar usando `Folds.jl` é a operação de _redução_. Esse tipo de operação atua sobre uma sequência combinando, ou _reduzindo_, valores em sequência, um bom exemplo disso é a somatória:
```math
\sum_{i = 1}^6 i = (((((1 + 2) + 3) + 4) + 5) + 6).
```

Veja, primeiro combinamos o 1 e 2 com o operador `+` (que nada mais é que uma função binária), a resposta com 3, com 4 e por fim com 5.

Quando essa operação de redução pode atuar em partes da sequencia e depois se novamente combinada (ou seja, vale associativa), abre-se espaço para paralelismo mais uma vez. Por exemplo,
```math
\sum_{i = 1}^6 i = (1 + 2 + 3) + (4 + 5 + 6).
```
As duas primeira somas podem ser feitas em paralelos e no final há apenas uma soma para fazer.

Esse tipo de operação também já está implementado em Julia pela função `reduce`.  Vamos usá-la para calcular a média de uma trajetória, agora mais longa.
"""

# ╔═╡ 9aeabeaf-ad07-47f7-ae75-dd86b6bc4e39
T2 = 100_000_000

# ╔═╡ 70fc0697-2c7c-4298-b54e-a91d85d5fcd8
traj = a_trajectory(T2)

# ╔═╡ 3cb8181c-3c0f-4618-8152-d59ad4445f9d
reduce(.+, traj) ./ T2

# ╔═╡ 7a5aff37-b8a6-4058-8918-be44d14eaa02
@btime reduce(.+, traj) ./ T2

# ╔═╡ fb3d6afa-2f82-4e2c-b334-bc7967ff2766
@btime Folds.reduce(.+, traj, init = (0, 0)) ./ T2

# ╔═╡ db9cffca-33ff-4820-b41a-ab0b631c7f35
md"""Agora, almo está estranho, não? E esperaria que a posição média em uma trajetória longa fosse o ponto de partida e não foi isso que vimos. Vamos então calcular a média das posições médias.

Para isso vamos unir os dois conceitos. Vamos primeiro criar uma função que mapeia a duração de uma trajetória na média de uma trajetória aleatória e depois reduzir essas médias por somas e obter a média das médias.
"""

# ╔═╡ 5b0360ed-5eda-40ef-a47d-5f15a24422be
T3, N3 = 1_000_000, 1000

# ╔═╡ 6e15051c-52f5-44a7-835f-85471cb5f577
function mean_trajectory(T3)
	traj = trajectory(Walker2D(0, 0), T3)
	return reduce(.+, traj) ./ T3
end

# ╔═╡ 254f7a34-10a6-4ae7-96b5-a1f0740493c2
mapreduce(mean_trajectory, .+, fill(T3, N3)) ./ N3

# ╔═╡ 25071ece-1484-4df5-b9ca-8f03c9b8d05e
@btime mapreduce(mean_trajectory, .+, fill(T3, N3)) ./ N3

# ╔═╡ a408a0ee-57f4-43c7-ad8a-7cab680f64c2
@btime Folds.mapreduce(mean_trajectory, .+, fill(T3, N3), init = (0, 0)) ./ N3

# ╔═╡ 8db311f4-92e7-44b1-b0b0-de5fd0f9cd21
md"""
Por fim é possível escrever versões mais sofisticadas e eficientes usando laços. Isso é um assunto mais avançado que deixo para vocês estudarem quando sentirem necessidade.
"""

# ╔═╡ 7eb279e3-10b6-4db6-95c9-b8fa08ea29f8
function parallelmean(T, N)
	@floop for i in 1:N
		mt = mean_trajectory(T)
		@reduce s .+= mt
	end
	return s ./ N
end

# ╔═╡ 9a3007ea-3bc8-4ad6-b8f0-dcd09dccd832
parallelmean(T3, N3)

# ╔═╡ c70122e3-b1be-4a10-8b3a-80d12982d76b
@btime parallelmean(T3, N3)

# ╔═╡ 30162386-039f-4cd7-9121-a3382be3c294
md"""
# Triângulo de Pascal

"""

# ╔═╡ 4e7b163e-dfd0-457e-b1f3-8807a4d8060a
md"""
Vamos começar pensando um pouco sobre o triângulo de Pascal. (obs: [Pascal não foi a primeira pessoa a estudar esses números](https://en.wikipedia.org/wiki/Pascal%27s_triangle).)
"""

# ╔═╡ e8ceab7b-45db-4393-bb8e-e000ecf78d2c
pascal(N) = [binomial(n, k) for n = 0:N, k = 0:N]

# ╔═╡ 2d4dffb9-39e4-48de-9688-980b96814c9f
pascal(10)

# ╔═╡ 8ff66523-bc2e-4c53-975b-8ba4f99eb1c6
md"""
As entradas não nulas da matriz são **coeficientes binomiais**: a k-ésima entrada da $n$-ésima coluna é o coeficiente de $x^k$ na expansão de $(1 + x)^n$, iniciando em $n = 0$ na primeira linha e $k = 0$ na primeira coluna.
"""

# ╔═╡ 2868dd57-7164-4162-8c5d-30628dedeb7a
md"""
Observe que há apenas zeros acima da diagonal principal, ou seja a matriz é **triangular inferior**. Esse tipo de matriz, com estrutura especial, é razoavelmente comum em álgebra linear computacional. Julia possui tipos específicos que representam visões de matrizes densas com informações sobre a estrutura especial de algumas matrizes que ocorrem naturalmente em álgebra linear computacional. Ao deixarmos isso claro para o sistema estamos liberando-o para usar rotinas mais especializadas que aproveitem a estrutura. Pense na solução de um sistema linear a partir de uma matriz triangular, por exemplo.

Esse tipos especiais estão definidos no pacote (padrão) `LinearAlgebra`.
"""

# ╔═╡ f6009473-d3c1-444f-88ae-814f770e811b
L = LowerTriangular(pascal(10))

# ╔═╡ 9a368602-acd3-43fb-9dff-e407a4bab930
md"""
Observe que a própria visualização da matriz muda: os zeros _estruturais_ são agora representados por pontos, deixando claro que eles estarão sempre ali.
"""

# ╔═╡ 67517333-175f-48c4-a915-76658cbf1304
md"""
Como já vimos, Julia também possui um tipo para representar matrizes esparsas que poderíamos ter usado nesse caso. Ele está definido na biblioteca (padrão), `SparseArrays`."""

# ╔═╡ d6832372-d336-4a54-bbcf-d0bb70e4de64
sparse(pascal(10))

# ╔═╡ 35f14826-f1e4-4977-a31a-0f6148fe25ad
md"""
Mas de fato, o tipo `LowerTriangular` é mais adequado nesse caso. Ele pega exatamente a estrutura da matriz. De novo, pense no caso da resolução de sistemas lineares. Se queremos resolver um sistema linear com um matriz triangular, não há necessidade de fatorações. Basta usar um algoritmo de substituição. Julia, ao tentar resolver um sistema com uma matriz `LowerTriangular` vai saber isso e usar a estratégia adequada. Já se a matriz fosse "apenas" esparsa, a linguagem iria ainda tentar calcular uma fatoração (esparsa) para resolver sistemas.

Um fato interessante sobre o triângulo de Pascal fica evidente quando destacamos as suas entrada ímpares. Vamos fazer isso e ainda um _Slider_.
"""

# ╔═╡ 7468fc5d-7f35-45e2-b5fc-7e63b562bc8f
@bind n_pascal Slider(1:63, show_value = true, default = 1)

# ╔═╡ 1ca8aa3b-b05d-40f6-a925-2f0248b79ca2
sparse(isodd.(pascal(n_pascal)))

# ╔═╡ 38d88b7c-3b4f-430b-8d3c-f672ab0c7a49
md"""
Note que para matrizes esparsas a representação visual inicia com números, mas depois de um tempo ela passa a enfatizar apenas a estrutura de esparsidade, destacando as entradas não nulas. Isso revela a **estrutura de esparsidade** da matriz: as posições onde encontramos números não nulos. Essas posições são apresentadas com pontos (e os zeros ficam como espaços em branco).
"""

# ╔═╡ f4c9b02b-738b-4de1-9e9d-05b1616bee0b
md"""
O padrão que emerge é bem interessante e é parente próximo de uma outra figura que já vimos: o triângulo de Sierpinski.
"""

# ╔═╡ d1c47afa-ab7f-4543-a161-e3ceb6f11eb4
md"""
Outro fato interessante emerge quando olhamos uma variação do triângulo de Pascal onde entrada (i, j) possui cada coluna fixa o número de elementos dos subconjuntos das combinações.
"""

# ╔═╡ bf78e00f-05d9-4a05-8512-4924ef9e25f7
[binomial(i + j, i) for i = 0:10, j = 0:10]

# ╔═╡ b948830f-ead1-4f36-a237-c998f2f7deb8
md"""
E, ainda mais interessante, essa mesma matriz pode ser obtida do triângulo original usando multiplicação de matrizes.
"""

# ╔═╡ 15223c51-8d31-4a50-a8ff-1cb7d35de454
pascal(10) * pascal(10)'

# ╔═╡ 0bd45c4a-3286-427a-a927-15869be2ebfe
md"""
## Convoluções presentes no triângulo de Pascal
"""

# ╔═╡ 999fb608-fb1a-46cb-82ca-f3f31fe617e1
pascal(6)

# ╔═╡ 6509e69a-6e50-4816-a98f-67ba437383fb
md"""
Esse triângulo ainda guarda várias propriedades, e por isso mesmo é tão estudado e interessante.

Por exemplo, no ensino médio aprendemos que podemos calcular novos valores somando dois **elementos adjacentes nas linhas**. O seu resultado é o elemento abaixo do último elemento somado.
"""

# ╔═╡ e58976a9-1784-441e-bb76-3011538b8ad0
md"""
Notem que esse tipo de operação, somar elementos de uma matriz já existente para obter novos elementos pode ser visto como uma operação de convolução como as operações que fizemos em imagens. É como se fosse uma convolução com a matrix

```
[
1 1 0 
0 0 0 
0 0 0 
]
```
"""

# ╔═╡ 61f9bbfc-09cc-4d0b-b79d-262235ff10a2
md"""
## É mais rápido mesmo?

Vamos fazer alguns testes para ver se Julia é de fato esperta o suficiente para pegar informação de estrutura e aproveitar isso ao fazer, por exemplo, multiplicações de matrizes por vetores e/ou resolução de sistemas lineares.
"""

# ╔═╡ 834e3dce-9a65-4452-b6dc-9a87a86aeb13
begin
    Random.seed!(10)
    dim = 1500
    A = rand(dim, dim)
    ltA = LowerTriangular(rand(dim, dim))
    symA = Symmetric(A + A')
    dpA = Symmetric(A * A')
    spA = sprand(dim, dim, 0.005)
	while rank(spA) < dim
		spA = sprand(dim, dim, 0.005)
	end
    densespA = Matrix(spA)
    b = rand(dim)
end

# ╔═╡ 80acaa77-a399-448b-81f6-3a645d3895be
rank(spA)

# ╔═╡ 6658a4e4-1dbb-457f-95e5-5b59853fae88
begin
    print("General:             ")
    @btime x = $A \ $b
    print("Lower triangular:    ")
    @btime x = $ltA \ $b
    print("Symmetric:           ")
    @btime x = $symA \ $b
    print("Symmetric pos. def.: ")
    @btime x = $dpA \ $b
end

# ╔═╡ af357814-f0a1-48b3-9e49-ee0ad1cee609
begin
    print("Cholesky: ")
    @btime x = cholesky($dpA) \ $b
end

# ╔═╡ 27040653-4639-419f-9c07-a826c9c8f8f5
begin
    print("Linear system with sparse matrix: ")
    @btime x = $spA \ $b
    print("Linear system with dense matrix:  ")
    @btime x = $densespA \ $b
end

# ╔═╡ c4b1a791-e318-47e5-80ed-7476f658f647
begin
	print("Sparse matrix times vector: ")
    @btime y = $spA * b
    print("Dense matrix times vector:  ")
    @btime y = $A * b
end


# ╔═╡ 1efc2b68-9313-424f-9850-eb4496cc8486
md"""
# Relembrando passeios aleatórios

## Variáveis aleatórias independentes e identicamente distribuídas
"""

# ╔═╡ 6e93ffda-217b-4d46-86b5-534ddc1bae90
md"""
A discussão acima sob o triângulo de Pascal e convoluções vai, surpreendentemente, aparecer na discussão abaixo sobre *passeios aleatórios*.

Lembre-se que, num passeio aleatório um passo, ou salto, é escolhido a cada instante do tempo. Digamos para direita ou para esquerda.

Como cada passo é aleatório, eles podem ser modelados usando uma *variável aleatória* que possui uma certa distribuição de probabilidade. Por exemplo, podemos usar uma variável aleatória com valores possíveis $+1$, com probabilidade $\frac{1}{2}$, e $-1$ com mesma chance.

Tipicamente, estudamos passeios aleatórios que possuem todos os passos "iguais". Mas o que quer dizer "igual" nesse contexto? É claro que não pode ser que todos os passos são os mesmos, afinal de contas eles são aleatórios. O igual aqui está relacionado a distribuição dos possíveis valores dos saltos. Ou sejam, todos os passos são *realizações de uma variável aleatória com a mesma distribuição*.

Também consideramos que os passos são *independentes* uns dos outros. Ou seja, que a escolha de uma direção em um passo anterior não influência a escolha em um passo subsequente. Portanto o passeio é descrito por uma **coleção de variáveis aleatórias independentes e identicamente distribuídas (IID)**.
"""

# ╔═╡ 396d2490-3cb9-4f68-8fdf-9209d2010e02
md"""
## Passeios aleatórios como somas acumuladas
"""

# ╔═╡ dc1c22e8-1c7b-43b7-8421-c2ca708931a5
md"""
Como vimos na última aula, os passeios aleatórios podem então ser visto como somas acumuladas dessas variáveis IID. Relembrando, se $S_n$ a posição da partícula no instante $n$ temos que (para um passeio em $S_0 = 0$):

$$S_t = X_1 + \cdots + X_n = \sum_{t^\prime=1}^t X_{t^\prime}.$$

Ainda, como fizemos antes, podemos nos perguntar qual a distribuição de probabilidade da posição $S_t$ para um certo instante $t$ fixo. Podemos também estar interessados em como essas distribuições evoluem no tempo.

A chave para isso é escrever a fórmula recursiva de como os vetores de que descrevem a probabilidade da particular estar na posição $i$ no instante $t$, $p^t_i$. Vimos que isso pode ser capturado por _equações mestre_ como

$$p_i^{t+1} = \textstyle \frac{1}{2} (p_{i-1}^{t} + p_{i+1}^{t}).$$

Ainda na última aula apresentamos uma implementação para calcular como essas probabilidades evoluem e fizemos duas visualizações.

Como discutimos antes, esse processo pode também ser visto como uma aplicação sucessiva de convoluções, assim como o triângulo de Pascal. É muito interessante ver como o mesmo conceito aparece em diferentes lugares.
"""

# ╔═╡ fb804fe2-58be-46c9-9200-ceb8863d052c
function evolve(p)
    p′ = similar(p)   # make a vector of the same length and type
    # to store the probability vector at the next time step

    for i = 2:length(p)-1   # iterate over the *bulk* of the system
        p′[i] = 0.5 * (p[i-1] + p[i+1])
    end

    # boundary conditions:
    p′[1] = 0
    p′[end] = 0

    return p′
end

# ╔═╡ 0b26efab-4e93-4d53-9c4d-faea68d12174
function initial_condition(n)

    p₀ = zeros(n)
    p₀[n÷2+1] = 1

    return p₀
end

# ╔═╡ b48e55b7-4b56-41aa-9796-674d04adf5df
function time_evolution(p0, N)
    ps = [p0]
    p = p0

    for i = 1:N
        p = evolve(p)
        push!(ps, copy(p))
    end

    return ps
end

# ╔═╡ 53a36c1a-0b8c-4099-8854-08d73c9f118e
md"""
Vamos visualizar isso:
"""

# ╔═╡ 6b298184-32c6-412d-a900-b113d6bd3d53
begin
    grid_size = 101
    max_time = 100
    p0 = initial_condition(grid_size)
end

# ╔═╡ b84a7255-7b0a-4ba1-8c87-9f5d3fa32ef3
ps = time_evolution(p0, max_time)

# ╔═╡ 242ea831-c421-4a76-b658-2a57fa924a4f
md"""
t = $(@bind tt Slider(1:length(ps), show_value=true, default=1))
"""

# ╔═╡ d0f89707-eccf-4155-82d5-780643e1b447
plot(ps[tt], ylim = (0, 1), xlim = (1, 100), leg = false, size = (500, 300))

# ╔═╡ 049feaa2-050a-45eb-85a1-75c758c08e87
sum(ps[tt])

# ╔═╡ 65946621-a2af-4370-8c4d-b2207b63fc51
md"# Múltiplas visualizações da mesma informação

Uma das tarefas mais importantes em computação científica é a visualização dos dados e resultados de simulações. Boas visualizações muitas vezes são a diferença entre se entender um fenômeno ou comunicar bem os seus resultados.

Na última aula, apresentamos duas visualizações da evolução das probabilidades. A primeira, apresentada acima e outra onde víamos uma matriz com todas as probabilidades ao longo do tempo.

Vamos agora explorar outras possibilidades de visualização e ensinar mais alguns truques de Julia e Plots.

Uma primeira alteração, é o formato da figura acima com os picos cuneiformes. Eles não estão exatamente corretos, não há uma mudança contínua, e linear, das probabilidades 0 para probabilidades positivas. A mudança é abrupta, são valores discretos. Um gráfico de barras faz melhor esse serviço.
"


# ╔═╡ aeaef573-1e90-45f3-a7fe-31ec5e2808c4
bar(ps[tt], ylim = (0, 1), leg = false, size = (500, 300), alpha = 0.5)

# ╔═╡ 610b2349-9ae6-4967-8b50-9b30b34d18d8
md"""
Uma mudança simples, mas que já produz um resultado mais agradável.

Outra característica é que a visualização acima só consegue capturar a evolução das probabilidades ao deslizarmos o slider. Não seria mais interessantes gerarmos uma animação que evolui a probabilidade no tempo. Por sorte, Plots já tem isso "pronto".
"""

# ╔═╡ 602fb644-bd1d-4f9d-979f-0b190931d649
begin
    anim = @animate for ttt = 1:max_time
        bar(ps[ttt], ylim = (0, 1), leg = false, alpha = 0.5, dpi = 200)
        title!("Time = $ttt")
    end
    gif(anim, fps = 10)
end

# ╔═╡ 1baafa2c-73c6-4e6f-832c-8b5c330b55d7
md"Nada mal para um código tão simples"

# ╔═╡ efe186da-3273-4767-aafc-fc8eae01dbd9
md"""
## Vendo tudo de uma vez: a versão matricial
"""

# ╔═╡ 61201091-b8b3-4776-9be9-4c23d5ba88ba
md"""
Outra opção é olhar todo o vetor de distribuições de probabilidade como fizemos na última aula. Para isso concatenamos todos em uma matriz.
"""

# ╔═╡ 66c4aed3-a04b-4a09-b954-79e816d2a3f7
M = reduce(hcat, ps)'

# ╔═╡ b135f6be-5e82-4c72-af11-0eb0d4141dec
md"""
E podemos reproduzir a visualização da última aula baseada em **mapas de calor**.
"""

# ╔═╡ e74e18e3-ad08-4a53-a803-cd53564dca65
heatmap(M, yflip = true)

# ╔═╡ 4d88a51b-ca51-4f37-90cf-b42fe14f081b
md"""
Sou só eu ou a visualização acima ficou escura demais?

Uma opção a isso é usar outro "tema" para os gráficos de Julia que ajudem a enfatizar melhor as cores. Para isso vamos usar temas disponíveis no pacote `PlotThemes.jl`. Vamos testar alguns.
"""

# ╔═╡ 2a39913c-0840-4152-914c-a2b61287ef15
begin
    theme(:default)
    #theme(:dark)
    #theme(:lime)
    #theme(:wong)
    #theme(:vibrant)
    heatmap(M, yflip = true)
end

# ╔═╡ ed02f00f-1bcd-43fa-a56c-7be9968614cc
md"""
Outra tentativa interessante é observar os dados como uma superfície 3D. Para podermos manipular o gráfico dentro do browser, vamos trocar o sistema que o `Plots.jl` usa para gerar as imagens para o `plotly`. Esse engenho é baseado em javascript, e como todo browser é capaz de lidar nativamente como javascript, esse backend permite iteração com as imagens diretamente de dentro do `Pluto`.
"""

# ╔═╡ 8d453f89-4a4a-42d0-8a00-9b153a3f435e
plotly()

# ╔═╡ f7de29b5-2a51-45e4-a0a5-f7f602681303
surface(M)

# ╔═╡ 7e817bad-dc51-4c29-a4fc-f7a8bb3663ca
md"""
Mas ainda não ficou bom. Que tal tentarmos gerar uma sequência de histogramas evoluindo ao longo do tempo? Vamos voltar para o engenho `gr` (que gera figuras mais agradáveis, mais isso é ao gosto do freguês) e tentar fazer isso.
"""

# ╔═╡ 403d607b-6171-431b-a058-0aad0909846f
gr()

# ╔═╡ c8c16c14-26b0-4f83-8135-4f862ed90686
begin
    plot(leg = false)

	endtime = 20
    for t = 1:endtime
        for i = 1:length(ps[t])
            # Draws a vertical line from 0 to the high of the probaility 
            plot!(
                [t, t],
                [-grid_size ÷ 2 + i, -grid_size ÷ 2 + i],
                [0, ps[t][i]],
                c = t,
                alpha = 0.8,
                lw = 2,
            )
        end
    end

    xlims!(1, endtime - 1)
    plot!(xaxis = "Time", yaxis = "Space", zaxis = "Probability")
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
FLoops = "cc61a311-1640-44b5-9fba-1b764f453329"
Folds = "41a02a25-b8f0-4f67-bc48-60067656b558"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PlotThemes = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[compat]
BenchmarkTools = "~1.2.0"
FLoops = "~0.2.1"
Folds = "~0.2.8"
PlotThemes = "~2.0.1"
Plots = "~1.22.3"
PlutoUI = "~0.7.14"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.3"
manifest_format = "2.0"

[[deps.Accessors]]
deps = ["Compat", "CompositionsBase", "ConstructionBase", "Dates", "InverseFunctions", "LinearAlgebra", "MacroTools", "Requires", "Test"]
git-tree-sha1 = "ce67f55da3a937bb001a8d00559bdfa4dba6e4f5"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.20"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[deps.ArgCheck]]
git-tree-sha1 = "a3a402a35a2f7e0b87828ccabbd5ebfbebe356b4"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.3.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.BangBang]]
deps = ["Compat", "ConstructionBase", "Future", "InitialValues", "LinearAlgebra", "Requires", "Setfield", "Tables", "ZygoteRules"]
git-tree-sha1 = "7fe6d92c4f281cf4ca6f2fba0ce7b299742da7ca"
uuid = "198e06fe-97b7-11e9-32a5-e1d131e6ad66"
version = "0.3.37"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Baselet]]
git-tree-sha1 = "aebf55e6d7795e02ca500a689d326ac979aaf89e"
uuid = "9718e550-a3fa-408a-8086-8db961cd8217"
version = "0.1.1"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "61adeb0823084487000600ef8b1c00cc2474cd47"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.2.0"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "31d0151f5716b655421d9d75b7fa74cc4e744df2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.39.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.CompositionsBase]]
git-tree-sha1 = "455419f7e328a1a2493cabc6428d79e951349769"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.1"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "fb21ddd70a051d882a1686a5a550990bbe371a95"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.4.1"

[[deps.ContextVariablesX]]
deps = ["Compat", "Logging", "UUIDs"]
git-tree-sha1 = "25cc3803f1030ab855e383129dcd3dc294e322cc"
uuid = "6add18c4-b38d-439d-96f6-d6bc489c04c5"
version = "0.1.3"

[[deps.Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[deps.DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DefineSingletons]]
git-tree-sha1 = "0fba8b706d0178b4dc7fd44a96a92382c9065c2c"
uuid = "244e2a9f-e319-4986-a169-4d1fe445cd52"
version = "0.1.2"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[deps.ExternalDocstrings]]
git-tree-sha1 = "1224740fc4d07c989949e1c1b508ebd49a65a5f6"
uuid = "e189563c-0753-4f5e-ad5c-be4293c83fb4"
version = "0.1.1"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[deps.FLoops]]
deps = ["BangBang", "Compat", "FLoopsBase", "InitialValues", "JuliaVariables", "MLStyle", "Serialization", "Setfield", "Transducers"]
git-tree-sha1 = "ffb97765602e3cbe59a0589d237bf07f245a8576"
uuid = "cc61a311-1640-44b5-9fba-1b764f453329"
version = "0.2.1"

[[deps.FLoopsBase]]
deps = ["ContextVariablesX"]
git-tree-sha1 = "656f7a6859be8673bf1f35da5670246b923964f7"
uuid = "b9860ae5-e623-471e-878b-f6a53c775ea6"
version = "0.1.1"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Folds]]
deps = ["Accessors", "BangBang", "Baselet", "DefineSingletons", "Distributed", "ExternalDocstrings", "InitialValues", "MicroCollections", "Referenceables", "Requires", "Test", "ThreadedScans", "Transducers"]
git-tree-sha1 = "638109532de382a1f99b1aae1ca8b5d08515d85a"
uuid = "41a02a25-b8f0-4f67-bc48-60067656b558"
version = "0.2.8"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "0c603255764a1fa0b61752d2bec14cfbd18f7fe8"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+1"

[[deps.GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "c2178cfbc0a5a552e16d097fae508f2024de61a3"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.59.0"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "ef49a187604f865f4708c90e3f431890724e9012"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.59.0+0"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "14eece7a3308b4d8be910e265c724a6ba51a9798"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.16"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypertextLiteral]]
git-tree-sha1 = "72053798e1be56026b81d4e2682dbe58922e5ec9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.0"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[deps.InitialValues]]
git-tree-sha1 = "4da0f88e9a39111c2fa3add390ab15f3a44f3ca3"
uuid = "22cec73e-a1b8-11e9-2c92-598750a2cf9c"
version = "0.3.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[deps.JuliaVariables]]
deps = ["MLStyle", "NameResolution"]
git-tree-sha1 = "49fb3cb53362ddadb4415e9b73926d6b40709e70"
uuid = "b14d175d-62b4-44ba-8fb7-3064adc8c3ec"
version = "0.2.4"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "c7f1c695e06c01b95a67f0cd1d34994f3e7db104"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.2.1"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a4b12a1bd2ebade87891ab7e36fdbce582301a92"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.6"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "c9551dd26e31ab17b86cbd00c2ede019c08758eb"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+1"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MLStyle]]
git-tree-sha1 = "0638598b2ea9c60303e036be920df8df60fe2812"
uuid = "d8e11817-5142-5d16-987a-aa16d5891078"
version = "0.4.14"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "5a5bc6bf062f0f95e62d0fe0a2d99699fed82dd9"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.8"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[deps.MicroCollections]]
deps = ["BangBang", "InitialValues", "Setfield"]
git-tree-sha1 = "4d5917a26ca33c66c8e5ca3247bd163624d35493"
uuid = "128add7d-3638-4c79-886c-908ea0c25c34"
version = "0.1.3"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[deps.NameResolution]]
deps = ["PrettyPrint"]
git-tree-sha1 = "1a0fa0e9613f46c9b8c11eee38ebb4f590013c5e"
uuid = "71a1bf82-56d0-4bbc-8a3c-48b961074391"
version = "0.1.5"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "a8709b968a1ea6abc2dc1967cb1db6ac9a00dfb6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.5"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "2537ed3c0ed5e03896927187f5f2ee6a4ab342db"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.14"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs"]
git-tree-sha1 = "cfbd033def161db9494f86c5d18fbf874e09e514"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.22.3"

[[deps.PlutoUI]]
deps = ["Base64", "Dates", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "d1fb76655a95bf6ea4348d7197b22e889a4375f4"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.14"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[deps.PrettyPrint]]
git-tree-sha1 = "632eb4abab3449ab30c5e1afaa874f0b98b586e4"
uuid = "8162dcfd-2161-5ef2-ae6c-7681170c5f98"
version = "0.2.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "c6c0f690d0cc7caddb74cef7aa847b824a16b256"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+1"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
git-tree-sha1 = "44a75aa7a527910ee3d1751d1f0e4148698add9e"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.2"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "7ad0dfa8d03b7bcf8c597f59f5292801730c55b8"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.4.1"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Referenceables]]
deps = ["Adapt"]
git-tree-sha1 = "e681d3bfa49cd46c3c161505caddf20f0e62aaa9"
uuid = "42d2dcc6-99eb-4e98-b66c-637b7d73030e"
version = "0.1.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SplittablesBase]]
deps = ["Setfield", "Test"]
git-tree-sha1 = "e08a62abc517eb79667d0a29dc08a3b589516bb5"
uuid = "171d559e-b47b-412a-8079-5efa626c420e"
version = "0.1.15"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "8cbbc098554648c84f79a463c9ff0fd277144b6c"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.10"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "1162ce4a6c4b7e31e0e6b14486a6986951c73be9"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.5.2"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.ThreadedScans]]
deps = ["ArgCheck"]
git-tree-sha1 = "ca1ba3000289eacba571aaa4efcefb642e7a1de6"
uuid = "24d252fe-5d94-4a69-83ea-56a14333d47a"
version = "0.1.0"

[[deps.Transducers]]
deps = ["Adapt", "ArgCheck", "BangBang", "Baselet", "CompositionsBase", "DefineSingletons", "Distributed", "InitialValues", "Logging", "Markdown", "MicroCollections", "Requires", "Setfield", "SplittablesBase", "Tables"]
git-tree-sha1 = "77fea79baa5b22aeda896a8d9c6445a74500a2c2"
uuid = "28d57a85-8fef-5791-bfe6-a80928e7c999"
version = "0.4.74"

[[deps.URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll"]
git-tree-sha1 = "2839f1c1296940218e35df0bbb220f2a79686670"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.18.0+4"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[deps.ZygoteRules]]
deps = ["MacroTools"]
git-tree-sha1 = "8c1a8e4dfacb1fd631745552c8db35d0deb09ea0"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.2"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─e46441c4-97bd-11eb-330c-97bd5ac41f9e
# ╠═85b45a43-d7bf-4597-a1a6-329b41dce20d
# ╠═85c26eb4-c258-4a8b-9415-7b5f7ddff02a
# ╟─2d48bfc6-9617-11eb-3a85-279bebd21332
# ╟─abbc1d4f-a6d5-444c-a3b0-148979e42ba9
# ╠═3895ae97-9d1d-4ecd-89cf-de4809a3273a
# ╠═8e4294f0-a6a9-467b-b9d6-e3facf1d03bd
# ╠═4e0b3cf4-f9a8-4f77-92bd-cd5f1a39e92a
# ╠═8f4b6cee-b2ec-4c96-9992-0057d35be32a
# ╠═f0d716f0-2724-4e9c-8868-cdec3dba5b02
# ╠═c361320c-c5a3-44ff-9933-44bb1d82fc62
# ╠═689959aa-6548-453f-a631-6abe76d26b40
# ╠═42accec8-4db0-4bf1-a1da-9ec07dbee499
# ╟─c2c27c13-4621-469d-8f42-340d665de687
# ╠═6b2d3e1b-2f96-4af3-a116-bce6a8cf8580
# ╠═b04d3912-8c04-4642-8409-a245f8fb8a0b
# ╟─c4edc5a6-ccc0-40bc-96f2-c17b7f25dc10
# ╠═4523623e-39ad-44f3-96af-1dfc32d69517
# ╠═0c9d5a88-fc7a-4c26-a899-5a9a94f5c940
# ╠═345c8f7d-649d-4e56-8bc5-c0cab17827ab
# ╟─d595c3de-851e-4acd-8d74-89d9d5dbcc50
# ╠═4ce4f93b-86d4-45ed-92a7-59eac9f79c47
# ╠═8480cc51-83a0-4875-ae0f-4a417a70d0f7
# ╠═67b16340-f0f1-40e4-a0ec-16fd45ca97a4
# ╟─53c31918-b9a5-4caf-95f7-5ea07f05a91b
# ╠═ee27d51a-f277-4d06-b5a6-f473866c9053
# ╟─33f4bbfe-62b3-4182-b1a3-3fdb5fedbaad
# ╠═419f6a67-69f8-49fa-9092-8d9f4568d507
# ╠═287300d0-8cbe-48d3-bf26-f0625f3f3874
# ╟─6e29c993-6ca7-4224-b069-4691a2d48284
# ╠═9aeabeaf-ad07-47f7-ae75-dd86b6bc4e39
# ╠═70fc0697-2c7c-4298-b54e-a91d85d5fcd8
# ╠═3cb8181c-3c0f-4618-8152-d59ad4445f9d
# ╠═7a5aff37-b8a6-4058-8918-be44d14eaa02
# ╠═fb3d6afa-2f82-4e2c-b334-bc7967ff2766
# ╟─db9cffca-33ff-4820-b41a-ab0b631c7f35
# ╠═5b0360ed-5eda-40ef-a47d-5f15a24422be
# ╠═6e15051c-52f5-44a7-835f-85471cb5f577
# ╠═254f7a34-10a6-4ae7-96b5-a1f0740493c2
# ╠═25071ece-1484-4df5-b9ca-8f03c9b8d05e
# ╠═a408a0ee-57f4-43c7-ad8a-7cab680f64c2
# ╟─8db311f4-92e7-44b1-b0b0-de5fd0f9cd21
# ╠═7eb279e3-10b6-4db6-95c9-b8fa08ea29f8
# ╠═9a3007ea-3bc8-4ad6-b8f0-dcd09dccd832
# ╠═c70122e3-b1be-4a10-8b3a-80d12982d76b
# ╟─30162386-039f-4cd7-9121-a3382be3c294
# ╟─4e7b163e-dfd0-457e-b1f3-8807a4d8060a
# ╠═e8ceab7b-45db-4393-bb8e-e000ecf78d2c
# ╠═2d4dffb9-39e4-48de-9688-980b96814c9f
# ╟─8ff66523-bc2e-4c53-975b-8ba4f99eb1c6
# ╟─2868dd57-7164-4162-8c5d-30628dedeb7a
# ╠═f6009473-d3c1-444f-88ae-814f770e811b
# ╟─9a368602-acd3-43fb-9dff-e407a4bab930
# ╟─67517333-175f-48c4-a915-76658cbf1304
# ╠═d6832372-d336-4a54-bbcf-d0bb70e4de64
# ╟─35f14826-f1e4-4977-a31a-0f6148fe25ad
# ╠═7468fc5d-7f35-45e2-b5fc-7e63b562bc8f
# ╠═1ca8aa3b-b05d-40f6-a925-2f0248b79ca2
# ╟─38d88b7c-3b4f-430b-8d3c-f672ab0c7a49
# ╟─f4c9b02b-738b-4de1-9e9d-05b1616bee0b
# ╠═d1c47afa-ab7f-4543-a161-e3ceb6f11eb4
# ╠═bf78e00f-05d9-4a05-8512-4924ef9e25f7
# ╟─b948830f-ead1-4f36-a237-c998f2f7deb8
# ╠═15223c51-8d31-4a50-a8ff-1cb7d35de454
# ╟─0bd45c4a-3286-427a-a927-15869be2ebfe
# ╠═999fb608-fb1a-46cb-82ca-f3f31fe617e1
# ╟─6509e69a-6e50-4816-a98f-67ba437383fb
# ╟─e58976a9-1784-441e-bb76-3011538b8ad0
# ╟─61f9bbfc-09cc-4d0b-b79d-262235ff10a2
# ╠═834e3dce-9a65-4452-b6dc-9a87a86aeb13
# ╠═80acaa77-a399-448b-81f6-3a645d3895be
# ╠═6658a4e4-1dbb-457f-95e5-5b59853fae88
# ╠═af357814-f0a1-48b3-9e49-ee0ad1cee609
# ╠═27040653-4639-419f-9c07-a826c9c8f8f5
# ╠═c4b1a791-e318-47e5-80ed-7476f658f647
# ╟─1efc2b68-9313-424f-9850-eb4496cc8486
# ╟─6e93ffda-217b-4d46-86b5-534ddc1bae90
# ╟─396d2490-3cb9-4f68-8fdf-9209d2010e02
# ╟─dc1c22e8-1c7b-43b7-8421-c2ca708931a5
# ╠═fb804fe2-58be-46c9-9200-ceb8863d052c
# ╠═0b26efab-4e93-4d53-9c4d-faea68d12174
# ╠═b48e55b7-4b56-41aa-9796-674d04adf5df
# ╟─53a36c1a-0b8c-4099-8854-08d73c9f118e
# ╠═6b298184-32c6-412d-a900-b113d6bd3d53
# ╠═b84a7255-7b0a-4ba1-8c87-9f5d3fa32ef3
# ╟─242ea831-c421-4a76-b658-2a57fa924a4f
# ╠═d0f89707-eccf-4155-82d5-780643e1b447
# ╠═049feaa2-050a-45eb-85a1-75c758c08e87
# ╟─65946621-a2af-4370-8c4d-b2207b63fc51
# ╠═aeaef573-1e90-45f3-a7fe-31ec5e2808c4
# ╟─610b2349-9ae6-4967-8b50-9b30b34d18d8
# ╠═602fb644-bd1d-4f9d-979f-0b190931d649
# ╟─1baafa2c-73c6-4e6f-832c-8b5c330b55d7
# ╟─efe186da-3273-4767-aafc-fc8eae01dbd9
# ╟─61201091-b8b3-4776-9be9-4c23d5ba88ba
# ╠═66c4aed3-a04b-4a09-b954-79e816d2a3f7
# ╟─b135f6be-5e82-4c72-af11-0eb0d4141dec
# ╠═e74e18e3-ad08-4a53-a803-cd53564dca65
# ╟─4d88a51b-ca51-4f37-90cf-b42fe14f081b
# ╠═2a39913c-0840-4152-914c-a2b61287ef15
# ╟─ed02f00f-1bcd-43fa-a56c-7be9968614cc
# ╠═8d453f89-4a4a-42d0-8a00-9b153a3f435e
# ╠═f7de29b5-2a51-45e4-a0a5-f7f602681303
# ╟─7e817bad-dc51-4c29-a4fc-f7a8bb3663ca
# ╠═403d607b-6171-431b-a058-0aad0909846f
# ╠═c8c16c14-26b0-4f83-8135-4f862ed90686
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
