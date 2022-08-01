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

# ╔═╡ 103cd2f4-903c-11eb-1116-a51dc540175c
begin
    using Statistics
    using LinearAlgebra
    using Plots
    using PlutoUI
    using Symbolics
end

# ╔═╡ 5d62e16c-8fd9-11eb-1c44-0b0232614011
TableOfContents(aside = true)

# ╔═╡ e3a22dc9-4046-4f97-b870-11746cb49ac5
md"Tradução livre de [random_variables_as_types.jl](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week7/random_variables_as_types.jl)"

# ╔═╡ 6bbfa37e-8ffe-11eb-3031-19ea76a6a8d2
md"""
# Conceitos de hoje

Na aula de hoje vamos ver com um pouco mais de detalhes como conseguimos organizar nosso código em torno de tipos em Julia. Para isso vamos ver algumas detalhes sobre o seu **sistema de tipos**.

Veremos que com algumas definições bem escolhidas é possível gerar código bastante geral e poderoso.

Conceitos importantes para hoje
- Usando tipos para capturar, com código, conceitos abstratos.
- Tipos abstratos.
- Subtipos
- Como criar expressões "subjacentes" usando tipos.
- `sum` em uma expressão com  iterator / gerador.
"""

# ╔═╡ 8a125ca0-8ff5-11eb-0607-45f993fb5ca7
md"""
# Distribuições de probabilidade como tipos
"""

# ╔═╡ b2971770-8ff7-11eb-002c-f9dc9d6d0d70
md"""
Essa palestra pode parecer que trata de distribuições de probabilidade de variáveis aleatórios (e, de fato, isso também é verdade). Mas nosso principal objetivo é que você a entenda também no cotexto de uma discussão sobre engenharia de software e abstrações, já que os princípios de programação que vamos discutir podem ser aplicados em vários contextos diferentes.
"""

# ╔═╡ cdd4497c-903d-11eb-03be-abf6002e75e7
md"""
## Variáveis aleatória e distribuições de probabilidade
"""

# ╔═╡ ae1b3a26-8fd3-11eb-3746-ad48301ff96e
md"""
Lembre-se que uma **variável aleatória** $X$ é um objeto que pode resultar em
diferentes valores $x$, que têm associadas uma certa **probabilidade**
$\mathbb{P}(X = x)$. Isso, pelo menos, no caso discreto.

A forma como essas probabiidades se distribuem em todos os resultados possíveis é chamada de **distribuição de probabilidade** da variável aleatória. 

"""

# ╔═╡ ae0008ee-8fd3-11eb-38bd-f52598a97dce
md"""
## Distribuições gaussianas
"""

# ╔═╡ c6c3cf54-8fd4-11eb-3b4f-415f1a2da18e
md"""
Vamos usar como exemplo inicial um tipo muito importante de distribuição de probailidade: a **distribuição gaussiana ou distribuição normal** com média $\mu$ e variância $\sigma^2$ (ou desvio padrão $\sigma$).

Nós podemos amostrar de uma distribuição gaussiana com média $0$ e variância $1$ usando a função `randn` (que quer dizer "random normal"). Podemos, então, deslocar e mudar a escala para obter umaa distribuição gaussiana qualquer:
"""

# ╔═╡ d8b74772-8fd4-11eb-3943-f98c29d02171
md"""
μ = $(@bind μ Slider(-3:0.01:3, show_value=true, default=0.0))
σ = $(@bind σ Slider(0.01:0.01:3, show_value=true, default=1.0))
"""

# ╔═╡ b11d964e-8fd4-11eb-3f6a-43e8d2fa462c
data = μ .+ σ .* randn(10^5)   # transform standard normal

# ╔═╡ ad7b3bee-8fd5-11eb-06f6-b39738d4b1fd
bell_curve(x) = exp(-x^2 / 2) / √(2π)

# ╔═╡ c76cd760-8fd5-11eb-3500-5d15515c33f5
bell_curve(x, μ, σ) = bell_curve((x - μ) / σ) / σ

# ╔═╡ b8c253f8-8fd4-11eb-304a-b1be962687e4
begin
    histogram(
        data,
        alpha = 0.2,
        norm = true,
        bins = 100,
        leg = false,
        title = "μ=$(μ), σ=$(σ)",
        size = (500, 300),
    )
    xlims!(-6, 6)
    ylims!(0, 0.7)


    xs = [μ - σ, μ, μ + σ]

    plot!(-6:0.01:6, x -> bell_curve(x, μ, σ), lw = 2)

    plot!((μ-σ):0.01:(μ+σ), x -> bell_curve(x, μ, σ), fill = true, alpha = 0.5, c = :purple)

    plot!([μ, μ], [0.05, bell_curve(μ, μ, σ)], ls = :dash, lw = 2, c = :white)
    annotate!(μ, 0.03, text("μ", :white))
    #	annotate!(μ + σ, 0.03, text("μ+σ", :yellow))
    #	annotate!(μ, 0.03, text("μ", :white))


end

# ╔═╡ f31275fa-8fd5-11eb-0b76-7d0513705273
bell_curve(0, 3, 2)

# ╔═╡ 276a7c36-8fd8-11eb-25d8-3d4cfaa1f71c
md"""
### Soma de duas Gaussianas
"""

# ╔═╡ 11f3853c-903e-11eb-04cd-a125017ad5d8
md"""
Vamos agora tentar **somar** duas distribuições gaussianas. Do ponto de vista empírico (experimental) a soma de duas variáveis aletórias é fácil de calcular. Basta amostrar as duas e somar os resultados dos experimentos:
"""

# ╔═╡ 2be60570-8fd8-11eb-0bdf-951280dc6181
begin
    data1 = 4 .+ sqrt(0.3) .* randn(10^5)
    data2 = 6 .+ sqrt(0.7) .* randn(10^5)

    total = data1 + data2
end

# ╔═╡ 5e094b52-8fd8-11eb-2ac4-5797599ab013
histogram(total, alpha = 0.5, leg = false, norm = true, size = (500, 300))

# ╔═╡ 79fb368c-8fd9-11eb-1c9c-bd0ceb122b11
md"""
Visualmente, parece que conseguimos de volta uma nova variável que segue uma distribuição gaussiana. E isso é um fato: a soma de duas gaussianas de médias  $\mu_1$ e $\mu_2$ e variâncias $\sigma_1^2$ e $\sigma_2^2$ é uma gaussiana. A média passa a ser $\mu_1 + \mu_2$ e a variância $\sigma_1^2 + \sigma_2^2$.  Vamos codificar esse resultado computacionalmente.
"""

# ╔═╡ a2481afa-8fd3-11eb-1769-bf97f42ea79e
md"""
## Variáveis aleatórias teóricas versus amostras

O que uma variável aletória teórica deveria ser capaz de fazer? O que deveria ser possível de se fazer a partir de uma amostra (ou com amostragem) ?


- **Nome**, por exemplo, `Gaussian`
- **Parâmetros**, por exemplo,  $\mu$ e $\sigma^2$

### Teórica 

- Média teórica.
- Variância teórica.

- A soma teórica de duas variáveis aleatória.
- O produto teórico de duas variáveis aletórias.

- Distribuição de probabilidade.

### Amostras

- Obtidas a partir da **amostragem** de uma variável aletória com distribuição determinada.
- Média da amostra.
- Variância da amostra.

- Soma de amostras.

- Histograma.
"""

# ╔═╡ a9654334-8fd9-11eb-2ea8-8d308ea66963
md"""

# Para quer definir um tipo?
"""

# ╔═╡ bb2132e0-8fd9-11eb-3bdd-594726c04859
md"""
Como podemos representar uma **distribuição e as respectivas variáveis aleatórias** em software?

Algumas linguagens permitem falar naturalmente de várias funções associadas a uma distribuição/variável aletória, mas não é possível falar da distribuição/variável aleatória em sim.

Vejamos o exemplo de R. Em R há padrões que definem regras, convenções, para representar densidades (`d`), por exemplo, seguindos de um nome como `norm` para definir qual a distribuição que possui aquela densidade. Mas não há um nome para falar da distribuição em si. As funções típicas são:

- `d` para a densidade.
- `p` para a função distribuição.
- `q` para a função quntil.
- `r` para gerar amostras aleatórias.

Veja, por exemplo,
- [Distribuição normal distribution em R](https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/Normal)

- [Distribuição chi-quadrado em R](https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/Chisquare)

Não deixa de ser curioso que todos esses objetos falem de características de uma distribuição (ou variável aletória) que você pode encontrar em qualquer curso de probabilidade, mas ao mesmo tempo não é possível falar da distribuição em si.
"""

# ╔═╡ f307e3b8-8ff0-11eb-137e-4f9a03bb4d78
md"""
Nós vamos adotar outro caminho, vamos buscar uma forma de se referir a distribuição/respectiva variável aleatória específica. 

Obs: **A partir desse ponto vou adotar a postura dos autores que usa o termo "variável aleatória" quase como sinônimo da respectiva distribuição, permitindo amostrar dela múltiplas vezes. Isso conflita com a convenção, por exemplo, do pacote `Distributions.jl` que usa o nome "distribuição" esse tipo de objetos. Por outro lado, isso é uma vatangem, já que permitem que o nosso código conviva com o `Distribution.jl` sem que ocorram conflitos de nomes.**

Nós queremos definir tipos que recebam os parâmetros de uma variável aletória associadas a uma distribuição de probabilidade específica (possuindo nome nome) antes de definir exatamente como amostrá-la. Esse é um bom exemplo em que alguma **abstração** com atencedência traz ganhos interessantes.

Nós pode definir como fazer a amostragem aleatória **depois** e até trocar o algoritmo de amostragem se uma nova técnica mais eficiente aparecer no futuro, localizando precisamente o ponto de implementação.
"""

# ╔═╡ e0ef47a6-903c-11eb-18aa-6ff06f0e28ac
md"""
## Definindo tipos abstratos para variáveis aleatórias
"""

# ╔═╡ 02051416-903d-11eb-0ade-3b20897989c5
md"""
Nós definimos um **tipo abstrato** usando  `abstract type <Name> end`, em que `<Name>` representa o nome do tipo.

Podemos pensar que um tipo abstrato representa uma coleção de tipos que compartilham algumas propriedades. No nosso caso, queremos criar tipos que 
representem uma distribuição qualquer e, além disso, subtipos que se 
especializem para representar distribuições _contínuas_ e _discretas_.

Ao fazer isso poderemos especificar depois tipos _concretos_ (ou seja particulares, especializados) de variáveis aleatórias discretas ou contínuas.

Para denotar subtipos usamos `<:`.
"""

# ╔═╡ 51ee3c3c-903d-11eb-1bfa-3bbcda98e977
begin
    abstract type RandomVariable end

    abstract type DiscreteRandomVariable <: RandomVariable end
    abstract type ContinuousRandomVariable <: RandomVariable end
end

# ╔═╡ 681429d8-8fff-11eb-0fa1-bbf9e05e6cea
md"""
## Definindo um tipo concreto para uma variável aleatória gaussiana
"""

# ╔═╡ 21236a86-8fda-11eb-1fcf-59d1de75470c
md"""
Vamos agora voltar a nossa atenção para variáveis aleatórias **gaussianas**, também conhecidas como variáveis **normais**. 
"""

# ╔═╡ dd130aae-8ff2-11eb-2b15-2f5123b40d20
md"""
### Nomes e parâmetros
"""

# ╔═╡ 4771e8e6-8fd2-11eb-178c-419cbdb348f4
begin
    struct Gaussian <: ContinuousRandomVariable
        μ::Any     # mean
        σ²::Any    # variance
    end

    Gaussian() = Gaussian(0.0, 1.0)  # normalised Gaussian with mean 0 and variance 1
end

# ╔═╡ ece14f6c-8fda-11eb-279b-c18dc0fc46d7
G = Gaussian(1, 2)

# ╔═╡ 0be6c548-8fd3-11eb-07a2-5bb382614cab
md"""
Observe que criamos uma variável gaussiana com parâmetros sem necessitar amostrar a partir delas. Na verdade, até esse momento, ainda não ensinamos Julia a fazer essa amostragem. 

Outro detalhe interessante é que criamos um construtor alternativo que não recebe parâmetros e cria uma variável gaussiana com média 0 e variância 1, que o tipo mais usual.
"""

# ╔═╡ 9c03814c-8ff2-11eb-189d-f3b0507507cb
md"""
### Média e variâncias teóricas
"""

# ╔═╡ f24bcb1a-8fda-11eb-1828-0307c65b81cd
md"""
Agora podemos estender as funções `mean`, `var` (variância) e `std` (desvio padrão) da biblioteca `Statistics` com métodos especializados para lidar com esses objetos:
"""

# ╔═╡ 0c76f49e-8fdb-11eb-2c2c-59a4060e8e1d
begin
    Statistics.mean(X::Gaussian) = X.μ
    Statistics.var(X::Gaussian) = X.σ²
end

# ╔═╡ 4596edec-8fdb-11eb-1369-f3e98cb831cd
mean(G)

# ╔═╡ 255d51b6-8ff3-11eb-076c-31ba4c5ce10d
var(G)

# ╔═╡ 43292298-8ff7-11eb-2b9d-017acc9ef185
md"""
### Quando é possível generalizar: o desvio padrão pode ser implementado para _qualquer_ variável aleatória
"""

# ╔═╡ 1bdc6068-8ff7-11eb-069c-6d0f1a83f373
md"""
Se tivermos a variância, conseguimos calcular o desvio padrão, já que ele é apenas sua raiz quadrada. Isso é válido para qualquer variável aleatória. É a própria definição de desvio padrão. Assim, podemos definir o método que calcula esse valor de forma geral e ele vai funcionar mesmo para novas distribuições que forem implementadas no futuro!
"""

# ╔═╡ 11ef1d18-8ff7-11eb-1645-113c1aae6e9b
Statistics.std(X::RandomVariable) = sqrt(var(X))

# ╔═╡ a32079ea-8fd8-11eb-01c4-81b603033b55
Statistics.std(total)

# ╔═╡ 592afd96-8ff7-11eb-1200-47eaf6b6a28a
md"""
Esse é um bom exemplo de desenho de software.
"""

# ╔═╡ 4ef2153a-8fdb-11eb-1a23-8b1c28381e34
std(G)

# ╔═╡ 76f4424e-8fdc-11eb-35ee-dd09752b947b
md"""
### A soma de duas gaussianas
"""

# ╔═╡ dede8022-8fd2-11eb-22f8-a5614d703c01
md"""
Vamos agora implementar a soma de duas variáveis aleatórias gaussianas. Com esse objetivo, vamos usar o resultado matemático que diz que a soma de gaussianas são gaussianas. Nesse caso dizemos que gaussianas são distribuições **estáveis**. [Existem outras distribuições estáveis](https://en.wikipedia.org/wiki/Stable_distribution). Note que essa observação não depende de se fazer amostragem. O código abaixo usa esse fato ao esteder a operação de soma entre duas gaussianas. Ele usa até o resultdo mais específico de qual é a média e a variância resultante.
"""

# ╔═╡ b4f18188-8fd2-11eb-1950-ef3bee3e4724
Base.:+(X::Gaussian, Y::Gaussian) = Gaussian(X.μ + Y.μ, X.σ² + Y.σ²)

# ╔═╡ 292f0e44-8fd3-11eb-07cf-5733a5327630
begin
    G1 = Gaussian(0, 1)
    G2 = Gaussian(5, 6)
end

# ╔═╡ 6b50e9e6-8fd3-11eb-0ab3-6fc3efea7e37
G1 + G2

# ╔═╡ 5300b082-8fdb-11eb-03fe-55f511364ad9
mean(G1 + G2) == mean(G1) + mean(G2)

# ╔═╡ ac3a7c18-8ff3-11eb-1c1f-17939cff40f9
md"""
Já o produto de duas guassianas não é uma gaussiana. Vamos lidar com essa situação depois.
"""

# ╔═╡ b8e59db2-8ff3-11eb-1fa1-595fdc6652bc
md"""
### Distribuições de probabilidade de gaussianas
"""

# ╔═╡ cb167a60-8ff3-11eb-3885-d1d8a70e2a5e
md"""
Lembremos que uma variável aleatória gaussiana é **contínua**, ou seja, seus possíveis valores se distribuem em um contínuo. Os possíveis valores são chamados de **suporte** da distribuição. No caso de uma gaussiana o suporte é toda a reta real, isto é $(-\infty, \infty)$.
"""

# ╔═╡ fc0acee6-8ff3-11eb-13d1-1350364f03a9
md"""
Uma forma de especificar como os valores de uma variável aleatória contínua $X$
se distribuem para diferentes conjuntos na reta é através da função densidade de
probabilidade, $f_X$. A probabilidade de $X$ pertencer a um intervalo $[a, b]$ é dada pela a área da curva abaixo de $f_X$ nesse intervalo.

$$\mathbb{P}(X \in [a, b]) = \int_{a}^b f_X(x) \, dx.$$
"""

# ╔═╡ 2c8b75de-8ff4-11eb-1bc6-cde7b67a2007
md"""
Para uma gaussiana com média  $\mu$ e variância $\sigma^2$, a função densidade é dada por

$$f_X(X) = \frac{1}{\sqrt{2\pi \sigma^2}} \exp \left[ -\frac{1}{2} \left( \frac{x - \mu}{\sigma} \right)^2 \right].$$
"""

# ╔═╡ 639e517c-8ff4-11eb-3ea8-07b73b0bff78
pdf(X::Gaussian) = x -> exp(-0.5 * ((x - X.μ)^2 / X.σ²)) / √(2π * X.σ²)

# ╔═╡ 3d78116c-8ff5-11eb-0ee3-71bf9413f30e
pdf(G)

# ╔═╡ b63c02e4-8ff4-11eb-11f6-d760e8760118
pdf(Gaussian())(0.0)

# ╔═╡ cd9b10f0-8ff5-11eb-1671-99c6738b8074
md"""
μ = $(@bind μμ Slider(-3:0.01:3, show_value=true, default=0.0))
σ = $(@bind σσ Slider(0.01:0.01:3, show_value=true, default=1.0))
"""

# ╔═╡ a899fc08-8ff5-11eb-1d00-e95b55c3be4b
begin
    plot(pdf(Gaussian(μμ, σσ)), leg = false)
    xlims!(-6, 6)
    ylims!(0, 0.5)
end

# ╔═╡ 0b901c34-8ff6-11eb-225b-511718412309
md"""
### Amostrando de uma distribuição gaussiana
"""

# ╔═╡ 11cbf48a-903f-11eb-1e77-81eeb358ec24
md"""
Nós também precisamos definir como amostrar de uma distrbuição gaussiana. Para isso, vamos estender a função `rand` com um novo método.
"""

# ╔═╡ 180a4746-8ff6-11eb-046f-ddf6bb938a35
Base.rand(X::Gaussian) = X.μ + √(X.σ²) * randn()

# ╔═╡ 27595716-8ff6-11eb-1d99-7bf13eedddf7
histogram!([rand(Gaussian(μμ, σσ)) for i = 1:10^4], alpha = 0.5, norm = true)

# ╔═╡ bfb62f1a-8ff5-11eb-0f7a-cf725f3269c5
md"""
# Distribuições mais gerais
"""

# ╔═╡ 0a150880-8ff6-11eb-0046-45fa2d4b476e
md"""
Lembremos agora da distribuição de Bernoulli da última aula. Ela representa uma moeda com pesos que tem probabilidade $p$ de sair cara (1) e probabilidade $1 - p$ de sair coroa (0). 

Essa é uma variável aleatória **discreta**: o conjunto de possível saídas é um conjunto discreto (finito ou enumerável). No caso, o suporte é $\{0, 1\}$.
"""

# ╔═╡ 26569eb4-8fd1-11eb-2df9-098a0792a09e
struct Bernoulli <: DiscreteRandomVariable
    p::Float64
end

# ╔═╡ baf1fe40-8ff6-11eb-1da1-cd43880db334
B = Bernoulli(0.25)

# ╔═╡ 38b10d94-903f-11eb-3e26-890382342dc1
md"""
Mais uma vez especificamos a média e variância teórica.
"""

# ╔═╡ be5f9900-8ff6-11eb-1816-03447cabd9a9
begin
    Statistics.mean(X::Bernoulli) = X.p
    Statistics.var(X::Bernoulli) = X.p * (1 - X.p)
end

# ╔═╡ 52a2cac8-8ff8-11eb-2da4-0b113618c64b
mean(B), var(B), std(B)

# ╔═╡ 6a06b64e-903f-11eb-0d23-53f223ed1ed3
md"""
Lembre-se, `std` "já" está pronta!
"""

# ╔═╡ 6e9ad41a-903f-11eb-06ae-1b34a6674eaf
md"""
E, por fim, especificamos como amostrar:
"""

# ╔═╡ 754b0a80-8ff8-11eb-364b-85fa49d6bb8e
Base.rand(X::Bernoulli) = Int(rand() < X.p)

# ╔═╡ bd484878-8ff8-11eb-0337-7730ab2b07d4
md"""
## Somando duas variáveis aleatórias
"""

# ╔═╡ c3043eb6-8ff8-11eb-2cae-13d1c1613234
md"""
O que ocorre quando somamos duas variáveis Bernoulli? Há dois caminhos que podemos seguir: podemos usar o que se conhece teoricamente sobre esse tipo de soma ou escrever um código geral que deveria funcionar para distribuições quaisquer. Vamos pegar o segundo caminho.
"""

# ╔═╡ 7e3cea0c-903f-11eb-0b41-0f381c1cce4b
md"""
Quando somamos duas Bernoulli, não obtemos uma Bernoulli. Essa distribuição não é estável. Para concluir isso, basta observar que a soma pode valer $2$, algo que não faz sentido para uma Bernoulli. 

Vamos encarar essa soma apenas pelo que ela é: a soma de duas variáveis aleatórias. No caso geral, a distribuição resultante muitas vezes nem tem um nome.

Então, precisamos definir um novo tipo que represente a "soma de duas variáveis aleatórias pré-existentes", que por sua vez é uma variável aleatória.
"""

# ╔═╡ eb555508-8ff8-11eb-1b70-e95290084742
struct SumOfTwoRandomVariables <: RandomVariable
    X1::RandomVariable
    X2::RandomVariable
end

# ╔═╡ 1e5047c4-8ff9-11eb-2628-c7824725678a
begin
    B1 = Bernoulli(0.25)
    B2 = Bernoulli(0.6)
end

# ╔═╡ cb2cd908-903f-11eb-09c0-99acde6d765c
md"""
Vamnos definir a soma de duas variáveis aleatória para *qualquer caso*:
"""

# ╔═╡ 44a5ef96-8ff9-11eb-06a0-d3a8dcf5c1aa
Base.:+(X1::RandomVariable, X2::RandomVariable) = SumOfTwoRandomVariables(X1, X2)

# ╔═╡ d8437e6c-903f-11eb-3ac2-5f7c380c0872
md"""
Vamos por exemplo somar as duas Bernoullis:
"""

# ╔═╡ 574744ec-8ff9-11eb-033c-a3dff07a292b
B1 + B2

# ╔═╡ e024377a-903f-11eb-316a-b5b7936e610f
md"""
Note que o sistema de despacho múltiplo ainda escolhe o caso particular ao somarmos duas gaussianas. O caso geral só é usado quando um caso mais particular não está definido."""

# ╔═╡ f37bb49c-903f-11eb-03fb-35d6ac35822d
G1 + G2

# ╔═╡ 318f5274-8ff9-11eb-1c88-5fde5b546099
md"""
Agora precisamos estender as várias funções para esse novo tipo representando a soma.
"""

# ╔═╡ 90ee7558-8ff9-11eb-3602-271890987ece
Statistics.mean(S::SumOfTwoRandomVariables) = mean(S.X1) + mean(S.X2)

# ╔═╡ bd083794-8fd8-11eb-0155-e59fe27d64f2
Statistics.mean(total)

# ╔═╡ a168ace6-8ff9-11eb-393d-45c34fdf577c
mean(B1 + B2)

# ╔═╡ a51b1538-8ff9-11eb-0635-81088e826bb3
md"""
Para ter uma expressão simples para a variância é preciso assumir que as duas variáveis são **independentes** e é isso que vamos fazer. Isso sugere que o nome do tipo deveria ter sido `SumOfTwoIndependentRandomVariables`, mas ficou longo demais.
"""

# ╔═╡ d88c0830-8ff9-11eb-3e71-c1ac327f4e25
Statistics.var(S::SumOfTwoRandomVariables) = var(S.X1) + var(S.X2)

# ╔═╡ dd995120-8ff9-11eb-1a53-2d65f0b5585a
md"""
Como amostrar da soma? De fato, não é difícil (é a definição da soma):
"""

# ╔═╡ f171c27c-8ff9-11eb-326c-6b2d8c38451d
Base.rand(S::SumOfTwoRandomVariables) = rand(S.X1) + rand(S.X2)

# ╔═╡ ab7c6b18-8ffa-11eb-2b6c-dde3dca1c6f7
md"""
Pronto agora podemos também somar uma Bernoulli com uma gaussiana. Esse é um exemplo de [**mistura de distribuições**](https://en.wikipedia.org/wiki/Mixture_distribution).
"""

# ╔═╡ 79c55fc0-8ffb-11eb-229f-49198aee8245
md"""
Vamos também estender a função `histogram` para ser capaz de desenhar histogramas de nossas variáveis aleatórias:
"""

# ╔═╡ 4493ac9e-8ffb-11eb-15c9-a146091d7696
Plots.histogram(X::RandomVariable; kw...) = histogram(
    [rand(X) for i = 1:10^6],
    norm = true,
    leg = false,
    alpha = 0.5,
    size = (500, 300),
    kw...,
)

# ╔═╡ a591ac12-8ffb-11eb-1734-09657f875b1e
histogram(Bernoulli(0.25) + Bernoulli(0.75))

# ╔═╡ 6c5ef6d4-8ffb-11eb-2fe9-9dd87d92abe4
histogram(Bernoulli(0.25) + Gaussian(0, 0.1))

# ╔═╡ 1d4e236c-8ffb-11eb-209d-851e1af231d4
md"""
Now... What if we sum more random variables?
"""

# ╔═╡ 0c3cfb16-8ffb-11eb-3ef9-33ea9acbb8c0
mixture = Bernoulli(0.25) + Bernoulli(0.75) + Gaussian(0, 0.1)

# ╔═╡ 325560f4-8ffb-11eb-0e9b-53f6869bdd97
rand(mixture)

# ╔═╡ 89138e02-8ffb-11eb-2ad2-c32e663f57b0
histogram(mixture)

# ╔═╡ 71cf1724-9040-11eb-25c3-69ccde4abf0d
md"""
## Programação genérica: `sum`
"""

# ╔═╡ 646ac706-9040-11eb-297c-7b6d8fdf3c16
md"""
Agora que definimos o operador `+`, A definião genérica de Julia para `sum` é capaz de lidar com a soma de muitas variáveis aleatórias.
"""

# ╔═╡ 34bcab72-8ffb-11eb-1d0c-29bd83de638b
S = sum(Bernoulli(0.25) for i = 1:30)

# ╔═╡ 77b54a34-9040-11eb-00d1-57f712ff6732
md"""
Observe que não foi necessário transformar a expressão acima primeiro em uma vetor com uma compreensão de veoters. Isso é possível porque sum aceita também  **iteradores** ou **expressões gertadoras**:
"""

# ╔═╡ bf9a4722-8ffb-11eb-1652-f1bfb4916d2a
histogram(S)

# ╔═╡ 611f770c-8ffc-11eb-2c23-0d5750afd7c8
mean(S)

# ╔═╡ 636b2ce0-8ffc-11eb-2411-571f78fb8a84
var(S)

# ╔═╡ c7613c44-8ffc-11eb-0a43-dbc8b1f62be9
rand(S)

# ╔═╡ 656999be-8ffc-11eb-0f51-51d5a162a004
md"""
Veja que interessante! Tudo funiona naturalmente!

Obs: a soma de $n$ Bernoullis com a mesma probabilidade $p$ é chamada de uma variável aleatória **binomial** com parâmetros $(n, p)$. Já vimos isso antes.
"""

# ╔═╡ 8cb5373a-8ffc-11eb-175d-b11ec5fae1ab
md"""
Se estivermos preocupados com performance, podemos optar por criar um tipo separado `Binomial`, ao invés de usar somas encadeadas de Bernoullis. Você vai fazer isso na lista.
"""

# ╔═╡ 25b4ccca-8ffd-11eb-3fe0-2d14ce90d8b3
md"""
## Distribuição χ₁² 
"""

# ╔═╡ 9913427a-8ffd-11eb-3c28-c12ee05ed9d3
md"""
Outra distribuição bem conhecida é a qui-quadrada. Ela é definida como uma soma de quadrados de gaussianas. A Qui-1 quadrada ($\chi_1^2$) é o quadrado de uma única gaussiana.
"""

# ╔═╡ aa9d94dc-8ffd-11eb-0537-c39344c224c2
struct ChiSquared1 <: ContinuousRandomVariable end

# ╔═╡ b5300720-8ffd-11eb-2ca4-ed7a7c9b5516
Base.rand(X::ChiSquared1) = rand(Gaussian())^2

# ╔═╡ eea0c788-8ffd-11eb-06e0-cfb65dbba7f1
histogram(ChiSquared1())

# ╔═╡ c57fb088-9040-11eb-3881-dfbd82e72b35
md"""
Agora podemos obter uma distribuição $\chi_n^2$ somando várias $\chi_1^2$:
"""

# ╔═╡ 028695a2-8ffe-11eb-3cf4-bd07bfe4df3a
histogram(sum(ChiSquared1() for i = 1:4))

# ╔═╡ 820af6dc-8fdc-11eb-1792-ad9f32eb915e
md"""
## Usando computação simbólica
"""

# ╔═╡ ce330b78-8fda-11eb-144d-756275542eea
md"""
Como não definimos os tipos dos parâmetros de nossas distribuições, podemos mesmo usar computação simbólica (que já estendeu os operadores de soma para variáveis simbólicas e números):
"""

# ╔═╡ 668ade6a-8fda-11eb-0a5e-cb791b245ec0
@variables μ₁, σ₁², μ₂, σ₂²   # introduce symbolic variables from Symbolics.jl

# ╔═╡ 4e94d1da-8fda-11eb-3572-398fb4a12c3c
Gaussian(μ₁, σ₁²) + Gaussian(μ₂, σ₂²)

# ╔═╡ 9ca993a6-8fda-11eb-089c-4d7f89c81b94
Gaussian(17, 3) + Gaussian(μ₂, σ₂²)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
Symbolics = "0c5d862f-8b57-4792-8d23-62f2024744c7"

[compat]
Plots = "~1.22.2"
PlutoUI = "~0.7.11"
Symbolics = "~3.4.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[ArrayInterface]]
deps = ["Compat", "IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "b8d49c34c3da35f220e7295659cd0bab8e739fed"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.1.33"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Bijections]]
git-tree-sha1 = "705e7822597b432ebe152baa844b49f8026df090"
uuid = "e2ed5e7c-b2de-5872-ae92-c73ca462fb04"
version = "0.1.3"

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

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "bd4afa1fdeec0c8b89dad3c6e92bc6e3b0fec9ce"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.6.0"

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

[[Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[CommonSolve]]
git-tree-sha1 = "68a0743f578349ada8bc911a5cbd5a2ef6ed6d1f"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "31d0151f5716b655421d9d75b7fa74cc4e744df2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.39.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[CompositeTypes]]
git-tree-sha1 = "d5b014b216dc891e81fea299638e4c10c657b582"
uuid = "b152e2b5-7a66-4b01-a709-34e65c35f657"
version = "0.1.2"

[[ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f74e9d5388b8620b4cee35d4c5a618dd4dc547f4"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.3.0"

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

[[DiffRules]]
deps = ["NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "7220bc21c33e990c14f4a9a319b1d242ebc5b269"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.3.1"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns"]
git-tree-sha1 = "f4efaa4b5157e0cdb8283ae0b5428bc9208436ed"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.16"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[DomainSets]]
deps = ["CompositeTypes", "IntervalSets", "LinearAlgebra", "StaticArrays", "Statistics"]
git-tree-sha1 = "627844a59d3970db8082b778e53f86741d17aaad"
uuid = "5b8099bc-c8ec-5219-889f-1d9e522a28bf"
version = "0.5.7"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[DynamicPolynomials]]
deps = ["DataStructures", "Future", "LinearAlgebra", "MultivariatePolynomials", "MutableArithmetics", "Pkg", "Reexport", "Test"]
git-tree-sha1 = "05b68e727a192783be0b34bd8fee8f678505c0bf"
uuid = "7c1d4256-1411-5781-91ec-d7bc3513ac07"
version = "0.3.20"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[EllipsisNotation]]
deps = ["ArrayInterface"]
git-tree-sha1 = "8041575f021cba5a099a456b4163c9a08b566a02"
uuid = "da5c29d0-fa7d-589e-88eb-ea29b0a81949"
version = "1.1.0"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[ExprTools]]
git-tree-sha1 = "b7e3d17636b348f005f11040025ae8c6f645fe92"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.6"

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

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "29890dfbc427afa59598b8cfcc10034719bd7744"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.6"

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

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

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
git-tree-sha1 = "60ed5f1643927479f845b0135bb369b031b541fa"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.14"

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

[[IfElse]]
git-tree-sha1 = "28e837ff3e7a6c3cdb252ce49fb412c8eb3caeef"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.0"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[IntervalSets]]
deps = ["Dates", "EllipsisNotation", "Statistics"]
git-tree-sha1 = "3cc368af3f110a767ac786560045dceddfc16758"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.5.3"

[[IrrationalConstants]]
git-tree-sha1 = "f76424439413893a832026ca355fe273e93bce94"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.0"

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

[[LabelledArrays]]
deps = ["ArrayInterface", "LinearAlgebra", "MacroTools", "StaticArrays"]
git-tree-sha1 = "8f5fd068dfee92655b79e0859ecad8b492dfe8b1"
uuid = "2ee39098-c373-598a-b85f-a56591580800"
version = "1.6.5"

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

[[LogExpFunctions]]
deps = ["ChainRulesCore", "DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "34dc30f868e368f8a17b728a1238f3fcda43931a"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.3"

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

[[MultivariatePolynomials]]
deps = ["DataStructures", "LinearAlgebra", "MutableArithmetics"]
git-tree-sha1 = "45c9940cec79dedcdccc73cc6dd09ea8b8ab142c"
uuid = "102ac46a-7ee4-5c85-9060-abc95bfdeaa3"
version = "0.3.18"

[[MutableArithmetics]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "3927848ccebcc165952dc0d9ac9aa274a87bfe01"
uuid = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"
version = "0.2.20"

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

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

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

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "4dd403333bcf0909341cfe57ec115152f937d7d8"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "9d8c00ef7a8d110787ff6f170579846f776133a9"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.4"

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
git-tree-sha1 = "457b13497a3ea4deb33d273a6a5ea15c25c0ebd9"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.22.2"

[[PlutoUI]]
deps = ["Base64", "Dates", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "0c3e067931708fa5641247affc1a1aceb53fff06"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.11"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

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

[[RecursiveArrayTools]]
deps = ["ArrayInterface", "ChainRulesCore", "DocStringExtensions", "LinearAlgebra", "RecipesBase", "Requires", "StaticArrays", "Statistics", "ZygoteRules"]
git-tree-sha1 = "00bede2eb099dcc1ddc3f9ec02180c326b420ee2"
uuid = "731186ca-8d62-57ce-b412-fbd966d074cd"
version = "2.17.2"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[RuntimeGeneratedFunctions]]
deps = ["ExprTools", "SHA", "Serialization"]
git-tree-sha1 = "cdc1e4278e91a6ad530770ebb327f9ed83cf10c4"
uuid = "7e49a35a-f44a-4d26-94aa-eba1b4ca6b47"
version = "0.5.3"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[SciMLBase]]
deps = ["ArrayInterface", "CommonSolve", "ConstructionBase", "Distributed", "DocStringExtensions", "IteratorInterfaceExtensions", "LinearAlgebra", "Logging", "RecipesBase", "RecursiveArrayTools", "StaticArrays", "Statistics", "Tables", "TreeViews"]
git-tree-sha1 = "91e29a2bb257a4b992c48f35084064578b87d364"
uuid = "0bca4576-84f4-4d90-8ffe-ffa030f20462"
version = "1.19.0"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "Requires"]
git-tree-sha1 = "fca29e68c5062722b5b4435594c3d1ba557072a3"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "0.7.1"

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

[[SpecialFunctions]]
deps = ["ChainRulesCore", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "ad42c30a6204c74d264692e633133dcea0e8b14e"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.6.2"

[[Static]]
deps = ["IfElse"]
git-tree-sha1 = "a8f30abc7c64a39d389680b74e749cf33f872a70"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.3.3"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3240808c6d463ac46f1c1cd7638375cd22abbccb"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.12"

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

[[StatsFuns]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "46d7ccc7104860c38b11966dd1f72ff042f382e4"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.10"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[SymbolicUtils]]
deps = ["AbstractTrees", "Bijections", "ChainRulesCore", "Combinatorics", "ConstructionBase", "DataStructures", "DocStringExtensions", "DynamicPolynomials", "IfElse", "LabelledArrays", "LinearAlgebra", "MultivariatePolynomials", "NaNMath", "Setfield", "SparseArrays", "SpecialFunctions", "StaticArrays", "TermInterface", "TimerOutputs"]
git-tree-sha1 = "b747ed621b12281f9bc69e7a6e5337334b1d0c7f"
uuid = "d1185830-fcd6-423d-90d6-eec64667417b"
version = "0.16.0"

[[Symbolics]]
deps = ["ConstructionBase", "DiffRules", "Distributions", "DocStringExtensions", "DomainSets", "IfElse", "Latexify", "Libdl", "LinearAlgebra", "MacroTools", "NaNMath", "RecipesBase", "Reexport", "Requires", "RuntimeGeneratedFunctions", "SciMLBase", "Setfield", "SparseArrays", "SpecialFunctions", "StaticArrays", "SymbolicUtils", "TreeViews"]
git-tree-sha1 = "e17bd63d88ae90df2ef3c0505a687a534f86f263"
uuid = "0c5d862f-8b57-4792-8d23-62f2024744c7"
version = "3.4.1"

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

[[TermInterface]]
git-tree-sha1 = "02a620218eaaa1c1914d228d0e75da122224a502"
uuid = "8ea1fca8-c5ef-4a55-8b96-4e9afe9c9a3c"
version = "0.1.8"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "7cb456f358e8f9d102a8b25e8dfedf58fa5689bc"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.13"

[[TreeViews]]
deps = ["Test"]
git-tree-sha1 = "8d0d7a3fe2f30d6a7f833a5f19f7c7a5b396eae6"
uuid = "a2a6695c-b41b-5b7d-aed9-dbfdeacea5d7"
version = "0.3.0"

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

[[ZygoteRules]]
deps = ["MacroTools"]
git-tree-sha1 = "9e7a1e8ca60b742e508a315c17eef5211e7fbfd7"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.1"

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
# ╟─5d62e16c-8fd9-11eb-1c44-0b0232614011
# ╟─e3a22dc9-4046-4f97-b870-11746cb49ac5
# ╠═103cd2f4-903c-11eb-1116-a51dc540175c
# ╟─6bbfa37e-8ffe-11eb-3031-19ea76a6a8d2
# ╟─8a125ca0-8ff5-11eb-0607-45f993fb5ca7
# ╟─b2971770-8ff7-11eb-002c-f9dc9d6d0d70
# ╟─cdd4497c-903d-11eb-03be-abf6002e75e7
# ╟─ae1b3a26-8fd3-11eb-3746-ad48301ff96e
# ╟─ae0008ee-8fd3-11eb-38bd-f52598a97dce
# ╟─c6c3cf54-8fd4-11eb-3b4f-415f1a2da18e
# ╠═b11d964e-8fd4-11eb-3f6a-43e8d2fa462c
# ╟─d8b74772-8fd4-11eb-3943-f98c29d02171
# ╟─b8c253f8-8fd4-11eb-304a-b1be962687e4
# ╠═ad7b3bee-8fd5-11eb-06f6-b39738d4b1fd
# ╠═c76cd760-8fd5-11eb-3500-5d15515c33f5
# ╠═f31275fa-8fd5-11eb-0b76-7d0513705273
# ╟─276a7c36-8fd8-11eb-25d8-3d4cfaa1f71c
# ╟─11f3853c-903e-11eb-04cd-a125017ad5d8
# ╠═2be60570-8fd8-11eb-0bdf-951280dc6181
# ╠═5e094b52-8fd8-11eb-2ac4-5797599ab013
# ╠═bd083794-8fd8-11eb-0155-e59fe27d64f2
# ╠═a32079ea-8fd8-11eb-01c4-81b603033b55
# ╟─79fb368c-8fd9-11eb-1c9c-bd0ceb122b11
# ╟─a2481afa-8fd3-11eb-1769-bf97f42ea79e
# ╟─a9654334-8fd9-11eb-2ea8-8d308ea66963
# ╟─bb2132e0-8fd9-11eb-3bdd-594726c04859
# ╟─f307e3b8-8ff0-11eb-137e-4f9a03bb4d78
# ╟─e0ef47a6-903c-11eb-18aa-6ff06f0e28ac
# ╟─02051416-903d-11eb-0ade-3b20897989c5
# ╠═51ee3c3c-903d-11eb-1bfa-3bbcda98e977
# ╟─681429d8-8fff-11eb-0fa1-bbf9e05e6cea
# ╟─21236a86-8fda-11eb-1fcf-59d1de75470c
# ╟─dd130aae-8ff2-11eb-2b15-2f5123b40d20
# ╠═4771e8e6-8fd2-11eb-178c-419cbdb348f4
# ╟─ece14f6c-8fda-11eb-279b-c18dc0fc46d7
# ╟─0be6c548-8fd3-11eb-07a2-5bb382614cab
# ╟─9c03814c-8ff2-11eb-189d-f3b0507507cb
# ╟─f24bcb1a-8fda-11eb-1828-0307c65b81cd
# ╠═0c76f49e-8fdb-11eb-2c2c-59a4060e8e1d
# ╠═4596edec-8fdb-11eb-1369-f3e98cb831cd
# ╠═255d51b6-8ff3-11eb-076c-31ba4c5ce10d
# ╟─43292298-8ff7-11eb-2b9d-017acc9ef185
# ╟─1bdc6068-8ff7-11eb-069c-6d0f1a83f373
# ╠═11ef1d18-8ff7-11eb-1645-113c1aae6e9b
# ╟─592afd96-8ff7-11eb-1200-47eaf6b6a28a
# ╠═4ef2153a-8fdb-11eb-1a23-8b1c28381e34
# ╟─76f4424e-8fdc-11eb-35ee-dd09752b947b
# ╟─dede8022-8fd2-11eb-22f8-a5614d703c01
# ╠═b4f18188-8fd2-11eb-1950-ef3bee3e4724
# ╠═292f0e44-8fd3-11eb-07cf-5733a5327630
# ╠═6b50e9e6-8fd3-11eb-0ab3-6fc3efea7e37
# ╠═5300b082-8fdb-11eb-03fe-55f511364ad9
# ╟─ac3a7c18-8ff3-11eb-1c1f-17939cff40f9
# ╟─b8e59db2-8ff3-11eb-1fa1-595fdc6652bc
# ╟─cb167a60-8ff3-11eb-3885-d1d8a70e2a5e
# ╟─fc0acee6-8ff3-11eb-13d1-1350364f03a9
# ╟─2c8b75de-8ff4-11eb-1bc6-cde7b67a2007
# ╠═639e517c-8ff4-11eb-3ea8-07b73b0bff78
# ╠═3d78116c-8ff5-11eb-0ee3-71bf9413f30e
# ╠═b63c02e4-8ff4-11eb-11f6-d760e8760118
# ╠═a899fc08-8ff5-11eb-1d00-e95b55c3be4b
# ╟─cd9b10f0-8ff5-11eb-1671-99c6738b8074
# ╟─0b901c34-8ff6-11eb-225b-511718412309
# ╟─11cbf48a-903f-11eb-1e77-81eeb358ec24
# ╠═180a4746-8ff6-11eb-046f-ddf6bb938a35
# ╠═27595716-8ff6-11eb-1d99-7bf13eedddf7
# ╟─bfb62f1a-8ff5-11eb-0f7a-cf725f3269c5
# ╟─0a150880-8ff6-11eb-0046-45fa2d4b476e
# ╠═26569eb4-8fd1-11eb-2df9-098a0792a09e
# ╠═baf1fe40-8ff6-11eb-1da1-cd43880db334
# ╟─38b10d94-903f-11eb-3e26-890382342dc1
# ╠═be5f9900-8ff6-11eb-1816-03447cabd9a9
# ╟─52a2cac8-8ff8-11eb-2da4-0b113618c64b
# ╟─6a06b64e-903f-11eb-0d23-53f223ed1ed3
# ╟─6e9ad41a-903f-11eb-06ae-1b34a6674eaf
# ╠═754b0a80-8ff8-11eb-364b-85fa49d6bb8e
# ╟─bd484878-8ff8-11eb-0337-7730ab2b07d4
# ╟─c3043eb6-8ff8-11eb-2cae-13d1c1613234
# ╟─7e3cea0c-903f-11eb-0b41-0f381c1cce4b
# ╠═eb555508-8ff8-11eb-1b70-e95290084742
# ╠═1e5047c4-8ff9-11eb-2628-c7824725678a
# ╟─cb2cd908-903f-11eb-09c0-99acde6d765c
# ╠═44a5ef96-8ff9-11eb-06a0-d3a8dcf5c1aa
# ╟─d8437e6c-903f-11eb-3ac2-5f7c380c0872
# ╠═574744ec-8ff9-11eb-033c-a3dff07a292b
# ╟─e024377a-903f-11eb-316a-b5b7936e610f
# ╠═f37bb49c-903f-11eb-03fb-35d6ac35822d
# ╟─318f5274-8ff9-11eb-1c88-5fde5b546099
# ╠═90ee7558-8ff9-11eb-3602-271890987ece
# ╠═a168ace6-8ff9-11eb-393d-45c34fdf577c
# ╟─a51b1538-8ff9-11eb-0635-81088e826bb3
# ╠═d88c0830-8ff9-11eb-3e71-c1ac327f4e25
# ╟─dd995120-8ff9-11eb-1a53-2d65f0b5585a
# ╠═f171c27c-8ff9-11eb-326c-6b2d8c38451d
# ╟─ab7c6b18-8ffa-11eb-2b6c-dde3dca1c6f7
# ╟─79c55fc0-8ffb-11eb-229f-49198aee8245
# ╠═4493ac9e-8ffb-11eb-15c9-a146091d7696
# ╠═a591ac12-8ffb-11eb-1734-09657f875b1e
# ╠═6c5ef6d4-8ffb-11eb-2fe9-9dd87d92abe4
# ╟─1d4e236c-8ffb-11eb-209d-851e1af231d4
# ╠═0c3cfb16-8ffb-11eb-3ef9-33ea9acbb8c0
# ╠═325560f4-8ffb-11eb-0e9b-53f6869bdd97
# ╠═89138e02-8ffb-11eb-2ad2-c32e663f57b0
# ╟─71cf1724-9040-11eb-25c3-69ccde4abf0d
# ╟─646ac706-9040-11eb-297c-7b6d8fdf3c16
# ╠═34bcab72-8ffb-11eb-1d0c-29bd83de638b
# ╟─77b54a34-9040-11eb-00d1-57f712ff6732
# ╠═bf9a4722-8ffb-11eb-1652-f1bfb4916d2a
# ╠═611f770c-8ffc-11eb-2c23-0d5750afd7c8
# ╠═636b2ce0-8ffc-11eb-2411-571f78fb8a84
# ╠═c7613c44-8ffc-11eb-0a43-dbc8b1f62be9
# ╟─656999be-8ffc-11eb-0f51-51d5a162a004
# ╟─8cb5373a-8ffc-11eb-175d-b11ec5fae1ab
# ╟─25b4ccca-8ffd-11eb-3fe0-2d14ce90d8b3
# ╟─9913427a-8ffd-11eb-3c28-c12ee05ed9d3
# ╠═aa9d94dc-8ffd-11eb-0537-c39344c224c2
# ╠═b5300720-8ffd-11eb-2ca4-ed7a7c9b5516
# ╠═eea0c788-8ffd-11eb-06e0-cfb65dbba7f1
# ╟─c57fb088-9040-11eb-3881-dfbd82e72b35
# ╠═028695a2-8ffe-11eb-3cf4-bd07bfe4df3a
# ╟─820af6dc-8fdc-11eb-1792-ad9f32eb915e
# ╟─ce330b78-8fda-11eb-144d-756275542eea
# ╠═668ade6a-8fda-11eb-0a5e-cb791b245ec0
# ╠═4e94d1da-8fda-11eb-3572-398fb4a12c3c
# ╠═9ca993a6-8fda-11eb-089c-4d7f89c81b94
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
