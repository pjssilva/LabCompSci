### A Pluto.jl notebook ###
# v0.19.13

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

# ╔═╡ 8c8388cf-9891-423c-8db2-d40d870bb38e
begin
	using PlutoUI
	using Plots
end

# ╔═╡ 9b6ce746-087c-4416-95ca-46b1e11ba049
md"Tradução livre de [hw6.jl](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week6/hw6.jl)"

# ╔═╡ 082542fe-f89d-4774-be20-1e1a78f21291
md"""

# **Lista 6**: _Distribuições de probabilidade_

`Data de entrega`: 25/10/2022.

Este caderno contém verificações _simples_ para ajudar você a saber se o que fez faz sentido. Essas verificações são incompletas e não corrigem completamente os exercícios. Mas, se elas disserem que algo não está bom, você sabe que tem que tentar de novo.

_As listas serão corrigidas com exemplos mais sofisticados e gerais do que aqueles das verificações incluídas.

Sintam-se livres de fazer perguntas no Discord.
"""

# ╔═╡ 6f4274b5-87e2-420d-83d2-83a8408650cd
# edite o código abaixo com seu nome e email da dac (sem o @dac.unicamp.br)

student = (name = "João Ninguém", email_dac = "j000000")

# aperte o botão ▶ no canto inferior direito da célula para executar o que você
# editou, ou use Shift+Enter

# Agora siga na página para ver o que deve fazer.

# ╔═╡ 0560cf7b-9986-402a-9c40-779ea7a7292d
md"""

Submetido por: **_$(student.name)_** ($(student.email_dac)@unicamp.br)
"""

# ╔═╡ aaa41509-a62d-417b-bca7-a120e3a5e5b2
md"""
#### Iniciando pacotes
Quando executado a primeira vez pode demorar por instalar pacotes.
"""

# ╔═╡ 6c6e055a-8c4c-11eb-14a7-6d3036e248b9
md"""

## **Exercício 1:** _Calculando frequências_

Neste exercício vamos praticar o uso de dicionários em Julia. Para isso você irá escrever a sua própria versão da função `countmap`. Lembre que essa função conta o número de vezes que um dado valor (discreto) ocorre num conjunto de dados de entrada.

Uma estrutura de dados adequada para essa tarefa é o **dicionário**. Ela permite armazenar dados que são esparsos, ou seja, nos quais vários dos possíveis valores não ocorrem, guardando informação apenas dos valores presentes.
"""

# ╔═╡ 2bebafd4-8c4d-11eb-14ba-27ab7eb763c1
function counts(data::Vector)
	counts = Dict{eltype(data), Int}()
	
	# your code here
	
	return counts
end

# ╔═╡ d025d432-23d0-4a6b-8b09-cc1114367b8f
counts([7, 8, 9, 7])

# ╔═╡ 17faeb5e-8c4d-11eb-3589-c96e799b8a52
md"""
Teste o seu código chamando-o na com o vetor `test_data` definido abaixo. Qual deveria ser a resposta? Verifique que você obteve a resposta correta no vetor `test_counts` definido abaixo.
"""

# ╔═╡ 5e6f16fc-04a0-4774-8ce0-78953e047269
test_data = [1, 0, 1, 0, 1000, 1, 1, 1000]

# ╔═╡ 49b9e55c-1179-4bee-844e-62ae36d20a5d
test_counts = counts(test_data)

# ╔═╡ 18031e1e-8c4d-11eb-006b-adaf55d54282
md"""
#### Exercício 1.2

O dicionário contem informação como uma sequencia de **pares** (ordenados) que mapeiam chaves a valores. Esse não é um formato que será útil para nós. Queremos obter dois vetores, um com as chaves ordenadas e outro com os _respectivos_ valores.

Vamos fazer uma nova versão chamada `counts2` que atinge esse objetivo abaixo. Comece por executar as três tarefas abaixo, rodando comandos diretamente sobre o dicionário `test_counts` que você obteve acima chamando a função `counts` original. Isso vai lhe ajudar a entender o que deve fazer. Depois de entender o processo, implemente finalmente a função `counts2`.  

👉 Obtenha os vetores de chaves `ks` e de valores `vs` usando as rotinas `keys()` e `values()` e em imediatamente em seguida converta os iteradores obtidos em vetores usando a função `collect`.
"""

# ╔═╡ 4bbbbd24-d592-4ce3-a619-b7f760672b99


# ╔═╡ 44d0f365-b2a8-41a2-98d3-0aa34e8c80c0


# ╔═╡ 18094d52-8c4d-11eb-0620-d30c24a8c75e
md"""
👉 Defina uma variável chamada `perm` obtida ao rodar a função `sortperm` no vetor de chaves. Ela devolve uma **permutação** que diz em qual ordem você deve pegar as chaves para obter a sua versão ordenada.
"""

# ╔═╡ c825f913-9545-4dbd-96f9-5f7621fc242d


# ╔═╡ 180fc1d2-8c4d-11eb-0362-230d84d47c7f
md"""

👉 Use indexação (por exemplo,  `ks[perm]`) para obter as chaves ordenadas e os respectivos valores nessa mesma ordem.  

[Aqui estamos passando um *vetor* como índice. Julia cria então uma _cópia_ do vetor original extraindo os valores seguindo a ordem dada no vetor de índices.]
"""

# ╔═╡ fde456e5-9985-4939-af59-9b9a92313b61


# ╔═╡ cc6923ff-09e0-44cc-9385-533182c4382d


# ╔═╡ 18103c98-8c4d-11eb-2bed-ed20aba64ae6
md"""
Agora que você entendeu o que deve ser feito, defina a rotina `counts2` abaixo que conta as aparições no vetor de inteiros `data` e devolve a reposta com dois vetores. O primeiro deve ter os valores presentes em data ordenados. O segundo é um vetor que conta quantas vezes cada entrada apareceu. verifique que ela está funcionando comparando o seu resultado com o que você obteve acima fazendo o processo manualmente.
"""

# ╔═╡ bfa216a2-ffa6-4716-a057-62a58fd9f04a
md"""
👉 Crie uma função `counts2` que executa todos esses passos.
"""

# ╔═╡ 156c1bea-8c4f-11eb-3a7a-793d0a056f80
function counts2(data::Vector)
	
	return missing
end

# ╔═╡ 37294d02-8c4f-11eb-141e-0be49ea07611
counts2(test_data)

# ╔═╡ 18139dc0-8c4d-11eb-0c31-a75361ed7321
md"""
#### Exercício 1.3

👉 Crie uma função `probability_distribution` que normaliza o resultado de `counts2` para calcular as frequências relativas de cada valor. Ou seja, para dar a distribuição de probabilidade empírica dos dados (e assim o vetor de valores obtidos deve somar 1).

A função deve retornar as chaves (os valores únicos que apareciam nos dados originais e que são calculados por `counts2`) e as probabilidades (frequências relativas).

Verifique que sua função dá o valor correto para o vetor `vv`.

Nós vamos usar essa função no restante da lista.
"""

# ╔═╡ 447bc642-8c4f-11eb-1d4f-750e883b81fb
function probability_distribution(data::Vector)
	
	return [0], [1] # Substitute the fixed values by your code
end

# ╔═╡ 6b1dc96a-8c4f-11eb-27ca-ffba02520fec
bb = probability_distribution(test_data)

# ╔═╡ 95145ee9-c826-45e3-ab51-442c8ca70fa3
md"""
## Intermezzo: _**funções**_ vs _**begin**_ vs _**let**_
$(html"<span id=function_begin_let></span>")

Nos cadernos dessas notas, por vezes usamos um código `let` para agrupar múltiplos comandos e expressões. Mas qual é diferença disso para `begin` e `function`?

> ##### function
> Escrever funções é uma forma de agrupar expressões (ou seja, linhas de código) em um mini-programa. Observe os seguintes detalhes sobre funções:
> - Uma função sempre retorna um **único objeto**[^1] (mas esse objetivo pode ser uma tupla, então dá para devolver vários objetos na prática e usamos isso o tempo todo). Esse objeto pode ser devolvido explicitamente como em  `return x`, ou implicitamente. Na ausência de return, Julia sempre retorna o valor calculado pela última expressão. Assim, `f(x) = x + 2` é o mesmo que `f(x) = return x + 2`.
> - Variáveis definidas dentro de uma função não são acessíveis fora delas. Em computação dizemos que os corpos de função tem **escopo local**. Isso permite que você trabalhe com mais liberdade, sabendo que o que ocorre dentro da função apenas afeta a função. A única forma de dar acesso a valores externamente é retorná-lo. (Há ainda a possibilidade de dar acesso indireto a valores usando fechamentos, mas esse é conceito mais avançado do que queremos discutir aqui).
 
> Mas há ainda duas formas de agrupar expressões que já vimos antes: `begin` e `let`.

> ##### begin
> **`begin`** agrupa expressões e devolve o valor da última sub-expressão
>
> Usamos isso nesse caderno quando queremos que várias expressões sempre executem juntas. O `begin` não inicia um novo escopo. Ele acessa, cria e modifica valores no escopo original.

> ##### let
> **`let`** também agrupa múltiplas expressões, mas variáveis criadas dentro de um `let` são **locais**: elas não afetam o código fora do bloco. Então, assim como `begin`, ele é apenas um bloco de código. Já como uma função, suas novas variáveis são criadas em um novo escopo local.
>
> Nós usamos isso quando queremos criar algumas variáveis locais (temporárias) para ajudar na realização de operações complicadas sem interferir com as outras células. Lembre-se que Pluto permite apenas uma única definição de um valor _global_ que é usado para coordenar a reatividade. Já valores locais não influenciam o que está fora do escopo e portanto o mesmo nome pode aparecer múltiplas vezes.

[^1]: Até uma função como
    
    `f(x) = return`
    
    retorna **um objetivo**: o objeto `nothing` — pode testar!
"""

# ╔═╡ c5464196-8ef7-418d-b1aa-fafc3a03c68c
md"""
### Exemplo de um problema de escopo com `begin`

O código abaixo não vai funcionar porque `fruits` é definido múltiplas vezes.
"""

# ╔═╡ 409ed7e5-a3b8-4d37-b85d-e5cb4c1e1708
md"""
### Resolvendo com `let`
"""

# ╔═╡ 36de9792-1870-4c78-8330-83f273ee1b46
let
	vegetables = ["🥦", "🥔", "🥬"]
	length(vegetables)
end

# ╔═╡ 8041603b-ae47-4569-af1d-cebb00edb32a
let
	vegetables = ["🌽"]
	length(vegetables)
end

# ╔═╡ 2d56bf20-8866-4ec1-9ceb-41004aa185d0


# ╔═╡ 2577c5a7-338f-4aef-b34b-456949cfc17b
md"""
O código acima funciona porque `vegetables` está definida apenas como uma _variável local dentro de uma célula_. Ela não é global.
"""

# ╔═╡ d12229f4-d950-4983-84a4-304a7637ac7b
@isdefined vegetables

# ╔═╡ a8241562-8c4c-11eb-2a85-d7502e7fb2cf
md"""
## **Exercise 2:** _Modelando a falha de componentes com uma distribuição geométrica_

Neste exercício, vamos revisitar o modelo simples de falha de componentes mecânicos (ou lâmpadas, ou decaimento radioativo, ou recuperação de uma infecção, ou ...) que vimos em aula. Vamos chamar de $\tau$ o tempo de falha.

Vamos usar um modelo simples em que cada componente tem uma probabilidade $p$ de falhar por dia. Se ele falhar no dia $n$, então $\tau = n$. Vemos então que $\tau$ é uma variável aleatória e o que vamos fazer agora é estudar a sua **distribuição de probabilidades**.
"""

# ╔═╡ fdb394a0-8c4f-11eb-0585-bb8c28f952cb
md"""
#### Exercício 2.1

👉 (Re)Defina a função `bernoulli(p)` da aula. Lembra que ela gera  `true` com probabilidade $p$ e `false` com probabilidade $(1 - p)$.
"""

# ╔═╡ 0233835a-8c50-11eb-01e7-7f80bd27683e
function bernoulli(p::Real)
	
	return missing
end

# ╔═╡ fdb3f1c8-8c4f-11eb-2281-bf01205bb804
md"""
#### Exercício 2.2

👉 Escreva uma função `geometric(p)`. Ela deve executar uma simulação com probabilidade $p$ de falha diária múltiplas vezes e esperar *até* que a falha ocorra. O seu retorno é o número de dias até a falha. Esse tempo resultante é uma **variável aleatória geométrica**, ou uma variável aleatória que obedece a uma **distribuição (de probabilidades) geométrica**
"""

# ╔═╡ 08028df8-8c50-11eb-3b22-fdf5104a4d52
function geometric(p::Real)
	
	
	return missing
end

# ╔═╡ 2b35dc1c-8c50-11eb-3517-83589f2aa8cc
geometric(0.25)

# ╔═╡ e125bd7f-1881-4cff-810f-8af86850249d
md"""
Ao fazer nossas implementações devemos ter sempre cuidado com casos especiais (em algumas situações esses casos são chamados de "condições de contorno"). Por exemplo, não permita que o seu código rode para $p = 0$! O que ocorreria nesse caso? Qual outra condição sobre $p$ deve ser obedecida? Faça suas verificações e se $p$ não for aceitável recuse a execução da função jogando uma exceção `ArgumentError` usando o modelo abaixo.

```julia
throw(ArgumentError("..."))
```

entre as aspas adicione uma mensagem de erro explicativa.
"""

# ╔═╡ 6cb36508-836a-4191-b615-45681a1f7443
md"""
👉 O que ocorre se $p=1$?
"""

# ╔═╡ 370ec1dc-8688-443c-bf57-dd1b2a42a5fa
interpretation_of_p_equals_one = md"""
blablabla
"""

# ╔═╡ fdb46c72-8c4f-11eb-17a2-8b7628b5d3b3
md"""
#### Exercício 2.3
👉 Escreva a função `experiment(p, N)` que roda a função `geometric` `N` vezes e guarda os resultados em um vetor.
"""

# ╔═╡ 32700660-8c50-11eb-2fdf-5d9401c07de3
function experiment(p::Real, N::Integer)
	
	return [0]
end

# ╔═╡ 192caf02-5234-4379-ad74-a95f3f249a72
small_experiment = experiment(0.5, 20)

# ╔═╡ fdc1a9f2-8c4f-11eb-1c1e-5f92987b79c7
md"""
#### Exercício 2.4

Vamos rodar o experimento com $p=0.25$ e $N=10,000$. Vamos graficar a distribuição de probabilidade resultante, ou seja, plotar $P(\tau = n)$ como função de $n$, em que $n$ é o momento de falha.
"""

# ╔═╡ 3cd78d94-8c50-11eb-2dcc-4d0478096274
large_experiment = experiment(0.25, 10000)

# ╔═╡ 4118ef38-8c50-11eb-3433-bf3df54671f0
let
	xs, ps = probability_distribution(large_experiment)
		
	bar(xs, ps, alpha=0.5, leg=false)	
end

# ╔═╡ c4ca3940-9bd5-4fa6-8c73-8675ef7d5f41
md"""
👉 Calcule o tempo médio de falha e defina a variável `mean_fail_time` abaixo.

"""

# ╔═╡ 25ae71d0-e6e2-45ff-8900-3caf6fcea937
mean_fail_time = 0

# ╔═╡ 3a7c7ca2-e879-422e-a681-d7edd271c018
md"""
👉 Crie o mesmo gráfico acima adicionando o tempo médio de falha ao gráfico usando a função `vline!()` com o estilo de linha `ls=:dash` que cria uma linha tracejada.

Observe que `vline!` usa um *vector* de valores onde você quer desenhar a linha vertical.
"""

# ╔═╡ 97d7d154-8c50-11eb-2fdd-fdf0a4e402d3
let
	
	# your code here
end

# ╔═╡ b1287960-8c50-11eb-20c3-b95a2a1b8de5
md"""
$(html"<span id=note_about_plotting></span>")
> ### Observações sobre gráficos
> 
> Plots.jl fez uma escolha interessante: um gráfico é um objeto e não uma ação. Funções como `plot`, `bar`, `histogram` não desenham nada  na tela - elas apenas retornam um `Plots.Plot`. Essa é uma estrutura que contem a _descrição_ da figura (o que deve ser desenhado onde e de qual forma). Ela não é a figura em si.
> Assim Pluto interpreta o resultado de uma célula com uma única linha `plot(1:10)` e mostra o resultado, interpretando essa descrição e apresentando a imagem final.
> ##### Modificando gráficos
> Gráficos interessantes são tipicamente obtidos sobrepondo vários gráficos. Em `Plot.jl` isso é feito usando as funções modificadoras que tem o ponto de exclamação em seu nome: `plot!`, `bar!`, `vline!`, etc. Caso exista mais de um gráfico, é possível passar aquele que deve ser modificado como parâmetro inicial.
> 
> Por exemplo, para desenhar as funções `sin`, `cos` e `tan` numa mesma imagem podemos usar:
> ```julia
> function sin_cos_plot()
>     T = -1.0:0.01:1.0
>     
>     result = plot(T, sin.(T))
>     plot!(result, T, cos.(T))
>     plot!(result, T, tan.(T))
>
>     return result
> end
> ```
> 
> 💡 Esse exemplo demonstra um bom padrão para combinar imagens:
> 1. Crie uma imagem **nova** e armazene-a em uma variável.
> 2. **Modifique** a imagem adicionando mais elementos.
> 3. Retorne o resultado final.
> 
> ##### Agrupando expressões
> É uma boa ideia fazer esses 3 passos **em uma única célula**. Isso evita possíveis problemas que ocorrem quando as células são executadas automaticamente pelo sistema de reação do Pluto. Lembre-se, vimos acima que há três formas de fazer isso: `begin`, `let` e `function`. 
"""

# ╔═╡ fdcab8f6-8c4f-11eb-27c6-3bdaa3fcf505
md"""
#### Exercício 2.5
👉 Qual a forma que a distribuição tem? Será que você consegue verificar isso usando uma ou mais escalas logarítmicas em um novo gráfico?
"""

# ╔═╡ 1b1f870f-ee4d-497f-8d4b-1dba737be075


# ╔═╡ fdcb1c1a-8c4f-11eb-0aeb-3fae27eaacbd
md"""
Use os widgets de PlutoUI para criar uma iteração iterativa que realiza o exercício  2.3 para $p$ variando entre $0$ e $1$ e $N$ entre $0$ e $100,000$.

Ao variar $p$, o que você consegue observar? Isso faz sentido (responda em um comentário abaixo)?
"""

# ╔═╡ 444a0557-d276-49f1-be6d-4784ae3ad8fa


# ╔═╡ d5b29c53-baff-4529-b2c1-776afe000d38
@bind hello Slider( 2 : 0.5 : 10 )

# ╔═╡ 9a92eba4-ad68-4c53-a242-734718aeb3f1
hello

# ╔═╡ 48751015-c374-4a77-8a00-bca81bbc8305


# ╔═╡ 562202be-5eac-46a4-9542-e6593bc39ff9


# ╔═╡ e8d2a4ab-b710-4c16-ab71-b8c1e71fe442


# ╔═╡ a486dc37-609d-4aae-b4ec-71de726191c7


# ╔═╡ 65ea5492-d833-4754-89a3-0aa671c3ec7a


# ╔═╡ 264089bc-aa30-450f-89f7-ffd589eee13c


# ╔═╡ 0be83efa-e94f-4397-829f-24f705b044b1


# ╔═╡ fdd5d98e-8c4f-11eb-32bc-51bc1db98930
md"""
#### Exercício 2.6
👉 Para $N = 10,000$ fixo, escreva uma função que calcula o tempo *médio* de falha, $\langle \tau(p) \rangle$, como uma função de $p$.
"""

# ╔═╡ 406c9bfa-409d-437c-9b86-fd02fdbeb88f


# ╔═╡ f8b982a7-7246-4ede-89c8-b2cf183470e9
md"""
👉 Use gráficos de sua função para encontrar a relação que existe entre $\langle \tau(p) \rangle$ e $p$.
"""

# ╔═╡ caafed37-0b3b-4f6c-919f-f16df7248c23


# ╔═╡ 501bcc30-f96f-42e4-a5aa-09a4138b5b72


# ╔═╡ b763b6e8-8221-4b08-9a8e-8d5e63cbd144


# ╔═╡ d2e4185e-8c51-11eb-3c31-637902456634
md"""
Baseado em minha observações, parece que temos a seguinte relação:

```math
\langle \tau(p) \rangle = minha \cdot resposta \cdot aqui
```
"""

# ╔═╡ a82728c4-8c4c-11eb-31b8-8bc5fcd8afb7
md"""

## **Exercício 3:** _Distribuições geométricas mais eficientes_

Vamos usar a notação $P_n := \mathbb{P}(\tau = n)$ para a probabilidade de falha no $n$-ésimo dia (passo no tempo).

Pensando um pouco podemos concluir que $P_1 = p$,  $P_2 = p (1-p)$ e, em geral, $P_n = p (1 - p)^{n-1}$.
"""

# ╔═╡ 23a1b76b-7393-4a4c-b6a5-40fb15dadd29
md"""
#### Exercise 3.1

👉 Fixe $p = 0.25$. Crie um vetor de valores $P_n$ para $n=1, \dots, 50$. Você deve (é claro), usar um laço ou outra construção semelhante. Não faça isso a mão!
"""

# ╔═╡ 45735d82-8c52-11eb-3735-6ff9782dde1f
Ps = let 
	
	[0] # your code here
end

# ╔═╡ dd80b2eb-e4c3-4b2f-ad5c-526a241ac5e6
md"""
👉 Eles somam 1?

"""

# ╔═╡ 3df70c76-1aa6-4a0c-8edf-a6e3079e406b
sum_Ps = 0.0  # Add your code here

# ╔═╡ b1ef5e8e-8c52-11eb-0d95-f7fa123ee3c9
md"""
#### Exercise 3.2
👉 Mostre analiticamente que de fato a soma dos infinitos valores é 1.
"""

# ╔═╡ a3f08480-4b2b-46f2-af4a-14270869e766
md"""

```math
\sum_{k=1}^{\infty} P_k = \dots your \cdot answer \cdot here \dots = 1

```
"""

# ╔═╡ 1b6035fb-d8fc-437f-b75e-f1a6b3b4cae7
md"""
#### Exercício 3.3: Soma de uma série geométrica.
"""

# ╔═╡ c3cb9ea0-5e0e-4d5a-ab23-80ed8d91209c
md"""
👉 Faça o gráfico de $P_n$ em função de $n$ e compare com o resultado do exercício anterior (ou seja, apresente os dois gráficos na mesma figura).
"""

# ╔═╡ dd59f48c-bb22-47b2-8acf-9c4ee4457cb9


# ╔═╡ 5907dc0a-de60-4b58-ac4b-1e415f0051d2
md"""
👉 Como poderíamos medir o *erro* entre os dois gráficos, como medir a distância entre eles. O que você acha que isso representa?
	"""

# ╔═╡ c7093f08-52d2-4f22-9391-23bd196c6fb9


# ╔═╡ 316f369a-c051-4a35-9c64-449b12599295
md"""
#### Exercício 3.4

Se $p$ for *pequeno*, digamos $p = 0.001$, então o algoritmo que usamos no exercício 2 será muito lento. Ele fica lá "parado" calculando um monte de `false` até que o improvável `true` apareça.
"""

# ╔═╡ 9240f9dc-aa34-4e7b-8b82-86ea1376f527
md"""
Vamos desenvolver um algoritmo melhor. Imagine cada $P_n$ como intervalos (com o seu  valor como largura). Se colocarmos esses intervalos um ao lado do outro, compeçando do $P_1$ mais à esquerda a partir do 0, depois o $P_2$, etc. vamos cobrir o intervalo $[0, 1]$ com uma infinidade de subintervalos (mesmo que os subintervalos tenham comprimentos muito pequenos, eles sempre serão estritamente positivos). 
"""

# ╔═╡ d24ddb61-3d65-4bea-ad8f-d5a3ac44a563
md"""
Agora considere que escolhemos um ponto $r$ uniformemente entre $0$ e $1$. Ele vai cair em um desses subintervalos, correspondendo ao $P_n$, retornamos então $n$ como o tempo de falha. A chance de escolher um valor é a mesma que o processo que fica lá esperando aparecer o `true` mas não precisa um laço de `false` até atingir um `true`! Ele é muito mais rápido. Vamos nos mover na direção dessa implementação. 
"""

# ╔═╡ 430e0975-8eb6-420c-a18e-f3493182c5c7
md"""
👉 Para desenhar essa figura, precisamos somar os comprimentos dos intervalos de $1$ a $n$ para cada $n$, isto é, queremos calcular uma soma acumulada de elementos. Escreva uma rotina `cumulative_sum` que recebe um vetor e devolve a soma acumulada de seus elementos.
"""

# ╔═╡ 5185c938-8c53-11eb-132d-83342e0c775f
function cumulative_sum(xs::Vector)
	
	return missing
end

# ╔═╡ e4095d34-552e-495d-b318-9afe6839d577
cumulative_sum([1, 3, 5, 7, 9])

# ╔═╡ fa5843e8-8c52-11eb-2138-dd57b8bf25f7
md"""
👉 Desenha o gráfico dos valores em uma linha horizontal. Gere alguns pontos aleatórios entre [0, 1] e se convença que a probabilidade de um ponto cair em um dos subintervalos é exatamente igual ao comprimento desse subintervalo."
"""

# ╔═╡ 7aa0ec08-8c53-11eb-1935-23237a448399
cumulative = cumulative_sum(Ps)

# ╔═╡ e649c914-dd28-4194-9393-4dc8836f3743


# ╔═╡ fa59099a-8c52-11eb-37a7-291f80ea0406
md"""
#### Exercício 3.5
👉 Apresente soma de $P_1$ a $P_n$ analiticamente (pode copiar a fórmula que aprendeu na escola).
"""

# ╔═╡ 1ae91530-c77e-4d92-9ad3-c969bc7e1fa8
md"""
```math
C_n := \sum_{k=1}^n P_k = my \cdot answer \cdot here
```
"""

# ╔═╡ fa599248-8c52-11eb-147a-99b5fb75d131
md"""
👉 Use a fórmula anterior para encontrar (analiticamente) em qual o subintervalo $n$ um valor dado $r \in [0, 1]$ cai, usando a desigualdade $C_{n} \le r \le C_{n + 1}$.
"""

# ╔═╡ 16b4e98c-4ae7-4145-addf-f43a0a96ec82
md"""
```math
n(r,p) = my \cdot answer \cdot here
```
"""

# ╔═╡ fa671c06-8c52-11eb-20e0-85e2abb4ecc7
md"""
#### Exercício 3.6

👉 Implemente essa fórmula como a função `geometric_bin(r, p)`, use a função `floor`.
"""

# ╔═╡ 47d56992-8c54-11eb-302a-eb3153978d26
function geometric_bin(u::Real, p::Real)
	
	return missing
end

# ╔═╡ adfb343d-beb8-4576-9f2a-d53404cee42b
md"""
Você pode usar isso para definir uma versão rápida da função `geometric`:
"""

# ╔═╡ 5b7f2a91-a4f0-49f7-b8cf-6f677104d3e1
geometric_fast(p) = geometric_bin(rand(), p)

# ╔═╡ b3b11113-2f0c-45d2-a14e-011a61ae8e9b
geometric_fast(0.25)

# ╔═╡ fc681dde-8c52-11eb-07fa-7d0ef9f22e93
md"""
#### Exercício 3.7
👉 Gere `10_000` amostras usando `geometric_fast` com $p=10^{-10}$ e desenhe o histograma da resposta. Isso iria demorar muito se você usasse a versão original de `geometric`.

Obs: a sua amostra deve ser guardada em um vetor chamado `fast_geometric_sample`!
"""

# ╔═╡ 1d007d99-2526-4c19-9c96-3fad1750670e
fast_geometric_sample = [0] # Substitua com o seu código

# ╔═╡ c37bbb1f-8f5e-4097-9104-43ef65aa1cbd


# ╔═╡ 79eb5e14-8c54-11eb-3c8c-dfeba16305b2
md"""
## **Exercício 4:** _Distribuição da "atmosfera"_

Nessa questão vamos implementar um modelo (bem) simples da densidade da atmosfera usando um **passeio aleatório**, ou simulando partículas que seguem um movimento *aleatório*. (Vamos ver mais sobre isso nas aulas de passeios aleatórios).

Podemos pensar em uma partícula muito leve de poeira sendo levada pelo vento. Estamos interessados apenas em sua posição vertical, $y$, e vamos considerar, por simplicidade, que $y$ é um inteiro. A partícula pode subir e descer aleatoriamente ao ser levada pelo vento. Porém a probabilidade de descer, devido à gravidade, de $y$ para $y - 1$, é maior do que a possibilidade de subir para $y + 1$.  Chamemos a possibilidade de descer de $p$ e a de subir $1 - p$.

No $y = 1$ aparece uma **condição de contorno**. A partícula atinge uma fronteira refletiva (que é a superfície de Terra). Podemos modelar essa barreira considerando que se uma partícula tem $y = 1$ e tenta se mover para baixo ela se mantém em $y = 1$.
Ou seja, ela fica parada.
"""

# ╔═╡ 8c9c217e-8c54-11eb-07f1-c5fde6aa2946
md"""
#### Exercício 4.1
👉 Escreva uma simulação desse modelo em uma função `atmosfera` que aceita `p`, a altura inicial `y0`, e um número de passos $N$ como variáveis.

"""

# ╔═╡ 2270e6ba-8c5e-11eb-3600-615519daa5e0
function atmosphere(p::Real, y0::Real, N::Integer)
	
	return missing
end

# ╔═╡ 225bbcbd-0628-4151-954e-9a85d1020fd9
atmosphere(0.8, 10, 50)

# ╔═╡ 1dc5daa6-8c5e-11eb-1355-b1f627d04a18
md"""
Vamos simular a atmosfera por $10^7$ passos no tempo com $x_0 = 10$ e $p=0.55$.

#### Exercício 4.2

👉 Calcule e desenhe a distribuição de probabilidade da altura da partícula de poeira.
"""

# ╔═╡ deb5fbfb-1e03-42ce-a6d6-c8d3edd89a9a


# ╔═╡ 8517f92b-d4d3-46b5-9b9a-e609175b6481


# ╔═╡ c1e3f066-5e12-4018-9fb2-4e7fc13172ba


# ╔═╡ 1dc68e2e-8c5e-11eb-3486-454d58ac9c87
md"""
👉 Como a figura se parece? Qual a forma que você crê que a distribuição possui? Verifique sua hipótese apresentando o gráfico da distribuição com diferentes escalas. Você pode aumentar o número de passos no tempo para que o seus resultados fiquem mais claros.
"""

# ╔═╡ bb8f69fd-c704-41ca-9328-6622d390f71f


# ╔═╡ 1dc7389c-8c5e-11eb-123a-7f59dc6504cf
md"""
#### Exercício 4.3

👉 Faça uma visualização iterativa de como a distribuição evolui com o tempo. O que ocorre quando deixamos o tempo final crescer cada vez mais?

"""

# ╔═╡ d3bec73d-0106-496d-93ae-e1e26534b8c7


# ╔═╡ d972be1f-a8ad-43ed-a90d-bca358d812c2


# ╔═╡ de83ffd6-cd0c-4b78-afe4-c0bcc54471d7
md"""
👉 Use a Wikipedia para encontrar a fórmula da pressão barométrica em função da altura. O resultado bate com suas expectativas?
"""

# ╔═╡ fe45b8de-eb3f-43ca-9d63-5c01d0d27671


# ╔═╡ 5aabbec1-a079-4936-9cd1-9c25fe5700e6
md"## Function library

Just some helper functions used in the notebook."

# ╔═╡ 42d6b87d-b4c3-4ccb-aceb-d1b020135f47
hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))

# ╔═╡ 17fa9e2e-8c4d-11eb-334c-ad3704b43e95
md"""

#### Exercício 1.1
👉 Escreva uma função `counts` que recebe um vetor `data` e calcula o número de vezes cada valor que aparece em `data` ocorre.

A entrada será um array de inteiros, **com possíveis valores duplicados**, e o resultado deve ser um dicionário que mapeia cada valor presente ao seu número de aparições.

Por exemplo,
```julia
counts([7, 8, 9, 7])
```
deve resultar em
```julia
Dict(
	7 => 2,
	8 => 1,
	9 => 1,
)
```

Para isso, use um **dicionário** chamado `counts`. [Lembre-se que as variáveis criadas dentro de funções são locais e não conflitam com variáveis globais definidas no caderno, no caso com o próprio nome da função. Notem também que se você fizer isso não será possível chamar a função recursivamente.]

$(hint(md"Você se lembra dos dicionários usados na lista 3? Você pode criar um dicionário vazio com `Dict()`. Você pode usar a funções`haskey` ou `get` no seu dicionário -- veja na documentação como usar essas funções.
"))

Sua função deve retornar um dicionário.
"""

# ╔═╡ 7077a0b6-4539-4246-af2d-ab990c34e810
hint(md"Lembre-se de sempre aproveitar o trabalho que já foi feito. Nesse caso você deve reaproveitar a função `bernoulli`.")

# ╔═╡ 8fd9e34c-8f20-4979-8f8a-e3e2ae7d6c65
almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))

# ╔═╡ d375c52d-2126-4594-b819-aba9d34fe77f
still_missing(text=md"Replace `default code` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))

# ╔═╡ 2d7565d4-88da-4e41-aad6-958ed6b3b2e0
keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))

# ╔═╡ d7f45d51-f426-4353-af58-858395295ce0
yays = [md"Fantastic!", md"Splendid!", md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next question."]

# ╔═╡ 9b2aa95d-4583-40ec-893c-9fc751ea22a1
correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))

# ╔═╡ 5dca2bb3-24e6-49ae-a6fc-d3912da4f82a
not_defined(variable_name) = Markdown.MD(Markdown.Admonition("danger", "Oopsie!", [md"Make sure that you define a variable called **$(Markdown.Code(string(variable_name)))**"]))

# ╔═╡ 645ace88-b8e6-4957-ad6e-49fd82b08fe5
if !@isdefined(counts)
	not_defined(:counts)
else
	let
		result = counts([51,-52,-52,53,51])

		if ismissing(result)
			still_missing()
		elseif !(result isa Dict)
			keep_working(md"Verifique que `counts` retorna um dicionário.")
		elseif result == Dict(
				51 => 2,
				-52 => 2,
				53 => 1,
			)
			correct()
		else
			keep_working()
		end
	end
end

# ╔═╡ 6a302ce6-a327-449e-b41a-859d502f4df7
if !@isdefined(test_counts)
	not_defined(:test_counts)
else
	if test_counts != Dict(
			0 => 2,
			1000 => 2,
			1 => 4
			)
		
		keep_working()
	else
		correct()
	end
end

# ╔═╡ 2b6a64b9-779b-47d1-9724-ad066f14fbff
if !@isdefined(counts2)
	not_defined(:counts2)
else
	let
		result = counts2([51,-52,-52,53,51])

		if ismissing(result)
			still_missing()
		elseif !(result isa Tuple{<:AbstractVector,<:AbstractVector})
			keep_working(md"Verifique que `counts2` retorna uma tupla com dois vetores.")
		elseif result == (
				[-52, 51, 53],
				[2, 2, 1],
			)
			correct()
		else
			keep_working()
		end
	end
end

# ╔═╡ 26bf2a9c-f42e-4c97-83d2-b9d637a2e8ae
if !@isdefined(probability_distribution)
	not_defined(:probability_distribution)
else
	let
		result = probability_distribution([51,-52,-52,53,51])

		if length(result) == 2 && result[1] == [0] && result[2] == [1]
			still_missing()
		elseif !(result isa Tuple{<:AbstractVector,<:AbstractVector})
			keep_working(md"Verifique que `counts2` retorne uma tupla com dois vetores.")
		elseif result[1] == [-52, 51, 53] &&
				isapprox(result[2], [2, 2, 1] ./ 5)
			correct()
		else
			keep_working()
		end
	end
end

# ╔═╡ 3ea51057-4438-4d4a-b964-630e87a82ce5
if !@isdefined(bernoulli)
	not_defined(:bernoulli)
else
	let
		result = bernoulli(0.5)
		
		if result isa Missing
			still_missing()
		elseif !(result isa Bool)
			keep_working(md"Verifique sua função retorne `true` ou `false`.")
		else
			if bernoulli(0.0) == false && bernoulli(1.0) == true
				correct()
			else
				keep_working()
			end
		end
	end
end

# ╔═╡ fccff967-e44f-4f89-8995-d822783301c3
if !@isdefined(geometric)
	not_defined(:geometric)
else
	let
		result = geometric(1.0)
		
		if result isa Missing
			still_missing()
		elseif !(result isa Int)
			keep_working(md"Verifique que sua função retorna um inteiro: o tempo de falha.")
		else
			if result == 1
				samples = [geometric(0.2) for _ in 1:256]
				
				a, b = extrema(samples)
				if a == 1 && b > 20
					correct()
				else
					keep_working()
				end
			else
				keep_working(md"Para `p = 1.0` deve retornar `1`: o componente falha já no primeiro dia.")
			end
		end
	end
end

# ╔═╡ 0210b558-80ae-4a15-92c1-60b0fd7924f3
if !@isdefined(cumulative_sum)
	not_defined(:cumulative_sum)
else
	let
		result = cumulative_sum([1,2,3,4])
		if result isa Missing
			still_missing()
		elseif !(result isa AbstractVector)
			keep_working(md"Sua rotina deve retornar um vetor: a soma acumulada!")
		elseif length(result) != 4
			keep_working(md"O vetor de retorno deve ter o mesmo comprimento que `xs`.")
		else
			if isapprox(result, [1, 3, 6, 10])
				correct()
			else
				keep_working()
			end
		end
	end
end

# ╔═╡ a81516e8-0099-414e-9f2c-ab438764348e
if !@isdefined(geometric_bin)
	not_defined(:geometric_bin)
else
	let
		result1 = geometric_bin(0.1, 0.1)
		result2 = geometric_bin(0.9, 0.1)
		
		if result1 isa Missing
			still_missing()
		elseif !(result1 isa Real)
			keep_working(md"Make sure that you return a number.")
		elseif all(isinteger, [result1, result2])
			if result1 == 21 || result2 == 21 ||  result1 == 22 || result2 == 22

				correct()
			else
				keep_working()
			end
		else
			keep_working(md"You should use the `floor` function to return an integer.")
		end
	end
end

# ╔═╡ ddf2a828-7823-4fc0-b944-72b60b391247
todo(text) = HTML("""<div
	style="background: rgb(220, 200, 255); padding: 2em; border-radius: 1em;"
	><h1>TODO</h1>$(repr(MIME"text/html"(), text))</div>""")

# ╔═╡ a7feaaa4-618b-4afe-8050-4bf7cc609c17
bigbreak = html"<br><br><br><br><br>";

# ╔═╡ 4ce0e43d-63d6-4cb2-88b8-8ba80e17012a
bigbreak

# ╔═╡ 6f55a612-8c4f-11eb-0f6b-755442c4ed3d
bigbreak

# ╔═╡ 51801da7-38da-4628-8a7a-119358e60086
bigbreak

# ╔═╡ 43966251-c8db-4999-bc4f-0f1fc34e0264
bigbreak

# ╔═╡ 06412687-b44d-4a69-8d6c-0cf4eb51dfad
bigbreak

# ╔═╡ 94053b41-4a06-435d-a91a-9dfa9655937c
bigbreak

# ╔═╡ a5234680-8b02-11eb-2574-15489d0d49ea
bigbreak

# ╔═╡ 2962c6da-feda-4d65-918b-d3b178a18fa0
begin
	fruits = ["🍒", "🍐", "🍋"]
	length(fruits)
end

# ╔═╡ 887a5106-c44a-4437-8c6f-04ad6610738a
begin
	fruits = ["🍉"]
	length(fruits)
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
Plots = "~1.35.3"
PlutoUI = "~0.7.12"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.3"
manifest_format = "2.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "84259bb6172806304b9101094a7cc4bc6f56dbc6"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.5"

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

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.DataAPI]]
git-tree-sha1 = "46d2680e618f8abd007bce0c3026cb0c4a8f2032"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.12.0"

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
git-tree-sha1 = "5158c2b41018c5f7eb1470d558127ac274eca0c9"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.1"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

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
git-tree-sha1 = "3cdd8948c55d8b53b5323f23c9581555dc2e30e1"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.5.0"

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

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

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
git-tree-sha1 = "5d4d2d9904227b8bd66386c1138cf4d5ffa826bf"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "0.4.9"

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
git-tree-sha1 = "6872f9594ff273da6d13c7c1a1545d5a8c7d0c1c"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.6"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "3c3c4a401d267b04942545b1e964a20279587fd7"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.3.0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e60321e3f2616584ff98f0a4f18d98ae6f89bbb3"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.17+0"

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

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "6c01a9b494f6d2a9fc180a08b182fcb06f0958a0"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.2"

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
git-tree-sha1 = "524d9ff1b2f4473fef59678c06f9f77160a204b1"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.35.3"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "6e33d318cf8843dade925e35162992145b4eb12f"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.44"

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
git-tree-sha1 = "c6c0f690d0cc7caddb74cef7aa847b824a16b256"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+1"

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
git-tree-sha1 = "9b1c0c8e9188950e66fc28f40bfe0f8aac311fe0"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.7"

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
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

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

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

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

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

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
# ╟─9b6ce746-087c-4416-95ca-46b1e11ba049
# ╟─0560cf7b-9986-402a-9c40-779ea7a7292d
# ╟─082542fe-f89d-4774-be20-1e1a78f21291
# ╠═6f4274b5-87e2-420d-83d2-83a8408650cd
# ╟─aaa41509-a62d-417b-bca7-a120e3a5e5b2
# ╠═8c8388cf-9891-423c-8db2-d40d870bb38e
# ╟─4ce0e43d-63d6-4cb2-88b8-8ba80e17012a
# ╟─6c6e055a-8c4c-11eb-14a7-6d3036e248b9
# ╟─17fa9e2e-8c4d-11eb-334c-ad3704b43e95
# ╠═2bebafd4-8c4d-11eb-14ba-27ab7eb763c1
# ╠═d025d432-23d0-4a6b-8b09-cc1114367b8f
# ╟─17faeb5e-8c4d-11eb-3589-c96e799b8a52
# ╠═5e6f16fc-04a0-4774-8ce0-78953e047269
# ╠═49b9e55c-1179-4bee-844e-62ae36d20a5d
# ╟─645ace88-b8e6-4957-ad6e-49fd82b08fe5
# ╟─6a302ce6-a327-449e-b41a-859d502f4df7
# ╟─18031e1e-8c4d-11eb-006b-adaf55d54282
# ╠═4bbbbd24-d592-4ce3-a619-b7f760672b99
# ╠═44d0f365-b2a8-41a2-98d3-0aa34e8c80c0
# ╟─18094d52-8c4d-11eb-0620-d30c24a8c75e
# ╠═c825f913-9545-4dbd-96f9-5f7621fc242d
# ╟─180fc1d2-8c4d-11eb-0362-230d84d47c7f
# ╠═fde456e5-9985-4939-af59-9b9a92313b61
# ╠═cc6923ff-09e0-44cc-9385-533182c4382d
# ╟─18103c98-8c4d-11eb-2bed-ed20aba64ae6
# ╟─bfa216a2-ffa6-4716-a057-62a58fd9f04a
# ╠═156c1bea-8c4f-11eb-3a7a-793d0a056f80
# ╠═37294d02-8c4f-11eb-141e-0be49ea07611
# ╟─2b6a64b9-779b-47d1-9724-ad066f14fbff
# ╠═18139dc0-8c4d-11eb-0c31-a75361ed7321
# ╠═447bc642-8c4f-11eb-1d4f-750e883b81fb
# ╠═6b1dc96a-8c4f-11eb-27ca-ffba02520fec
# ╟─26bf2a9c-f42e-4c97-83d2-b9d637a2e8ae
# ╟─6f55a612-8c4f-11eb-0f6b-755442c4ed3d
# ╟─95145ee9-c826-45e3-ab51-442c8ca70fa3
# ╟─51801da7-38da-4628-8a7a-119358e60086
# ╟─c5464196-8ef7-418d-b1aa-fafc3a03c68c
# ╠═2962c6da-feda-4d65-918b-d3b178a18fa0
# ╠═887a5106-c44a-4437-8c6f-04ad6610738a
# ╟─409ed7e5-a3b8-4d37-b85d-e5cb4c1e1708
# ╠═36de9792-1870-4c78-8330-83f273ee1b46
# ╠═8041603b-ae47-4569-af1d-cebb00edb32a
# ╟─2d56bf20-8866-4ec1-9ceb-41004aa185d0
# ╟─2577c5a7-338f-4aef-b34b-456949cfc17b
# ╠═d12229f4-d950-4983-84a4-304a7637ac7b
# ╟─43966251-c8db-4999-bc4f-0f1fc34e0264
# ╟─a8241562-8c4c-11eb-2a85-d7502e7fb2cf
# ╟─fdb394a0-8c4f-11eb-0585-bb8c28f952cb
# ╠═0233835a-8c50-11eb-01e7-7f80bd27683e
# ╟─3ea51057-4438-4d4a-b964-630e87a82ce5
# ╟─fdb3f1c8-8c4f-11eb-2281-bf01205bb804
# ╠═08028df8-8c50-11eb-3b22-fdf5104a4d52
# ╠═2b35dc1c-8c50-11eb-3517-83589f2aa8cc
# ╟─7077a0b6-4539-4246-af2d-ab990c34e810
# ╟─e125bd7f-1881-4cff-810f-8af86850249d
# ╟─fccff967-e44f-4f89-8995-d822783301c3
# ╟─6cb36508-836a-4191-b615-45681a1f7443
# ╠═370ec1dc-8688-443c-bf57-dd1b2a42a5fa
# ╟─fdb46c72-8c4f-11eb-17a2-8b7628b5d3b3
# ╠═32700660-8c50-11eb-2fdf-5d9401c07de3
# ╠═192caf02-5234-4379-ad74-a95f3f249a72
# ╟─fdc1a9f2-8c4f-11eb-1c1e-5f92987b79c7
# ╠═3cd78d94-8c50-11eb-2dcc-4d0478096274
# ╠═4118ef38-8c50-11eb-3433-bf3df54671f0
# ╟─c4ca3940-9bd5-4fa6-8c73-8675ef7d5f41
# ╠═25ae71d0-e6e2-45ff-8900-3caf6fcea937
# ╟─3a7c7ca2-e879-422e-a681-d7edd271c018
# ╠═97d7d154-8c50-11eb-2fdd-fdf0a4e402d3
# ╟─b1287960-8c50-11eb-20c3-b95a2a1b8de5
# ╟─fdcab8f6-8c4f-11eb-27c6-3bdaa3fcf505
# ╠═1b1f870f-ee4d-497f-8d4b-1dba737be075
# ╟─fdcb1c1a-8c4f-11eb-0aeb-3fae27eaacbd
# ╠═444a0557-d276-49f1-be6d-4784ae3ad8fa
# ╠═d5b29c53-baff-4529-b2c1-776afe000d38
# ╠═9a92eba4-ad68-4c53-a242-734718aeb3f1
# ╠═48751015-c374-4a77-8a00-bca81bbc8305
# ╠═562202be-5eac-46a4-9542-e6593bc39ff9
# ╠═e8d2a4ab-b710-4c16-ab71-b8c1e71fe442
# ╠═a486dc37-609d-4aae-b4ec-71de726191c7
# ╠═65ea5492-d833-4754-89a3-0aa671c3ec7a
# ╠═264089bc-aa30-450f-89f7-ffd589eee13c
# ╠═0be83efa-e94f-4397-829f-24f705b044b1
# ╟─fdd5d98e-8c4f-11eb-32bc-51bc1db98930
# ╠═406c9bfa-409d-437c-9b86-fd02fdbeb88f
# ╟─f8b982a7-7246-4ede-89c8-b2cf183470e9
# ╠═caafed37-0b3b-4f6c-919f-f16df7248c23
# ╠═501bcc30-f96f-42e4-a5aa-09a4138b5b72
# ╠═b763b6e8-8221-4b08-9a8e-8d5e63cbd144
# ╟─d2e4185e-8c51-11eb-3c31-637902456634
# ╟─06412687-b44d-4a69-8d6c-0cf4eb51dfad
# ╟─a82728c4-8c4c-11eb-31b8-8bc5fcd8afb7
# ╟─23a1b76b-7393-4a4c-b6a5-40fb15dadd29
# ╠═45735d82-8c52-11eb-3735-6ff9782dde1f
# ╠═dd80b2eb-e4c3-4b2f-ad5c-526a241ac5e6
# ╠═3df70c76-1aa6-4a0c-8edf-a6e3079e406b
# ╟─b1ef5e8e-8c52-11eb-0d95-f7fa123ee3c9
# ╟─a3f08480-4b2b-46f2-af4a-14270869e766
# ╟─1b6035fb-d8fc-437f-b75e-f1a6b3b4cae7
# ╟─c3cb9ea0-5e0e-4d5a-ab23-80ed8d91209c
# ╠═dd59f48c-bb22-47b2-8acf-9c4ee4457cb9
# ╟─5907dc0a-de60-4b58-ac4b-1e415f0051d2
# ╠═c7093f08-52d2-4f22-9391-23bd196c6fb9
# ╟─316f369a-c051-4a35-9c64-449b12599295
# ╟─9240f9dc-aa34-4e7b-8b82-86ea1376f527
# ╟─d24ddb61-3d65-4bea-ad8f-d5a3ac44a563
# ╟─430e0975-8eb6-420c-a18e-f3493182c5c7
# ╠═5185c938-8c53-11eb-132d-83342e0c775f
# ╠═e4095d34-552e-495d-b318-9afe6839d577
# ╟─0210b558-80ae-4a15-92c1-60b0fd7924f3
# ╟─fa5843e8-8c52-11eb-2138-dd57b8bf25f7
# ╠═7aa0ec08-8c53-11eb-1935-23237a448399
# ╠═e649c914-dd28-4194-9393-4dc8836f3743
# ╟─fa59099a-8c52-11eb-37a7-291f80ea0406
# ╠═1ae91530-c77e-4d92-9ad3-c969bc7e1fa8
# ╠═fa599248-8c52-11eb-147a-99b5fb75d131
# ╠═16b4e98c-4ae7-4145-addf-f43a0a96ec82
# ╟─fa671c06-8c52-11eb-20e0-85e2abb4ecc7
# ╠═47d56992-8c54-11eb-302a-eb3153978d26
# ╟─a81516e8-0099-414e-9f2c-ab438764348e
# ╟─adfb343d-beb8-4576-9f2a-d53404cee42b
# ╠═5b7f2a91-a4f0-49f7-b8cf-6f677104d3e1
# ╠═b3b11113-2f0c-45d2-a14e-011a61ae8e9b
# ╟─fc681dde-8c52-11eb-07fa-7d0ef9f22e93
# ╠═1d007d99-2526-4c19-9c96-3fad1750670e
# ╠═c37bbb1f-8f5e-4097-9104-43ef65aa1cbd
# ╟─94053b41-4a06-435d-a91a-9dfa9655937c
# ╟─79eb5e14-8c54-11eb-3c8c-dfeba16305b2
# ╟─8c9c217e-8c54-11eb-07f1-c5fde6aa2946
# ╠═2270e6ba-8c5e-11eb-3600-615519daa5e0
# ╠═225bbcbd-0628-4151-954e-9a85d1020fd9
# ╟─1dc5daa6-8c5e-11eb-1355-b1f627d04a18
# ╠═deb5fbfb-1e03-42ce-a6d6-c8d3edd89a9a
# ╠═8517f92b-d4d3-46b5-9b9a-e609175b6481
# ╠═c1e3f066-5e12-4018-9fb2-4e7fc13172ba
# ╟─1dc68e2e-8c5e-11eb-3486-454d58ac9c87
# ╠═bb8f69fd-c704-41ca-9328-6622d390f71f
# ╟─1dc7389c-8c5e-11eb-123a-7f59dc6504cf
# ╠═d3bec73d-0106-496d-93ae-e1e26534b8c7
# ╠═d972be1f-a8ad-43ed-a90d-bca358d812c2
# ╟─de83ffd6-cd0c-4b78-afe4-c0bcc54471d7
# ╠═fe45b8de-eb3f-43ca-9d63-5c01d0d27671
# ╟─a5234680-8b02-11eb-2574-15489d0d49ea
# ╟─5aabbec1-a079-4936-9cd1-9c25fe5700e6
# ╟─42d6b87d-b4c3-4ccb-aceb-d1b020135f47
# ╟─8fd9e34c-8f20-4979-8f8a-e3e2ae7d6c65
# ╠═d375c52d-2126-4594-b819-aba9d34fe77f
# ╟─2d7565d4-88da-4e41-aad6-958ed6b3b2e0
# ╟─d7f45d51-f426-4353-af58-858395295ce0
# ╟─9b2aa95d-4583-40ec-893c-9fc751ea22a1
# ╟─5dca2bb3-24e6-49ae-a6fc-d3912da4f82a
# ╟─ddf2a828-7823-4fc0-b944-72b60b391247
# ╟─a7feaaa4-618b-4afe-8050-4bf7cc609c17
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
