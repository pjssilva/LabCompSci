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

# ╔═╡ 851c03a4-e7a4-11ea-1652-d59b7a6599f0
# configurando o sistema de pacotes
begin
	import Pkg
	Pkg.activate(mktempdir())
	Pkg.Registry.update()
end

# ╔═╡ d6ee91ea-e750-11ea-1260-31ebf3ec6a9b
# instala um pacote no nosso ambiente
begin
	Pkg.add("Compose")
	# call `using` so that we can use it in our code
	using Compose
end

# ╔═╡ 5acd58e0-e856-11ea-2d3d-8329889fe16f
begin
	Pkg.add("PlutoUI")
	using PlutoUI
end

# ╔═╡ fafae38e-e852-11ea-1208-732b4744e4c2
md"Lista 0, versão 1 -- 2º sem 2021_"

# ╔═╡ 7308bc54-e6cd-11ea-0eab-83f7535edf25
# Edite o código abaixo com o seu nome e email da DAC (sem o @unincamp.br)

student = (name = "João Ninguém", email_dac = "j000000")

# Preciosne o botão ▶ no canto inferior direito desta célula para rodar com os novos 
# dados ou use Shift+Enter

# POde ser necessário esperar que as outras células desse notebook rodem até  fim 
# Continue movendo a página para baixo para ver o que deve fazer

# ╔═╡ cdff6730-e785-11ea-2546-4969521b33a7
md"""

Submetido por: **_$(student.name)_** ($(student.email_dac)@unicamp.br)
"""

# ╔═╡ a2181260-e6cd-11ea-2a69-8d9d31d1ef0e
md"""
# Lista 0: Ficando pronto para o jogo

L0 data disponível: Terça, 10 de agosto de 2021.

**L0 data de entrega: Quinta 12 de agosto de 2021. Mas é melhor entregar na quarta para estar pronto para a aula da quinta_.

Em primeiro lugar: **bem vindo ao curso**. Esto muito animado em dividir com vocês ferramentas e ideias que uso cotidianamente para atacar probemas _reais_.

Espero que todos submetam essa **lista 0**, isso vai ajudar a saber quem conseguiu instalar o ambiente mínimo de uso do curso e tomar alguma atitude corretiva se for necessário. Mesm que você não tenha conseguido fazer muito, pelo menos coloque o seu nome e email da DAC e mande assim mesmo. A nota dessa lista não conta para o curso.🙂
"""

# ╔═╡ 31a8fbf8-e6ce-11ea-2c66-4b4d02b41995
md"""## Logística das listas

As listas serão feita com [notebooks PLuto](https://github.com/fonsp/Pluto.jl). Você deve completar o que for pedido e submeter o notebook no [Moodle](https://moodle.ggte.unicamp.br/course/view.php?id=11421).

As listas serão tipicamente disponibilizadas nas quintas e devem ser entregues na quinta seguint até as 11:59 da noite.

Homeworks will be released on Thursdays and due on Thursdays 11:59pm Eastern time.

O objetivo da L0 é você configurar o seu sistema corretament e testar a entrega. Vocẽ deve entregá-la mas ela não vai contar para a sua nota.
"""

# ╔═╡ f9d7250a-706f-11eb-104d-3f07c59f7174
md"## Requisitos desta lista

- Instalar Julia e Pluto.    
- Resolver o exercício 0.

Isso é tdo. se quiser pode também tentar fazer os outros exercícios quesão _opcionais_. "

# ╔═╡ 430a260e-6cbb-11eb-34af-31366543c9dc
md"""# Instalação

Para conseguir executar esse notebook a contento você terá que instalar a linguagem Julia e o Pluto, siga as istruções do vídeo da primeira aula. Veja-o no Moodle.

Uma vez instalado, inicie o Pluto a partir do REPL da Julia, digitando

```julia
import Pluto
Pluto.run()
```

Use o browser para carregar o arquivo do notebook e siga as instruções para resolver o exercício.

"""

# ╔═╡ a05d2bc8-7024-11eb-08cb-196543bbb8fd
md"## (Requerido) Exercício 0 - _Escrevendo sua prmeira função básica_

Calcule o quadrado de um número, isso é fácil basta mutiplicá-lo por si mesmo. 
##### Algoritmo:

Dado: $x$

Devolva: $x^2$

1. Multiplicando `x` por `x`"

# ╔═╡ e02f7ea6-7024-11eb-3672-fd59a6cff79b
function basic_square(x)
	return 1 # isso está errado, você deve preencher com seu código aqui!
end

# ╔═╡ 6acef56c-7025-11eb-2524-819c30a75d39
let
	result = basic_square(5)
	if !(result isa Number)
		md"""
!!! warning "Não é um número"
    `basic_square` não retornou um número. Você esqueceu de escrever `return`?
		"""
	elseif abs(result - 5*5) < 0.01
		md"""
!!! correct
    Ótimo!
		"""
	else
		md"""
!!! warning "Incorreto"
    Continue tentando!
		"""
	end
end

# ╔═╡ 348cea34-7025-11eb-3def-41bbc16c7512
md"Isso é tudo que deve ser feito nessa lista. Agora submita o notebook no Moodle. Nosso objetivo é saber se você tem um sistema que está funcionando.

Se quiser continuar e trabalhar um pouco mais, colocamos mais alguns exercícios abaixo."

# ╔═╡ b3c7a050-e855-11ea-3a22-3f514da746a4
if student.email_dac === "j000000"
	md"""
!!! danger "Oops!"
    **Antes de submeter**, lembre de preencher o seu nome e o email da DAC no topo desse caderno!
	"""
end

# ╔═╡ 339c2d5c-e6ce-11ea-32f9-714b3628909c
md"## (Opcional) Exercício 1 - _Raiz quadrada usando o método de Newton_

Calcular a raiz quadrada é fácil -- usando o que você aprendeu em Cálculo Numérico. 

Como isso é posível?

##### Algoritmo:

Dado: $x > 0$

Saída: $\sqrt{x}$

1. Comece com um valor `a` > 0
1. Divida `x` por `a`
1. Faça a = média `x/a` e `a`. (A raiz de `x` deve estar entre esses dois números. Porque?)
1. Continue até que `x/a` é aproximadamente igual a `a`. Devolta `a` como a raiz quadrada.

Pode ocorrer de você nunca obter `x/a` _exatamente igual_ a `a`, lembre de novo de cálculo numérico. Então se o seu código tentar continuar até que `x/a == a`, ele pode não parar nunca.

Então o seu algotimo deve possuir um parâmetro `error_margin`, que será usado para decidir quando `x/a` e `a` são tão parecidos que é permitido parar.
"

# ╔═╡ 56866718-e6ce-11ea-0804-d108af4e5653
md"### Exercício 1.1

O passo 3 do algoritimo define a próxima aproximação como a média entre o novo valor `x/a` e o anterior `a`.

Isso faz sentido porque a raiz desejada está entre esses dois números `x/a` e `a`. Porque?
"

# ╔═╡ bccf0e88-e754-11ea-3ab8-0170c2d44628
ex_1_1 = md"""
Escreva sua resposta aqui. Agora é uma boa hora para ler sobre Markdown.
""" 

# ╔═╡ e7abd366-e7a6-11ea-30d7-1b6194614d0a
if !(@isdefined ex_1_1)
	md"""Do not change the name of the variable - write you answer as `ex_1_1 = "..."`"""
end

# ╔═╡ d62f223c-e754-11ea-2470-e72a605a9d7e
md"### Exercício 1.2

Escreava uma fnção `newton_sqrt` que implementa o algorimo descrito."

# ╔═╡ 4896bf0c-e754-11ea-19dc-1380bb356ab6
function newton_sqrt(x, error_margin=0.01, a=x/2) # a=x/2 é um chute padrão para o `a` inicial
	return x #  Isto está errado, complete com seu código.
end

# ╔═╡ 7a01a508-e78a-11ea-11da-999d38785348
newton_sqrt(2)

# ╔═╡ 682db9f8-e7b1-11ea-3949-6b683ca8b47b
let
	result = newton_sqrt(2, 0.01)
	if !(result isa Number)
		md"""
!!! warning "Não é um número"
    `newton_sqrt` não retornou um número. Você esqueceu de digitar `return`?
		"""
	elseif abs(result - sqrt(2)) < 0.01
		md"""
!!! correct
    Muito bem!
		"""
	else
		md"""
!!! warning "Incorreto"
    Continue tentando!
		"""
	end
end

# ╔═╡ 088cc652-e7a8-11ea-0ca7-f744f6f3afdd
md"""
!!! hint
    `abs(r - s)` é a distância entre `r` e `s`
"""

# ╔═╡ 5e24d95c-e6ce-11ea-24be-bb19e1e14657
md"## (Opcional) Exercício 2 - _triângulo de Sierpinksi_

O triângulo de Sierpinski triangle é definido _recursivamente_:

- Um triângulo Sierpinski de complexidade N é uma figura na forma de um triângulo que é formada por 3 figuras triângulares que são por sua vez triângulos de Sierpinski de complexidade N-1.

- Um triângulo Sierpinski de complexidade 0 é um triângulo sólido simples e equilátero.
"

# ╔═╡ 6b8883f6-e7b3-11ea-155e-6f62117e123b
md"Para desenhar um triângulo de Sierpinski, nós vamos usar um pacote externo, [_Compose.jl_](https://giovineitalia.github.io/Compose.jl/latest/tutorial). Vamos configurar o ambiente e instalar o pacote.

Um pacote é um software que possui um grupo de funcionalidades correlacionadas que podem ser usadas na forma de uma _caixa preta_ de acordo com sua especificação. Há [vários pacores Julia](https://juliahub.com/ui/Home).
"

# ╔═╡ dbc4da6a-e7b4-11ea-3b70-6f2abfcab992
md"Como na definição a função `sierpinksi` é _recursiva_: ela chama a si mesma."

# ╔═╡ 02b9c9d6-e752-11ea-0f32-91b7b6481684
complexity = 3

# ╔═╡ 1eb79812-e7b5-11ea-1c10-63b24803dd8a
if complexity == 3 
	md"""
Tente alterar valor de **`complexity` para `5`** na célular acima. 

Aperte `Shift+Enter` para a mudança fazer efeito.
	"""
else
	md"""
**Muito bem!** Como você pode ver as diferentes células do caderno estão ligadas pelas variáveis que elas definem e usam, como numa planilha de cálculo!
	"""
end

# ╔═╡ d7e8202c-e7b5-11ea-30d3-adcd6867d5f5
md"### Exercício 2.1

Como você pode ver a área total coberta pelos triângulos cheios diminui a medida que a complexidade aumenta."

# ╔═╡ f22222b4-e7b5-11ea-0ea0-8fa368d2a014
md"""
Você consegue escrever uma função que calcula a a área de `sierpinski(n)`, como uma fração da área de `sierpinski(0)`?

Teremos:
```
area_sierpinski(0) = 1.0
area_sierpinski(1) = 0.??
...
```
"""

# ╔═╡ ca8d2f72-e7b6-11ea-1893-f1e6d0a20dc7
function area_sierpinski(n)
	return 1.0 # Complete com sua implementação
end

# ╔═╡ 71c78614-e7bc-11ea-0959-c7a91a10d481
if area_sierpinski(0) == 1.0 && area_sierpinski(1) == 3 / 4
	md"""
!!! correct
    Muito bem!
	"""
else
	md"""
!!! warning "Incorreto"
    Continue tentando!
	"""
end

# ╔═╡ c21096c0-e856-11ea-3dc5-a5b0cbf29335
md"**Let's try it out below:**"

# ╔═╡ 52533e00-e856-11ea-08a7-25e556fb1127
md"Complexity = $(@bind n Slider(0:6, show_value=true))"

# ╔═╡ c1ecad86-e7bc-11ea-1201-23ee380181a1
md"""
!!! hint
    Você pode escrever a área `area_sierpinksi(n)` como uma função da `area_sierpinski(n-1)`?
"""

# ╔═╡ a60a492a-e7bc-11ea-0f0b-75d81ce46a01
md"Isso é tudo por enquanto, a gente se vê na próxima lista"

# ╔═╡ dfdeab34-e751-11ea-0f90-2fa9bbdccb1e
triangle() = compose(context(), polygon([(1, 1), (0, 1), (1 / 2, 0)]))

# ╔═╡ b923d394-e750-11ea-1971-595e09ab35b5
# Você pode mover a ordem das células, para facilitar a apresentação. 
# Pluto consegue manter a dependência entre trechos de código e executá-los 
# de maneira a obedecer a dependência entre os diversos trechos. Assim você
# está livre para reordenar trechos de código de forma a promover uma melhor
# organização / compreensão.

function place_in_3_corners(t)
	# Uses the Compose library to place 3 copies of t
	# in the 3 corners of a triangle.
	# treat this function as a black box,
	# or learn how it works from the Compose documentation here https://giovineitalia.github.io/Compose.jl/latest/tutorial/#Compose-is-declarative-1
	compose(context(),
			(context(1/4,   0, 1/2, 1/2), t),
			(context(  0, 1/2, 1/2, 1/2), t),
			(context(1/2, 1/2, 1/2, 1/2), t))
end

# ╔═╡ e2848b9a-e703-11ea-24f9-b9131434a84b
function sierpinski(n)
	if n == 0
		triangle()
	else
		t = sierpinski(n - 1) # constroi recursivamente um triângulo menor
		place_in_3_corners(t) # Coloca os três triângulos menores nos cantos 
		                      # para formar o triângulo maior.
	end
end

# ╔═╡ 9664ac52-e750-11ea-171c-e7d57741a68c
sierpinski(complexity)

# ╔═╡ df0a4068-e7b2-11ea-2475-81b237d492b3
sierpinski.(0:6)

# ╔═╡ 147ed7b0-e856-11ea-0d0e-7ff0d527e352
md"""

Sierpinski's triangle of complexity $(n)

 $(sierpinski(n))

has area **$(area_sierpinski(n))**

"""

# ╔═╡ Cell order:
# ╟─fafae38e-e852-11ea-1208-732b4744e4c2
# ╟─cdff6730-e785-11ea-2546-4969521b33a7
# ╠═7308bc54-e6cd-11ea-0eab-83f7535edf25
# ╟─a2181260-e6cd-11ea-2a69-8d9d31d1ef0e
# ╟─31a8fbf8-e6ce-11ea-2c66-4b4d02b41995
# ╟─f9d7250a-706f-11eb-104d-3f07c59f7174
# ╟─430a260e-6cbb-11eb-34af-31366543c9dc
# ╟─a05d2bc8-7024-11eb-08cb-196543bbb8fd
# ╠═e02f7ea6-7024-11eb-3672-fd59a6cff79b
# ╟─6acef56c-7025-11eb-2524-819c30a75d39
# ╟─348cea34-7025-11eb-3def-41bbc16c7512
# ╟─b3c7a050-e855-11ea-3a22-3f514da746a4
# ╟─339c2d5c-e6ce-11ea-32f9-714b3628909c
# ╟─56866718-e6ce-11ea-0804-d108af4e5653
# ╠═bccf0e88-e754-11ea-3ab8-0170c2d44628
# ╟─e7abd366-e7a6-11ea-30d7-1b6194614d0a
# ╟─d62f223c-e754-11ea-2470-e72a605a9d7e
# ╠═4896bf0c-e754-11ea-19dc-1380bb356ab6
# ╠═7a01a508-e78a-11ea-11da-999d38785348
# ╟─682db9f8-e7b1-11ea-3949-6b683ca8b47b
# ╟─088cc652-e7a8-11ea-0ca7-f744f6f3afdd
# ╟─5e24d95c-e6ce-11ea-24be-bb19e1e14657
# ╟─6b8883f6-e7b3-11ea-155e-6f62117e123b
# ╠═851c03a4-e7a4-11ea-1652-d59b7a6599f0
# ╠═d6ee91ea-e750-11ea-1260-31ebf3ec6a9b
# ╠═5acd58e0-e856-11ea-2d3d-8329889fe16f
# ╟─dbc4da6a-e7b4-11ea-3b70-6f2abfcab992
# ╠═e2848b9a-e703-11ea-24f9-b9131434a84b
# ╠═9664ac52-e750-11ea-171c-e7d57741a68c
# ╠═02b9c9d6-e752-11ea-0f32-91b7b6481684
# ╟─1eb79812-e7b5-11ea-1c10-63b24803dd8a
# ╟─d7e8202c-e7b5-11ea-30d3-adcd6867d5f5
# ╠═df0a4068-e7b2-11ea-2475-81b237d492b3
# ╟─f22222b4-e7b5-11ea-0ea0-8fa368d2a014
# ╠═ca8d2f72-e7b6-11ea-1893-f1e6d0a20dc7
# ╟─71c78614-e7bc-11ea-0959-c7a91a10d481
# ╟─c21096c0-e856-11ea-3dc5-a5b0cbf29335
# ╟─52533e00-e856-11ea-08a7-25e556fb1127
# ╟─147ed7b0-e856-11ea-0d0e-7ff0d527e352
# ╟─c1ecad86-e7bc-11ea-1201-23ee380181a1
# ╟─a60a492a-e7bc-11ea-0f0b-75d81ce46a01
# ╠═dfdeab34-e751-11ea-0f90-2fa9bbdccb1e
# ╠═b923d394-e750-11ea-1971-595e09ab35b5
