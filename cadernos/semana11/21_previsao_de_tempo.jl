### A Pluto.jl notebook ###
# v0.19.42

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

# ╔═╡ 88b46d2e-220e-11eb-0f7f-b3f523f0214e
begin
    using Plots
    using PlutoUI
    using LaTeXStrings
    using Roots
    using DifferentialEquations
    using Statistics
    using LinearAlgebra
end

# ╔═╡ b88f370f-d7d6-4eb1-939f-587a3219d42c
md"Tradução livre de [predicting\_the\_weather.jl](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week11/predicting_the_weather.jl)."

# ╔═╡ f9dbf2e8-574d-4846-af48-f7e5a82a1afc
TableOfContents(title="Índice", aside=true)

# ╔═╡ a2b2eae2-762e-41c3-a546-0caedc79db7d
md"""
# Porque podemos prever o clima mas não prever o tempo
"""

# ╔═╡ 91b34e59-e4d2-45b7-9e2b-1b95748e5d6a
md"""
## Clima vs tempo
"""

# ╔═╡ 22bddfca-fd1c-4dc7-85f3-f864c3b53407
md"""
Vai chover amanhã? Se vemos todo o avanço do conhecimento humano já atingido, parece que deveríamos ser capazes de usar informações sobre o estado atual da atmosfera e modelos de equações diferenciais para prever para amanhã como o vento irar mover o ar, qual será a temperatura ou se irá chover ou não.

E a previsão para a próxima semana? E para o próximo ano?

A nossa experiência sugere que conseguimos prever o tempo em períodos curtos de tempo, obtendo repostas confiáveis para intervalos que vão até uma semana aproximadamente (e, é claro, a probabilidade de acerto é limitada). Já prever um mês no futuro parece ser algo impossível. 

Por outro lado, podemos falar do _clima_ e como ele se comporta em escalas de tempo muito mais longas. Ou seja podemos fazer afirmações como "a temperatura média em São Paulo é de 19.5° C". A previsão de curto prazo tem um forte componente aleatório (ou aparentemente aleatório), mas se torna muito mais estável quando passamos a considerar propriedades estatísticas como médias e desvios padrões. É isso que chamamos de **clima**.
"""

# ╔═╡ 6f554dc0-220c-11eb-341f-1b66de841c86
md"""
# Dinâmica não-linear: estabilidade e bifurcações
"""

# ╔═╡ 2c6f4b31-2f08-4e24-8e31-ad80d2700fa8
md"""
Nesse caderno vamos ver que o modelo mais simples possível para o clima, um conjunto de três EDOs acopladas conhecido como **Equações de Lorenz** podem apresentar um comportamento imprevisível chamado **caos (determinístico)**. Vamos chegar lá começando de dois modelos mais simples com dinâmicas uni e bidimensionais.
"""

# ╔═╡ 822c015a-8bb3-4432-a2d4-2e2ba4f906a6
md"""
## Lembrando: equações diferenciais ordinárias (EDOs)
"""

# ╔═╡ 816de40c-220c-11eb-2d3a-23e6267cd529
md"""
Lembre-se que vamos usar equações diferenciais na nossa tentativa de modelar a evolução do clima. 

O tipo mais simples de equações diferenciais são as equações diferenciais ordinárias. Nelas algumas variáveis contínuas evoluem (continuamente) ao longo do tempo. O modelo especifica a taxa de variação instantânea (as derivadas) da variável como uma função dos seus valores atuais e, eventualmente, do tempo.

Equações diferenciais que não dependem explicitamente do tempo são um caso particularmente mais simples. Elas são conhecidas como equações **autônomas**. O modelo geral para esse caso é

$$\frac{dx(t)}{dt} = f(x(t)),$$

ou

$$\dot{x}(t) = f(x(t)),$$

com condição inicial $x(0) = x_0$.

Lembre-se que $\dot{x}(t)$ denota a derivada da função $t \mapsto x(t)$ no instante $t$.
"""

# ╔═╡ d21f6358-220c-11eb-00b8-03fe0746fdc9
md"""
Nós também vimos que o método numérico mais simples para resolução desse tipo de equação é o **método de Euler (explícito)**. Ele transforma a equação diferencial em uma equação de diferenças explícita: dado um pequeno passo temporal $h$ o método aproxima a sua derivada por

$$\frac{dx(t)}{dt} \simeq \frac{x(t + h) - x(t)}{h},$$

gerando o método 

$$x_{n+1} = x_{n} + h f(x_n),$$

em que $x_n$ é a aproximação da solução verdadeira $x(t_n)$ no $n$-ésimo passo de tempo $t_n$.
"""

# ╔═╡ 735bb47e-220d-11eb-1ba6-8d591a935857
md"""
# 1D: Modelando o crescimento de bactérias
"""

# ╔═╡ 79b148b6-220d-11eb-2785-25d05068aeed
md"""
Vamos usar isso para simula uma EDO não-linear simples que descreve a dinâmica de uma população de bactérias. As bactérias se reproduzem em uma taxa $\lambda$ _caso_ exista alimento suficiente. Nessa situação a equação seria $\dot{x} = \lambda x$. Mas a necessidade de alimento introduz um _limite_ na população. Ela só pode chegar a um valor $K$, algumas vezes conhecido como **capacidade de carga**. 

O modelo mais simples que combina o efeito de crescimento e saturação é:

$$\dot{x} = \lambda \, x \, (K - x).$$

Quando $x$ está próximo de $0$, a taxa de crescimento é $\lambda$, mas ela decresce a medida que $x$ cresce, ficando negativa se falta alimento.

(Essa equação é conhecia como equação diferencial  [**logística**](https://en.wikipedia.org/wiki/Logistic_function#Logistic_differential_equation).)
"""

# ╔═╡ d43a869e-220d-11eb-009c-a119de57e7da
md"""
O nosso objetivo aqui é usar raciocínio computacional, mas não estamos interessados na dinâmica exata. O foco deve estar no comportamento **qualitativo** do sistema. Queremos responder perguntas como: para tempos longos (formalmente $t \to \infty$) a população cresce de forma arbitrária? Ou ela oscila em torno de um valor especial? Ou ainda, ela converge a um tamanho específico? Esse tipo de pergunta, menos quantitativo e mais qualitativo, é o domínio de uma área conhecida como **dinâmica não-linear** ou **sistemas dinâmicos**. De fato essa área é muito desenvolvida no Brasil. Inclusive nos rendeu nossa única Medalha Fields (o "Nobel" da Matemática).
"""

# ╔═╡ 088eabb2-220e-11eb-1ac0-df419b87f39a
md"""
Vamos simular o sistema usando o método de Euler e tentar obter a resposta para a nossa questão sobre o comportamento "assintótico" do tamanho populacional. Lembre-se que há métodos muito mais sofisticados do que esse no pacote `DifferentialEquations.jl`. De fato, o método de Euler quase nunca é uma boa escolha e deveria ser evitado em situações práticas. Dê preferência para métodos mais bem estabelecidos, capazes de gerar soluções mais precisas, especialmente se você estiver interessado em resultados mais quantitativos.
"""

# ╔═╡ a44cc180-22d4-11eb-2129-211d024c4921
md"""
Uma boa ideia é começarmos mudando a escala das variáveis para chegar na forma mais simples:

$$\dot{x} = x \, (1 - x).$$

[Isso pode ser feito definindo um novo conjunto variáveis de espaço e tempo $x'$ e $t'$ (adimensionais) através de: $x := K \, x'$, que resulta em $K \dot{x'} = \lambda K \, x' (K - K x')$. Em seguida, definimos $t' := \lambda K \,  t$, que leva a $dx' / dt' = 1 / (\lambda K) dx' / dt$ e assim $dx' / dt' = x' (1 - x')$.]
"""

# ╔═╡ 57566646-1b4c-4098-abf7-eb242d01ca81
md"""
Agora, podemos definir a função que representa o lado direito da EDO:
"""

# ╔═╡ 6aa1d2f4-220e-11eb-06e0-c346f74aa018
logistic(x) = x * (1 - x)

# ╔═╡ b6d0dd18-22d4-11eb-2083-0b02de030579
md"""
E simulamos o crescimento da colônia de bactérias usando a nossa implementação do método de Euler (que se encontra no final do caderno) obtendo $x(t)$ como função de $t$.
"""

# ╔═╡ 2d1c6abf-3b15-4638-88c5-89b5d0585c98
md"""
Lembre-se, tipicamente iríamos evitar o método de Euler para calcular as trajetórias, mas ele é bom o suficiente para entender o comportamento _qualitativo_ da equação. E vamos usá-la justamente porque a conhecemos bem.
"""

# ╔═╡ f055be76-22d4-11eb-268a-bf70c7d8f1a1
md"""
Vemos que para essa condição inicial, a solução parece convergir a um valor fixo depois de um tempo e permanence ali indefinidamente.

Um valor como esse é chamado de **ponto fixo**, **ponto estacionário** ou **estado de equilíbrio** da EDO.
"""

# ╔═╡ 90ccb392-2216-11eb-1fd8-83b7d7c16b54
md"""
## Comportamento qualitativo: pontos fixos e sua estabilidade
"""

# ╔═╡ 0bf302de-4a0f-4341-b010-d3606e237acc
gr(fmt=:png, dpi=300, size=(400, 300))

# ╔═╡ bef9c2e4-220e-11eb-24d8-bd618d2985ea
md"""
Vamos ver o que ocorre para outras condições iniciais.
"""

# ╔═╡ 17317eb8-22d5-11eb-0f46-2bf1bddd36bb
md"""
x₀ = $(@bind x0 Slider(-0.9:0.001:3.0, default=0.5, show_value=true))
"""

# ╔═╡ ae862e10-22d5-11eb-3d75-1d748cf86944
md"""
Para ter uma visão geral do que ocorre podemos colocar várias trajetórias na mesma figura.
"""

# ╔═╡ 446c564e-220f-11eb-191a-6b419e790f3f
md"""
Vemos que todas as curvas começando perto do  $x_0 = 1$ parecem convergir a $1$ ao longo to tempo. Se o sistema começa *exatamente* no 0 fica lá para sempre. Mas se começar perto de 0, seja qual for o lado, o sistema parece se *afastar* do 0 (sem cruzar de lado). Se começa negativo as curvas se tornam ainda mais negativas "explodindo'. (Por outro lado, populações negativas não fazem sentido no problema que o sistema modela. Mas podemos ainda fazer a pergunta matemática de como o sistema se comporta nesse caso, já que ele pode, eventualmente, modelar outras situações.)

Os valores especiais $x^*_1=1$ e $x^*_2=0$ são chamados de **pontos estacionários** ou **pontos fixos** da equação diferencial. Se começarmos em um desses pontos $x^*_i$, a derivada será $f'(x^*_i) = 0$, e assim a população não muda, permanecendo no mesmo lugar $x^*_i$! Os pontos fixos podem ser encontrados procurando os zeros ou _raízes_ da função $f$, ou seja valores $x^*$ em que $f(x^*) = 0$.
"""

# ╔═╡ 38894c32-2210-11eb-26ff-d9796edd7871
md"""
Entretanto, podemos ver que há diferentes pontos fixos do ponto de vista **qualitativo**: trajetórias que começam próximas a  $x^*_1 = 1$ se *aproximam* de $x^*_1$. Já trajetórias que começam próximas a $x^*_2 = 0$ se *afastam* desse valor. Dizemos nesse caso que $x^*_1$ é um **ponto fixo estável**. Já $x^*_2$ é chamado de **ponto fixo instável**.

Em casos gerais, não é possível encontrar expressões analíticas que determinam as posições e a estabilidade dos pontos fixos. Nesse caso, podemos usar algoritmos numéricos para encontrar raízes de $f$, como o método de Newton implementado em bibliotecas de Julia como `Roots.jl`, que vamos usar. Ela parece funcionar bem para funções escalares.
"""

# ╔═╡ a196a20a-2216-11eb-11f9-6789bb2a3ece
md"""
## Espaço de estado: campos vetoriais e retrato de fase
"""

# ╔═╡ c15a53e8-2216-11eb-1460-8510aea0f570
md"""
Se quisermos encontrar a trajetória completa para uma condição inicial fixa, nós precisamos resolver a equação, seja analiticamente, seja numericamente.

Entretanto, podemos necessitar de menos informação sobre o sistema. Por exemplo, podemos estar interessados apenas no seu comportamento para **tempos longos** ou sua **dinâmica assintótica**. E, de fato, é possível obter informação sobre esse tipo de comportamento sem resolver "completamente" a EDO. Esse é o ponto de partida para o estudo qualitativo de sistemas não-lineares.

Ao invés de desenharmos trajetórias de $x(t)$ em função do tempo $t$, como fizemos acima, vamos usar uma representação gráfica alternativa. Vamos desenhar o **espaço de estados** ou **espaço de fase** do sistema: o conjunto ("espaço") de todas os possíveis valores que a variável dependente pode assumir. No sistema acima há uma única variável dependente, $x$, então o espaço de estados é a reta real, $\mathbb{R}$.

Para cada valor possível de $x$, a EDO apresenta informação sobre a taxa de variação de $x(t)$ naquele ponto. Vamos então desenhar uma **seta** nesses pontos, apontando na direção que uma partícula iniciando naquele ponto iria se mover. Para cima se  $\dot{x} > 0$ e para baixo se $\dot{x} < 0$.
"""

# ╔═╡ 42c28b16-2218-11eb-304a-e534353fa12b
md"""
Esse campo vetorial de fato nos fornece o comportamento *qualitativo* da dinâmica. Ele não nos diz o quão rápido ela será em cada região, mas indica a *tendência* das trajetórias. Nós usamos representações distintas para os pontos fixos de acordo com suas propriedades de estabilidade. Isso pode ser estimado olhando a derivada $f'(x^*)$, já que ela fornece informação de como a função $f$ vai se comportar próximo a $x^*$, com condições iniciais $x^* + \delta x$. O ponto fixo instável será representado por um quadrado verde, já o estável por um círculo cinza. Essa convenção será usada ao longo deste caderno.
"""

# ╔═╡ e6ed3366-2246-11eb-3a86-f375162c746d
md"""
## Bifurcações
"""

# ╔═╡ ec3c5d9c-2246-11eb-1ec5-e3d9c8a7fa23
md"""
Agora, imagine que há um parâmetro $\mu$ que pode variar definindo _diferentes_ versões da EDO.

$$\dot{x} = f_\mu(x).$$

Por exemplo, 
$$\dot{x} = \mu + x^2.$$

Vamos desenhar o espaço de estados para cada valor diferente de $\mu$.
"""

# ╔═╡ 3fa21738-2247-11eb-09d5-4dcf0e7377fc
g(μ, x) = μ + x^2

# ╔═╡ 19eb987e-2248-11eb-2982-1930b5840aed
md"""
μ = $(@bind λ Slider(-1.0:0.05:1, show_value=true))
"""

# ╔═╡ 49ec803a-22d7-11eb-3f04-db8f8c119a7d
md"""
Podemos também colecionar todos os campos vetorias em um único gráfico. O eixo horizontal agora representa diferentes valores possíveis de $\mu$.
"""

# ╔═╡ 27190ac0-230b-11eb-3367-af2bbbf57e5e
md"""
Vemos que no **valor crítico** $\mu_c = 0$ ocorre uma mudança **qualitativa no comportamento** do sistema. Para $\mu_x < 0$ exitem dois pontos fixos. Já para $\mu > 0$ não há nenhum. Esse tipo de mudança qualitativa de comportamento é denominado uma **bifurcação**. Nesse caso particular, os dois pontos fixos colidem em uma bifurcação **sela-nó**. 
"""

# ╔═╡ 48ef665e-22d0-11eb-2c72-b722fafd296e
md"""
# 1D: Biestabilidade e histerese
"""

# ╔═╡ 51eeb46c-22d0-11eb-1643-c92e725d9da0
md"""
Vamos agora analisar o seguinte sistema dinâmico:

$$\dot{x} = \mu + x - x^3.$$
"""

# ╔═╡ 44c1738a-2247-11eb-3232-f30b46fd7ce6
h(μ, x) = μ + x - x^3

# ╔═╡ 7a94642e-39d8-480d-9516-d11e6c1b078b
md"""
Começamos por apresentar, mais uma vez, o diagrama acima.
"""

# ╔═╡ a56ad0bc-22d7-11eb-0418-d36f3ef14109
md"""
Vemos que há uma faixa de calores $\mu$ nos quais **coexistem três pontos fixos**, dois estáveis e um instável. Como há dois pontos fixos estáveis para onde convergir dizemos que esse sistema é **biestável**.
"""

# ╔═╡ 5b9c66ce-224b-11eb-02a4-b9a5a173ee6a
md"""
Agora que entendemos o que os disgramas querem dizer e a dinâmica associada, vamos apresentar apenas os pontos fixos $x^*(\mu)$ como uma função de $\mu$. Esse tipo de gráfico é chamado de **diagrama de bifurcação**.
"""

# ╔═╡ aa81663c-230b-11eb-3c0e-39759f36deb6
md"""
Os trechos diferentes das curvas são chamados de **ramos** (de soluções).
"""

# ╔═╡ 55d4d188-2249-11eb-0c47-dfddce9b2027
md"""
## Histerese
"""

# ╔═╡ 5ac33518-2249-11eb-2d57-7de185d43e5f
md"""
Agora imagine que vamos modificar o parâmeto $\mu$ vagarosamente. Ao mudarmos o parâmetro um pouco, o sistema não estará mais em um ponto fixo, já que a posição do ponto fixo muda ao alterarmos o parâmetro. Entrentato, o sistema irá **relaxar**: seguirár a dinâmica associada ao novo valor de $\mu$ e convergirá rapidamente para o novo ponto fixo que está próximo.

Para deixar a explicação mais clara, pense que começamos com $\mu = -2$, o sistema irá se acomodar no ponto fixo inferior. A medida que aumentarmos $mu$ _lentamente_ o sistema irá sempre se acomodar no ponto fixo inferior até chegarmos nos valores de $\mu = 0.4$, aproximadamente. Nesse momento, a trajetória irá mudar, não há mais um ponto fixo estável próximo, há apenas o outro ponto fixo muito mais acima que passa a atrair todas as trajetórias. Assim o sistema irá transitar, rapidamente, para esse outro ponto.

Agora imagine que diminuímos, vagarosamente, o valor de $\mu$. Agora o sistema vai se manter em torno do ponto fixo superior até $\mu = -0.4$, aproximadamente, e só aí pular de volta para o ponto fixo inferior. 

Já para os valores do parâmetro $\mu \in [-0.4, 0.4]$ ocorre o fenômeno de **biestabiidade**, ou seja a coexistência de _dois_ pontos fixos estáveis para o mesmo valor do parâmetro (ao mesmo tempo que há um terceiro onto fixo instável entre os dois que basicamente nunca será observado).

O fato que o sistema persegue ramos diferentes depenendo de onde começa, ou seja dependente da história da dinâmica, é chamado de **histerese**.
"""

# ╔═╡ 4c73705e-230c-11eb-3c90-b14536d78808
md"""
Comportamento de hitsterse ocorre em muitos contextos científicos e de engenharia, incluindo mudanças de comportamento em biologia, como em genética e na dinâmica histórica do clima da Terra.
"""

# ╔═╡ 2ced9e26-22d0-11eb-34a5-bf80822f5c43
md"""
## Sistemas lentos-rápidos
"""

# ╔═╡ 3213d406-22d0-11eb-0e89-71b42ea5cada
md"""
O que estamos fazendo, de fato, ao permitir o parâmetro $\mu$ variar? O que temos agora é um sistema com duas EDOs acopladas

$$\dot{x} = \mu + x - x^3;$$
$$\dot{\mu} = \epsilon,$$

em que $\mu$ varia a uma velocidade lenta $\epsilon$. Mas isso ocorre em uma escala de tempo muito mais lenta do que a escala de tempo natural na primeira equação, então $x$ "não vê" a mudança e se mantem próximo da ponto fixo 
$x^* (\mu)$ para o valor atual de $\mu$ (isso está associado com **aproximação adiabática**). Lembre-e que $\mu$ está, de fato, se movendo mesmo que vagarosamente. Assim o valor de $x$ vai se manter próxima a curva de pontos fixos, $x(t) \approx x^*(\mu(t))$, a medida que $\mu$ muda.

Isso ocorre até o valor de $\mu$ atingir o valor crítivo ($\approx \pm 0.4$ dependendo da situação). A partir daí não há mais ponto fixo próximo e a dinâmica de $x$ acelera para convergir ao outro ponto fixo que está distante. 

E se agora revertemos a variação de $mu$, a dinâmica de $x$ irá perseguir o outro ponto fixo.
"""

# ╔═╡ bcce1286-2213-4f25-a947-7a429bd96594
md"""
# 2D: Oscilações em reatores químicos -- o modelo Brusselator
"""

# ╔═╡ 77ae220e-08bd-4808-b1f5-f80397afe9bc
md"""
Bifurcações não ocorrem apenas em 1D. De fato as dinâmicas podem ser muito mais ricas em dimensões maiores. 

Como exemplos, vamos dar uma olhada no [modelo Brusselator](https://en.wikipedia.org/wiki/Brusselator). Ele modela um reação química que **oscila**, chamada de [relógio químico](https://en.wikipedia.org/wiki/Chemical_clock):
"""

# ╔═╡ c48b8097-d81e-43a1-a61f-b2d01edbc8d5
md"""
$$\begin{aligned}
\dot{x} &= a + x^2 y - bx - x \\
\dot{y} &= b x - x^2 y
\end{aligned}$$
"""

# ╔═╡ 6b857cb0-182f-4451-9f5a-e170dae185c1
function brusselator(xx, p, t)
    x, y = xx
    a, b = p

    return [a + x^2 * y - b * x - x, b * x - x^2 * y]
end

# ╔═╡ 77e5ff47-1e95-4552-a3d2-2fdf7bbea7cb
md"""
a = $(@bind a Slider(0.0:0.1:5.0, show_value=true, default=1.0))

b = $(@bind b Slider(0.0:0.1:5.0, show_value=true, default=1.5))
"""

# ╔═╡ e2953d11-6880-45cb-8000-3f6903a85c7d
begin
    u0 = [1, 1]
    tspan = (0.0, 50.0)
    params = [a, b]
end

# ╔═╡ cbb9e351-b496-45cc-8816-519ada1dc5d5
begin
    prob = ODEProblem(brusselator, u0, tspan, params)
    soln = solve(prob)
end;

# ╔═╡ 92aca04d-376f-4ac7-b4c3-5b0652974157
gr(dpi=300)

# ╔═╡ 34556546-0cab-43e2-bc2c-f7487288392c
let
    tspan = (0.0, 10.0)
    params = [a, b]

    p1 = plot(leg=false, background_color_inside=:black)

    for x = 0:1.0:5
        for y = 0:1.0:5
            u0 = [x, y]

            prob = ODEProblem(brusselator, u0, tspan, params)
            soln = solve(prob)


            plot!(
                p1,
                soln,
                idxs=(1, 2),
                xlims=(0, 5),
                ylims=(0, 5),
                ratio=1,
                lw=1.5,
            )
            #	p2 = plot(soln)

            #	plot(p1, p2, ylims=(0, 5))
        end
    end

    # plot direction field:
    xs = Float64[]
    ys = Float64[]

    for x = 0:0.1:5
        for y = 0:0.1:5
            v = brusselator([x, y], params, 0)
            v ./= (norm(v) * 30)
            # plot!([x, x + v[1]], [y, y + v[2]], alpha=0.5, c=:gray)

            push!(xs, x - v[1], x + v[1], NaN)
            push!(ys, y - v[2], y + v[2], NaN)

        end
    end

    plot!(xs, ys, alpha=0.7, c=:gray)

    # as_svg(p1)

    md"""
    #### Trajectories in state space for the Brusselator model

    $(p1)

    """


end

# ╔═╡ c90e3885-33bd-40d2-8a64-946fd7676656
md"""
Como podemos ver, ao variar o parâmetro $b$ o ponto fixo se torna instável gerando a partir de um certo valor uma órbita periódica atratora. Isso é uma [**bifurcação de Hopf**](https://en.wikipedia.org/wiki/Hopf_bifurcation).
"""

# ╔═╡ e01fa79b-e92b-4b77-8234-108839ed2598
md"""
# 3D: Caos nas equações de Lorenz
"""

# ╔═╡ 1d91975b-2644-41da-a2a4-667ae6ed5ca1
md"""
As [equações de Lorenz](https://en.wikipedia.org/wiki/Lorenz_system) são um modelo (muito simplificado) de convecção em uma camada de fluido representando a atmosfera. Ela foi estudada inicialment em um artigo de Edward Lorenz, publicado em 1963, sobre um trabalho feito no MIT.  Elas representam um trabalho pioneiro da investigação numérica de **comportamento caótico**.

As equações de Lorenz são composta de três EDOs acopladas, possuindo uma forma aparentemente simples com apenas dois termos não lineares.
"""

# ╔═╡ d99002e1-02ca-45bd-ba26-581f7f1b4fe8
md"""
$$\begin{align}
\dot{x} &= \sigma (y - x) \\[6pt]
\dot{y} &= x (\rho - z) - y \\[6pt]
\dot{z} &= x y - \beta z
\end{align}$$
"""

# ╔═╡ 64642233-3331-40ea-929b-be5daa933393
md"""
Mesmo assim, veremos que elas podem apresentar um comportamento bastante complexo. De fato, muitas EDOs não lineares com pelo menos três variáveis tende a apresentar comportamento complexo similar.
"""

# ╔═╡ 2228c7f6-8692-487e-bf8a-6600e7e93a06
md"""
Vamos resolver o sistema usando `DifferentialEquations.jl`. Vamos fixas os parâmetros $\sigma = 10$ e $\beta = 8/3$, seus valores clássicos. Já $\rho$ poderá variar, o seu valor clássico é $28$.
"""

# ╔═╡ cfa7b192-f1a0-4cd1-ae34-cec07e7b47f6
function lorenz(u, p, t)
    x, y, z = u
    σ, ρ, β = p

    dx = σ * (y - x)
    dy = x * (ρ - z) - y
    dz = x * y - β * z

    return [dx, dy, dz]
end

# ╔═╡ e068c809-34c6-4723-8ad5-a55918cfed87
md"""
ρ = $(@bind ρ Slider(0.0:0.1:100.0, show_value=true, default=10.0))
"""

# ╔═╡ 58dbd153-09e2-4a38-94c1-9f69acf515ae
lorenz_params = (σ=10.0, ρ=ρ, β=8 / 3)

# ╔═╡ 2e61c129-7fd8-46b6-8480-40f0244aab47
begin
    lorenz_prob = ODEProblem(lorenz, [0.01, 0.01, 0.01], (0.0, 100.0), lorenz_params)

    lorenz_soln = solve(lorenz_prob, Tsit5())
end;

# ╔═╡ 5ffeba9b-8487-4be1-bb64-8d2330824ee5
plot(
    lorenz_soln,
    idxs=(1, 2, 3),
    xlabel="x",
    ylabel="y",
    zlabel="z",
    xlims=(-25, 25),
    ylims=(-25, 25),
    zlims=(0, 60),
)

# ╔═╡ a7f067e4-d088-400b-bba4-d58f9cfb87a8
md"""
A medida que $\rho$ aumenta, vemos uma sequência de bifurcações. Acima de um ponto crítico as trajetórias convergem a um **atrator estranho**, no qual a dinâmica é **caótica**.
"""

# ╔═╡ cc7ee950-6b86-4d43-8524-86254978bd1b
md"""
Caos determinístico ocorre quando condições iniciais próximas se afastam exponencialmente rápido no estado de espaços. É esse fenômeno que é chamado de **efeito borboleta**: uma pertubação no estado da atmosfera causado pelo bater de asas de uma borboleta pode ser amplificado a ponto de modificar a direção na qual um tornado se move.

Podemos ver isso perturbando pouco a condição inicial e calculando a distância entre as duas soluções como função de $t$:
"""

# ╔═╡ aebdd083-4f70-4490-9949-8fe5c1cb2e1e
begin
    ϵ = 1e-10

    lorenz_prob2 =
        ODEProblem(lorenz, [0.01 + ϵ, 0.01 + ϵ, 0.01 + ϵ], (0, 50.0), lorenz_params)

    lorenz_soln2 = solve(lorenz_prob2, Tsit5())
end;

# ╔═╡ f44c9f92-aacd-4556-b494-8ee874387e5d
begin
    ts = 0:0.01:50
    distances = [norm(lorenz_soln2(t) - lorenz_soln(t)) for t in ts]
    plot(ts, distances, yscale=:log10, label="distance", xlabel="t", leg=:topleft)
end

# ╔═╡ 0b1b4e0e-d146-4c94-bfee-3d0a50323d0b
md"""
Observe que há um trecho significativo que a distância cresce exponencialmente (que fica evidenciada por subidas lineares em escala semi-log) para valores grandes de $\rho$, até que o valor se estabiliza em algo que é da ordem do diâmetro do atrator.

A taxa de crescimento exponencial é conhecida como **expoente de Lyapunov**. Há formas melhores de estimá-lo com mais precisão do que essa que usamos em nossa visualização.
"""

# ╔═╡ b8423240-1761-490d-a856-f722714cc763
md"""
Como as equações de Lorenz modelam a atmosfera de forma simplificada, é natural esperar que a dinâmica real da atmosfera seja pelo menos tão complicada quanto a dinâmica observada.
"""

# ╔═╡ 8eb1c83e-18f2-497a-94fd-a4abe11beed3
md"""
Nós também podemos comparar a coordenada x de cada trajetória para comparação.
"""

# ╔═╡ 3188c2ca-ab8f-45a9-bcbc-10159659a9d4
begin
    plot(lorenz_soln, idxs=1, label="original", size=(500, 300), leg=:topleft)
    plot!(lorenz_soln2, idxs=1, label="perturbed")
    ylabel!("x(t)")
end

# ╔═╡ 75f3d63d-aa5d-46ce-824c-72153623d2c5
md"""
Para tempos longos, as trajetórias se separam e se comportam de forma muito diferente.
"""

# ╔═╡ 019be011-51ed-4997-8e8e-1035c109efe7
md"""
Por fim, vamos olhar o "clima" presente nesse modelo, ou seja vamos olhar estatísticas como a média das coordenadas ao longo do tempo.
"""

# ╔═╡ 5c27ade2-5983-4332-9097-20efb20504bc
begin
    T = 1000.0

    lorenz_prob3 = ODEProblem(lorenz, [0, 1 + ϵ, 1 + ϵ], (0.0, T), lorenz_params)

    lorenz_soln3 = solve(lorenz_prob3, Tsit5())

    lorenz_prob4 = ODEProblem(lorenz, [1, 1, 1], (0.0, T), lorenz_params)

    lorenz_soln4 = solve(lorenz_prob4, Tsit5())
end;

# ╔═╡ 043c35e5-bf4b-445a-b746-9030b96033ca
mean(abs.(lorenz_soln3(t)) for t = T/2:T)

# ╔═╡ d9b34169-85a2-4f97-a7e3-a2ed67ee205a
mean(abs.(lorenz_soln4(t)) for t = T/2:T)

# ╔═╡ 02f295ba-6bb1-41ca-9581-af33766241a4
md"""
Como podemos ver a média de cada componente é aproximadamente a mesma, apesar das trajetórias individuais serem muito diferentes. Este é um exemplo em que as propriedades estatísticas podem ser muito semelhantes, mesmo que o comportamento individual seja muito distinto. Isso motiva a noção de clima -- i.e. "o tempo médio" -- ele pode ser estável, mesmo que a variação a cada dia oscile muito.
"""

# ╔═╡ d0918f0c-22d4-11eb-383a-553e33114c52
md"""
# Function library
"""

# ╔═╡ 319c2ba8-220e-11eb-1ee0-4dd51ff4cd25
euler_step(f, x, h) = x + h * f(x)

# ╔═╡ 42de6dd6-220e-11eb-2a48-a3c69b10a03b
function euler(f, x0, h, t_final)
    ts = [0.0]
    xs = [x0]

    x = x0
    t = 0.0

    while t < t_final
        x = euler_step(f, x, h)
        t += h

        push!(xs, x)
        push!(ts, t)
    end

    return (ts=ts, xs=xs)  # a named tuple
end

# ╔═╡ 6e90ea26-220e-11eb-0c65-bf52b3d2e195
results = euler(logistic, 0.5, 0.01, 20.0)

# ╔═╡ 96e22792-220e-11eb-2729-63964507b5f2
begin
    plot(
        results.ts,
        results.xs,
        size=(400, 300),
        leg=false,
        xlabel=L"t",
        ylabel=L"x(t)",
        lw=3,
    )
    scatter!([(results.ts[1], results.xs[1])])
    ylims!(0.4, 1.1)
end

# ╔═╡ 2300b29a-22d5-11eb-3c99-bdec0e5a2685
let
    p = plot(xlabel=L"t", ylabel=L"x(t)", leg=false, ylim=(-1, 2))

    results = euler(logistic, x0, 0.01, 5.0)

    plot!(results.ts, results.xs, alpha=1, lw=3)
    scatter!([0.0], [x0])

    hline!([0.0], ls=:dash)
    # as_svg(p)
end


# ╔═╡ c5bf15b1-a540-478b-acec-1aa47aad13d1
let
    p = plot(xlabel=L"t", ylabel=L"x(t)", leg=false, ylim=(-1, 2))

    # for x0 in -0.5:0.05:2.0
    #for x0 in 0.0:0.1:2.0
    for x0 = -0.5:0.1:2.0
        results = euler(logistic, x0, 0.05, 5.0)

        # 	for x0 in -0.5:0.05:2.0
        # 		results = euler(logistic, x0, 0.01, 10.0)	

        plot!(p, results.ts, results.xs, alpha=0.8, lw=1, arrow=true)
    end


    md"""
    #### Trajectories for $ẋ = x(1-x)$ 

    $p

    """
end

# ╔═╡ 546168ce-2218-11eb-198b-1da9f8a9a242
derivative(f, x, h=0.001) = (f(x + h) - f(x - h)) / (2h)

# ╔═╡ 46f1e3a2-2217-11eb-184f-f5649b892004
"Draw 1D vector field using centred arrows"
function horiz_vector_field(f)

    xlo, xhi = -2, 2.5
    arrow_size = 0.07
    tol = 1e-5  # tolerance to check for fixed point

    p = plot(
        size=(400, 100),
        xlim=(xlo, xhi),
        ylim=(-0.5, 0.5),
        leg=false,
        yticks=[],
    )

    for x = xlo:0.2:xhi
        d = f(x)  # derivative

        if d > tol
            plot!(
                [x - arrow_size, x + arrow_size],
                [0, 0],
                arrow=true,
                c=:blue,
                alpha=0.5,
                lw=1.5,
            )

        elseif d < -tol
            plot!(
                [x + arrow_size, x - arrow_size],
                [0, 0],
                arrow=true,
                c=:red,
                alpha=0.5,
                lw=1.5,
            )

        end


    end

    roots = find_zeros(f, -10, 10)

    for root in roots
        stability = sign(derivative(f, root))

        if stability > 0
            scatter!([root], [0], c=:green, alpha=0.5, m=:square, ms=5)  # unstable
        else
            scatter!([root], [0], c=:black, alpha=0.5, ms=6)  # stable
        end

    end

    p
end

# ╔═╡ 2b1b49b0-2247-11eb-1d25-57f3b4f46d04
"Draw vertical vector field of 1D ODE on plot p with parameter μ"
function vector_field!(p, μ, f)

    xlo, xhi = -2, 2
    arrow_size = 0.07
    tol = 1e-5  # tolerance to check for fixed point

    for x = xlo:0.2:xhi
        d = f(x)  # derivative

        if d > tol

            plot!(
                [μ, μ],
                [x - arrow_size, x + arrow_size],
                arrow=(3.0, 2.0),
                arrowstyle=:triangle,
                c=:blue,
                alpha=0.4,
                lw=1.5,
            )

        elseif d < -tol
            plot!(
                [μ, μ],
                [x + arrow_size, x - arrow_size],
                arrow=true,
                c=:red,
                alpha=0.4,
                lw=1.5,
            )
        end

    end

    roots = find_zeros(f, -10, 10)

    for root in roots
        stability = sign(derivative(f, root))

        if stability > 0
            scatter!([μ], [root], c=:green, alpha=0.5, m=:square, ms=2)  # unstable
        else
            scatter!([μ], [root], c=:black, alpha=0.5, ms=3)  # stable
        end

    end

    p
end

# ╔═╡ d4fa7bec-2371-11eb-3e9f-69d552546331
function vector_field(f)
    p = plot(leg=false, xticks=[], xrange=(-1, 1), size=(100, 200))
    vector_field!(p, 0, f)
end

# ╔═╡ 9a833edc-2217-11eb-0701-99862b410bfa
vector_field(logistic)

# ╔═╡ 25578fa6-2248-11eb-2838-57fbfb928fc4
begin
    vector_field(x -> g(λ, x))
end

# ╔═╡ e55d2780-2247-11eb-01e0-fbdc94bba264
function bifurcation_diagram(h)
    p = plot(leg=false, ratio=1)

    for μ = -2:0.15:2
        vector_field!(p, μ, x -> h(μ, x))
    end

    xlabel!("μ")
    ylabel!("fixed points and dynamics with given μ")

    return p
end

# ╔═╡ b9ee4db4-22d7-11eb-38ef-511e30df16cc
bifurcation_diagram(g)

# ╔═╡ f040d1c4-2247-11eb-0bf0-090e90a86a85
bifurcation_diagram(h)

# ╔═╡ e27dace4-2248-11eb-2ae1-953639d8c944
function fixed_points(f)
    p = plot(leg=false, ratio=1)

    for μ = -2:0.01:2

        roots = find_zeros(x -> f(μ, x), -10, 10)

        for root in roots
            stability = sign(derivative(x -> f(μ, x), root))

            if stability > 0
                scatter!([μ], [root], c=:green, alpha=0.5, m=:square)  # unstable
            else
                scatter!([μ], [root], c=:black, alpha=0.5)  # stable
            end
        end

    end

    xlabel!(L"\mu")
    ylabel!(L"x^*(\mu)")


    return p
end

# ╔═╡ 0c3c88fe-2249-11eb-03af-bf9c393fadd4
fixed_points(h)

# ╔═╡ Cell order:
# ╟─b88f370f-d7d6-4eb1-939f-587a3219d42c
# ╠═88b46d2e-220e-11eb-0f7f-b3f523f0214e
# ╟─f9dbf2e8-574d-4846-af48-f7e5a82a1afc
# ╟─a2b2eae2-762e-41c3-a546-0caedc79db7d
# ╟─91b34e59-e4d2-45b7-9e2b-1b95748e5d6a
# ╟─22bddfca-fd1c-4dc7-85f3-f864c3b53407
# ╟─6f554dc0-220c-11eb-341f-1b66de841c86
# ╟─2c6f4b31-2f08-4e24-8e31-ad80d2700fa8
# ╠═822c015a-8bb3-4432-a2d4-2e2ba4f906a6
# ╟─816de40c-220c-11eb-2d3a-23e6267cd529
# ╟─d21f6358-220c-11eb-00b8-03fe0746fdc9
# ╟─735bb47e-220d-11eb-1ba6-8d591a935857
# ╟─79b148b6-220d-11eb-2785-25d05068aeed
# ╟─d43a869e-220d-11eb-009c-a119de57e7da
# ╟─088eabb2-220e-11eb-1ac0-df419b87f39a
# ╟─a44cc180-22d4-11eb-2129-211d024c4921
# ╟─57566646-1b4c-4098-abf7-eb242d01ca81
# ╠═6aa1d2f4-220e-11eb-06e0-c346f74aa018
# ╟─b6d0dd18-22d4-11eb-2083-0b02de030579
# ╠═6e90ea26-220e-11eb-0c65-bf52b3d2e195
# ╟─2d1c6abf-3b15-4638-88c5-89b5d0585c98
# ╟─f055be76-22d4-11eb-268a-bf70c7d8f1a1
# ╟─96e22792-220e-11eb-2729-63964507b5f2
# ╟─90ccb392-2216-11eb-1fd8-83b7d7c16b54
# ╠═0bf302de-4a0f-4341-b010-d3606e237acc
# ╟─bef9c2e4-220e-11eb-24d8-bd618d2985ea
# ╟─17317eb8-22d5-11eb-0f46-2bf1bddd36bb
# ╟─2300b29a-22d5-11eb-3c99-bdec0e5a2685
# ╟─ae862e10-22d5-11eb-3d75-1d748cf86944
# ╟─c5bf15b1-a540-478b-acec-1aa47aad13d1
# ╟─446c564e-220f-11eb-191a-6b419e790f3f
# ╟─38894c32-2210-11eb-26ff-d9796edd7871
# ╟─a196a20a-2216-11eb-11f9-6789bb2a3ece
# ╟─c15a53e8-2216-11eb-1460-8510aea0f570
# ╠═9a833edc-2217-11eb-0701-99862b410bfa
# ╟─42c28b16-2218-11eb-304a-e534353fa12b
# ╟─e6ed3366-2246-11eb-3a86-f375162c746d
# ╟─ec3c5d9c-2246-11eb-1ec5-e3d9c8a7fa23
# ╠═3fa21738-2247-11eb-09d5-4dcf0e7377fc
# ╟─19eb987e-2248-11eb-2982-1930b5840aed
# ╠═25578fa6-2248-11eb-2838-57fbfb928fc4
# ╟─49ec803a-22d7-11eb-3f04-db8f8c119a7d
# ╠═b9ee4db4-22d7-11eb-38ef-511e30df16cc
# ╟─27190ac0-230b-11eb-3367-af2bbbf57e5e
# ╟─48ef665e-22d0-11eb-2c72-b722fafd296e
# ╟─51eeb46c-22d0-11eb-1643-c92e725d9da0
# ╠═44c1738a-2247-11eb-3232-f30b46fd7ce6
# ╟─7a94642e-39d8-480d-9516-d11e6c1b078b
# ╠═f040d1c4-2247-11eb-0bf0-090e90a86a85
# ╟─a56ad0bc-22d7-11eb-0418-d36f3ef14109
# ╟─5b9c66ce-224b-11eb-02a4-b9a5a173ee6a
# ╠═0c3c88fe-2249-11eb-03af-bf9c393fadd4
# ╟─aa81663c-230b-11eb-3c0e-39759f36deb6
# ╟─55d4d188-2249-11eb-0c47-dfddce9b2027
# ╟─5ac33518-2249-11eb-2d57-7de185d43e5f
# ╟─4c73705e-230c-11eb-3c90-b14536d78808
# ╟─2ced9e26-22d0-11eb-34a5-bf80822f5c43
# ╟─3213d406-22d0-11eb-0e89-71b42ea5cada
# ╟─bcce1286-2213-4f25-a947-7a429bd96594
# ╟─77ae220e-08bd-4808-b1f5-f80397afe9bc
# ╟─c48b8097-d81e-43a1-a61f-b2d01edbc8d5
# ╠═6b857cb0-182f-4451-9f5a-e170dae185c1
# ╠═e2953d11-6880-45cb-8000-3f6903a85c7d
# ╠═cbb9e351-b496-45cc-8816-519ada1dc5d5
# ╟─77e5ff47-1e95-4552-a3d2-2fdf7bbea7cb
# ╠═92aca04d-376f-4ac7-b4c3-5b0652974157
# ╠═34556546-0cab-43e2-bc2c-f7487288392c
# ╟─c90e3885-33bd-40d2-8a64-946fd7676656
# ╟─e01fa79b-e92b-4b77-8234-108839ed2598
# ╟─1d91975b-2644-41da-a2a4-667ae6ed5ca1
# ╟─d99002e1-02ca-45bd-ba26-581f7f1b4fe8
# ╟─64642233-3331-40ea-929b-be5daa933393
# ╟─2228c7f6-8692-487e-bf8a-6600e7e93a06
# ╠═cfa7b192-f1a0-4cd1-ae34-cec07e7b47f6
# ╠═2e61c129-7fd8-46b6-8480-40f0244aab47
# ╠═58dbd153-09e2-4a38-94c1-9f69acf515ae
# ╟─e068c809-34c6-4723-8ad5-a55918cfed87
# ╠═5ffeba9b-8487-4be1-bb64-8d2330824ee5
# ╟─a7f067e4-d088-400b-bba4-d58f9cfb87a8
# ╟─cc7ee950-6b86-4d43-8524-86254978bd1b
# ╠═aebdd083-4f70-4490-9949-8fe5c1cb2e1e
# ╠═f44c9f92-aacd-4556-b494-8ee874387e5d
# ╟─0b1b4e0e-d146-4c94-bfee-3d0a50323d0b
# ╟─b8423240-1761-490d-a856-f722714cc763
# ╟─8eb1c83e-18f2-497a-94fd-a4abe11beed3
# ╠═3188c2ca-ab8f-45a9-bcbc-10159659a9d4
# ╟─75f3d63d-aa5d-46ce-824c-72153623d2c5
# ╟─019be011-51ed-4997-8e8e-1035c109efe7
# ╠═5c27ade2-5983-4332-9097-20efb20504bc
# ╠═043c35e5-bf4b-445a-b746-9030b96033ca
# ╠═d9b34169-85a2-4f97-a7e3-a2ed67ee205a
# ╟─02f295ba-6bb1-41ca-9581-af33766241a4
# ╟─d0918f0c-22d4-11eb-383a-553e33114c52
# ╠═319c2ba8-220e-11eb-1ee0-4dd51ff4cd25
# ╠═42de6dd6-220e-11eb-2a48-a3c69b10a03b
# ╠═546168ce-2218-11eb-198b-1da9f8a9a242
# ╠═46f1e3a2-2217-11eb-184f-f5649b892004
# ╠═2b1b49b0-2247-11eb-1d25-57f3b4f46d04
# ╠═d4fa7bec-2371-11eb-3e9f-69d552546331
# ╠═e55d2780-2247-11eb-01e0-fbdc94bba264
# ╟─e27dace4-2248-11eb-2ae1-953639d8c944
