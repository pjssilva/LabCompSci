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

# ╔═╡ 230cba36-9d0a-4726-9e55-7df2c6743968
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
    using PlutoUI
    using Colors, ColorVectorSpace, ImageShow, FileIO
    using PlutoUI
    using HypertextLiteral
    using LinearAlgebra
    using ForwardDiff
    using NonlinearSolve
    using StaticArrays
    using BenchmarkTools
end

# ╔═╡ b7895bd2-7634-11eb-211e-ef876d23bd88
PlutoUI.TableOfContents(aside = true)

# ╔═╡ 230b0118-30b7-4035-ad31-520165a76fcc
md"""
#### Inicialização de pacotes

_Quando você executar esse caderno pela primeira vez ele irá instalr pacotes. Isso pode demorar até 15 minutos. Aguente firme!_
"""

# ╔═╡ 890d30b9-2cd0-4d3a-99f6-f7d3d7858fda
img_sources = [
    "https://www.ime.unicamp.br/~pjssilva/images/ensino/labcompsci/carmel-arquelau-bV3RXy9Upqg-unsplash.png" =>
        "Tucano",
    "https://www.ime.unicamp.br/~pjssilva/images/ensino/labcompsci/matt-paul-catalano-MUwfuO5RXEo-unsplash.png" =>
        "Onda",
    "https://www.ime.unicamp.br/~pjssilva/images/ensino/labcompsci/matt-paul-catalano-MUwfuO5RXEo-unsplash_square.png" =>
        "Onda quadrada",
    "https://user-images.githubusercontent.com/6933510/108883855-39690f80-7606-11eb-8eb1-e595c6c8d829.png" =>
        "Setas",
]

# ╔═╡ 85fba8fb-a9ea-444d-831b-ec6489b58b4f
md"""
#### Escolha uma imagem:

$(@bind img_source Select(img_sources))

Imagem do tucano de [Carmel Arquelau](https://unsplash.com/@kkpsi?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) em [Unsplash](https://unsplash.com/s/photos/toucan?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText).

Imagem onda de [Matt Paul Catalano](https://unsplash.com/@mattpaul?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) em [Unsplash](https://unsplash.com/s/photos/wave?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText).
"""

# ╔═╡ 96766502-7a06-11eb-00cc-29849773dbcf
img_original = load(download(img_source))

# ╔═╡ 26dd0e98-7a75-11eb-2196-5d7bda201b19
md"""
Após você selecionar a sua imagem, pode ser interessante mover essa célula para o topo da janela do navegador par fter you select your image, we suggest moving this line above just above the top of your browser.

---------------
"""

# ╔═╡ e0b657ce-7a03-11eb-1f9d-f32168cb5394
md"""
#  Um pouco de diversão: brincando com transformações
"""

# ╔═╡ ab2fd438-b384-401f-a5d0-5a58c23e54ed
begin
    transfs_names = [
        "Id",
        "Rotate(α)",
        "Shear(α)",
        "Linear",
        "Nonlinear shear(α)",
        "Warp(α)",
        "xy",
        "rθ",
        "Custom",
    ]
    md"""
    #### Escolha uma transformação inversa:

    $(@bind transf Select(transfs_names))
    """
end

# ╔═╡ 23ade8ee-7a09-11eb-0e40-296c6b831d74
md"""
Escolha uma transformação [linear](#a0afe3ae-76b9-11eb-2301-cde7260ddd7f) ou 
[não-linear](#a290d5e2-7a02-11eb-37db-41bf86b1f3b3), ou [crie a sua](f2c1671b-3f72-47e9-8eef-d6f1b33f05fa)!
"""

# ╔═╡ 005ca75a-7622-11eb-2ba4-9f450e71df1f
let

    range = -1.5:0.1:1.5
    md"""

    Essa é matriz "variável": clique e arraste para mudar!

    **A =**

    ``(``
     $(@bind a Scrubbable( range; default=1.0))
     $(@bind b Scrubbable( range; default=0.0))
    ``)``

    ``(``
    $(@bind c Scrubbable(range; default=0.0 ))
    $(@bind d Scrubbable(range; default=1.0))
    ``)``
    """
end

# ╔═╡ 2efaa336-7630-11eb-0c17-a7d4a0141dac
md"""
zoom = $(@bind  z Scrubbable(.1:.1:3,  default=1))
"""

# ╔═╡ 7f28ac40-7914-11eb-1403-b7bec34aeb94
md"""
pan = [$(@bind panx Scrubbable(-1:.1:1, default=0)),
$(@bind pany Scrubbable(-1:.1:1, default=0)) ]
"""

# ╔═╡ ce55beee-7643-11eb-04bc-b517703facff
md"""
α= $(@bind α Slider(-30:.1:30, show_value=true, default=0))
β= $(@bind β Slider(-10:.1:10, show_value=true, default = 5))
h= $(@bind h Slider(.1:.1:10, show_value=true, default = 5))
"""

# ╔═╡ f2c1671b-3f72-47e9-8eef-d6f1b33f05fa
# custom = ((x, y),) -> [x, α*y^2]
custom = ((x, y),) -> [sin(α * x), y]
# custom = ((x, y),)-> [x + α*y^2, y + α*x^2] # may be non-invertible
# custom  = flipy ∘ ((x, y),) ->  [(β*x - α*y)/(β - y), -h*y/(β - y)]
# custom = ((x, y),) -> [log(x + 1.2), log(y + 1.2)] # Exponentialish
# custom = ((x, y),) -> [ log(x^2 + y^2 + 1.2)/2, atan(y, x) ] # (reim(log(complex(y,x)) ))
# custom = inverse( nonlin_shear(α) )

# ╔═╡ 5d33f6ea-7e9c-11eb-2fb3-dbb7cb07c60c
md"""
pixels = $(@bind pixels Slider(1:1000, default=800, show_value=true))
"""

# ╔═╡ 45dccdec-7912-11eb-01b4-a97e30344f39
md"""
Show grid lines $(@bind show_grid CheckBox(default=true))
ngrid = $(@bind ngrid Slider(5:5:20, show_value=true, default = 10))
"""

# ╔═╡ d2fb356e-7f32-11eb-177d-4f47d6c9e59b
md"""
Circular Frame $(@bind circular CheckBox(default=true))
radius = $(@bind r Slider(.1:.1:1, show_value=true, default = 1))
"""

# ╔═╡ 55b5fc92-7a76-11eb-3fba-854c65eb87f9
md"""
A imagem original é levada em [-1,1] x [-1 1] e depois transformada.
"""

# ╔═╡ 85686412-7a75-11eb-3d83-9f2f8a3c5509
A = [a b; c d];

# ╔═╡ a7df7346-79f8-11eb-1de6-71f027c46643
md"""
## Estratégia de ensino: porque o primeiro módulo foca em processamento de imagens?

Processamente de imagens é uma ótima forma aprender Julia, um pouco de álgebra linear e matemática não-linear. Mas não se engane, esse não é um curso de processamento de imagens. Acreditamos, porém, que alguma ideias aqui podem ser usadas como ponto de partida para aprender mais. E é muito divertido brincar com imagens devido ao feedback instantâneo que usa nossa enorme capacidade processamento visual.
"""

# ╔═╡ 044e6128-79fe-11eb-18c1-395ae857dc73
md"""
# Relembrando a última aula
"""

# ╔═╡ 78d61e28-79f9-11eb-0605-e77d206cda84
md"""
## Uma pergunta interessante:

Levar linhas em linhas é suficiente para a transformação ser linear?

Resposta = **não**!

Um exemplo é uma perspectiva que leva linhas em linhas mas paralelogramos não são mais levados em palelogramos.
"""

# ╔═╡ aad4d6e4-79f9-11eb-0342-b900a41cfbaf
md"""
[Uma demostrantação iterativa de perspectivca](https://www.khanacademy.org/humanities/renaissance-reformation/early-renaissance1/beginners-renaissance-florence/a/linear-perspective-interactive) disponível na  Khan academy. (Possivelmente você precisa estar desconectar do Khan Academy se o usa em português.)
"""

# ╔═╡ d42aec08-76ad-11eb-361a-a1f2c90fd4ec
Resource(
    "https://cdn.kastatic.org/ka-perseus-images/1b351a3653c1a12f713ec24f443a95516f916136.jpg",
)

# ╔═╡ e965cf5e-79fd-11eb-201d-695b54d08e54
md"""
## Relembrando dicas de estilo em Julia: definindo funções com argumentos vetoriais
"""

# ╔═╡ 1e11c1ec-79fe-11eb-1867-9da72b3f3bc4
md"""
Muitas pessoas se atrapalhan ao ler algo como


`f(v) = [ v[1] + v[2], v[1] - v[2] ]  ` ou
`  f = v ->  [ v[1] + v[2], v[1] - v[2] ]  `

e preferem usar os velhos e bons nomes `x` e `y`:

`f((x, y)) = [ x + y, x - y ] ` or
` f = ((x, y),) -> [ x + y, x - y ] `.

Qualquer uma dessas formas vai levar um ponto no plano em outro ponto no plano. Isto é, qualquer uma dessas forma nos permite avaliar depois `f([1, 2])`.

As formas que usam o operador `->` (eu o leio "leva a") são funções anônimas, mesmo que logo depois já as atribuímos a uma varíavel, nomeando-a. Um teste interessante é ver a diferença que existe entre `methods(f)` em que `f` é uma função "de início" ou uma variável que recebeu uma função anônima.
"""

# ╔═╡ 28ef451c-7aa1-11eb-340c-ab3a1193a3c4
md"""
## Funções com parâmetros

Funções anônimas são úteis quando queremos gerar rapidamente um `fechamento` (do inglês `closure`), ou seja uma função que depende do valor de um **parâmetro** no momento de sua criação. Por exemplo,

`f(α) = ((x,y),) -> [x + α*y, x - α*y]`

é na verdade uma fábrica de funções que são definidas de acordo com o parâmetro α repassado. Por exemplo tente rodar `f(7)([1, 2])` e, depois, `f(3)([1, 2])`.

Num primeiro momento isso não parece grande coisa, mas lembre que essa função pode ser atribuída a outra variável, passada como argumento para outra função, ou retornada da chamada de uma função. Em todos esses casos ela irá lembrar do valor de α usando no momento de sua criação.
"""

# ╔═╡ a0afe3ae-76b9-11eb-2301-cde7260ddd7f
md"""
# Uma coleção de transformações lineares (usada acima)
"""

# ╔═╡ fc2deb7c-7aa1-11eb-019f-d3e3c80b9ff1
md"""
Aque estão algumas transformações lineares:
"""

# ╔═╡ d364f91a-76b9-11eb-1807-75e733940d53
begin
    id((x, y)) = SA[x, y]
    scalex(α) = ((x, y),) -> SA[α*x, y]
    scaley(α) = ((x, y),) -> SA[x, α*y]
    scale(α) = ((x, y),) -> SA[α*x, α*y]
    swap((x, y)) = SA[y, x]
    flipy((x, y)) = SA[x, -y]
    rotate(θ) = ((x, y),) -> SA[cos(θ)*x+sin(θ)*y, -sin(θ)*x+cos(θ)*y]
    shear(α) = ((x, y),) -> SA[x+α*y, y]
end

# ╔═╡ 080d87e0-7aa2-11eb-18f5-2fb6a7a5bcb4
md"""
De fato podemos escrever uma transformação linear *geral* de duas formas:
"""

# ╔═╡ 15283aba-7aa2-11eb-389c-e9f215bd03e2
begin
    lin(a, b, c, d) = ((x, y),) -> (a * x + b * y, c * x + d * y)

    lin(A) = v -> A * v  # linear algebra version using matrix multiplication
end

# ╔═╡ 2612d2c2-7aa2-11eb-085a-1f27b6174995
md"""
A segunda versão usa a notação de matrizes de álgebra linear, que é exatamente igual ao apresentado na primeira versão para

$$A = \begin{bmatrix} a & b \\ c & d \end{bmatrix}$$
"""

# ╔═╡ bf1fcb80-2a85-4b75-a8cf-a66fa6ab2744
md"""Vocês notaram o uso do `SA` na frente dos arrays acima? Isso vem do pacote `StaticArrays` que permite criar arrays estáticos (cujo tamanho é fixo e não pode mudar) em Julia. Arrays estáticos pequenos são muito mais rápidos do que os arrays padrão em Julia, mas demandam mais do compilador, pois precisam de código muito otimzado. Assim, se você vai usar arrays pequenos com tamanho fixo, essa pode ser uma forma simples de ganhar tempo extra. Veja:
"""

# ╔═╡ 1943078d-9524-4cb6-ab66-9d069081b532
begin
    M1 = [1 2; 3 4]
    v1 = [1, 2]
    @benchmark $M1 * $v1
end

# ╔═╡ 2c2eafb8-a3f4-4225-8432-4628a9da40db
begin
    M2 = SA[1 2; 3 4]
    v2 = SA[1, 2]
    @benchmark $M2 * $v2
end

# ╔═╡ 11cd57f1-e83e-4f17-825d-ac5a9f5f6a97
# Se precisar de arrays que podem mudar seus valores use "Mutable" Arrays
begin
    M3 = MMatrix{2,2}(1, 3, 2, 4)    # Valores por coluna
    v3 = MVector{2}(1, 2)
    @benchmark $M3 * $v3
end

# ╔═╡ 507c9f1f-503a-415a-9881-e5e19dde3b98
typeof(M1), typeof(M2), typeof(M3)

# ╔═╡ a290d5e2-7a02-11eb-37db-41bf86b1f3b3
md"""
# Uma coleção de transformações não lineares
"""

# ╔═╡ b4cdd412-7a02-11eb-149a-df1888a0f465
begin
    translate(α, β) = ((x, y),) -> SA[x+α, y+β]   # affine, but not linear

    nonlin_shear(α) = ((x, y),) -> SA[x, y+α*x^2]

    function warp(α)
        function fwarp((x, y))
            θ = α * √(x^2 + y^2)
            return SA[cos(θ)*x+sin(θ)*y, -sin(θ)*x+cos(θ)*y]
        end
        return fwarp
    end

    xy((r, θ)) = SA[r*cos(θ), r*sin(θ)]
    rθ(x) = SA[norm(x), atan(x[2], x[1])]
end

# ╔═╡ 74bd4232-5255-441d-bd28-f3fe7d706e20
transfs = Dict(
    "Id" => id,
    "Rotate(α)" => rotate(α),
    "Shear(α)" => shear(α),
    "Linear" => lin(A),
    "Nonlinear shear(α)" => nonlin_shear(α),
    "Warp(α)" => warp(α),
    "xy" => xy,
    "rθ" => rθ,
    "Custom" => custom,
)

# ╔═╡ 58a30e54-7a08-11eb-1c57-dfef0000255f
T⁻¹ = transfs[transf]

# ╔═╡ 4a2404d5-6894-4f78-a295-0e26156e544d
md"""
Por outro lado, vejamos como podemos redefinir a função warp, que vimos acima, usando a ideia de fechamentos com funções anônimas. Temos as seguintes opções:
"""

# ╔═╡ 3d28ce92-6c12-4143-9f53-3634bbc687ce
begin
    warp₂(α, x, y) = rotate(α * √(x^2 + y^2))
    warp₂(α) = ((x, y),) -> warp₂(α, x, y)([x, y])
end

# ╔═╡ 3460ad26-daeb-4e9c-9c75-1e00e43d592d
warp₃(α) = ((x, y),) -> rotate(α * √(x^2 + y^2))([x, y])

# ╔═╡ a05a2667-ed48-4610-bc4d-bff0317788ef
md"Vejamos que são todas equivalentes:"

# ╔═╡ 2b50dc4e-6549-4640-922d-c1c15bb82d7c
begin
    test_v = rand(2)
    warp(1)(test_v), warp₂(1)(test_v), warp₃(1)(test_v)
end

# ╔═╡ 46898e66-8d95-43bd-83f6-6806e3c1ead7
md"""Note, porém, que do ponto de vista de execução as últimas duas versões são bem diferentes da primeira. Elas criam uma função anônima nova para calcular o warp a cada chamada, enquanto a original cria apenas uma função para cada α fixo. Vejamos o impacto disso no temo de execução.
"""

# ╔═╡ 069988e7-1262-47b6-b399-a464bdcab21b
@benchmark warp(1)($test_v)

# ╔═╡ be3dabd6-2c7e-416f-92d3-44a7cee36f8b
@benchmark warp₂(1)($test_v)

# ╔═╡ de1cfad9-8dae-42e0-b9bb-2e0eb5a03968
@benchmark warp₃(1)($test_v)

# ╔═╡ 704a87ec-7a1e-11eb-3964-e102357a4d1f
md"""
# Composição
"""

# ╔═╡ 44792484-7a20-11eb-1c09-95b27b08bd34
md"""
## Composição de funções em Matemática
[Wikipedia (math) ](https://en.wikipedia.org/wiki/Function_composition)

Em matemática usamos *composição* para criar novas funções: a função que pega $x$ e leva em $\sin(\cos(x))$ é a composição das funções seno e cosseno.

Já nós, seres humanos, tendemos em misturar os conceitos da função seno e do seu valor calculado em um $x$ partitular. Mas a função seno é um objeto em si, que pode ser avaliado em diferentes argumentos $x$. Em algum sentido o mesmo ocorre com muitas liguagens de programação. Eles conseguem naturalmente escrever

```sin(cos(x))```

mas isso não define a função composta, apenas calcula o seu valor para um argumento em particular.

Por outro lado, Julia possui um operador para definir novas funções a partir de outras fazendo a composição. E, já que podemos usar caracters Unicode, isso é feito com o operador "bola" (∘), exatemente como na matemática. Ou seja, em Julia se escrevemos

```sin∘cos```

estamos definindo uma nova função que por sua vez pode avaliada em um `x` qualquer, por `(sin∘cos)(x)`. Para conseguir escrever o operador bola use `\circ<TAB>`.

Julia busca encorajar o uso de operador para gerar comportamento sofisticado, vamos ver mais exemplos durante o curso.
"""

# ╔═╡ 4b0e8742-7a70-11eb-1e78-813f6ad005f4
let
    x = rand()
    (sin ∘ cos)(x) ≈ sin(cos(x))
end

# ╔═╡ f650b788-7a70-11eb-0b20-779d2f18f111
md"""
Você pode ver como outras linguagens lidam com composição de funções na [Wikipedia]
(https://en.wikipedia.org/wiki/Function_composition_(computer_science)).
"""

# ╔═╡ 014c14a6-7a72-11eb-119b-f5cfc82085ca
md"""
### Exemplos:
"""

# ╔═╡ 89f0bc54-76bb-11eb-271b-3190b4d8cbc0
md"""
Lembramos que transformações lineares podem ser inscritas em notação matricial no formato

$$\begin{pmatrix} a & b \\ c & d \end{pmatrix}
\begin{pmatrix} x \\ y \end{pmatrix}.$$
"""

# ╔═╡ ad700740-7a74-11eb-3369-15e5fd89194d
md"""
# Transformações lineares: matrizes são mais que números
"""

# ╔═╡ e051259a-7a74-11eb-12fc-99c5dc867fbd
md"""
Uma visão inocente de matrizes as reduzem a uma tabela de números sobre as quais definimos algumas operações. Mas nós sabemos melhor, já que estudamos álgebra linear: matrizes *são transformações lineares*! É isso que os matemáticos profissionais vêem.
"""

# ╔═╡ 1856ddae-7a78-11eb-3422-298e1103275b
md"""
Como definir uma transformação linear?  Podemos definir de diferentes maneiras.
"""

# ╔═╡ 4b4fe818-7a78-11eb-2986-59e60063d346
md"""
**Definições de transformações lineares:**
"""

# ╔═╡ 5d656494-7a78-11eb-12e8-d17856bd8c4d
md"""
- A definição mais intuitiva (geométrica):

   > Os retângulos (formados por linhas da malha) na imagem transformada, [vistos acima](#e0b657ce-7a03-11eb-1f9d-f32168cb5394), sempre se tornam paralelogramas congruentes.

- A definição operacional mais simples (mas sem muita intuição):

   > Uma transformação é linear se puder se escrita como $v \mapsto Av$ (matriz vezes vetor) para alguma matriz fixa $A$.

- Comuta com escalamento e soma (definição formal, matemática):

   > 1. Se você escala e transforma ou tranforma e escala, o resultado é o mesmo:
   >
   > $T(cv)=c \, T(v)$ ( $v$ é um vetor qqer, e $c$ um número qqer.)
   >
   > 2. Se você soma e transforma ou transforma e soma, o resultado é o mesmo:
   >
   > $T(v_1+v_2) = T(v_1) + T(v_2).$ ($v_1,v_2$ vetores quaisquer.)

- A definição consolidada:

   > A transformação $T$ é linear se
   >
   > $T(c_1 v_1 + c_2 v_2) = c_1 T(v_1) + c_2 T(v_2)$ para quaisquer números $c_1,c_2$ e vetore $v_1,v_2$.
"""

# ╔═╡ b0e6d1ac-7a7d-11eb-0a9e-1310dcb5957f
md"""
### A matriz
"""

# ╔═╡ 7e4ad37c-7a84-11eb-1490-25090e133a7c
Resource("https://upload.wikimedia.org/wikipedia/en/c/c1/The_Matrix_Poster.jpg")

# ╔═╡ 96f47252-7a84-11eb-3d18-e3ba79dd20c2
md"""
Não a outra Matriz! (Gostei da piadinha... esse filme foi um marco importante para mim.)
"""

# ╔═╡ ae5b3a32-7a84-11eb-04c0-337a74105a58
md"""
Já sabemos que é fácil escrever a matriz associada a uma transformação linear. A primeira coluna é $T([1, 0])$. Já a segunda é $T([0, 1])$.
"""

# ╔═╡ df609690-5047-4795-bbd2-cd4e6f2cb986


# ╔═╡ c9f2b61e-7a84-11eb-3841-33739a226ff9
md"""
Com isso, a relação linear

$$T([x, y]) = x \, T([1, 0]) + y \, T([0, 1]) = x \, (\mathrm{coluna\ 1\ de\ } A) + y \, (\mathrm{coluna\ 2\ de\ } A)$$
é justamente a definição do produto de uma matriz por um vetor. Verifique.
"""

# ╔═╡ 23d8a45c-7a85-11eb-3a68-ef11e6f58cac
md"""
### Lembrando o razão da multiplicação de matrizes.
"""

# ╔═╡ 4a96d516-7a85-11eb-181c-63a6b461790b
md"""
Se você não teve um curso formal de álgebra linear deve ficar pensando porque a multiplicação de matrizes vem de uma fórmula estranha.
"""

# ╔═╡ 8206e1ee-7a8a-11eb-1f26-054f6b100076
let
    A = randn(2, 2)
    B = randn(2, 2)
    v = rand(2)

    (lin(A) ∘ lin(B))(v), lin(A * B)(v)
end

# ╔═╡ 7d803684-7a8a-11eb-33d2-89d5e2a05bcf
md"""
**Importante:** Como vemos acima a transformação linear associada a matriz produto $AB$ é justamente a composição das trasformações lineares definidas a partir de $A$ e $B$ isoladamente. Essa é justamente a origem da definição da fórmula de multiplicação de matrizes. É a única fórmula capaz de fazer isso valer.

Você pode verificar isso você mesmo lembrando que a primeira coluna da matriz associada a `lin(A)∘lin(B)` deve ser o valor dessa transformação calculada no vetor $[1, 0]$. Isso é obtido fazendo primeiro $y=A[1,0]$ e, depois, $z = By$. Já a segunda coluna da matriz associada à composição é obtida fazendo o mesmo para o segundo vetor da base canônica $[0, 1]$.

Se nunca viu isso, tente fazer você mesmo, valhe à pena tentar fazer isso sozinho.
"""

# ╔═╡ 17281256-7aa5-11eb-3144-b72777334326
md"""
Agora, computacionalmente podemos testar isso facilmente:
"""

# ╔═╡ 05049fa0-7a8e-11eb-283b-cb4753c4aaf0
begin

    P = randn(2, 2)
    Q = randn(2, 2)

    T₁ = lin(P) ∘ lin(Q)
    T₂ = lin(P * Q)

    T₁([1, 0]), T₂([1, 0])
end

# ╔═╡ 313cdcbd-5b11-41c8-9fcd-5aeaca3b8d24
test_pixels = 300;

# ╔═╡ 57848b42-7a8f-11eb-023a-cf247cb53819
md"""
lin(P)∘lin(Q)
"""

# ╔═╡ 620ee7d8-7a8f-11eb-3888-356c27a2d591
md"""
`lin(P*Q)`
"""

# ╔═╡ 04da7710-7a91-11eb-02a1-0b6e889150a2
md"""
# Transformações de coordenadas versus transformações de objetos
"""

# ╔═╡ 155cd218-7a91-11eb-0b4c-bd028507e925
md"""
Se você quiser mover um objeto para direita, a primeira coisa que deve pensar é em somar 1 (ou outro valor positivo desejado) em todas as coordenadas dos pontos do seu objeto. Mas outra opção é criar um novo sistema de coordenadas "movendo o 0" a mesma quantidade para a esquerda. Essa última ideia é um exemplo de mudança no sistema de coordenadas.
"""

# ╔═╡ fd25da12-7a92-11eb-20c0-995e7c46b3bc
md"""
### Mudando de coordenadas entre índices de array $(i, j)$ e pontos no plano $(x, y)$
"""

# ╔═╡ 1ab2265e-7c1d-11eb-26df-39c4c7289243
md"""
Uma imagem tem índices (1, 1) no canto superior esquerdo. Ainda por cima, o eixo y cresce para baixo e os entradas vertical e horizontal estão na ordem errada. Como fazemos para mapear pontos no plano a valores de índices?
"""

# ╔═╡ 7c68c7b6-7a9e-11eb-3f7f-99bb10aedd95
Resource(
    "https://raw.githubusercontent.com/mitmath/18S191/Spring21/notebooks/week3/coord_transform.png",
)

# ╔═╡ c1efc54a-7e9b-11eb-1e76-dbd0a66184a9
translate(-400, 400)([1, 1])

# ╔═╡ db4bc328-76bb-11eb-28dc-eb9df8892d01
md"""
# Inversas
"""

# ╔═╡ 0b8ed36c-7a1e-11eb-053c-63cf9ee0b16f
md"""
Se $f$ é uma função do plano no plano (digamos), podemos definir a sua **inversa**, denotada por $f^{-1}$, como aquilo que *desfaz* o efeito de $f$, isto é:

$$f(f^{-1}(v))=v$$

e $f^{-1}(f(v))=v$.

Essa equação deve valer para todo $v$ ou pelo menos para todo $v$ em uma região de interesse.
"""

# ╔═╡ 7a4e785e-7a71-11eb-07fb-cfba453a117b
md"""
## Examplos: rotações e escalamento
"""

# ╔═╡ 9264508a-7a71-11eb-1b7c-bf6e62788115
let
    v = rand(2)
    T = rotate(30) ∘ rotate(-30)
    T(v), v
end

# ╔═╡ e89339b2-7a71-11eb-0f97-971b2ed277d1
let
    T = scale(0.5) ∘ scale(2)

    v = rand(2)
    T(v) .≈ v
end

# ╔═╡ 0957fd9a-7a72-11eb-0566-e93ef32fb626
md"""
Observanmos numericamente que as operações `rotate(30)` e `rotate(-30)`, assim como `scale(2)` e `scale(.5)` são inversas entre si. Pensando um pouco isso é muito natural.
"""

# ╔═╡ c7cc412c-7aa5-11eb-2df1-d3d788047238
md"""
## Inversas: o caso linear
"""

# ╔═╡ ce620b8e-7aa5-11eb-370b-11e34b07d54d
md"""
O que de fato fazem funções inversas?

Vamos começar de novo com o exemplo simples de escalamento. Dado um vetor de entrada $x$, escalá-lo por $2$ é calcular o vetor

$$y = 2 x$$

Agora, se queremos ir no sentido contrário, ou seja se conhecemos o $y$, como encontrar o $x$? Nesse caso é fácil, é só dividir por $2$. Ou seja $x = \frac{1}{2} y$.

Lembremos que o escalamento é uma função linear bem simples. Mas nós já conhecmos a fórmula geral de uma transformação linear:

$$y = A x,$$

para alguma matriz $A$.

Agora se temos o $y$ e queremos ir na direção de encontrar o $x$ que levou nesse $y$ vemos, da mesma expressão só que lida da direita, que queremos resolver um sistema linear com $x$ como as variáveis e $y$ como o lado direito.

Tipicamente esse tipo de sistema pode ser resolvido procurando uma matriz $B$ que "desfaz" a ação da matriz $A$. Ou seja $B$ seria capaz de obter

$$x = B y.$$

Mas isso quer dizer que

$$x = (BA) * x,$$

de onde concluímos que $B A$ deve ser a matriz identidade. Então $B$ deve ser a *matriz inversa* de $A$, denotada por

$$B = A^{-1}.$$

Para matrizes $2 \times 2$ consiguimos escrever uma fórmula geral para a inversa, quando ela existe. Já para matrizes de dimensão arbitrária precisamos usar algoritmos mais sofisticados que vocês viram no curso de cálculo numérico.
"""

# ╔═╡ 4f51931c-7aac-11eb-13ba-4b8768ac376f
md"""
### Invertendo uma transformação linear no computador
"""

# ╔═╡ 5ce799f4-7aac-11eb-0629-ebd8a404e9d3
let
    v = rand(2)
    A = randn(2, 2)
    (lin(inv(A)) ∘ lin(A))(v), v
end

# ╔═╡ 9b456686-7aac-11eb-3aa5-25e6c3c86aff
let
    A = randn(2, 2)
    B = randn(2, 2)
    inv(A * B) ≈ inv(B) * inv(A)
end

# ╔═╡ c2b0a488-7aac-11eb-1d8b-edd6bd23d1fd
md"""
``A^{-1}
=
\begin{pmatrix} d & -b \\ -c & a  \end{pmatrix} / (ad-bc) \quad
``
if
``\ A \ =
\begin{pmatrix} a & b \\ c & d  \end{pmatrix} .
``
"""

# ╔═╡ 02d6b440-7aa7-11eb-1be0-b78dea91387f
md"""
## Invertendo transformações não-lineares
"""

# ╔═╡ 0be9fb1e-7aa7-11eb-0116-c3e86ab82c77
md"""
Veremos como fazer isso na próxima aula.
"""

# ╔═╡ 4c93d784-763d-11eb-1f48-81d4d45d5ce0
md"""
## Porque estamos fazendo isso de trás para frente?

Se quisermor mover as cores dos píxeis aplicando T no lugar de T⁻¹ precisamos lidar com o fato que píxeis são elementos discretos. Ao levar um único píxel numa região onde imagem está sendo expandida apareceriam "vazios". Lembre da última aula. Ao contrário, ao levar um píxel em uma região em que a imagem fica "encolhida", haveria choque entre as cores caindo num mesmo píxel de chegada. Isso iria dificultar muito o trabalho de se obter resultados satisfatórios como já vimos antes.
"""

# ╔═╡ 7609d686-7aa7-11eb-310a-3550509504a1
md"""
# O diagrama do esquema de transformação das imagens
"""

# ╔═╡ 1b9faf64-7aab-11eb-1396-6fb89be7c445
Resource(
    "https://raw.githubusercontent.com/mitmath/18S191/Spring21/notebooks/week3/comm2.png",
)

# ╔═╡ 5f0568dc-7aad-11eb-162f-0d6e26f17d59
md"""
Observe que estamos de fato usando o mapa inverso de T para poder andar píxel por píxel na resultado.
"""

# ╔═╡ 8d32fff4-7c1b-11eb-1fa1-6ff2d87bfb73
md"""
## Colisões
"""

# ╔═╡ 80456168-7c1b-11eb-271c-83ef59a41102
Resource(
    "https://raw.githubusercontent.com/mitmath/18S191/Spring21/notebooks/week3/collide.png",
)

# ╔═╡ 5227afd0-7641-11eb-0065-918cb8538d55
md"""
Apagar
"""

# ╔═╡ c536dafb-4206-4689-ad6d-6935385d8fdf
md"""
# Apêndice
"""

# ╔═╡ fb509fb4-9608-421d-9c40-a4375f459b3f
det_A = det(A)

# ╔═╡ b754bae2-762f-11eb-1c6a-01251495a9bb
begin
    white(c::RGB) = RGB(1, 1, 1)
    white(c::RGBA) = RGBA(1, 1, 1, 0.75)
    black(c::RGB) = RGB(0, 0, 0)
    black(c::RGBA) = RGBA(0, 0, 0, 0.75)
end

# ╔═╡ 7d0096ad-d89a-4ade-9679-6ee95f7d2044
begin
    function transform_xy_to_ij(img::AbstractMatrix, x::Float64, y::Float64)
        # convert coordinate system xy to ij
        # center image, and use "white" when out of the boundary

        rows, cols = size(img)
        m = max(cols, rows)

        # function to take xy to ij
        xy_to_ij = translate(rows / 2, cols / 2) ∘ swap ∘ flipy ∘ scale(m / 2)

        # apply the function and "snap to grid"
        i, j = floor.(Int, xy_to_ij((x, y)))

    end

    function transform_ij_to_xy(i::Int, j::Int, pixels)
        ij_to_xy = scale(2 / pixels) ∘ flipy ∘ swap ∘ translate(-pixels / 2, -pixels / 2)

        ij_to_xy([i, j])
    end

    function getpixel(img, i::Int, j::Int; circular::Bool = false, r::Real = 200)
        #  grab image color or place default
        rows, cols = size(img)
        m = max(cols, rows)
        if circular
            c = (i - rows / 2)^2 + (j - cols / 2)^2 ≤ r * m^2 / 4
        else
            c = true
        end

        if 1 < i ≤ rows && 1 < j ≤ cols && c
            img[i, j]
        else
            #white(img[1, 1])
            black(img[1, 1])
        end

    end
end

# ╔═╡ bf1954d6-7e9a-11eb-216d-010bd761e470
transform_ij_to_xy(1, 1, 400)

# ╔═╡ 83d45d42-7406-11eb-2a9c-e75efe62b12c
function with_gridlines(img::Matrix; n = 10)
    rows, cols = size(img)
    result = copy(img)

    stroke = white(img[1, 1])

    # Add grid
    grid_lin = floor.(Int, LinRange(1, rows - 1, n))
    grid_col = floor.(Int, LinRange(1, cols - 1, n))
    for i in grid_lin
        result[i:i+1, :] .= stroke
    end
    for j in grid_col
        result[:, j:j+1] .= stroke
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
    with_gridlines(img_original; n = ngrid)
else
    img_original
end;

# ╔═╡ ca28189e-7e9a-11eb-21d6-bd819f3e0d3a
[
    begin
        x, y = transform_ij_to_xy(i, j, pixels)
        X, Y = (T⁻¹ ∘ scale(1 / z) ∘ translate(-panx, -pany))([x, y])
        i, j = transform_xy_to_ij(img, X, Y)
        getpixel(img, i, j; circular = circular, r = r)
    end for i = 1:pixels, j = 1:pixels
]


# ╔═╡ ccea7244-7f2f-11eb-1b7b-b9b8473a8c74
transform_xy_to_ij(img, 0.0, 0.0)  # Centro da imagem de partida

# ╔═╡ da73d9f6-7a8d-11eb-2e6f-1b819bbb0185
[
    begin
        x, y = transform_ij_to_xy(i, j, test_pixels)
        X, Y = T₁([x, y])
        i, j = transform_xy_to_ij(img, X, Y)
        getpixel(img, i, j)
    end

    for i = 1:test_pixels, j = 1:test_pixels
]

# ╔═╡ 30f522a0-7a8e-11eb-2181-8313760778ef
[
    begin
        x, y = transform_ij_to_xy(i, j, test_pixels)
        X, Y = T₂([x, y])
        i, j = transform_xy_to_ij(img, X, Y)
        getpixel(img, i, j)
    end

    for i = 1:test_pixels, j = 1:test_pixels
]

# ╔═╡ c2e0e032-7c4c-11eb-2b2a-27fe69c42a01
img

# ╔═╡ c662e3d8-7c4c-11eb-0dcf-f9da2bd14baf
size(img)

# ╔═╡ d0e9a1e8-7c4c-11eb-056c-aff283c49c31
img[200, 300]

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
ColorVectorSpace = "c3611d14-8923-5661-9e6a-0046d554d3a4"
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
ImageIO = "82e4d734-157c-48bb-816b-45c225c6df19"
ImageShow = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
NonlinearSolve = "8913a72c-1f9b-4ce2-8d82-65094dcecaec"
PNGFiles = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[compat]
BenchmarkTools = "~1.1.3"
ColorVectorSpace = "~0.9.5"
Colors = "~0.12.8"
FileIO = "~1.11.0"
ForwardDiff = "~0.10.19"
HypertextLiteral = "~0.9.0"
ImageIO = "~0.5.7"
ImageShow = "~0.3.2"
NonlinearSolve = "~0.3.9"
PNGFiles = "~0.3.7"
PlutoUI = "~0.7.9"
StaticArrays = "~1.2.12"
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

[[ArrayInterface]]
deps = ["IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "cdb00a6fb50762255021e5571cf95df3e1797a51"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.1.23"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Statistics", "UUIDs"]
git-tree-sha1 = "aa3aba5ed8f882ed01b71e09ca2ba0f77f44a99e"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.1.3"

[[CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[CPUSummary]]
deps = ["Hwloc", "IfElse", "Static"]
git-tree-sha1 = "147bcca99e098c0da48d7d9e108210704138f0f9"
uuid = "2a0fbf3d-bb9c-48f3-b0a9-814d99fd7ab9"
version = "0.1.2"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "bdc0937269321858ab2a4f288486cb258b9a0af7"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.3.0"

[[CloseOpenIntervals]]
deps = ["ArrayInterface", "Static"]
git-tree-sha1 = "4fcacb5811c9e4eb6f9adde4afc0e9c4a7a92f5a"
uuid = "fb6a15b2-703c-40df-9091-08a04967cfa9"
version = "0.1.1"

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

[[CommonSolve]]
git-tree-sha1 = "68a0743f578349ada8bc911a5cbd5a2ef6ed6d1f"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.0"

[[CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "727e463cfebd0c7b999bbf3e9e7e16f254b94193"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.34.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f74e9d5388b8620b4cee35d4c5a618dd4dc547f4"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.3.0"

[[DataAPI]]
git-tree-sha1 = "ee400abb2298bd13bfc3df1c412ed228061a2385"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.7.0"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

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
git-tree-sha1 = "3ed8fa7178a10d1cd0f1ca524f249ba6937490c0"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.3.0"

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
git-tree-sha1 = "937c29268e405b6808d958a9ac41bfe1a31b08e7"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.11.0"

[[FiniteDiff]]
deps = ["ArrayInterface", "LinearAlgebra", "Requires", "SparseArrays", "StaticArrays"]
git-tree-sha1 = "8b3c09b56acaf3c0e581c66638b85c8650ee9dca"
uuid = "6a86dc24-6348-571c-b903-95158fe2bd41"
version = "2.8.1"

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

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "2c1cf4df419938ece72de17f368a021ee162762e"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.0"

[[HostCPUFeatures]]
deps = ["IfElse", "Libdl", "Static"]
git-tree-sha1 = "e86382a874edd4ff47fd1373e03f38302af93345"
uuid = "3e5b6fbb-0976-4d2c-9146-d79de83f2fb0"
version = "0.1.2"

[[Hwloc]]
deps = ["Hwloc_jll"]
git-tree-sha1 = "92d99146066c5c6888d5a3abc871e6a214388b91"
uuid = "0e44f5e4-bd66-52a0-8798-143a42290a1d"
version = "2.0.0"

[[Hwloc_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3395d4d4aeb3c9d31f5929d32760d8baeee88aaf"
uuid = "e33a78d0-f292-5ffc-b300-72abe9b543c8"
version = "2.5.0+0"

[[HypertextLiteral]]
git-tree-sha1 = "72053798e1be56026b81d4e2682dbe58922e5ec9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.0"

[[IfElse]]
git-tree-sha1 = "28e837ff3e7a6c3cdb252ce49fb412c8eb3caeef"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.0"

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
deps = ["FileIO", "Netpbm", "OpenEXR", "PNGFiles", "TiffImages", "UUIDs"]
git-tree-sha1 = "ba5334adebad6bcf43f2586e7151d2c83f09f9b6"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.5.7"

[[ImageShow]]
deps = ["Base64", "FileIO", "ImageBase", "ImageCore", "OffsetArrays", "StackViews"]
git-tree-sha1 = "e439b5a4e8676da8a29da0b7d2b498f2db6dbce3"
uuid = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
version = "0.3.2"

[[Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "87f7662e03a649cffa2e05bf19c303e168732d3e"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.2+0"

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

[[IterativeSolvers]]
deps = ["LinearAlgebra", "Printf", "Random", "RecipesBase", "SparseArrays"]
git-tree-sha1 = "1a8c6237e78b714e901e406c096fc8a65528af7d"
uuid = "42fd0dbc-a981-5370-80f2-aaf504508153"
version = "0.9.1"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

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

[[LoopVectorization]]
deps = ["ArrayInterface", "DocStringExtensions", "IfElse", "LinearAlgebra", "OffsetArrays", "Polyester", "Requires", "SLEEFPirates", "Static", "StrideArraysCore", "ThreadingUtilities", "UnPack", "VectorizationBase"]
git-tree-sha1 = "9f23789217866ad9ecd053857ef202de5edcac4b"
uuid = "bdcacae8-1622-11e9-2a5c-532679323890"
version = "0.12.65"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "0fb723cd8c45858c22169b2e42269e53271a6df7"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.7"

[[ManualMemory]]
git-tree-sha1 = "9cb207b18148b2199db259adfa923b45593fe08e"
uuid = "d125e4d3-2237-4719-b19c-fa641b8a4667"
version = "0.1.6"

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

[[NonlinearSolve]]
deps = ["ArrayInterface", "FiniteDiff", "ForwardDiff", "IterativeSolvers", "LinearAlgebra", "RecursiveArrayTools", "RecursiveFactorization", "Reexport", "SciMLBase", "Setfield", "StaticArrays", "UnPack"]
git-tree-sha1 = "f2530482ef6447c8ae24c660914436f1ae3917e0"
uuid = "8913a72c-1f9b-4ce2-8d82-65094dcecaec"
version = "0.3.9"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "c0f4a4836e5f3e0763243b8324200af6d0e0f90c"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.5"

[[OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "923319661e9a22712f24596ce81c54fc0366f304"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.1+0"

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
git-tree-sha1 = "438d35d2d95ae2c5e8780b330592b6de8494e779"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.3"

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

[[Polyester]]
deps = ["ArrayInterface", "IfElse", "ManualMemory", "Requires", "Static", "StrideArraysCore", "ThreadingUtilities", "VectorizationBase"]
git-tree-sha1 = "3ced65f2f182e5b5335a573eaa98f883eba3678b"
uuid = "f517fe37-dbe3-4b94-8317-1923a5111588"
version = "0.3.9"

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

[[RecipesBase]]
git-tree-sha1 = "44a75aa7a527910ee3d1751d1f0e4148698add9e"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.2"

[[RecursiveArrayTools]]
deps = ["ArrayInterface", "ChainRulesCore", "DocStringExtensions", "LinearAlgebra", "RecipesBase", "Requires", "StaticArrays", "Statistics", "ZygoteRules"]
git-tree-sha1 = "82efc2429a2b2e72daf2322dbdf5fc60df6dc51f"
uuid = "731186ca-8d62-57ce-b412-fbd966d074cd"
version = "2.17.1"

[[RecursiveFactorization]]
deps = ["LinearAlgebra", "LoopVectorization", "Polyester", "StrideArraysCore", "TriangularSolve"]
git-tree-sha1 = "9ac54089f52b0d0c37bebca35b9505720013a108"
uuid = "f2c3362d-daeb-58d1-803e-2bc74f2840b4"
version = "0.2.2"

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

[[SLEEFPirates]]
deps = ["IfElse", "Static", "VectorizationBase"]
git-tree-sha1 = "bfdf9532c33db35d2ce9df4828330f0e92344a52"
uuid = "476501e8-09a2-5ece-8869-fb82de89a1fa"
version = "0.6.25"

[[SciMLBase]]
deps = ["ArrayInterface", "CommonSolve", "ConstructionBase", "Distributed", "DocStringExtensions", "IteratorInterfaceExtensions", "LinearAlgebra", "Logging", "RecipesBase", "RecursiveArrayTools", "StaticArrays", "Statistics", "Tables", "TreeViews"]
git-tree-sha1 = "ff686e0c79dbe91767f4c1e44257621a5455b1c6"
uuid = "0bca4576-84f4-4d90-8ffe-ffa030f20462"
version = "1.18.7"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "Requires"]
git-tree-sha1 = "fca29e68c5062722b5b4435594c3d1ba557072a3"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "0.7.1"

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

[[Static]]
deps = ["IfElse"]
git-tree-sha1 = "62701892d172a2fa41a1f829f66d2b0db94a9a63"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.3.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3240808c6d463ac46f1c1cd7638375cd22abbccb"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.12"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StrideArraysCore]]
deps = ["ArrayInterface", "ManualMemory", "Requires", "ThreadingUtilities", "VectorizationBase"]
git-tree-sha1 = "9ab16bda5fe1212e0af0bea80f1d11096aeb3248"
uuid = "7792a7ef-975c-4747-a70f-980b88e8d1da"
version = "0.1.18"

[[Suppressor]]
git-tree-sha1 = "a819d77f31f83e5792a76081eee1ea6342ab8787"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.0"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "d0c690d37c73aeb5ca063056283fde5585a41710"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.5.0"

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

[[ThreadingUtilities]]
deps = ["ManualMemory"]
git-tree-sha1 = "03013c6ae7f1824131b2ae2fc1d49793b51e8394"
uuid = "8290d209-cae3-49c0-8002-c8c24d57dab5"
version = "0.4.6"

[[TiffImages]]
deps = ["ColorTypes", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "OffsetArrays", "OrderedCollections", "PkgVersion", "ProgressMeter"]
git-tree-sha1 = "03fb246ac6e6b7cb7abac3b3302447d55b43270e"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.4.1"

[[TreeViews]]
deps = ["Test"]
git-tree-sha1 = "8d0d7a3fe2f30d6a7f833a5f19f7c7a5b396eae6"
uuid = "a2a6695c-b41b-5b7d-aed9-dbfdeacea5d7"
version = "0.3.0"

[[TriangularSolve]]
deps = ["CloseOpenIntervals", "IfElse", "LinearAlgebra", "LoopVectorization", "Polyester", "Static", "VectorizationBase"]
git-tree-sha1 = "cb80cf5e0dfb1aedd4c6dbca09b5faaa9a300c62"
uuid = "d5829a12-d9aa-46ab-831f-fb7c9ab06edf"
version = "0.1.3"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[VectorizationBase]]
deps = ["ArrayInterface", "CPUSummary", "HostCPUFeatures", "Hwloc", "IfElse", "Libdl", "LinearAlgebra", "Static"]
git-tree-sha1 = "0e940546f8ad51f53966c866db14ff9b58be24e0"
uuid = "3d5dd08c-fd9d-11e8-17fa-ed2836048c2f"
version = "0.20.34"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[ZygoteRules]]
deps = ["MacroTools"]
git-tree-sha1 = "9e7a1e8ca60b742e508a315c17eef5211e7fbfd7"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.1"

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
# ╠═b7895bd2-7634-11eb-211e-ef876d23bd88
# ╟─230b0118-30b7-4035-ad31-520165a76fcc
# ╠═6b473b2d-4326-46b4-af38-07b61de287fc
# ╟─230cba36-9d0a-4726-9e55-7df2c6743968
# ╠═85fba8fb-a9ea-444d-831b-ec6489b58b4f
# ╟─890d30b9-2cd0-4d3a-99f6-f7d3d7858fda
# ╠═96766502-7a06-11eb-00cc-29849773dbcf
# ╟─26dd0e98-7a75-11eb-2196-5d7bda201b19
# ╟─e0b657ce-7a03-11eb-1f9d-f32168cb5394
# ╠═74bd4232-5255-441d-bd28-f3fe7d706e20
# ╠═f2c1671b-3f72-47e9-8eef-d6f1b33f05fa
# ╟─ab2fd438-b384-401f-a5d0-5a58c23e54ed
# ╟─23ade8ee-7a09-11eb-0e40-296c6b831d74
# ╟─58a30e54-7a08-11eb-1c57-dfef0000255f
# ╟─005ca75a-7622-11eb-2ba4-9f450e71df1f
# ╟─2efaa336-7630-11eb-0c17-a7d4a0141dac
# ╟─7f28ac40-7914-11eb-1403-b7bec34aeb94
# ╟─ce55beee-7643-11eb-04bc-b517703facff
# ╟─5d33f6ea-7e9c-11eb-2fb3-dbb7cb07c60c
# ╟─45dccdec-7912-11eb-01b4-a97e30344f39
# ╟─d2fb356e-7f32-11eb-177d-4f47d6c9e59b
# ╠═ca28189e-7e9a-11eb-21d6-bd819f3e0d3a
# ╠═ccea7244-7f2f-11eb-1b7b-b9b8473a8c74
# ╟─55b5fc92-7a76-11eb-3fba-854c65eb87f9
# ╟─85686412-7a75-11eb-3d83-9f2f8a3c5509
# ╟─a7df7346-79f8-11eb-1de6-71f027c46643
# ╟─044e6128-79fe-11eb-18c1-395ae857dc73
# ╟─78d61e28-79f9-11eb-0605-e77d206cda84
# ╟─aad4d6e4-79f9-11eb-0342-b900a41cfbaf
# ╟─d42aec08-76ad-11eb-361a-a1f2c90fd4ec
# ╟─e965cf5e-79fd-11eb-201d-695b54d08e54
# ╟─1e11c1ec-79fe-11eb-1867-9da72b3f3bc4
# ╟─28ef451c-7aa1-11eb-340c-ab3a1193a3c4
# ╟─a0afe3ae-76b9-11eb-2301-cde7260ddd7f
# ╟─fc2deb7c-7aa1-11eb-019f-d3e3c80b9ff1
# ╠═d364f91a-76b9-11eb-1807-75e733940d53
# ╟─080d87e0-7aa2-11eb-18f5-2fb6a7a5bcb4
# ╠═15283aba-7aa2-11eb-389c-e9f215bd03e2
# ╟─2612d2c2-7aa2-11eb-085a-1f27b6174995
# ╟─bf1fcb80-2a85-4b75-a8cf-a66fa6ab2744
# ╠═1943078d-9524-4cb6-ab66-9d069081b532
# ╠═2c2eafb8-a3f4-4225-8432-4628a9da40db
# ╠═11cd57f1-e83e-4f17-825d-ac5a9f5f6a97
# ╠═507c9f1f-503a-415a-9881-e5e19dde3b98
# ╟─a290d5e2-7a02-11eb-37db-41bf86b1f3b3
# ╠═b4cdd412-7a02-11eb-149a-df1888a0f465
# ╟─4a2404d5-6894-4f78-a295-0e26156e544d
# ╠═3d28ce92-6c12-4143-9f53-3634bbc687ce
# ╠═3460ad26-daeb-4e9c-9c75-1e00e43d592d
# ╟─a05a2667-ed48-4610-bc4d-bff0317788ef
# ╠═2b50dc4e-6549-4640-922d-c1c15bb82d7c
# ╟─46898e66-8d95-43bd-83f6-6806e3c1ead7
# ╠═069988e7-1262-47b6-b399-a464bdcab21b
# ╠═be3dabd6-2c7e-416f-92d3-44a7cee36f8b
# ╠═de1cfad9-8dae-42e0-b9bb-2e0eb5a03968
# ╟─704a87ec-7a1e-11eb-3964-e102357a4d1f
# ╟─44792484-7a20-11eb-1c09-95b27b08bd34
# ╠═4b0e8742-7a70-11eb-1e78-813f6ad005f4
# ╟─f650b788-7a70-11eb-0b20-779d2f18f111
# ╟─014c14a6-7a72-11eb-119b-f5cfc82085ca
# ╟─89f0bc54-76bb-11eb-271b-3190b4d8cbc0
# ╟─ad700740-7a74-11eb-3369-15e5fd89194d
# ╟─e051259a-7a74-11eb-12fc-99c5dc867fbd
# ╟─1856ddae-7a78-11eb-3422-298e1103275b
# ╟─4b4fe818-7a78-11eb-2986-59e60063d346
# ╠═5d656494-7a78-11eb-12e8-d17856bd8c4d
# ╟─b0e6d1ac-7a7d-11eb-0a9e-1310dcb5957f
# ╟─7e4ad37c-7a84-11eb-1490-25090e133a7c
# ╟─96f47252-7a84-11eb-3d18-e3ba79dd20c2
# ╟─ae5b3a32-7a84-11eb-04c0-337a74105a58
# ╠═df609690-5047-4795-bbd2-cd4e6f2cb986
# ╠═c9f2b61e-7a84-11eb-3841-33739a226ff9
# ╟─23d8a45c-7a85-11eb-3a68-ef11e6f58cac
# ╟─4a96d516-7a85-11eb-181c-63a6b461790b
# ╠═8206e1ee-7a8a-11eb-1f26-054f6b100076
# ╟─7d803684-7a8a-11eb-33d2-89d5e2a05bcf
# ╟─17281256-7aa5-11eb-3144-b72777334326
# ╠═05049fa0-7a8e-11eb-283b-cb4753c4aaf0
# ╠═313cdcbd-5b11-41c8-9fcd-5aeaca3b8d24
# ╟─57848b42-7a8f-11eb-023a-cf247cb53819
# ╠═da73d9f6-7a8d-11eb-2e6f-1b819bbb0185
# ╟─620ee7d8-7a8f-11eb-3888-356c27a2d591
# ╟─30f522a0-7a8e-11eb-2181-8313760778ef
# ╟─04da7710-7a91-11eb-02a1-0b6e889150a2
# ╟─c2e0e032-7c4c-11eb-2b2a-27fe69c42a01
# ╠═c662e3d8-7c4c-11eb-0dcf-f9da2bd14baf
# ╠═d0e9a1e8-7c4c-11eb-056c-aff283c49c31
# ╟─155cd218-7a91-11eb-0b4c-bd028507e925
# ╟─fd25da12-7a92-11eb-20c0-995e7c46b3bc
# ╟─1ab2265e-7c1d-11eb-26df-39c4c7289243
# ╟─7c68c7b6-7a9e-11eb-3f7f-99bb10aedd95
# ╠═7d0096ad-d89a-4ade-9679-6ee95f7d2044
# ╠═bf1954d6-7e9a-11eb-216d-010bd761e470
# ╠═c1efc54a-7e9b-11eb-1e76-dbd0a66184a9
# ╟─db4bc328-76bb-11eb-28dc-eb9df8892d01
# ╟─0b8ed36c-7a1e-11eb-053c-63cf9ee0b16f
# ╟─7a4e785e-7a71-11eb-07fb-cfba453a117b
# ╠═9264508a-7a71-11eb-1b7c-bf6e62788115
# ╠═e89339b2-7a71-11eb-0f97-971b2ed277d1
# ╟─0957fd9a-7a72-11eb-0566-e93ef32fb626
# ╟─c7cc412c-7aa5-11eb-2df1-d3d788047238
# ╟─ce620b8e-7aa5-11eb-370b-11e34b07d54d
# ╟─4f51931c-7aac-11eb-13ba-4b8768ac376f
# ╠═5ce799f4-7aac-11eb-0629-ebd8a404e9d3
# ╠═9b456686-7aac-11eb-3aa5-25e6c3c86aff
# ╟─c2b0a488-7aac-11eb-1d8b-edd6bd23d1fd
# ╟─02d6b440-7aa7-11eb-1be0-b78dea91387f
# ╟─0be9fb1e-7aa7-11eb-0116-c3e86ab82c77
# ╟─4c93d784-763d-11eb-1f48-81d4d45d5ce0
# ╟─7609d686-7aa7-11eb-310a-3550509504a1
# ╟─1b9faf64-7aab-11eb-1396-6fb89be7c445
# ╟─5f0568dc-7aad-11eb-162f-0d6e26f17d59
# ╟─8d32fff4-7c1b-11eb-1fa1-6ff2d87bfb73
# ╟─80456168-7c1b-11eb-271c-83ef59a41102
# ╟─5227afd0-7641-11eb-0065-918cb8538d55
# ╟─c536dafb-4206-4689-ad6d-6935385d8fdf
# ╟─fb509fb4-9608-421d-9c40-a4375f459b3f
# ╠═55898e88-36a0-4f49-897f-e0850bd2b0df
# ╠═b754bae2-762f-11eb-1c6a-01251495a9bb
# ╠═83d45d42-7406-11eb-2a9c-e75efe62b12c
# ╟─2e8c4a48-d535-44ac-a1f1-4cb26c4aece6
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
