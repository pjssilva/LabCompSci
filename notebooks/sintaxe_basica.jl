### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 0d3aec92-edeb-11ea-3adb-cd0dc17cbdab
md"# Um pouco de Julia

Lembre-se que para executar esse caderno em sua máquina é preciso primeiro instalar a linguagem Julia e o Pluto.

Obs: Esse caderno é apenas uma introcução bem rápida à Julia para quem nunca viu a linguagem. Ele não tenta de fato ensinar Julia, apenas faz um sobrevoo parnorâmico. Para apresnder Julia sugiro fortemente que você procure um texto introdutório completo ou mesmo um livro.

Uma boa opção, em português, é o capítulo 1 do [texto do Leandro Martínez](http://leandro.iqm.unicamp.br/m3g/main/didatico/simulacoes2/simulacoes2.pdf), do IQ. Um bom livro é o [Julia 1.0 Programming](https://www.packtpub.com/product/julia-1-0-programming-second-edition/9781788999090) do Balbert.

Outra ótima fonte de informção é o [manual da linguagem](https://docs.julialang.org/en/v1/).
"


# ╔═╡ 3b038ee0-edeb-11ea-0977-97cc30d1c6ff
md"## Variáveis

Em Julia definimos variáveis usando a atribuição `=`, nos moldes de linguagens dinâmicas como Python. O tipo da variável é então o tipo do valor que lhe foi atribuido. Há formas de se definir tipos explícitos de parâmetros de função e/ou variáveis locais para limitar os possíveis valores que elas podem receber, para ver isso consulte outro texto.

De posse de uma variável é possível fazer conta com elas, que lembram os valores que lhe foram atribuidos (afinal de contas, essa é a função das variáveis). Note também que em Julia, quando não há dúvida, é possível omitir o sinal de multiplicação, assim como na notação matemática usual
"

# ╔═╡ 3e8e0ea0-edeb-11ea-22e0-c58f7c2168ce
x = 3


# ╔═╡ 59b66862-edeb-11ea-2d62-71dcc79dbfab
y = 2x

# ╔═╡ 5e062a24-edeb-11ea-256a-d938f77d7815
md"Ao executar uma expressão Julia, tipicamente, devolve o o valor calculado. Assim o Pluto apresenta esse valor final como resposta da respectiva célula. Caso você queira suprimir esse valord e reposta, impedido que ele seja impresso, coloque um `;` no final.
"

# ╔═╡ 7e46f0e8-edeb-11ea-1092-4b5e8acd9ee0
md"Se você quiser qual o tipo do valor que está em uma variável use `typeof`:"

# ╔═╡ 8a695b86-edeb-11ea-08cc-17263bec09df
typeof(y)

# ╔═╡ 8e2dd3be-edeb-11ea-0703-354fb31c12f5
md"## Funções"

# ╔═╡ 96b5a28c-edeb-11ea-11c0-597615962f54
md"Há duas formas de definir funções. Uma mais simples e adequada para funções mais curtas usa uma notação próxima a matemática:"

# ╔═╡ a7453572-edeb-11ea-1e27-9f710fd856a6
f(x) = 2 + x

# ╔═╡ b341db4e-edeb-11ea-078b-b71ac00089d7
md"O nome da função a representa, ele é uma variável como outra qualquer. Ao se digitar o nome de uma função obtemos alguma informação ela: quantos *métodos* ela define. Aqui vemos algo novo, na verdade o nome de uma função representa todo um conjunto de funções concretas que são diferentes entre si pelos número e tipos dos parâmetros de entrada. Essas funções concretas são chamadas de métodos. Vamos pegar inicialmente informação sobre a função que acabamos de criar.
"

# ╔═╡ a92ff397-cd8d-4cd6-8b1a-d1b8703ea11f
md"Agora podemos reutilizar o nome e definir uma funçao f que recebe dois valores. Note que depois disso o nome `f` está associada às dus funções concretas que são distintas. Julia sabe qual função chamar pelo número de parâmetros. É também possível usar o tipo dos parâmetros para fazer a distinção."

# ╔═╡ 2f0acda8-b30c-4fa1-bd69-3d97ffcf84f0
f(x, y) = x*y + 2

# ╔═╡ 23f9afd4-eded-11ea-202a-9f0f1f91e5ad
f

# ╔═╡ cc1f6872-edeb-11ea-33e9-6976fd9b107a
f(10)

# ╔═╡ e7583d52-4887-4619-aee5-3425a188a94c
f

# ╔═╡ 4151cf81-5b76-4049-bb43-c1eeb6b7096e
"f(10) = $(f(10)), f(3, 5) = $(f(3, 5))"

# ╔═╡ b5e2339d-ffc5-4083-b917-b7e4425f2419
md"Acima usamos outra característica de Julia: a interpolação de valores. Se dentro de uma cadeia de caracteres (string) Julia encontra o símbolo `$` a linguagem interpretao que vem a seguir como uma expressão que deve ser avaliada e substituida pela resposta.
"

# ╔═╡ ce9667c2-edeb-11ea-2665-d789032abd11
md"Funções mais longas, que envolvam mais do que uma simples expressão, são definidas iniciando com a palavra reservada `function` e terminando com 'end`:"

# ╔═╡ d73d3400-edeb-11ea-2dea-95e8c4a6563b
function g(x, y)
	z = x + y
	return z^2
end

# ╔═╡ e04ccf10-edeb-11ea-36d1-d11969e4b2f2
g(1, 2)

# ╔═╡ e297c5cc-edeb-11ea-3bdd-090f415685ab
md"## Laços `For`"

# ╔═╡ ec751446-edeb-11ea-31ba-2372e7c71b42
md"Use `for` para percorrer um conjunto de valores pré-determinados:"

# ╔═╡ fe3fa290-edeb-11ea-121e-7114e5c573c1
let s = 0
	
	for i in 1:10
		s += i    # Equivalente a s = s + i
	end
	
	s
end

# ╔═╡ 394b0ec8-eded-11ea-31fb-27392068ef8f
md"A expressão `1:10` representa uma sequência de números que inicia no 1 e vai a 10 (pulando de 1 em 1). Esse tipo de expressão receveo o nome de `Range`."

# ╔═╡ 4dc00908-eded-11ea-25c5-0f7b2b7e18f9
typeof(1:10)

# ╔═╡ 6c44abb4-edec-11ea-16bd-557800b5f9d2
md"Acima usamos um bloco `let` para criar uma nova variável local `s`. Essa variável existe apenas dentro do bloco. Mas o uso de variáveis locais é bem mais comum dentro de fuções, e de fato funções são preferíveis por serem reutilizáveis. Por exemplo, podemos reescrever o código acima para usar quantas vezes quisermos:"

# ╔═╡ 683af3e2-eded-11ea-25a5-0d90bf099d98
function mysum(n)
	s = 0
	
	for i in 1:n
		s += i    
	end
	
	return s
end

# ╔═╡ 76764ea2-eded-11ea-1aa6-296f3421de1c
mysum(100)

# ╔═╡ 93a231f4-edec-11ea-3b39-299b3be2da78
md"## Condicionais `if`"

# ╔═╡ 82e63a24-eded-11ea-3887-15d6bfabea4b
md"Como outras linguagens Julia possui expressões lógicas que retornam verdadeiro ou falso:"

# ╔═╡ 9b339b2a-eded-11ea-10d7-8fc9a907c892
a = 3

# ╔═╡ 9535eb40-eded-11ea-1651-e33c9c23dbfb
a < 5

# ╔═╡ a16299a2-eded-11ea-2b56-93eb7a1010a7
md"Condições lógicas podem então ser usadas em expressões condicionais que escolhem uma linha de execução."

# ╔═╡ bc6b124e-eded-11ea-0290-b3760cb81024
if a < 5
	"small"
	
else
	"big"
	
end

# ╔═╡ cfb21014-eded-11ea-1261-3bc30952a88e
md"""Note que o `if` também funciona como uma expressão, restornando o último valor que foi avaliado. No exemplo isso o resultado foi a string `"small"`. Se a condição fosse falsa seria `"big"`. Como Pluto é um caderno *reativo* se você mudar o valor de `a` na célula que o define, o valor restulstando do `if` é atualizado!"""

# ╔═╡ ffee7d80-eded-11ea-26b1-1331df204c67
md"## Arrays"

# ╔═╡ cae4137e-edee-11ea-14af-59a32227de1b
md"### Arrays unidimensionais ou vetores (`Vector`)"

# ╔═╡ 714f4fca-edee-11ea-3410-c9ab8825d836
md"A notação para arrays unidimensionais, ou vetores, é baseada em colchetes, com itens separados por vírgulas:"

# ╔═╡ 82cc2a0e-edee-11ea-11b7-fbaa5ad7b556
v = [1, 2, 3]

# ╔═╡ 85916c18-edee-11ea-0738-5f5d78875b86
typeof(v)

# ╔═╡ 881b7d0c-edee-11ea-0b4a-4bd7d5be2c77
md"O `1` na descrição do tipo mostra que esse é um vetor unidimensional (1D).

Os elementos de um vetor são acessados também usando colchetes com o índice (iniciando de 1):"

# ╔═╡ a298e8ae-edee-11ea-3613-0dd4bae70c26
v[2]

# ╔═╡ a5ebddd6-edee-11ea-2234-55453ea59c5a
v[2] = 10

# ╔═╡ a9b48e54-edee-11ea-1333-a96181de0185
md"Observe que o Pluto não atualiza células automaticamente quando o dos elementos do vetor é modificado, mas o valor é de fato modificado."

# ╔═╡ 68c4ead2-edef-11ea-124a-03c2d7dd6a1b
md"Uma forma bastante versátil para a criação de vetores é a **compreenção de arrays** que também existe em Python:"

# ╔═╡ 84129294-edef-11ea-0c77-ffa2b9592a26
v2 = [i^2 for i in 1:10]

# ╔═╡ d364fa16-edee-11ea-2050-0f6cb70e1bcf
md"## Arrays 2D (matrizes)"

# ╔═╡ db99ae9a-edee-11ea-393e-9de420a545a1
md"Podemos também usar colchetes para definir matrizes. Nesse caso os elementos de uma mesma linha são separados por espaços e as linhas em si por ponto-e-vírgula ou quebra de linha"

# ╔═╡ 04f175f2-edef-11ea-0882-712548ebb7a3
M = [1 2
	 3 4]

# ╔═╡ 0a8ac112-edef-11ea-1e99-cf7c7808c4f5
typeof(M)

# ╔═╡ 1295f48a-edef-11ea-22a5-61e8a2e1d005
md"Observe, mais uma vez, que o `2` na descrição do tipo confirma que esse é um array  2D."

# ╔═╡ 3e1fdaa8-edef-11ea-2f03-eb41b2b9ea0f
md"Há ainda funções específicas para criar matrizes maiores. Por exemplo, é fácil criar uma matriz toda com zeros."

# ╔═╡ 48f3deca-edef-11ea-2c18-e7419c9030a0
zeros(5, 5)

# ╔═╡ a8f26af8-edef-11ea-2fc7-2b776f515aea
md"A função `zeros` devolve uma matriz com elementos do tipo `Float64`s como padrão. Para alterar esse comportamento é possível definir o tipo além do número de elementos."

# ╔═╡ b595373e-edef-11ea-03e2-6599ef14af20
zeros(Int, 4, 5)

# ╔═╡ 4cb33c04-edef-11ea-2b35-1139c246c331
md"Depois disso podemos preencher a matriz com quaisquer valores elemento por elemento, por exemplo usando laços `for` encaixados."

# ╔═╡ 54e47e9e-edef-11ea-2d75-b5f550902528
md"Ou ainda usar a sintaxe alternatica de compreensão de arrays mas agora com dois laços `for` (encaixados). Note que nesse caso o primeiro laço percorre as linhas e o segundo laço percorre as colunas. As matrizes em Julia são guardas por colunas, uma após a outra."

# ╔═╡ 6348edce-edef-11ea-1ab4-019514eb414f
[i + j for i in 1:5, j in 1:6]

# ╔═╡ Cell order:
# ╠═0d3aec92-edeb-11ea-3adb-cd0dc17cbdab
# ╟─3b038ee0-edeb-11ea-0977-97cc30d1c6ff
# ╠═3e8e0ea0-edeb-11ea-22e0-c58f7c2168ce
# ╠═59b66862-edeb-11ea-2d62-71dcc79dbfab
# ╟─5e062a24-edeb-11ea-256a-d938f77d7815
# ╟─7e46f0e8-edeb-11ea-1092-4b5e8acd9ee0
# ╠═8a695b86-edeb-11ea-08cc-17263bec09df
# ╟─8e2dd3be-edeb-11ea-0703-354fb31c12f5
# ╟─96b5a28c-edeb-11ea-11c0-597615962f54
# ╠═a7453572-edeb-11ea-1e27-9f710fd856a6
# ╟─b341db4e-edeb-11ea-078b-b71ac00089d7
# ╠═23f9afd4-eded-11ea-202a-9f0f1f91e5ad
# ╠═cc1f6872-edeb-11ea-33e9-6976fd9b107a
# ╟─a92ff397-cd8d-4cd6-8b1a-d1b8703ea11f
# ╠═2f0acda8-b30c-4fa1-bd69-3d97ffcf84f0
# ╠═e7583d52-4887-4619-aee5-3425a188a94c
# ╠═4151cf81-5b76-4049-bb43-c1eeb6b7096e
# ╟─b5e2339d-ffc5-4083-b917-b7e4425f2419
# ╟─ce9667c2-edeb-11ea-2665-d789032abd11
# ╠═d73d3400-edeb-11ea-2dea-95e8c4a6563b
# ╠═e04ccf10-edeb-11ea-36d1-d11969e4b2f2
# ╟─e297c5cc-edeb-11ea-3bdd-090f415685ab
# ╟─ec751446-edeb-11ea-31ba-2372e7c71b42
# ╠═fe3fa290-edeb-11ea-121e-7114e5c573c1
# ╟─394b0ec8-eded-11ea-31fb-27392068ef8f
# ╠═4dc00908-eded-11ea-25c5-0f7b2b7e18f9
# ╟─6c44abb4-edec-11ea-16bd-557800b5f9d2
# ╠═683af3e2-eded-11ea-25a5-0d90bf099d98
# ╠═76764ea2-eded-11ea-1aa6-296f3421de1c
# ╟─93a231f4-edec-11ea-3b39-299b3be2da78
# ╟─82e63a24-eded-11ea-3887-15d6bfabea4b
# ╠═9b339b2a-eded-11ea-10d7-8fc9a907c892
# ╠═9535eb40-eded-11ea-1651-e33c9c23dbfb
# ╟─a16299a2-eded-11ea-2b56-93eb7a1010a7
# ╠═bc6b124e-eded-11ea-0290-b3760cb81024
# ╟─cfb21014-eded-11ea-1261-3bc30952a88e
# ╟─ffee7d80-eded-11ea-26b1-1331df204c67
# ╟─cae4137e-edee-11ea-14af-59a32227de1b
# ╟─714f4fca-edee-11ea-3410-c9ab8825d836
# ╠═82cc2a0e-edee-11ea-11b7-fbaa5ad7b556
# ╠═85916c18-edee-11ea-0738-5f5d78875b86
# ╟─881b7d0c-edee-11ea-0b4a-4bd7d5be2c77
# ╠═a298e8ae-edee-11ea-3613-0dd4bae70c26
# ╠═a5ebddd6-edee-11ea-2234-55453ea59c5a
# ╟─a9b48e54-edee-11ea-1333-a96181de0185
# ╟─68c4ead2-edef-11ea-124a-03c2d7dd6a1b
# ╠═84129294-edef-11ea-0c77-ffa2b9592a26
# ╟─d364fa16-edee-11ea-2050-0f6cb70e1bcf
# ╟─db99ae9a-edee-11ea-393e-9de420a545a1
# ╠═04f175f2-edef-11ea-0882-712548ebb7a3
# ╠═0a8ac112-edef-11ea-1e99-cf7c7808c4f5
# ╟─1295f48a-edef-11ea-22a5-61e8a2e1d005
# ╟─3e1fdaa8-edef-11ea-2f03-eb41b2b9ea0f
# ╠═48f3deca-edef-11ea-2c18-e7419c9030a0
# ╟─a8f26af8-edef-11ea-2fc7-2b776f515aea
# ╠═b595373e-edef-11ea-03e2-6599ef14af20
# ╟─4cb33c04-edef-11ea-2b35-1139c246c331
# ╟─54e47e9e-edef-11ea-2d75-b5f550902528
# ╠═6348edce-edef-11ea-1ab4-019514eb414f
