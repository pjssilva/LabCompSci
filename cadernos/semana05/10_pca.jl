### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ cf82077a-81c2-11eb-1de2-09ed6c35d810
begin
    import ImageMagick
	import ForwardDiff
    using PlutoUI
    using Colors
	using ColorSchemes
	using Images
    using LaTeXStrings
    using Plots
    gr()

    using Statistics, LinearAlgebra  # standard libraries
end

# ╔═╡ 03825a62-7ffd-4bfe-8876-79db1a3131fa
md"Tradução livre de [pca.jl](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week5/pca.jl)."

# ╔═╡ c593a748-81b6-11eb-295a-a9800f9dec6d
PlutoUI.TableOfContents(aside = true)

# ╔═╡ deb2af50-8524-11eb-0dd4-9d799ff6d3e2
md"""
# Introdução: entendendo dados

Vamos agora passar a olhar outros tipos de **dados** além de imagens. O nosso objetivo será extrair informação desses dados usando métodos estatísticos, nesse primeiro exemplo iremos usar [**análise de componentes principais**](https://en.wikipedia.org/wiki/Principal_component_analysis).  

Esse método procura identificar quais são as _direções_ mais importantes para explicar os dados, para capturar a sua variação. Com isso seremos capazes de [diminuir a dimensionalidade](https://en.wikipedia.org/wiki/Dimensionality_reduction) (número de variáveis úteis ou explicativas) do dados.

Podemos encarar essa ideia como uma forma de buscar **estrutura** especial nos dados e, então, explorar esse conhecimento. Ela também leva naturalmente a alguns conceitos de **aprendizado de máquina**.
"""

# ╔═╡ 2e50a070-853f-11eb-2045-b1cc43c29768
md"""
# Posto de uma matriz
"""

# ╔═╡ ed7ff6b2-f863-11ea-1a59-eb242a8674e3
md"## Bandeiras"

# ╔═╡ fed5845e-f863-11ea-2f95-c331d3c62647
md"Vamos relembrar algumas ideias da última aula. Mais especificamente os conceitos de _tabelas de multiplicação_ e/ou _produtos externos_:"

# ╔═╡ 0e1a6d80-f864-11ea-074a-5f7890180114
outer(v, w) = [x * y for x in v, y in w]

# ╔═╡ 2e497e30-f895-11ea-09f1-d7f2c1f61193
outer(1:10, 1:10)

# ╔═╡ 4773686e-f955-4422-9b5c-18c51a3b6a8d
collect(1:10) * collect(1:10)'

# ╔═╡ cfdd04f8-815a-11eb-0409-79a2599c29ab
md"""
Olhando a fórmula do produto externo, ou a própria definição de uma tabela de multiplicação, vemos que cada coluna é um múltiplo (mas não necessariamente um múltiplo por um número inteiro) de qualquer uma das outras colunas (não nulas). Cada linha também é um múltiplo das outras linhas (não nulas). 

Esse é um exemplo de uma matriz que possui _estrutura especial_. De fato podemos evitar o armazenamento de todos os m × n números e armazenar apenas uma das colunas (não nulas) e os fatores multiplicativos, totalizando m + n informações. Isso é potencialmente muito menos informação. De posse disso, e da regra de formação, somos capazes de restaurar completamente a tabela original. 
"""

# ╔═╡ ab3d55cc-f905-11ea-2f22-5398f3aca803
md"""
Um fato, "curioso", é que algumas bandeiras podem ser vistas como exemplos simples de produtos externos. Vejamos um exemplo.
"""

# ╔═╡ 13b6c108-f864-11ea-2447-2b0741f15c7b
flag = outer([1, 0.1, 2], ones(6))

# ╔═╡ e66b30a6-f914-11ea-2c0f-35282d45a30a
ones(6)

# ╔═╡ 71d1b12e-f895-11ea-39df-f5c18a7766c3
flag2 = outer([1, 0.1, 2], [1, 1, 1, 3, 3, 3])

# ╔═╡ 356267fa-815b-11eb-1c57-ad14fd6e91a7
md"""
Porém, nem sempre é simples identificar visualmente que uma matriz provém de um produto externo. Mas tipicamenet conseguimos identificar que há alguma estrutura especial subjacente.
"""

# ╔═╡ cdbe1d8e-f905-11ea-3884-efeeef386dda
md"## Posto de matriz"

# ╔═╡ d9aa9af0-f865-11ea-379e-f16b452bd94c
md"""
Se uma matriz não nula pode ser escrita como uma _única_ tabela de multiplicação / produto externo, dizemos que ela tem **posto 1**. Isso porque o seu espaço imagem, que é o espaço gerado pelas colunas da matriz, é obtido a partir de um único vetor que é "repetido" (a menos de fatores multiplicativos) em todas as colunas. Já, se forem necessários a soma de dois produtos externos, a matriz terá **posto 2** (pense um pouco sobre isso) e assim sucessivamente.
"""

# ╔═╡ 2e8ae92a-f867-11ea-0219-1bdd9627c1ea
md"Vejamos como se parece uma matriz aleatória de posto 1:"

# ╔═╡ 9ad13804-815c-11eb-0253-8f8baf15eee3
w = 300

# ╔═╡ 38adc490-f867-11ea-1de5-3b633aff7c97
data = outer([1; 0.4; rand(50)], rand(w));

# ╔═╡ 946fde3c-815b-11eb-3039-db4105bc43ab
md"""
Ela possui esse visual quadriculado ou de "tabuleiro".
"""

# ╔═╡ ab924210-815b-11eb-07fe-411db58fbc3a
md"""
Agora uma matriz aleatória de posto 2:
"""

# ╔═╡ b5094384-815b-11eb-06fd-1f40134c6fd8
md"""
Ela já se mostra um pouco menos regular, mas ainda demonstra ter estrutura especial.
"""

# ╔═╡ cc4f3fee-815b-11eb-2982-9b797b806b45
md"""
#### Exercício:

Crie uma visualização iterativa para uma matriz aletória de posto $n$ em que é possível variar o $n$.
"""

# ╔═╡ dc55775a-815b-11eb-15b7-7993190bffab
md"""
## Adicionando ruído
"""

# ╔═╡ 9cf23f9a-f864-11ea-3a08-af448aceefd8
md"""
Mas, como vocês aprenderam em laboratório de física, dados nunca são obtido de maneira perfeita. Sempre há algum algum **ruído** aleatório, mesmo que advindo do processo de medição. O que ocorre se adicionamos ruído aleatório em uma matriz de posto 1?
"""

# ╔═╡ a5b62530-f864-11ea-21e8-71ccfed487f8
noisy_data = data .+ 0.03 .* randn.();

# ╔═╡ c41df86c-f865-11ea-1253-4942bbdbe9d2
md"""
A matriz com o ruído passa a ter posto "matemático" maior que 1. Porém, visualmente, ainda conseguimos identificar o padrão de tabuleiro e com isso intuir que ela está próxima de uma matriz de posto 1.

Dada um matriz, há alguma forma sistemática de descobrir que ela está próxima de uma matriz de posto 1, ou de posto baixo? Em outras palavras, é possível dizer se uma matriz está próxima de uma matriz mais simples? Vamos ver no restante da aula que se "simples" quer dizer "posto pequeno", conseguimos fazer isso com decomposições de valores singulares."""

# ╔═╡ 7fca33ac-f864-11ea-2a8b-933eb382c172
md"## Imagens como (visualizações) de dados"

# ╔═╡ 283f5da4-f866-11ea-27d4-957ca2551b92
md"""
Como dissemos, estamos lidando com dados que não são necessariamente imagens, mas sim observações de algum fenônomeno. De fato em Ciência de Dados s observações vêm tipicamente como linhas de uma matriz de dados observados, chamada de *matriz de dados*.

Por outro lado, sempre podemos pegar os dados e gerar visualizações a partir deles como forma de ganhar intuição (_insight_) sobre o seu comportamento. 

Vamos fazer isso a partir das primeiras duas linhas dos dados aleatórios gerados acima, que vamos interpretar como coordenadas $x$ e $y$ no plano.
"""

# ╔═╡ 54977286-f908-11ea-166d-d1df33f38454
data[1:2, 1:20]

# ╔═╡ 7b4e90b4-f866-11ea-26b3-95efde6c650b
begin
    xx = data[1, :]
    yy = data[2, :]
end

# ╔═╡ f574ad7c-f866-11ea-0efa-d9d0602aa63b
md"# Dos dados a visualizações"

# ╔═╡ 8775b3fe-f866-11ea-3e6f-9732e39a3525
md"""
Vamos visualizar esses dados com o pacote `Plots.jl`, passando-os como as coordenadas $x$ e $y$ de uma nuvem de pontos. No caso dos dados originais e ruidosos vemos o seguinte:
"""

# ╔═╡ 1147cbda-f867-11ea-08fa-ef6ed2ae1e93
begin
    xs = noisy_data[1, :]
    ys = noisy_data[2, :]

    default(alpha = 0.3, leg = :topright, framestyle = :origin, size = (500, 400), ratio = 1)

    scatter(xs, ys, label = "ruidoso", m = :dot, ms = 4)

    scatter!(xx, yy, label = "Posto 1", m = :square, ms = 3, c = :red)

    title!("Plotar uma matriz de posto 1 gera uma reta!")
end

# ╔═╡ 8a611e36-f867-11ea-121f-317b7c145fe3
md"
Podemos ver que a matriz exata de posto 1 possui linhas que se *encaixam perfeitamente em uma linha reta que passa pela origem*. Isso é natural, elas são sempre o mesmo par $(x, y)$ multiplicado por diferentes valores. 

Por exemplo, se $(x_1, x_2)$ e $(y_1, y_2)$ vêm de duas linhas, sabemos que existe $c$ tal que $y_1 = c x_1$ e $y_2 = c x_2$. Portantanto, $y_2 / x_2 = y_1 / x_1$, que mostra justamente que pertencem a uma mesma linha que passa pela origem.

Já os dados ruidosos não pertecem mais a essa linha, mas ainda se mantém próximos.
"

# ╔═╡ f7371934-f867-11ea-3b53-d1566684585c
md"Então, a partir de um conjunto de dados conseguimos uma forma *automatizável* de verificar se eles pertecem a uma mesma linha ou se estão próximos de uma linha?

Alguém pode estar pesando em fazer quadrados mínimos, mas vamos tentar adotar um caminho alternativo.
"

# ╔═╡ 987c1f2e-f868-11ea-1125-0d8c02843ae4
md"""
## Usando estatísticas para medir o "tamanho" de uma nuvem de dados
"""

# ╔═╡ 9e78b048-f868-11ea-192e-d903265d1eb5
md"Olhano a nuvem de pontos, podemos pensar naturalmente em *medir* suas dimensões: quão largo ou alto ele é? Em outras palavras, o quando ele varia ao longo dos eixos?"

# ╔═╡ 24df1f32-ec90-11ea-1f6d-03c1bfa5df8e
md"""Por exemplo, podemos focar em calcular a largura dos dados, ou seja o quanto ele varia em sua coordenada $x$. Para isso podemos ignorar completamente a informação na direção $y$.
"""

# ╔═╡ b264f724-81bf-11eb-1052-295b81cde5fb
md"""
Para isso, parece natural simplesmente varrer os dados e pegar os valores máximo e mínimo de $x$. Porém os dados podem conter alguns poucos valores muito grandes, ou muito pequenos, muitas vezes chamados de **outliers**. Se existirem, apesar de pouco comuns, eles vão definir completamente os valores máximos e mínimos. Isso indepenpendetemente do comportamento da **maior parte** dos dados.

Outra opção é usar técnicas estatísticas, onde consideramos todos os dados e calculamos médias. Esse processo deve diluir o impacto dos possíveis outliers capturando melhor o comportamento **global**.
"""

# ╔═╡ 09991230-8526-11eb-04aa-fb904bd2036c
md"""
Como estamos interessados mais na variação dos dados. Vamos iniciar centralizado a informação em torno da média, que será transformada no 0. 
"""

# ╔═╡ aec46a9b-f743-4cbd-97a7-3ef3cac78b12
begin
    xs_centered = xs .- mean(xs)
    ys_centered = ys .- mean(ys)
end

# ╔═╡ 1b8c743e-ec90-11ea-10aa-e3b94f768f82
scatter(xs_centered, ys_centered, ms = 5, leg = false)

# ╔═╡ eb867f18-852e-11eb-005f-e15b6d0d0d95
md"""
## Medindo a "largura" de um conjunto de dados
"""

# ╔═╡ f7079016-852e-11eb-3bc9-53fa0846276f
md"""
Uma forma de medir o "tamanho" de um conjunto de dados seria medir a sua largura e altura separadamente. Ou seja, projetamos cada um dos pontos em cada eixo e medimos a amplitude obtida. Também, é claro que o mesmo processo pode ser feito em mais de duas variáveis.

Agora um observação _importante_: como já subtraímos a média, o que estamos calculando é o "desvio com relação à media", se calcularmos a média desses valores em módulos obtemos a estatística do [desvio médio absoluto](https://en.wikipedia.org/wiki/Average_absolute_deviation). Essa é uma boa estatística para "resumir" o quanto os dados variam em cada direção.
"""

# ╔═╡ 870d3efa-f8fc-11ea-1593-1552511dcf86
begin
    scatter(xs_centered, ys_centered, ms = 5, alpha = 0.5, leg = false)

    scatter!(xs_centered, zeros(size(xs_centered)), ms = 5, alpha = 0.1, leg = false)

    for i = 1:length(xs_centered)
        plot!(
            [(xs_centered[i], ys_centered[i]), (xs_centered[i], 0)],
            ls = :dash,
            c = :black,
            alpha = 0.1,
        )
    end

    plot!()

end

# ╔═╡ 4fb82f18-852f-11eb-278d-cf93571f4adc
mean(abs.(xs_centered))

# ╔═╡ 5fcf832c-852f-11eb-1354-792933a891a5
md"""
Essa medida de dispersão parece adequada, mas vamos olhar uma outra medida possível que tem propriedades teóricas / analíticas melhores.
"""

# ╔═╡ ef4a2a54-81bf-11eb-358b-0da2072f20c8
md"""
### A raiz da média dos quadrados: o desvio padrão
"""

# ╔═╡ f5358ce4-f86a-11ea-2989-b1f37be89183
md"""
O **desvio padrão** é a **raiz da média dos quadrados** das distâncias dos dados centralizados à origem. 

Quebrando em partes. Primeiro nos elevamos as distâncias (o deslocamento) a partir da origem ao quadrado. Depois calculamos a média desses, obtendo a **variância**. Mas, como a variância é obtida somando quadrados, a unidade de medida não está certa. Ela está ao quadrado. Então, tomamos a raiz quadrada para obter uma medida na unidade correta:
"""

# ╔═╡ 2c3721da-f86b-11ea-36cf-3fe4c6622dc6
begin
	# root-mean-square distance from 0
    σ_x, σ_y = √(mean(xs_centered .^ 2)), √(mean(ys_centered .^ 2))   
end

# ╔═╡ 03ab44c0-f8fd-11ea-2243-1f3580f98a65
md"Em torno dos dados originais, obtemos os seguinte limiares para a nuvem de dados:"

# ╔═╡ 6dec0db8-ec93-11ea-24ad-e17870ee64c2
begin
    scatter(
        xs_centered,
        ys_centered,
        ms = 5,
        alpha = 0.5,
        ratio = 1,
        leg = false,
        framestyle = :origin,
    )

    vline!([-2 * σ_x, 2 * σ_x], ls = :dash, lw = 2, c = :green)
    hline!([-2 * σ_y, 2 * σ_y], ls = :dash, lw = 2, c = :blue)

    annotate!(2σ_x * 0.93, 0.03, text(L"2\sigma_x", 14, :green))
    annotate!(-2σ_x * 0.88, 0.03, text(L"-2\sigma_x", 14, :green))

    annotate!(0.05, 2σ_y * 1.13, text(L"2\sigma_y", 14, :blue))
    annotate!(0.06, -2σ_y * 1.14, text(L"-2\sigma_y", 14, :blue))

end

# ╔═╡ 5fab2c32-f86b-11ea-2f27-ed5feaac1fa5
md"""
Para dados com distribuição normal, esperamos que a maior parte dele (cerca de 95%) esteja a até dois desvios padrão da média, ou seja entre $\mu \pm 2 \sigma$, em que $\mu$ é a média e $\sigma$ é o desvio padrão. A hipótese de distribuição normal não é de fato válida para os dados que estamos usando, mas de qualquer forma vemos que os intervalos dados capturam a maior parte dos dados.
"""

# ╔═╡ ae9a2900-ec93-11ea-1ae5-0748221328fc
md"## Dados correlacionados"

# ╔═╡ b81c9db2-ec93-11ea-0dbd-4bd0951cb2cc
md"""
Por outro lado, ao olhar a figura vemos que claramente as direções dos eixos $x$ e $y$ não são as "melhores direções" para explicar o comportamento dos dados. Parece que teria sido melhor focar na direção geral em torno da qual os dados variam, que capturaria a maior parte da informação, e a direção ortogonal onde a variação parece ser mínima. 

Precisamos de alguma forma de obter essas direções *a partir dos dados em si*. De posse dessas direções podemos medir a extensão (largura) dos dados nessas direções. 

Mas essas direções especiais, tipicamente, não podem ser obtidadas tentando olhar as variáveis $x$ e $y$ de forma isolada. De fato, a informação que desejamos deve ser capaz de lançar luz sobre a *relação* que existe entre as variáveis $x$ e $y$ que está aparente do conjunto dos dados. 

Nos dados, se $x$ é um numero muito negativo, o mesmo ocorre com $y$. Enquanto que se $x$ cresce e fica grande e positivo, o $y$ vai atrás. Isso sugere que essas duas medidas são **correlacionadas**. Ao conhecermos algo sobre uma delas, aprendemos também algo sobre a outra. 

Outro exemplo, se medirmos a variável $x$ e ela for algo como $0.25$ ao olharmos os dados podemos imaginar que o $y$ vai ser um pouco menor mas ainda positivo. Digamos que entre $0.05$ e $0.2$. Seria muito surpreendente que $y$ valesse -0.5.
"""

# ╔═╡ 80722856-f86d-11ea-363d-53fc5f6b8152
md"""
Existem métodos aderquados para se tentar calcular essa correlação. Mas vamos agora continuar explorando os dados usando os nossos conhecimentos computacionais e nossa intuição para ver o que conseguimos descobrir.
"""

# ╔═╡ b8fa6a1c-f86d-11ea-3d6b-2959d737254b
md"""
Estamos tentando capturar o que ocorre quando olhamos os dados através de _direções_ diferentes. Vamos então introduzir um ângulo $\theta$ para descrever essas direções. Em seguida, vamos calcular a largura da nuvem de pointos com respeito a essa nova direção (e a direção perpendicular).

Na prática o que estamos fazendo é mudando de coordenadas, indo para um novo sistema de coordenadas que ainda é ortogonal. A compreensão clara disso exige uma certa familiariedade com álgebra linear. Mas vamos ver até onde podemos ir com intuição e programação.
"""

# ╔═╡ 3547f296-f86f-11ea-1698-53d3c1a0bc30
md"## Rotacionando os eixos"

# ╔═╡ 7a83101e-f871-11ea-1d87-4946162777b5
md"""
Ao rotacionarmos os eixos podemos olhar "diferentes direções" e calcular a dispersão dos dados ao longo dessa direção. Para isso precisamos **projetar os dados perpendicularmente** sobre o novo "eixo".
"""

# ╔═╡ e8276b4e-f86f-11ea-38be-218a72452b10
# Put the points in a matrix as columns, so that it is easy to transform that at once
M = [xs_centered ys_centered]'

# ╔═╡ 7eb51908-f906-11ea-19d2-e947d81cb743
md"
Na figura a seguir, estamos rotacionando o eixo (seta vermelha) e projetando os pontos originais no novo eixo (e não mais no eixo $x$). 

Já a figura mais abaixo adota uma postura alternativa que é rodar os dados no sentido inverso. Aqui o eixo $x$ se mantem fixo e projetar o dados rotacionados sobre ele tem o mesmo efeito. 

Em outras palavras, a segunda figura é igual a primeira se rodarmos a nossa cabeça para ver a seta vermelha como horizontal."

# ╔═╡ 4f1980ea-f86f-11ea-3df2-35cca6c961f3
md"""
degrees = $(@bind degrees Slider(0:360, default=28, show_value=true)) 
"""

# ╔═╡ f70065aa-835a-11eb-00cb-ffa27bcb486e
θ = π * degrees / 180   # radians

# ╔═╡ 3b71142c-f86f-11ea-0d43-47011d00786c
p1 = begin
    # Scatter points
    scatter(
        M[1, :],
        M[2, :],
        ratio = 1,
        leg = false,
        ms = 2.5,
        alpha = 0.5,
        framestyle = :origin,
    )

    # The rotated axis is [cos(θ), sin(θ)]
    # Plot the axis and set picture limits
    plot!(
        0.7 .* [-cos(θ), cos(θ)],
        0.7 .* [-sin(θ), sin(θ)],
        lw = 1,
        arrow = true,
        c = :red,
        alpha = 0.3,
    )
    xlims!(-0.7, 0.7)
    ylims!(-0.7, 0.7)

    # Compute projections and plot them (try to derive the formula)		
    projected = ([cos(θ) sin(θ)] * M) .* [cos(θ), sin(θ)]
    scatter!(projected[1, :], projected[2, :], m = :3, alpha = 0.1, c = :green)

    # Plot the lines from the original points to the respective projection
    # Obs: the nan's make plot create separate lines 
    lines_x = reduce(vcat, [M[1, i], projected[1, i], NaN] for i = 1:size(M, 2))
    lines_y = reduce(vcat, [M[2, i], projected[2, i], NaN] for i = 1:size(M, 2))
    plot!(lines_x, lines_y, ls = :dash, c = :black, alpha = 0.1)
end;

# ╔═╡ 8b8e6b2e-8531-11eb-1ea6-637db25b28d5
p1

# ╔═╡ c9da6e64-8540-11eb-3984-47fdf8be0dac
md"""
## Rotacionando os dados
"""

# ╔═╡ 88bbe1bc-f86f-11ea-3b6b-29175ddbea04
p2 = begin
    # Clockwise rotation matrix
    R(θ) = [
        cos(θ) sin(θ)
        -sin(θ) cos(θ)
    ]

    # Rotate the data
    M2 = R(θ) * M

    # Plot the rotated data
    scatter(
        M2[1, :],
        M2[2, :],
        ratio = 1,
        leg = false,
        ms = 2.5,
        alpha = 0.3,
        framestyle = :origin,
        size = (500, 500),
    )

    # Set limits
    xlims!(-0.7, 0.7)
    ylims!(-0.7, 0.7)

    # Now the projection is just the first coordinate
    scatter!(
        M2[1, :],
        zeros(size(xs_centered)),
        ms = 3,
        alpha = 0.1,
        ratio = 1,
        leg = false,
        framestyle = :origin,
        c = :green,
    )


    # Plot the lines from the original points to the respective projection
    lines2_x = reduce(vcat, [M2[1, i], M2[1, i], NaN] for i = 1:size(M2, 2))
    lines2_y = reduce(vcat, [M2[2, i], 0, NaN] for i = 1:size(M2, 2))
    plot!(lines2_x, lines2_y, ls = :dash, c = :black, alpha = 0.1)

    # Calculate the standard deviation of the displacements
    σ = std(M2[1, :])

    # Add the vertical lines that should contain most of the data
    vline!([-2σ, 2σ], ls = :dash, lw = 2)
    annotate!(2σ + 0.05, 0.05, text("2σ", 10, :green))
    annotate!(-2σ - 0.05, 0.05, text("-2σ", 10, :green))

    # Present the standard deviation so that we can maximize it (or minimize it)
    title!("σ = $(round(σ, digits=4))")
end;

# ╔═╡ 2ffe7ed0-f870-11ea-06aa-390581500ca1
p2

# ╔═╡ a5cdad52-f906-11ea-0486-755a6403a367
md"""
Como podemos ver, a extensão (o desvio padrão) dos dados na direção definida por $\theta$ varia quando variamos $\theta$. De fato podemos plotar o gráfico da variância como função de $\theta$. Veja que obtemos uma função que é basicamente um seno / cosseno! Tem matemática para ser feita aí!
"""

# ╔═╡ 0115c974-f871-11ea-1204-054510848849
variance(θ) = var((R(θ)*M)[1, :])

# ╔═╡ 0935c870-f871-11ea-2a0b-b1b824379350
p3 = begin
    plot(
        0:360,
        variance.(range(0, 2π, length = 361)),
        leg = false,
        ratio = :auto,
        size = (400, 200),
        alpha = 1,
    )
    scatter!([degrees], [σ^2], alpha = 1)
    xlabel!("θ")
    ylabel!("Variance in dir. θ")
end

# ╔═╡ e4af4d26-f877-11ea-1de3-a9f8d389138e
md"""
A direção na qual a variância (ou o desvio padrão, eles andam juntos) é maximizada fornece a direção mais importante para dos dados. Essa é a direção que melhor consegue distiguir os dados, e a posição nessa direção nos dá o máximo de informação com um único valor. Essa direção é conhecida como primeira **componente principal** dos dados. Em linear álgebra o seu nome é o primeiro **vetor singular**. Isso vai ficar mais claro abaixo. 

Nós também podemos medir o quão próximo os dados estão da direção principal medindo a dispersão na perpendicular que é bem menor. Quanto menor esse valor, mais puramente unidimensional é o dado, ou seja mais próximo ele está de ser explicando como uma tabela de multiplicação, ou matriz de posto 1. 
"""

# ╔═╡ bf57f674-f906-11ea-08eb-9b50818a025b
md"
Podemos aproveitar que o computador é muito rápido e calcular os maiores e menores valores da variância simplemente avaliando em uma malha fina e uniforme e procurando o maior e o menor valor:"

# ╔═╡ 17e015fe-f8ff-11ea-17b4-a3aa072cd7b3
begin
    θs = 0:0.01:2π
    fs = variance.(θs)

    θmax = θs[argmax(fs)]
    θmin = θs[argmin(fs)]

    fmax = variance(θmax)
    fmin = variance(θmin)
    fmax, fmin
end

# ╔═╡ 045b9b98-f8ff-11ea-0d49-5b209319e951
begin
    scatter(xs_centered, ys_centered, ms = 5, leg = false)

    plot!(
        [(0, 0), 2 * sqrt(fmax) .* (cos(θmax), sin(θmax))],
        arrow = true,
        lw = 3,
        c = :red,
    )
    plot!(
        [(0, 0), 2 * sqrt(fmin) .* (cos(θmin), sin(θmin))],
        arrow = true,
        lw = 3,
        c = :red,
    )

end

# ╔═╡ cfec1ec4-f8ff-11ea-265d-ab4844f0f739
md"""
Observe que as direções de máxima e mínima dispersão são perpendiculares. Isso sempre ocorre e pode ser comprovado através de decomposições por valores singulares em álgebra linear.

Existem múltiplas formas de se interpretar esse procedimento. Um deles é pensar que estamos tentando encontrar uma elipse que melhor se ajusta ao corpo dos dados. Naturalmente os semi-eixos da elipse devem ser alinhar com as direções de máxima e mínima dispersão. 

Outra maneira, mas afeita à estatística, é imaginar que estamos tentando ajustar uma distribuição normal multivariada aos dados procurando a matriz de covariância mais adequada.
"""

# ╔═╡ e6e900b8-f904-11ea-2a0d-953b99785553
begin
    circle = [cos.(θs) sin.(θs)]'
    stretch = [
        2*sqrt(fmax) 0
        0 2*sqrt(fmin)
    ]
    ellipse = R(-θmax) * stretch * circle

    plot!(
        ellipse[1, :],
        ellipse[2, :],
        series = :shape,
        alpha = 0.4,
        fill = true,
        c = :orange,
    )
end

# ╔═╡ 301f4d06-8162-11eb-1cd6-31dd8da164b6
md"""
Note que o código acima obtem a elipse através de uma transformação linear da bola unitária. Essa é mais uma forma de interpretar o que está sendo feito. Estamos tentando transformar a bola unitária por uma transformação linear de maneira a ela se ajustar bem a nossa nuvem de pontos.
"""

# ╔═╡ aaff88e8-f877-11ea-1527-ff4d3db663db
md"## Aumentando a dimensão"

# ╔═╡ aefa84de-f877-11ea-3e26-678008e9739e
md"""
Será que podemos generalizar o que estamos fazendo para dimensões maiores que 2? 

No espaço (3D), pegaríamos as primeiras três linhas da matriz do topo desse caderno para formar a nossa nuvem de pontos 3D. 

Nesse contexto, como os dados vêm de uma matriz de posto 1, eles ainda estarão dispontos em linha no espaço. Ao somarmos um ruído aleatório obteríamos uma espécie de cilindro em torno de dessa linha.

Já se partíssemos de matrizes de posto 2, os dados estariam num plano. Ao somar erros aleatórios eles ainda iriam ficar próximos ao plano, mas se dipersando no espaço tridimensional.

E assim como nós fizemos acima, podemos ainda tentar encontrar elipsoides que contenham a maior parte dos dados e o comprimento dos semi-eixos vão dizer o quão perto dos dados estão de uma reta ou de um plano (posto 1 ou posto 2). 
"""

# ╔═╡ 0bd9358e-f879-11ea-2c83-ed4e7bf9d903
md"""
Em mais de 3 dimensões já não conseguimos visualizar. Mas podemos continuar calculandos nossos objetos usando a decomposições SVD. Se alguns dos semi-eixos forem muito pequenos, vemos que podemos "ignorar" essas direções reduzindo a dimensionalidade dos dados ao mudarmos as coordenadas para usarem as componentes principais.
"""

# ╔═╡ 9960e1c2-85a0-11eb-3d68-cd3a07a9c0b5
md"""
## O que é a Decomposição por valores singulares (SVD)?
"""

# ╔═╡ dc4cca88-85a0-11eb-2791-d7610a610e36
md"""
A **Decomposição por valores singulares** (SVD, sigla do ingês) é uma forma de escrever uma matriz qualquer como produto de matrizes de comportamento simples. Pensando nas respectivas transformações lineares, vemos que uma transformação qualquer $T$ pode ser decomposta como uma sequência de três transformações especiais:

T = rotação/reflexão₂ ∘ escalamento ∘ rotação/reflexão₁

Já em termos de matrizes, isso diz que *qualquer* matrix $M \in \mathbb{R}^{m \times n}$ pode ser escrita na forma

$$M = U \, \Sigma \, V^\text{T},$$

em que $U \in \mathbb{R}^{m \times m}$ e $V \in \mathbb{R}^{n \times n}$ são matrizes **ortogonais**, isto é, elas satisfazem $U U^\text{T} = I$ e $V V^\text{T} = I$. Já $\Sigma \in \mathbb{R}^{m \times n}$ é uma matriz diagonal de elementos não negativos em ordem decrescente.

Matrizes ortogonais são muito especiais. Elas preservam ângulos e comprimentos, resultado apenas em rotações combinadas com reflexões. Naturalmente elas também preservam áreas e volumes, possuindo determinante ±1.

Além disso, exitem algoritmos robustos de álgebra linear computacional que permitem calcular a decomposição SVD de uma matriz qualquer. Em Julia basta chamar a função `svd`. Vamos vê-la em ação.
"""

# ╔═╡ 453689c2-85a2-11eb-2cbc-7d6476b42f2f
let
    M = [
        2 1
        1 1
    ]

    svd(M)
end

# ╔═╡ 91b77acc-85a2-11eb-19bb-bd2bdd0c1a68
md"""
À luz dessa decomposição vamos interpretar a ação de uma matriz sobre o disco (ou bola) unitário. Para isso vamos gerar dados uniformemente no quadrado $[-1, 1]^2$ e *rejeitar* os que estão fora da bola.

Obs: essa estratégia de gerar pontos uniformes num quadrado, ou retângulo, que contem a figura onde queremos amostrar e rejeitar os pontos que não pertecem à figura de interesse é conhecida como _amostragem por rejeição_ e é uma das formas mais simples de se atingir pontos uniformes em regiões complexas. No caso do disco, a solução inocente de amostrar uniformemente em coordenadas polares **não funciona**.
"""

# ╔═╡ f92c75f6-85a3-11eb-1689-23aeaa3daeb7
begin
    unit_square = [(-1.0 .+ 2.0 .* rand(2)) for i = 1:2000]
    unit_disc = reduce(hcat, [x for x in unit_square if x[1]^2 + x[2]^2 <= 1])
end

# ╔═╡ 03069da6-85a4-11eb-2ac5-87b767846550
scatter(unit_disc[1, :], unit_disc[2, :], ratio = 1, leg = false, alpha = 0.5, ms = 3)

# ╔═╡ 1647a126-85a4-11eb-3923-5f5a6f703403
md"""
t = $(@bind tt Slider(0:0.01:1, show_value=true))
"""

# ╔═╡ 40b87cbe-85a4-11eb-30f8-cf7b5e79c19a
# Direct action of the matrix T
pp1 = begin
    T = [
        1+tt tt
        tt   1
    ]
    scatter(
        unit_disc[1, :],
        unit_disc[2, :],
        ratio = 1,
        leg = false,
        alpha = 0.5,
        title = "stretch + rotate",
    )
    result = T * unit_disc
    scatter!(result[1, :], result[2, :], alpha = 0.2)

    ylims!(-3, 3)
    xlims!(-3, 3)
end;

# ╔═╡ 28a7d6dc-85a5-11eb-0e4b-b7e9b4c592ed
# Decompose M and see only what happens after the strech
pp2 = begin
    UU, Sigma, VV = svd(T)
    scatter(
        unit_disc[1, :],
        unit_disc[2, :],
        ratio = 1,
        leg = false,
        alpha = 0.5,
        title = "stretch",
    )

    result2 = Diagonal(Sigma) * unit_disc

    scatter!(result2[1, :], result2[2, :], alpha = 0.2)

    ylims!(-3, 3)
    xlims!(-3, 3)

end;


# ╔═╡ 6ec7f980-85a5-11eb-12fc-cb132db28d83
plot(pp2, pp1)

# ╔═╡ 67b00528-9a50-44f2-b1f9-225675598370
md"## Usando SVD para achar a direção de máxima variação"

# ╔═╡ 02ef3bb8-5819-420c-b062-28a5523b5cb8
md"""
Como podemos usar a SVD para achar a direção de máxima variação dos dados? A figura acima nos dá uma ideia: _olhar os dados, que são elementos do $\mathbb{R}^n$, como aplicação de uma sequência de operações_. 

1. Encontrar pontos na bola unitária do $\mathbb{R}^n$ de partida.
2. Aplicar um escalamento nesses pontos.
3. Rotacionar (e/ou refletir) os eixos originais.

Será que conseguimos fazer isso? Vamos relembrar qual é a nossa matriz de dados.
"""

# ╔═╡ 701b2cd0-5160-4cd7-91e7-0883cc829a6b
M

# ╔═╡ 8226e48e-b436-4b2b-b855-ca0caed7d914
md"""
Ela é uma matriz 2 × 300, com 300 pontos do plano. O que ocorre se calculamos a decomposição SVD dessa matriz? Obtemos matrizes $U \in \mathbb{R}^{2 \times 2},\ \Sigma \in \mathbb{R}^{2 \times 300},\ V^T \in \mathbb{R}^{300 \times 300}$, em que $U$ e $V^T$ são ortogonais, $\Sigma$ é diagonal e $M = U \Sigma V^T$. 

Em particular, $\Sigma$ tem a forma

$$\begin{bmatrix}
\sigma_1 & 0         & 0 & 0 &  0 & \ldots & 0 \\
0        & \sigma_2  & 0 & 0 &  0 & \ldots & 0
\end{bmatrix}.$$

Já as colunas de $V^T$ são pontos da bola unitária de $\mathbb{R}^{300}$. Assim quando calculamos $\Sigma V^t$ ocorrem duas coisas:

* Os zeros no final de $\Sigma$ "apagam" as coordenadas das colunas de $V^T$ a partir da coordenada 3. Assim, apenas as duas primeiras coordenadas das colunas $V^T$ entram nas contas e essas pondem ser interpretadas como pontos no disco unitário (do plano). 

* Esses pontos do disco unitário são esticados/encolhidos nos eixos por $\sigma_1$ na primeira coordenada e $\sigma_2$ para a segunda coordenada. Assim os pontos da primeira coordenada ficam mais espalhados do que na segunda, já que os $\sigma_i$ estão em ordem decrescente. Assim, o eixo $x$ nesse momento é a direção de maior variação.

A seguir pegamos o resultado dessas operações e rotacionamos/refletimos pela matriz $U$, isso gera uma nova elipse que mapeia o eixo x na primeira coluna de $U$ que representa a direção do semi-eixo principal da elipse final que são justamente os dados originais. 

Concluímos que a direção principal é dada pela primeira coluna de $U$. Como ela é um vetor unitário, ela está na forma $(\cos \theta, \sin \theta)$ em que $\theta$ é o ângulo de rotação do eixo $x$ que buscávamos. Ou equivalentemente, $-\theta$ é o ângulo de rotação dos dados que usamos na fução `variance`. De fato,
"""

# ╔═╡ f621e9de-80ba-47c5-918c-3aaa4c951885
begin
    UM, SM, VM = svd(M)
    θsvd = acos(UM[1, 1])
    variance(θmax), variance(-θsvd), variance(θmax) < variance(-θsvd)
end

# ╔═╡ fd76305e-ec37-4f9d-aaab-459e97bf29d5
md"Como você pode ver o $-\theta$ calculado a partir da SVD é ainda melhor que o valor calculado pelo método de aproximação por força bruta que usamos antes."

# ╔═╡ 81dda8f7-d8c2-4199-ad38-2ecc5324896e
md"
Podemos também ver o que ocorre quando transformamos o círculo que contém os pontos de partida que estavam em $V^t$. A nossa discussão diz que esse círculo deve ser transformado na ellipse rotacionada com o tamanho certinho para caber todos os pontos no conjunto de dados.
"

# ╔═╡ 15808ca3-c0b1-4533-a8e2-cda5e2e4316a
begin
    # Plot original points
    scatter(
        xs_centered,
        ys_centered,
        ms = 5,
        alpha = 0.3,
        ratio = 1,
        leg = false,
        framestyle = :origin,
    )

    # Find the radius of the ball tha encloses the points in V^T
    radius = maximum(norm(VM[i, :]) for i = 1:size(M, 2))

    # Compute the transformed elipssis and plot it
    ellipse_svd = R(θsvd) * diagm(SM) * (radius .* circle)
    plot!(
        ellipse_svd[1, :],
        ellipse_svd[2, :],
        series = :shape,
        alpha = 0.4,
        fill = true,
        c = :orange,
    )
end

# ╔═╡ 467e5a2c-9b6e-44d2-a645-aacf01fcdb0f
md"
Há outras formas, inclusive com demostrações mais formais para se deduzir como podem ser obtidas as direções principais. Muitas vezes elas envolvem o uso de matrizes de covariância e os repectivos autovalores e vetores que estão completamente relacionados às matrizes $U$ e $\Sigma$. Por exemplo, você pode aprender um pouco mais na [Wikipedia](https://en.wikipedia.org/wiki/Principal_component_analysis).

O importante, porém, é entender como uma abordagem do problema baseada em computação científica aponta na direção correta e nos ajuda a resolver problemas de uma forma prática e iterativa.
"

# ╔═╡ 1cf3e098-f864-11ea-3f3a-c53017b73490
md"#### Apêndice"

# ╔═╡ 2917943c-f864-11ea-3ee6-db952ca7cd67
begin
    show_image(M) = get.(Ref(ColorSchemes.rainbow), M ./ maximum(M))
    show_image(x::AbstractVector) = show_image(x')
end

# ╔═╡ 43bff19e-f864-11ea-2315-0f85b532a325
show_image(flag)

# ╔═╡ 79d2c6f4-f895-11ea-30c4-9d1102c99482
show_image(flag2)

# ╔═╡ b183b6ca-f864-11ea-0b34-4dd3f4f5e69d
show_image(data)

# ╔═╡ 74c04322-815b-11eb-2308-7b3d571cf613
begin

    data2 = outer([1; 0.4; rand(50)], rand(w)) + outer(rand(52), rand(w))

    show_image(data2)
end

# ╔═╡ f6713bec-815b-11eb-2fc4-6b0326a64b16
show_image(data)

# ╔═╡ 5471ddce-f867-11ea-2519-21981f5ea68b
show_image(noisy_data)

# ╔═╡ 1957f71c-f8eb-11ea-0dcf-339bfa7f96fc
show_image(data[1:2, 1:20])

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ColorSchemes = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
ImageMagick = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
Images = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
ColorSchemes = "~3.24.0"
Colors = "~0.12.8"
ForwardDiff = "~0.10.32"
ImageMagick = "~1.3.1"
Images = "~0.25.2"
LaTeXStrings = "~1.3.0"
Plots = "~1.40.4"
PlutoUI = "~0.7.40"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.6"
manifest_format = "2.0"
project_hash = "87732355a5088ac9ecc8c26b8dd48398f6fb1381"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "d92ad398961a3ed262d8bf04a1a2b8340f915fef"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.5.0"
weakdeps = ["ChainRulesCore", "Test"]

    [deps.AbstractFFTs.extensions]
    AbstractFFTsChainRulesCoreExt = "ChainRulesCore"
    AbstractFFTsTestExt = "Test"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "cde29ddf7e5726c9fb511f340244ea3481267608"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.7.2"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "d57bd3762d308bded22c3b82d033bff85f6195c6"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.4.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "16351be62963a67ac4083f748fdb3cca58bfd52f"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.7"

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

[[deps.CEnum]]
git-tree-sha1 = "389ad5c84de1ae7cf0e28e381131c98ea87d54fc"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.5.0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "2ac646d71d0d24b44f3f8c84da8c9f4d70fb67df"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.4+0"

[[deps.CatIndices]]
deps = ["CustomUnitRanges", "OffsetArrays"]
git-tree-sha1 = "a0f80a09780eed9b1d106a1bf62041c2efc995bc"
uuid = "aafaddc9-749c-510e-ac4f-586e18779b91"
version = "0.2.2"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "1713c74e00545bfe14605d2a2be1712de8fbcb58"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.25.1"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "Random", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "3e22db924e2945282e70c33b75d4dde8bfa44c94"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.15.8"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "962834c22b66e32aa10f7611c08c8ca4e20749a9"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.8"

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
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "600cc5508d66b78aae350f7accdb58763ac18589"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.10"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "362a287c3aa50601b0bc359053d5c2468f0e7ce0"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.11"

[[deps.CommonSubexpressions]]
deps = ["MacroTools"]
git-tree-sha1 = "cda2cfaebb4be89c9084adaca7dd7333369715c5"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.1"

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

[[deps.ComputationalResources]]
git-tree-sha1 = "52cb3ec90e8a8bea0e62e275ba577ad0f74821f7"
uuid = "ed09eef8-17a6-5b46-8889-db040fac31e3"
version = "0.3.2"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "d9d26935a0bcffc87d2613ce14c527c99fc543fd"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.5.0"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.CoordinateTransformations]]
deps = ["LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "a692f5e257d332de1e554e4566a4e5a8a72de2b2"
uuid = "150eb455-5306-5404-9cee-2592286d6298"
version = "0.6.4"

[[deps.CustomUnitRanges]]
git-tree-sha1 = "1a3f97f907e6dd8983b744d2642651bb162a3f7a"
uuid = "dc8bdbbb-1ca9-579f-8c36-e416f6a65cce"
version = "1.0.2"

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

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "23163d55f885173722d1e4cf0f6110cdbaf7e272"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.15.1"

[[deps.Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "c7e3a542b999843086e2f29dac96a618c105be1d"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.12"
weakdeps = ["ChainRulesCore", "SparseArrays"]

    [deps.Distances.extensions]
    DistancesChainRulesCoreExt = "ChainRulesCore"
    DistancesSparseArraysExt = "SparseArrays"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

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
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FFTViews]]
deps = ["CustomUnitRanges", "FFTW"]
git-tree-sha1 = "cbdf14d1e8c7c8aacbe8b19862e0179fd08321c2"
uuid = "4f61f5a4-77b1-5117-aa51-3ab5ef4ef0cd"
version = "0.3.2"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "7de7c78d681078f027389e067864a8d53bd7c3c9"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.8.1"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6d6219a004b8cf1e0b4dbe27a2860b8e04eba0be"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.11+0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "b66970a70db13f45b7e57fbda1736e1cf72174ea"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.17.0"
weakdeps = ["HTTP"]

    [deps.FileIO.extensions]
    HTTPExt = "HTTP"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

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

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "a2df1b776752e3f344e5116c06d75a10436ab853"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.38"
weakdeps = ["StaticArrays"]

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

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
git-tree-sha1 = "8e2d86e06ceb4580110d9e716be26658effc5bfd"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.72.8"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "da121cbdc95b065da07fbb93638367737969693f"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.72.8+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "43ba3d3c82c18d88471cfd2924931658838c9d8f"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.0+4"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "b0036b392358c80d2d2124746c2bf3d48d457938"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.82.4+0"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "a641238db938fff9b2f60d08ed9030387daf428c"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.3"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a6dbda1fd736d60cc477d99f2e7a042acfa46e8"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.15+0"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "3169fd3440a02f35e549728b0890904cfd4ae58a"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.12.1"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "PrecompileTools", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "c67b33b085f6e2faf8bf79a61962e7339a81129c"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.15"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "55c53be97790242c29031e5cd45e8ac296dadda3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.5.0+0"

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

[[deps.ImageAxes]]
deps = ["AxisArrays", "ImageBase", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "2e4520d67b0cef90865b3ef727594d2a58e0e1f8"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.11"

[[deps.ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "b51bb8cae22c66d0f6357e3bcb6363145ef20835"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.5"

[[deps.ImageContrastAdjustment]]
deps = ["ImageBase", "ImageCore", "ImageTransformations", "Parameters"]
git-tree-sha1 = "eb3d4365a10e3f3ecb3b115e9d12db131d28a386"
uuid = "f332f351-ec65-5f6a-b3d1-319c6670881a"
version = "0.3.12"

[[deps.ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "acf614720ef026d38400b3817614c45882d75500"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.4"

[[deps.ImageDistances]]
deps = ["Distances", "ImageCore", "ImageMorphology", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "08b0e6354b21ef5dd5e49026028e41831401aca8"
uuid = "51556ac3-7006-55f5-8cb3-34580c88182d"
version = "0.2.17"

[[deps.ImageFiltering]]
deps = ["CatIndices", "ComputationalResources", "DataStructures", "FFTViews", "FFTW", "ImageBase", "ImageCore", "LinearAlgebra", "OffsetArrays", "PrecompileTools", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "TiledIteration"]
git-tree-sha1 = "3447781d4c80dbe6d71d239f7cfb1f8049d4c84f"
uuid = "6a3955dd-da59-5b1f-98d4-e7296123deb5"
version = "0.7.6"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "437abb322a41d527c197fa800455f79d414f0a3c"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.8"

[[deps.ImageMagick]]
deps = ["FileIO", "ImageCore", "ImageMagick_jll", "InteractiveUtils"]
git-tree-sha1 = "8e2eae13d144d545ef829324f1f0a5a4fe4340f3"
uuid = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
version = "1.3.1"

[[deps.ImageMagick_jll]]
deps = ["Artifacts", "Ghostscript_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "OpenJpeg_jll", "Pkg", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "8d2e786fd090199a91ecbf4a66d03aedd0fb24d4"
uuid = "c73af94c-d91f-53ed-93a7-00f77d67a9d7"
version = "6.9.11+4"

[[deps.ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "355e2b974f2e3212a75dfb60519de21361ad3cb7"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.9"

[[deps.ImageMorphology]]
deps = ["ImageCore", "LinearAlgebra", "Requires", "TiledIteration"]
git-tree-sha1 = "e7c68ab3df4a75511ba33fc5d8d9098007b579a8"
uuid = "787d08f9-d448-5407-9aad-5290dd7ab264"
version = "0.3.2"

[[deps.ImageQualityIndexes]]
deps = ["ImageContrastAdjustment", "ImageCore", "ImageDistances", "ImageFiltering", "LazyModules", "OffsetArrays", "PrecompileTools", "Statistics"]
git-tree-sha1 = "783b70725ed326340adf225be4889906c96b8fd1"
uuid = "2996bd0c-7a13-11e9-2da2-2f5ce47296a9"
version = "0.3.7"

[[deps.ImageSegmentation]]
deps = ["Clustering", "DataStructures", "Distances", "Graphs", "ImageCore", "ImageFiltering", "ImageMorphology", "LinearAlgebra", "MetaGraphs", "RegionTrees", "SimpleWeightedGraphs", "StaticArrays", "Statistics"]
git-tree-sha1 = "44664eea5408828c03e5addb84fa4f916132fc26"
uuid = "80713f31-8817-5129-9cf8-209ff8fb23e1"
version = "1.8.1"

[[deps.ImageShow]]
deps = ["Base64", "ColorSchemes", "FileIO", "ImageBase", "ImageCore", "OffsetArrays", "StackViews"]
git-tree-sha1 = "3b5344bcdbdc11ad58f3b1956709b5b9345355de"
uuid = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
version = "0.3.8"

[[deps.ImageTransformations]]
deps = ["AxisAlgorithms", "ColorVectorSpace", "CoordinateTransformations", "ImageBase", "ImageCore", "Interpolations", "OffsetArrays", "Rotations", "StaticArrays"]
git-tree-sha1 = "8717482f4a2108c9358e5c3ca903d3a6113badc9"
uuid = "02fcd773-0e25-5acc-982a-7f6622650795"
version = "0.9.5"

[[deps.Images]]
deps = ["Base64", "FileIO", "Graphics", "ImageAxes", "ImageBase", "ImageContrastAdjustment", "ImageCore", "ImageDistances", "ImageFiltering", "ImageIO", "ImageMagick", "ImageMetadata", "ImageMorphology", "ImageQualityIndexes", "ImageSegmentation", "ImageShow", "ImageTransformations", "IndirectArrays", "IntegralArrays", "Random", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "StatsBase", "TiledIteration"]
git-tree-sha1 = "5fa9f92e1e2918d9d1243b1131abe623cdf98be7"
uuid = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
version = "0.25.3"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "0936ba688c6d201805a83da835b55c61a180db52"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.11+0"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "d1b1b796e47d94588b3757fe84fbf65a5ec4a80d"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.5"

[[deps.IntegralArrays]]
deps = ["ColorTypes", "FixedPointNumbers", "IntervalSets"]
git-tree-sha1 = "b842cbff3f44804a84fda409745cc8f04c029a20"
uuid = "1d092043-8f09-5a30-832f-7509e371ab51"
version = "0.1.6"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl"]
git-tree-sha1 = "0f14a5456bdc6b9731a5682f439a672750a09e48"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2025.0.4+0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "721ec2cf720536ad005cb38f50dbba7b02419a15"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.14.7"

[[deps.IntervalSets]]
git-tree-sha1 = "dba9ddf07f77f60450fe5d2e2beb9854d9a49bd0"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.10"
weakdeps = ["Random", "RecipesBase", "Statistics"]

    [deps.IntervalSets.extensions]
    IntervalSetsRandomExt = "Random"
    IntervalSetsRecipesBaseExt = "RecipesBase"
    IntervalSetsStatisticsExt = "Statistics"

[[deps.IrrationalConstants]]
git-tree-sha1 = "e2222959fbc6c19554dc15174c81bf7bf3aa691c"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.4"

[[deps.IterTools]]
git-tree-sha1 = "42d5f897009e7ff2cf88db414a389e5ed1bdd023"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.10.0"

[[deps.JLD2]]
deps = ["FileIO", "MacroTools", "Mmap", "OrderedCollections", "PrecompileTools", "Requires", "TranscodingStreams"]
git-tree-sha1 = "89e1e5c3d43078d42eed2306cab2a11b13e5c6ae"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.54"

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

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "9496de8fb52c224a2e3f9ff403947674517317d9"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.6"

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
git-tree-sha1 = "78211fb6cbc872f77cad3fc0b6cf647d923f4929"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.7+0"

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

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

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

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll"]
git-tree-sha1 = "d77592fa54ad343c5043b6f38a03f1a3c3959ffe"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.11.1+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "ff3b4b9d35de638936a525ecd36e86a8bb919d11"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "df37206100d39f79b3376afb6b9cee4970041c61"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.51.1+0"

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

[[deps.LittleCMS_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg"]
git-tree-sha1 = "110897e7db2d6836be22c18bffd9422218ee6284"
uuid = "d3a379c0-f9a3-5b72-a4c0-6bf4d2e8af0f"
version = "2.12.0+0"

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

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "oneTBB_jll"]
git-tree-sha1 = "5de60bc6cb3899cd318d80d627560fae2e2d99ae"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2025.0.1+1"

[[deps.MacroTools]]
git-tree-sha1 = "72aebe0b5051e5143a079a4685a46da330a40472"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.15"

[[deps.MappedArrays]]
git-tree-sha1 = "2dab0221fe2b0f2cb6754eaa743cc266339f527e"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.2"

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

[[deps.MetaGraphs]]
deps = ["Graphs", "JLD2", "Random"]
git-tree-sha1 = "1130dbe1d5276cb656f6e1094ce97466ed700e5a"
uuid = "626554b9-1ddb-594c-aa3c-2596fe9399a5"
version = "0.7.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "7b86a5d4d70a9f5cdf2dacb3cbe6d251d1a61dbe"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.4"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "9b8215b1ee9e78a293f99797cd31375471b2bcae"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.3"

[[deps.NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "8a3271d8309285f4db73b4f662b1b290c715e85e"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.21"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore", "ImageMetadata"]
git-tree-sha1 = "d92b107dbb887293622df7697a2223f9f8176fcd"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.1.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
git-tree-sha1 = "a414039192a155fb38c4599a60110f0018c6ec82"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.16.0"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "97db9e07fe2091882c765380ef58ec553074e9c7"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.3"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "8292dd5c8a38257111ada2174000a33745b06d4e"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.2.4+0"

[[deps.OpenJpeg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libtiff_jll", "LittleCMS_jll", "Pkg", "libpng_jll"]
git-tree-sha1 = "76374b6e7f632c130e78100b166e5a48464256f8"
uuid = "643b3616-a352-519d-856d-80112ee9badc"
version = "2.4.0+0"

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
git-tree-sha1 = "cc4054e898b852042d7b503313f7ad03de99c3dd"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.0"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "cf181f0b1e6a18dfeb0ee8acc4a9d1672499626c"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.4.4"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "0fac6313486baae819364c52b4f483450a9d793f"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.12"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "3b31172c032a1def20c98dae3f2cdc9d10e3b561"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.56.1+0"

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

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "db76b1ecd5e9715f3d043cec13b2ec93ce015d53"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.44.2+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f9501cc0430a26bc3d156ae1b5b0c1b47af4d6da"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.3"

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
git-tree-sha1 = "f202a1ca4f6e165238d8175df63a7e26a51e04dc"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.40.7"

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

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "13c5103482a8ed1536a54c08d0e742ae3dca2d42"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.10.4"

[[deps.PtrArrays]]
git-tree-sha1 = "1d36ef11a9aaf1e8b74dacc6a731dd1de8fd493d"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.3.0"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "8b3fc30bc0390abdce15f8822c889f669baed73d"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.1"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[deps.Quaternions]]
deps = ["LinearAlgebra", "Random", "RealDot"]
git-tree-sha1 = "994cc27cdacca10e68feb291673ec3a76aa2fae9"
uuid = "94ee1d12-ae83-5a48-8b1c-48b8ff168ae0"
version = "0.7.6"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "1342a47bf3260ee108163042310d26f2be5ec90b"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.5"
weakdeps = ["FixedPointNumbers"]

    [deps.Ratios.extensions]
    RatiosFixedPointNumbersExt = "FixedPointNumbers"

[[deps.RealDot]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9f0a1b71baaf7650f4fa8a1d168c7fb6ee41f0c9"
uuid = "c1ae055f-0cd5-4b69-90a6-9a35b1a98df9"
version = "0.1.0"

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

[[deps.RegionTrees]]
deps = ["IterTools", "LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "4618ed0da7a251c7f92e869ae1a19c74a7d2a7f9"
uuid = "dee08c22-ab7f-5625-9660-a9af2021b33f"
version = "0.3.2"

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

[[deps.Rotations]]
deps = ["LinearAlgebra", "Quaternions", "Random", "StaticArrays"]
git-tree-sha1 = "5680a9276685d392c87407df00d57c9924d9f11e"
uuid = "6038ab10-8711-5258-84ad-4b1120ba62dc"
version = "1.7.1"
weakdeps = ["RecipesBase"]

    [deps.Rotations.extensions]
    RotationsRecipesBaseExt = "RecipesBase"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMD]]
deps = ["PrecompileTools"]
git-tree-sha1 = "fea870727142270bdf7624ad675901a1ee3b4c87"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.7.1"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

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
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.SimpleWeightedGraphs]]
deps = ["Graphs", "LinearAlgebra", "Markdown", "SparseArrays"]
git-tree-sha1 = "3e5f165e58b18204aed03158664c4982d691f454"
uuid = "47aef6b3-ad0c-573a-a1e2-d07658019622"
version = "1.5.0"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "2da10356e31327c7096832eb9cd86307a50b1eb6"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.3"

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
git-tree-sha1 = "64cca0c26b4f31ba18f13f6c12af7c85f478cfde"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.5.0"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "83e6cce8324d49dfaf9ef059227f91ed4441a8e5"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.2"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "0feb6b9031bd5c51f9072393eb5ab3efd31bf9e4"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.13"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

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

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "SIMD", "UUIDs"]
git-tree-sha1 = "38f139cc4abf345dd4f22286ec000728d5e8e097"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.10.2"

[[deps.TiledIteration]]
deps = ["OffsetArrays"]
git-tree-sha1 = "5683455224ba92ef59db72d10690690f4a8dc297"
uuid = "06e1c1a7-607b-532d-9fad-de7d9aa2abac"
version = "0.3.1"

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

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "5f24e158cf4cee437052371455fe361f526da062"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.6"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "b8b243e47228b4a3877f1dd6aee0c5d56db7fcf4"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.6+1"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "82df486bfc568c29de4a207f7566d6716db6377c"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.43+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "9dafcee1d24c4f024e7edc92603cedba72118283"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+3"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e9216fdcd8514b7072b43653874fd688e4c6c003"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.12+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "807c226eaf3651e7b2c468f687ac788291f9a89b"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.3+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "89799ae67c17caa5b3b5a19b8469eeee474377db"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.5+0"

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

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c57201109a9e4c0585b208bb408bc41d205ac4e9"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.2+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "1a74296303b6524a0472a8cb12d3d87a78eb3612"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "dbc53e4cf7701c6c7047c51e17d6e64df55dca94"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.2+1"

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

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6e50f145003024df4f5cb96c7fce79466741d601"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.56.3+0"

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
git-tree-sha1 = "068dfe202b0a05b8332f1e8e6b4080684b9c7700"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.47+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "libpng_jll"]
git-tree-sha1 = "c1733e347283df07689d71d61e14be986e49e47a"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.5+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "490376214c4721cdaca654041f635213c6165cb3"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+2"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.oneTBB_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d5a767a3bb77135a99e433afe0eb14cd7f6914c3"
uuid = "1317d2d5-d96f-522e-a858-c73665f53c3e"
version = "2022.0.0+0"

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
# ╟─03825a62-7ffd-4bfe-8876-79db1a3131fa
# ╠═cf82077a-81c2-11eb-1de2-09ed6c35d810
# ╟─c593a748-81b6-11eb-295a-a9800f9dec6d
# ╟─deb2af50-8524-11eb-0dd4-9d799ff6d3e2
# ╟─2e50a070-853f-11eb-2045-b1cc43c29768
# ╟─ed7ff6b2-f863-11ea-1a59-eb242a8674e3
# ╟─fed5845e-f863-11ea-2f95-c331d3c62647
# ╠═0e1a6d80-f864-11ea-074a-5f7890180114
# ╠═2e497e30-f895-11ea-09f1-d7f2c1f61193
# ╠═4773686e-f955-4422-9b5c-18c51a3b6a8d
# ╟─cfdd04f8-815a-11eb-0409-79a2599c29ab
# ╟─ab3d55cc-f905-11ea-2f22-5398f3aca803
# ╠═13b6c108-f864-11ea-2447-2b0741f15c7b
# ╠═e66b30a6-f914-11ea-2c0f-35282d45a30a
# ╠═43bff19e-f864-11ea-2315-0f85b532a325
# ╠═71d1b12e-f895-11ea-39df-f5c18a7766c3
# ╠═79d2c6f4-f895-11ea-30c4-9d1102c99482
# ╟─356267fa-815b-11eb-1c57-ad14fd6e91a7
# ╟─cdbe1d8e-f905-11ea-3884-efeeef386dda
# ╟─d9aa9af0-f865-11ea-379e-f16b452bd94c
# ╟─2e8ae92a-f867-11ea-0219-1bdd9627c1ea
# ╠═9ad13804-815c-11eb-0253-8f8baf15eee3
# ╠═38adc490-f867-11ea-1de5-3b633aff7c97
# ╠═b183b6ca-f864-11ea-0b34-4dd3f4f5e69d
# ╟─946fde3c-815b-11eb-3039-db4105bc43ab
# ╟─ab924210-815b-11eb-07fe-411db58fbc3a
# ╠═74c04322-815b-11eb-2308-7b3d571cf613
# ╟─b5094384-815b-11eb-06fd-1f40134c6fd8
# ╟─cc4f3fee-815b-11eb-2982-9b797b806b45
# ╟─dc55775a-815b-11eb-15b7-7993190bffab
# ╟─9cf23f9a-f864-11ea-3a08-af448aceefd8
# ╠═a5b62530-f864-11ea-21e8-71ccfed487f8
# ╠═f6713bec-815b-11eb-2fc4-6b0326a64b16
# ╠═5471ddce-f867-11ea-2519-21981f5ea68b
# ╟─c41df86c-f865-11ea-1253-4942bbdbe9d2
# ╟─7fca33ac-f864-11ea-2a8b-933eb382c172
# ╟─283f5da4-f866-11ea-27d4-957ca2551b92
# ╠═1957f71c-f8eb-11ea-0dcf-339bfa7f96fc
# ╠═54977286-f908-11ea-166d-d1df33f38454
# ╠═7b4e90b4-f866-11ea-26b3-95efde6c650b
# ╟─f574ad7c-f866-11ea-0efa-d9d0602aa63b
# ╟─8775b3fe-f866-11ea-3e6f-9732e39a3525
# ╠═1147cbda-f867-11ea-08fa-ef6ed2ae1e93
# ╟─8a611e36-f867-11ea-121f-317b7c145fe3
# ╟─f7371934-f867-11ea-3b53-d1566684585c
# ╟─987c1f2e-f868-11ea-1125-0d8c02843ae4
# ╟─9e78b048-f868-11ea-192e-d903265d1eb5
# ╟─24df1f32-ec90-11ea-1f6d-03c1bfa5df8e
# ╟─b264f724-81bf-11eb-1052-295b81cde5fb
# ╟─09991230-8526-11eb-04aa-fb904bd2036c
# ╠═aec46a9b-f743-4cbd-97a7-3ef3cac78b12
# ╠═1b8c743e-ec90-11ea-10aa-e3b94f768f82
# ╟─eb867f18-852e-11eb-005f-e15b6d0d0d95
# ╟─f7079016-852e-11eb-3bc9-53fa0846276f
# ╠═870d3efa-f8fc-11ea-1593-1552511dcf86
# ╠═4fb82f18-852f-11eb-278d-cf93571f4adc
# ╟─5fcf832c-852f-11eb-1354-792933a891a5
# ╟─ef4a2a54-81bf-11eb-358b-0da2072f20c8
# ╟─f5358ce4-f86a-11ea-2989-b1f37be89183
# ╠═2c3721da-f86b-11ea-36cf-3fe4c6622dc6
# ╟─03ab44c0-f8fd-11ea-2243-1f3580f98a65
# ╠═6dec0db8-ec93-11ea-24ad-e17870ee64c2
# ╟─5fab2c32-f86b-11ea-2f27-ed5feaac1fa5
# ╟─ae9a2900-ec93-11ea-1ae5-0748221328fc
# ╟─b81c9db2-ec93-11ea-0dbd-4bd0951cb2cc
# ╟─80722856-f86d-11ea-363d-53fc5f6b8152
# ╟─b8fa6a1c-f86d-11ea-3d6b-2959d737254b
# ╟─3547f296-f86f-11ea-1698-53d3c1a0bc30
# ╟─7a83101e-f871-11ea-1d87-4946162777b5
# ╠═e8276b4e-f86f-11ea-38be-218a72452b10
# ╟─7eb51908-f906-11ea-19d2-e947d81cb743
# ╟─4f1980ea-f86f-11ea-3df2-35cca6c961f3
# ╟─f70065aa-835a-11eb-00cb-ffa27bcb486e
# ╠═8b8e6b2e-8531-11eb-1ea6-637db25b28d5
# ╟─3b71142c-f86f-11ea-0d43-47011d00786c
# ╟─c9da6e64-8540-11eb-3984-47fdf8be0dac
# ╠═2ffe7ed0-f870-11ea-06aa-390581500ca1
# ╟─88bbe1bc-f86f-11ea-3b6b-29175ddbea04
# ╟─a5cdad52-f906-11ea-0486-755a6403a367
# ╠═0115c974-f871-11ea-1204-054510848849
# ╟─0935c870-f871-11ea-2a0b-b1b824379350
# ╟─e4af4d26-f877-11ea-1de3-a9f8d389138e
# ╟─bf57f674-f906-11ea-08eb-9b50818a025b
# ╠═17e015fe-f8ff-11ea-17b4-a3aa072cd7b3
# ╠═045b9b98-f8ff-11ea-0d49-5b209319e951
# ╟─cfec1ec4-f8ff-11ea-265d-ab4844f0f739
# ╠═e6e900b8-f904-11ea-2a0d-953b99785553
# ╟─301f4d06-8162-11eb-1cd6-31dd8da164b6
# ╟─aaff88e8-f877-11ea-1527-ff4d3db663db
# ╟─aefa84de-f877-11ea-3e26-678008e9739e
# ╟─0bd9358e-f879-11ea-2c83-ed4e7bf9d903
# ╟─9960e1c2-85a0-11eb-3d68-cd3a07a9c0b5
# ╟─dc4cca88-85a0-11eb-2791-d7610a610e36
# ╠═453689c2-85a2-11eb-2cbc-7d6476b42f2f
# ╟─91b77acc-85a2-11eb-19bb-bd2bdd0c1a68
# ╠═f92c75f6-85a3-11eb-1689-23aeaa3daeb7
# ╠═03069da6-85a4-11eb-2ac5-87b767846550
# ╟─1647a126-85a4-11eb-3923-5f5a6f703403
# ╠═6ec7f980-85a5-11eb-12fc-cb132db28d83
# ╠═40b87cbe-85a4-11eb-30f8-cf7b5e79c19a
# ╠═28a7d6dc-85a5-11eb-0e4b-b7e9b4c592ed
# ╟─67b00528-9a50-44f2-b1f9-225675598370
# ╟─02ef3bb8-5819-420c-b062-28a5523b5cb8
# ╠═701b2cd0-5160-4cd7-91e7-0883cc829a6b
# ╟─8226e48e-b436-4b2b-b855-ca0caed7d914
# ╠═f621e9de-80ba-47c5-918c-3aaa4c951885
# ╟─fd76305e-ec37-4f9d-aaab-459e97bf29d5
# ╟─81dda8f7-d8c2-4199-ad38-2ecc5324896e
# ╠═15808ca3-c0b1-4533-a8e2-cda5e2e4316a
# ╟─467e5a2c-9b6e-44d2-a645-aacf01fcdb0f
# ╟─1cf3e098-f864-11ea-3f3a-c53017b73490
# ╠═2917943c-f864-11ea-3ee6-db952ca7cd67
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
