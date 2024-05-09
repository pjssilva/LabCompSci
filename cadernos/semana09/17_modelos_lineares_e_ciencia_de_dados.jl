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

# ╔═╡ d155ea12-9628-11eb-347f-7754a33fd403
begin
    using Plots
	using PlutoUI
	using DataFrames
	using CSV
	using GLM
	using Distributions
    using Statistics
	using LinearAlgebra
	using Distributions
end

# ╔═╡ adda160f-2db3-47b9-9faa-88fbb450b398
md"Tradução livre de [liinearmodel_datascience.jl](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week9/linearmodel_datascience.jl)."

# ╔═╡ 01506de2-918a-11eb-2a4d-c554a6e54631
TableOfContents(title = "📚 Índice", aside = true)

# ╔═╡ 877deb2c-702b-457b-a54b-f27c277928d4
md"""
# Alguns conceitos para Estatística em Julia

Como já disse, o valor prático de uma linguagem não reside apenas em sua sintaxe e funcionalidades principais, mas também no seu ecossistema de pacotes. Já vimos vários exemplos disso e agora veremos mais um: Ciência de Dados. Um dos principais desafios em Ciência de Dados é ler as grandes bases de dados e disponibilizá-las para serem manipuladas com facilidade pela linguagem. Nesse mundo uma biblioteca dominou: *Pandas* (de Python). Vamos agora ver uma alternativa disponível em Julia, que adotou algumas opções diferentes, mas que procurar preencher o mesmo nicho.

- Data Frames (`DataFrames.jl`).
- `CSVread`, `CSVwrite` (`CSV.jl`).
- `lm` (modelo linear) (`GLM.jl`).
- `@formula` (macro de fórmula para especificar as variáveis para análise) (`GLM.jl`).
- Sublinha como separados de dígitos (`1_000` como 1000).
- O valor de simulações rápidas.
"""

# ╔═╡ 36ce167f-382c-4b9a-be34-83250b10c4e5
md"""
Nessa aula vamos analisar uma aplicação estatística real e com isso entender um pouco melhor como ela pode ser de usada. Nesse contexto, é muito útil ser capaz de fazer simulações rapidamente.
"""

# ╔═╡ 83912943-a847-420a-bfdb-450027b631e8
md"""
# Conjunto de dados de Fahrenheit e Celsius
"""

# ╔═╡ 280d112f-d34a-4cc4-9e3a-4ebbfcd5eb51
n = 10

# ╔═╡ b5031c96-db57-4baf-b271-6bb12e29de9b
x = sort(rand(-10:100, n))

# ╔═╡ c2f77e8f-a8c0-4144-a8b4-b25dd98ed234
y = 5 / 9 .* (x .- 32)

# ╔═╡ 8e422886-74ef-4c0f-be1e-fda238c8db44
[x y]

# ╔═╡ ad161b98-f4a1-42ac-ad4f-8b71fabcfde9
begin
    plot(x, y, marker = :c, markercolor = :red, legend = false)
    xlabel!("°F")
    annotate!(-4, 16, text("°C", 11))
end

# ╔═╡ ca21122a-2522-482a-b7ef-bd73e96cb5a9
md"""
## Julia: Data Frames
Uma das maneiras de se pensar em um Data Frame é numa matrix, uma tabela, com rótulos para as colunas.
"""

# ╔═╡ 41e05b1e-8b5e-45e3-91bb-01355ade9f3d
md"""
### Data Frame por Colunas com rótulos
"""

# ╔═╡ 9d2e3861-ca36-406e-952d-831ca3947e44
data = DataFrame(°F = x, °C = y) # Label = data

# ╔═╡ e73854ed-3581-41c4-ada5-e48242033759
md"""
### Data Frame a partir de uma matriz
"""

# ╔═╡ 9873d944-b611-46f9-82a7-0cf714a3078c
begin
    data2 = DataFrame([x y], :auto) # convert Matrix to DataFrame
    rename!(data2, ["°F", "°C"]) # add column labels
end

# ╔═╡ 2be44753-afee-4125-b6bc-8866d2293dc2
Matrix(data2) # Convert back to a matrix (lose label information)

# ╔═╡ 6e07e8fb-fe51-4b37-bfb2-d1466e768754
md"""
## Julia: um comentário sobre tipos

Lembre-se que em Julia matrizes são sempre do mesmo tipo. Então ao criar uma matriz por concatenação, por exemplo por `[x y]` a linguagem irá converter todos os valores para um tipo comum se possível. Nesse caso seria para `Float64`. Já em Data Frames, as colunas podem ter tipos diferentes.
"""

# ╔═╡ a755e58a-b16c-4d3b-a85f-81ccf374793f
md"""
# Lendo / Escrevendo arquivos CSV (valores separados por vírgula)
"""

# ╔═╡ f1e10fb7-adac-4083-8977-616a505fd591
md"""
O uso de arquivos CSV é bem comum nesse domínio. Isso permite uma fácil interoperabilidade com planilhas eletrônicas e outras fontes de dados. 

  ### Escrevendo um arquivo CSV
"""

# ╔═╡ 2e42986c-2de3-49e6-9c29-a7313c0b1da8
CSV.write("testCSVwrite.csv", data)

# ╔═╡ 22758dd6-9d04-4616-ba99-1430f2dedf9a
md"""
 ### Lendo um arquivo CSV
"""

# ╔═╡ aff6a616-6d8b-4584-a6f2-195decef7774
data_again = CSV.read("testCSVwrite.csv", DataFrame)

# ╔═╡ 338da13a-3c26-4366-a669-ac3e24f31577
data_again[:, "°F"] #or data_again[:,1]

# ╔═╡ 5a742546-1e4d-4aee-bed1-cb10c543e439
data_again[:, 1]

# ╔═╡ 13c0052e-09d8-4f9a-8243-c67e580bcf43
md"""
## Um aviso aos brasileiros

Ler e escrever CSVs pode ser delicado. Isso porque diferentes línguas têm diferentes convenções. Por exemplo, em português a vírgula tem um significado especial. Ela representa o ponto do número onde a informação passa representar valores menores que a unidade. Em inglês esse símbolo é o ponto. Nesse sentido é bem comum arquivos CSV gerados por planilhas em português usarem outros separador, como o ponto-e-vírgula. Há ainda outros exemplos onde essas diferenças podem ser importantes, como em datas.

A função `read` da `CSV.j` possui várias opções para costumizar a leitura, em particular para lidar com essas diferenças associadas a linguagem. Leia com calma a sua [documentação](https://csv.juliadata.org/stable/reading.html#CSV.read).
"""

# ╔═╡ 6a9c8c9a-fac7-42f7-976d-3168132cae48
md"""
# Dados ruidosos

## Adicionando ruído em nossa leitura de Celsius
"""

# ╔═╡ 83c28c76-2eab-49f9-9999-05df85054520
md"""
#### Um slider para o ruído (assim podemos recuperá-lo facilmente)
"""

# ╔═╡ ba671804-dc6d-415c-89de-9cf6294907b3
md"""
noise = $(@bind noise Slider(0:.5:100, show_value = true ))
"""

# ╔═╡ 3c038b68-8676-4877-9720-38da7c4e0e0e
begin
    noisy_data = copy(data)  # Noisy DataFrame
    noisy_data[:, "°C"] .+= noise * randn(n)
    yy = noisy_data[:, "°C"]
    noisy_data
end

# ╔═╡ e8683a71-5822-4491-9ccd-20e0fc3bf531
md"""
## A tabela misteriosa que sai do software estatístico

A biblioteca `GLM.jl` possui código para vários modelos estatísticos. Podemos usá-la para ajustar os nossos dados a uma reta e obter várias medidas da qualidade desse ajuste. Abaixo usamos um "modelo linear simples" (`lm`) para fazer esse ajuste. O que é faz é um ajuste por quadrados mínimos. Há também a opção de quadrados mínimos com pesos que trata erros com diferentes pesos.
"""

# ╔═╡ 0489e5d8-51ca-4955-83e1-95ea353d9cf2
ols = lm(@formula(°C ~ 1 + °F), noisy_data)

# ╔═╡ 9a65aee4-ab8e-4ab7-be6f-cc2a2e9d5127
noisy_data

# ╔═╡ c3539f42-6ca7-47fb-9707-4d11c9e76643
md"""
Essa aula vai tentar explicar melhor o significado dos valores nessa tabela.
"""

# ╔═╡ 469d809f-424f-4595-ad43-a5b2cc055304
md"""
# Algumas palavras sobre regressão
"""

# ╔═╡ 6128b8fd-9b85-4896-a0bf-934a0733fafb
md"""
A coluna `Coef.` na tabela apresenta a inclinação e intercepto da linha que melhor ajusta os dados.
"""

# ╔═╡ 9eb7caaa-438d-4bcb-9c54-4a0fa72c61de
b, m = [one.(x) x] \ yy  # The mysterious linear algebra solution using "least squares"

# ╔═╡ 5a877e40-a101-4f7d-b2a1-ef4cfe5d8807
begin

    scatter(x, yy, marker = :c, markercolor = :red, label = "noisy data", ylims = (-40, 60))
    for i = 1:length(data[:, 2])
        plot!([x[i], x[i]], [m * x[i] + b, yy[i]], color = :gray, ls = :dash, label = false)
    end
    xlabel!("°F")
	ylabel!("°C")
    title!("Temperature conversion")
    plot!(x, m .* x .+ b, color = :blue, label = "best fit line")
    plot!(x, y, alpha = 0.5, color = :red, label = "theory") # theoretical 
    plot!(legend = :top)
end

# ╔═╡ 0e8fce45-f1c0-41d4-996a-d6093182afee
function linear_regression(x, y)      # a direct computation from the data
    n = length(x)
    x0 = x .- mean(x)
    y0 = y .- mean(y)

    mᵉ = sum(x0 .* y0) / sum(x0 .^ 2) # slope estimate
    bᵉ = mean(y) - mᵉ * mean(x)       # intercept estimate

    σᵉ = sum((mᵉ .* x .+ bᵉ .- y) .^ 2) / (n - 2) # noise estimate
    bᵉ, mᵉ, σᵉ
end

# ╔═╡ 71590890-38b6-440e-b61b-ece6c49ac602
linear_regression(x, yy)

# ╔═╡ f7cc7146-9ee6-4d87-b024-2a91863f4b24
md"""
[Mas porque se chama "regressão"?](http://blog.minitab.com/blog/statistics-and-quality-data-analysis/so-why-is-it-called-regression-anyway) O sentido original dado por Galton não é o mesmo que usamos hoje. Se quiser saber a história, dê uma lida no link.
"""

# ╔═╡ f64815e2-44b8-4585-9269-9a62655c984c
md"""
# Explicando o que é um _modelo_

Um modelo é uma explicação, uma lei, que tenta representar um fenômeno. Tipicamente modelos dependem de parâmetros que são desconhecidos e uma das tarefas importantes é _identificar_ esses parâmetros de forma a tornar o modelo geral representativo de um conjunto específico de dados. Esse processo também é conhecido como _ajuste_.

No nosso exemplo, o modelo é `y = m*x + b + σ*randn()`. Isso que dizer que acreditamos que os valores medidos obedecem a essa lei e que existem valores b, m e σ que permitem explicar o fenômeno. Porém, não os conhecemos.

Por outro lado, temos dados de medidas y (como função de) x que nos permite calcular estimativas bᵉ,  mᵉ e σᵉ. Note que ao tentar o experimento de novo, devido a sua natureza aleatória, você obteria outros dados. Por sorte estamos no computador e podemos fazer vários experimentos rapidamente e "ver" o que pode ocorrer.

Lembre, num modelo há três tipos diferentes de variáveis. Os _parâmetros_ do modelo, b, m e σ no exemplo acima, que estamos considerando desconhecidos. Há também as variáveis _preditivas_, consideradas conhecidas (sem ruído), e as variáveis de _resposta_ que são ruidosas.
"""

# ╔═╡ feb3c45e-88f4-4ffc-a4a0-e89489187c8d
md"""
## Entendendo a relação `°C ~ 1 + °F`
"""

# ╔═╡ 99069dd7-e088-4626-aa29-e48d6f9a474e
ols

# ╔═╡ 051a9e38-9a84-4ead-96fa-24c86c2b9f2d
md"""
`°C ~ 1 + °F` significa Celsius (y) é da forma (Coef1)*1 + (Coef2)*(°F).

Em geral `y ~ 1 + x1 + x2 + x3` denota que ``y = c_0 + c_1 x_1 + c_2 x_2 + c_3 x_3``, etc.
"""

# ╔═╡ 2f33ee51-0725-46c2-9f1b-a61cd68abab1
md"""
# Simulando o mundo real: rodando muitos modelos ruidosos
"""

# ╔═╡ e4acd97b-22f7-4812-9898-1a485887a5f2
function simulate(σ, howmany)
    [linear_regression(x, y .+ σ * randn(length(x))) for i = 1:howmany]
    #[linear_regression(x,y .+ (σ * sqrt(12)) * (-.5 .+ rand(length(x))))   for i=1:howmany]
    # [linear_regression(x,y .+ (σ ) * ( rand([-1,1],length(x))))   for i=1:howmany]
end

# ╔═╡ 7b94db0d-f46b-4621-9413-1dc787ae9a39
md"""
#### Julia: sublinha como separador de dígitos
"""

# ╔═╡ 4e413b40-81c4-4160-9d01-046c2d179a06
howmany = 100_000

# ╔═╡ d2971801-2cdb-4b9f-8ec8-c74cbb2a0b31
md"""
Desvio padrão para ser usado nos experimentos:

σ = $(@bind σ Slider(0:.1:3, show_value=true, default=1))
"""

# ╔═╡ 51a28b67-ad64-4cf2-a0e6-a78fb101eb15
s = simulate(σ, howmany)

# ╔═╡ d451af49-3139-4329-a885-a210b1760f74
s[1] # first simulation,  intercept, slope, estimation of noise σ²

# ╔═╡ c7455f7a-9c72-42f5-8238-1799cad96f6c
md"""
## Interceptos simulados ($howmany simulações)
"""

# ╔═╡ e1e8c140-bc4e-400d-beb2-0986e071c3a3
begin
    histogram(first.(s), alpha = 0.6, bins = 100, norm = true)
    vline!([-17.777777], lw = 2, color = :red)
    title!("intercept")
    xlims!(-17.7777 - 3, -17.7777 + 3)
    ylims!(0, 1)
    plot!(legend = false)
end

# ╔═╡ 1429be09-a31f-415f-9c3d-f32b085ef68d
md"""
A média experimental do intercepto
"""

# ╔═╡ da321202-0dc5-44ad-aac0-f3ea0d229243
mean(first.(s)), -5*32/9

# ╔═╡ 2aceb366-a067-4271-9362-c320f4735ed1
md"""
O desvio padrão experimental do intercepto
"""

# ╔═╡ 58f548fd-f6d0-479d-8469-bc886783f9a7
std(first.(s))

# ╔═╡ 07be9435-bc07-4a18-aad8-3ff19f5bcce4
md"""
Os estatíticos derivaram a fórmula teórica do desvio pardrão do intercepto como função dos pontos de medida.
"""

# ╔═╡ 1a6ad08d-c3bb-47e7-bdee-156bbff3aeda
sb = σ * norm(x) / norm(x .- mean(x)) / sqrt(n)


# ╔═╡ 9368081d-d78e-44e1-baed-d567fc6321d6
x, n

# ╔═╡ c55e4894-db71-4729-a1a1-5f68b45e3bf5
md"""
## Inclinações (coeficiente angular) simulados ($howmany simulações)
"""

# ╔═╡ f50d66eb-0357-4017-ac9b-99e63cd52dc0
begin
    histogram(getindex.(s, 2), alpha = 0.6, bins = 100, norm = true, legend = false)
    title!("slope")
    vline!([5 / 9], lw=2, color = :red)
    xlims!(5 / 9 - 0.1, 5 / 9 + 0.1)
    ylims!(0, 50)
end

# ╔═╡ 5c7a7361-f0e7-473a-9e38-226828aa00ca
md"""
Média amostral da inclinação:
"""

# ╔═╡ acf0e90e-8f1f-451f-9f0f-70a0bcc7efca
mean(getindex.(s, 2)), 0.555555

# ╔═╡ c9f65e15-f222-4a88-98c2-9e1d8b5ec3eb
md"""
Desvio padrão amostral da inclinação:
"""

# ╔═╡ 2589a369-8b21-406d-906d-71b18e4c7895
std(getindex.(s, 2))

# ╔═╡ ed6a0e6a-2d0c-4f77-9b08-1a5b5d56dd34
md"""
Mais uma vez os estatísticos sabem a fórmula teórica do desvio padrão.
"""

# ╔═╡ 61d1c1f7-e070-413b-8a92-76f44d237206
σ / norm(x .- mean(x))

# ╔═╡ 94d80ad6-0403-4322-aa9f-647c291c19d7
md"""
## Simulated σ ($howmany simulations)
"""

# ╔═╡ ce89b805-39a2-49e6-8781-c557aa73ed27
begin
    histogram(
        last.(s) ./ (σ^2 / (n - 2)),
        alpha = 0.6,
        bins = 100,
        norm = true,
        legend = false,
    )
    title!("residual")
    vline!([n - 2], color = :red, lw = 4)
    xlims!(0,20)
    ylims!(0,.13)
    plot!(x -> pdf(Chisq(n - 2), x), lw = 4, color = :black)
    plot!()

end

# ╔═╡ 37550225-41a9-486a-a028-510edda4a772
md"Média experimental de σ²"

# ╔═╡ 75f9b5e9-775d-4767-9da6-222f977da686
mean(last.(s))

# ╔═╡ 797c9f2f-0b85-4435-b1c0-edc8cf67f738
σ^2

# ╔═╡ 559da1b3-a1f0-4abc-9aa9-be0b69650fd0
md"Desvio padrão da estimativa de σ"

# ╔═╡ 6e0b2452-9f8b-4730-8072-a663704893c5
std(last.(s))

# ╔═╡ 6d7989bd-f505-4035-ab58-4a5c74c6c7cb
md"Valor teórico"

# ╔═╡ bf537a3a-b7c6-4c64-8b44-85511c3d492e
(σ^2 / sqrt((n - 2) / 2))

# ╔═╡ 1340818c-3391-420b-aa94-acaea8a47d7d
md"""
# A tabela resultante de `LinearModel`
"""

# ╔═╡ 829607ff-25e0-4585-9c5c-d132ecb86cc8
ols # = lm(@formula(°C ~ °F), noisy_data)

# ╔═╡ 9233dc6a-7578-4d72-b0c2-c3bb110a9fbe
md"""
## A coluna `Coef.` devolve a fórmula para o melhor ajuste
"""

# ╔═╡ 07e02bb6-380d-40dd-86ad-19d713cd1657
mᵉ, bᵉ, σ²ᵉ = linear_regression(x, yy)

# ╔═╡ b14593ba-cb8c-4f28-8fb0-2d2df479357b
md"""
## A coluna `Std. error`
"""

# ╔═╡ ac204681-b9df-471b-a22e-9d8f68679151
md"""
Vimos acima que os estatísticos conhecem as formulas para o desvio padrão teórico da inclinação e do intercepto (dado o σ):

`std(intercept) = σ * norm(x)  / norm(x .- mean(x)) / sqrt(n)`

` std(slope) =  σ  / norm(x .- mean(x))`
"""

# ╔═╡ 08f43fff-fbd8-468f-8b3b-efd1829f4fc0
md"""
Vamos substituir o σ teórico (desconhecido) por nossa estimativa √σ²ᵉ
"""

# ╔═╡ 43ec6124-c3e5-4f34-b0d9-1a0b069aa3e0
sqrt(σ²ᵉ) * norm(x) / norm(x .- mean(x)) / sqrt(n)

# ╔═╡ 3fe71215-bbf2-40e9-bcfc-0bc9b3ac94c8
sqrt(σ²ᵉ) / norm(x .- mean(x))

# ╔═╡ a2b27841-256e-4898-aeca-04c4f44138fb
md"""
Ôpa, agora sabemos como esses números são calculados. É sempre bom entender o que são os números e ser capaz de reproduzí-los. Ajuda a entender o seu significado e limitações.
"""

# ╔═╡ 8851dca3-e1a6-46b2-9745-f175ef0b0fae
md"""
## A coluna `t`
"""

# ╔═╡ ccfcb4d9-5a88-48fb-9568-1147a74f6eec
md"""
A coluna `t` é obtida simplesmente dividindo a coluna `Coeff.` pela coluna `Std. error`. Ela será usada no teste de hipótese na coluna seguinte.
"""

# ╔═╡ 2c61f48d-3107-4b8f-ad47-d84747fb71a4
-14.9707 / 6.89064, 0.489115 / 0.0948958

# ╔═╡ 13858c0a-3e7a-4742-a821-97dd9a45109d
md"""
### A distribuição t
"""

# ╔═╡ b2c3c1e5-e569-4c6f-bad9-055a25d73dce
md"""
Em uma aula de estatística você deve ter encontrado (ou vai encontrar) uma variável aleatória com distribuição t (e parâmetro k). Ela representa a razão entre uma normal padrão e uma distribuição Χ com parâmetro k e corrigida por um fator $\sqrt{k}$. Vamos simular isso a partir de `randn` e da definição da Χ. Para os dados nos experimentos de hoje em dia, a distribuição normal está próxima da t (já o que o k está associado com o número de amostras, que é tipicamente alto), ao ponto não se usar mais a t. De qualquer forma, usando uma t ou uma normal, usamos essa distribuição porque estamos conscientes que o valor real de σ é desconhecido. Ele foi obtido por estimativa.
"""

# ╔═╡ dbc1dc6d-70cd-4849-8625-e84f2a1f342e
mean(rand(Chi(5), 10000000))

# ╔═╡ 644ba925-2cf0-48f4-8fa7-44a93e56bb05
mean([norm(randn(5)) for i = 1:1000000])

# ╔═╡ 305e4dfc-af7d-4667-8da8-a7ba5fd20fa6
rand_t(k) = sqrt(k) * randn() / norm(randn(k))

# ╔═╡ a648ba4f-fec4-4fa7-b328-1b52070224eb
md"""
k = $(@bind k Slider(3:100, show_value=true))
"""

# ╔═╡ d652df7d-7364-4da4-b51e-9fc88b978cda
begin

    histogram([rand_t(k) for i = 1:100000], norm = true, bins = 500, label = false)
    plot!(x -> pdf(TDist(k), x), lw = 4, color = :red, label = "t dist")
    plot!(x -> pdf(Normal(), x), color = :green, lw = 2, label = "normal dist")
    xlims!(-3, 3)
    ylims!(0, 0.4)
end

# ╔═╡ 2e530106-57a8-46a9-8f99-49a871d43255
md"""
## A coluna `Pr(>|t|)`

A coluna `Pr(>|t|)` é a área dos dados fora do intervalo [-t,t].
"""

# ╔═╡ a990b133-ce50-4edf-81e1-1e78aeff8cd6
md"""
Em estatística nós perguntamos se um coeficiente deve ser considerado nulo (que diz que os dados não tem intercepto ou não dependem de x) or se os coeficientes estimados são significativos com alguma probabilidade. A conluna `Pr(>|t|)` nos dá a probabilidade de aceitarmos a hipótese nula, ou seja que o respectivo coeficiente deve ser simplesmente 0.

Em um teste estatístico correto, você deve decidir em qual nível aceita (ou rejeita) a hipótese. Por exemplo com 0.99, 0.95 ou 0.9 podem ser valores razoáveis. Se o teste der uma probabilidade menor você deve aceitar que os coeficientes são significativos. Você não deve decidir o volor, por exemplo, 0.99 depois de ver os resultados.
"""

# ╔═╡ 3d0ea801-d66b-4e4e-90da-3a7dce28140d
md"""
# Graus de liberdade
"""

# ╔═╡ 6fb223bb-f193-414d-9144-df180d09bea1
md"""
É interessante ver que o soma dos quadrados de uma vetor gaussiano subtraido de sua média é o seu comprimento - 1. Essa é a razão por trás de dividirmos a média da mostra por (n - 1) para estimar a variância.
"""

# ╔═╡ fb495ba4-52e6-4e0d-bd9c-981700edfebc
md"""
Veja quantos graus de liberdade num vetor de normal subtraido da média?
"""

# ╔═╡ cdc4b25d-d05f-40c8-9c79-265876f01523

mean([(v = randn(17); v .-= mean(v); sum(v .^ 2)) for i = 1:1_000_000])

# ╔═╡ 967c5e3e-ab4c-45de-953c-aff6d16229af
md"""
Se você já pensou, como eu, porque dividimos por (n - 1) quando estimamos a variância a partir de uma amostra e não por n, aí está a chave da explicação.
"""

# ╔═╡ Cell order:
# ╟─adda160f-2db3-47b9-9faa-88fbb450b398
# ╠═d155ea12-9628-11eb-347f-7754a33fd403
# ╟─01506de2-918a-11eb-2a4d-c554a6e54631
# ╟─877deb2c-702b-457b-a54b-f27c277928d4
# ╟─36ce167f-382c-4b9a-be34-83250b10c4e5
# ╟─83912943-a847-420a-bfdb-450027b631e8
# ╠═280d112f-d34a-4cc4-9e3a-4ebbfcd5eb51
# ╠═b5031c96-db57-4baf-b271-6bb12e29de9b
# ╠═c2f77e8f-a8c0-4144-a8b4-b25dd98ed234
# ╠═8e422886-74ef-4c0f-be1e-fda238c8db44
# ╠═ad161b98-f4a1-42ac-ad4f-8b71fabcfde9
# ╟─ca21122a-2522-482a-b7ef-bd73e96cb5a9
# ╟─41e05b1e-8b5e-45e3-91bb-01355ade9f3d
# ╠═9d2e3861-ca36-406e-952d-831ca3947e44
# ╟─e73854ed-3581-41c4-ada5-e48242033759
# ╠═9873d944-b611-46f9-82a7-0cf714a3078c
# ╠═2be44753-afee-4125-b6bc-8866d2293dc2
# ╟─6e07e8fb-fe51-4b37-bfb2-d1466e768754
# ╟─a755e58a-b16c-4d3b-a85f-81ccf374793f
# ╟─f1e10fb7-adac-4083-8977-616a505fd591
# ╠═2e42986c-2de3-49e6-9c29-a7313c0b1da8
# ╟─22758dd6-9d04-4616-ba99-1430f2dedf9a
# ╠═aff6a616-6d8b-4584-a6f2-195decef7774
# ╠═338da13a-3c26-4366-a669-ac3e24f31577
# ╠═5a742546-1e4d-4aee-bed1-cb10c543e439
# ╟─13c0052e-09d8-4f9a-8243-c67e580bcf43
# ╟─6a9c8c9a-fac7-42f7-976d-3168132cae48
# ╟─83c28c76-2eab-49f9-9999-05df85054520
# ╟─ba671804-dc6d-415c-89de-9cf6294907b3
# ╟─3c038b68-8676-4877-9720-38da7c4e0e0e
# ╠═5a877e40-a101-4f7d-b2a1-ef4cfe5d8807
# ╟─e8683a71-5822-4491-9ccd-20e0fc3bf531
# ╠═0489e5d8-51ca-4955-83e1-95ea353d9cf2
# ╠═9a65aee4-ab8e-4ab7-be6f-cc2a2e9d5127
# ╟─c3539f42-6ca7-47fb-9707-4d11c9e76643
# ╟─469d809f-424f-4595-ad43-a5b2cc055304
# ╟─6128b8fd-9b85-4896-a0bf-934a0733fafb
# ╠═9eb7caaa-438d-4bcb-9c54-4a0fa72c61de
# ╠═0e8fce45-f1c0-41d4-996a-d6093182afee
# ╠═71590890-38b6-440e-b61b-ece6c49ac602
# ╟─f7cc7146-9ee6-4d87-b024-2a91863f4b24
# ╟─f64815e2-44b8-4585-9269-9a62655c984c
# ╟─feb3c45e-88f4-4ffc-a4a0-e89489187c8d
# ╠═99069dd7-e088-4626-aa29-e48d6f9a474e
# ╟─051a9e38-9a84-4ead-96fa-24c86c2b9f2d
# ╟─2f33ee51-0725-46c2-9f1b-a61cd68abab1
# ╠═e4acd97b-22f7-4812-9898-1a485887a5f2
# ╟─7b94db0d-f46b-4621-9413-1dc787ae9a39
# ╠═4e413b40-81c4-4160-9d01-046c2d179a06
# ╟─d2971801-2cdb-4b9f-8ec8-c74cbb2a0b31
# ╠═51a28b67-ad64-4cf2-a0e6-a78fb101eb15
# ╠═d451af49-3139-4329-a885-a210b1760f74
# ╟─c7455f7a-9c72-42f5-8238-1799cad96f6c
# ╠═e1e8c140-bc4e-400d-beb2-0986e071c3a3
# ╟─1429be09-a31f-415f-9c3d-f32b085ef68d
# ╠═da321202-0dc5-44ad-aac0-f3ea0d229243
# ╟─2aceb366-a067-4271-9362-c320f4735ed1
# ╠═58f548fd-f6d0-479d-8469-bc886783f9a7
# ╟─07be9435-bc07-4a18-aad8-3ff19f5bcce4
# ╠═1a6ad08d-c3bb-47e7-bdee-156bbff3aeda
# ╠═9368081d-d78e-44e1-baed-d567fc6321d6
# ╟─c55e4894-db71-4729-a1a1-5f68b45e3bf5
# ╠═f50d66eb-0357-4017-ac9b-99e63cd52dc0
# ╟─5c7a7361-f0e7-473a-9e38-226828aa00ca
# ╠═acf0e90e-8f1f-451f-9f0f-70a0bcc7efca
# ╟─c9f65e15-f222-4a88-98c2-9e1d8b5ec3eb
# ╠═2589a369-8b21-406d-906d-71b18e4c7895
# ╟─ed6a0e6a-2d0c-4f77-9b08-1a5b5d56dd34
# ╠═61d1c1f7-e070-413b-8a92-76f44d237206
# ╟─94d80ad6-0403-4322-aa9f-647c291c19d7
# ╠═ce89b805-39a2-49e6-8781-c557aa73ed27
# ╟─37550225-41a9-486a-a028-510edda4a772
# ╠═75f9b5e9-775d-4767-9da6-222f977da686
# ╠═797c9f2f-0b85-4435-b1c0-edc8cf67f738
# ╟─559da1b3-a1f0-4abc-9aa9-be0b69650fd0
# ╠═6e0b2452-9f8b-4730-8072-a663704893c5
# ╟─6d7989bd-f505-4035-ab58-4a5c74c6c7cb
# ╠═bf537a3a-b7c6-4c64-8b44-85511c3d492e
# ╟─1340818c-3391-420b-aa94-acaea8a47d7d
# ╠═829607ff-25e0-4585-9c5c-d132ecb86cc8
# ╟─9233dc6a-7578-4d72-b0c2-c3bb110a9fbe
# ╠═07e02bb6-380d-40dd-86ad-19d713cd1657
# ╟─b14593ba-cb8c-4f28-8fb0-2d2df479357b
# ╟─ac204681-b9df-471b-a22e-9d8f68679151
# ╟─08f43fff-fbd8-468f-8b3b-efd1829f4fc0
# ╠═43ec6124-c3e5-4f34-b0d9-1a0b069aa3e0
# ╠═3fe71215-bbf2-40e9-bcfc-0bc9b3ac94c8
# ╟─a2b27841-256e-4898-aeca-04c4f44138fb
# ╟─8851dca3-e1a6-46b2-9745-f175ef0b0fae
# ╟─ccfcb4d9-5a88-48fb-9568-1147a74f6eec
# ╠═2c61f48d-3107-4b8f-ad47-d84747fb71a4
# ╟─13858c0a-3e7a-4742-a821-97dd9a45109d
# ╠═b2c3c1e5-e569-4c6f-bad9-055a25d73dce
# ╠═dbc1dc6d-70cd-4849-8625-e84f2a1f342e
# ╠═644ba925-2cf0-48f4-8fa7-44a93e56bb05
# ╠═305e4dfc-af7d-4667-8da8-a7ba5fd20fa6
# ╟─a648ba4f-fec4-4fa7-b328-1b52070224eb
# ╠═d652df7d-7364-4da4-b51e-9fc88b978cda
# ╟─2e530106-57a8-46a9-8f99-49a871d43255
# ╟─a990b133-ce50-4edf-81e1-1e78aeff8cd6
# ╟─3d0ea801-d66b-4e4e-90da-3a7dce28140d
# ╟─6fb223bb-f193-414d-9144-df180d09bea1
# ╟─fb495ba4-52e6-4e0d-bd9c-981700edfebc
# ╠═cdc4b25d-d05f-40c8-9c79-265876f01523
# ╟─967c5e3e-ab4c-45de-953c-aff6d16229af
