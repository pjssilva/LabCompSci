### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 1ccb3a84-88d4-11eb-2499-91af66e78e89
begin
    import Pkg
    Pkg.activate(mktempdir())
    using Plots
end

# ╔═╡ 47452d72-88d6-11eb-27ef-bbc1d061060d
md"""
## Documentação



* Documentação do Plots [Dicas úteis](https://docs.juliaplots.org/latest/basics/#Useful-Tips)
* Documentação do Plots [Exemplos](https://docs.juliaplots.org/latest/generated/gr/)
* [Atributos de Plot](http://docs.juliaplots.org/latest/generated/attributes_plot/)
* [Atributos de Axis](http://docs.juliaplots.org/latest/generated/attributes_axis/#Axis)
* [Nomes de cores](http://juliagraphics.github.io/Colors.jl/stable/namedcolors/)
"""

# ╔═╡ 2a2338e4-88d4-11eb-0e6b-03609b700baa
md"""
## Tempo de inicialização

A inicialização da `Plots` é bastante demorada e sim, isso é chato. Esse é um problema conhecido com Julia, mas ela compensa sendo rápida depois de "pegar no tranco". Pegue uma xícara de café... ☕☕☕☕☕☕☕☕☕
"""

# ╔═╡ 4316799c-88d4-11eb-0e83-a7df319711ad
md"""
## Primeiro gráfico

A forma mais simples de gerar um gráfico de uma função é usar a função `plot`.
"""

# ╔═╡ 6fcad280-88d4-11eb-310f-5f89a5d21f9b
plot(rand(4))

# ╔═╡ 8ed02562-01fd-4e5d-89e7-58ba8f155aa7
md"""Note que ela já tenta fazer múltiplas coisas para você, talvez um pouco mais do outras bibliotecas gráficas. De maneira a já gerar um gráfico pronto. Um exemplo é a legenda `y1` que é adicionada aumaticamente e que ajuda a saber qual foi a primeira função a ser desenhada. Você pode mudar o texto da legenda passando um parâmetro extra para a `plot` chamado de `label`. Se quiser omitir a lengeda passe para `label` o valor `false` ou a string vazia (`""`).
"""

# ╔═╡ 63da4054-88d5-11eb-29c9-b3648548c367
md"""
## Adicionando mais informação
"""

# ╔═╡ 6b55e978-88d5-11eb-1fea-739e61bbb35a
begin
    plot!(rand(4))
    scatter!(rand(4))
end

# ╔═╡ c5dde003-4f55-4c03-8ca5-ed00da6854fe
md"Aqui vemos uma característica interessante de Julia. Nessa linguagem convencionou-se que funções cujo nome termina com um ponto de exclamação alteram o valor de um de seus argumentos (tipicamente o primeiro) ou de algo que já existe. Assim a função `plot` cria uma nova figura, já a função `plot!` adiciona o gráfico de uma nova função a uma figura já existente. Isso é muito usado em `Plots`. Por exemplo para adicionar um título a figura depois de ela já ter sido criada você pode usar a função `title!`. 

Outra novidade na figura acima é o uso da função do tipo `scatter`. Essa função ao invés de desenhar uma função, imaginando que os pontos repassados estão ligados, considera que devem apenas ser desenhados os pontos isolados, nesse caso usando o símbolo do círculo. Note que assim como a função plot, como foi repassado apenas um vetor, ela assumiu que ele possui os valores da coordenada y e para a coordenada x usou um vetor que começa em 1 e vai até o número de elementos do vetor y pulando de um em um."

# ╔═╡ 198eb00c-88d5-11eb-3d3c-3963d197f0e0
md"""
## Removendo elementos

Como disse, a função plots possui vários parâmetros. Eles podem ser utilizados para controlar diversos detalhes da apresentação. Por exemplo, você pode apagar os eixos (`axis`), a malha (`grid`) ou mesmo os números que são colocados nos eixos (`ticks`). 

A quantidade de parâmetros possíveis é muito grande, dê uma olhada na documentação no início desse caderno.
"""

# ╔═╡ 2b4cc1d0-88d5-11eb-0afd-3988abd9a870
plot!(legend = false, axis = false, grid = false, ticks = false)

# ╔═╡ cf89db1e-88d7-11eb-2a92-850c7d46a296
md"""
## Controlando a razão de aspecto
"""

# ╔═╡ da7b4c10-88d7-11eb-011e-dbb639e6fa2b
let
    angles = LinRange(0, 2π, 360)
    x = cos.(angles)
    y = sin.(angles)
    plot(x, y, ratio = 1, legend = false)
end

# ╔═╡ df146faa-edc8-4c7f-b3c0-87695336b0c9
md"""
Tipicamente a razão de aspecto (relação entre os tamanhos no eixo x e y) não é quadrada. Isso faz alguns gráficos mais agradáveis, mas pode deformar as figuras em casos importantes. Essa razão pode ser definida com o parâmetro `ratio`. Colocá-lo em 1 força a razão "quadrada". Experimente mudando o `ratio` acima e vendo o que ocorre.
"""

# ╔═╡ cca58686-88d8-11eb-2fe4-d7d378c5408a
md"""
##  Matrizes com cores (mapas de calor)

Você pode apresentar matrizes como se fossem figuras. Os valores guardados na matriz serão então interpretados como uma cor para que possam ser observados.
"""

# ╔═╡ d2c81aec-88d8-11eb-0e25-57a2068c3bf9
A = [1 1000 1; 1 1 1; 1 1 1]

# ╔═╡ e3f7d1ea-88d8-11eb-21bf-cbcdec1e8810
heatmap(
    A,
    ratio = 1,
    yflip = true,
    legend = false,
    axis = false,
    grid = false,
    ticks = false,
)

# ╔═╡ f378e1a5-e3c1-474b-a58c-60255067ba2a
md"""
Note o uso do parâmtro `yflip` acima. Tipicamente o heatmap tem o eixo x crescendo para cima e em figuras isso é tipicamente o que você quer. Mas se você quer vez uma matriz matemática o "eixo y" (que é o número da linha da matriz) cresce para baixo! Então invertemos a ordem do eixo y usando o parâmetro `yflip` para evitar que a imagem da matriz pareça invertida.
"""

# ╔═╡ b059780e-88db-11eb-028c-6b07355fb1ab
heatmap(rand(10, 10), ratio = 1, clim = (0, 1), legend = false, axis = false, ticks = false)

# ╔═╡ 410bfac0-0d6d-4c02-b058-d9e0c13c5985
md"""
No exemplo acima usamos o parâmetro `clim` para definir a faixa de valores possíveis para as entradas da matriz. Como ele é gerada pela função `rand` que devolve valores aleatórios com distribuição entre $[0, 1)$, informamos essa faixa através do `clim`.

Já no exemplo abaixo controlamos as cores passando diretamente um vetor de possíveis cores. Note que o Plots define tipos de cores RGB e RGBA (o A é de alfa, o canal de transparência). Brinque um pouco mudando os valores e vendo o impacto abaixo. Note também que como não definimos `yflip=true` a matriz é apresentanda de cabeça-para-baixo.
"""

# ╔═╡ 48561d5a-8991-11eb-2a55-db793e4c9fea
begin
    MM = [0 1 0; 0 0 0; 1 0 0]

    whiteblack = [RGBA(1, 1, 1, 0), RGB(0, 0, 0)]
    heatmap(
        MM,
        c = whiteblack,
        aspect_ratio = 1,
        ticks = 0.5:3.5,
        lims = (0.5, 3.5),
        gridalpha = 1,
        legend = false,
        axis = false,
        ylabel = "i",
        xlabel = "j",
    )
end

# ╔═╡ 7870b9c2-a78a-459b-b706-e079755fe4a3
md"""
De fato `Plots` é um pacote bastante geral que possui muitas funcinalidade e várias extensões. Despois dessa rápida introdução simples vá para o [tutorial oficial](https://docs.juliaplots.org/latest/tutorial/) e aprenda um ponto mais.
"""

# ╔═╡ 3395ee1c-8d81-11eb-3e94-b1373d69dc93


# ╔═╡ Cell order:
# ╠═1ccb3a84-88d4-11eb-2499-91af66e78e89
# ╟─47452d72-88d6-11eb-27ef-bbc1d061060d
# ╟─2a2338e4-88d4-11eb-0e6b-03609b700baa
# ╟─4316799c-88d4-11eb-0e83-a7df319711ad
# ╠═6fcad280-88d4-11eb-310f-5f89a5d21f9b
# ╟─8ed02562-01fd-4e5d-89e7-58ba8f155aa7
# ╟─63da4054-88d5-11eb-29c9-b3648548c367
# ╠═6b55e978-88d5-11eb-1fea-739e61bbb35a
# ╟─c5dde003-4f55-4c03-8ca5-ed00da6854fe
# ╟─198eb00c-88d5-11eb-3d3c-3963d197f0e0
# ╠═2b4cc1d0-88d5-11eb-0afd-3988abd9a870
# ╟─cf89db1e-88d7-11eb-2a92-850c7d46a296
# ╠═da7b4c10-88d7-11eb-011e-dbb639e6fa2b
# ╟─df146faa-edc8-4c7f-b3c0-87695336b0c9
# ╟─cca58686-88d8-11eb-2fe4-d7d378c5408a
# ╠═d2c81aec-88d8-11eb-0e25-57a2068c3bf9
# ╠═e3f7d1ea-88d8-11eb-21bf-cbcdec1e8810
# ╟─f378e1a5-e3c1-474b-a58c-60255067ba2a
# ╠═b059780e-88db-11eb-028c-6b07355fb1ab
# ╟─410bfac0-0d6d-4c02-b058-d9e0c13c5985
# ╠═48561d5a-8991-11eb-2a55-db793e4c9fea
# ╟─7870b9c2-a78a-459b-b706-e079755fe4a3
# ╟─3395ee1c-8d81-11eb-3e94-b1373d69dc93
