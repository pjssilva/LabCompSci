### A Pluto.jl notebook ###
# v0.20.10

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

# ╔═╡ 1e06178a-1fbf-11eb-32b3-61769a79b7c0
begin
    using LaTeXStrings
    using Plots
    using PlutoUI
    using Random
	using Distributions
end

# ╔═╡ 21524c08-2433-11eb-0c55-47b1bdc9e459
md"""

# **Lista 10**: _Modelagem climática_

`Data de entrega`: **24/06, 2025**

Este caderno contém _verificações ativas das respostas_! Em alguns exercícios você verá uma caixa colorida que roda alguns casos simples de teste e provê retorno imediato para a sua solução. Edite sua solução, execute a célula e verifique se passou na verificação. Note que a verificação feita é apenas superficial. Para a correção serão verificados mais casos e você tem a obrigação de escrever código que funcione adequadamente.

Pergunte o quanto quiser (use o Discord)!
"""

# ╔═╡ 23335418-2433-11eb-05e4-2b35dc6cca0e
# edite o código abaixo com seu nome e email da dac (sem o @dac.unicamp.br)

student = (name="João Ninguém", email_dac="j000000")

# aperte o botão ▶ no canto inferior direito da célula para executar o que você
# editou, ou use Shift+Enter

# Agora siga na página para ver o que deve fazer.

# ╔═╡ 18be4f7c-2433-11eb-33cb-8d90ca6f124c
md"""

Submetido por: **_$(student.name)_** ($(student.email_dac)@unicamp.br)
"""

# ╔═╡ 253f4da0-2433-11eb-1e48-4906059607d3
md"## Iniciando e/ou instalando pacotes"

# ╔═╡ fe3304f8-2668-11eb-066d-fdacadce5a19
md"""
_Lembre-se de assistir as aulas sobre modelagem climática antes de tentar fazer essa lista. Algumas rotinas que vimos nessas aulas serão adicionadas na célula abaixo. É uma boa ideia dar uma lida nelas antes de começar._
"""

# ╔═╡ 930d7154-1fbf-11eb-1c3a-b1970d291811
module Model

const S = 1368 # solar insolation [W/m^2]  (energy per unit time per unit area)
const α = 0.3 # albedo, or planetary reflectivity [unitless]
const B = -1.3 # climate feedback parameter [W/m^2/°C],
const T0 = 14.0 # preindustrial temperature [°C]

absorbed_solar_radiation(; α=α, S=S) = S * (1 - α) / 4 # [W/m^2]
outgoing_thermal_radiation(T; A=A, B=B) = A - B * T

const A = S * (1.0 - α) / 4 + B * T0 # [W/m^2].

greenhouse_effect(CO2; a=a, CO2_PI=CO2_PI) = a * log(CO2 / CO2_PI)

const a = 5.0 # CO2 forcing coefficient [W/m^2]
const CO2_PI = 280.0 # preindustrial CO2 concentration [parts per million; ppm];
CO2_const(t) = CO2_PI # constant CO2 concentrations

const C = 51.0 # atmosphere and upper-ocean heat capacity [J/m^2/°C]

function timestep!(ebm)
    append!(ebm.T, ebm.T[end] + ebm.Δt * tendency(ebm))
    append!(ebm.t, ebm.t[end] + ebm.Δt)
end

tendency(ebm) = (1.0 / ebm.C) * (
    +absorbed_solar_radiation(α=ebm.α, S=ebm.S)
    -
    outgoing_thermal_radiation(ebm.T[end], A=ebm.A, B=ebm.B)
    +
    greenhouse_effect(ebm.CO2(ebm.t[end]), a=ebm.a, CO2_PI=ebm.CO2_PI)
)

begin
    mutable struct EBM
        T::Array{Float64,1}

        t::Array{Float64,1}
        Δt::Float64

        CO2::Function

        C::Float64
        a::Float64
        A::Float64
        B::Float64
        CO2_PI::Float64

        α::Float64
        S::Float64
    end

    # Make constant parameters optional kwargs
    EBM(T::Array{Float64,1}, t::Array{Float64,1}, Δt::Real, CO2::Function;
        C=C, a=a, A=A, B=B, CO2_PI=CO2_PI, α=α, S=S) = (
        EBM(T, t, Δt, CO2, C, a, A, B, CO2_PI, α, S)
    )

    # Construct from float inputs for convenience
    EBM(T0::Real, t0::Real, Δt::Real, CO2::Function;
        C=C, a=a, A=A, B=B, CO2_PI=CO2_PI, α=α, S=S) = (
        EBM(Float64[T0], Float64[t0], Δt, CO2;
            C=C, a=a, A=A, B=B, CO2_PI=CO2_PI, α=α, S=S)
    )
end

begin
    function run!(ebm::EBM, end_year::Real)
        while ebm.t[end] < end_year
            timestep!(ebm)
        end
    end

    run!(ebm) = run!(ebm, 200.0) # run for 200 years by default
end




CO2_hist(t) = CO2_PI * (1 .+ fractional_increase(t))
fractional_increase(t) = ((t .- 1850.0) / 220) .^ 3

begin
    CO2_RCP26(t) = CO2_PI * (1 .+ fractional_increase(t) .* min.(1.0, exp.(-((t .- 1850.0) .- 170) / 100)))
    RCP26 = EBM(T0, 1850.0, 1.0, CO2_RCP26)
    run!(RCP26, 2100.0)

    CO2_RCP85(t) = CO2_PI * (1 .+ fractional_increase(t) .* max.(1.0, exp.(((t .- 1850.0) .- 170) / 100)))
    RCP85 = EBM(T0, 1850.0, 1.0, CO2_RCP85)
    run!(RCP85, 2100.0)
end

end

# ╔═╡ 1312525c-1fc0-11eb-2756-5bc3101d2260
md"""## **Exercício 1** - _objetivos de políticas sob incerteza_

Um importantíssimo [artigo de revisão](https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2019RG000678) recente obteve a estimativa mais precisa conhecida para o **parâmetro de retorno climático**. Nele obteve-se que

$B \approx \mathcal{N}(-1.3, 0.4),$

ou seja, até onde sabemos esse valor obedece a uma distribuição normal com média  $\overline{B} = -1.3$ W/m²/K e desvio padrão  $\sigma = 0.4$ W/m²/K. A partir dessa descrição crua é difícil saber o que isso significa. Quais cenários estão descritos? O nosso objetivo agora é entender o que isso significa e qual o impacto que isso pode ter na definição de políticas de mitigação.

**Definição:** *Sensitividade climática de equilíbrio (ECS)* é definida como a quantidade de aquecimento $\Delta T$ causada por uma duplicação na concentração de CO₂ (por exemplo, saindo de 280 ppm, a concentração do período pré-industrial, para 560 ppm), no equilíbrio.

No equilíbrio, a equação do modelo de balanço energético é:

$0 = \frac{S(1 - α)}{4} - (A - BT_{eq}) + a \ln\left( \frac{2\;\text{CO}₂_{\text{PI}}}{\text{CO}₂_{\text{PI}}} \right)$

Partindo daí, podemos subtrair o balaço pré-industrial, dado por

$0 = \frac{S(1-α)}{4} - (A - BT_{0}),$

após rearranjar os termos e uma simplificação simples obtemos a nossa definição de $\text{ECS}$:

$\text{ECS} \equiv T_{eq} - T_{0} = -\frac{a\ln(2)}{B}.$
"""

# ╔═╡ 7f961bc0-1fc5-11eb-1f18-612aeff0d8df
md"""O gráfico abaixo fornece um exemplo de um experimento "abrupto 2 × CO₂", um método clássico de tratamento experimental em modelagem climática que é usado na prática para estimar ECS para um modelo específico. (Nota: em modelos climáticos complicados, os valores dos parâmetros $a$ e $B$ não são especificados *a priori*, mas *emergem* como resultados da simulação.)

A simulação começa no equilíbrio pré-industrial, ou seja, uma temperatura $T_ {0} = 14$°C está em equilíbrio com a concentração de CO₂ pré-industrial de 280 ppm até que o CO₂ seja abruptamente dobrado de 280 ppm para 560 ppm. O clima responde aquecendo-se rapidamente e, após algumas centenas de anos, aproxima-se do valor de sensibilidade ao clima de equilíbrio, por definição. 
"""

# ╔═╡ fa7e6f7e-2434-11eb-1e61-1b1858bb0988
md"""
``B = `` $(@bind B_slider Slider(-2.5:.001:0; show_value=true, default=-1.3))
"""

# ╔═╡ 16348b6a-1fc2-11eb-0b9c-65df528db2a1
md"""
##### Exercício 1.1 - _Compreendendo retro-alimentações (retornos) e sensitividade climática_
"""

# ╔═╡ e296c6e8-259c-11eb-1385-53f757f4d585
md"""
👉 Modifique o slide para o valor de $B$ acima. O que significa um valor menor para $B$? Explique porque o nome de $B$ é _parâmetro de retorno climático_.
"""

# ╔═╡ a86f13de-259d-11eb-3f46-1f6fb40020ce
# Solução ex. 1.1.a (não apague esse comentário)

observations_from_changing_B = md"""
Coloque sua resposta aqui!
"""

# ╔═╡ 3d66bd30-259d-11eb-2694-471fb3a4a7be
md"""
👉 O que ocorre quando B é maior ou igual a zero?
"""

# ╔═╡ 5f82dec8-259e-11eb-2f4f-4d661f44ef41
# Solução ex. 1.1.b (não apague esse comentário)

observations_from_nonnegative_B = md"""
Coloque sua resposta aqui!
"""

# ╔═╡ 56b68356-2601-11eb-39a9-5f4b8e580b87
md"Revele a resposta: $(@bind reveal_nonnegative_B_answer CheckBox())"

# ╔═╡ 7d815988-1fc7-11eb-322a-4509e7128ce3
if reveal_nonnegative_B_answer
    md"""
    Isso é conhecido como o "efeito estufa descontrolado", em que o aquecimento se amplifica tão fortemente por meio de *retornos positivos* que o aquecimento continua para sempre (ou até que os oceanos fervam e não haja mais um reservatório ou água para sustentar uma *retro-alimentação de vapor de água*. Acredita-se que isso explique o clima extremamente quente e hostil de Vênus, mas como você pode ver, é extremamente improvável que ocorra na Terra atual."""
end

# ╔═╡ aed8f00e-266b-11eb-156d-8bb09de0dc2b
md"""
👉 Crie um gráfico para visualizar o ECS como uma função de B. 
"""

# ╔═╡ b9f882d8-266b-11eb-2998-75d6539088c7
# Solução ex. 1.1.c (não apague esse comentário)


# ╔═╡ 269200ec-259f-11eb-353b-0b73523ef71a
md"""
#### Exercício 1.2 - _Duplicando CO₂_

Para calcular ECS, nós duplicamos o CO₂ na atmosfera. Esse fator de 2 não é completamente arbitrário: sem que haja um esforço hercúleo para reduzir as emissões de CO₂ espera-se que haja **no mínimo** uma duplicação da concentração desse gás até 2100.

Atualmente, nossa concentração de CO₂ é de 415 ppm -- $(round(415 / 280, digits=3)) vezes o valor de 280 que representa a concentração pré-industrial, presente em 1850. 

Já as concentrações _futuras_ dependem da ação humana. Existem vários modelos para as concentrações futuras, que são gerados baseados em diferentes _cenários de políticas_. O modelo de partida é o RCP8.5 - um modelo de emissões elevadas de "pior caso". No nosso caderno, esse modelo é dado como uma função de ``t``.
"""

# ╔═╡ 2dfab366-25a1-11eb-15c9-b3dd9cd6b96c
md"""
👉 Em qual ano espera-se atingir a duplicação da concentração de CO₂ sob o cenário RCP8.5? Considere que `Model.CO2_RCP85(t)` devolve a concentração às 0 h de 1º de janeiro do ano `t`.
"""

# ╔═╡ 50ea30ba-25a1-11eb-05d8-b3d579f85652
# Solução ex. 1.2 (não apague esse comentário)

expected_double_CO2_year = let

    missing
end

# ╔═╡ bade1372-25a1-11eb-35f4-4b43d4e8d156
md"""
#### Exercício 1.3 - _Incerteza em B_

O parâmetro de feedback do clima ``B`` não é algo que possamos controlar - é uma propriedade emergente do sistema climático global. Infelizmente, ``B`` também é difícil de quantificar empiricamente (os processos relevantes são difíceis ou impossíveis de observar diretamente), então permanece a dúvida quanto ao seu valor exato.

Um valor de ``B`` próximo a zero significa que um aumento nas concentrações de CO₂ terá um impacto maior no aquecimento global, e que mais ações são necessárias para ficar abaixo de uma temperatura máxima. Assim para responder questões relacionadas à política que devemos seguir, precisamos levar em consideração a incerteza associada com nossas estimativas para ``B``. Neste exercício, faremos isso usando uma simulação de Monte Carlo: geramos uma amostra de valores para ``B`` e usamos esses valores em nossa análise.
"""

# ╔═╡ 02232964-2603-11eb-2c4c-c7b7e5fed7d1
B̅, σ = -1.3, 0.4

# ╔═╡ c4398f9c-1fc4-11eb-0bbb-37f066c6027d
ECS(; B=B̅, a=Model.a) = -a * log(2.0) ./ B;

# ╔═╡ 25f92dec-1fc4-11eb-055d-f34deea81d0e
let
    double_CO2(t) =
        if t >= 0
            2 * Model.CO2_PI
        else
            Model.CO2_PI
        end

    # the definition of A depends on B, so we recalculate:
    A = Model.S * (1.0 - Model.α) / 4 + B_slider * Model.T0
    # create the model
    ebm_ECS = Model.EBM(14.0, -100.0, 1.0, double_CO2, A=A, B=B_slider)
    Model.run!(ebm_ECS, 300)

    ecs = ECS(B=B_slider)

    p = plot(
        size=(500, 250), legend=:bottomright,
        title="Transient response to instant doubling of CO₂",
        ylabel="temperature change [°C]", xlabel="years after doubling",
        ylim=(-0.5, (isfinite(ecs) && ecs < 4) ? 4 : 10),
    )

    plot!(p, [ebm_ECS.t[1], ebm_ECS.t[end]], ecs .* [1, 1],
        ls=:dash, color=:darkred, label="ECS")

    plot!(p, ebm_ECS.t, ebm_ECS.T .- ebm_ECS.T[1],
        label="ΔT(t) = T(t) - T₀")
end |> as_svg

# ╔═╡ 736ed1b6-1fc2-11eb-359e-a1be0a188670
B_samples = let
    Random.seed!(1)
    B_distribution = Normal(B̅, σ)
    Nsamples = 50000

    samples = rand(B_distribution, Nsamples)
    # we only sample negative values of B
    filter(x -> x < 0, samples)
end

# ╔═╡ 49cb5174-1fc3-11eb-3670-c3868c9b0255
histogram(B_samples, size=(600, 250), label=nothing, xlabel="B [W/m²/K]", ylabel="samples")

# ╔═╡ f3abc83c-1fc7-11eb-1aa8-01ce67c8bdde
md"""
👉 Gere uma amostra da distribuição de probabilidade da ECS baseada na amostra da distribuição de $B$ obtida acima. Apresente um histograma.
"""

# ╔═╡ 3d72ab3a-2689-11eb-360d-9b3d829b78a9
# Solução ex. 1.3.a (não apague esse comentário)

ECS_samples = [0.0]  # Corrija com seu código, mas mantenha o nome da variável

# ╔═╡ 1f148d9a-1fc8-11eb-158e-9d784e390b24
# Solução ex. 1.3.b (não apague esse comentário)

# Faça o histograma aqui

# ╔═╡ a618a7c6-9f8c-4d50-ba0a-9e0163560367
md"👉 Qual o maior valor observado para as amostras de ECS?"

# ╔═╡ e5673105-7f78-447c-87be-c8d858b9e836
# Solução ex. 1.3.c (não apague esse comentário)

# Coloque código para responder à pergunta aqui.

# ╔═╡ cf8dca6c-1fc8-11eb-1f89-099e6ba53c22
md"Como podemos ver, a distribuição da ECS não é **normalmente distribuída**, apesar de $B$ o ser.

👉 Como que a média das amostras de ECS se compara com o ECS do $B$ médio? Qual a probabilidade das amostras de ECS ficarem acima do ECS do $B$ médio?
"

# ╔═╡ 02173c7a-2695-11eb-251c-65efb5b4a45f
# Solução ex. 1.3.d (não apague esse comentário)

begin
    mean_ECS = 0.0 # Corrija com seu código, mas mantenha o nome da variável
    ECS_mean_B = 0.0 # Corrija com seu código, mas mantenha o nome da variável
    prob_bigger = 0.0 # Corrija com seu código, mas mantenha o nome da variável
    mean_ECS, ECS_mean_B, prob_bigger
end


# ╔═╡ 440271b6-25e8-11eb-26ce-1b80aa176aca
md"""
👉 O que a discrepância acima nos ensina sobre fazer apenas uma simulação com o ECS médio ou fazer várias simulações com vários ECS possíveis? Como seria nossa "impressão"  sobre o os possíveis crescimentos de temperatura?
"""

# ╔═╡ cf276892-25e7-11eb-38f0-03f75c90dd9e
# Solução ex. 1.3.e (não apague esse comentário)

md"""
Coloque suas observações aqui!
"""

# ╔═╡ 5b5f25f0-266c-11eb-25d4-17e411c850c9
md"""
#### Exercício 1.5 - _Executando o modelo_

Nas aulas e no código acima introduzimos uma _estrutura mutável_ `EBM` (_modelo de balanço energético_), que contém:

- os parâmetros da simulação climática (`C`, `a`, `A`, `B`, `CO2_PI`, `α`, `S`, veja detalhes abaixo)

- a função `CO2`, que mapeia um ano `t` na concentração de CO₂ daquele ano. Por exemplo, podemos usar a função `t -> 280` para simular um modelo com concentrações de gás carbônico fixas em 280 ppm.

`EBM` também armazena os resultados da simulação em dois vetores:
- `T` é o vetor de temperaturas (°C, `Float64`).
- `t` é o vetor de instantes do tempo (anos, `Float64`), de mesmo comprimento que `T`.
"""

# ╔═╡ 7bad483f-66de-42ee-aaac-de8fcc91039e
md"""
Propriedades de um objeto `EBM`:

| Nome | Descrição |
|:----:|:----------|
| `A`  | deslocamento da linearização da radiação térmica de saída [W/m²] |
| `B`  | inclinação da linearização da radiação térmica de saída [W/m²/°C] |
| `α`  | Albedo do Planeta 0.0-1.0 (adimensional) |
| `S`  | Insolação solar [W/m²]
| `C`  | Capacidade térmica da superfície dos oceanos e atmosfera [W yr / m²/ °C] |
| `a`  | Efeito forçante do CO₂ [M / m²]
| `CO2_PI` | Concentração de CO₂ pré-industrial [ppm]
"""



# ╔═╡ 971f401e-266c-11eb-3104-171ae299ef70
md"""

Você pode inicializar uma instância de um `EBM` da seguinte forma:
"""

# ╔═╡ 746aa5bc-266c-11eb-14c9-63ccc313f5de
empty_ebm = Model.EBM(
    14.0, # initial temperature
    1850, # initial year
    1,    # Δt
    t -> 280.0, # CO2 function
)

# ╔═╡ a919d584-2670-11eb-1cf9-2327c8135d6d
md"""
Dê uma olhada no código desse objeto, acima. Veja que os vetores `T` e `t` são inicializados como um vetor de um único elemento.

Vamos executar o modelo:
"""

# ╔═╡ bfb07a0a-2670-11eb-3938-772499c637b1
simulated_model = let
    ebm = Model.EBM(14.0, 1850, 1, t -> 280.0)
    Model.run!(ebm, 2020)
    ebm
end

# ╔═╡ 12cbbab0-2671-11eb-2b1f-038c206e84ce
md"""
Novamente, olhe dentro de `simulated_model` e observe que os vetores `T` e `t` acumularam os resultados da simulação.

Nesta simulação, usamos `T0 = 14` e` CO2 = t -> 280`, razão pela qual `T` é constante durante nossa simulação. Esses parâmetros são os valores padrão pré-industriais, e nosso modelo é baseado neste equilíbrio.

👉 Execute uma simulação com o cenário de política RCP8.5 e plote o gráfico de temperatura calculado. Qual é a temperatura global no ano 2100?
"""

# ╔═╡ 9596c2dc-2671-11eb-36b9-c1af7e5f1089
# Solução ex. 1.5.a (não apague esse comentário)
# Ao final o let deve calcular os dois valores pedidos

simulated_rcp85_model, temperature_at_2100 = let

    missing, missing
end

# ╔═╡ 4b091fac-2672-11eb-0db8-75457788d85e
md"""
Parâmetros adicionais podem ser configurados usando argumentos com palavras chaves. Por exemplo:

```julia
Model.EBM(14, 1850, 1, t -> 280.0; B=-2.0)
```
Cria o mesmo modelo que antes, mas agora com `B = -2.0`.
"""

# ╔═╡ 9cdc5f84-2671-11eb-3c78-e3495bc64d33
md"""
👉 Escreva uma função `temperature_response` que recebe uma função `CO2` e um valor opcional `B` como argumentos e retorna a temperatura em 2100 de acordo com o nosso modelo.
"""

# ╔═╡ f688f9f2-2671-11eb-1d71-a57c9817433f
# Solução ex. 1.5.b (não apague esse comentário)

function temperature_response(CO2::Function, B::Float64=-1.3)
    return 1.0 # Modifique com usa resposta
end

# ╔═╡ 049a866e-2672-11eb-29f7-bfea7ad8f572
temperature_response(t -> 280)

# ╔═╡ 09901de6-2672-11eb-3d50-05b176b729e7
temperature_response(Model.CO2_RCP85)

# ╔═╡ aea0d0b4-2672-11eb-231e-395c863827d3
temperature_response(Model.CO2_RCP85, -1.0)

# ╔═╡ 9c32db5c-1fc9-11eb-029a-d5d554de1067
md"""#### Exercício 1.6 - _Aplicações a questões relevantes para políticas_

Nós falamos de dois _cenários de emissões_ diferentes:  RCP2.6 (forte mitigação - Concentrações de CO2 controladas) e RCP8.5 (sem mitigação - Altas concentrações de CO2). Eles são dadas pelas seguintes funções:
"""

# ╔═╡ ee1be5dc-252b-11eb-0865-291aa823b9e9
t = 1850:2100

# ╔═╡ e10a9b70-25a0-11eb-2aed-17ed8221c208
plot(t, Model.CO2_RCP85.(t),
    ylim=(0, 1200), ylabel="CO2 concentration [ppm]")

# ╔═╡ 40f1e7d8-252d-11eb-0549-49ca4e806e16
@bind t_scenario_test Slider(t; show_value=true, default=1850)

# ╔═╡ 19957754-252d-11eb-1e0a-930b5208f5ac
Model.CO2_RCP26(t_scenario_test), Model.CO2_RCP85(t_scenario_test)

# ╔═╡ 06c5139e-252d-11eb-2645-8b324b24c405
md"""
Estamos interessados em como a **incerteza no parâmetro de entrada** $B$ (o parâmetro de retorno do clima) *se propaga* por meio de nosso modelo para determinar a **incerteza em nossa saída** $T(t)$, para um dado cenário de emissões. O objetivo deste exercício é responder ao seguinte usando *Simulação Monte Carlo* para *propagação de incerteza*:

> 👉 Qual é a probabilidade de vermos mais de 2 ° C de aquecimento até 2100 no cenário de baixas emissões RCP2.6? E no cenário de altas emissões RCP8.5?
"""

# ╔═╡ f2e55166-25ff-11eb-0297-796e97c62b07
# Solução ex. 1.6 (não apague esse comentário)

prob_rcp26, prob_rcp85 = let
    0.0, 0.0  # Substitua com sua resposta, use o vetor de amostras criado acima
    # o vetor B_samples
end

# ╔═╡ 1ea81214-1fca-11eb-2442-7b0b448b49d6
md"""
## **Exercício 2** - _Como a Terra bola de neve derreteu_?

Em aula, vimos que apenas o aumento de brilho do Sol não seria suficiente para derreter a Terra bola de neve.
"""

# ╔═╡ 3e310cf8-25ec-11eb-07da-cb4a2c71ae34
md"""
Conversamos sobre uma segunda teoria - um grande aumento de CO₂ (por vulcões) poderia ter causado um efeito estufa forte o suficiente para derreter a bola de neve. Se imaginarmos que o CO₂ então diminuiu (por exemplo, ao ser sequestrado pelo oceano, agora líquido), podemos ser capazes de explicar como ocorreu a transição de uma Terra bola de neve hostil para a Terra "bola de água" habitável de hoje.

Neste exercício, você irá estimar quanto CO₂ seria necessário para derreter a bola de neve e visualizar uma possível trajetória para o clima da Terra nos últimos 700 milhões de anos, fazendo um *diagrama de bifurcação* interativo.

#### Exercício 2.1

No [caderno de aula](https://github.com/pjssilva/LabCompSci/blob/Sem2_21/notebooks/week13/24_terraboladeneve_e_histerese.jl), havia um diagrama de bifurcação de $S$ (insolação solar) vs $T$ (temperatura). Ao aumentar $S$, observamos o ponto se mover  no diagrama até encontrar o ponto crítico. Desta vez, faremos o mesmo, mas iremos variar a concentração de CO₂ e manteremos $S$ fixo em seu valor padrão (dias atuais).
"""

# ╔═╡ d6d1b312-2543-11eb-1cb2-e5b801686ffb
md"""
Abaixo encontra-se um diagrama vazio, que já está configurado como um diagrama CO₂ vs $T$, com um eixo horizontal logarítmico. Agora é sua vez! Escrevemos abaixo algumas dicas para ajudá-lo, mas fique à vontade para fazer do seu jeito.
"""

# ╔═╡ 3cbc95ba-2685-11eb-3810-3bf38aa33231
md"""
Usamos duas funções auxiliares:
"""

# ╔═╡ 68b2a560-2536-11eb-0cc4-27793b4d6a70
function add_cold_hot_areas!(p)

    left, right = xlims(p)

    plot!(p,
        [left, right], [-60, -60],
        fillrange=[-10.0, -10.0], fillalpha=0.3, c=:lightblue, label=nothing
    )
    annotate!(p,
        left + 12, -19,
        text("completely\nfrozen", 10, :darkblue, :left)
    )

    plot!(p,
        [left, right], [10, 10],
        fillrange=[80.0, 80.0], fillalpha=0.09, c=:red, lw=0.0, label=nothing
    )
    annotate!(p,
        left + 12, 15,
        text("no ice", 10, :darkred, :left)
    )
end

# ╔═╡ 0e19f82e-2685-11eb-2e99-0d094c1aa520
function add_reference_points!(p)
    plot!(p,
        [Model.CO2_PI, Model.CO2_PI], [-55, 75],
        color=:grey, alpha=0.3, lw=8,
        label="Pre-industrial CO2"
    )
    plot!(p,
        [Model.CO2_PI], [Model.T0],
        shape=:circle, color=:orange, markersize=8,
        label="Our preindustrial climate"
    )
    plot!(p,
        [Model.CO2_PI], [-38.3],
        shape=:circle, color=:aqua, markersize=8,
        label="Alternate preindustrial climate"
    )
end

# ╔═╡ 1eabe908-268b-11eb-329b-b35160ec951e
md"""
👉 Crie um slider para `CO2` entre `CO2min` e `CO2max`. Assim como o eixo horizontal do gráfico, queremos que o slider seja _logarítmico_. 
"""

# ╔═╡ 1d388372-2695-11eb-3068-7b28a2ccb9ac
# Solução ex. 2.1.a.i (não apague esse comentário)


# ╔═╡ 272f8910-a7b1-4633-b6c4-eedd1b8ea82f
# Solução ex. 2.1.a.ii (não apague esse comentário)


# ╔═╡ 4c9173ac-2685-11eb-2129-99071821ebeb
md"""
👉 Escreva uma função `step_model!` que recebe um `ebm` existente e um  `new_CO2`, e realiza um passo do nosso processo iterativo:

- Reinicie o modelo transformando  `ebm.t` e `ebm.T` em vetores de um único elemento. _Qual o valor adequado?_
- Atribui uma nova função a `ebm.CO2`. _Qual função?_
- Evolui o modelo por 1000 anos.
"""

# ╔═╡ 736515ba-2685-11eb-38cb-65bfcf8d1b8d
# Solução ex. 2.1.b (não apague esse comentário)

function step_model!(ebm::Model.EBM, CO2::Real)

    # your code here

    return ebm
end

# ╔═╡ 8b06b944-268c-11eb-0bfc-8d4dd21e1f02
md"""
👉 Dentro da célula que gera o gráfico de bifurcação, acima, chame a rotina  `step_model!` para apresentar o novo equilíbrio.
"""

# ╔═╡ 09ce27ca-268c-11eb-0cdd-c9801db876f8
md"""
##### parâmetros
"""

# ╔═╡ 298deff4-2676-11eb-2595-e7e22f613ea1
CO2min = 10

# ╔═╡ 2bbf5a70-2676-11eb-1085-7130d4a30443
CO2max = 1_000_000

# ╔═╡ de95efae-2675-11eb-0909-73afcd68fd42
Tneo = -48

# ╔═╡ 06d28052-2531-11eb-39e2-e9613ab0401c
ebm = Model.EBM(Tneo, 0.0, 5.0, Model.CO2_const)

# ╔═╡ 378aed18-252b-11eb-0b37-a3b511af2cb5
let
    p = plot(
        xlims=(CO2min, CO2max), ylims=(-55, 75),
        xaxis=:log,
        xlabel="CO2 concentration [ppm]",
        ylabel="Global temperature T [°C]",
        title="Earth's CO2 concentration bifurcation diagram",
        legend=:topleft
    )

    add_cold_hot_areas!(p)
    add_reference_points!(p)

    # your code here 

    plot!(p,
        [ebm.CO2(ebm.t[end])], [ebm.T[end]],
        label=nothing,
        color=:black,
        shape=:circle,
    )

end |> as_svg

# ╔═╡ c78e02b4-268a-11eb-0af7-f7c7620fcc34
md"""
O retorno albedo é implementado pelos métodos abaixo:
"""

# ╔═╡ d7801e88-2530-11eb-0b93-6f1c78d00eea
function α(T; α0=Model.α, αi=0.5, ΔT=10.0)
    if T < -ΔT
        return αi
    elseif -ΔT <= T < ΔT
        return αi + (α0 - αi) * (T + ΔT) / (2ΔT)
    elseif T >= ΔT
        return α0
    end
end

# ╔═╡ 607058ec-253c-11eb-0fb6-add8cfb73a4f
function Model.timestep!(ebm)
    ebm.α = α(ebm.T[end]) # Added this line
    append!(ebm.T, ebm.T[end] + ebm.Δt * Model.tendency(ebm))
    append!(ebm.t, ebm.t[end] + ebm.Δt)
end

# ╔═╡ 9c1f73e0-268a-11eb-2bf1-216a5d869568
md"""
Se você quiser, deixe a sua visualização mais informativa. Como no caderno da aula, você poderia deixar um rastro atrás do ponto negro, ou você poderia apresentar os ramos estáveis e instáveis. Isso fica com você (e é opcional)!
"""

# ╔═╡ 11096250-2544-11eb-057b-d7112f20b05c
md"""
#### Exercício 2.2

👉 Encontre a **menor concentração de CO₂** necessária para derreter a bola de neve. Isso deve ser feito de forma "automática" (ou seja, usando código). A precisão mínima deve ser de 0.01 em escala logarítmica.
"""

# ╔═╡ 9eb07a6e-2687-11eb-0de3-7bc6aa0eefb0
# Solução ex. 2.2 (não apague esse comentário)

co2_to_melt_snowball = let

    missing
end

# ╔═╡ 36e2dfea-2433-11eb-1c90-bb93ab25b33c
if student.name == "João Ninguém" || student.email_dac == "j000000"
    md"""
    !!! danger "Antes de submeter"
        Lembre de preencher o seu **nome** e **email dac** no início desse caderno.
    """
end

# ╔═╡ 36ea4410-2433-11eb-1d98-ab4016245d95
md"## Function library

Just some helper functions used in the notebook."

# ╔═╡ 36f8c1e8-2433-11eb-1f6e-69dc552a4a07
hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))

# ╔═╡ 51e2e742-25a1-11eb-2511-ab3434eacc3e
hint(md"A função `findfirst` pode ser útil.")

# ╔═╡ 53c2eaf6-268b-11eb-0899-b91c03713da4
hint(md"
```julia
@bind log_CO2 Slider(❓)
```

```julia
CO2 = 10^log_CO2
```

")

# ╔═╡ cb15cd88-25ed-11eb-2be4-f31500a726c8
hint(md"Use uma condição no albedo ou na temperatura para verificar se a bola de nve derreteu.")

# ╔═╡ 232b9bec-2544-11eb-0401-97a60bb172fc
hint(md"Uma opção é começar escrevendo uma função `equilibrium_temperature(CO2)` que cria um novo `EBM` na temperatura da Terra bola de neve T = $(Tneo) e retorna a temperatura final para o nível de CO₂ fornecido.")

# ╔═╡ 37061f1e-2433-11eb-3879-2d31dc70a771
almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))

# ╔═╡ 371352ec-2433-11eb-153d-379afa8ed15e
still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))

# ╔═╡ 372002e4-2433-11eb-0b25-39ce1b1dd3d1
keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))

# ╔═╡ 372c1480-2433-11eb-3c4e-95a37d51835f
yays = [md"Fantastic!", md"Splendid!", md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next section."]

# ╔═╡ 3737be8e-2433-11eb-2049-2d6d8a5e4753
correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))

# ╔═╡ 374522c4-2433-11eb-3da3-17419949defc
not_defined(variable_name) = Markdown.MD(Markdown.Admonition("danger", "Oopsie!", [md"Make sure that you define a variable called **$(Markdown.Code(string(variable_name)))**"]))

# ╔═╡ 37552044-2433-11eb-1984-d16e355a7c10
TODO = html"<span style='display: inline; font-size: 2em; color: purple; font-weight: 900;'>TODO</span>"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
Distributions = "~0.25.77"
LaTeXStrings = "~1.3.0"
Plots = "~1.36.1"
PlutoUI = "~0.7.48"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.9"
manifest_format = "2.0"
project_hash = "649af19d1cab60774119c538a0f677326cdf9e24"

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
git-tree-sha1 = "fde3bf89aead2e723284a8ff9cdf5b551ed700e8"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.5+0"

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
git-tree-sha1 = "37ea44092930b1811e666c3bc38065d7d87fcc74"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.1"

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
git-tree-sha1 = "3e6d038b77f22791b8e3472b7c633acea1ecac06"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.120"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

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
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

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

[[deps.Formatting]]
deps = ["Logging", "Printf"]
git-tree-sha1 = "fb409abab2caf118986fc597ba84b50cbaf00b87"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.3"

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
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "4423d87dc2d3201f3f1768a29e807ddc8cc867ef"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.71.8"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "3657eb348d44575cc5560c80d7e55b812ff6ffe1"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.71.8+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "fee60557e4f19d0fe5cd169211fdda80e494f4e8"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.84.0+0"

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
git-tree-sha1 = "f923f9a774fcf3f5cb761bfa43aeadd689714813"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.5.1+0"

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
git-tree-sha1 = "82f7acdc599b65e0f8ccd270ffa1467c21cb647b"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.11"

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
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "eb62a3deb62fc6d8822c0c4bef73e4412419c5d8"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.8+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1c602b1127f4751facb671441ca72715cc95938a"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.3+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "8c57307b5d9bb3be1ff2da469063628631d4d51e"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.21"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    DiffEqBiologicalExt = "DiffEqBiological"
    ParameterizedFunctionsExt = "DiffEqBase"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    DiffEqBase = "2b5f629d-d688-5b77-993f-72d75c75574e"
    DiffEqBiological = "eb300fae-53e8-50a0-950c-e21f52c2b7e0"
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
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c8da7e6a91781c41a863611c7e966098d783c57a"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.4.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "d36c21b9e7c172a44a10484125024495e2625ac0"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.1+1"

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
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

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
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

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
git-tree-sha1 = "f1a7e086c677df53e064e0fdd2c9d0b0833e3f6e"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.5.0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "ad31332567b189f508a3ea8957a2640b1147ab00"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.23+1"

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
git-tree-sha1 = "05868e21324cede2207c6f0f466b4bfef6d5e7ee"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "f07c06228a1c670ae4c87d1276b92c7c597fdda0"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.35"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "275a9a6d85dc86c24d03d1837a0010226a96f540"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.56.3+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "7d2f8f21da5db6a806faf7b9b292296da42b2810"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.3"

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
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SnoopPrecompile", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "6a9521b955b816aa500462951aa67f3e4467248a"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.36.6"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "3876f0ab0390136ae0b5e3f064a109b87fa1e56e"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.63"

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

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

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

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

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
git-tree-sha1 = "95af145932c2ed859b63329952ce8d633719f091"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.3"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9d72a13a3f4dd3795a195ac5a44d7d6ff5f552ff"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.1"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "8e45cecc66f3b42633b8ce14d431e8e57a3e242e"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.5.0"

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

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "XML2_jll"]
git-tree-sha1 = "49be0be57db8f863a902d59c0083d73281ecae8e"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.23.1+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "54b8a029ac145ebe8299463447fd1590b2b1d92f"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.44.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "b8b243e47228b4a3877f1dd6aee0c5d56db7fcf4"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.6+1"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "b5899b25d17bf1889d25906fb9deed5da0c15b3b"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.12+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aa1261ebbac3ccc8d16558ae6799524c450ed16b"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.13+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "6c74ca84bbabc18c4547014765d194ff0b4dc9da"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.4+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "52858d64353db33a56e13c341d7bf44cd0d7b309"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.6+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "a4c0ee07ad36bf8bbce1c3bb52d21fb1e0b987fb"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.7+0"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "9caba99d38404b285db8801d5c45ef4f4f425a6d"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.1+0"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "a376af5c7ae60d29825164db40787f15c80c7c54"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.8.3+0"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll"]
git-tree-sha1 = "a5bc75478d323358a90dc36766f3c99ba7feb024"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.6+0"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "aff463c82a773cb86061bce8d53a0d976854923e"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.5+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "7ed9347888fac59a618302ee38216dd0379c480d"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.12+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXau_jll", "Xorg_libXdmcp_jll"]
git-tree-sha1 = "bfcaf7ec088eaba362093393fe11aa141fa15422"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.1+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "e3150c7400c41e207012b41659591f083f3ef795"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.3+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "f4fc02e384b74418679983a97385644b67e1263b"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll"]
git-tree-sha1 = "68da27247e7d8d8dafd1fcf0c3654ad6506f5f97"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "44ec54b0e2acd408b0fb361e1e9244c60c9c3dd4"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "5b0263b6d080716a02544c55fdff2c8d7f9a16a0"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.10+0"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "f233c83cad1fa0e70b7771e0e21b061a116f2763"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.2+0"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "801a858fc9fb90c11ffddee1801bb06a738bda9b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.7+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "00af7ebdc563c9217ecc67776d1bbf037dbcebf4"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.44.0+0"

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

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6a34e0e0960190ac2a4363a1bd003504772d631"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.61.1+0"

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

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a22cf860a7d27e4f3498a0fe0811a7957badb38"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.3+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "002748401f7b520273e2b506f61cab95d4701ccf"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.48+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "490376214c4721cdaca654041f635213c6165cb3"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+2"

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
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "c950ae0a3577aec97bfccf3381f66666bc416729"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.8.1+0"
"""

# ╔═╡ Cell order:
# ╟─18be4f7c-2433-11eb-33cb-8d90ca6f124c
# ╟─21524c08-2433-11eb-0c55-47b1bdc9e459
# ╠═23335418-2433-11eb-05e4-2b35dc6cca0e
# ╟─253f4da0-2433-11eb-1e48-4906059607d3
# ╠═1e06178a-1fbf-11eb-32b3-61769a79b7c0
# ╟─fe3304f8-2668-11eb-066d-fdacadce5a19
# ╠═930d7154-1fbf-11eb-1c3a-b1970d291811
# ╟─1312525c-1fc0-11eb-2756-5bc3101d2260
# ╠═c4398f9c-1fc4-11eb-0bbb-37f066c6027d
# ╟─7f961bc0-1fc5-11eb-1f18-612aeff0d8df
# ╟─25f92dec-1fc4-11eb-055d-f34deea81d0e
# ╟─fa7e6f7e-2434-11eb-1e61-1b1858bb0988
# ╟─16348b6a-1fc2-11eb-0b9c-65df528db2a1
# ╟─e296c6e8-259c-11eb-1385-53f757f4d585
# ╠═a86f13de-259d-11eb-3f46-1f6fb40020ce
# ╟─3d66bd30-259d-11eb-2694-471fb3a4a7be
# ╠═5f82dec8-259e-11eb-2f4f-4d661f44ef41
# ╟─56b68356-2601-11eb-39a9-5f4b8e580b87
# ╟─7d815988-1fc7-11eb-322a-4509e7128ce3
# ╟─aed8f00e-266b-11eb-156d-8bb09de0dc2b
# ╠═b9f882d8-266b-11eb-2998-75d6539088c7
# ╟─269200ec-259f-11eb-353b-0b73523ef71a
# ╠═e10a9b70-25a0-11eb-2aed-17ed8221c208
# ╟─2dfab366-25a1-11eb-15c9-b3dd9cd6b96c
# ╠═50ea30ba-25a1-11eb-05d8-b3d579f85652
# ╟─51e2e742-25a1-11eb-2511-ab3434eacc3e
# ╟─bade1372-25a1-11eb-35f4-4b43d4e8d156
# ╠═02232964-2603-11eb-2c4c-c7b7e5fed7d1
# ╠═736ed1b6-1fc2-11eb-359e-a1be0a188670
# ╠═49cb5174-1fc3-11eb-3670-c3868c9b0255
# ╟─f3abc83c-1fc7-11eb-1aa8-01ce67c8bdde
# ╠═3d72ab3a-2689-11eb-360d-9b3d829b78a9
# ╠═1f148d9a-1fc8-11eb-158e-9d784e390b24
# ╟─a618a7c6-9f8c-4d50-ba0a-9e0163560367
# ╠═e5673105-7f78-447c-87be-c8d858b9e836
# ╟─cf8dca6c-1fc8-11eb-1f89-099e6ba53c22
# ╠═02173c7a-2695-11eb-251c-65efb5b4a45f
# ╟─440271b6-25e8-11eb-26ce-1b80aa176aca
# ╠═cf276892-25e7-11eb-38f0-03f75c90dd9e
# ╟─5b5f25f0-266c-11eb-25d4-17e411c850c9
# ╟─7bad483f-66de-42ee-aaac-de8fcc91039e
# ╟─971f401e-266c-11eb-3104-171ae299ef70
# ╠═746aa5bc-266c-11eb-14c9-63ccc313f5de
# ╟─a919d584-2670-11eb-1cf9-2327c8135d6d
# ╠═bfb07a0a-2670-11eb-3938-772499c637b1
# ╟─12cbbab0-2671-11eb-2b1f-038c206e84ce
# ╠═9596c2dc-2671-11eb-36b9-c1af7e5f1089
# ╟─4b091fac-2672-11eb-0db8-75457788d85e
# ╟─9cdc5f84-2671-11eb-3c78-e3495bc64d33
# ╠═f688f9f2-2671-11eb-1d71-a57c9817433f
# ╠═049a866e-2672-11eb-29f7-bfea7ad8f572
# ╠═09901de6-2672-11eb-3d50-05b176b729e7
# ╠═aea0d0b4-2672-11eb-231e-395c863827d3
# ╟─9c32db5c-1fc9-11eb-029a-d5d554de1067
# ╠═19957754-252d-11eb-1e0a-930b5208f5ac
# ╠═40f1e7d8-252d-11eb-0549-49ca4e806e16
# ╟─ee1be5dc-252b-11eb-0865-291aa823b9e9
# ╟─06c5139e-252d-11eb-2645-8b324b24c405
# ╠═f2e55166-25ff-11eb-0297-796e97c62b07
# ╟─1ea81214-1fca-11eb-2442-7b0b448b49d6
# ╟─3e310cf8-25ec-11eb-07da-cb4a2c71ae34
# ╟─d6d1b312-2543-11eb-1cb2-e5b801686ffb
# ╠═378aed18-252b-11eb-0b37-a3b511af2cb5
# ╟─3cbc95ba-2685-11eb-3810-3bf38aa33231
# ╟─68b2a560-2536-11eb-0cc4-27793b4d6a70
# ╟─0e19f82e-2685-11eb-2e99-0d094c1aa520
# ╟─1eabe908-268b-11eb-329b-b35160ec951e
# ╠═1d388372-2695-11eb-3068-7b28a2ccb9ac
# ╠═272f8910-a7b1-4633-b6c4-eedd1b8ea82f
# ╟─53c2eaf6-268b-11eb-0899-b91c03713da4
# ╟─06d28052-2531-11eb-39e2-e9613ab0401c
# ╟─4c9173ac-2685-11eb-2129-99071821ebeb
# ╠═736515ba-2685-11eb-38cb-65bfcf8d1b8d
# ╟─8b06b944-268c-11eb-0bfc-8d4dd21e1f02
# ╟─09ce27ca-268c-11eb-0cdd-c9801db876f8
# ╟─298deff4-2676-11eb-2595-e7e22f613ea1
# ╟─2bbf5a70-2676-11eb-1085-7130d4a30443
# ╟─de95efae-2675-11eb-0909-73afcd68fd42
# ╟─c78e02b4-268a-11eb-0af7-f7c7620fcc34
# ╠═d7801e88-2530-11eb-0b93-6f1c78d00eea
# ╠═607058ec-253c-11eb-0fb6-add8cfb73a4f
# ╟─9c1f73e0-268a-11eb-2bf1-216a5d869568
# ╟─11096250-2544-11eb-057b-d7112f20b05c
# ╠═9eb07a6e-2687-11eb-0de3-7bc6aa0eefb0
# ╟─cb15cd88-25ed-11eb-2be4-f31500a726c8
# ╟─232b9bec-2544-11eb-0401-97a60bb172fc
# ╟─36e2dfea-2433-11eb-1c90-bb93ab25b33c
# ╟─36ea4410-2433-11eb-1d98-ab4016245d95
# ╟─36f8c1e8-2433-11eb-1f6e-69dc552a4a07
# ╟─37061f1e-2433-11eb-3879-2d31dc70a771
# ╟─371352ec-2433-11eb-153d-379afa8ed15e
# ╟─372002e4-2433-11eb-0b25-39ce1b1dd3d1
# ╟─372c1480-2433-11eb-3c4e-95a37d51835f
# ╟─3737be8e-2433-11eb-2049-2d6d8a5e4753
# ╟─374522c4-2433-11eb-3da3-17419949defc
# ╟─37552044-2433-11eb-1984-d16e355a7c10
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
