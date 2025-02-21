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

# ╔═╡ d49682ff-d529-4283-871b-f8ee50a4e6ee
filter!(LOAD_PATH) do path
    path != "@v#.#"
end;

# ╔═╡ 6b473b2d-4326-46b4-af38-07b61de287fc
begin
    import ImageIO
    import PNGFiles
    using Colors, ColorVectorSpace, ImageShow, FileIO
    using PlutoUI
    using HypertextLiteral
    using LinearAlgebra
    using ForwardDiff
    using Printf
end

# ╔═╡ 440d3d97-4b81-4a55-add1-2dcf87089ef2
md"Tradução livre de [`transformations_and_autodiff.jl`](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week2/transformations_and_autodiff.jl)"

# ╔═╡ b7895bd2-7634-11eb-211e-ef876d23bd88
PlutoUI.TableOfContents(aside=true)

# ╔═╡ e6a09409-f262-453b-a434-bfd935306719
md"""
#### Inicializando pacotes

_Ao executar esse notebook a primeira vez ele pode levar até 15 min, tenha paciência_
"""

# ╔═╡ 58a520ca-763b-11eb-21f4-3f27aafbc498
md"""
Da última vez nós definimos combinações lineares de imagens. Elas eram baseadas nas operações fundamentais:
* Multiplicar uma imagem por escalar (mudando a sua escala ou "força").
* Adicionar duas imagens através da soma das cores.

Como vocês viram em álgebra linear, essas duas operações geram _combinações lineares_. Vimos também que no caso de imagens é mais natural considerar combinações convexas (para não ter que lidar com a saturação). Na aula de hoje vamos partir dessas ideias e focar em transformações lineares, que são funções. Usaremos, então, o computador para nos ajudar a entendê-las.

Vamos começar por ver diferentes formas de definir funções em Julia.
"""

# ╔═╡ 2cca0638-7635-11eb-3b60-db3fabe6f536
md"""
# Funções em Matemática e em Julia
"""

# ╔═╡ c8a3b5b4-76ac-11eb-14f0-abb7a33b104d
md"""
### Funções de uma variável
"""

# ╔═╡ db56bcda-76aa-11eb-2447-5d9076789244
md"""
Veja abaixo alguns exemplos de funções, como aprendemos no ensino médio:
* $f₁(x) = x^2$
* $f₂(x) = \sin(x)$
* $f₃(x) = x^\alpha$

Julia permite que definir funções simples em um formato curto. Há também um formato adequado a funções mais longas e complexas.
"""

# ╔═╡ 539aeec8-76ab-11eb-32a3-95c6672a0ea9
# Short version
f₁(x) = x^2 # subscript unicode: \_1 + <tab>

# ╔═╡ 81a00b78-76ab-11eb-072a-6b96847c2ce4
f₁(5)

# ╔═╡ 2369fb18-76ab-11eb-1189-85309c8f925b
# Anonymous version
x -> sin(x)

# ╔═╡ 98498f84-76ab-11eb-23cf-857c776a9163
(x -> sin(x))(π / 2)

# ╔═╡ c6c860a6-76ab-11eb-1dec-1b2f179a0fa9
# Long version
function f₃(x, α=3) # Valor default
    return x^α      # O "return" é opcional
end

# ╔═╡ f07fbc6c-76ab-11eb-3382-87c7d65b4078
f₃(5)

# ╔═╡ f4fa8c1a-76ab-11eb-302d-bd410432e3cf
f₃(5, 2)

# ╔═╡ b3faf4d8-76ac-11eb-0be9-7dda3d37aba0
md"""
Argumentos com nomes (keywords). Eles só podem ser usados com os nomes, já que neles a ordem não importa. Usa-se o `;` para marcar o seu início. Podem ou não ter valores padrão.
"""

# ╔═╡ 71c074f0-76ac-11eb-2164-c36381212bff
f₄(x; α) = x^α

# ╔═╡ 87b99c8a-76ac-11eb-1c94-8f1ffe3be593
f₄(2, α=5)

# ╔═╡ 504076fc-76ac-11eb-30c3-bfa75c991cb2
md"""
Veja a [documentação sobre funções de Julia](https://docs.julialang.org/en/v1/manual/functions/) para mais detalhes.
"""

# ╔═╡ f1dd24d8-76ac-11eb-1de7-a763a1b95668
md"""
### Diferenciação automática de funções de uma variável
"""

# ╔═╡ 38b51946-76ae-11eb-2c8a-e19b30bf42cb
md"""
Lembrando que a definição de derivada é
```math
f'(x) = \lim_{h \rightarrow 0} \frac{f(x + h) - f(x)}{h}.
```
Essa definição sugere imediatamente a fórmula de diferenciação progressiva que você deve ter visto em cálculo numérico. Vamos relembrá-la no caso específico da função seno.
"""

# ╔═╡ 632a1f8c-76ae-11eb-2088-15c3e3c0a210
begin
    md"""
    $(@bind e Slider(-12:-4, default=-12, show_value=true))
    """
end

# ╔═╡ 8a99f186-76af-11eb-031b-f1c288993c7f
h = 10.0^e

# ╔═╡ ca1dfb8a-76b0-11eb-1323-d100bdeedc2d
@sprintf("Numérico = %.12f, Exato = %.12f", (sin(1 + h) - sin(1)) / h, cos(1))

# ╔═╡ fe01da74-76ac-11eb-12e3-8320340b6139
md"""
De fato, as formas tradicionais de se diferenciar uma função numericamente são:

* Usar diferenças finitas seja progressiva ou centrada com os devidos cuidados para escolher a pertubação $h$.

* Implementar manualmente a fórmula da derivada.

A primeira opção sofre por não ser exata, mas tem a grande vantagem de ser simples de implementar. Já a segunda pode dar trabalho, dependendo de quão complexa for a função, e está propensa a erros. Muitas vezes usamos a primeira para verificar se não comentemos erros grosseiros na segunda.

Uma alternativa mais moderna é o uso de diferenciação automática. Nesse caso usamos um sistema que calcula automaticamente a função e a derivada, sem intervenção manual e sem erros numéricos. Uma boa biblioteca de diferenciação automática ainda faz isso com cuidado de não impor uma grande penalidade no tempo de execução. De fato, especialmente para funções com muitos parâmetros, a tendência é que a implementação automática seja mais eficiente que uma implementação manual simples.

Em Julia, uma biblioteca com esse tipo de funcionalidade é a `ForwardDiff`. Vamos vê-la em ação inicialmente para funções de um único parâmetro.
"""

# ╔═╡ d42aec08-76ad-11eb-361a-a1f2c90fd4ec
ForwardDiff.derivative(f₁, 5)

# ╔═╡ 06437040-76ae-11eb-0b1c-23a6470f41c8
ForwardDiff.derivative(x -> f₃(x, 4), 5)

# ╔═╡ 28cd454c-76ae-11eb-0d1e-a56995100d59
md"""
Observe que usamos uma função anônima para fixar o parâmetro `α = 4` e criar uma nova função que depende de um único parâmetro.

Por fim, retomando o exemplo da função seno.
"""

# ╔═╡ f8a7e203-b2b9-480c-817f-e2d440881775
@sprintf(
    "Numérico = %.12f, Exato = %.12f, Automático = %.12f",
    (sin(1 + h) - sin(1)) / h,
    cos(1),
    ForwardDiff.derivative(sin, 1)
)

# ╔═╡ f7df6cda-76b1-11eb-11e4-8d0af0349651
md"""
### Funções reais de várias variáveis
"""

# ╔═╡ 63449b54-76b4-11eb-202f-3bda2f4cff4d
md"""
Muitas vezes estamos interessados em usar funções a valores reais mas que dependem de múltiplas variáveis. Em Julia você pode definir esse tipo de função recebendo um vetor ou recebendo as múltiplas variáveis. Vamos ver isso implementando
$f_5(x) = 5\sin(x_1*x_2) + 2x_2/4x_3$.

Observe que usamos o mesmo nome, porque é a mesma função e Julia sabe distinguir as duas versões pelo número de parâmetros.
"""

# ╔═╡ 8c6b0236-76b4-11eb-2acf-91da23bedf0e
begin
    f₅(v) = 5sin(v[1] * v[2]) + 2v[2] / 4v[3]
    f₅(x, y, z) = 5sin(x * y) + 2y / 4z
end

# ╔═╡ a397d526-76b5-11eb-3cce-4374e33324d1
f₅(1, 2, 3), f₅([1, 2, 3])

# ╔═╡ 4a57d898-76b6-11eb-15ea-7be43393922c
md"""
Melhor ainda, você pode escrever a função uma única vez e definir a outra versão chamando a primeira e, assim, evitando re-escrever o código. Isso é sempre uma boa prática. Assim se você modificar a definição da primeira função ela já estará ajustada na segunda versão.
"""

# ╔═╡ bf23ab30-76b5-11eb-1adb-3d74a52cddfd
begin
    f₆(x, y, z) = 5sin(x * y) + 2y / 4z
    f₆(v) = f₆(v[1], v[2], v[3])
end

# ╔═╡ d5d4ac48-76b6-11eb-1687-ed853c2db7c9
f₆(1, 2, 3), f₆([1, 2, 3])

# ╔═╡ 89b2d570-76ba-11eb-0389-813bbb33efea
md"""
Julia também tem um "truque" que permite que você escreva uma função com um número predefinido de argumentos mas recebendo um vetor. Para isso usamos um tupla de elementos como argumento que é usada para "desconstruir" o vetor de entrada.

Uma das vantagens dessa forma é que torna possível criar funções que recebem vetores e que são mais legíveis quando o número de elementos do vetor é predeterminado e pequeno.
"""

# ╔═╡ a8c28578-76ba-11eb-3f3f-af35ff0b6c74
f₇((x, y, z)) = 5sin(x * y) + 2y / 4z # more readable than 5sin(v[1]*v[2]) + 2*v[2]/4v[3]

# ╔═╡ d9e07084-76ba-11eb-18ac-c58b1bc972ba
f₇([1, 2, 3]) # this works with vector arguments, but not scalars (f₇(1,2,3) error)

# ╔═╡ 42172fb6-76b7-11eb-0a11-b7e10c6881f5
md"""
Lembrando, na prática as funções $f_5$ e $f_6$ têm dois métodos definidos distintos. Um que recebe um único argumento e outro que recebe três. Já $f_7$ tem um método apenas, que recebe um único argumento.

Obs: Na verdade f₇ é uma função que recebe um único parâmetro e o que a linguagem faz é uma atribuição no topo da função para poder usar os nomes internamente. Isso é chamado de [desestruturação de argumentos](https://docs.julialang.org/en/v1/manual/functions/#Argument-destructuring).

Ou seja se você define uma função
```julia
function foo((a, b, c))
	⋮
end
```

O que a linguagem faz para você é criar a função assim:
```julia 
function foo(v)
	a, b, c = v
	⋮
end
```

Também é possível ter mais de um grupo de parâmetros assim:
```julia
function bar((x, y), (z, w))
	⋮
end
```
"""

# ╔═╡ 57b0cd3c-76b7-11eb-0ece-810f3a8ede00
methods(f₅)

# ╔═╡ 6d411cea-76b9-11eb-061b-87d472bc3bdd
md"""
### Diferenciação automática no caso de funções escalares a várias variáveis
"""

# ╔═╡ bc2c6afc-76b7-11eb-0631-51f83cd73205
md"""
Em muitas aplicações, como em aprendizado de máquina, é comum termos que otimizar funções escalares de várias variáveis. Nesse caso, os métodos de otimização tipicamente dependem da capacidade de se calcular as derivadas da função que são capturadas na noção de **gradiente**. Mais uma vez podemos usar a diferenciação automática para fazer isso por nós:
"""

# ╔═╡ ef06cfd8-76b7-11eb-1530-1fcd7e5c5992
ForwardDiff.gradient(f₅, [1, 2, 3])

# ╔═╡ 051db7a0-76b8-11eb-14c7-531f42ef60b8
md"""
Lembrando que
$f_5(x) = 5\sin(x_1*x_2) + 2x_2/4x_3$
"""

# ╔═╡ 5f1afd24-76b8-11eb-36ab-9bbb3d73b930
md"""
Podemos verificar numericamente o valor calculado fazendo diferença progressiva em cada uma das coordenadas. Lembre, o gradiente é o vetor de derivadas parciais.
"""

# ╔═╡ 2705bf34-76b8-11eb-3aaa-d363085784ff
begin
    ∂f₅∂x = (f₅(1 + h, 2, 3) - f₅(1, 2, 3)) / h
    ∂f₅∂y = (f₅(1, 2 + h, 3) - f₅(1, 2, 3)) / h
    ∂f₅∂z = (f₅(1, 2, 3 + h) - f₅(1, 2, 3)) / h
    ∇f = [∂f₅∂x, ∂f₅∂y, ∂f₅∂z]
end

# ╔═╡ dfb9d74c-76b8-11eb-24ff-e521f1294a6f
md"""
A fórmula acima é bastante natural ao recordamos o que é uma derivada parcial. Nela, mantemos todas as variáveis menos uma fixa e imaginamos que estamos derivando a função resultante que permite a mudança dessa única variável.
"""

# ╔═╡ 1049f458-76b9-11eb-1d2d-af0b22480121
md"""
**Observação importante**: Em aprendizagem de máquina, e outros problemas de otimização modernos, é comum se querer minimizar uma função escalar que depende de um número _muito grande_ de variáveis. Nesse contexto, o uso de métodos baseados em seguir a direção de menos o gradiente é comum. Caso o número de variáveis seja pequeno, há, certamente, métodos mais rápidos. Um exemplo é o método de Newton. que usa informação de derivada segunda. Lembre que a derivada segunda nesse caso é uma matriz (a hessiana). Se o número de variáveis for muito grande, pode ser impossível armazenar a matriz inteira na memória. Ela é um objeto com tamanho proporcional ao quadrado do número de variáveis.
"""

# ╔═╡ a0afe3ae-76b9-11eb-2301-cde7260ddd7f
md"""
### Mais transformações: Funções de múltiplas variáveis a valores vetoriais
"""

# ╔═╡ ac1ab224-76bb-11eb-13cb-0bd44bea1042
md"""
Em alguns contextos usamos o nome "transformação" para funções que recebem múltiplas variáveis e devolvem múltiplos valores. Ou seja, entram e saem vetores.
"""

# ╔═╡ bcf92688-76b9-11eb-30fb-1f320a65f45a
md"""
Vamos definir algumas funções simples que recebem vetores bidimensionais e devolvem também vetores bidimensionais.
"""

# ╔═╡ d364f91a-76b9-11eb-1807-75e733940d53
begin
    id((x, y)) = [x, y]
    lin1((x, y)) = [2x + 3y, -5x + 4x]
    scalex(α) = ((x, y),) -> (α * x, y)
    scaley(α) = ((x, y),) -> (x, α * y)
    rot(θ) = ((x, y),) -> [cos(θ) * x + sin(θ) * y, -sin(θ) * x + cos(θ) * y]
    shear(α) = ((x, y),) -> [x + α * y, y]
    genlin(a, b, c, d) = ((x, y),) -> [a * x + b * y; c * x + d * y]
end

# ╔═╡ f25c6308-76b9-11eb-3563-1f0ef4cdf86a
rot(π / 2)([4, 5])

# ╔═╡ c9a148f0-76bb-11eb-0778-9d3e84369a19
md"""
Imagino que você notou que todas essas funções podem ser definidas com matrizes, já que são lineares. O caso geral é o último, ou seja:
"""

# ╔═╡ 89f0bc54-76bb-11eb-271b-3190b4d8cbc0
md"""
``\begin{pmatrix} a & b \\ c & d \end{pmatrix} \begin{pmatrix} x \\ y \end{pmatrix}`` .
"""

# ╔═╡ f70f7ea8-76b9-11eb-3bd7-87d40a2861b1
md"""
Mas é claro que você sabe que há outras transformações que são não lineares: elas não podem ser escritas na forma matricial.

O que diferencia um tipo de outro?
"""

# ╔═╡ 78176284-76bc-11eb-3045-f584127f58b9
begin
    function warp(α)
        ((x, y),) -> begin
            r = √(x^2 + y^2)
            θ = α * r
            rot(θ)([x, y])
        end
    end

    rθ(x) = (norm(x), atan(x[2], x[1])) # maybe vectors are more readable here?

    xy((r, θ)) = (r * cos(θ), r * sin(θ))
end

# ╔═╡ bf28c388-76bd-11eb-08a7-af2671218017
md"""
Em uma primeira leitura, a função "warp" parece meio sofisticada, mas ela nada mais é do que uma rotação cujo ângulo de rotação aumenta a medida que nos afastamos da origem.

Já rθ, nada mais é do que a mudança para coordenadas polares e a xy sua inversa.
"""

# ╔═╡ 5655d2a6-76bd-11eb-3042-5b2dd3f6f44e
begin
    warp₂(α, x, y) = rot(α * √(x^2 + y^2))
    warp₂(α) = ((x, y),) -> warp₂(α, x, y)([x, y])
end

# ╔═╡ 852592d6-76bd-11eb-1265-5f200e39113d
warp(1)([5, 6])

# ╔═╡ 8e36f4a2-76bd-11eb-2fda-9d1424752812
warp₂(1.0)([5.0, 6.0])

# ╔═╡ 09ed6d38-76be-11eb-255b-3fbf76c21097
md"""
### Diferenciação automática de transformações

Naturalmente `ForwardDiff` também consegue diferenciar automaticamente transformações. Nesse caso, o objeto que representa a derivada é uma matriz, chamada de matriz jacobiana. Isso porque ela é composta de múltiplos gradientes Um para cada coordenada de saída.
"""

# ╔═╡ 9786e2be-76be-11eb-3755-b5669c37aa64
ForwardDiff.jacobian(warp(3.0), [4, 5])

# ╔═╡ 963694d6-76be-11eb-1b27-d5d063964d24
md"""
What is this thing?
"""

# ╔═╡ b78ef2fe-76be-11eb-1f55-3d0874b298e8
begin
    ∂w∂x = (warp(3.0)([4 + h, 5]) - warp(3.0)([4, 5])) / h # This is a vector!
    ∂w∂y = (warp(3.0)([4, 5 + h]) - warp(3.0)([4, 5])) / h # This too.
    [∂w∂x ∂w∂y]
end

# ╔═╡ ad728ee6-7639-11eb-0b23-c37f1366fb4e
md"""
## O que é, de verdade, uma transformação linear?

No ensino médio aprendemos a multiplicar duas matrizes ou multiplicar matrizes por vetores sem uma compreensão clara do significado da fórmula. Como é uma fórmula complexa e com várias contas repetidas, os computadores são ótimos para executar essa tarefa. Por que então ensinar humanos a fazer isso sem uma justificativa clara?
"""

# ╔═╡ 4d4e6b32-763b-11eb-3021-8bc61ac07eea
md"""
Mas vocês já fizeram Álgebra Linear e lá aprenderam que matrizes são representações de transformações lineares. Nesse contexto, multiplicar uma matriz por um vetor calcula o resultado da transformação sobre aquele vetor de entrada. Já a multiplicação de matrizes nada mais é do que a forma natural de se obter a matriz da transformação composta.
"""

# ╔═╡ ce55beee-7643-11eb-04bc-b517703facff
begin
    transfs = Dict("Linear" => genlin, "Warp" => warp, "xy" => xy, "rθ" => rθ)
    transfs_names = collect(keys(transfs))
    md"""
    #### Escolha uma transformação:

    $(@bind transf Select(transfs_names))
    """
end

# ╔═╡ 005ca75a-7622-11eb-2ba4-9f450e71df1f
let
    range = -1.5:0.1:1.5
    md"""
    Modifica a matriz para definir a transformação linear.

    ``(``
     $(@bind a Scrubbable( range; default=1.0))
     $(@bind b Scrubbable( range; default=0.0))
    ``)``

    ``(``
    $(@bind c Scrubbable(range; default=0.0 ))
    $(@bind d Scrubbable(range; default=1.0))
    ``)``

    	**Executando essa célula redefine a matriz para a identidade**
    """
end

# ╔═╡ e04fa982-81fe-4f4e-bd2e-efb3392f246b
md"""Defina o parâmetro $\alpha$ da warp.

α = $(@bind α Slider(0:.1:10, show_value=true, default=0))
"""

# ╔═╡ 683bfffd-906d-45fc-b442-496639fb09cd
if transf == "Warp"
    T = warp(α)
elseif transf == "Linear"
    T = genlin(a, b, c, d)
else
    T = transfs[transf]
end

# ╔═╡ 60532aa0-740c-11eb-0402-af8ff117f042
md"Show grid lines $(@bind show_grid CheckBox(default=true))"

# ╔═╡ f085296d-48b1-4db6-bb87-db863bb54049
A = [
    a b
    c d
]

# ╔═╡ d1757b2c-7400-11eb-1406-d937294d5388
md"**_Det(A)_ = $a * $d - $c * $b =  $(det(A))**"

# ╔═╡ 5227afd0-7641-11eb-0065-918cb8538d55
md"""
Seria legal ter visto nas aulas de Álgebra Linear, não?

Dê uma olhada se quiser
[Wikipedia - Transformação Linear](https://en.wikipedia.org/wiki/Linear_map)

[Wikipedia - Matriz associada a uma transformação](https://en.wikipedia.org/wiki/Transformation_matrix)
"""

# ╔═╡ 2835e33a-7642-11eb-33fd-79fb8ad27fa7
md"""
Outra fórmula que muitas vezes é ensinada sem uma explicação mais profunda, ou geométrica, de seu significado é o determinante de uma matriz. Não tenho como provar isso nesse curso, mas é interessante entender que ele representa o fator de como a área dos paralelogramos transformados pela transformação linear varia! Esse é um exemplo de um objeto algébrico que fica muito mais interessante quando entendemos de onde vem, quando vemos o seu apelo geométrico!.
"""

# ╔═╡ a66eb6fe-76b3-11eb-1d50-659ec2bf7c44
md"""
### Diferenciação automática em 10 mins (tá bom... 11min)
"""

# ╔═╡ b9dba026-76b3-11eb-1bfb-ffe9c43ced5d
html"""
<div notthestyle="position: relative; right: 0; top: 0; z-index: 300;"><iframe src="https://www.youtube.com/embed/vAp6nUMrKYg" width=400 height=250  frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div>
"""

# ╔═╡ 62b28c02-763a-11eb-1418-c1e30555b1fa
md"""
E como ir além de três dimensões?

A gente escuta de tudo:
* Não existe algo como _mais de 3 dimensões_.
* A quarta dimensão é o tempo!
* Eu já tenho problemas de visualizar (ou desenhar) em 3 dimensões, imagine contemplar uma quarta!

... mas matemáticos não tem problemas com a ideia de dimensão geral $n$. Elas são apenas como novos graus de liberdade e boa parte da intuição que vem do espaço tri-dimensional se aplica para o caso de dimensões mais altas. É claro que que algo também se perde, mas mesmo isso pode ser a dica de um fenômenos interessante que merece ser compreendido.
"""

# ╔═╡ c536dafb-4206-4689-ad6d-6935385d8fdf
md"""
## Apêndice
"""

# ╔═╡ 40655bcc-6d1e-4d1e-9726-41eab98d8472
img_sources = [
    "https://www.ime.unicamp.br/~pjssilva/images/ensino/labcompsci/carmel-arquelau-bV3RXy9Upqg-unsplash.png" => "Tucano",
    "https://www.ime.unicamp.br/~pjssilva/images/ensino/labcompsci/matt-paul-catalano-MUwfuO5RXEo-unsplash.png" => "Onda",
    "https://user-images.githubusercontent.com/6933510/108883855-39690f80-7606-11eb-8eb1-e595c6c8d829.png" => "Setas",
]

# ╔═╡ c0c90fec-0e55-4be3-8ea2-88b8705ee258
md"""
#### Escolha uma imagem:

$(@bind img_source Select(img_sources))

Imagem do tucano de [Carmel Arquelau](https://unsplash.com/@kkpsi?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) em [Unsplash](https://unsplash.com/s/photos/toucan?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText).

Imagem onda de [Matt Paul Catalano](https://unsplash.com/@mattpaul?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) em [Unsplash](https://unsplash.com/s/photos/wave?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText).
"""

# ╔═╡ 4fcb4ac1-1ad1-406e-8776-4675c0fdbb43
img_original = load(download(img_source));

# ╔═╡ 74fe3391-21f0-4ab9-a41a-6eca0d88f889
"Maps x ∈ [mino, maxo] to [mind, maxd]"
function map_ints(x::Number, mino::Number, maxo::Number, mind::Number, maxd::Number)
    return mind + (x - mino) / (maxo - mino) * (maxd - mind)
end

# ╔═╡ 1726b965-acf6-4df5-83ef-8eb34308fc82
begin
    white(c::RGB) = RGB(1, 1, 1)
    white(c::RGBA) = RGBA(1, 1, 1, 0.75)
    black(c::RGB) = RGB(0, 0, 0)
    black(c::RGBA) = RGBA(0, 0, 0, 0.75)
end

# ╔═╡ cb1f80dd-ba4a-4176-b439-652529b8fd1a
function transform_image(T, img::AbstractMatrix)
    nrows, ncols = size(img)

    # I will assume that the x range from [-1, 1] and calculate the respective y range
    xmin, xmax = -1.0, 1.0
    ymin, ymax = -nrows / ncols, nrows / ncols

    # Create a white image 	
    out = fill(black(img[1, 1]), nrows, ncols)

    for col = 1:ncols, row = 1:nrows
        # Map pixel position to cartesian plane, the image in the original
        # zoom level will span half of the area
        x = map_ints(col, 1, ncols, 0.5 * xmin, 0.5 * xmax)
        y = map_ints(row, 1, nrows, 0.5 * ymax, 0.5 * ymin)

        x_dest, y_dest = T((x, y))

        # Paint transformed pixel
        if xmin ≤ x_dest ≤ xmax && ymin ≤ y_dest ≤ ymax
            j = round(Int, map_ints(x_dest, xmin, xmax, 1, ncols))
            i = round(Int, map_ints(y_dest, ymax, ymin, 1, nrows))
            out[i, j] = img[round(Int, row), round(Int, col)]
        end
    end
    return out
end

# ╔═╡ 83d45d42-7406-11eb-2a9c-e75efe62b12c
function with_gridlines(img::Matrix; n=10)
    rows, cols = size(img)
    result = copy(img)

    stroke = white(img[1, 1])

    # Add grid
    grid_lin = floor.(Int, LinRange(2, rows - 1, n))
    grid_col = floor.(Int, LinRange(2, cols - 1, n))
    for i in grid_lin
        result[i-1:i+1, :] .= stroke
    end
    for j in grid_col
        result[:, j-1:j+1] .= stroke
    end

    # Add axis marks
    axis_lin = rows ÷ 2
    axis_col = cols ÷ 2
    result[axis_lin-1:axis_lin+1, :] .= RGBA(0, 1, 0, 1)
    result[:, axis_col-1:axis_col+1] .= RGBA(1, 0, 0, 1)
    return result
end

# ╔═╡ 55898e88-36a0-4f49-897f-e0850bd2b0df
img = if show_grid
    with_gridlines(img_original)
else
    img_original
end;

# ╔═╡ 8e0505be-359b-4459-9de3-f87ec7b60c23
transform_image(T, img)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ColorVectorSpace = "c3611d14-8923-5661-9e6a-0046d554d3a4"
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
ImageIO = "82e4d734-157c-48bb-816b-45c225c6df19"
ImageShow = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PNGFiles = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[compat]
ColorVectorSpace = "~0.10.0"
Colors = "~0.12.10"
FileIO = "~1.16.3"
ForwardDiff = "~0.10.36"
HypertextLiteral = "~0.9.5"
ImageIO = "~0.6.7"
ImageShow = "~0.3.8"
PNGFiles = "~0.4.3"
PlutoUI = "~0.7.58"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.8"
manifest_format = "2.0"
project_hash = "bcf41f73774925fba93228f48340e462a3596512"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "16351be62963a67ac4083f748fdb3cca58bfd52f"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.7"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CEnum]]
git-tree-sha1 = "389ad5c84de1ae7cf0e28e381131c98ea87d54fc"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.5.0"

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

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

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

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "2dd20384bf8c6d411b5c7370865b1e9b26cb2ea3"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.6"

    [deps.FileIO.extensions]
    HTTPExt = "HTTP"

    [deps.FileIO.weakdeps]
    HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "a2df1b776752e3f344e5116c06d75a10436ab853"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.38"

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

    [deps.ForwardDiff.weakdeps]
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.Giflib_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6570366d757b50fabae9f4315ad74d2e40c0560a"
uuid = "59f7168a-df46-5410-90c8-f2779963d0ec"
version = "5.2.3+0"

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
git-tree-sha1 = "e12629406c6c4442539436581041d372d69c55ba"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.12"

[[deps.ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "eb49b82c172811fd2c86759fa0553a2221feb909"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.7"

[[deps.ImageCore]]
deps = ["ColorVectorSpace", "Colors", "FixedPointNumbers", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "PrecompileTools", "Reexport"]
git-tree-sha1 = "8c193230235bbcee22c8066b0374f63b5683c2d3"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.10.5"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs", "WebP"]
git-tree-sha1 = "696144904b76e1ca433b886b4e7edd067d76cbf7"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.9"

[[deps.ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "2a81c3897be6fbcde0802a0ebe6796d0562f63ec"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.10"

[[deps.ImageShow]]
deps = ["Base64", "ColorSchemes", "FileIO", "ImageBase", "ImageCore", "OffsetArrays", "StackViews"]
git-tree-sha1 = "3b5344bcdbdc11ad58f3b1956709b5b9345355de"
uuid = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
version = "0.3.8"

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

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IntervalSets]]
git-tree-sha1 = "dba9ddf07f77f60450fe5d2e2beb9854d9a49bd0"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.10"

    [deps.IntervalSets.extensions]
    IntervalSetsRandomExt = "Random"
    IntervalSetsRecipesBaseExt = "RecipesBase"
    IntervalSetsStatisticsExt = "Statistics"

    [deps.IntervalSets.weakdeps]
    Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.IrrationalConstants]]
git-tree-sha1 = "e2222959fbc6c19554dc15174c81bf7bf3aa691c"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.4"

[[deps.IterTools]]
git-tree-sha1 = "42d5f897009e7ff2cf88db414a389e5ed1bdd023"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.10.0"

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
git-tree-sha1 = "fa6d0bcff8583bac20f1ffa708c3913ca605c611"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.5"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "eac1206917768cb54957c65a615460d87b455fc1"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.1.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aaafe88dccbd957a8d82f7d05be9b69172e0cee3"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.0.1+0"

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

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll"]
git-tree-sha1 = "8be878062e0ffa2c3f67bb58a595375eda5de80b"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.11.0+0"

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

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "4ab7581296671007fc33f07a721631b8855f4b1d"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.1+0"

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

[[deps.MIMEs]]
git-tree-sha1 = "1833212fd6f580c20d4291da9c1b4e8a655b128e"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.0.0"

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

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

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
git-tree-sha1 = "cc0a5deefdb12ab3a096f00a6d42133af4560d71"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.2"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore", "ImageMetadata"]
git-tree-sha1 = "d92b107dbb887293622df7697a2223f9f8176fcd"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.1.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
git-tree-sha1 = "5e1897147d1ff8d98883cda2be2187dcf57d8f0c"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.15.0"

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

    [deps.OffsetArrays.weakdeps]
    Adapt = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"

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

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "cc4054e898b852042d7b503313f7ad03de99c3dd"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.0"

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

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f9501cc0430a26bc3d156ae1b5b0c1b47af4d6da"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.3"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "7e71a55b87222942f0f9337be62e26b1f103d3e4"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.61"

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
git-tree-sha1 = "8f6bc219586aef8baf0ff9a5fe16ee9c70cb65e4"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.10.2"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "8b3fc30bc0390abdce15f8822c889f669baed73d"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.1"

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

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMD]]
deps = ["PrecompileTools"]
git-tree-sha1 = "fea870727142270bdf7624ad675901a1ee3b4c87"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.7.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "2da10356e31327c7096832eb9cd86307a50b1eb6"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "64cca0c26b4f31ba18f13f6c12af7c85f478cfde"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.5.0"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.StaticArraysCore]]
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

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
git-tree-sha1 = "f21231b166166bebc73b99cea236071eb047525b"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "6cae795a5a9313bbb4f60683f7263318fc7d1505"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.10"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WebP]]
deps = ["CEnum", "ColorTypes", "FileIO", "FixedPointNumbers", "ImageCore", "libwebp_jll"]
git-tree-sha1 = "aa1ca3c47f119fbdae8770c29820e5e6119b83f2"
uuid = "e3aaa7dc-3e4b-44e0-be63-ffb868ccd7c1"
version = "0.1.3"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "ee6f41aac16f6c9a8cab34e2f7a200418b1cc1e3"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.6+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "7d1671acbe47ac88e981868a078bd6b4e27c5191"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.42+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "56c6604ec8b2d82cc4cfe01aa03b00426aac7e1f"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.6.4+1"

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

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6dba04dbfb72ae3ebe5418ba33d087ba8aa8cb00"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.1+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "622cf78670d067c738667aaa96c553430b65e269"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "055a96774f383318750a1a5e10fd4151f04c29c5"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.46+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "libpng_jll"]
git-tree-sha1 = "c1733e347283df07689d71d61e14be986e49e47a"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.5+0"

[[deps.libwebp_jll]]
deps = ["Artifacts", "Giflib_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libglvnd_jll", "Libtiff_jll", "libpng_jll"]
git-tree-sha1 = "d2408cac540942921e7bd77272c32e58c33d8a77"
uuid = "c5f90fcd-3b7e-5836-afba-fc50a0988cb2"
version = "1.5.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─440d3d97-4b81-4a55-add1-2dcf87089ef2
# ╟─b7895bd2-7634-11eb-211e-ef876d23bd88
# ╟─e6a09409-f262-453b-a434-bfd935306719
# ╠═6b473b2d-4326-46b4-af38-07b61de287fc
# ╟─d49682ff-d529-4283-871b-f8ee50a4e6ee
# ╟─58a520ca-763b-11eb-21f4-3f27aafbc498
# ╟─2cca0638-7635-11eb-3b60-db3fabe6f536
# ╟─c8a3b5b4-76ac-11eb-14f0-abb7a33b104d
# ╟─db56bcda-76aa-11eb-2447-5d9076789244
# ╠═539aeec8-76ab-11eb-32a3-95c6672a0ea9
# ╠═81a00b78-76ab-11eb-072a-6b96847c2ce4
# ╠═2369fb18-76ab-11eb-1189-85309c8f925b
# ╠═98498f84-76ab-11eb-23cf-857c776a9163
# ╠═c6c860a6-76ab-11eb-1dec-1b2f179a0fa9
# ╠═f07fbc6c-76ab-11eb-3382-87c7d65b4078
# ╠═f4fa8c1a-76ab-11eb-302d-bd410432e3cf
# ╟─b3faf4d8-76ac-11eb-0be9-7dda3d37aba0
# ╠═71c074f0-76ac-11eb-2164-c36381212bff
# ╠═87b99c8a-76ac-11eb-1c94-8f1ffe3be593
# ╟─504076fc-76ac-11eb-30c3-bfa75c991cb2
# ╟─f1dd24d8-76ac-11eb-1de7-a763a1b95668
# ╟─38b51946-76ae-11eb-2c8a-e19b30bf42cb
# ╟─632a1f8c-76ae-11eb-2088-15c3e3c0a210
# ╟─8a99f186-76af-11eb-031b-f1c288993c7f
# ╠═ca1dfb8a-76b0-11eb-1323-d100bdeedc2d
# ╟─fe01da74-76ac-11eb-12e3-8320340b6139
# ╠═d42aec08-76ad-11eb-361a-a1f2c90fd4ec
# ╠═06437040-76ae-11eb-0b1c-23a6470f41c8
# ╟─28cd454c-76ae-11eb-0d1e-a56995100d59
# ╟─f8a7e203-b2b9-480c-817f-e2d440881775
# ╟─f7df6cda-76b1-11eb-11e4-8d0af0349651
# ╟─63449b54-76b4-11eb-202f-3bda2f4cff4d
# ╠═8c6b0236-76b4-11eb-2acf-91da23bedf0e
# ╟─a397d526-76b5-11eb-3cce-4374e33324d1
# ╟─4a57d898-76b6-11eb-15ea-7be43393922c
# ╠═bf23ab30-76b5-11eb-1adb-3d74a52cddfd
# ╠═d5d4ac48-76b6-11eb-1687-ed853c2db7c9
# ╟─89b2d570-76ba-11eb-0389-813bbb33efea
# ╠═a8c28578-76ba-11eb-3f3f-af35ff0b6c74
# ╠═d9e07084-76ba-11eb-18ac-c58b1bc972ba
# ╟─42172fb6-76b7-11eb-0a11-b7e10c6881f5
# ╠═57b0cd3c-76b7-11eb-0ece-810f3a8ede00
# ╟─6d411cea-76b9-11eb-061b-87d472bc3bdd
# ╟─bc2c6afc-76b7-11eb-0631-51f83cd73205
# ╠═ef06cfd8-76b7-11eb-1530-1fcd7e5c5992
# ╟─051db7a0-76b8-11eb-14c7-531f42ef60b8
# ╟─5f1afd24-76b8-11eb-36ab-9bbb3d73b930
# ╠═2705bf34-76b8-11eb-3aaa-d363085784ff
# ╟─dfb9d74c-76b8-11eb-24ff-e521f1294a6f
# ╟─1049f458-76b9-11eb-1d2d-af0b22480121
# ╟─a0afe3ae-76b9-11eb-2301-cde7260ddd7f
# ╟─ac1ab224-76bb-11eb-13cb-0bd44bea1042
# ╟─bcf92688-76b9-11eb-30fb-1f320a65f45a
# ╠═d364f91a-76b9-11eb-1807-75e733940d53
# ╠═f25c6308-76b9-11eb-3563-1f0ef4cdf86a
# ╟─c9a148f0-76bb-11eb-0778-9d3e84369a19
# ╟─89f0bc54-76bb-11eb-271b-3190b4d8cbc0
# ╟─f70f7ea8-76b9-11eb-3bd7-87d40a2861b1
# ╠═78176284-76bc-11eb-3045-f584127f58b9
# ╟─bf28c388-76bd-11eb-08a7-af2671218017
# ╠═5655d2a6-76bd-11eb-3042-5b2dd3f6f44e
# ╠═852592d6-76bd-11eb-1265-5f200e39113d
# ╠═8e36f4a2-76bd-11eb-2fda-9d1424752812
# ╟─09ed6d38-76be-11eb-255b-3fbf76c21097
# ╠═9786e2be-76be-11eb-3755-b5669c37aa64
# ╟─963694d6-76be-11eb-1b27-d5d063964d24
# ╠═b78ef2fe-76be-11eb-1f55-3d0874b298e8
# ╟─ad728ee6-7639-11eb-0b23-c37f1366fb4e
# ╟─4d4e6b32-763b-11eb-3021-8bc61ac07eea
# ╟─c0c90fec-0e55-4be3-8ea2-88b8705ee258
# ╟─ce55beee-7643-11eb-04bc-b517703facff
# ╟─005ca75a-7622-11eb-2ba4-9f450e71df1f
# ╟─e04fa982-81fe-4f4e-bd2e-efb3392f246b
# ╟─683bfffd-906d-45fc-b442-496639fb09cd
# ╟─60532aa0-740c-11eb-0402-af8ff117f042
# ╠═8e0505be-359b-4459-9de3-f87ec7b60c23
# ╟─f085296d-48b1-4db6-bb87-db863bb54049
# ╟─d1757b2c-7400-11eb-1406-d937294d5388
# ╟─5227afd0-7641-11eb-0065-918cb8538d55
# ╟─2835e33a-7642-11eb-33fd-79fb8ad27fa7
# ╟─a66eb6fe-76b3-11eb-1d50-659ec2bf7c44
# ╟─b9dba026-76b3-11eb-1bfb-ffe9c43ced5d
# ╟─62b28c02-763a-11eb-1418-c1e30555b1fa
# ╟─c536dafb-4206-4689-ad6d-6935385d8fdf
# ╟─40655bcc-6d1e-4d1e-9726-41eab98d8472
# ╠═4fcb4ac1-1ad1-406e-8776-4675c0fdbb43
# ╠═55898e88-36a0-4f49-897f-e0850bd2b0df
# ╠═74fe3391-21f0-4ab9-a41a-6eca0d88f889
# ╠═cb1f80dd-ba4a-4176-b439-652529b8fd1a
# ╠═1726b965-acf6-4df5-83ef-8eb34308fc82
# ╠═83d45d42-7406-11eb-2a9c-e75efe62b12c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
