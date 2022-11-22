### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try
            Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value
        catch
            b -> missing
        end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ e0c0dc94-277e-11eb-379e-83d064a93413
begin
    using PlutoUI
    using LinearAlgebra
    using Plots
    gr()
end

# ╔═╡ 5648fa26-da0b-41d9-b13f-debd4e0485af
TableOfContents(; title="📚 Índice", indent=true, depth=4, aside=true)

# ╔═╡ 00877a4a-277c-11eb-3ec0-e71e4094b404
md"""
# Evolução no tempo e no espaço: advecção e difusão em 1D
"""

# ╔═╡ 1b25b916-277c-11eb-0274-4b4fb946258d
md"""
Até o momento estamos estudando dinâmicas no tempo, por exemplo, como a temperatura da Terra varia (ao longo do tempo). Mas a Terra não possui uma única temperatura uniforme. Ao invés disso, a cada instante do tempo diferentes locais no globo estão em diferentes temperaturas e essas temperaturas variam no tempo guiadas por vários mecanismos. 

Neste caderno vamos analisar dois mecanismos fundamentais: **advecção** e **difusão**. Vamos pensar na temperatura do oceano. Como o oceano é um fluido que está em movimento, uma porção quente de água pode se deslocar para uma nova posição devido ao movimento físico da água; isso é **advecção**. E, mesmo que a água não se mova, a temperatura ou uma alta concentração de uma substância dissolvida em um líquido pode se "espalhar" usado outros mecanismos moleculares. Isso é a **difusão**.
"""

# ╔═╡ 956f5104-277d-11eb-291d-1faef485a5aa
md"""
Por enquanto, vamos nos restringir a uma dimensão espacial (1D). Então, vamos pensar na temperatura, por exemplo, como uma função $T(t, x)$ de duas variáveis independentes:

- tempo, $t$;
- espaço, $x$.

Nós queremos calcular o valor da temperatura $T$ para cada possível par de valores $(t, x)$, ou seja para todo tempo ($> 0$) e todas as posições.

A temperatura em cada ponto irá variar de acordo com dois processos físicos diferentes. Vamos modelar isso escrevendo equações que descrevem cada um desses processos físicos e como eles afetam a temperatura. Como há *duas* variáveis independentes, $t$ e $x$, podemos antever que vamos usar derivadas com relação *a nessas duas* variáveis. Desse modo, a taxa de variação da temperatura no tempo em um determinado ponto no espaço irá depender ter de gradientes da temperatura *no tempo e no espaço*. Isso vai levar a **equações diferenciais parciais** que criam relações entre as derivadas *parciais* de $T$.

No contexto de modelagem climática, podemos pensar no $x$ como sendo a **latitude**, imaginando que a temperatura é a igual em todos os pontos de mesma latitude. Nesse modelo, poderíamos capturar o fato que os polos são mais frios que o equador e considerar o fluxo de calor das regiões quentes para as mais frias.

Entretanto, é claro que não seremos capazes de modelar correntes reais do oceano dessa forma. Isso exige modelos bi ou mesmo tridimensionais.
"""

# ╔═╡ b12e76db-1a18-465a-8955-dab29dfde611
md"""
## Visualizando advecção e difusão
"""

# ╔═╡ c14470f2-d8a4-4d34-8470-09842b2576a3
md"""
Aqui está uma visualização dos processos físicos de advecção e difusão em uma dimensão que nós iremos discutir e modelar neste caderno.
"""

# ╔═╡ b04a6f81-3ece-4521-b141-a2e416718948
md"""
U = $(@bind UU Slider(-1:0.01:1, show_value=true, default=0))

D = $(@bind DD Slider(-0.2:0.001:0.2, show_value=true, default=0))
"""

# ╔═╡ 36328b70-277d-11eb-02c7-2f854c1466cc
md"""
# Perfis de temperatura de discretização
"""

# ╔═╡ 42190984-277d-11eb-1ac2-7d84516c3269
md"""
Uma equação diferencial necessita de um valor inicial para cada variável. Analogamente, agora vamos precisar de uma *função* inicial $T_0(x)$ que nos dá a temperatura em cada posição $x$ no instante 0. Vamos considerar que essa posição está restrita a um intervalo $[0, L_x]$. 

Vamos representar uma função contínua no computador discretizando-o de algum modo. Isso está relacionando com a forma de solução numérica de equações diferenciais. Ou seja, vamos ter que aproximar essa função contínua por um conjunto finito de números. 

A forma mais simples de fazer isso (há outras) é **amostrar** o valor da função em pontos discretos de uma **malha** (ou **nós**) $x_i$, para $i = 1, \dots, N_x$. Por simplicidade, vamos tomar esses pontos equiespaçados, com espaçamento $x_{i+1} - x_i =: \delta x := L_x / N_x$.
"""

# ╔═╡ d2bed768-277e-11eb-32cf-41f1fedec3cb
md"""
Por exemplo, vamos considerar o perfil de temperatura inicial a seguir:
"""

# ╔═╡ e6493da0-277e-11eb-22ff-29752652b576
T₀(x) = sin(2π * x) + 2 * cos(4π * x) + 0.2

# ╔═╡ 0d6271c0-286c-11eb-1c9c-3ba039b49d24
md"""
e definir os pontos da malha por:
"""

# ╔═╡ f17f7734-277e-11eb-25cf-5f2ba2db5aa3
begin
    Nₓ = 20
    Lₓ = 1.0
    δx = Lₓ / Nₓ
    xs = (δx/2):δx:Lₓ
end

# ╔═╡ fa327c08-286b-11eb-0032-2384998a42a8
xs

# ╔═╡ 0db43be2-284c-11eb-2740-4379437fd70c
md"""
Uma boa ideia é tomar os pontos da malha no *centro* de cada intervalo e assim teremos $N_x$ intervalos e $N_x$ pontos na malha. O primeiro é $x_1 = \delta x/2$, continuando até $x_N = L_x - \delta x / 2$.
"""

# ╔═╡ 468a0590-2780-11eb-045c-d1f468fc4e50
md"""
Nós chamamos essa função de $x$ em um instante do tempo de um **perfil de temperatura**. Vamos apresentá-lo tanto como uma função quando com um mapa de calor.
"""

# ╔═╡ af30a0d0-2781-11eb-0274-ab423205facb
md"""
Vamos denotar por $T^0_i$ a temperatura inicial no ponto $i$ da malha.
"""

# ╔═╡ 646bc32e-284c-11eb-2ce8-5f64b1a49534
md"""
Pode ser interessante pensar em $T^n_i$ como uma espécie de média (espacial) de $T(t_n, x)$ nos intervalos de posições que contém os pontos da malha. Assim, $T_i$ seria a média no intervalo entre $x_i - \frac{\delta x}{2}$ and $x_i + \frac{\delta x}{2}$. Isso leva, naturalmente, a seguinte aproximação **constante por partes** da função contínua original:
"""

# ╔═╡ 79ce4b10-284c-11eb-2258-2155f850171d
let
    δx = xs[2] - xs[1]

    p = plot(0:0.001:Lₓ, T₀; label="T₀", lw=1, ls=:dash)
    scatter!(xs, T₀.(xs); label="sampled")
    scatter!(xs, zero.(xs); label="x nodes", alpha=0.5, ms=3, lw=2)

    for i in 1:length(xs)
        plot!(
            [(xs[i] - δx / 2, T₀(xs[i])), (xs[i] + δx / 2, T₀(xs[i]))];
            c=:green,
            lw=4,
            lab=false
        )

        plot!(
            [
                (xs[i] - δx / 2, 0),
                (xs[i] - δx / 2, T₀(xs[i])),
                (xs[i] + δx / 2, T₀(xs[i])),
                (xs[i] + δx / 2, 0),
            ];
            c=:green,
            lw=1,
            lab=false,
            ls=:dash,
            alpha=0.3
        )
    end

    xlabel!("x")
    ylabel!("T₀(x)")
end

# ╔═╡ 2494daaa-2780-11eb-3084-2317924048ea
md"""
# Advecção
"""

# ╔═╡ 29444ffe-2780-11eb-0875-095302b5d486
md"""
Podemos agora pensar nesse perfil como representante da temperatura em cada pequeno volume, ou "parcela", de fluido. Vamos imaginar que o fluido está se movendo para a direita com uma velocidade constante e uniforme $U$ (o **uniforme** no sentido que a velocidade é mesma em *todo* o fluido em um certo instante do tempo). Então, o perfil de temperatura também deveria se *mover com o fluido*! Nós chamamos uma quantidade, como a temperatura, que é carregada com o fluido de um **marcador**.

Se forcarmos em um único ponto fixo no espaço, digamos o ponto da malha $x_i$, a temperatura lá irá variar ao longo do tempo, porque o fluido está se movendo, passando por ele. Essa variação de temperatura depende dos valores nos pontos da malha vizinhos, já que eles definem quanto calor será transportado para essa posição e será removido dela.

[O ponto de vista que fixa a atenção em um único ponto do espaço é chamado de **euleriano**. A alternativa natural é seguir uma parcela particular de fluido que se move pelo espaço. Esse é o ponto de vista **lagrangiano**.]

"""

# ╔═╡ 1dcb9690-6436-49f0-880f-23490fe28ea4
md"""
## Simulando fluxos em um fluido
"""

# ╔═╡ b63bb2e8-1d23-48fb-94b5-60d947465830
md"""
Vamos visualizar o que ocorre quando o fluido se movem atravessando um ponto da malha ou, sendo mais preciso, o intervalo ou célula centrada no ponto escolhido. Vamos visualizar partículas marcadoras se movendo dentro do fluido:
"""

# ╔═╡ e94a90c5-f2c1-4b5b-9946-7869ef7775a6
# Total number of markers
N = 5000

# ╔═╡ dd87fc01-4bf0-44f6-a9f6-560e433754a0
# Place initial particles between  -1.5 and 2 (in x), more concentrated in the 
# beginning
begin
    xx = (abs.(-2 .+ 4 .* rand(N)) .^ 2) .- 1.5
    yy = rand(N)
end

# ╔═╡ 7ae9f5b8-10ea-42a7-aa01-0e04a7287c77
# A time delta to observe
δ = 0.8

# ╔═╡ 2f24e0c7-b05c-4f89-835a-081f8e6107e5
md"""
destaca partículas entrando e saindo em $\delta t$: $(@bind show_particles CheckBox())
"""

# ╔═╡ 75bc87be-2b66-46b5-8de8-428a63655815
md"""
t = $(@bind t Slider(0:0.01:2, show_value=true, default=0))
"""

# ╔═╡ 3437e53b-9dd0-4afe-a1bd-a556871d1799
md"""
## Passos no tempo
"""

# ╔═╡ 65df7158-60dc-4809-82a3-913a79bcfc75
md"""
Nós queremos modelar como o perfil de temperatura muda no tempo devido a fluxo do fluido. Faremos isso olhando cada célula e perguntando quanto calor entra e sai de cada uma delas em um passo de tempo, de duração $\delta t$.
"""

# ╔═╡ 7256778a-2785-11eb-0369-f3b43d5dd203
md"""
Vamos chamar $T^n_i$ o valor médio (desconhecido) da temperatura $T$ na célula associada à posição $x_i$ no $n$-ésimo passo de tempo $t_n$. Ela é uma aproximação de $T(t_n, x_i)$, em que $t_n = n \, \delta t$. 

Então, 

$$T^{n+1}_i \simeq T(t_n + \delta t, x_i)\ \ \text{e}\ \ T^{n}_{i+1} \simeq T(t_n, x_i + \delta x).$$

[Observe que os super-escritos $n$ nesses algoritmos não representam potências. Eles são apenas um rótulo para o passo no tempo. Poderíamos uma notação mais pesada, como  $T_i^{(n)}$, mas isso sobrecarrega a escrita e iremos usar a forma sem parênteses.]
"""

# ╔═╡ 44433a34-2782-11eb-0079-837c9306c5bd
md"""
Suponha que o fluido está se movendo para direita com velocidade $U$. Durante um passo de tempo de duração  $\delta t$, a temperatura $T^n_i$  na célula $i$ muda por dois motivos:

- Calor entra $i$.
- Além disso, calor sai da célula $i$.

Observe que a maior parte do fluido que começa na célula $i$ permanece lá durante um passo de tempo(se ele for curto o suficiente), como vimos na visualização acima.

Para calcular quanto calor entra e sai, começamos observando que apenas o calor de regiões do fluido que estão a uma distância $U \, \delta t$ da fronteira da célula vão cruzá-la.

[Aqui não vamos tentar distinguir a diferença que há entre "quantidade de calor" e "temperatura".]

Assim, grosseiramente, uma quantidade de  $T^n_i (U \delta t) / \delta x$ vai sair da célula $i$ e cruzar a fronteira para a célula $i + 1$ (a célula da direita). De maneira análoga, uma quantidade $T^n_{i - 1} (U \delta t) / \delta x$ vai *entrar* na célula $i$ vinda da célula vizinha $i - 1$ que se encontra à esquerda.

Assim chegamos a 

$$T^{n+1}_i = T^{n}_i + (T^n_{i - 1} - T^n_{i})\, U \, \delta t / \delta x.$$

Observe que o lado direito da equação se refere à quantidades no passo de tempo $n$. Já o lado esquerdo refere-se ao passo de tempo $n + 1$. Então, essa equação nos ensina como *atualizar* as quantidades do trecho de tempo $n$ para o trecho $n + 1$.
"""

# ╔═╡ 87e2be25-227c-498c-94fa-6e404c8918f1
md"""
## Limite contínuo: a EDP de advecção
"""

# ╔═╡ 72c0ab0c-2781-11eb-1f59-9b22a52b0be0
md"""
Reorganizando a equação anterior, obtemos

$$\frac{T^{n+1}_i - T^{n}_i}{\delta t} =  \frac{T^n_{i-1} - T^n_{i}}{\delta x}\,  U.$$
"""

# ╔═╡ e5761990-278b-11eb-134e-7954b577b1ac
md"""
Tomando o limite quando  $\delta t \to 0$ e $\delta x \to 0$, encontramos a definição de **derivadas parciais** com relação ao espaço e tempo de Cálculo 2 (note que índices diferentes mudam de um lado e de outro da equação). 

Usando a notação usual para denotar derivadas parciais, chegamos à **equação de advecção**:

$$\frac{\partial T(t, x)}{\partial t} = -U \frac{\partial T(t, x)}{\partial x},$$

ou, sem explicitar as variáveis independentes,

$$\frac{\partial T}{\partial t} = -U \frac{\partial T}{\partial x}.$$

Como $T$ é uma função de ambos $x$ e $t$, essa equação usa derivadas parciais com respeito às duas variáveis independentes. Isso é uma equação diferencial parcial (EDP). Ela descreve como a função $T(t, x)$ varia continuamente em função de ambos espaço e tempo. 

Apesar de existirem alguns métodos analíticos para resolver EDPs, normalmente é necessário empregar métodos numéricos. Vamos ver alguns métodos simples para resolver esse tipo de equação.
"""

# ╔═╡ 2033364e-278c-11eb-2936-17598ce14a41
md"""
## Métodos numéricos para equação de advecção
"""

# ╔═╡ e9a37908-278c-11eb-278e-9bd155f0cae6
md"""
Vamos agora retomar a versão da equação discreta que isola o valor da temperatura no passo de tempo *seguinte* 

$$T^{n+1}_i = T^{n}_i - (T^n_{i} - T^n_{i-1}) \left( U \frac{\delta t}{\delta x} \right).$$

No último termo do lado direito vemos que é necessário combinar valores de $T$ no mesmo instante mais em locais diferentes usando coeficientes específicos.
"""

# ╔═╡ bcf1ceca-f557-4d75-9058-bbaa58665fb7
md"""
Há várias formas de se implementar isso numericamente. A mais simples é transcrever a equação diretamente a partir da $i$-ésima entrada do vetor.

Chamando de `T` o vetor atual, ou seja, $\mathbf{T}^n := (T^n_i)_{i=1, \ldots, N_x}$, e `T′` o novo vetor no próximo passo de tempo, chegamos a seguinte expressão:

	T′[i] = T[i] + δt * U * (T[i-1] - T[i]) / δx


Mas agora aparece um problema novo: o que fazer com a posição $i = 1$? Nesse caso, ocorrerá uma tentativa de indexar o vetor `T` na posição 0 e ela não existe!
"""

# ╔═╡ 3736a25e-4dec-46ac-9bf6-9712e3d00e7a
md"""

### Condições de fronteira

Esse fenômeno ilustra a necessidade de se definir **condições de fronteira** que determinam o que ocorre nos limites do domínio.

Por simplicidade, vamos empregar **condições periódicas de fronteira**. Essa é uma abstração matemática que nos permite tratar todas as células igualmente ao considerar que o domínio em um toro de modo que as células $i = 1$ e $i = N_x$ torna-se vizinhas. Ela também é bastante natural no cotexto de modelagem climática já que o espaço aqui representa latitudes. 
"""

# ╔═╡ e542a8da-284e-11eb-3297-6bbbf052284b
md"""
Isso pode ser implementado da seguinte maneira, em que tratamos separadamente o caso especial $i=1$:
"""

# ╔═╡ b15f4f44-284b-11eb-37c5-ab0153f7fe92
function advection(T, δt, δx, U)
    N = length(T)
    T′ = similar(T)  # create new vector of the same length

    # bulk cells:
    for i in 2:N
        T′[i] = T[i] - δt * U * (T[i] - T[i-1]) / δx
    end

    # boundary cells:
    T′[1] = T[1] - δt * U * (T[1] - T[N]) / δx   # periodic

    return T′
end

# ╔═╡ fcbec610-d9fc-4e41-8e76-729dbbc61d92
md"""
Essa equação executa um passo temporal da equação de advecção, recebendo o vetor $T$ original e devolvendo o vetor no próximo passo de tempo $T'$.

Observe que a ideia fundamental que empregamos aqui é semelhante àquela do método de Euler usada na resolução de EDOs. Mas agora há várias variáveis para atualizar ao mesmo tempo já que, efetivamente, estamos resolvendo um grande sistemas de EDOs acopladas".
"""

# ╔═╡ af79e360-286e-11eb-2a4d-3d6d7564088c
begin
    # Time step
    δt = 0.001
    # Constant velocity
    U = 0.2
end;

# ╔═╡ addab3e6-f189-41d6-badb-92f0323b6192
# assign colors to particles that will enter and leave between 0 ... δ
cs = map(xx) do x
    if -U * δ < x < 0
        1
    elseif 1 - (U * δ) < x < 1
        2
    else
        0
    end
end

# ╔═╡ f684dd94-f1c7-4f79-9776-3a06b8eec39b
begin
    plot(
        [0, 1, 1, 0, 0],
        [0, 0, 1, 1, 0];
        series=:shape,
        alpha=0.5,
        fill=true,
        ratio=1,
        label=false,
        leg=false
    )

    new_xx = xx .+ U .* t

    scatter!(xx .+ U .* t, yy; ms=1.5, alpha=0.1, c=:gray)

    if show_particles
        scatter!(new_xx[cs.!=0], yy[cs.!=0]; ms=1.5, alpha=0.5, c=cs[cs.!=0])
    end

    plot!([-1.5, 2], [0, 0]; c=:black)
    plot!([-1.5, 2], [1, 1]; c=:black)

    xlims!(-2, 2)
    ylims!(-0.1, 1.1)

    as_svg(plot!(; axis=true, yticks=[0, 1]))
end

# ╔═╡ 8c05e3cc-2858-11eb-1e1c-9781c30738c3
md"""
Infelizmente *não* obtemos o efeito esperado: ao invés de preservar o formato do perfil ao longo do tempo, a tentativa de solução da equação está fazendo ele decair. Isso ocorre porque estamos usando uma aproximação ruim (lembre estamos usando uma técnica análoga a Euler).

Uma forma melhor de discretização pode ser obtida usando **diferenças centradas** que você deve ter visto em um curso de cálculo numérico.

$$\frac{\partial T(t_n, x_i)}{\partial x} \simeq \frac{T^n_{i+1} - T^n_{i-1}}{2 \delta x}$$
"""

# ╔═╡ a29fecac-285a-11eb-14b0-9313f8994fbb
function advection2(T, δt, δx, U)
    N = length(T)
    T′ = similar(T)  # create new vector of the same length

    for i in 2:(N-1)
        T′[i] = T[i] - δt * U * (T[i+1] - T[i-1]) / (2δx)
    end

    # periodic boundary:
    T′[1] = T[1] - δt * U * (T[2] - T[N]) / (2δx)
    T′[N] = T[N] - δt * U * (T[1] - T[N-1]) / (2δx)

    return T′
end

# ╔═╡ 5232b7cc-6fb9-4ed8-beb2-79c32cd1c35a
md"Bem melhor!"

# ╔═╡ c59388ea-286e-11eb-0f21-eb18e5ba516f
md"""
# Difusão
"""

# ╔═╡ 3c944998-2888-11eb-087d-492b9d0ee32e
md"""
Outro processo físico fundamental é a **difusão**. Ele modela como temperatura ou uma concentração diluída (de algum material) se espalha de uma região quente ou com alta concentração para regiões mais frias ou com baixa concentração.

## Mecanismo físico: passeios aleatórios

O mecanismo físico por trás desse fenômeno é o **passeio aleatório browniano**: o limite contínuo de equações descrevendo a evolução da distribuição de probabilidade no espaço e tempo de uma nuvem de andarilhos aleatórios.

Esse é o processo que já vimos antes no curso. Usando nossa notação atual, já vimos que a distribuição de probabilidade de uma nuvem de andarilhos aleatórios satisfaz uma evolução temporal do tipo

$$p^{n+1}_i = \frac{1}{2}(p^n_{i-1} + p^n_{i+1})$$

Se agora considerarmos que os andarilhos transitam apenas com uma certa probabilidade, e possuem uma probabilidade mais alta de permanecer no local, e que esses andarilhos são os responsáveis por transportar o calor chegamos a

$$T^{n+1}_i = \kappa (T^n_{i-1} - 2 T^n_i + T^n_{i+1}).$$

Veja [esse vídeo](https://www.youtube.com/watch?v=a3V0BJLIo_c) de uma versão anterior do curso original do MIT para ver o Grant Sanderson explicando esse fenômeno.
"""

# ╔═╡ 6ac74e34-ed58-4903-8c53-82be13b6c21f
md"""
## O limite contínuo: a equação do calor
"""

# ╔═╡ de42149c-85ce-4e73-8503-84f64a173cbb
md"""
Introduzindo o passo de discretização espacial $\delta x$ e o passo de tempo $\delta t$ chegamos em 

$$T^{n+1}_i = \kappa \frac{\delta t}{\delta x^2}  (T^n_{i-1} - 2 T^n_i + T^n_{i+1}).$$

"""

# ╔═╡ ef42d541-74a1-433a-9773-5e6cca525350
md"""
O limite contínuo é conhecido como **equação do calor** ou **equação de difusão**:
"""

# ╔═╡ 6b7cea44-2888-11eb-0208-990860d6a152
md"""
$$\frac{\partial T}{\partial t} = \kappa \frac{\partial^2 T}{\partial x^2}.$$
"""

# ╔═╡ 83a1e1f5-0946-422c-83f4-d7a19e9c0789
md"""
A constante $\kappa$ é conhecida como **difusividade térmica**, que diz o quão rapidamente o calor se propaga no meio. Já no contexto de difusão de concentração de massa, a contante é conhecida como $D$, o **coeficiente de difusão**."""

# ╔═╡ 68db3372-2888-11eb-1b03-b5ebca4c2bd5
md"""
Para obter um método numérico para resolver essa equação, temos que discretizá-la mais uma vez. Em particular temos que discretizar a segunda derivada. Uma possível discretização é (lembre foi dela que partimos antes de tomar o limite e chegar na versão contínua):

$$\frac{\partial^2 T}{\partial x^2}(t_n, x_i) \simeq \frac{T^n_{i+1} - 2 T^n_i + T^n_{i-1}}{\delta x^2}.$$
"""

# ╔═╡ d6131ad0-2889-11eb-3085-15d17e33ee7a
md"""
Ela também pode ser diretamente transportada para o código:
"""

# ╔═╡ 630314bc-2868-11eb-1b93-b7b08a4b2887
function diffusion(T, δt, δx, D)
    N = length(T)
    T′ = similar(T)  # create new vector of the same length

    for i in 2:(N-1)
        T′[i] = T[i] + δt * D * (T[i+1] - 2T[i] + T[i-1]) / (δx^2)
    end

    # periodic boundary:
    T′[1] = T[1] + δt * D * (T[2] - 2T[1] + T[N]) / (δx^2)
    T′[N] = T[N] + δt * D * (T[1] - 2T[N] + T[N-1]) / (δx^2)

    return T′
end

# ╔═╡ e63cfa84-2889-11eb-1ea2-51726645ddd9
md"""
# A EDP advecção-difusão
"""

# ╔═╡ eee3008e-2889-11eb-088a-73aff304e736
md"""
Agora podemos combinar os dois mecanismos e descrever um marcador que está ao mesmo tempo sofrendo advecção a uma velocidade constante e difusão. Isso é feito, basicamente, compondo as funções de advecção e difusão. 
"""

# ╔═╡ ffd2a838-2889-11eb-1a7c-b35992543b8a
function advection_diffusion(T, δt, δx, (U, D))
    temp = advection2(T, δt, δx, U)
    return diffusion(temp, δt, δx, D)
end

# ╔═╡ 575a5f3c-2780-11eb-2119-27a4114ceac5
md"""
# Apêndice: biblioteca de funções
"""

# ╔═╡ 5a3eec86-2780-11eb-0341-39a5c343fc52
function temperature_heatmap(x, T)
    p = heatmap(
        x, [0.0], collect(T'); clims=(-1.0, 1.0), cbar=false, xticks=nothing, yticks=nothing
    )

    return p
end

# ╔═╡ 6de1859c-277f-11eb-1ead-8b4794832d59
begin
    p1 = plot(0:0.001:Lₓ, T₀; label="T₀", lw=3)
    scatter!(xs, T₀.(xs); label="sampled")
    scatter!(xs, zero.(xs); label="x nodes", alpha=0.5, ms=3)

    xlabel!("x")
    ylabel!("T₀")

    for x in xs
        plot!([(x, 0), (x, T₀(x))]; ls=:dash, c=:black, label="", alpha=0.5)
    end

    hline!([0]; ls=:dash, lab=false)

    p2 = temperature_heatmap(xs, T₀.(xs))

    plot(p1, p2; layout=grid(2, 1; heights=[0.9, 0.1]), legend=:bottomleft)
end

# ╔═╡ 9187350a-2851-11eb-05f0-d3a6eef190fe
function evolve(method, xs, δt, U, t_final=10.0, f₀=T₀)
    T = f₀.(xs)
    δx = xs[2] - xs[1]

    t = 0.0
    ts = [t]

    results = [T]

    while t < t_final
        T′ = method(T, δt, δx, U)  # new
        push!(results, T′)

        t += δt
        push!(ts, t)

        T = copy(T′)
    end

    return ts, results
end

# ╔═╡ 30006c82-695d-40b1-8ded-22d03c3bff41
ts0, results0 = evolve(advection_diffusion, xs, δt, (UU, DD))

# ╔═╡ 6b2bfc73-d0a9-4a36-970d-c89149238284
md"""
time step = $(@bind n0 Slider(1:10:length(results0), show_value=true))
"""

# ╔═╡ 21eb19f7-467b-4995-be65-8dede4eb7ac1
let
    p1 = plot(
        xs,
        results0[n0];
        m=:o,
        xlim=(0, 1),
        ylim=(-3.1, 3.1),
        title="t = $(round(ts0[n0], digits=2))",
        leg=false
    )
    p2 = temperature_heatmap(xs, results0[n0])

    plot(p1, p2; layout=grid(2, 1; heights=[0.9, 0.1]), clim=(-1, 1))
end

# ╔═╡ 02a893e4-2852-11eb-358a-371459191da7
ts1, evolution1 = evolve(advection, xs, δt, U)

# ╔═╡ e6ae447e-2851-11eb-3fe1-096459167f2b
@bind n1 Slider(1:10:length(evolution1); show_value=true)

# ╔═╡ 014e2530-2852-11eb-103f-1d647cb999b0
let
    p1 = plot(
        xs,
        evolution1[n1];
        m=:o,
        xlim=(0, 1),
        ylim=(-3.1, 3.1),
        title="t = $(round(ts1[n1], digits=2))",
        leg=false
    )

    p2 = temperature_heatmap(xs, evolution1[n1])

    plot(p1, p2; layout=grid(2, 1; heights=[0.9, 0.1]))
end

# ╔═╡ e42ec13e-285a-11eb-3cc0-7dc41ed5495b
ts2, evolution2 = evolve(advection2, xs, δt, 0.1)

# ╔═╡ f60a8b5e-285a-11eb-0d35-8daf23cf92ae
n2_slider = @bind n2 Slider(1:10:length(evolution2); show_value=true)

# ╔═╡ f1b5d130-285a-11eb-001c-67035925f43d
let
    p1 = plot(
        xs,
        evolution2[n2];
        m=:o,
        xlim=(0, 1),
        ylim=(-3.1, 3.1),
        title="t = $(round(ts2[n2], digits=2))",
        leg=false
    )

    p2 = temperature_heatmap(xs, evolution2[n2])

    plot(p1, p2; layout=grid(2, 1; heights=[0.9, 0.1]))
end

# ╔═╡ 09bc3c40-288a-11eb-0339-59f0b70e03a3
md"t = $(@bind n3 Slider(1:10:length(evolution2), show_value=true))"

# ╔═╡ 121255d2-288a-11eb-1fa5-9db68af8c232
ts3, evolution3 = evolve(diffusion, xs, δt, 0.01)

# ╔═╡ 175d9902-288a-11eb-3700-390ccd1caa5b
let
    p1 = plot(
        xs,
        evolution3[n3];
        m=:o,
        xlim=(0, 1),
        ylim=(-3.1, 3.1),
        title="t = $(round(ts3[n3], digits=2))",
        leg=false
    )
    p2 = temperature_heatmap(xs, evolution3[n3])

    plot(p1, p2; layout=grid(2, 1; heights=[0.9, 0.1]), clim=(-1, 1))
end

# ╔═╡ f6fa3770-288d-11eb-32de-f95e03705791
ts5, evolution5 = evolve(advection_diffusion, xs, δt, (1.0, 0.01))

# ╔═╡ 6eb00a02-288d-11eb-354b-b56cf5a8380e
@bind n5 Slider(1:length(evolution5); show_value=true)

# ╔═╡ 65126bfc-288d-11eb-2bfc-493588365164
let
    p1 = plot(
        xs,
        evolution5[n5];
        m=:o,
        xlim=(0, 1),
        ylim=(-3.1, 3.1),
        title="t = $(round(ts5[n5], digits=2))",
        leg=false
    )
    p2 = temperature_heatmap(xs, evolution5[n5])

    plot(p1, p2; layout=grid(2, 1; heights=[0.9, 0.1]), clim=(-1, 1))
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
Plots = "~1.36.1"
PlutoUI = "~0.7.48"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "3ab577affb93990a922526f87d8f9f1510a3d9aa"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "629c6e4a7be8f427d268cebef2a5e3de6c50d462"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.6"

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
version = "0.5.2+0"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.DataAPI]]
git-tree-sha1 = "e08915633fcb3ea83bf9d6126292e5bc5c739922"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.13.0"

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

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "c36550cb29cbe373e95b3f40486b9a4148f89ffd"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.2"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

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
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "0c0e8d05fdd5e9792b31b7c7841f11a2ff8ad633"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.5.4"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

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
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

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
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

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
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

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
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "5628f092c6186a80484bfefdf89ff64efdaec552"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.3.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6e9dba33f9f2c44e08a020b0caf6903be540004"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.19+0"

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
version = "10.40.0+0"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "cceb0257b662528ecdf0b4b4302eb00e767b38e7"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.0"

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
version = "1.8.0"

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
git-tree-sha1 = "47e70b391ff314cc36e7c2400f7d2c5455dc9496"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.36.1"

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
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

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
git-tree-sha1 = "a030182cccc5c461386c6f055c36ab8449ef1340"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.10"

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

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

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

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

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
version = "1.2.12+3"

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
version = "5.1.1+0"

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
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

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
# ╠═e0c0dc94-277e-11eb-379e-83d064a93413
# ╟─5648fa26-da0b-41d9-b13f-debd4e0485af
# ╟─00877a4a-277c-11eb-3ec0-e71e4094b404
# ╟─1b25b916-277c-11eb-0274-4b4fb946258d
# ╟─956f5104-277d-11eb-291d-1faef485a5aa
# ╟─b12e76db-1a18-465a-8955-dab29dfde611
# ╟─c14470f2-d8a4-4d34-8470-09842b2576a3
# ╠═30006c82-695d-40b1-8ded-22d03c3bff41
# ╟─b04a6f81-3ece-4521-b141-a2e416718948
# ╟─6b2bfc73-d0a9-4a36-970d-c89149238284
# ╟─21eb19f7-467b-4995-be65-8dede4eb7ac1
# ╟─36328b70-277d-11eb-02c7-2f854c1466cc
# ╟─42190984-277d-11eb-1ac2-7d84516c3269
# ╟─d2bed768-277e-11eb-32cf-41f1fedec3cb
# ╠═e6493da0-277e-11eb-22ff-29752652b576
# ╟─0d6271c0-286c-11eb-1c9c-3ba039b49d24
# ╠═f17f7734-277e-11eb-25cf-5f2ba2db5aa3
# ╠═fa327c08-286b-11eb-0032-2384998a42a8
# ╟─0db43be2-284c-11eb-2740-4379437fd70c
# ╟─468a0590-2780-11eb-045c-d1f468fc4e50
# ╟─6de1859c-277f-11eb-1ead-8b4794832d59
# ╟─af30a0d0-2781-11eb-0274-ab423205facb
# ╟─646bc32e-284c-11eb-2ce8-5f64b1a49534
# ╟─79ce4b10-284c-11eb-2258-2155f850171d
# ╟─2494daaa-2780-11eb-3084-2317924048ea
# ╟─29444ffe-2780-11eb-0875-095302b5d486
# ╟─1dcb9690-6436-49f0-880f-23490fe28ea4
# ╟─b63bb2e8-1d23-48fb-94b5-60d947465830
# ╠═e94a90c5-f2c1-4b5b-9946-7869ef7775a6
# ╠═dd87fc01-4bf0-44f6-a9f6-560e433754a0
# ╠═7ae9f5b8-10ea-42a7-aa01-0e04a7287c77
# ╟─addab3e6-f189-41d6-badb-92f0323b6192
# ╟─2f24e0c7-b05c-4f89-835a-081f8e6107e5
# ╟─75bc87be-2b66-46b5-8de8-428a63655815
# ╟─f684dd94-f1c7-4f79-9776-3a06b8eec39b
# ╟─3437e53b-9dd0-4afe-a1bd-a556871d1799
# ╟─65df7158-60dc-4809-82a3-913a79bcfc75
# ╟─7256778a-2785-11eb-0369-f3b43d5dd203
# ╟─44433a34-2782-11eb-0079-837c9306c5bd
# ╟─87e2be25-227c-498c-94fa-6e404c8918f1
# ╟─72c0ab0c-2781-11eb-1f59-9b22a52b0be0
# ╟─e5761990-278b-11eb-134e-7954b577b1ac
# ╟─2033364e-278c-11eb-2936-17598ce14a41
# ╟─e9a37908-278c-11eb-278e-9bd155f0cae6
# ╟─bcf1ceca-f557-4d75-9058-bbaa58665fb7
# ╟─3736a25e-4dec-46ac-9bf6-9712e3d00e7a
# ╟─e542a8da-284e-11eb-3297-6bbbf052284b
# ╠═b15f4f44-284b-11eb-37c5-ab0153f7fe92
# ╟─fcbec610-d9fc-4e41-8e76-729dbbc61d92
# ╠═af79e360-286e-11eb-2a4d-3d6d7564088c
# ╠═02a893e4-2852-11eb-358a-371459191da7
# ╠═e6ae447e-2851-11eb-3fe1-096459167f2b
# ╟─014e2530-2852-11eb-103f-1d647cb999b0
# ╟─8c05e3cc-2858-11eb-1e1c-9781c30738c3
# ╠═a29fecac-285a-11eb-14b0-9313f8994fbb
# ╠═e42ec13e-285a-11eb-3cc0-7dc41ed5495b
# ╟─f60a8b5e-285a-11eb-0d35-8daf23cf92ae
# ╟─f1b5d130-285a-11eb-001c-67035925f43d
# ╟─5232b7cc-6fb9-4ed8-beb2-79c32cd1c35a
# ╟─c59388ea-286e-11eb-0f21-eb18e5ba516f
# ╟─3c944998-2888-11eb-087d-492b9d0ee32e
# ╟─6ac74e34-ed58-4903-8c53-82be13b6c21f
# ╟─de42149c-85ce-4e73-8503-84f64a173cbb
# ╟─ef42d541-74a1-433a-9773-5e6cca525350
# ╟─6b7cea44-2888-11eb-0208-990860d6a152
# ╟─83a1e1f5-0946-422c-83f4-d7a19e9c0789
# ╟─68db3372-2888-11eb-1b03-b5ebca4c2bd5
# ╟─d6131ad0-2889-11eb-3085-15d17e33ee7a
# ╠═630314bc-2868-11eb-1b93-b7b08a4b2887
# ╠═121255d2-288a-11eb-1fa5-9db68af8c232
# ╟─09bc3c40-288a-11eb-0339-59f0b70e03a3
# ╟─175d9902-288a-11eb-3700-390ccd1caa5b
# ╟─e63cfa84-2889-11eb-1ea2-51726645ddd9
# ╟─eee3008e-2889-11eb-088a-73aff304e736
# ╠═ffd2a838-2889-11eb-1a7c-b35992543b8a
# ╠═f6fa3770-288d-11eb-32de-f95e03705791
# ╠═6eb00a02-288d-11eb-354b-b56cf5a8380e
# ╟─65126bfc-288d-11eb-2bfc-493588365164
# ╟─575a5f3c-2780-11eb-2119-27a4114ceac5
# ╟─5a3eec86-2780-11eb-0341-39a5c343fc52
# ╠═9187350a-2851-11eb-05f0-d3a6eef190fe
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

#  LocalWords:  equiespaçados
