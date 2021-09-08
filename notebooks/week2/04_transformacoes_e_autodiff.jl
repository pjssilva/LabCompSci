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

# ╔═╡ d49682ff-d529-4283-871b-f8ee50a4e6ee
filter!(LOAD_PATH) do path
    path != "@v#.#"
end;

# ╔═╡ 2e8c4a48-d535-44ac-a1f1-4cb26c4aece6
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
PlutoUI.TableOfContents(aside = true)

# ╔═╡ e6a09409-f262-453b-a434-bfd935306719
md"""
#### Inicializando pacotes

_Ao executar esse notebook a primeira ele pode levar até 15 min, tenha paciência_
"""

# ╔═╡ 58a520ca-763b-11eb-21f4-3f27aafbc498
md"""
Da última vez nós definimos combinções lineares de imagens. Elas eram baseadas nas operações fundamentais:
* Multiplicar uma imagem por escalar (mudando a sua escala).
* Adicionar duas imagens através da soma das cores (e possível saturação).

Como vocês viram em álgebra linear ao fazermos essas duas operações ao mesmo tempo estamos criando um combinação linear. Na aula de hoje vamos partir do mesmo tipo de ideia para, mas focando em transformações lineares que são funções. Vamos usar o computador para nos ajudar a entendê-las.

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
Essas são as funções que aprendemos no ensino médio. Alguns exemplos:
* $f₁(x) = x^2$
* $f₂(x) = \sin(x)$
* $f₃(x) = x^\alpha$

Julia permite que definir esse tipo de funções simples em um formato curto ou em outro mais longo e adequado a funções mais complexas.
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
function f₃(x, α = 3) # Valor default
    return x^α      # O "return" é opcional
end

# ╔═╡ f07fbc6c-76ab-11eb-3382-87c7d65b4078
f₃(5)

# ╔═╡ f4fa8c1a-76ab-11eb-302d-bd410432e3cf
f₃(5, 2)

# ╔═╡ b3faf4d8-76ac-11eb-0be9-7dda3d37aba0
md"""
Argumentos com nomes (keywords)
"""

# ╔═╡ 71c074f0-76ac-11eb-2164-c36381212bff
f₄(x; α) = x^α

# ╔═╡ 87b99c8a-76ac-11eb-1c94-8f1ffe3be593
f₄(2, α = 5)

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

* Usar diferenças finitas seja progressiva ou centrada com os devidos cuidados para escolher a pertubação do ponto de partida.

* Implementar manualmente a fórmula da derivada.

A primeira opção sofre por não ser exata e tem a grande vantagem de ser simples de implementar. Já a segunda pode dar trabalho, dependendo de qual complexa for a função, e está propensa a erros. Muitas vezes usamos a primeira para verificar se não comentemos erros groesseiros na segunda.

Uma alternativa mais moderna é o uso de diferenciação automática. Nesse caso usamos um sistema que calcula automáticamente a função e a derivada, sem intervenção manual e sem erros numéricos. Uma boa biblioteca de diferenciação automática ainda faz isso com cuidado de não impor uma grande penalidade no tempo de execução. De fato, especialmente para funções com muitos parâmtros, a tendência é que a implementação automática seja bem mais eficiente que uma implementação manual simples.

Em Julia uma biblioteca com esse tipo de funcionalidade é a `ForwardDiff`. Vamos vê-la em ação inicialmente para funções de um único parâmetro.
"""

# ╔═╡ d42aec08-76ad-11eb-361a-a1f2c90fd4ec
ForwardDiff.derivative(f₁, 5)

# ╔═╡ 06437040-76ae-11eb-0b1c-23a6470f41c8
ForwardDiff.derivative(x -> f₃(x, 2), 5)

# ╔═╡ 28cd454c-76ae-11eb-0d1e-a56995100d59
md"""
Observe que usamos uma função anônima para fixar o parâmetro α=3 e criar uma nova função que de fato depende de um único parâmetro.

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
### Funções escalres de várias variáveis
"""

# ╔═╡ 63449b54-76b4-11eb-202f-3bda2f4cff4d
md"""
Muitas vezes estamos interessandos em usar funções a valores escalares mas que dependem de múltiplas variáveis. Em Julia vocẽ pode definir esse tipo de função recebendo um vetor ou recebendo as múltiplas variáveis:
e.g. $f_5(x) = 5\sin(x_1*x_2) + 2x_2/4x_3$.

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
Melhor ainda, você pode escrever a função uma única vez e definir a outra versão em função da primeira, ervitando re-escrever o código. Isso é sempre uma boa prática. Assim se você ajustar a definição da função ela já estará ajustada na segunda versão.
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
Julia também tem um "truque" que permite que você escreva uma função com um número predefinido de argumentos mas recebendo um vetor. Para isso usamos um tupla de elementos como argumento que é usada para "deconstruir" o vetor de entrada.

Uma das vantagens dessa forma é que torna possível criar funções que recebem vetores mais legíveis quando o número de elementos do vetor é predeterminado e pequeno.
"""

# ╔═╡ a8c28578-76ba-11eb-3f3f-af35ff0b6c74
f₇((x, y, z)) = 5sin(x * y) + 2y / 4z # more readable than 5sin(v[1]*v[2]) + 2*v[2]/4v[3]

# ╔═╡ d9e07084-76ba-11eb-18ac-c58b1bc972ba
f₇([1, 2, 3]) # this works with vector arguments, but not scalars (f₇(1,2,3) error)

# ╔═╡ 42172fb6-76b7-11eb-0a11-b7e10c6881f5
md"""
Lembrando, na prática as funções $f_5$ e $f_6$ têm dois métodos definidos distintos. Um que receve um único argumento e outro que recebe três. Já $f_7$ tem um método apenas, que recebe um único argumento.

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
Em muitas aplicações, como em apredizagem de máquina, é comum termos que otimizar funções escalare de várias variáveis. Nesse caso o métodos de otimização tipicamente dependem da capacidade de se calcular as derivadas da função que são capturadas na noção de **gradiente**. Mais uma vez podemos usar a diferenciação automática para fazer isso por nós:
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
Lembrem que a fórmula acima é bastante natural se lembrando o que é uma derivada parcial. Nela mantemos todas as variáveis menos uma fixa e imaginamos que estamos derivando a função obtida por permite a mudança dessa única variável.
"""

# ╔═╡ 1049f458-76b9-11eb-1d2d-af0b22480121
md"""
**Important Remark**: Em aprendizagem de máquina, e outros problemas de otimização modernos, é comum se querer minimizar uma função escalar que depende de um número muito grande de variáveis. Nesse contexto, o uso de métodos baseados em seguir a direção de menos o gradiente é comum. Caso o número de variáveis seja pequeno há certamente métodos mais rápidos como o método de Newton que usa informação de derivada segunda. Lembre que a derivada segunda nesse caso é uma matriz. Se o número de variáveis for muito grande pode ser até mesmo impossível armazenar a matriz inteira na memória. Ela é um objeto com tamanho proporcional ao quadrado do número de variáveis.
"""

# ╔═╡ a0afe3ae-76b9-11eb-2301-cde7260ddd7f
md"""
### Mais transformações: Funções de múltiplas variáveis a valores vetoriais
"""

# ╔═╡ ac1ab224-76bb-11eb-13cb-0bd44bea1042
md"""
Em alguns contextos usamos o nome "transformação" para funções que múltiplas variáveis que também devolvem múltiplos valores, ou seja vetores.
"""

# ╔═╡ bcf92688-76b9-11eb-30fb-1f320a65f45a
md"""
Vamos definir algumas funções simples que recebem vetores bidikmensionais e devolvem também vetores bidmensionais.
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
Imagino que você notou que todas essas funções podems er definidas com matrizes, já que são lineares. De fato o caso geral é o último, ou seja:
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
Em uma primeira leitura, a função "warp" parece meio sofisticada, mas ela nada mais uma do que uma rotação cujo ângulo de rotação aumenta a medida que nos afastamos da origem.

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

No ensino médio aprendemos a multiplicar duas matrizes ou multiplicar matrizes por vetores sem uma compreensão clara do significado da fórmula. Como é uma fórmula complexa e com várias contas repetidas, os computadores são ótimos para executar essa tarefa. Para que então ensinam humanos a fazer isso sem uma justificativa clara?
"""

# ╔═╡ 4d4e6b32-763b-11eb-3021-8bc61ac07eea
md"""
Mas vocês já fizeram Álgebra Linear e lá aprenderam que matrizes são representações de transformações linear. Nesse contexto, multiplicar uma matriz por um vetor calcula o resultado da transformação sobre aquele vetor de entrada. Já a multiplicação de matrizes nada mais é do que a forma natural de se obter a matriz da transformação composta.
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

    	**Executando essa célula redifine a matriz para a identidade**
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

... mas matemáticos não tem problemas com a ideia de dimensão geral $n$, uma vez que entendemos essa apenas como novos graus de liberdade e vemos que boa parte da intuição que vem do espaço se transporta para o caso de dimensões mais altas. É claro que que algo também se perde, mas mesmo isso pode ser a dica de um fenômenos interessante que merece ser compreendido.
"""

# ╔═╡ c536dafb-4206-4689-ad6d-6935385d8fdf
md"""
## Apêndice
"""

# ╔═╡ 40655bcc-6d1e-4d1e-9726-41eab98d8472
img_sources = [
    "https://www.ime.unicamp.br/~pjssilva/images/ensino/labcompsci/carmel-arquelau-bV3RXy9Upqg-unsplash.png" =>
        "Tucano",
    "https://www.ime.unicamp.br/~pjssilva/images/ensino/labcompsci/matt-paul-catalano-MUwfuO5RXEo-unsplash.png" =>
        "Onda",
    "https://user-images.githubusercontent.com/6933510/108883855-39690f80-7606-11eb-8eb1-e595c6c8d829.png" =>
        "Setas",
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
function with_gridlines(img::Matrix; n = 10)
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
ColorVectorSpace = "~0.9.5"
Colors = "~0.12.8"
FileIO = "~1.10.1"
ForwardDiff = "~0.10.19"
HypertextLiteral = "~0.9.0"
ImageIO = "~0.5.6"
ImageShow = "~0.3.2"
PNGFiles = "~0.3.7"
PlutoUI = "~0.7.9"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "bdc0937269321858ab2a4f288486cb258b9a0af7"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.3.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "42a9b08d3f2f951c9b283ea427d96ed9f1f30343"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.5"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "344f143fa0ec67e47917848795ab19c6a455f32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.32.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[DiffResults]]
deps = ["StaticArrays"]
git-tree-sha1 = "c18e98cba888c6c25d1c3b048e4b3380ca956805"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.0.3"

[[DiffRules]]
deps = ["NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "85d2d9e2524da988bffaf2a381864e20d2dae08d"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.2.1"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "256d8e6188f3f1ebfa1a5d17e072a0efafa8c5bf"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.10.1"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "NaNMath", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "b5e930ac60b613ef3406da6d4f42c35d8dc51419"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.19"

[[Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "2c1cf4df419938ece72de17f368a021ee162762e"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.0"

[[HypertextLiteral]]
git-tree-sha1 = "72053798e1be56026b81d4e2682dbe58922e5ec9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.0"

[[ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "5d19b6f294625fc59dba19ed744c81fca5667dac"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.2"

[[ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "75f7fea2b3601b58f24ee83617b528e57160cbfd"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.1"

[[ImageIO]]
deps = ["FileIO", "Netpbm", "PNGFiles", "TiffImages", "UUIDs"]
git-tree-sha1 = "d067570b4d4870a942b19d9ceacaea4fb39b69a1"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.5.6"

[[ImageShow]]
deps = ["Base64", "FileIO", "ImageBase", "ImageCore", "OffsetArrays", "StackViews"]
git-tree-sha1 = "e439b5a4e8676da8a29da0b7d2b498f2db6dbce3"
uuid = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
version = "0.3.2"

[[IndirectArrays]]
git-tree-sha1 = "c2a145a145dc03a7620af1444e0264ef907bd44f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "0.5.1"

[[Inflate]]
git-tree-sha1 = "f5fc07d4e706b84f72d54eedcc1c13d92fb0871c"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[IrrationalConstants]]
git-tree-sha1 = "f76424439413893a832026ca355fe273e93bce94"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "3d682c07e6dd250ed082f883dc88aee7996bf2cc"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.0"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "0fb723cd8c45858c22169b2e42269e53271a6df7"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.7"

[[MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "b34e3bc3ca7c94914418637cb10cc4d1d80d877d"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.3"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[Netpbm]]
deps = ["FileIO", "ImageCore"]
git-tree-sha1 = "18efc06f6ec36a8b801b23f076e3c6ac7c3bf153"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.2"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "c0f4a4836e5f3e0763243b8324200af6d0e0f90c"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.5"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "520e28d4026d16dcf7b8c8140a3041f0e20a9ca8"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.7"

[[PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "646eed6f6a5d8df6708f15ea7e02a7a2c4fe4800"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.10"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "477bf42b4d1496b454c10cce46645bb5b8a0cf2c"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.2"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "a7a7e1a88853564e551e4eba8650f8c38df79b37"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.1.1"

[[PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "44e225d5837e2a2345e69a1d1e01ac2443ff9fcb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.9"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "afadeba63d90ff223a6a48d2009434ecee2ec9e8"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.1"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "5f6c21241f0f655da3952fd60aa18477cf96c220"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.1.0"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "LogExpFunctions", "OpenSpecFun_jll"]
git-tree-sha1 = "a322a9493e49c5f3a10b50df3aedaf1cdb3244b7"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.6.1"

[[StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3240808c6d463ac46f1c1cd7638375cd22abbccb"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.12"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[Suppressor]]
git-tree-sha1 = "a819d77f31f83e5792a76081eee1ea6342ab8787"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.0"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TiffImages]]
deps = ["ColorTypes", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "OffsetArrays", "OrderedCollections", "PkgVersion", "ProgressMeter"]
git-tree-sha1 = "03fb246ac6e6b7cb7abac3b3302447d55b43270e"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.4.1"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
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
# ╠═f8a7e203-b2b9-480c-817f-e2d440881775
# ╟─f7df6cda-76b1-11eb-11e4-8d0af0349651
# ╟─63449b54-76b4-11eb-202f-3bda2f4cff4d
# ╠═8c6b0236-76b4-11eb-2acf-91da23bedf0e
# ╟─a397d526-76b5-11eb-3cce-4374e33324d1
# ╟─4a57d898-76b6-11eb-15ea-7be43393922c
# ╠═bf23ab30-76b5-11eb-1adb-3d74a52cddfd
# ╠═d5d4ac48-76b6-11eb-1687-ed853c2db7c9
# ╠═89b2d570-76ba-11eb-0389-813bbb33efea
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
# ╠═2e8c4a48-d535-44ac-a1f1-4cb26c4aece6
# ╟─c0c90fec-0e55-4be3-8ea2-88b8705ee258
# ╠═ce55beee-7643-11eb-04bc-b517703facff
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
