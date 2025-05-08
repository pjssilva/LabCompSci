### A Pluto.jl notebook ###
# v0.20.6

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 9a0cec14-08db-11eb-3cfa-4d1c327c63f1
begin
    using PlutoUI 
	using StatsBase
	using Statistics
	using Distributions
    using Plots
	gr()
end

# ╔═╡ 334d4c94-0c39-469e-8797-9c5a17648948
md"Tradução livre de [`simulating_component_failure_live.jl`](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week6/simulating_component_failure_live.jl)"

# ╔═╡ fb6cdc08-8b44-11eb-09f5-43c167aa53fd
PlutoUI.TableOfContents(aside = true)

# ╔═╡ f3aad4f0-8cc2-11eb-1a25-535297327c65
md"""
# Modelando com simulações estocásticas
"""

# ╔═╡ b6b055b6-8cae-11eb-29e5-b507c1a2b9bf
md"""
## Recursos de Julia
"""

# ╔═╡ bcfaedfa-8cae-11eb-10a1-cb7be7dc2e6b
md"""
- É possível estender uma função de pacotes (além de `Base`).

- Porque criar um tipo novo? Abstração e organização da informação relacionadas a um mesmo objeto.

- Diferentes tipos de gráficos.

- Interpolação de strings.

- Convenções sobre capitalização de nomes de funções, variáveis e tipos.
"""

# ╔═╡ d2c19564-8b44-11eb-1077-ddf6d1395b59
md"""
## Modelos baseados em agentes, ou partículas (microscópicos).
"""

# ╔═╡ ac4f6944-08d9-11eb-0b3c-f5e0a8b8c17e
md"""
Modelos **baseados em agentes** especificam o comportamento, ou ações, de cada indivíduo usando um conjunto de regras. Mesmo nesse caso, é comum buscarmos informações sobre o comportamento global de sistemas compostos de muitos indivíduos e como esse sistema evolui no tempo. Por exemplo, podemos querer responder perguntas como:

* Qual a proporção de indivíduos infectados por uma doença em um certo instante de tempo?
* O mercado de ações está subindo ou descendo?

Neste caderno, nós vamos ver como podemos partir de um modelo probabilístico baseado em indivíduos e, por vezes, chegar a um modelo **determinístico** de equações que explicam o comportamento **macroscópico** (geral/médio) do sistema. 

Essas equações macroscópicas podem se apresentar em tempo discreto (**relações de recorrência** ou **equações de diferenças**) ou permitirem a obtenção de um **limite contínuo** que leva a um sistema de **equações diferenciais ordinárias**.
"""

# ╔═╡ 4ca399f4-8b45-11eb-2d2b-8189e04fc804
md"""
## Modelando tempo para o sucesso (ou o tempo de falha)
"""

# ╔═╡ 57080632-8b45-11eb-1003-05afb2331b25
md"""
Vamos começar com um modelo simples de **tempo para o sucesso**. Considere que estamos jogando um jogo no qual temos probabilidade de vitória igual a $p$ a cada rodada. Quantas rodadas precisamos para ganhar? Por exemplo, quantas vezes temos que lançar um dado até obter um 6? Ou dois dados para obter um duplo 6?
"""

# ╔═╡ 139ecfec-8b46-11eb-2649-2f77833d749a
md"""
Essa ideia pode ser usada para modelar diferentes situações. Por exemplo: o tempo para uma lâmpada queimar, o tempo para uma máquina precisar de manutenção, o tempo de decaimento de um núcleo radioativo, o tempo para se recuperar de uma infecção, etc.
"""

# ╔═╡ f9a75ac4-08d9-11eb-3167-011eb698a32c
md"""
A questão básica é:

> Considere que temos $N$ lâmpadas que estão funcionando bem no dia $0$. 
> 
> - Se cada lâmpada tem probabilidade $p$ de queimar a cada dia, quantas lâmpadas ainda estarão acessas no dia $t$?
> - Quanto, em média, um lâmpada dura?
> - Será que lâmpadas queimam exatamente ao passar a meia-noite de um dado dia? É possível pensar em modelos mais realísticos?

Vamos de novo usar o ponto de vista do pensamento computacional: vamos usar código para fazer simulações e visualizações e ganhar intuição sobre o problema.
"""

# ╔═╡ 17812c7c-8cac-11eb-1d0a-6512415f6938
md"""
## Visualizando falhas de componentes
"""

# ╔═╡ 179a4db2-8cac-11eb-374f-0f24dc81ebeb
md"""
m = $(@bind m Slider(2:20, show_value=true, default=8))
"""

# ╔═╡ 17cf895a-8cac-11eb-017e-c79ffcab60b1
md"""
p= $(@bind prob Slider(0.01:.01:1, show_value=true, default=.1))

t = $(@bind tt Slider(1:100, show_value=true, default=1))
"""

# ╔═╡ 18da7920-8cac-11eb-07f4-e109298fd5f1
begin
    rectangle(w, h, x, y) = (x .+ [0, w, w, 0], y .+ [0, 0, h, h])

    function circle(r, x, y)
		θ = range(0, 2π, length = 30)
    	return (x .+ r .* cos.(θ), y .+ r .* sin.(θ))
	end
end

# ╔═╡ a9447530-8cb6-11eb-38f7-ff69a640e3c4
md"""
## Interpolações em strings
"""

# ╔═╡ c1fde6ba-8cb6-11eb-2170-af6bc84c01a7
md"""
Vamos abrir um rápido parêntesis. Como apresentar uma imagem, digamos do Daniel Bernoulli, no Pluto? Uma opção é usar diretamente HTML, que a linguagem usada na construção de páginas web. Naturalmente, podemos armazenar código HTML em uma string. Julia, por sua vez, já possui um tipo que recebe uma string representado código HTML e a devolve em um formato que Pluto pode mostrar imediatamente.

Para exemplificar isso, vamos gerar código HTML que apresenta uma imagem do Bernoulli, junto à informação da largura desejada. O browser vai então se encarregar de mostrar a imagem no tamanho pedido. Para passar essas informações para a string vamos usar _interpolação_, a capacidade que Julia tem de substituir a sintaxe `$(variable)` dentro de uma string pelo o valor atual da variável.

Em seguida, convertemos a string para HTML, usando o construtor`HTML(...)` e Pluto repassa o objeto HTML ao browser diretamente.
"""

# ╔═╡ 18755e3e-8cac-11eb-37bf-1dfa5fbe730a
@bind bernoulliwidth Slider(10:10:500, show_value = true)

# ╔═╡ f947a976-8cb6-11eb-2ae7-59eba4c6f40f
url = "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/ETH-BIB-Bernoulli%2C_Daniel_%281700-1782%29-Portrait-Portr_10971.tif_%28cropped%29.jpg/440px-ETH-BIB-Bernoulli%2C_Daniel_%281700-1782%29-Portrait-Portr_10971.tif_%28cropped%29.jpg"

# ╔═╡ 5a0b407e-8cb7-11eb-0c0d-c7767a6b0a1d
s = "<img src=$url width=$bernoulliwidth>"

# ╔═╡ fe53ee0c-8cb6-11eb-19bc-2976da1abe16
md"""
Observe que podemos usar um conjunto de _três_ aspas seguidas (`"`) para representar uma string com múltiplas linhas, ou para escrever strings que possuem aspas em seu conteúdo.
"""

# ╔═╡ 1894b388-8cac-11eb-2287-97f985df1fbd
HTML(s)

# ╔═╡ f90981e7-4118-4cf4-8cdb-a0bd28c2c6e6
md"Outra opção é usar strings `html` que já repassam a string para o construtor `HTML`. Elas funcionam como as strings `md` para representar _Markdown_."

# ╔═╡ 86299112-8cc6-11eb-257a-9d803feac359
html"3 <br> 4"

# ╔═╡ 9eb69e94-8cc6-11eb-323b-5587cc743571
HTML("3 <br> 4")

# ╔═╡ b8d01ae4-8cc6-11eb-1d16-47095532f738
@bind num_breaks Slider(1:10, show_value = true)

# ╔═╡ fc715452-8cc6-11eb-0246-e941f7698cfe
HTML("3 $("<br>"^num_breaks) 4")

# ╔═╡ 71fbc75e-8bf3-11eb-3ac9-dd5401033c78
md"""
## Um pouco de matemática: variáveis aleatórias Bernoulli
"""

# ╔═╡ 7c01f6a6-8bf3-11eb-3c4d-ad7e206a9277
md"""
Uma **variável aleatória que segue a distribuição de Bernoulli**, ou simplesmente **variável aleatória Bernoulli** modela uma moeda viciada: ela pode valer $1$, com probabilidade $p$, ou $0$, com probabilidade $q = 1 - p$.
"""

# ╔═╡ dcd279b0-8bf3-11eb-0cb9-95f351626ed1
md"""
Da forma que foi definida, a variável está retornando um valor  `Bool` (verdadeiro ou falso). Para converter esse valor para 0 ou 1 basta repassá-lo para `Int`.
"""

# ╔═╡ fbada990-8bf3-11eb-2bb7-d786362669e8
md"""
Vamos gerar (amostra) algumas variáveis Bernoulli:
"""

# ╔═╡ ac98f5da-8bf3-11eb-076f-597ce4455e76
md"""
Como já vimos, é natural se perguntar qual é sua **média** ou **esperança** ou **valor esperado**.
"""

# ╔═╡ 0e7a04a4-8bf4-11eb-2e9d-fb48c23b8d8c
sample_mean(data) = sum(data) / length(data)

# ╔═╡ 111eccd2-8bf4-11eb-097c-7582f811d146
md"""
Nesse caso calcular a média, simplesmente devolve a proporção de 1's (já que o outro valor é 0). Essa deve aproximar justamente $p$.

Obs: Acima escrevemos a nossa própria versão de `sample_mean`. Mas o pacote `Statistics` já define  a função `mean` capaz de fazer o mesmo. Assim como `std` e `var` para desvio padrão e variância respectivamente. 

#### Exercício:
Calcule a variância de uma variável aleatória Bernoulli.

Dica: Não se esqueça de centralizar os dados antes de somar os quadrados.
"""

# ╔═╡ 4edaec4a-8bf4-11eb-3094-010ebe9b56ab
md"""
## Julia: crie um tipo!
"""

# ╔═╡ 9d66e31e-8cad-11eb-3ad0-3980ba66cb0e
md"""
É importante sempre lembrar que muitas vezes nós já vimos código que lida com situações específicas. Por exemplo, já sabemos que podemos usar a função `rand` para amostrar uma variável aleatória e se passarmos para ela uma distribuição de probabilidades ela vai amostrar seguindo a distribuição.

Isso permite alterar rapidamente código baseado em `rand` para usar uma nova distribuição. Mas para isso é preciso estender a função original para explicar como lidar com uma nova distribuição. 


Vamos fazer isso abaixo e estender algumas funções importantes.
"""

# ╔═╡ 79112bc0-c3a8-4fea-8457-90aca33a8022
md"""
Isso sugere que mesmo que toda informação de nossa distribuição Bernoulli possa ser guardada em uma simples variável Float64, é melhor criar um tipo específico para ela. Assim fica fácil estender funções com novos métodos que serão adaptados para esse novo tipo. 

Se nós guardamos a informação de nossa distribuição Bernoulli em um `Float64`, não há muito como fazer essa extensão. É impossível diferenciá-lo pelo tipo. Além disso, guardar esse informação em um `Float64` comum não deixa claro que esse número na verdade representa outro conceito: uma distribuição Bernoulli. Esse é mais um motivo para criar um tipo específico.
"""

# ╔═╡ 8405e310-8bf8-11eb-282b-d93b4fc683aa
struct Bernoulli   # weighted coin flip
    p::Float64
end

# ╔═╡ af2594c4-8cad-11eb-0fff-f59e65102b3f
md"""
Como disse, queremos amostrar a distribuição usando `rand`. Podemos também querer calcular a sua média e desvio padrão. Para isso vamos estender as respectivas funções com novos métodos especializados. Vocês farão mais disso na lista.
"""

# ╔═╡ 8aa60da0-8bf8-11eb-0fa2-11aeecb89564
Base.rand(X::Bernoulli) = Int(rand() < X.p)

# ╔═╡ 8d56b6d2-8cc8-11eb-0dbd-b3533dde4aa3
md"""
Obs: Lembre-se, em Julia a convenção é que os nomes de função e nomes de variáveis começam com letras minúsculas. Já os nomes de tipos com maiúsculas. Uma possível exceção são variáveis com nome de uma única letra que representam conceitos que em Matemática são tipicamente representados como maiúsculas, como o nome de matrizes.
"""

# ╔═╡ a034c2a6-8bf8-11eb-0f06-0b35a0e8e68d
B = Bernoulli(0.25)

# ╔═╡ c166edb6-8cc8-11eb-0436-f74164ff6ea7
methods(Bernoulli)

# ╔═╡ d25dc130-8cc8-11eb-177f-63a1792494c0
Bernoulli(1 // 4)

# ╔═╡ 3ef23da4-8cb4-11eb-0d5f-d5ee8fc56227
md"""
O objeto `B` representa uma distribuição Bernoulli com probabilidade $p$. Ele pode ser usado sempre que precisarmos de uma distribuição desse tipo. Você agora pode tentar criar o seu próprio mini pacote com sua distribuição simples. Assim não vai precisar fazer copia-e-cola quando precisar reutilizá-la. 

Por outro lado, já existem pacotes com muitas possíveis distribuições incluindo essa. Dê uma olhada em `Distributions.jl` ou no novo `MeasureTheory.jl`.
"""

# ╔═╡ 2d9c560e-8bf9-11eb-1ac5-f77f7caf776f
Statistics.mean(X::Bernoulli) = X.p

# ╔═╡ ce94541c-8bf9-11eb-1ac9-51e66a017813
mean(B)

# ╔═╡ a057e7ee-8bf9-11eb-2ceb-2dda3718a70a
md"""
## Executando uma simulação estocástica
"""

# ╔═╡ 4a743662-8cb6-11eb-26a6-d911e60653e4
md"""
Vamos definir uma simulação e rodá-la algumas vezes.
"""

# ╔═╡ fe0aa72c-8b46-11eb-15aa-49ae570e5858
md"""
N = $(@bind N Slider(1:1000, show_value=true, default=70))

p = $(@bind p Slider(0:0.01:1, show_value=true, default=0.05))

T = $(@bind T Slider(1:100, show_value=true, default=100))
"""

# ╔═╡ caa3faa2-08e5-11eb-33fe-cbbc00cfd459
md"""
## Evolução temporal da média: uma derivação intuitiva
"""

# ╔═╡ 2174aeba-08e6-11eb-09a9-2d6a882a2604
md"""
A média parece se comportar de forma muito previsível. Será que conseguimos entender o que está ocorrendo?

Seja $N_t$ o número de lâmpadas acessas no tempo $t$. Esse número diminui porque algumas lâmpadas queimam. Como as lâmpadas queimam com probabilidade $p$, o número de lâmpadas que queima no período $t$ é em média $p N_t$. Observe que a unidade de tempo corresponde a uma passo na simulação.

Isso é capturado pelas equações (verde denota lâmpadas acessas e vermelho lampadas que queimam):

$$\Delta N_t = -{\color{red} p \, N_t} = {\color{lightgreen} N_{t+1}} - {\color{lightgreen}N_t}.$$

Assim, 

$${\color{lightgreen} N_{t+1}} = {\color{lightgreen}N_t} - {\color{red} p \, N_t}$$

ou

$$N_{t+1} = (1 - p) N_t .$$
"""

# ╔═╡ f5756dd6-0847-11eb-0870-fd06ad10b6c7
md"""
Agora, podemos dar uma passo a mais para trás no tempo e ver que:

$$N_{t+1} = (1 - p) (1 - p) N_{t-1} = (1 - p)^2 N_{t-1}.$$

Taí uma recorrência fácil de resolver. Ela diz que

$$N_t = (1-p)^t \, N_0.$$
"""

# ╔═╡ 113c31b2-08ed-11eb-35ef-6b4726128eff
md"""
Vamos comparar o resultado exato com a simulação numérica.
"""

# ╔═╡ 6a545268-0846-11eb-3861-c3d5f52c061b
exact = [N * (1 - p)^t for t = 0:T]

# ╔═╡ 3cd1ad48-08ed-11eb-294c-f96b0e7c33bb
md"""
Elas se ajustam muito bem, como esperado. Esse ajuste tende a ser melhor (ou seja com oscilações menores) para populações maiores.
"""

# ╔═╡ f32b936a-8bf6-11eb-1dd7-fd8c5904bf1f
md"""
## A distribuição binomial
"""

# ╔═╡ f8f38028-8bf6-11eb-321b-8f91e38da495
md"""
No instante $0$ existem $N_0$ lâmpadas funcionando. Quantas ficam ``{\color{red} \text{vermelhas}}`` (queimam) no primeiro passo? Vamos chamar isso de $\Delta N_0$.

Intuitivamente, a média é $\mathbb{E} (\Delta N_0) = p N_0$. Mas isso não captura tudo. De fato, $\Delta N_0$ é uma variável aleatória. Em princípio, pode ocorrer que nenhuma lâmpada queime, ou mesmo que todos queimem ao mesmo tempo. Mas esses dois eventos têm probabilidade baixa.

Para cada uma das $N_0$ Lâmpadas, $i=1, \ldots, N_0$, temos uma variável aleatória Bernoulli que nos diz se a lâmpada $i$ vai queimar. Vamos denotar esse variável  $B_0^i$.

Isso nos permite deduzir uma expressão para a $\Delta N_0$:

$$\Delta N_0 = \sum_{i=1}^{N_0} B_0^i$$
"""

# ╔═╡ 2de1ef6c-8cb1-11eb-3dd9-f3904ec1408b
md"""
Vamos criar um tipo para representar a soma de $N$ Bernoullis de probabilidade $p$. Esse tipo de variável aleatória é chamada de uma **variável aleatória binomial**. A única informação realmente necessária é apenas $N$ e $p$.
"""

# ╔═╡ 48fb6ed6-8cb1-11eb-0894-b526e6c43b01
struct Binomial
    N::Int64
    p::Float64
end

# ╔═╡ 713a2644-8cb1-11eb-1904-f301e39d141e
md"""
Note que em Julia não somos obrigados a implementar todos os possíveis métodos imediatamente ao criar o tipo, como ocorre em outras linguagens. Podemos criar os métodos depois, e outras pessoas podem também adicionar novos métodos se tiverem acesso ao seu pacote ou, mesmo, modificar o comportamento original.
"""

# ╔═╡ 511892e0-8cb1-11eb-3814-b98e8e0bbe5c
function Base.rand(X::Binomial)
	B = Bernoulli(X.p)
	events = [rand(B) for i = 1:X.N]
	return sum(events)
end

# ╔═╡ 178631ec-8cac-11eb-1117-5d872ba7f66e
function simulate(m, p, tmax = 100)
	# We use tmax + 1 to indicate that the failure did not occur in
	# the simulation time frame.
    S = fill(tmax + 1, m, m) # We have n = m^2 light bulbs.

	t = 0
    while t < tmax && any(S .== tmax + 1)
        t += 1

        for i = 1:m, j = 1:m
            if rand() < p && S[i, j] == tmax + 1
                S[i, j] = t
            end
        end

    end

    return S
end

# ╔═╡ 17bbf532-8cac-11eb-1e3f-c54072021208
simulation = simulate(m, prob)

# ╔═╡ 17e0d142-8cac-11eb-2d6a-fdf175f5d419
begin
    w = 0.9
    h = 0.9
    c = [RGB(0, 1, 0), RGB(1, 0, 0), :purple][1 .+ (simulation .< tt) .+ (simulation .< (tt .- 1))]

	plot(size = (500, 500), ratio = 1, legend = false, axis = false, ticks = false, grid = false)

    for i = 1:m, j = 1:m
        plot!(rectangle(w, h, i, m - j), c = :black, fill = true, alpha = 0.5)
        plot!(circle(0.3, i + 0.45, m + 1 - (j + 0.55)), c = c[j, i], fill = true, alpha = 0.5)
    end

    for i = 1:m, j = 1:m
        if simulation[j, i] < tt
            annotate!(i + 0.5, m + 1 - (j + 0.55), text("$(simulation[j, i])", 7, :white))
        end
    end


    plot!(
        xlims = (0, m + 1.1), ylims = (0, m + 1.1),
        title = "time = $(tt-1);  failed count: $(sum(simulation.<tt))",
    )
end

# ╔═╡ 17fe87a0-8cac-11eb-2938-2d9cd19ecc0f
begin
    plot(size = (500, 300))
    cdf = [count(simulation .≤ i) for i = 0:100]
    bar!(cdf, c = :purple, legend = false, ylim=(0, m^2), xlim = (0, tt), alpha = 0.8)
	title!("Total failed in time")
end

# ╔═╡ 1829091c-8cac-11eb-1b77-c5ed7dd1261b
begin
    newcdf = [count(simulation .> i) for i = 0:100]
    bar!(newcdf, c = RGB(0, 1, 0), legend = false, xlim = (0, tt), alpha = 0.8)
	title!("Glowing vs failed in time")
end

# ╔═╡ 1851dd6a-8cac-11eb-18e4-87dbe1714be0
bar(
    countmap(simulation[:]),  # This create a copy.
	                          # You can also use vec(simulation) and get a view.
    c = :red,
    legend = false,
    xlim = (0, tt + 0.5),
    size = (500, 300),
	title = "Number of failures at each period"
)

# ╔═╡ ba7ffe78-0845-11eb-2847-851a407dd2ec
bernoulli(p) = rand() < p

# ╔═╡ 45bb6df0-8cc7-11eb-100f-37c2a76df464
bernoulli(0.25)

# ╔═╡ b6786ec8-8bf3-11eb-1347-61f231fd3b4c
flips = [Int(bernoulli(0.25)) for i = 1:100_000]

# ╔═╡ 093275e4-8cc8-11eb-136f-3ffe522c4125
sample_mean(flips)

# ╔═╡ 174ccb7f-b134-4c1f-9b59-e4c8460bc40e
rand(Normal())

# ╔═╡ e2f45234-8cc8-11eb-2be9-598eb590592a
rand(B)

# ╔═╡ bc5d6fae-8cad-11eb-3351-a734d2366557
rand(B)

# ╔═╡ e2d764d0-0845-11eb-0031-e74d2f5acaf9
function step!(bulbs, B)
    for i = 1:length(bulbs)
        if bulbs[i] && rand(B) == 1
            bulbs[i] = false
        end
    end
end

# ╔═╡ 33f9fc36-0846-11eb-18c2-77f92fca3176
function simulate_lifespan(N, T, p)
    B = Bernoulli(p)
    bulbs = trues(N)
    n_glowing = [N]

    for t = 1:T
        step!(bulbs, B)
        push!(n_glowing, count(bulbs))
    end

    return n_glowing
end

# ╔═╡ cb278624-08dd-11eb-3375-276bfe8d7b3a
begin
    plot(simulate_lifespan(N, T, p), label = "run 1", alpha = 0.5, lw = 2, m = :o)
    plot!(simulate_lifespan(N, T, p), label = "run 2", alpha = 0.5, lw = 2, m = :o)

    xlabel!("time (days)")
    ylabel!("glowing")
end

# ╔═╡ f3c85814-0846-11eb-1266-63f31f351a51
all_data = [simulate_lifespan(N, T, p) for runs = 1:5];

# ╔═╡ 01dbe272-0847-11eb-1331-4360a575ff14
begin
    plot(all_data, alpha = 0.1, label="", m = :o, ms = 1, size = (500, 400))
    xlabel!("time (days)")
    ylabel!("glowing")
end

# ╔═╡ be8e4ac2-08dd-11eb-2f72-a9da5a750d32
plot!(
    mean(all_data),
    label = "mean",
    lw = 3,
    c = :red,
    m = :o,
    alpha = 0.5, 
    size = (500, 400),
)

# ╔═╡ 8bc52d58-0848-11eb-3487-ef0d06061042
begin
    plot(
        replace.(all_data, 0.0 => NaN),  # This avoids computing log of 0.
        yscale = :log10,
        alpha = 0.3,
        label = "",
        m = :o,
        ms = 1,
        size = (500, 400),
    )

    plot!(
        mean(all_data),
        yscale = :log10,
        lw = 3,
        c = :red,
        m = :o,
        label = "mean",
        alpha = 0.5,
    )

    xlabel!("time (days)")
    ylabel!("glowing")
end



# ╔═╡ 4c8827b8-0847-11eb-0fd1-cfbdbdcf392e
begin
    plot(
        mean(all_data),
        m = :o,
        alpha = 0.5,
        label = "mean of stochastic simulations",
        size = (500, 400),
    )
    plot!(exact, lw = 3, alpha = 0.8, label = "deterministic model", leg = :right)
    title!("Experiment vs. theory")
    xlabel!("time")
    ylabel!("""number of "greens" """)
end


# ╔═╡ 1173ebbe-8cb1-11eb-0a21-7d40a2c8a855
rand(Binomial(10, 0.25))

# ╔═╡ dfdaf1dc-8cb1-11eb-0287-f150380d323b
md"""
N = $(@bind binomial_N Slider(1:100, show_value=true, default=1)); 
p = $(@bind binomial_p Slider(0.0:0.01:1, show_value=true, default=0))

"""

# ╔═╡ ca3db0a8-8cb1-11eb-2f7b-c9343a29ed02
begin
    nexperiments = 10000
    binomial_data = [rand(Binomial(binomial_N, binomial_p)) for i = 1:nexperiments]

    bar(
        countmap(binomial_data),
        alpha = 0.5,
        size = (500, 300),
        leg = false,
        bin_width = 0.5,
    )
    xlabel!("number of failed bulbs")
    ylabel!("How often in $nexperiments tests")
end

# ╔═╡ b3ce9e3a-8c35-11eb-1ad0-81f9b09f963e
md"""
Se chamarmos de $q := 1 - p$, então cada para lâmpada os dois possíveis resultados são "falha", com probabilidade $p$, e "não-falha", com probabilidade `q`. Isso é exatamente equivalente a jogar $n$ moedas viciadas de maneira independente.

O número de maneiras de escolher os resultados de tal maneira que exatamente $k$ lâmpadas falhem é dado pelo coeficiente de $p^k$ na expansão de $(p + q)^n$, ou seja, é dado pelo **coeficiente binomial**

$$\begin{pmatrix} n \\ k \end{pmatrix} := \frac{n!}{k! \, (n-k)!},$$

em que $n! := 1 \times 2 \times \cdots n$ é o fatorial de $n$.

"""

# ╔═╡ 2f980870-0848-11eb-3edb-0d4cd1ed5b3d
md"""
## Tempo contínuo

Se olharmos o gráfico da média em função do tempo, ele parece seguir uma curva suave. De fato, isso sugere que faz sentido não apenas perguntar o número de lâmpadas que falham ao final de cada *dia*, mas pensar se conseguirmos estimar isso para *qualquer instante do tempo*.

Para ver como fazer isso, vamos tentar ajustar as ideias acima para passos no tempo de $\delta t$ quaisquer no lugar de $\delta t = 1$ que usamos acima.

Nós precisamos ajustar a probabilidade de falha para cada possível passo. Se imaginarmos que a chance de falhar em qualquer instante é constante, é natural considerar que a probabilidade de falha para um certo $\delta t$ é proporcional à sua duração:

$$p(\delta t) \simeq \lambda \, \delta t,$$

em que $\lambda$ é a *taxa* de falha. O termo *taxa* é para enfatizar que ela fornece a probabilidade de falha *por unidade de tempo*.

Obtemos,
"""

# ╔═╡ 6af30142-08b4-11eb-3759-4d2505faf5a0
md"""
$$N(t + \delta t) - N(t) \simeq -\lambda \,\delta t \, N(t),$$
"""

# ╔═╡ c6f9feb6-08f3-11eb-0930-83385ca5f032
md"""
note que estamos agora usando o $t$ como um argumento de uma função que está definida em todo o tempo e não mais como um índice de um vetor discreto.

Dividindo por $\delta t$ isso dá

$$\frac{N(t + \delta t) - N(t)}{\delta t} \simeq -\lambda \, N(t).$$

O limite à esquerda com $\delta t \rightarrow 0$ não mais o que o quociente usado na definição *derivada* do número de lâmpadas funcionando em função do tempo. Tomando o limite obtemos
"""

# ╔═╡ d8d8e7d8-08b4-11eb-086e-6fdb88511c6a
md"""
$$\frac{dN(t)}{dt} = -\lambda \, N(t)$$

Ou seja, obtemos uma **equação diferencial ordinária** que fornece a solução de nosso problema de forma implícita. Resolvendo a equação, junto com a condição inicial $N(0) = N_0$ dá a solução:
"""

# ╔═╡ 780c483a-08f4-11eb-1205-0b8aaa4b1c2d
md"""
$$N(t) = N_0 \exp(-\lambda \, t).$$
"""

# ╔═╡ a13dd444-08f4-11eb-08f5-df9dd99c8ab5
md"""
Uma dedução alternativa pode ser obtida reconhecendo a fórmula da exponencial no limite ao se considerar cada vez mais passos discretos, com  $\delta t \to 0$, na expressão obtida a partir da fórmula recursiva. Note que isso também é a expressão usual de juros compostos.
"""

# ╔═╡ cb99fe22-0848-11eb-1f61-5953be879f92
md"""
$$N_{t} = (1 - \lambda \, \delta t)^{(t / \delta t)} N_0$$
"""

# ╔═╡ 8d2858a4-8c38-11eb-0b3b-61a913eed928
md"""
## Do discreto ao contínuo
"""

# ╔═╡ 93da8b36-8c38-11eb-122a-85314d6e1921
function plot_cumulative!(p, nsteps, δ = 1; kw...)
    # Probability of failure at step t
    ps = [p * (1 - p)^(t - 1) for t = 1:nsteps]

    # Cumulative: probability of faling up to step t
    cumulative = cumsum(ps)

    # Plot the cumulative probability curve
    scatter!([n * δ for n = 1:nsteps], cumulative; kw...)
end

# ╔═╡ 9572eda8-8c38-11eb-258c-739b511de833
begin
    plot(size = (500, 300), leg = false)
    base_p, final_T, unit_step = 0.1, 30, 1
    plot_cumulative!(base_p, final_T, unit_step, ms = 5, c = :red, alpha = 0.5)
    # Test with different factors = 2, 4, 8
    factor = 2
    plot_cumulative!(
        base_p / factor,
        final_T * factor,
        unit_step / factor;
        label = "",
        ms = 3,
        c = :lightgreen,
        alpha = 0.5,
    )
end

# ╔═╡ 7850b114-8c3b-11eb-276a-df5c332bf6d3
fails_at_step_1 = 1.0 - (1.0 - base_p / factor)^factor    # almost 10%

# ╔═╡ 9f41d4f2-8c38-11eb-3eae-a1ec0d86d64c
begin
    # If base_p is the exact failure rate at time 1, λ should be:
    λ = -log(1.0 - base_p)

    plot(0:0.01:30, t -> 1 - exp(-λ * t), lw = 1, legend = :topleft)
    plot!(0:0.01:30, t -> 1 - exp(-base_p * t), lw = 1)


end

# ╔═╡ 36a0fd79-fe02-463f-b615-c519e55c4710
λ

# ╔═╡ 148f486c-8c3d-11eb-069f-cd595c5f7177
md"""
Note que o último modelo, em tempo contínuo é mais interessante. Ele permite que as lâmpadas queimem em qualquer instante do tempo e não somente em instantes pré-definidos. Afinal de contas, é exatamente isso o que ocorre no mundo real. Lâmpadas não esperam o cronômetro zerar. 

Por outro lado, o que medimos é tipicamente discreto, medimos quantas lâmpadas queimaram no último dia, hora, etc. O processo contínuo é então o limite do que veríamos se pudéssemos medir cada vez mais rápido com cada vez mais lâmpadas. 

Essa última afirmação se faz necessária porque o processo contínuo aceita "meia" lâmpada queimada.
"""

# ╔═╡ 4d61636e-8c3d-11eb-2726-6dc51e8a4f84
md"Essas mesmas ideias são usadas para modelar o processo de pessoas se recuperando de doenças, em modelo de epidemiologia matemática como SIR que foram tão usados na pandemia de Covid-19. Além disso, fórmulas de recorrência um pouco mais sofisticadas, onde a probabilidade de mudar de estado na verdade depende da proporção de pessoas em outro estado, levam diretamente ao modelo SIR completo. Mas isso é para uma outra versão dessa aula."

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
Distributions = "~0.25.108"
Plots = "~1.40.4"
PlutoUI = "~0.7.59"
StatsBase = "~0.34.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.9"
manifest_format = "2.0"
project_hash = "a1579b1dd7db23b62098bd138f7e6d06a21fb80c"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1b96ea4a01afe0ea4090c5c8039690672dd13f2e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.9+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "2ac646d71d0d24b44f3f8c84da8c9f4d70fb67df"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.4+0"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "962834c22b66e32aa10f7611c08c8ca4e20749a9"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.8"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "403f2d8e209681fcbd9468a8514efff3ea08452e"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.29.0"

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
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "64e15186f0aa277e174aa81798f7eb8598e0157e"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.0"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "d9d26935a0bcffc87d2613ce14c527c99fc543fd"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.5.0"

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
git-tree-sha1 = "4e1fe97fdaed23e9dc21d4d664bea76b65fc50a0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.22"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "473e9afc9cf30814eb67ffa5f2db7df82c3ad9fd"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.16.2+0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Distributions]]
deps = ["AliasTables", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "0b4190661e8a4e51a842070e7dd4fae440ddb7f4"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.118"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.DocStringExtensions]]
git-tree-sha1 = "e7b7e6f178525d17c720ab9c081e4ef04429f860"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.4"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a4be429317c42cfae6a7fc03c31bad1970c310d"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+1"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "d36f682e590a83d63d1c7dbd287573764682d12a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.11"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d55dffd9ae73ff72f1c0482454dcf2ec6c6c4a63"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.6.5+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "53ebe7511fa11d33bec688a9178fac4e49eeee00"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.2"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "466d45dc38e15794ec7d5d63ec03d776a9aff36e"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.4+1"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "6a70198746448456524cb442b8af316927ff3e1a"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.13.0"
weakdeps = ["PDMats", "SparseArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "301b5d5d731a0654825f1f2e906990f7141a106b"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.16.0+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "2c5512e11c791d1baed2049c5652441b28fc6a31"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7a214fdac5ed5f59a22c2d9a885a16da1c74bbc7"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.17+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "fcb0584ff34e25155876418979d4c8971243bb89"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.4.0+2"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Preferences", "Printf", "Qt6Wayland_jll", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "p7zip_jll"]
git-tree-sha1 = "0ff136326605f8e06e9bcf085a356ab312eef18a"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.13"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "9cb62849057df859575fc1dda1e91b82f8609709"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.13+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "b0036b392358c80d2d2124746c2bf3d48d457938"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.82.4+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a6dbda1fd736d60cc477d99f2e7a042acfa46e8"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.15+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "PrecompileTools", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "f93655dc73d7a0b4a368e3c0bce296ae035ad76e"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.16"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "55c53be97790242c29031e5cd45e8ac296dadda3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.5.0+0"

[[deps.HypergeometricFunctions]]
deps = ["LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "68c173f4f449de5b438ee67ed0c9c748dc31a2ec"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.28"

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
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IrrationalConstants]]
git-tree-sha1 = "e2222959fbc6c19554dc15174c81bf7bf3aa691c"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.4"

[[deps.JLFzf]]
deps = ["REPL", "Random", "fzf_jll"]
git-tree-sha1 = "1d4015b1eb6dc3be7e6c400fbd8042fe825a6bac"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.10"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "a007feb38b422fbdab534406aeca1b86823cb4d6"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.7.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "eac1206917768cb54957c65a615460d87b455fc1"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.1.1+0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "170b660facf5df5de098d866564877e119141cbd"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.2+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aaafe88dccbd957a8d82f7d05be9b69172e0cee3"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.0.1+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "78211fb6cbc872f77cad3fc0b6cf647d923f4929"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.7+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1c602b1127f4751facb671441ca72715cc95938a"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.3+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.Latexify]]
deps = ["Format", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "cd10d2cc78d34c0e2a3a36420ab607b611debfbb"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.7"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
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
git-tree-sha1 = "27ecae93dd25ee0909666e6835051dd684cc035e"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+2"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "ff3b4b9d35de638936a525ecd36e86a8bb919d11"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "be484f5c92fad0bd8acfef35fe017900b0b73809"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.18.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a31572773ac1b745e0343fe5e2c8ddda7a37e997"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.41.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "4ab7581296671007fc33f07a721631b8855f4b1d"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.1+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "321ccef73a96ba828cd51f2ab5b9f917fa73945a"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.41.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "13ca9e2586b89836fd20cccf56e57e2b9ae7f38f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.29"

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
git-tree-sha1 = "f02b56007b064fbfddb4c9cd60161b6dd0f40df3"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.1.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MacroTools]]
git-tree-sha1 = "72aebe0b5051e5143a079a4685a46da330a40472"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.15"

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
git-tree-sha1 = "9b8215b1ee9e78a293f99797cd31375471b2bcae"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.3"

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
version = "0.8.1+4"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "38cb508d080d21dc1128f7fb04f20387ed4c0af4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a9697f1d06cc3eb3fb3ad49cc67f2cfabaac31ea"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.16+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6703a85cb3781bd5909d48730a67205f3f31a575"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.3+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "cc4054e898b852042d7b503313f7ad03de99c3dd"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.0"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "0e1340b5d98971513bddaa6bbed470670cebbbfe"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.34"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "3b31172c032a1def20c98dae3f2cdc9d10e3b561"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.56.1+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "44f6c1f38f77cafef9450ff93946c53bd9ca16ff"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.2"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "db76b1ecd5e9715f3d043cec13b2ec93ce015d53"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.44.2+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "41031ef3a1be6f5bbbf3e8073f210556daeae5ca"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.3.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "StableRNGs", "Statistics"]
git-tree-sha1 = "3ca9a356cd2e113c420f2c13bea19f8d3fb1cb18"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.3"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "TOML", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "41c9a70abc1ff7296873adc5d768bff33a481652"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.40.12"

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
git-tree-sha1 = "d3de2694b52a01ce61a036f18ea9c0f61c4a9230"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.62"

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

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.PtrArrays]]
git-tree-sha1 = "1d36ef11a9aaf1e8b74dacc6a731dd1de8fd493d"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.3.0"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "492601870742dcd38f233b23c3ec629628c1d724"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.7.1+1"

[[deps.Qt6Declarative_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6ShaderTools_jll"]
git-tree-sha1 = "e5dd466bf2569fe08c91a2cc29c1003f4797ac3b"
uuid = "629bc702-f1f5-5709-abd5-49b8460ea067"
version = "6.7.1+2"

[[deps.Qt6ShaderTools_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "1a180aeced866700d4bebc3120ea1451201f16bc"
uuid = "ce943373-25bb-56aa-8eca-768745ed7b5a"
version = "6.7.1+1"

[[deps.Qt6Wayland_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6Declarative_jll"]
git-tree-sha1 = "729927532d48cf79f49070341e1d918a65aba6b0"
uuid = "e99dba38-086e-5de3-a5b1-6e4c66e897c3"
version = "6.7.1+1"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "9da16da70037ba9d701192e27befedefb91ec284"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.11.2"

    [deps.QuadGK.extensions]
    QuadGKEnzymeExt = "Enzyme"

    [deps.QuadGK.weakdeps]
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"

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

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "852bd0f55565a9e973fcfee83a84413270224dc4"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.8.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "58cdd8fb2201a6267e1db87ff148dd6c1dbd8ad8"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.5.1+0"

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

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

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

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "41852b8679f78c8d8961eeadc8f62cef861a52e3"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.5.1"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "83e6cce8324d49dfaf9ef059227f91ed4441a8e5"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.2"

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
deps = ["AliasTables", "DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "29321314c920c26684834965ec2ce0dacc9cf8e5"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.4"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "35b09e80be285516e52c9054792c884b9216ae3c"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.4.0"

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

    [deps.StatsFuns.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

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

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "6cae795a5a9313bbb4f60683f7263318fc7d1505"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.10"

[[deps.URIs]]
git-tree-sha1 = "cbbebadbcc76c5ca1cc4b4f3b0614b3e603b5000"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.2"

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

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "c0667a8e676c53d390a09dc6870b3d8d6650e2bf"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.22.0"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "975c354fcd5f7e1ddcc1f1a23e6e091d99e99bc8"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.4"

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
git-tree-sha1 = "85c7811eddec9e7f22615371c3cc81a504c508ee"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+2"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "5db3e9d307d32baba7067b13fc7b5aa6edd4a19a"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.36.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "b8b243e47228b4a3877f1dd6aee0c5d56db7fcf4"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.6+1"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "fee71455b0aaa3440dfdd54a9a36ccef829be7d4"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.8.1+0"

[[deps.Xorg_libICE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a3ea76ee3f4facd7a64684f9af25310825ee3668"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.1.2+0"

[[deps.Xorg_libSM_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libICE_jll"]
git-tree-sha1 = "9c7ad99c629a44f81e7799eb05ec2746abb5d588"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.6+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "9dafcee1d24c4f024e7edc92603cedba72118283"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+3"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aa1261ebbac3ccc8d16558ae6799524c450ed16b"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.13+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "807c226eaf3651e7b2c468f687ac788291f9a89b"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.3+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "52858d64353db33a56e13c341d7bf44cd0d7b309"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.6+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "d7155fea91a4123ef59f42c4afb5ab3b4ca95058"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.6+3"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "6fcc21d5aea1a0b7cce6cab3e62246abd1949b86"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.0+0"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "984b313b049c89739075b8e2a94407076de17449"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.8.2+0"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll"]
git-tree-sha1 = "a1a7eaf6c3b5b05cb903e35e8372049b107ac729"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.5+0"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "b6f664b7b2f6a39689d822a6300b14df4668f0f4"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.4+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "a490c6212a0e90d2d55111ac956f7c4fa9c277a6"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.11+1"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXau_jll", "Xorg_libXdmcp_jll"]
git-tree-sha1 = "bfcaf7ec088eaba362093393fe11aa141fa15422"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.1+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "dbc53e4cf7701c6c7047c51e17d6e64df55dca94"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.2+1"

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
git-tree-sha1 = "ab2221d309eda71020cdda67a973aa582aa85d69"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.6+1"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "691634e5453ad362044e2ad653e79f3ee3bb98c3"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.39.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a63799ff68005991f9d9491b6e95bd3478d783cb"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.6.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "446b23e73536f84e8037f5dce465e92275f6a308"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "gperf_jll"]
git-tree-sha1 = "431b678a28ebb559d224c0b6b6d01afce87c51ba"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.9+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6e50f145003024df4f5cb96c7fce79466741d601"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.56.3+0"

[[deps.gperf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0ba42241cb6809f1a278d0bcb976e0483c3f1f2d"
uuid = "1a1c6b14-54f6-533d-8383-74cd7377aa70"
version = "3.1.1+1"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "522c1df09d05a71785765d19c9524661234738e9"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.11.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e17c115d55c5fbb7e52ebedb427a0dca79d4484e"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.2+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.libdecor_jll]]
deps = ["Artifacts", "Dbus_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pango_jll", "Wayland_jll", "xkbcommon_jll"]
git-tree-sha1 = "9bf7903af251d2050b467f76bdbe57ce541f7f4f"
uuid = "1183f4f0-6f2a-5f1a-908b-139f9cdfea6f"
version = "0.2.2+0"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "141fe65dc3efabb0b1d5ba74e91f6ad26f84cc22"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.11.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a22cf860a7d27e4f3498a0fe0811a7957badb38"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.3+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "ad50e5b90f222cfe78aa3d5183a20a12de1322ce"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.18.0+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "068dfe202b0a05b8332f1e8e6b4080684b9c7700"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.47+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "490376214c4721cdaca654041f635213c6165cb3"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+2"

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
git-tree-sha1 = "63406453ed9b33a0df95d570816d5366c92b7809"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+2"
"""

# ╔═╡ Cell order:
# ╟─334d4c94-0c39-469e-8797-9c5a17648948
# ╠═9a0cec14-08db-11eb-3cfa-4d1c327c63f1
# ╠═fb6cdc08-8b44-11eb-09f5-43c167aa53fd
# ╟─f3aad4f0-8cc2-11eb-1a25-535297327c65
# ╟─b6b055b6-8cae-11eb-29e5-b507c1a2b9bf
# ╟─bcfaedfa-8cae-11eb-10a1-cb7be7dc2e6b
# ╟─d2c19564-8b44-11eb-1077-ddf6d1395b59
# ╟─ac4f6944-08d9-11eb-0b3c-f5e0a8b8c17e
# ╟─4ca399f4-8b45-11eb-2d2b-8189e04fc804
# ╟─57080632-8b45-11eb-1003-05afb2331b25
# ╟─139ecfec-8b46-11eb-2649-2f77833d749a
# ╟─f9a75ac4-08d9-11eb-3167-011eb698a32c
# ╟─17812c7c-8cac-11eb-1d0a-6512415f6938
# ╠═178631ec-8cac-11eb-1117-5d872ba7f66e
# ╟─179a4db2-8cac-11eb-374f-0f24dc81ebeb
# ╟─17cf895a-8cac-11eb-017e-c79ffcab60b1
# ╠═17bbf532-8cac-11eb-1e3f-c54072021208
# ╠═17e0d142-8cac-11eb-2d6a-fdf175f5d419
# ╟─18da7920-8cac-11eb-07f4-e109298fd5f1
# ╠═17fe87a0-8cac-11eb-2938-2d9cd19ecc0f
# ╠═1829091c-8cac-11eb-1b77-c5ed7dd1261b
# ╠═1851dd6a-8cac-11eb-18e4-87dbe1714be0
# ╟─a9447530-8cb6-11eb-38f7-ff69a640e3c4
# ╟─c1fde6ba-8cb6-11eb-2170-af6bc84c01a7
# ╠═18755e3e-8cac-11eb-37bf-1dfa5fbe730a
# ╠═f947a976-8cb6-11eb-2ae7-59eba4c6f40f
# ╠═5a0b407e-8cb7-11eb-0c0d-c7767a6b0a1d
# ╟─fe53ee0c-8cb6-11eb-19bc-2976da1abe16
# ╠═1894b388-8cac-11eb-2287-97f985df1fbd
# ╟─f90981e7-4118-4cf4-8cdb-a0bd28c2c6e6
# ╠═86299112-8cc6-11eb-257a-9d803feac359
# ╠═9eb69e94-8cc6-11eb-323b-5587cc743571
# ╠═b8d01ae4-8cc6-11eb-1d16-47095532f738
# ╠═fc715452-8cc6-11eb-0246-e941f7698cfe
# ╟─71fbc75e-8bf3-11eb-3ac9-dd5401033c78
# ╟─7c01f6a6-8bf3-11eb-3c4d-ad7e206a9277
# ╠═ba7ffe78-0845-11eb-2847-851a407dd2ec
# ╠═45bb6df0-8cc7-11eb-100f-37c2a76df464
# ╟─dcd279b0-8bf3-11eb-0cb9-95f351626ed1
# ╟─fbada990-8bf3-11eb-2bb7-d786362669e8
# ╠═b6786ec8-8bf3-11eb-1347-61f231fd3b4c
# ╟─ac98f5da-8bf3-11eb-076f-597ce4455e76
# ╠═0e7a04a4-8bf4-11eb-2e9d-fb48c23b8d8c
# ╠═093275e4-8cc8-11eb-136f-3ffe522c4125
# ╟─111eccd2-8bf4-11eb-097c-7582f811d146
# ╟─4edaec4a-8bf4-11eb-3094-010ebe9b56ab
# ╟─9d66e31e-8cad-11eb-3ad0-3980ba66cb0e
# ╠═174ccb7f-b134-4c1f-9b59-e4c8460bc40e
# ╟─79112bc0-c3a8-4fea-8457-90aca33a8022
# ╠═8405e310-8bf8-11eb-282b-d93b4fc683aa
# ╟─af2594c4-8cad-11eb-0fff-f59e65102b3f
# ╠═8aa60da0-8bf8-11eb-0fa2-11aeecb89564
# ╟─8d56b6d2-8cc8-11eb-0dbd-b3533dde4aa3
# ╠═a034c2a6-8bf8-11eb-0f06-0b35a0e8e68d
# ╠═c166edb6-8cc8-11eb-0436-f74164ff6ea7
# ╠═d25dc130-8cc8-11eb-177f-63a1792494c0
# ╠═e2f45234-8cc8-11eb-2be9-598eb590592a
# ╟─3ef23da4-8cb4-11eb-0d5f-d5ee8fc56227
# ╠═bc5d6fae-8cad-11eb-3351-a734d2366557
# ╠═2d9c560e-8bf9-11eb-1ac5-f77f7caf776f
# ╠═ce94541c-8bf9-11eb-1ac9-51e66a017813
# ╟─a057e7ee-8bf9-11eb-2ceb-2dda3718a70a
# ╟─4a743662-8cb6-11eb-26a6-d911e60653e4
# ╠═e2d764d0-0845-11eb-0031-e74d2f5acaf9
# ╠═33f9fc36-0846-11eb-18c2-77f92fca3176
# ╠═cb278624-08dd-11eb-3375-276bfe8d7b3a
# ╠═f3c85814-0846-11eb-1266-63f31f351a51
# ╠═01dbe272-0847-11eb-1331-4360a575ff14
# ╠═be8e4ac2-08dd-11eb-2f72-a9da5a750d32
# ╟─fe0aa72c-8b46-11eb-15aa-49ae570e5858
# ╠═8bc52d58-0848-11eb-3487-ef0d06061042
# ╟─caa3faa2-08e5-11eb-33fe-cbbc00cfd459
# ╟─2174aeba-08e6-11eb-09a9-2d6a882a2604
# ╟─f5756dd6-0847-11eb-0870-fd06ad10b6c7
# ╟─113c31b2-08ed-11eb-35ef-6b4726128eff
# ╠═6a545268-0846-11eb-3861-c3d5f52c061b
# ╟─4c8827b8-0847-11eb-0fd1-cfbdbdcf392e
# ╟─3cd1ad48-08ed-11eb-294c-f96b0e7c33bb
# ╟─f32b936a-8bf6-11eb-1dd7-fd8c5904bf1f
# ╟─f8f38028-8bf6-11eb-321b-8f91e38da495
# ╟─2de1ef6c-8cb1-11eb-3dd9-f3904ec1408b
# ╠═48fb6ed6-8cb1-11eb-0894-b526e6c43b01
# ╟─713a2644-8cb1-11eb-1904-f301e39d141e
# ╠═511892e0-8cb1-11eb-3814-b98e8e0bbe5c
# ╠═1173ebbe-8cb1-11eb-0a21-7d40a2c8a855
# ╟─dfdaf1dc-8cb1-11eb-0287-f150380d323b
# ╠═ca3db0a8-8cb1-11eb-2f7b-c9343a29ed02
# ╟─b3ce9e3a-8c35-11eb-1ad0-81f9b09f963e
# ╟─2f980870-0848-11eb-3edb-0d4cd1ed5b3d
# ╟─6af30142-08b4-11eb-3759-4d2505faf5a0
# ╟─c6f9feb6-08f3-11eb-0930-83385ca5f032
# ╟─d8d8e7d8-08b4-11eb-086e-6fdb88511c6a
# ╟─780c483a-08f4-11eb-1205-0b8aaa4b1c2d
# ╟─a13dd444-08f4-11eb-08f5-df9dd99c8ab5
# ╟─cb99fe22-0848-11eb-1f61-5953be879f92
# ╟─8d2858a4-8c38-11eb-0b3b-61a913eed928
# ╠═93da8b36-8c38-11eb-122a-85314d6e1921
# ╠═9572eda8-8c38-11eb-258c-739b511de833
# ╠═7850b114-8c3b-11eb-276a-df5c332bf6d3
# ╠═9f41d4f2-8c38-11eb-3eae-a1ec0d86d64c
# ╠═36a0fd79-fe02-463f-b615-c519e55c4710
# ╟─148f486c-8c3d-11eb-069f-cd595c5f7177
# ╟─4d61636e-8c3d-11eb-2726-6dc51e8a4f84
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
