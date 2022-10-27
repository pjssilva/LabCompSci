### A Pluto.jl notebook ###
# v0.19.14

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

# ╔═╡ d155ea12-9628-11eb-347f-7754a33fd403
begin
    using Plots
    using PlutoUI
    using HypertextLiteral
    using LightGraphs
    using GraphPlot
    using Printf
    using SpecialFunctions
    using Statistics
    using Distributions
end

# ╔═╡ bad1ae0f-0b0b-4cdd-94ff-e9a55fad6dfe
md"Tradução livre de [discrete\_and\_continuos.jl](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week8/discrete_and_continuous.jl)"

# ╔═╡ 01506de2-918a-11eb-2a4d-c554a6e54631
TableOfContents(title="📚 Assuntos", aside=true)

# ╔═╡ ee349b52-9189-11eb-2b86-b5dc15ebe432
md"""
###  Discreto e contínuo
"""

# ╔═╡ 877deb2c-702b-457b-a54b-f27c277928d4
md"""
A aula de hoje tem um tom um pouco "filosófico". O espírito é mostrar como, em muitos casos, o mundo da matemática discreta e contínua se encontram e interagem e como os objetos contínuos muitas vezes são limites de objetos discretos capturando suas propriedades mais importantes e eliminando a complexidade inerente ao caso discreto.
"""

# ╔═╡ 43e39a6c-918a-11eb-2408-93563b4fb8c1
md"""
Uma definição exata do que são os objetos discretos e contínuos não é simples. De qualquer forma, a definição intuitiva é que a Matemática discreta lida com conjunto com um número finito de objetos ou conjuntos infinitos de objetos isolados. Nesse sentido um conjunto como $\{1, 2, 3, \ldots, n \}$ e o $\mathbb{Z}$ são objetos discretos.
"""

# ╔═╡ 719a4c8c-9615-11eb-3dd7-7fb786f7fa17
md"""
**Exemplos de objetos matemáticos discretos:**

1. Conjuntos finitos: $\{1, 2,  \ldots , 100\}$.

2. Conjuntos discretos infinitos: ``\mathbb{Z}`` = inteiros = ``\{\ldots,-2, -1, 0, 1, 2, \ldots\}``

3. Grafos:
"""

# ╔═╡ 45ecee7e-970e-11eb-22fd-01f56876684e
# gplot(barabasi_albert(150, 2))

# ╔═╡ 61ffe0f2-9615-11eb-37d5-f9e30a31c111
md"""
Por outro lado, intervalos ou reta real completa estão associados a objetos contínuos. 

De fato, matemáticos trabalham exaustivamente com esses conceitos, criando áreas como topologia geral para, entre outras coisas, reconhecer objetos discretos. Já análise é área da matemática que lida com o contínuo.
"""

# ╔═╡ 627f6db6-9617-11eb-0453-a1f9e341ecfe
md"""
**A reta real (contínua):**

![continuous](data:image/png;base64,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)
"""

# ╔═╡ 091a8a44-918c-11eb-2ee3-9be84a311afd
md"""
### Mas sempre ouvimos pelos corredores: eu só gosto de matemática discreta... Já eu de contínua ✋.
"""

# ╔═╡ 173b44ea-918c-11eb-116b-0bbaeffc3fe2
md"""
É comum que alunos (e professores) tomem um lado e gravitem em torno de uma das duas linhas. Por outro lado, é importante reconhecer que as duas áreas, apesar de parecerem completamente separadas, se encontram em muitos momentos. Nesse sentido é importante conhecer um pouco de cada e se sentir confortável com as duas. 

Um exemplo interessante é a própria Ciência da Computação. Até recentemente ela estava se tornado cada vez mais discreta, a ponto de eu ter ouvido de um _big shot_ da IEEE que ponto flutuante estava morrendo (no final da minha graduação, em 1994). O domínio do ponto flutuante se limitaria a situações específicas, no que chamamos de computação científica, associadas ao estudos de sistemas físicos em engenharia e física. 

Mas a popularidade de áreas novas, como Aprendizado de Máquina, têm contrariando essa afirmação. Ideias contínuas, como métodos de otimização baseados em descida por gradientes, voltam a ter cada vez mais importância em Ciência da Computação, reacendendo a necessidade de se dominar bem ideias contínuas. Outros exemplos de áreas que estão cada vez mais misturando o discreto e o contínuo são a Ciência de Dados e a Estatística.

E notem que o computador é uma máquina ideal para isso. Nele é possível fazer cálculos com alta precisão que permitem aproximar bem objetos contínuos. Mas ele é, intrinsecamente, um equipamento discreto. Fazer Matemática contínua no computador é andar nesse fronteira.

Alguns pontos para se guardar:

* Matemática contínua muitas vezes permite substituir sistemas enormes e complicados com vários detalhes por uma abstração mais simples de se entender e trabalhar.

* Em várias situações, a combinação do que é discreto e do que é contínuo é mais efetiva do que o uso de uma única abordagem.

* São muitos os exemplos atuais onde matemática contínua é fundamental: Aprendizado de Máquinas, Sistemas Dinâmicos, como em mecânica de fluidos, previsão do tempo e modelagem climática ou mesmo a compreensão da evolução de pandemias.
"""

# ╔═╡ 5c536430-9188-11eb-229c-e7feba62d257
md"""
### Um primeiro exemplo inesperado: indexação vs funções

Todos nós conhecemos o que são funções: objetos que processam entradas e devolvem valores. Tipicamente pensamos em fórmulas que dizem o que fazer com as entradas para calcular a saída.

Por outro lado, conhecemos bem o que é a indexação de um vetor: ela é usada acessar a informação previamente armazenada em uma certa posição. 

Qual a relação entre os dois conceitos? Indexação pode ser vista como uma função que dado índice devolve um valor. É uma função do conjunto de índices (que é discreto) no conjunto de valores armazenado no vetor!

Nesse sentido objetos que representam faixas em Julia são implementados justamente com esse conceito de indexação como função. Quando você encontra um objeto como `2:2:20` você pode pensar que ele é simplesmente o vetor `[2, 4, 6, ..., 20]` mas não. Internamente a faixa guarda apenas os três números `incio:passo:fim` e avalia a função `i → inicio + (i - 1)*passo if i <= fim`. 
Vamos ver isso em ação.
"""

# ╔═╡ 1e8ea849-40b7-41fd-b17f-cd2d991d5c24
collect(2:2:20) # Or [2:2:20;] - this expands the "iterator" into an ordinary vector

# ╔═╡ 679a39ee-99a5-4211-9adc-8296d499e37e
collect(2:2:20)[7] # Extracts an element from Memory (of course there is an address calculation)

# ╔═╡ 2c64f98d-dc84-4fa5-81ce-25b319ff9583
(2:2:20)[7] # Compute 2*7 (more or less)

# ╔═╡ 0a379cae-386d-4daa-ab6f-9d0424c1cdc1
begin
    f(x) = 2x
    f(7)     # Compute 2*7
end

# ╔═╡ 890c0fa2-c247-4f14-84f6-2bed69d0f0c5
md"""
Em qualquer um dos casos podemos interpretar a indexação como uma função cuja entrada está em $\{1,2,3,4,5,6,7,8,9,10\}$.
"""

# ╔═╡ 40095ad2-961f-11eb-1f23-83d1a381ace7
md"""
### Área: um objeto contínuo que é limite de discretos
"""

# ╔═╡ ed71b026-9565-11eb-1058-d77efe114562
md"""
Vamos agora nos voltar para ideia de objetos contínuos que são limites de objetos discretos. Um primeiro exemplo que vamos analisar são as áreas. Começando pela área do círculo. Uma forma tradicional de computar isso é usar a área de polígonos regulares:
"""

# ╔═╡ 68b60d09-acee-48d8-8bb1-7ab4faa6b785
gr()

# ╔═╡ 3b84bb0a-9566-11eb-1c1f-e30ca7330c09
md"""
n = $(@bind sides Slider(3:100, show_value=true, default=6))
"""

# ╔═╡ f20da096-9712-11eb-2a67-cd33f6ab8750
area(s) = (s / 2) * sin(2π / s)  # You can derive this formula yourself!

# ╔═╡ 02784976-9566-11eb-125c-a7f1f1bafd6b
begin
    θ = (0:0.01:1) * 2π
    plot(
        cos.(θ),
        sin.(θ),
        ratio=1,
        axis=false,
        legend=false,
        ticks=false,
        lw=4,
        color=:black,
        fill=false,
    )
    plot!(
        cos.(θ),
        sin.(θ),
        ratio=1,
        axis=false,
        legend=false,
        ticks=false,
        lw=4,
        color=:white,
        fill=true,
        alpha=0.6,
    )


    ϕ = (0:sides) * 2π / sides
    for i = 1:sides
        plot!(
            Shape([0, cos(ϕ[i]), cos(ϕ[i+1])], [0, sin(ϕ[i]), sin(ϕ[i+1])]),
            fill=true,
            lw=0,
        )
    end
    title!("Area = ($sides/2)sin(2π/$sides) ≈  $(area(sides)/π )  π")
end

# ╔═╡ 6fd93018-c33b-4682-91c3-7a20a41d9b03
area0 = area.(2 .^ (2:10)) # Area of polygons with # sides  = [4, 8, ..., 1024]

# ╔═╡ a306559f-e095-4f6d-94e8-b0be160e77fa
π

# ╔═╡ ea29e286-4b4a-4291-a093-cd942ba46e49
md"""
O que acontece se fizermos uma convolução "mágica" [-1/3,4/3]?
"""

# ╔═╡ 103c93ae-8175-4996-ab8f-5d537691defc
area1 = [4 / 3 * area0[i+1] .- 1 / 3 * area0[i] for i = 1:length(area0)-1]

# ╔═╡ a76ac67b-27b9-4e2b-9fca-61480dca5264
area2 = [16 / 15 * area1[i+1] .- 1 / 15 * area1[i] for i = 1:length(area1)-1]

# ╔═╡ c742742a-765b-4eb5-bd65-dc0cd6328255
md"""
Outra convolução cuidadosamente escolhida: [-1/15,16/15]. Você vê um padrão emergir?
"""

# ╔═╡ 4dd03325-2498-4fe7-9212-f964081a0300
area3 = [64 / 63 * area2[i+1] .- 1 / 63 * area2[i] for i = 1:length(area2)-1]

# ╔═╡ 626242ea-544c-49fc-9884-c70dd6800902
area4 = [256 / 255 * area3[i+1] .- 1 / 255 * area3[i] for i = 1:length(area3)-1]

# ╔═╡ dbccc2d5-c2af-48c4-8726-a95c09da78ae
md"""
Porque isso funciona?
"""

# ╔═╡ 82a407b6-0ecb-4011-a0f6-bc9e1f51393f
md"""
Area(s) = ``(s/2) \sin (2\pi/s) = \pi- \frac{2\pi^3}{3} s^{-2}  + \frac{2\pi^5}{15}s^{-4} -  \frac{4\pi^7}{315} s^{-6} + \ldots``    

com `` s \rightarrow \infty ``.
"""

# ╔═╡ 5947dc80-9714-11eb-389d-1510a1137a50
md"""
Area(s) = `` \pi  -  c_1 /s^2  + c_2 / s^4  - \ldots`` 

Area(2s) = `` \pi  -  c_1 /(4s^2)  + c_2 / (16s^4)  - \ldots`` 
"""

# ╔═╡ db8121ec-8546-4f1e-8153-cff5b4df39df
md"""
Agora imagine o que resulta (4/3) Area(2s) - (1/3) Area(s).

Obtemos
``\pi + c s^{-4}`` como termo dominante. Então duplicar o número de lados, s, reduz o erro da aproximação por 16, aproximadamente. Antes o fator de redução era de apenas 4.

E podemos continuar o jogo achando novas convoluções que eliminem os termos dominantes.

Nesse exemplo já atingimos o número total de dígitos significativos em um número de ponto flutuante de precisão dupla. Vamos aproveitar que Julia possui números de precisão arbitrária e ir um pouco mais longe.
"""

# ╔═╡ d4f83a20-62cf-47f1-a622-d5c4c34e4813
areab(s) = (s / 2) * sin(2 * big(π) / s)  # Using Big Float that defaults to 256 digits

# ╔═╡ 37fc6e56-9714-11eb-1427-b75613800366
big(π)

# ╔═╡ 4a072870-961f-11eb-1215-17efa0013873
md"""
## Areas de novo: múltiplas possibilidades de definição

Há várias formas de se tentar estender a noção de área para figuras além de polígonos simples. Por exemplo podemos usar quadrados inscritos.
"""

# ╔═╡ de9066e2-d5eb-49e3-be71-edda8e8e31dd
@bind s Slider(2:40, show_value=true)

# ╔═╡ 4d4705d0-9568-11eb-085c-0fc556c4cfe7
let

    plot()
    for i = -s:s
        plot!([i / s, i / s], [-1, 1], color=RGB(0, 1, 0), lw=1)
        plot!([-1, 1], [i / s, i / s], color=RGB(0, 1, 0), lw=1)
    end
    P = plot!(
        cos.(θ),
        sin.(θ),
        ratio=1,
        axis=false,
        legend=false,
        ticks=false,
        lw=3,
        color=:black,
    )
    plot!(P)

    h = 1 / s
    a = 0


    xx = floor(√2 / 2h)
    x = xx * h
    y = x
    plot!(Shape([-x, -x, x, x], [-y, y, y, -y]), color=RGB(1, 0, 0), alpha=0.7)

    a = a + Int(2 * xx)^2


    for i = -s:(-xx-1), j = -s:(-1)
        x = i * h
        y = j * h
        if (x^2 + y^2 ≤ 1) &
           ((x + h)^2 + (y + h)^2 ≤ 1) &
           (x^2 + (y + h)^2 ≤ 1) &
           ((x + h)^2 + y^2 ≤ 1)
            plot!(Shape([x, x, x + h, x + h], [y, y + h, y + h, y]), color=:blue)
            plot!(Shape([-x - h, -x - h, -x, -x], [y, y + h, y + h, y]), color=:blue)
            plot!(Shape([x, x, x + h, x + h], [-y - h, -y, -y, -y - h]), color=:blue)
            plot!(Shape([-x - h, -x - h, -x, -x], [-y - h, -y, -y, -y - h]), color=:blue)
            plot!(Shape([y, y + h, y + h, y], [x, x, x + h, x + h]), color=:blue)
            plot!(Shape([-y - h, -y, -y, -y - h], [x, x, x + h, x + h]), color=:blue)
            plot!(Shape([y, y + h, y + h, y], [-x - h, -x - h, -x, -x]), color=:blue)
            plot!(Shape([-y - h, -y, -y, -y - h], [-x - h, -x - h, -x, -x]), color=:blue)
            a += 8
        end
    end


    xlabel!("s  =  $s")

    title!("$(a//s^2) =  $(a*h^2/π) π")
    plot!()


end

# ╔═╡ e6884c6c-9712-11eb-288b-f1a439b0aba3
md"""
De fato, à medida que a dimensão dos quadrados diminui, a sequência das áreas dos quadrados inscritos converge a π que é a área do círculo de raio unitário. Mas seria diferente se usássemos outra figura? Triângulos? Hexágonos? E se ao invés de olharmos os inscritos, olhássemos os que tem alguma intersecção com o círculo?

Essa pergunta já foi respondida pelos matemáticos: em todos os casos o valor limite é o mesmo. Esse valor especial, esse conceito particular, merece então um nome: **área**. Existem vários exemplos de processos assim na matemática. Objetos contínuos que são limites "estáveis" de diferentes aproximações discretas. Nessa caso fica claro como esse objeto captura um novo conceito bem definido e que ele merece, então, ser estudado. Vejamos um outro exemplo.

## Movimento Browniano: limite de passeios aleatórios
"""

# ╔═╡ 1e18f95c-cd53-4ede-8d93-572c81f872da
md"""
Um passeio aleatório é uma função aleatória discreta. Ela está definida sobre valores em um reticulado. Vamos agora pensar em um processo limite sobre passeios aleatórios com passos cada vez mais curtos. A ideia é o seguinte:

1. Normalizamos o intervalo de tempo para o [0, 1].
2. Esse intervalo então é dividido em N subintervalos de comprimento h = 1/N.
3. Iniciando no tempo 0, definimos um passeio aleatório que a cada instante do tempo t escolhe a próxima posição a partir da posição atual mais um variável aleatória **com qualquer distribuição** de média 0 e variância h (o comprimento dos subintervalos).
4. Aumentamos N e vemos o que obtemos no limite.
"""

# ╔═╡ 4f845436-9646-11eb-2445-c12746a9e556
begin
    N = 1024
    h = 1 / N
    #dist(N) = sqrt(h) .* randn(N) # Normal with 0 mean and h variance
    #dist(N) = sqrt(12*h) .* (rand(N) .- 0.5)  # Uniform with 0 mean and h variance
    dist(N) = sqrt(h) .* (rand(Erlang(), N) .- 1.0) # Erlang with unit shape and scale
    # Try other distribuitions
    v = dist(N)
end

# ╔═╡ 155241b0-9646-11eb-180e-89c8651536c6
@bind j Slider(1:9, show_value=true, default=6)

# ╔═╡ 31d56008-9646-11eb-1985-2b68af354773
begin
    J = N ÷ 2^j
    timestep = J * h
end

# ╔═╡ 1761187e-9645-11eb-3778-b132f856696d
begin
    plot()
    w = [0; cumsum(v)]
    plot!((0:N) ./ N, w)
    scatter!((0:J:N) ./ N, w[1:J:end], legend=false, m=:o, ms=5, color=:red, lw=5)
    plot!(ylims=(-2, 2))
    xlabel!("time")
    ylabel!("position")
    title!("Random walk with some points in evidence")
end

# ╔═╡ 48eed5ae-b3cf-4998-ba2f-ba50e120b557
md"""
Vamos ver como ficam a distribuições das possíveis posições em um tempo t′ fixo, considerando muitas simulações.
"""

# ╔═╡ 59a8b92c-0454-4a9c-89d8-e4a044d156d3
begin
    # All possible times
    times = cumsum(h * ones(N))

    # Makes 10_000 simulations and plot the position at time t′
    t′ = 0.3
    ind = argmin(abs.(t′ .- times))
    samples = Float64[]
    for i = 1:10_000
        local w = cumsum(dist(N))
        push!(samples, w[ind])
    end
    histogram(samples, nbis=20, normalize=true, legend=false)

    # Show a normal distribution with mean 0 and variance t′
    normalpdf(x, σ²) = exp(-x^2 / (2 * σ²)) / √(2π * σ²)
    xs = range(-4.0, 4.0, length=200)
    plot!(xs, normalpdf.(xs, times[ind]), lw=3)
    title!("Positions at time $t′")
end


# ╔═╡ 2c0c01fe-9f54-4d5b-9f7f-b7ef0d3a8474
md"""
É uma normal com média 0 e variância t′! O que estamos vendo é que esse processo limite converge então para um passeio aleatório em tempo contínuo em que a cada instante t′ a distribuição das possíveis posições é essa normal. Esse processo aleatório é chamado de **movimento browniano**.
"""

# ╔═╡ 9c519eca-9710-11eb-20dc-3f76801545d1
@bind t Slider(0.01:0.01:8, show_value=true)

# ╔═╡ 7c4b82c8-9710-11eb-101e-53616e278289
begin
    x = -3:0.01:3
    plot(x, normalpdf.(x, t), ylims=(0, 1), legend=false)
end

# ╔═╡ 236347f9-71c3-4299-9537-14d89eac2b93
plotly()

# ╔═╡ 021d7e9a-9711-11eb-063b-11441afa2e69
begin
    surface(-2:0.05:2, 0.2:0.01:1, normalpdf, alpha=0.4, c=:Reds, legend=false)
    for t = 0.2:0.1:1
        plot!(-2:0.05:2, fill(t, length(-2:0.05:2)), normalpdf.(-2:0.05:2, t), c=:black)
    end
    xlabel!("x")
    ylabel!("time")
    plot!()
end

# ╔═╡ f16cb73d-4289-4ba2-93de-7acd0c51bb57
md"## Outros exemplos (muitos já vimos):"

# ╔═╡ bb8dc4fe-918d-11eb-2bde-bb00c47a1c27
md"""
#### Somas e integrais (definidas)
"""

# ╔═╡ c4a3bf6c-918d-11eb-1d50-911f83b6df81
md"""
#### Somas acumuladas e integrais indefinidas
"""

# ╔═╡ d99dc494-918d-11eb-2733-29ce93ba584e
md"""
#### Filtros de diferenças finitas e derivadas / gradientes
"""

# ╔═╡ 0fb84ff2-918e-11eb-150f-8dad121c87bc
md"""
#### Convoluções discretas e contínuas
"""

# ╔═╡ a7c5ef96-918d-11eb-0632-f94386eb64f2
md"""
#### Passeios aleatórios discretos e movimento browniano
"""

# ╔═╡ 75672be6-918d-11eb-1e10-07fbcc72abbd
md"""
#### Distribuição binomial e distribuição normal
"""

# ╔═╡ 906758c6-918d-11eb-08ae-b3c4f7870b4e
md"""
#### Transformadas de Fourier discreta e contínua
"""

# ╔═╡ c32e0f9c-918e-11eb-1cf9-a340786db24a
md"""
Termino deixando com vocês um ensaio original do Alan Edelman, autor original desta palestra. 

Alan's essay:

In what sense does the continuous even exist?  The fact of the matter is that there are limits that give the same answer no matter how you get there, and these limits
are important to us. For example, no matter how you cover an area, by little rectangles, the sum always converges to what we intuitively call area.
The normal distribution is interesting in that no matter which starting finite distribution we might take, if add n independent copies and normalize to variance 1 we get the same limit.  Again, there are so many ways to start, and yet we always end up with the same thing.  Continuous mathematics is full of so many examples, where discrete objects end up behaving the same.

Indeed what happens as discrete objects get larger and larger, their complexity gets out of control if one wants to keep track of every detail, but they get simpler in their aggregate behavior.
"""

# ╔═╡ e115c506-ce45-42e4-9fb4-fe07fc5512a1
md"## Funções auxiliares"

# ╔═╡ 686904c9-1cc4-4476-860b-159e56471e38
function colorgoodbad(should_be, given)
    indexofmistake =
        something(findfirst(collect(should_be) .!== collect(given)), length(given) + 1)
    @htl(
        """
    <span style="color:black">$(given[1:indexofmistake-1])</span><span style="color: red">$(given[indexofmistake:end])</span>
    """
    )
end

# ╔═╡ bcfd1585-8161-43a2-8b19-ed654df2e0e1
colorgoodbad(string(float(π)), string(22 / 7))

# ╔═╡ 43d20d56-d56a-47a8-893e-f726c1a99651
pp(x) = colorgoodbad(string(float(π)), (@sprintf "%.15f" x))

# ╔═╡ 01631c38-9713-11eb-30bf-3d23cf0d3dc8
begin
    area0b = areab.(big.([2^i for i = 1:16])) # Goes to 65536
    colorgoodbad((@sprintf "%.80f" big(π)), (@sprintf "%.80f" big(area0b[end])))
end

# ╔═╡ 553bdb0a-9714-11eb-1646-413a969d6884
begin
    area1b = [4 // 3 * area0b[i+1] .- 1 // 3 * area0b[i] for i = 1:length(area0b)-1]
    colorgoodbad((@sprintf "%.80f" big(π)), (@sprintf "%.80f" big(area1b[end])))
end

# ╔═╡ 8bcd29e2-41db-4969-9932-3cc56edfdc18
colorgoodbad((@sprintf "%.30f" big(π)), (@sprintf "%.30f" big(area1b[end])))

# ╔═╡ 453f2585-157d-490a-9d1c-0b02939d0a11
begin
    area2b = [16 // 15 * area1b[i+1] .- 1 // 15 * area1b[i] for i = 1:length(area1b)-1]
    colorgoodbad((@sprintf "%.80f" big(π)), (@sprintf "%.80f" big(area2b[end])))
end

# ╔═╡ bc1efddd-c959-4407-9a86-ba73a64508a8
begin
    area3b = [64 // 63 * area2b[i+1] .- 1 // 63 * area2b[i] for i = 1:length(area2b)-1]
    colorgoodbad((@sprintf "%.80f" big(π)), (@sprintf "%.80f" big(area3b[end])))
end

# ╔═╡ 516b69d8-5d94-4b4d-9596-2db0dfbf4038
begin
    area4b = [256 // 255 * area3b[i+1] .- 1 // 255 * area3b[i] for i = 1:length(area3b)-1]
    colorgoodbad((@sprintf "%.80f" big(π)), (@sprintf "%.80f" big(area4b[end])))
end

# ╔═╡ cec13915-8adb-4627-b220-591377239997
begin
    area5b =
        [1024 // 1023 * area4b[i+1] .- 1 // 1023 * area4b[i] for i = 1:length(area4b)-1]
    colorgoodbad((@sprintf "%.80f" big(π)), (@sprintf "%.80f" big(area5b[end])))
end

# ╔═╡ 6d954628-6290-4867-8144-dd486551545d
begin
    area6b =
        [4096 // 4095 * area5b[i+1] .- 1 // 4095 * area5b[i] for i = 1:length(area5b)-1]
    colorgoodbad((@sprintf "%.80f" big(π)), (@sprintf "%.80f" big(area6b[end])))
end

# ╔═╡ 00478b2c-5dcc-44fc-a7be-a3dadf6300e7
begin
    area7b =
        [16384 // 16383 * area6b[i+1] .- 1 // 16383 * area6b[i] for i = 1:length(area6b)-1]
    colorgoodbad((@sprintf "%.80f" big(π)), (@sprintf "%.80f" big(area7b[end])))
end

# ╔═╡ 23d1186e-7d56-40bf-b208-c6e9a3ff120b
begin
    area8b =
        [65536 // 65535 * area7b[i+1] .- 1 // 65535 * area7b[i] for i = 1:length(area7b)-1]
    colorgoodbad((@sprintf "%.80f" big(π)), (@sprintf "%.80f" big(area8b[end])))
end

# ╔═╡ c03d45f8-9188-11eb-2e11-0fafa39f253d
function pyramid(rows::Vector{<:Vector}; horizontal=false, padding_x=8, padding_y=2)

    style = (; padding="$(padding_y)px $(padding_x)px")
    render_row(xs) = @htl(
        """<div><padder></padder>$([@htl("<span style=$(style)>$(x)</span>") for x in xs])<padder></padder></div>"""
    )

    @htl("""
     <style>
     .pyramid {
     	flex-direction: column;
     	display: flex;
         font-family: monospace;
         font-size: 0.75rem;
     }
     .pyramid.horizontal {
     	flex-direction: row;
     }
     .pyramid div {
     	display: flex;
     	flex-direction: row;
     }
     .pyramid.horizontal div {
     	flex-direction: column;
     }
     .pyramid div>span:hover {
     	background: rgb(255, 220, 220);
     	font-weight: 900;
     }
     .pyramid div padder {
     	flex: 1 1 auto;
     }
     .pyramid div span {
     	text-align: center;
     }


     </style>
     <div class=$(["pyramid", (horizontal ? "horizontal" : "vertical")])>
     $(render_row.(rows))
     </div>

     """)
end

# ╔═╡ d2d1366b-9b6d-4e54-a0c4-7087f5f063c4
pyramid(([pp.(area0), pp.(area1)]), horizontal=true)

# ╔═╡ 6577e546-8f0b-413a-a8bb-b9c12803199d
pyramid([pp.(area0), pp.(area1), pp.(area2)], horizontal=true)

# ╔═╡ 893a56b0-f5d0-4f8d-ba15-1048180a7e53
pyramid([pp.(area0), pp.(area1), pp.(area2), pp.(area3), pp.(area4)], horizontal=true)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
GraphPlot = "a2cc645c-3eea-5389-862e-a155d0052231"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
LightGraphs = "093fc24a-ae57-5d10-9952-331d41423f4d"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
Distributions = "~0.25.76"
GraphPlot = "~0.5.2"
HypertextLiteral = "~0.9.4"
LightGraphs = "~1.3.5"
Plots = "~1.35.5"
PlutoUI = "~0.7.48"
SpecialFunctions = "~2.1.7"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.3"
manifest_format = "2.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "f87e559f87a45bece9c9ed97458d3afe98b1ebb9"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.1.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "84259bb6172806304b9101094a7cc4bc6f56dbc6"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.5"

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

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e7ff6cadf743c098e08fca25c91103ee4303c9bb"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.6"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "1fd869cc3875b57347f7027521f561cf46d1fcd8"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.19.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "d08c20eef1f2cbc6e60fd3612ac4340b89fea322"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.9"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "3ca828fe1b75fa84b021a7860bd039eaea84d2f2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.3.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Compose]]
deps = ["Base64", "Colors", "DataStructures", "Dates", "IterTools", "JSON", "LinearAlgebra", "Measures", "Printf", "Random", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "d853e57661ba3a57abcdaa201f4c9917a93487a2"
uuid = "a81c6b42-2e10-5240-aca2-a61377ecd94b"
version = "0.9.4"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.DataAPI]]
git-tree-sha1 = "46d2680e618f8abd007bce0c3026cb0c4a8f2032"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.12.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "04db820ebcfc1e053bd8cbb8d8bccf0ff3ead3f7"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.76"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "c36550cb29cbe373e95b3f40486b9a4148f89ffd"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.2"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "802bfc139833d2ba893dd9e62ba1767c88d708ae"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.5"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

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

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "00a9d4abadc05b9476e937a5557fcce476b9e547"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.69.5"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "bc9f7725571ddb4ab2c4bc74fa397c1c5ad08943"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.69.1+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "fb83fbe02fe57f2c068013aa94bcdf6760d3a7a7"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+1"

[[deps.GraphPlot]]
deps = ["ArnoldiMethod", "ColorTypes", "Colors", "Compose", "DelimitedFiles", "Graphs", "LinearAlgebra", "Random", "SparseArrays"]
git-tree-sha1 = "5cd479730a0cb01f880eff119e9803c13f214cab"
uuid = "a2cc645c-3eea-5389-862e-a155d0052231"
version = "0.5.2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "ba2d094a88b6b287bd25cfa86f301e7693ffae2f"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.7.4"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "a97d47758e933cd5fe5ea181d178936a9fc60427"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.5.1"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions", "Test"]
git-tree-sha1 = "709d864e3ed6e3545230601f94e11ebc65994641"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.11"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.Inflate]]
git-tree-sha1 = "5cd07aab533df5170988219191dfad0519391428"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.3"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "f377670cda23b6b7c1c0b3893e37451c5c1a2185"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.5"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

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
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "ab9aa169d2160129beb241cb2750ca499b4e90e9"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.17"

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
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LightGraphs]]
deps = ["ArnoldiMethod", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "432428df5f360964040ed60418dd5601ecd240b6"
uuid = "093fc24a-ae57-5d10-9952-331d41423f4d"
version = "1.3.5"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "94d9c52ca447e23eac0c0f074effbcd38830deb5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.18"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "5d4d2d9904227b8bd66386c1138cf4d5ffa826bf"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "0.4.9"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

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
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

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

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "3c3c4a401d267b04942545b1e964a20279587fd7"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.3.0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e60321e3f2616584ff98f0a4f18d98ae6f89bbb3"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.17+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "cf494dca75a69712a72b80bc48f59dcf3dea63ec"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.16"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "6c01a9b494f6d2a9fc180a08b182fcb06f0958a0"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.2"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "21303256d239f6b484977314674aef4bb1fe4420"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.1"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SnoopPrecompile", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "0a56829d264eb1bc910cf7c39ac008b5bcb5a0d9"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.35.5"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "efc140104e6d0ae3e7e30d56c98c4a927154d684"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.48"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "c6c0f690d0cc7caddb74cef7aa847b824a16b256"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+1"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "97aa253e65b784fd13e83774cadc95b38011d734"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.6.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "d12e612bba40d189cead6ff857ddb67bd2e6a387"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.1"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase", "SnoopPrecompile"]
git-tree-sha1 = "9b1c0c8e9188950e66fc28f40bfe0f8aac311fe0"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.7"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

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

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "f86b3a049e5d05227b10e15dbb315c5b90f14988"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.9"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "5783b877201a82fc0014cbf381e7e6eb130473a4"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.0.1"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "8a75929dcd3c38611db2f8d08546decb514fcadf"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.9"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "e59ecc5a41b000fa94423a578d29290c7266fc10"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

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
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

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
git-tree-sha1 = "9ebfc140cc56e8c2156a15ceac2f0302e327ac0a"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+0"
"""

# ╔═╡ Cell order:
# ╟─bad1ae0f-0b0b-4cdd-94ff-e9a55fad6dfe
# ╠═d155ea12-9628-11eb-347f-7754a33fd403
# ╟─01506de2-918a-11eb-2a4d-c554a6e54631
# ╟─ee349b52-9189-11eb-2b86-b5dc15ebe432
# ╟─877deb2c-702b-457b-a54b-f27c277928d4
# ╟─43e39a6c-918a-11eb-2408-93563b4fb8c1
# ╟─719a4c8c-9615-11eb-3dd7-7fb786f7fa17
# ╟─45ecee7e-970e-11eb-22fd-01f56876684e
# ╟─61ffe0f2-9615-11eb-37d5-f9e30a31c111
# ╟─627f6db6-9617-11eb-0453-a1f9e341ecfe
# ╟─091a8a44-918c-11eb-2ee3-9be84a311afd
# ╟─173b44ea-918c-11eb-116b-0bbaeffc3fe2
# ╟─5c536430-9188-11eb-229c-e7feba62d257
# ╠═1e8ea849-40b7-41fd-b17f-cd2d991d5c24
# ╠═679a39ee-99a5-4211-9adc-8296d499e37e
# ╠═2c64f98d-dc84-4fa5-81ce-25b319ff9583
# ╠═0a379cae-386d-4daa-ab6f-9d0424c1cdc1
# ╟─890c0fa2-c247-4f14-84f6-2bed69d0f0c5
# ╟─40095ad2-961f-11eb-1f23-83d1a381ace7
# ╟─ed71b026-9565-11eb-1058-d77efe114562
# ╠═68b60d09-acee-48d8-8bb1-7ab4faa6b785
# ╟─3b84bb0a-9566-11eb-1c1f-e30ca7330c09
# ╟─02784976-9566-11eb-125c-a7f1f1bafd6b
# ╠═f20da096-9712-11eb-2a67-cd33f6ab8750
# ╠═6fd93018-c33b-4682-91c3-7a20a41d9b03
# ╠═a306559f-e095-4f6d-94e8-b0be160e77fa
# ╟─ea29e286-4b4a-4291-a093-cd942ba46e49
# ╠═103c93ae-8175-4996-ab8f-5d537691defc
# ╠═bcfd1585-8161-43a2-8b19-ed654df2e0e1
# ╠═43d20d56-d56a-47a8-893e-f726c1a99651
# ╠═d2d1366b-9b6d-4e54-a0c4-7087f5f063c4
# ╠═a76ac67b-27b9-4e2b-9fca-61480dca5264
# ╟─c742742a-765b-4eb5-bd65-dc0cd6328255
# ╠═6577e546-8f0b-413a-a8bb-b9c12803199d
# ╠═4dd03325-2498-4fe7-9212-f964081a0300
# ╠═626242ea-544c-49fc-9884-c70dd6800902
# ╠═893a56b0-f5d0-4f8d-ba15-1048180a7e53
# ╠═8bcd29e2-41db-4969-9932-3cc56edfdc18
# ╟─dbccc2d5-c2af-48c4-8726-a95c09da78ae
# ╟─82a407b6-0ecb-4011-a0f6-bc9e1f51393f
# ╟─5947dc80-9714-11eb-389d-1510a1137a50
# ╟─db8121ec-8546-4f1e-8153-cff5b4df39df
# ╠═d4f83a20-62cf-47f1-a622-d5c4c34e4813
# ╠═01631c38-9713-11eb-30bf-3d23cf0d3dc8
# ╠═553bdb0a-9714-11eb-1646-413a969d6884
# ╠═453f2585-157d-490a-9d1c-0b02939d0a11
# ╠═bc1efddd-c959-4407-9a86-ba73a64508a8
# ╠═516b69d8-5d94-4b4d-9596-2db0dfbf4038
# ╠═cec13915-8adb-4627-b220-591377239997
# ╠═6d954628-6290-4867-8144-dd486551545d
# ╠═00478b2c-5dcc-44fc-a7be-a3dadf6300e7
# ╠═23d1186e-7d56-40bf-b208-c6e9a3ff120b
# ╠═37fc6e56-9714-11eb-1427-b75613800366
# ╟─4a072870-961f-11eb-1215-17efa0013873
# ╠═de9066e2-d5eb-49e3-be71-edda8e8e31dd
# ╟─4d4705d0-9568-11eb-085c-0fc556c4cfe7
# ╟─e6884c6c-9712-11eb-288b-f1a439b0aba3
# ╟─1e18f95c-cd53-4ede-8d93-572c81f872da
# ╠═4f845436-9646-11eb-2445-c12746a9e556
# ╠═155241b0-9646-11eb-180e-89c8651536c6
# ╟─31d56008-9646-11eb-1985-2b68af354773
# ╠═1761187e-9645-11eb-3778-b132f856696d
# ╟─48eed5ae-b3cf-4998-ba2f-ba50e120b557
# ╠═59a8b92c-0454-4a9c-89d8-e4a044d156d3
# ╟─2c0c01fe-9f54-4d5b-9f7f-b7ef0d3a8474
# ╠═9c519eca-9710-11eb-20dc-3f76801545d1
# ╠═7c4b82c8-9710-11eb-101e-53616e278289
# ╠═236347f9-71c3-4299-9537-14d89eac2b93
# ╠═021d7e9a-9711-11eb-063b-11441afa2e69
# ╟─f16cb73d-4289-4ba2-93de-7acd0c51bb57
# ╟─bb8dc4fe-918d-11eb-2bde-bb00c47a1c27
# ╟─c4a3bf6c-918d-11eb-1d50-911f83b6df81
# ╟─d99dc494-918d-11eb-2733-29ce93ba584e
# ╟─0fb84ff2-918e-11eb-150f-8dad121c87bc
# ╟─a7c5ef96-918d-11eb-0632-f94386eb64f2
# ╟─75672be6-918d-11eb-1e10-07fbcc72abbd
# ╟─906758c6-918d-11eb-08ae-b3c4f7870b4e
# ╟─c32e0f9c-918e-11eb-1cf9-a340786db24a
# ╟─e115c506-ce45-42e4-9fb4-fe07fc5512a1
# ╟─686904c9-1cc4-4476-860b-159e56471e38
# ╟─c03d45f8-9188-11eb-2e11-0fafa39f253d
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
