### A Pluto.jl notebook ###
# v0.19.41

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
	using Base.Iterators
    using LinearAlgebra
    using SparseArrays
    using Random
    using PlutoUI
    using Plots
	import PlotlyBase
	import PlotlyKaleido
	using PlotThemes
    using BenchmarkTools
    using Folds
    using FLoops
end

# ╔═╡ e46441c4-97bd-11eb-330c-97bd5ac41f9e
md"Tradução livre de [random\_walks\_ii.jl](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week8/random_walks_II.jl) + a parte de computação paralela."

# ╔═╡ 85c26eb4-c258-4a8b-9415-7b5f7ddff02a
TableOfContents(aside=true)

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
# Um outro exemplo de computação paralela

Nesse cadernos vamos rever ideias computação paralela usando o pacote [`Folds.jl`](https://github.com/JuliaFolds/Folds.jl).

A ideia básica desse pacote é encapsular alguns padrões típicos de paralelismo e disponibilizá-los com uma sintaxe simples e familiar na linguagem. Mas antes disso, vamos ver os três tipos principais de paralelismo:

1. Memória compartilhada: o programa roda em paralelo em múltiplos núcleos (que nada mais são que processadores independentes em uma CPU) que compartilham um mesmo espaço de memória. Isso simplifica muito o modelo porque esses processos independentes podem se comunicar simples alterado o valor de variáveis comuns.

2. Memória distribuída: o programa roda em paralelo em nós computacionais distintos, cada um com sua memória. Aqui já é necessário ter ferramentas explícitas para que os vários processos se comuniquem entre si enviando "mensagens" uns para os outros.

3. GPU: o programa roda em um co-processador vetorial que é muito rápido, tem um número enorme de cores, mas não consegue executar instruções complexas, com desvios condicionais, naturalmente. Esse tipo de paralelismo também é conhecido como _vetorial_, já que uma mesma operação é aplicada a um vetor (conjunto grande) de dados ao mesmo tempo (de forma síncrona).

Nesse curso, vamos focar em operações que são naturalmente paralelas. Isso ocorre quando você tem que fazer várias tarefas independentes entre si ou que possuem uma dependência "fraca", que pode ser explorada. A ideia do pacote `Folds.jl` é justamente essa: apresentar ferramentas que permitam explorar situações de paralelismo típica de maneira transparente.

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
step(w::Walker1D) = rand((-1, +1))

# ╔═╡ f0d716f0-2724-4e9c-8868-cdec3dba5b02
# Update the Walker position, since Walker is immutable, we opt to create a new Walker representing it in the new position
update(w::W, step) where {W<:Walker} = W(position(w) .+ step)  # W is a type parameter, explain

# ╔═╡ 689959aa-6548-453f-a631-6abe76d26b40
begin
    struct Walker2D <: Walker
        pos::Tuple{Int64,Int64}
    end

    Walker2D(x, y) = Walker2D((x, y))
end

# ╔═╡ 42accec8-4db0-4bf1-a1da-9ec07dbee499
step(w::Walker2D) = rand(((1, 0), (0, 1), (-1, 0), (0, -1)))

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
a_trajectory(T) = trajectory(Walker2D(0, 0), T)

# ╔═╡ 67b16340-f0f1-40e4-a0ec-16fd45ca97a4
@btime wss = map(a_trajectory, repeated(T, N))

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
pwss = Folds.map(a_trajectory, repeated(T, N))

# ╔═╡ 287300d0-8cbe-48d3-bf26-f0625f3f3874
@btime pwss = Folds.map(a_trajectory, repeated(T, N))

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
# init is used to say where the reduces should start
@btime Folds.reduce(.+, traj, init=(0, 0)) ./ T2

# ╔═╡ db9cffca-33ff-4820-b41a-ab0b631c7f35
md"""Agora, algo está estranho, não? Parece natural que a posição média em uma trajetória longa fosse o ponto de partida e não foi isso que vimos. Vamos então calcular a média das posições médias.

Para isso vamos unir os dois conceitos. Vamos primeiro criar uma função que mapeia a duração de uma trajetória na média de uma trajetória aleatória e depois reduzir essas médias por somas e obter a média das médias.
"""

# ╔═╡ 5b0360ed-5eda-40ef-a47d-5f15a24422be
T3, N3 = 1_000_000, 1_000

# ╔═╡ 6e15051c-52f5-44a7-835f-85471cb5f577
function mean_trajectory(T3)
    traj = trajectory(Walker2D(0, 0), T3)
    return reduce(.+, traj) ./ T3
end

# ╔═╡ 254f7a34-10a6-4ae7-96b5-a1f0740493c2
mapreduce(mean_trajectory, .+, fill(T3, N3)) ./ N3

# ╔═╡ 25071ece-1484-4df5-b9ca-8f03c9b8d05e
@time mapreduce(mean_trajectory, .+, fill(T3, N3)) ./ N3

# ╔═╡ a408a0ee-57f4-43c7-ad8a-7cab680f64c2
@time Folds.mapreduce(mean_trajectory, .+, fill(T3, N3), init=(0, 0)) ./ N3

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
@time parallelmean(T3, N3)

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
@bind n_pascal Slider(1:63, show_value=true, default=1)

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
Uma alternativa interessante surge quando olhamos uma variação do triângulo de Pascal onde a entrada (i, j) possui na coluna j o número de elementos dos subconjuntos das combinações de forma fixa.
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
plot(ps[tt], ylim=(0, 1), xlim=(1, 100), leg=false, size=(500, 300))

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
bar(ps[tt], ylim=(0, 1), leg=false, size=(500, 300), alpha=0.5)

# ╔═╡ 610b2349-9ae6-4967-8b50-9b30b34d18d8
md"""
Uma mudança simples, mas que já produz um resultado mais agradável.

Outra característica é que a visualização acima só consegue capturar a evolução das probabilidades ao deslizarmos o slider. Não seria mais interessantes gerarmos uma animação que evolui a probabilidade no tempo. Por sorte, Plots já tem isso "pronto".
"""

# ╔═╡ 602fb644-bd1d-4f9d-979f-0b190931d649
begin
    anim = @animate for ttt = 1:max_time
        bar(ps[ttt], ylim=(0, 1), leg=false, alpha=0.5, dpi=200)
        title!("Time = $ttt")
    end
    gif(anim, fps=10)
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
heatmap(M, yflip=true)

# ╔═╡ 4d88a51b-ca51-4f37-90cf-b42fe14f081b
md"""
Sou só eu ou a visualização acima ficou escura demais?

Uma opção a isso é usar outro "tema" para os gráficos de Julia que ajudem a enfatizar melhor as cores. Para isso vamos usar temas disponíveis no pacote `PlotThemes.jl`. Vamos testar alguns.
"""

# ╔═╡ 2a39913c-0840-4152-914c-a2b61287ef15
begin
    #theme(:default)
    #theme(:dark)
    #theme(:lime)
    #theme(:wong)
    #theme(:vibrant)
    heatmap(M, yflip=true)
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
    plot(leg=false)

    endtime = 20
    for t = 1:endtime
        for i = 1:length(ps[t])
            # Draws a vertical line from 0 to the high of the probaility 
            plot!(
                [t, t],
                [-grid_size ÷ 2 + i, -grid_size ÷ 2 + i],
                [0, ps[t][i]],
                c=t,
                alpha=0.8,
                lw=2,
            )
        end
    end

    xlims!(1, endtime - 1)
    plot!(xaxis="Time", yaxis="Space", zaxis="Probability")
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
FLoops = "cc61a311-1640-44b5-9fba-1b764f453329"
Folds = "41a02a25-b8f0-4f67-bc48-60067656b558"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PlotThemes = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
PlotlyBase = "a03496cd-edff-5a9b-9e67-9cda94a718b5"
PlotlyKaleido = "f2990250-8cf9-495f-b13a-cce12b45703c"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[compat]
BenchmarkTools = "~1.5.0"
FLoops = "~0.2.1"
Folds = "~0.2.10"
PlotThemes = "~3.1.0"
PlotlyBase = "~0.8.19"
PlotlyKaleido = "~2.2.4"
Plots = "~1.40.4"
PlutoUI = "~0.7.59"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.2"
manifest_format = "2.0"
project_hash = "1d85789d0826f02f1d865a08be1e9dd80c63c412"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.Accessors]]
deps = ["CompositionsBase", "ConstructionBase", "Dates", "InverseFunctions", "LinearAlgebra", "MacroTools", "Markdown", "Test"]
git-tree-sha1 = "c0d491ef0b135fd7d63cbc6404286bc633329425"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.36"

    [deps.Accessors.extensions]
    AccessorsAxisKeysExt = "AxisKeys"
    AccessorsIntervalSetsExt = "IntervalSets"
    AccessorsStaticArraysExt = "StaticArrays"
    AccessorsStructArraysExt = "StructArrays"
    AccessorsUnitfulExt = "Unitful"

    [deps.Accessors.weakdeps]
    AxisKeys = "94b1ba4f-4ee9-5380-92f1-94cde586c3c5"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    Requires = "ae029012-a4dd-5104-9daa-d747884805df"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "6a55b747d1812e699320963ffde36f1ebdda4099"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.0.4"

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

    [deps.Adapt.weakdeps]
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.ArgCheck]]
git-tree-sha1 = "a3a402a35a2f7e0b87828ccabbd5ebfbebe356b4"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.3.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.BangBang]]
deps = ["Compat", "ConstructionBase", "InitialValues", "LinearAlgebra", "Requires", "Setfield", "Tables"]
git-tree-sha1 = "7aa7ad1682f3d5754e3491bb59b8103cae28e3a3"
uuid = "198e06fe-97b7-11e9-32a5-e1d131e6ad66"
version = "0.3.40"

    [deps.BangBang.extensions]
    BangBangChainRulesCoreExt = "ChainRulesCore"
    BangBangDataFramesExt = "DataFrames"
    BangBangStaticArraysExt = "StaticArrays"
    BangBangStructArraysExt = "StructArrays"
    BangBangTypedTablesExt = "TypedTables"

    [deps.BangBang.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    TypedTables = "9d95f2ec-7b3d-5a63-8d20-e2491e220bb9"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Baselet]]
git-tree-sha1 = "aebf55e6d7795e02ca500a689d326ac979aaf89e"
uuid = "9718e550-a3fa-408a-8086-8db961cd8217"
version = "0.1.1"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "f1dff6729bc61f4d49e140da1af55dcd1ac97b2f"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.5.0"

[[deps.BitFlags]]
git-tree-sha1 = "2dc09997850d68179b69dafb58ae806167a32b1b"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.8"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9e2a6b69137e6969bab0152632dcb3bc108c8bdd"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+1"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "a4c43f59baa34011e303e76f5c8c91bf58415aaf"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.0+1"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "59939d8a997469ee05c4b4944560a820f9ba0d73"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.4"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "67c1f244b991cad9b0aa4b7540fb758c2488b129"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.24.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

    [deps.ColorVectorSpace.weakdeps]
    SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "b1c55339b7c6c350ee89f2c1604299660525b248"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.15.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.0+0"

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"
weakdeps = ["InverseFunctions"]

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "6cbbd4d241d7e6579ab354737f4dd95ca43946e1"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.4.1"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "260fd2400ed2dab602a7c15cf10c1933c59930a2"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.5"

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.ContextVariablesX]]
deps = ["Compat", "Logging", "UUIDs"]
git-tree-sha1 = "25cc3803f1030ab855e383129dcd3dc294e322cc"
uuid = "6add18c4-b38d-439d-96f6-d6bc489c04c5"
version = "0.1.3"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

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
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8e9441ee83492030ace98f9789a654a6d0b1f643"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "dcb08a0d93ec0b1cdc4af184b26b591e9695423a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.10"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1c6317308b9dc757616f0b5cb379db10494443a7"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.6.2+0"

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
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "466d45dc38e15794ec7d5d63ec03d776a9aff36e"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.4+1"

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
git-tree-sha1 = "7eb4bc88d8295e387a667fd43d67c157ddee76cf"
uuid = "41a02a25-b8f0-4f67-bc48-60067656b558"
version = "0.2.10"

    [deps.Folds.extensions]
    FoldsOnlineStatsBaseExt = "OnlineStatsBase"

    [deps.Folds.weakdeps]
    OnlineStatsBase = "925886fa-5bf2-5e8e-b522-a9147a512338"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "db16beca600632c95fc8aca29890d83788dd8b23"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.96+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "d8db6a5a2fe1381c1ea4ef2cab7c69c2de7f9ea0"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.1+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1ed150b39aebcc805c26b93a8d0122c940f64ce2"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.14+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "ff38ba61beff76b8f4acad8ab0c97ef73bb670cb"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.9+0"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "p7zip_jll"]
git-tree-sha1 = "ddda044ca260ee324c5fc07edb6d7cf3f0b9c350"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.5"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "278e5e0f820178e8a26df3184fcb2280717c79b1"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.5+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "359a1ba2e320790ddbe4ee8b4d54a305c0ea2aff"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.80.0+0"

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
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "2c3ec1f90bb4a8f7beafb0cffea8a4c3f4e636ab"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.6"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "8b72179abc660bfab5e28472e019392b97d0985c"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.4"

[[deps.InitialValues]]
git-tree-sha1 = "4da0f88e9a39111c2fa3add390ab15f3a44f3ca3"
uuid = "22cec73e-a1b8-11e9-2c92-598750a2cf9c"
version = "0.3.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "e7cbed5032c4c397a6ac23d1493f3289e01231c4"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.14"
weakdeps = ["Dates"]

    [deps.InverseFunctions.extensions]
    DatesExt = "Dates"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "a53ebe394b71470c7f97c2e7e170d51df21b17af"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.7"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "3336abae9a713d2210bb57ab484b1e065edd7d23"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.0.2+0"

[[deps.JuliaVariables]]
deps = ["MLStyle", "NameResolution"]
git-tree-sha1 = "49fb3cb53362ddadb4415e9b73926d6b40709e70"
uuid = "b14d175d-62b4-44ba-8fb7-3064adc8c3ec"
version = "0.2.4"

[[deps.Kaleido_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "43032da5832754f58d14a91ffbe86d5f176acda9"
uuid = "f7e6163d-2fa5-5f23-b69c-1db539e41963"
version = "0.2.1+0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "170b660facf5df5de098d866564877e119141cbd"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.2+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d986ce2d884d49126836ea94ed5bfb0f12679713"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "15.0.7+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "70c5da094887fd2cae843b8db33920bac4b6f07d"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.2+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[deps.Latexify]]
deps = ["Format", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "e0b5cd21dc1b44ec6e64f351976f961e6f31d6c4"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.3"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

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

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll"]
git-tree-sha1 = "9fd170c4bbfd8b935fdc5f8b7aa33532c991a673"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.11+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "fbb1f2bef882392312feb1ede3615ddc1e9b99ed"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.49.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f9557a255370125b405568f9767d6d195822a175"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "4b683b19157282f50bfd5dcaa2efe5295814ea22"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.40.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "2da088d113af58221c52828a80378e16be7d037a"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.5.1+1"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "27fd5cc10be85658cacfe11bb81bee216af13eda"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.40.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "18144f3e9cbe9b15b070288eef858f71b291ce37"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.27"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "c1dd6d7978c12545b4179fb6153b9250c96b0075"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.3"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MLStyle]]
git-tree-sha1 = "bc38dff0548128765760c79eb7388a4b37fae2c8"
uuid = "d8e11817-5142-5d16-987a-aa16d5891078"
version = "0.4.17"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.MicroCollections]]
deps = ["BangBang", "InitialValues", "Setfield"]
git-tree-sha1 = "629afd7d10dbc6935ec59b32daeb33bc4460a42e"
uuid = "128add7d-3638-4c79-886c-908ea0c25c34"
version = "0.1.4"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NameResolution]]
deps = ["PrettyPrint"]
git-tree-sha1 = "1a0fa0e9613f46c9b8c11eee38ebb4f590013c5e"
uuid = "71a1bf82-56d0-4bbc-8a3c-48b961074391"
version = "0.1.5"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "38cb508d080d21dc1128f7fb04f20387ed4c0af4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "3da7367955dcc5c54c1ba4d402ccdc09a1a3e046"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.13+1"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "64779bc4c9784fee475689a1752ef4d5747c5e87"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.42.2+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "7b1a9df27f072ac4c9c7cbe5efb198489258d1f5"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.1"

[[deps.PlotlyBase]]
deps = ["ColorSchemes", "Dates", "DelimitedFiles", "DocStringExtensions", "JSON", "LaTeXStrings", "Logging", "Parameters", "Pkg", "REPL", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "56baf69781fc5e61607c3e46227ab17f7040ffa2"
uuid = "a03496cd-edff-5a9b-9e67-9cda94a718b5"
version = "0.8.19"

[[deps.PlotlyKaleido]]
deps = ["Base64", "JSON", "Kaleido_jll"]
git-tree-sha1 = "2650cd8fb83f73394996d507b3411a7316f6f184"
uuid = "f2990250-8cf9-495f-b13a-cce12b45703c"
version = "2.2.4"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "442e1e7ac27dd5ff8825c3fa62fbd1e86397974b"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.40.4"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "ab55ee1510ad2af0ff674dbcced5e94921f867a9"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.59"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

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

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "37b7bb7aabf9a085e0044307e1717436117f2b3b"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.5.3+1"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Referenceables]]
deps = ["Adapt"]
git-tree-sha1 = "02d31ad62838181c1a3a5fd23a1ce5914a643601"
uuid = "42d2dcc6-99eb-4e98-b66c-637b7d73030e"
version = "0.1.3"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.SplittablesBase]]
deps = ["Setfield", "Test"]
git-tree-sha1 = "e08a62abc517eb79667d0a29dc08a3b589516bb5"
uuid = "171d559e-b47b-412a-8079-5efa626c420e"
version = "0.1.15"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "5cf7606d6cef84b543b483848d4ae08ad9832b21"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.3"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "cb76cf677714c095e535e3501ac7954732aeea2d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.ThreadedScans]]
deps = ["ArgCheck"]
git-tree-sha1 = "ca1ba3000289eacba571aaa4efcefb642e7a1de6"
uuid = "24d252fe-5d94-4a69-83ea-56a14333d47a"
version = "0.1.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "5d54d076465da49d6746c647022f3b3674e64156"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.8"
weakdeps = ["Random", "Test"]

    [deps.TranscodingStreams.extensions]
    TestExt = ["Test", "Random"]

[[deps.Transducers]]
deps = ["Adapt", "ArgCheck", "BangBang", "Baselet", "CompositionsBase", "ConstructionBase", "DefineSingletons", "Distributed", "InitialValues", "Logging", "Markdown", "MicroCollections", "Requires", "Setfield", "SplittablesBase", "Tables"]
git-tree-sha1 = "3064e780dbb8a9296ebb3af8f440f787bb5332af"
uuid = "28d57a85-8fef-5791-bfe6-a80928e7c999"
version = "0.4.80"

    [deps.Transducers.extensions]
    TransducersBlockArraysExt = "BlockArrays"
    TransducersDataFramesExt = "DataFrames"
    TransducersLazyArraysExt = "LazyArrays"
    TransducersOnlineStatsBaseExt = "OnlineStatsBase"
    TransducersReferenceablesExt = "Referenceables"

    [deps.Transducers.weakdeps]
    BlockArrays = "8e7c35d0-a365-5155-bbbb-fb81a777f24e"
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    LazyArrays = "5078a376-72f3-5289-bfd5-ec5146d43c02"
    OnlineStatsBase = "925886fa-5bf2-5e8e-b522-a9147a512338"
    Referenceables = "42d2dcc6-99eb-4e98-b66c-637b7d73030e"

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "3c793be6df9dd77a0cf49d80984ef9ff996948fa"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.19.0"
weakdeps = ["ConstructionBase", "InverseFunctions"]

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "e2d817cc500e960fdbafcf988ac8436ba3208bfd"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.3"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "7558e29847e99bc3f04d6569e82d0f5c54460703"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+1"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "93f43ab61b16ddfb2fd3bb13b3ce241cafb0e6c9"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.31.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "532e22cf7be8462035d092ff21fada7527e2c488"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.12.6+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "ac88fb95ae6447c8dda6a5503f3bafd496ae8632"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.4.6+0"

[[deps.Xorg_libICE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "326b4fea307b0b39892b3e85fa451692eda8d46c"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.1.1+0"

[[deps.Xorg_libSM_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libICE_jll"]
git-tree-sha1 = "3796722887072218eabafb494a13c963209754ce"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.4+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "afead5aba5aa507ad5a3bf01f58f82c8d1403495"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6035850dcc70518ca32f012e46015b9beeda49d8"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.11+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "34d526d318358a859d7de23da945578e8e8727b7"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.4+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "d2d1a5c49fae4ba39983f63de6afcbea47194e85"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.6+0"

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
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "47e45cd78224c53109495b3e324df0c37bb61fbe"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.11+0"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8fdda4c692503d44d04a0603d9ac0982054635f9"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.1+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "b4bfde5d5b652e22b9c790ad00af08b6d042b97d"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.15.0+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "730eeca102434283c50ccf7d1ecdadf521a765a4"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.2+0"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "04341cb870f29dcd5e39055f895c39d016e18ccd"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.4+0"

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
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "330f955bc41bb8f5270a369c473fc4a5a4e4d3cb"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.6+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "691634e5453ad362044e2ad653e79f3ee3bb98c3"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.39.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e92a1a012a10506618f10b7047e478403a046c77"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e678132f07ddb5bfa46857f0d7620fb9be675d3b"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.6+0"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "gperf_jll"]
git-tree-sha1 = "431b678a28ebb559d224c0b6b6d01afce87c51ba"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.9+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a68c9655fbe6dfcab3d972808f1aafec151ce3f8"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.43.0+0"

[[deps.gperf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3516a5630f741c9eecb3720b1ec9d8edc3ecc033"
uuid = "1a1c6b14-54f6-533d-8383-74cd7377aa70"
version = "3.1.1+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "141fe65dc3efabb0b1d5ba74e91f6ad26f84cc22"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.11.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "ad50e5b90f222cfe78aa3d5183a20a12de1322ce"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.18.0+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "d7015d2e18a5fd9a4f47de711837e980519781a4"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.43+1"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "814e154bdb7be91d78b6802843f76b6ece642f11"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.6+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

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
git-tree-sha1 = "9c304562909ab2bab0262639bd4f444d7bc2be37"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+1"
"""

# ╔═╡ Cell order:
# ╟─e46441c4-97bd-11eb-330c-97bd5ac41f9e
# ╠═85b45a43-d7bf-4597-a1a6-329b41dce20d
# ╟─85c26eb4-c258-4a8b-9415-7b5f7ddff02a
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
# ╟─d1c47afa-ab7f-4543-a161-e3ceb6f11eb4
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
