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

# ╔═╡ 9a0cec14-08db-11eb-3cfa-4d1c327c63f1
begin
    using PlutoUI, StatsBase, Statistics
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

- Porque criar um tipo novo? Abstração e manter a organização da informação relacionadas a um mesmo objeto.

- Diferentes tipos de gráficos.

- Interpolação de strings.

- Convenções sobre capitalização de nomes de funções, variáveis e tipos.
"""

# ╔═╡ d2c19564-8b44-11eb-1077-ddf6d1395b59
md"""
## Modelos baseados em indivíduos, ou partículas (microscópicos).
"""

# ╔═╡ ac4f6944-08d9-11eb-0b3c-f5e0a8b8c17e
md"""

Modelos **baseados em indivíduos** especificam o comportamento, ou ações, de cada indivíduo usando um conjunto de regras. Mesmo nesse caso, é comum buscarmos informações sobre o comportamento global de sistemas compostos de muitos indivíduos e como esse sistema evolui no tempo. Por exemplo, podemos querer responder perguntas como:

* Qual a proporção de indivíduos infectados em um certo instante de tempo?
* O mercado de ações está subindo ou descendo?

Neste caderno, nó vamos ver como podemos partir de um modelo probabilístico baseado em indivíduos e, por vezes, chegar a um model **determinístivo** de equações que explicam o comportamento **macroscópico** (geral) do sistema. 

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
Essa ideia pode ser usada para modelar diferentes situações. Por exemplo: o tempo para uma lâmpada queimar ou o tempo para uma máquina precisar de manutenção, o tempo de decaimento de um núcleo radioativo, o tempo para se recuperar de uma infecção, etc.
"""

# ╔═╡ f9a75ac4-08d9-11eb-3167-011eb698a32c
md"""

A questão básica é:

> Considere que temos $N$ lâmpadas que estão funcionando bem no dia $0$. 
> 
> - Se cada lâmpada tem probabilidade $p$ de queimar a cada dia, quantas lâmpadas ainda estarão acessas no dia $t$?
> - Quanto, em média, um lâmpada dura?
> - E, será que lâmpadas queimam exatamente ao passar a meia-noite de um dado dia? É possível pensar em modelos mais realísticos?

Vamos de novo usar o ponto de vista do pensamento computacional: vamos usar código para fazer simulações e visualizações e ganhar intuição sobre o problema.
"""

# ╔═╡ 17812c7c-8cac-11eb-1d0a-6512415f6938
md"""
## Visualizando falhas de componentes
"""

# ╔═╡ 178631ec-8cac-11eb-1117-5d872ba7f66e
function simulate(m, p, tmax = 100)
	# We use tmax + 1 to indicate that the failure did not occur in
	# the simulation time frame.
    S = fill(tmax + 1, m, m)

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

# ╔═╡ 179a4db2-8cac-11eb-374f-0f24dc81ebeb
md"""
m = $(@bind m Slider(2:20, show_value=true, default=8))
"""

# ╔═╡ 17cf895a-8cac-11eb-017e-c79ffcab60b1
md"""
p= $(@bind prob Slider(0.01:.01:1, show_value=true, default=.1))

t = $(@bind tt Slider(1:100, show_value=true, default=1))
"""

# ╔═╡ 17bbf532-8cac-11eb-1e3f-c54072021208
simulation = simulate(m, prob)

# ╔═╡ 18da7920-8cac-11eb-07f4-e109298fd5f1
begin
    rectangle(w, h, x, y) = (x .+ [0, w, w, 0], y .+ [0, 0, h, h])

    function circle(r, x, y)
		θ = range(0, 2π, length = 30)
    	return (x .+ r .* cos.(θ), y .+ r .* sin.(θ))
	end
end

# ╔═╡ 17e0d142-8cac-11eb-2d6a-fdf175f5d419
begin
    w = 0.9
    h = 0.9
    c = [RGB(0, 1, 0), RGB(1, 0, 0), :purple][1 .+ (simulation .< tt) .+ (simulation .< (tt .- 1))]

	plot(size = (500, 500), ratio = 1, legend = false, axis = false, ticks = false, grid = false)

    for i = 1:m, j = 1:m
        plot!(rectangle(w, h, i, m - 1 - j), c = :black, fill = true, alpha = 0.5)
        plot!(circle(0.3, i + 0.45, m - (j + 0.55)), c = c[j, i], fill = true, alpha = 0.5)
    end

    for i = 1:m, j = 1:m
        if simulation[j, i] < tt
            annotate!(i + 0.5, m - (j + 0.55), text("$(simulation[j, i])", 7, :white))
        end
    end


    plot!(
        lims = (0, m + 1.1, 0, m + 1.1),
        title = "time = $(tt-1);  failed count: $(sum(simulation.<tt))",
    )
end

# ╔═╡ 17fe87a0-8cac-11eb-2938-2d9cd19ecc0f
begin

    plot(size = (500, 300))
    cdf = [count(simulation .≤ i) for i = 0:100]
    bar!(cdf, c = :purple, legend = false, xlim = (0, tt), alpha = 0.8)
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
    countmap(simulation[:]),
    c = :red,
    legend = false,
    xlim = (0, tt + 0.5),
    size = (500, 300),
	title = "Number of failures at each period"
)

# ╔═╡ a9447530-8cb6-11eb-38f7-ff69a640e3c4
md"""
## Interpolações em strings
"""

# ╔═╡ c1fde6ba-8cb6-11eb-2170-af6bc84c01a7
md"""
Vamos abrir um rápido parêntesis. Como apresentar uma image, digamos do Daneil Bernoulli, no Pluto. Uma opção é usar diretamente HTML, que a linguagem usada na construção de páginas web. Naturalmente, podemos armazear código HTML em uma string. Julia, por sua vez, já possui um tipo que recebe uma string representado código HTML e a devolve em um formato que Pluto pode mostrar imediatamente.

Para mostrar isso em ação vamos gerar código HTML para apresentar uma imagem do Bernouli, junto a informação da largura desejada. O browser vai então se encarregar de mostrar a imagem no tamanho pedido. Para passar essas informações para a string vamos usar _interpolação_, a capacide que Julia tem de sustituir a sintaxe `$(variable)` dentro de uma string pelo o valor atual da variável.
		
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
Observe que podemos usar um conjunto de _três_ aspas seguidas (`"`) para representar uma string com múltiplas linhas, ou para escrever strings que possui aspas em seu conteúdo.
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

# ╔═╡ ba7ffe78-0845-11eb-2847-851a407dd2ec
bernoulli(p) = rand() < p

# ╔═╡ 45bb6df0-8cc7-11eb-100f-37c2a76df464
bernoulli(0.25)

# ╔═╡ dcd279b0-8bf3-11eb-0cb9-95f351626ed1
md"""
Da forma que foi definida, a variável está retornando um valor  `Bool` (verdadeiro ou falso). Para converter esse valor para 0 ou 1 basta repassá-lo para `Int`.
"""

# ╔═╡ fbada990-8bf3-11eb-2bb7-d786362669e8
md"""
Let's generate (sample) some Bernoulli random variates:
"""

# ╔═╡ b6786ec8-8bf3-11eb-1347-61f231fd3b4c
flips = [Int(bernoulli(0.25)) for i = 1:100]

# ╔═╡ ac98f5da-8bf3-11eb-076f-597ce4455e76
md"""
Como já vimos, é natural se perguntar qual é usa **média** ou **esperança** ou **valor esperado**.
"""

# ╔═╡ 0e7a04a4-8bf4-11eb-2e9d-fb48c23b8d8c
sample_mean(data) = sum(data) / length(data)

# ╔═╡ 093275e4-8cc8-11eb-136f-3ffe522c4125
sample_mean(flips)

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

Isso permite alterar rapidamente código basedado em `rand` para usar uma nova distribuição. Mas para isso é preciso estender a função original para entender que está recebendo uma nova distribuição. 

Isso sugere que mesmo que toda informação de nossa distribuição Bernoulli possa ser guarda em uma simples variável Float64, é melhor criar um tipo específico para ela. Assim fica fácil estender funções com novos métodos que se especialização nesse tipo. 

Se nós guardamos a informação de nossa distribuição Bernoulli em um `Float64` não há muito como fazer essa extensão. Além disso guardar esse informação em um `Float64` comum não deixa claro que esse número na verdade representa outro conceito: uma distribuição Bernoulli. Esse é mais um motivo para criar um tipo específico.

Vamos fazer isso abaixo e estenter algumas funções importantes.
"""

# ╔═╡ 8405e310-8bf8-11eb-282b-d93b4fc683aa
struct Bernoulli   # weighted coin flip
    p::Float64
end

# ╔═╡ af2594c4-8cad-11eb-0fff-f59e65102b3f
md"""
Como disse acima, queremos amostrar a distribuiução usando `rand`. Podemos também querer calcular a sia média e desvio padrão. Para isso vamos estender as respecticas funções com novos métodos especializados. Vocês farão mais disso na lista.
"""

# ╔═╡ 8aa60da0-8bf8-11eb-0fa2-11aeecb89564
Base.rand(X::Bernoulli) = Int(rand() < X.p)

# ╔═╡ 8d56b6d2-8cc8-11eb-0dbd-b3533dde4aa3
md"""
[Lembre-se: em Julia a convenção é que os nomes de função e nomes de variáveis começam com letras minúsculas. Já os nomes de tipos com maiúsculas. Uma possível exceção são variáveis com nome de uma única letra que representam conceitos que em Matemática são tipicamente representados como maiúsculas, como o nome de matrizes.]
"""

# ╔═╡ a034c2a6-8bf8-11eb-0f06-0b35a0e8e68d
B = Bernoulli(0.25)

# ╔═╡ c166edb6-8cc8-11eb-0436-f74164ff6ea7
methods(Bernoulli)

# ╔═╡ d25dc130-8cc8-11eb-177f-63a1792494c0
Bernoulli(1 // 4)

# ╔═╡ e2f45234-8cc8-11eb-2be9-598eb590592a
rand(B)

# ╔═╡ 3ef23da4-8cb4-11eb-0d5f-d5ee8fc56227
md"""
O objeto `B` representação uma distribuição Bernoulli com probabilidade $p$. Ela pode ser usada sempre que precisarmos de uma distribuição desse tipo. Você agora tentar criar o seu próprio mini pacote com sua distribuição simples. Assim não vai precisar fazer copia-e-cola quando precisar reutilizá-la. 

Por outro lado, já existem pacotes com muitas possíveis distribuições incluindo essa. Dê uma olhada em `Distributions.jl` ou no novo `MeasureTheory.jl`.
"""

# ╔═╡ bc5d6fae-8cad-11eb-3351-a734d2366557
rand(B)

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

# ╔═╡ e2d764d0-0845-11eb-0031-e74d2f5acaf9
function step!(bulbs, B)
    for i = 1:length(bulbs)
        if bulbs[i] && rand(B) == 1
            bulbs[i] = false
        end
    end
end

# ╔═╡ fe0aa72c-8b46-11eb-15aa-49ae570e5858
md"""
N = $(@bind N Slider(1:1000, show_value=true, default=70))

p = $(@bind p Slider(0:0.01:1, show_value=true, default=0.05))

T = $(@bind T Slider(1:100, show_value=true, default=100))
"""

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

    xlabel!("time t")
    ylabel!("glowing")
end

# ╔═╡ f3c85814-0846-11eb-1266-63f31f351a51
all_data = [simulate_lifespan(N, T, p) for runs = 1:30];

# ╔═╡ 01dbe272-0847-11eb-1331-4360a575ff14
begin
    plot(all_data, alpha = 0.1, label="", m = :o, ms = 1, size = (500, 400))
    xlabel!("time t")
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
        replace.(all_data, 0.0 => NaN),
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

    xlabel!("Time t")
    ylabel!("glowing")
end



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

$$N_{t+1} = (1 - p) (1 - p) N_{t-1} = (1 - p)^2 N_{t-1}$$.

Taí uma recorrência fácil de resolver. Ela diz que

$$N_t = (1-p)^t \, N_0.$$
"""

# ╔═╡ 113c31b2-08ed-11eb-35ef-6b4726128eff
md"""
Vamos comparar o resultado exato com a simulação numérica.
"""

# ╔═╡ 6a545268-0846-11eb-3861-c3d5f52c061b
exact = [N * (1 - p)^t for t = 0:T]

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
No instante $0$ existem $N_0$ lâmpadas funcinando. Quandas ficam ``{\color{red} \text{vermelhas}}`` (queimam) no primeiro passo? Vamos chamar isso de $\Delta N_0$.

Intuitivamente, a média é $\langle \Delta N_0 \rangle = p N_0$. Mas isso não captura tudo. De fato, $\Delta N_0$ é uma variável aleatória. Em princípio, pode ocorrer que nenhuma lâmpada queime, ou mesmo que todos queimem ao mesmo tempo. Mas esses dois eventos têm probabilidade baixa.

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
Note que em Julia não somos obrigados a implementar todos os possíveis métodos imediatamente ao criar o tipo, como ocorre em outras linguagens. Podemos criar os métodos depois, e outras pessoas podem também adicionar novos métodos se tiverem acesso ao seu pacote ou, mesmo, modificar o comporatmento original.
"""

# ╔═╡ 511892e0-8cb1-11eb-3814-b98e8e0bbe5c
Base.rand(X::Binomial) = sum(rand(Bernoulli(X.p)) for i = 1:X.N)

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
Se chamarmos de $q := 1 - p$, então cada pra lâmpada os dois possíveis resultados são "falha", probabilidade $p$, "não-falha" com probabilidade "q". Isso é exatamente equivalente a jogar $n$ moedas viciadas de maneira independente.

O número de maneiras de escolher os resultados de tal maneira que exatamente $k$ lâmpadas falhem é dado pelo coeficiente de $p^k$ na expansão de $(p + q)^n$, ou seja, é dado pelo **coeficiente binomial**

$$\begin{pmatrix} n \\ k \end{pmatrix} := \frac{n!}{k! \, (n-k)!},$$

em que $n! := 1 \times 2 \times \cdots n$ é o fatorial de $n$.

"""

# ╔═╡ 2f980870-0848-11eb-3edb-0d4cd1ed5b3d
md"""
## Tempo contínuo

Se olharmos o gráfico da média em função do tempo, ele parece seguir uma curva suave. De fato, isso sugere que faz sentido não apenas perguntar o número de lâmpadas que falham ao final de cada *dia*, mas pensar se não conseguirmos estimar isso para qualquer instante do tempo.

Para ver como fazer isso, vamos tentar ajustar as ideias acima para passos no tempo de $\delta t$ quaisquer no lugar de $\delta t = 1$ como foi usado acima.

Nós precisamos ajustar a probabilidade de falha para cada possível passo. Se imaginarmos que a change de falhar em qualquer instante é a mesma é natural considerar que a probabilidade de falha para um certo $\delta t$ é proporcial à sua duração:

$$p(\delta t) \simeq \lambda \, \delta t,$$

em que $\lambda$ é a *taxa* de falha. O termo *taxa* é para enfatizar que ela fornece a probabiidade de falha *por unidade de tempo*.

Obtemos,
"""

# ╔═╡ 6af30142-08b4-11eb-3759-4d2505faf5a0
md"""
$$N(t + \delta t) - N(t) \simeq -\lambda \,\delta t \, N(t)$$,
"""

# ╔═╡ c6f9feb6-08f3-11eb-0930-83385ca5f032
md"""
note que estamos agora usando o $t$ como um argumento de uma função que está definida em todo o tempo e não mais como um índice de um vetor discreto.

Dividindo por $\delta t$ isso dá

$$\frac{N(t + \delta t) - N(t)}{\delta t} \simeq -\lambda \, N(t)$$.

O limite à esquerda não mais o que o quociente usado na definição *derivada* do número de lâmpadas funcionando em função do tempo. Tomando o limite obtemos
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
Uma dedução alternativa pode ser obtida reconhecendo a fórmula da exponencial no limite ao se conderar cada vez mais passos discretos com  $\delta t \to 0$ of da expressão obtida a partir da fórmula recursiva. Note que isso também é a expressão usual de juros compostos.
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
Note que o último modelo, em tempo contínuo é mais interessante. Ele permite que as lâmpadas queimem em qualquer instante do tempo e não somente em instantes pré-definidos. Afinal de contas, é examente isso o que ocorre no mundo real. Lâmpadas não esperam o cronômetro zerar. 

Por outro lado o que medimos é tipicamente discreto, medimos quantas lâmbadas queimaram no último dia, hora, etc. O processo contínuo é então o limite do que veríamos se pudéssemos medir cada vez mais rápido com cada vez mais lâmpadas. 

Essa última afirmação se faz necessária porque o processo contínuo aceita "meia" lâmpada queimada.
"""

# ╔═╡ 4d61636e-8c3d-11eb-2726-6dc51e8a4f84
md"Essas mesmas ideias são usadas para modelar o processo de pessoas se recuperando de doenças, em modelo de epidemiologia matemática como SIR que foram tão usados na pandemia de Covid-19. Além disso, fórmulas de recorrência um pouco mais sofisticadas, onde a probabilidade mudar de estado na verdade depende da proporção de pessoas em outro estado, levam diretamente ao modelo SIR completo. Mas isso é para uma outra versão dessa aula."

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
Plots = "~1.22.1"
PlutoUI = "~0.7.9"
StatsBase = "~0.33.10"
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
git-tree-sha1 = "9995eb3977fbf67b86d0a0a0508e83017ded03f2"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.14.0"

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
git-tree-sha1 = "4866e381721b30fac8dda4c8cb1d9db45c8d2994"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.37.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[DataAPI]]
git-tree-sha1 = "bec2532f8adb82005476c141ec23e921fc20971b"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.8.0"

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
git-tree-sha1 = "60ed5f1643927479f845b0135bb369b031b541fa"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.14"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "8a954fed8ac097d5be04921d595f741115c1b2ad"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+0"

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
git-tree-sha1 = "438d35d2d95ae2c5e8780b330592b6de8494e779"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.3"

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
git-tree-sha1 = "4c2637482176b1c2fb99af4d83cb2ff0328fc33c"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.22.1"

[[PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "44e225d5837e2a2345e69a1d1e01ac2443ff9fcb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.9"

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

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[Suppressor]]
git-tree-sha1 = "a819d77f31f83e5792a76081eee1ea6342ab8787"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.0"

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
# ╠═17bbf532-8cac-11eb-1e3f-c54072021208
# ╟─17cf895a-8cac-11eb-017e-c79ffcab60b1
# ╟─17e0d142-8cac-11eb-2d6a-fdf175f5d419
# ╟─18da7920-8cac-11eb-07f4-e109298fd5f1
# ╠═17fe87a0-8cac-11eb-2938-2d9cd19ecc0f
# ╟─1829091c-8cac-11eb-1b77-c5ed7dd1261b
# ╟─1851dd6a-8cac-11eb-18e4-87dbe1714be0
# ╟─a9447530-8cb6-11eb-38f7-ff69a640e3c4
# ╟─c1fde6ba-8cb6-11eb-2170-af6bc84c01a7
# ╟─18755e3e-8cac-11eb-37bf-1dfa5fbe730a
# ╟─f947a976-8cb6-11eb-2ae7-59eba4c6f40f
# ╟─5a0b407e-8cb7-11eb-0c0d-c7767a6b0a1d
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
# ╟─45bb6df0-8cc7-11eb-100f-37c2a76df464
# ╟─dcd279b0-8bf3-11eb-0cb9-95f351626ed1
# ╟─fbada990-8bf3-11eb-2bb7-d786362669e8
# ╠═b6786ec8-8bf3-11eb-1347-61f231fd3b4c
# ╟─ac98f5da-8bf3-11eb-076f-597ce4455e76
# ╠═0e7a04a4-8bf4-11eb-2e9d-fb48c23b8d8c
# ╠═093275e4-8cc8-11eb-136f-3ffe522c4125
# ╟─111eccd2-8bf4-11eb-097c-7582f811d146
# ╟─4edaec4a-8bf4-11eb-3094-010ebe9b56ab
# ╟─9d66e31e-8cad-11eb-3ad0-3980ba66cb0e
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
# ╟─fe0aa72c-8b46-11eb-15aa-49ae570e5858
# ╠═33f9fc36-0846-11eb-18c2-77f92fca3176
# ╠═cb278624-08dd-11eb-3375-276bfe8d7b3a
# ╠═f3c85814-0846-11eb-1266-63f31f351a51
# ╠═01dbe272-0847-11eb-1331-4360a575ff14
# ╠═be8e4ac2-08dd-11eb-2f72-a9da5a750d32
# ╠═8bc52d58-0848-11eb-3487-ef0d06061042
# ╟─caa3faa2-08e5-11eb-33fe-cbbc00cfd459
# ╟─2174aeba-08e6-11eb-09a9-2d6a882a2604
# ╟─f5756dd6-0847-11eb-0870-fd06ad10b6c7
# ╟─113c31b2-08ed-11eb-35ef-6b4726128eff
# ╟─6a545268-0846-11eb-3861-c3d5f52c061b
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
