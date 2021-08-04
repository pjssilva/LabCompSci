### A Pluto.jl notebook ###
# v0.15.1

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

# ╔═╡ da1d65a0-ec42-11ea-0141-334c9eeeb035
begin
	using Pkg
	Pkg.activate(mktempdir())
	Pkg.add(["PlutoUI", "Images", "ImageMagick"])
	using PlutoUI
	using Images
end

# ╔═╡ fbe33f22-672e-45b2-a1b1-30bb24033db8
md"""
#### Tradução livre de [`abstraction.jl`](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week1/abstraction.jl)
"""

# ╔═╡ 60ae819a-70a7-11eb-31d4-750c7f5dc6ca
PlutoUI.TableOfContents(aside=true)

# ╔═╡ 792c6a62-ec41-11ea-01f3-73e7eee23cc7
md"""
#### Inicializando os pacotes

_Ao executar esse notebook pela primeira vez ele pode demorar muito para instalar e inicializar pacotes. Ele também pega umas imagens na Internet, outro motivo de espera. Por isso tenha um pouco de paciência, vá fazer outra coisa e volte em alguns instantes!_
"""

# ╔═╡ ef1bfa16-70ea-11eb-189c-a54db292cd6f
md"""
## Introdução

Esse caderno vai falar com você sobre _abstração_. Uma das formas de se pensar em abstração, principalmente do ponto de vista computacional, é como o oposto da _especialização_. Ou seja, abstração é a arte de se ver o que há de comum em objetos diferentes, focando no que importa para a tarefa do momento.

Vamos ver isso com um exemplo meio bobo, mas elucidativo.

### O que é _um_?

Antes de tentarmos partir para os fundamentos da matemática, deixe-me apresentar alguns objetos que podem ser vistos naturalmente como _um_ em contextos diferentes.
"""

# ╔═╡ 6fcac482-70ee-11eb-0b80-ff41c708053b
md"Cada um desses itens pode ser interpretado como o _um_ em contextos diferentes. Ou seja eles são diferentes versões de representações _especializadas_ do _um):
1. Como um inteiro
1. Como um float (ponto flutuante)
1. Como uma string (cadeia de caracteres)
1. Como um número racional (sim, Julia tem isso!)
1. Como uma figura enfeitada do número 1
1. A matriz identidade 2x2
1. Como um foguete

É claro que cada um desses é apenas um exemplo da ideia abstrata de _um_. Como esse é um conceito simples e fundamental, há inúmeras represetações do _um_ nas várias linguagens, notações, em manifestações artísticas, etc. 

A diferença entre eles é clara. De fato nós deixamos isso claro ao descrever cada um deles como sua versão especializada. Mas para o computador, como será que ele diferencia essas diferentes formas do _um_?
"

# ╔═╡ 9ebc079a-70f0-11eb-07d9-f9e80f3f4584
md"Vemos que o computador diferencias essas diferentes forma usando tipos diferentes para armaezenar cada um."

# ╔═╡ 15f7f90a-70f0-11eb-0d41-63677e4023f4
md"### What is a collection of _one_s?

Now, I want to make a collection of ones for some reason. Below is a way for you to experiment building this collection with different _one_s. As you do this experiment, I want you to look at what stays in the same in the Julia output, and what doesn't."

# ╔═╡ f6886d90-70ed-11eb-07c4-471ee267e7c1
md"""
Antes mesmo de rodar os exemplo, mas apenas lendo o código, isso chama atenção: como isso roda? Essa dúvida deve ser particularmente forte para programadores de linguagens fortemente tipadas como C, C++ ou Fortran. Em Julia, e outras linguagens dinâmicas, o código não parece se preocupar com qual é o _um_ que estou colocando na matriz! Ele simplesmente cria uma matriz do tipo adequado.

E sim, é exatamente essa a força da abstração. Para o tipo de operações que estamos fazendo não há motivo para diferenciar entre os diferentes tipos _específicos_ de _um_. A linguagem é "esperta", ou "ágil", o suficience para criar a matriz do tipo natural desejado e continuar em frente.

Note ainda que a informação que Julia devolve é bastante informativa. Veja quais seriam as primeiras linhas (que informam o tipo dos elementos armazenados na matriz) para alguns diferentes _uns_:

```
array = 3x4 Array{Int64, 2}
array = 3x4 Array{Float64, 2}
array = 3x4 Array{Rational{Int64}, 2}
```

Atente que todos esse tem a mesma forma geral: `3x4 Array{***, 2}`.
"""

# ╔═╡ 3c1a3cf8-70f8-11eb-3c18-375207f321eb
md"""
## Um primeiro encontro com a abstração

Agora, vamos ver como trabalhar com uma coleção de uns, no caso uma matriz de uns, sem que o código precise saber qual o tipo específico de um que ela armazena. Ou seja, queremos escrever uma função que recebe a coleção e modifica a matriz em uma posição específica, mas que não está a priori "consciente" de qual é o tipo que ela manipula. 
"""

# ╔═╡ 19f4ddb0-ec44-11ea-20b9-5d97fb2b1cf4
function insert(new, A, i, j)
	B = copy(A)
	B[i,j] = new
	return B
end

# ╔═╡ 424f5f10-ec44-11ea-076d-f3cba4435e0c
begin
	max_i, max_j = 3, 4
	md"""
	i: $(@bind i Slider(1: max_i, show_value=true))
	j: $(@bind j Slider(1: max_j, show_value=true))
	"""
end

# ╔═╡ 71ac08ea-7145-11eb-237d-5506adfb9533
begin
	one_number_array = fill(1, max_i, max_j)
	insert(5, one_number_array, i, j)
end

# ╔═╡ ee43d808-70fa-11eb-0cc6-337279f41494
md"""
Mais uma vez vemos o poder da abstração. Nós escrevemos uma função que pode manipular matrizes com objetos de diferentes tipos. Ela não se importa com o tipo específico do que está dentro da matriz, já que tudo que ela faz é manipular o seu conteúdo e para isso precisamos basicamente do operador de atribuição apenas, que naturalmente funciona com qualquer tipo. Aí a mesma função funcionou para matrizes de tipos completamente distintos: imagens e inteiros. 

Como Julia faz isso? Diferente de outras linguagens, a primeira vez que ele vê uma chamada concreta de uma função ele cria uma versão especializada para aquele tipo, compila e depois executa. Isso faz com o código a partir da segunda chamada seja extremamente eficiente, é código compilado. Isso porque a linguagem tem um ferramental que guarda as diferentes versões compiladas e chama a versão correta no momento de uma nova chamada. O preço a pagar: a primeira chamada, que gera uma nova versão que deve ser compilada, é mais demorada. Isso ajuda a explicar porque Julia parece lento de início, mas depois que "pega no tranco", ou seja que compila o código, é estremamente rápida.
"""

# ╔═╡ 263a8a0a-70ee-11eb-236d-c941ba63dff3
md"
## Conclusão

A ideia é que as linguagens de computação deveria permitir realizar todas as operações que fazem sentido para os diferentes tipos de maneira natural. Isso porque muitas vezes a mesma operação faz sentido para diferentes tipos. Então podemos abstrair as diferenças e escrever um único código para o que esses objetos têm em comum. 

A especialização deve ser usada apenas quando estritamente necessária.
"

# ╔═╡ 52461588-ea1a-4e7d-aec2-3de388d31656
md"""
## Apêndice
"""

# ╔═╡ 1a2a9000-ec43-11ea-3f39-8312ea286a92
begin
	oneimage = load(download("https://gallery.yopriceville.com/var/albums/Free-Clipart-Pictures/Decorative-Numbers/Cute_Number_One_PNG_Clipart_Image.png?m=1437447301"))
	rocket = load(download("https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/Bangabandhu_Satellite-1_Mission_%2842025499722%29.jpg/800px-Bangabandhu_Satellite-1_Mission_%2842025499722%29.jpg"))
	nothing
end


# ╔═╡ 0504ac94-70ee-11eb-1c4e-977d9e7d35c9
one = [
	1,
	1.0,
	"one",
	1//1,
	oneimage,
	[1 0; 0 1],
	rocket,
]

# ╔═╡ 0b1668ba-ec42-11ea-3e50-ed97c5b17ced
computer_ones = typeof.(one)

# ╔═╡ b2239b96-70ef-11eb-0b85-21ecab25dc9f
begin
	one_keys = ["1", "1.0", "one", "1//1", "Cute One", "2x2 Identity", "One rocket"]
	lookup_element = Dict(one_keys .=> one)
	md"$(@bind element_key Select(one_keys))"
end

# ╔═╡ 4251f668-70aa-11eb-3d89-35f8d53b7d9b
# your chosen one
element = lookup_element[element_key]

# ╔═╡ f1568d10-ec41-11ea-3dd2-a9cb273ce5b8
#its type
typeof(element)

# ╔═╡ ab02d850-ec41-11ea-10b2-a1b600b12658
# a 3x4 array of this one.
array = fill(element, 3, 4)

# ╔═╡ 5363a400-ec44-11ea-284e-d13a8872551c
begin
	one_image_array = fill(oneimage, max_i, max_j)
	insert(rocket, one_image_array, i, j)
end

# ╔═╡ Cell order:
# ╟─fbe33f22-672e-45b2-a1b1-30bb24033db8
# ╟─60ae819a-70a7-11eb-31d4-750c7f5dc6ca
# ╟─792c6a62-ec41-11ea-01f3-73e7eee23cc7
# ╟─ef1bfa16-70ea-11eb-189c-a54db292cd6f
# ╠═0504ac94-70ee-11eb-1c4e-977d9e7d35c9
# ╟─6fcac482-70ee-11eb-0b80-ff41c708053b
# ╠═0b1668ba-ec42-11ea-3e50-ed97c5b17ced
# ╟─9ebc079a-70f0-11eb-07d9-f9e80f3f4584
# ╟─15f7f90a-70f0-11eb-0d41-63677e4023f4
# ╠═b2239b96-70ef-11eb-0b85-21ecab25dc9f
# ╠═4251f668-70aa-11eb-3d89-35f8d53b7d9b
# ╠═f1568d10-ec41-11ea-3dd2-a9cb273ce5b8
# ╠═ab02d850-ec41-11ea-10b2-a1b600b12658
# ╟─f6886d90-70ed-11eb-07c4-471ee267e7c1
# ╟─3c1a3cf8-70f8-11eb-3c18-375207f321eb
# ╠═19f4ddb0-ec44-11ea-20b9-5d97fb2b1cf4
# ╟─424f5f10-ec44-11ea-076d-f3cba4435e0c
# ╠═5363a400-ec44-11ea-284e-d13a8872551c
# ╠═71ac08ea-7145-11eb-237d-5506adfb9533
# ╟─ee43d808-70fa-11eb-0cc6-337279f41494
# ╟─263a8a0a-70ee-11eb-236d-c941ba63dff3
# ╟─52461588-ea1a-4e7d-aec2-3de388d31656
# ╠═da1d65a0-ec42-11ea-0141-334c9eeeb035
# ╠═1a2a9000-ec43-11ea-3f39-8312ea286a92
