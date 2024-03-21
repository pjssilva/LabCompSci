### A Pluto.jl notebook ###
# v0.19.40

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
PlutoUI.TableOfContents(aside=true)

# ╔═╡ 230b0118-30b7-4035-ad31-520165a76fcc
md"""
#### Inicialização de pacotes

_Quando você executar esse caderno pela primeira vez ele irá instalar pacotes. Isso pode demorar até 15 minutos. Aguente firme!_
"""

# ╔═╡ 890d30b9-2cd0-4d3a-99f6-f7d3d7858fda
img_sources = [
    "https://www.ime.unicamp.br/~pjssilva/images/ensino/labcompsci/carmel-arquelau-bV3RXy9Upqg-unsplash.png" => "Tucano",
    "https://www.ime.unicamp.br/~pjssilva/images/ensino/labcompsci/matt-paul-catalano-MUwfuO5RXEo-unsplash.png" => "Onda",
    "https://www.ime.unicamp.br/~pjssilva/images/ensino/labcompsci/matt-paul-catalano-MUwfuO5RXEo-unsplash_square.png" => "Onda quadrada",
    "https://user-images.githubusercontent.com/6933510/108883855-39690f80-7606-11eb-8eb1-e595c6c8d829.png" => "Setas",
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
Após você selecionar a sua imagem, pode ser interessante mover essa célula para o topo da janela do navegador.

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
custom = ((x, y),) -> [x, α * y^2]
# custom = ((x, y),) -> [sin(α * x), y]
# custom = ((x, y),)-> [x + α*y^2, y + α*x^2] # may be non-invertible
# custom  = flipy ∘ ((x, y),) ->  [(β*x - α*y)/(β - y), -h*y/(β - y)]
# custom = ((x, y),) -> [log(x + 1.2), log(y + 1.2)] # Exponentialish
# custom = ((x, y),) -> [ log(x^2 + y^2 + 1.2)/2, atan(y, x) ] # (reim(log(complex(y,x)) ))

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
[Uma demostrantação iterativa de perspectiva](https://www.khanacademy.org/humanities/renaissance-reformation/early-renaissance1/beginners-renaissance-florence/a/linear-perspective-interactive), disponível na  Khan academy. (Possivelmente você precisa estar desconectar do Khan Academy se o usa em português.)
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

As formas que usam o operador `->` (eu o leio "leva a") são funções anônimas. É claro que depois de criar uma dessas funções podemos atribui-la a uma varíavel, nomeando-a. Um teste interessante é ver a diferença que existe entre `methods(f)` em que `f` é uma função "de início" ou uma variável que recebeu uma função anônima.
"""

# ╔═╡ 28ef451c-7aa1-11eb-340c-ab3a1193a3c4
md"""
## Funções com parâmetros

Funções anônimas são úteis quando queremos gerar rapidamente um **fechamento** (do inglês `closure`), ou seja uma função que depende do valor de um **parâmetro no momento de sua criação**. Por exemplo,

`f(α) = ((x,y),) -> [x + α*y, x - α*y]`

é na verdade uma fábrica de funções que são definidas de acordo com o parâmetro α repassado. Por exemplo tente rodar `f(7)([1, 2])` e, depois, `f(3)([1, 2])`.

Num primeiro momento isso não parece grande coisa, mas lembre que essa função pode ser atribuída a outra variável, passada como argumento para outra função, ou retornada da chamada de uma função. Em todos esses casos ela irá lembrar a associação com α definida no momento de sua criação.
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

Julia busca encorajar o uso desse operador para gerar comportamento sofisticado, vamos ver mais exemplos durante o curso.
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
   > $T(cv)=c \, T(v)$ ( $v$ é um vetor qualquer, e $c$ um número qualquer.)
   >
   > 2. Se você soma e transforma ou transforma e soma, o resultado é o mesmo:
   >
   > $T(v_1+v_2) = T(v_1) + T(v_2).$ ($v_1,v_2$ são vetores quaisquer.)

- A definição consolidada:

   > A transformação $T$ é linear se
   >
   > $T(c_1 v_1 + c_2 v_2) = c_1 T(v_1) + c_2 T(v_2)$ para quaisquer números $c_1,c_2$ e vetores $v_1,v_2$.
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

# ╔═╡ c9f2b61e-7a84-11eb-3841-33739a226ff9
md"""
Com isso, a relação linear

$$T([x, y]) = x \, T([1, 0]) + y \, T([0, 1]) = x \, (\mathrm{coluna\ 1\ de\ } A) + y \, (\mathrm{coluna\ 2\ de\ } A)$$
é justamente a definição do produto de uma matriz por um vetor. Verifique.
"""

# ╔═╡ 23d8a45c-7a85-11eb-3a68-ef11e6f58cac
md"""
### Lembrando a razão por trás da fórmula de multiplicação de matrizes.
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
Uma imagem tem índices (1, 1) no canto superior esquerdo. Ainda por cima, o eixo y cresce para baixo e as entradas vertical e horizontal estão na ordem errada. Como fazemos para mapear pontos no plano a valores de índices?
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

Lembremos que o escalamento é uma função linear bem simples. Mas nós já conhecemos a fórmula geral de uma transformação linear:

$$y = A x,$$

para uma matriz $A$.

Agora se temos o $y$ e queremos ir na direção de encontrar o $x$ que levou nesse $y$ vemos, da mesma expressão só que lida da direita, que queremos resolver um sistema linear com $x$ como as variáveis e $y$ como o lado direito.

Tipicamente esse tipo de sistema pode ser resolvido procurando uma matriz $B$ que "desfaz" a ação da matriz $A$. Ou seja $B$ seria capaz de obter

$$x = B y.$$

Mas isso quer dizer que

$$x = (BA) * x,$$

de onde concluímos que $B A$ deve ser a matriz identidade. Então $B$ deve ser a *matriz inversa* de $A$, denotada por

$$B = A^{-1}.$$

Para matrizes $2 \times 2$ conseguimos escrever uma fórmula geral para a inversa, quando ela existe. Já para matrizes de dimensão arbitrária precisamos usar algoritmos mais sofisticados que vocês viram no curso de cálculo numérico.
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

    function getpixel(img, i::Int, j::Int; circular::Bool=false, r::Real=200)
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
function with_gridlines(img::Matrix; n=10)
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
    with_gridlines(img_original; n=ngrid)
else
    img_original
end;

# ╔═╡ ca28189e-7e9a-11eb-21d6-bd819f3e0d3a
[
    begin
        x, y = transform_ij_to_xy(i, j, pixels)
        X, Y = (T⁻¹ ∘ scale(1 / z) ∘ translate(-panx, -pany))([x, y])
        i, j = transform_xy_to_ij(img, X, Y)
        getpixel(img, i, j; circular=circular, r=r)
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
BenchmarkTools = "~1.5.0"
ColorVectorSpace = "~0.10.0"
Colors = "~0.12.10"
FileIO = "~1.16.3"
ForwardDiff = "~0.10.36"
HypertextLiteral = "~0.9.5"
ImageIO = "~0.6.7"
ImageShow = "~0.3.8"
NonlinearSolve = "~3.8.0"
PNGFiles = "~0.4.3"
PlutoUI = "~0.7.58"
StaticArrays = "~1.9.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.2"
manifest_format = "2.0"
project_hash = "1b6c60192a88048f7120158929bc251c753e1fa0"

[[deps.ADTypes]]
git-tree-sha1 = "016833eb52ba2d6bea9fcb50ca295980e728ee24"
uuid = "47edcb42-4c32-4615-8424-f2b9edc5f35b"
version = "0.2.7"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "0f748c81756f2e5e6854298f11ad8b2dfae6911a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.0"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "6a55b747d1812e699320963ffde36f1ebdda4099"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.0.4"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[deps.ArrayInterface]]
deps = ["Adapt", "LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "44691067188f6bd1b2289552a23e4b7572f4528d"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.9.0"

    [deps.ArrayInterface.extensions]
    ArrayInterfaceBandedMatricesExt = "BandedMatrices"
    ArrayInterfaceBlockBandedMatricesExt = "BlockBandedMatrices"
    ArrayInterfaceCUDAExt = "CUDA"
    ArrayInterfaceChainRulesExt = "ChainRules"
    ArrayInterfaceGPUArraysCoreExt = "GPUArraysCore"
    ArrayInterfaceReverseDiffExt = "ReverseDiff"
    ArrayInterfaceStaticArraysCoreExt = "StaticArraysCore"
    ArrayInterfaceTrackerExt = "Tracker"

    [deps.ArrayInterface.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    ChainRules = "082447d4-558c-5d27-93f4-14fc19e9eca2"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"

[[deps.ArrayLayouts]]
deps = ["FillArrays", "LinearAlgebra"]
git-tree-sha1 = "2aeaeaff72cdedaa0b5f30dfb8c1f16aefdac65d"
uuid = "4c555306-a7a7-4459-81d9-ec55ddd5c99a"
version = "1.7.0"
weakdeps = ["SparseArrays"]

    [deps.ArrayLayouts.extensions]
    ArrayLayoutsSparseArraysExt = "SparseArrays"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "16351be62963a67ac4083f748fdb3cca58bfd52f"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.7"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "f1dff6729bc61f4d49e140da1af55dcd1ac97b2f"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.5.0"

[[deps.BitTwiddlingConvenienceFunctions]]
deps = ["Static"]
git-tree-sha1 = "0c5f81f47bbbcf4aea7b2959135713459170798b"
uuid = "62783981-4cbd-42fc-bca8-16325de8dc4b"
version = "0.1.5"

[[deps.CEnum]]
git-tree-sha1 = "389ad5c84de1ae7cf0e28e381131c98ea87d54fc"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.5.0"

[[deps.CPUSummary]]
deps = ["CpuId", "IfElse", "PrecompileTools", "Static"]
git-tree-sha1 = "601f7e7b3d36f18790e2caf83a882d88e9b71ff1"
uuid = "2a0fbf3d-bb9c-48f3-b0a9-814d99fd7ab9"
version = "0.2.4"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "575cd02e080939a33b6df6c5853d14924c08e35b"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.23.0"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.CloseOpenIntervals]]
deps = ["Static", "StaticArrayInterface"]
git-tree-sha1 = "70232f82ffaab9dc52585e0dd043b5e0c6b714f1"
uuid = "fb6a15b2-703c-40df-9091-08a04967cfa9"
version = "0.1.12"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "67c1f244b991cad9b0aa4b7540fb758c2488b129"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.24.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

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
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.CommonSolve]]
git-tree-sha1 = "0eee5eb66b1cf62cd6ad1b460238e60e4b09400c"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.4"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "c955881e3c981181362ae4088b35995446298b80"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.14.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.0+0"

[[deps.ConcreteStructs]]
git-tree-sha1 = "f749037478283d372048690eb3b5f92a79432b34"
uuid = "2569d6c7-a4a2-43d3-a901-331e8e4be471"
version = "0.2.3"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "260fd2400ed2dab602a7c15cf10c1933c59930a2"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.5"
weakdeps = ["IntervalSets", "StaticArrays"]

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseStaticArraysExt = "StaticArrays"

[[deps.CpuId]]
deps = ["Markdown"]
git-tree-sha1 = "fcbb72b032692610bfbdb15018ac16a36cf2e406"
uuid = "adafc99b-e345-5852-983c-f28acb93d879"
version = "0.3.1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "0f4b5d62a88d8f59003e43c25a8a90de9eb76317"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.18"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DiffEqBase]]
deps = ["ArrayInterface", "DataStructures", "DocStringExtensions", "EnumX", "EnzymeCore", "FastBroadcast", "ForwardDiff", "FunctionWrappers", "FunctionWrappersWrappers", "LinearAlgebra", "Logging", "Markdown", "MuladdMacro", "Parameters", "PreallocationTools", "PrecompileTools", "Printf", "RecursiveArrayTools", "Reexport", "SciMLBase", "SciMLOperators", "Setfield", "SparseArrays", "Static", "StaticArraysCore", "Statistics", "Tricks", "TruncatedStacktraces"]
git-tree-sha1 = "b19b2bb1ecd1271334e4b25d605e50f75e68fcae"
uuid = "2b5f629d-d688-5b77-993f-72d75c75574e"
version = "6.148.0"

    [deps.DiffEqBase.extensions]
    DiffEqBaseChainRulesCoreExt = "ChainRulesCore"
    DiffEqBaseDistributionsExt = "Distributions"
    DiffEqBaseEnzymeExt = ["ChainRulesCore", "Enzyme"]
    DiffEqBaseGeneralizedGeneratedExt = "GeneralizedGenerated"
    DiffEqBaseMPIExt = "MPI"
    DiffEqBaseMeasurementsExt = "Measurements"
    DiffEqBaseMonteCarloMeasurementsExt = "MonteCarloMeasurements"
    DiffEqBaseReverseDiffExt = "ReverseDiff"
    DiffEqBaseTrackerExt = "Tracker"
    DiffEqBaseUnitfulExt = "Unitful"

    [deps.DiffEqBase.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"
    GeneralizedGenerated = "6b9d7cbe-bcb9-11e9-073f-15a7a543e2eb"
    MPI = "da04e1cc-30fd-572f-bb4f-1f8673147195"
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    MonteCarloMeasurements = "0987c9cc-fe09-11e8-30f0-b96dd679fdca"
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

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

[[deps.EnumX]]
git-tree-sha1 = "bdb1942cd4c45e3c678fd11569d5cccd80976237"
uuid = "4e289a0a-7415-4d19-859d-a7e5c4648b56"
version = "1.0.4"

[[deps.EnzymeCore]]
git-tree-sha1 = "59c44d8fbc651c0395d8a6eda64b05ce316f58b4"
uuid = "f151be2c-9106-41f4-ab19-57ee4f262869"
version = "0.6.5"
weakdeps = ["Adapt"]

    [deps.EnzymeCore.extensions]
    AdaptExt = "Adapt"

[[deps.ExprTools]]
git-tree-sha1 = "27415f162e6028e81c72b82ef756bf321213b6ec"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.10"

[[deps.FastBroadcast]]
deps = ["ArrayInterface", "LinearAlgebra", "Polyester", "Static", "StaticArrayInterface", "StrideArraysCore"]
git-tree-sha1 = "a6e756a880fc419c8b41592010aebe6a5ce09136"
uuid = "7034ab61-46d4-4ed7-9d0f-46aef9175898"
version = "0.2.8"

[[deps.FastClosures]]
git-tree-sha1 = "acebe244d53ee1b461970f8910c235b259e772ef"
uuid = "9aa1b823-49e4-5ca5-8b0f-3971ec8bab6a"
version = "0.3.2"

[[deps.FastLapackInterface]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "0a59c7d1002f3131de53dc4568a47d15a44daef7"
uuid = "29a986be-02c6-4525-aec4-84b980013641"
version = "2.0.2"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "82d8afa92ecf4b52d78d869f038ebfb881267322"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.3"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random"]
git-tree-sha1 = "5b93957f6dcd33fc343044af3d48c215be2562f1"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.9.3"

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

    [deps.FillArrays.weakdeps]
    PDMats = "90014a1f-27ba-587c-ab20-58faa44d9150"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.FiniteDiff]]
deps = ["ArrayInterface", "LinearAlgebra", "Requires", "Setfield", "SparseArrays"]
git-tree-sha1 = "bc0c5092d6caaea112d3c8e3b238d61563c58d5f"
uuid = "6a86dc24-6348-571c-b903-95158fe2bd41"
version = "2.23.0"

    [deps.FiniteDiff.extensions]
    FiniteDiffBandedMatricesExt = "BandedMatrices"
    FiniteDiffBlockBandedMatricesExt = "BlockBandedMatrices"
    FiniteDiffStaticArraysExt = "StaticArrays"

    [deps.FiniteDiff.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "cf0fe81336da9fb90944683b8c41984b08793dad"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.36"
weakdeps = ["StaticArrays"]

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

[[deps.FunctionWrappers]]
git-tree-sha1 = "d62485945ce5ae9c0c48f124a84998d755bae00e"
uuid = "069b7b12-0de2-55c6-9aab-29f3d0a68a2e"
version = "1.1.3"

[[deps.FunctionWrappersWrappers]]
deps = ["FunctionWrappers"]
git-tree-sha1 = "b104d487b34566608f8b4e1c39fb0b10aa279ff8"
uuid = "77dc65aa-8811-40c2-897b-53d922fa7daf"
version = "0.1.3"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "ec632f177c0d990e64d955ccc1b8c04c485a0950"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.6"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "899050ace26649433ef1af25bc17a815b3db52b7"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.9.0"

[[deps.HostCPUFeatures]]
deps = ["BitTwiddlingConvenienceFunctions", "IfElse", "Libdl", "Static"]
git-tree-sha1 = "eb8fed28f4994600e29beef49744639d985a04b2"
uuid = "3e5b6fbb-0976-4d2c-9146-d79de83f2fb0"
version = "0.1.16"

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
git-tree-sha1 = "8b72179abc660bfab5e28472e019392b97d0985c"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.4"

[[deps.IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[deps.ImageAxes]]
deps = ["AxisArrays", "ImageBase", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "2e4520d67b0cef90865b3ef727594d2a58e0e1f8"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.11"

[[deps.ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "eb49b82c172811fd2c86759fa0553a2221feb909"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.7"

[[deps.ImageCore]]
deps = ["ColorVectorSpace", "Colors", "FixedPointNumbers", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "PrecompileTools", "Reexport"]
git-tree-sha1 = "b2a7eaa169c13f5bcae8131a83bc30eff8f71be0"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.10.2"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "bca20b2f5d00c4fbc192c3212da8fa79f4688009"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.7"

[[deps.ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "355e2b974f2e3212a75dfb60519de21361ad3cb7"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.9"

[[deps.ImageShow]]
deps = ["Base64", "ColorSchemes", "FileIO", "ImageBase", "ImageCore", "OffsetArrays", "StackViews"]
git-tree-sha1 = "3b5344bcdbdc11ad58f3b1956709b5b9345355de"
uuid = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
version = "0.3.8"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "3d09a9f60edf77f8a4d99f9e015e8fbf9989605d"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.7+0"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "ea8031dea4aff6bd41f1df8f2fdfb25b33626381"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.4"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "5fdf2fe6724d8caabf43b557b84ce53f3b7e2f6b"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2024.0.2+0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

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
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IterTools]]
git-tree-sha1 = "42d5f897009e7ff2cf88db414a389e5ed1bdd023"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.10.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

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
git-tree-sha1 = "3336abae9a713d2210bb57ab484b1e065edd7d23"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.0.2+0"

[[deps.KLU]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse_jll"]
git-tree-sha1 = "07649c499349dad9f08dde4243a4c597064663e9"
uuid = "ef3ab10e-7fda-4108-b977-705223b18434"
version = "0.6.0"

[[deps.Krylov]]
deps = ["LinearAlgebra", "Printf", "SparseArrays"]
git-tree-sha1 = "8a6837ec02fe5fb3def1abc907bb802ef11a0729"
uuid = "ba0b0d4f-ebba-5204-a429-3ac8c609bfb7"
version = "0.9.5"

[[deps.LayoutPointers]]
deps = ["ArrayInterface", "LinearAlgebra", "ManualMemory", "SIMDTypes", "Static", "StaticArrayInterface"]
git-tree-sha1 = "62edfee3211981241b57ff1cedf4d74d79519277"
uuid = "10f19ff3-798f-405d-979b-55457f8fc047"
version = "0.1.15"

[[deps.LazyArrays]]
deps = ["ArrayLayouts", "FillArrays", "LinearAlgebra", "MacroTools", "MatrixFactorizations", "SparseArrays"]
git-tree-sha1 = "9cfca23ab83b0dfac93cb1a1ef3331ab9fe596a5"
uuid = "5078a376-72f3-5289-bfd5-ec5146d43c02"
version = "1.8.3"
weakdeps = ["StaticArrays"]

    [deps.LazyArrays.extensions]
    LazyArraysStaticArraysExt = "StaticArrays"

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

[[deps.LineSearches]]
deps = ["LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "Printf"]
git-tree-sha1 = "7bbea35cec17305fc70a0e5b4641477dc0789d9d"
uuid = "d3d80556-e9d4-5f37-9878-2ab0fcc64255"
version = "7.2.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LinearSolve]]
deps = ["ArrayInterface", "ChainRulesCore", "ConcreteStructs", "DocStringExtensions", "EnumX", "FastLapackInterface", "GPUArraysCore", "InteractiveUtils", "KLU", "Krylov", "Libdl", "LinearAlgebra", "MKL_jll", "Markdown", "PrecompileTools", "Preferences", "RecursiveFactorization", "Reexport", "SciMLBase", "SciMLOperators", "Setfield", "SparseArrays", "Sparspak", "StaticArraysCore", "UnPack"]
git-tree-sha1 = "73d8f61f8d27f279edfbafc93faaea93ea447e94"
uuid = "7ed4a6bd-45f5-4d41-b270-4a48e9bafcae"
version = "2.27.0"

    [deps.LinearSolve.extensions]
    LinearSolveBandedMatricesExt = "BandedMatrices"
    LinearSolveBlockDiagonalsExt = "BlockDiagonals"
    LinearSolveCUDAExt = "CUDA"
    LinearSolveEnzymeExt = ["Enzyme", "EnzymeCore"]
    LinearSolveFastAlmostBandedMatricesExt = ["FastAlmostBandedMatrices"]
    LinearSolveHYPREExt = "HYPRE"
    LinearSolveIterativeSolversExt = "IterativeSolvers"
    LinearSolveKernelAbstractionsExt = "KernelAbstractions"
    LinearSolveKrylovKitExt = "KrylovKit"
    LinearSolveMetalExt = "Metal"
    LinearSolvePardisoExt = "Pardiso"
    LinearSolveRecursiveArrayToolsExt = "RecursiveArrayTools"

    [deps.LinearSolve.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockDiagonals = "0a1fb500-61f7-11e9-3c65-f5ef3456f9f0"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"
    EnzymeCore = "f151be2c-9106-41f4-ab19-57ee4f262869"
    FastAlmostBandedMatrices = "9d29842c-ecb8-4973-b1e9-a27b1157504e"
    HYPRE = "b5ffcf37-a2bd-41ab-a3da-4bd9bc8ad771"
    IterativeSolvers = "42fd0dbc-a981-5370-80f2-aaf504508153"
    KernelAbstractions = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
    KrylovKit = "0b1a1467-8014-51b9-945f-bf0ae24f4b77"
    Metal = "dde4c033-4e86-420c-a63e-0dd931031962"
    Pardiso = "46dd5b70-b6fb-5a00-ae2d-e8fea33afaf2"
    RecursiveArrayTools = "731186ca-8d62-57ce-b412-fbd966d074cd"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "18144f3e9cbe9b15b070288eef858f71b291ce37"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.27"

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

[[deps.LoopVectorization]]
deps = ["ArrayInterface", "CPUSummary", "CloseOpenIntervals", "DocStringExtensions", "HostCPUFeatures", "IfElse", "LayoutPointers", "LinearAlgebra", "OffsetArrays", "PolyesterWeave", "PrecompileTools", "SIMDTypes", "SLEEFPirates", "Static", "StaticArrayInterface", "ThreadingUtilities", "UnPack", "VectorizationBase"]
git-tree-sha1 = "0f5648fbae0d015e3abe5867bca2b362f67a5894"
uuid = "bdcacae8-1622-11e9-2a5c-532679323890"
version = "0.12.166"
weakdeps = ["ChainRulesCore", "ForwardDiff", "SpecialFunctions"]

    [deps.LoopVectorization.extensions]
    ForwardDiffExt = ["ChainRulesCore", "ForwardDiff"]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl"]
git-tree-sha1 = "72dc3cf284559eb8f53aa593fe62cb33f83ed0c0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2024.0.0+0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.ManualMemory]]
git-tree-sha1 = "bcaef4fc7a0cfe2cba636d84cda54b5e4e4ca3cd"
uuid = "d125e4d3-2237-4719-b19c-fa641b8a4667"
version = "0.1.8"

[[deps.MappedArrays]]
git-tree-sha1 = "2dab0221fe2b0f2cb6754eaa743cc266339f527e"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.2"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MatrixFactorizations]]
deps = ["ArrayLayouts", "LinearAlgebra", "Printf", "Random"]
git-tree-sha1 = "78f6e33434939b0ac9ba1df81e6d005ee85a7396"
uuid = "a3b82374-2e81-5b9e-98ce-41277c0e4c87"
version = "2.1.0"

[[deps.MaybeInplace]]
deps = ["ArrayInterface", "LinearAlgebra", "MacroTools", "SparseArrays"]
git-tree-sha1 = "a85c6a98c9e5a2a7046bc1bb89f28a3241e1de4d"
uuid = "bb5d69b7-63fc-4a16-80bd-7e42200c7bdb"
version = "0.1.1"

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

[[deps.MuladdMacro]]
git-tree-sha1 = "cac9cc5499c25554cba55cd3c30543cff5ca4fab"
uuid = "46d2c3a1-f734-5fdb-9937-b9b9aeba4221"
version = "0.2.4"

[[deps.NLSolversBase]]
deps = ["DiffResults", "Distributed", "FiniteDiff", "ForwardDiff"]
git-tree-sha1 = "a0b464d183da839699f4c79e7606d9d186ec172c"
uuid = "d41bc354-129a-5804-8e4c-c37616107c6c"
version = "7.8.3"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore", "ImageMetadata"]
git-tree-sha1 = "d92b107dbb887293622df7697a2223f9f8176fcd"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.1.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.NonlinearSolve]]
deps = ["ADTypes", "ArrayInterface", "ConcreteStructs", "DiffEqBase", "FastBroadcast", "FastClosures", "FiniteDiff", "ForwardDiff", "LazyArrays", "LineSearches", "LinearAlgebra", "LinearSolve", "MaybeInplace", "PrecompileTools", "Preferences", "Printf", "RecursiveArrayTools", "Reexport", "SciMLBase", "SimpleNonlinearSolve", "SparseArrays", "SparseDiffTools", "StaticArraysCore", "TimerOutputs"]
git-tree-sha1 = "d52bac2b94358b4b960cbfb896d5193d67f3ff09"
uuid = "8913a72c-1f9b-4ce2-8d82-65094dcecaec"
version = "3.8.0"

    [deps.NonlinearSolve.extensions]
    NonlinearSolveBandedMatricesExt = "BandedMatrices"
    NonlinearSolveFastLevenbergMarquardtExt = "FastLevenbergMarquardt"
    NonlinearSolveFixedPointAccelerationExt = "FixedPointAcceleration"
    NonlinearSolveLeastSquaresOptimExt = "LeastSquaresOptim"
    NonlinearSolveMINPACKExt = "MINPACK"
    NonlinearSolveNLSolversExt = "NLSolvers"
    NonlinearSolveNLsolveExt = "NLsolve"
    NonlinearSolveSIAMFANLEquationsExt = "SIAMFANLEquations"
    NonlinearSolveSpeedMappingExt = "SpeedMapping"
    NonlinearSolveSymbolicsExt = "Symbolics"
    NonlinearSolveZygoteExt = "Zygote"

    [deps.NonlinearSolve.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    FastLevenbergMarquardt = "7a0df574-e128-4d35-8cbd-3d84502bf7ce"
    FixedPointAcceleration = "817d07cb-a79a-5c30-9a31-890123675176"
    LeastSquaresOptim = "0fc2ff8b-aaa3-5acd-a817-1944a5e08891"
    MINPACK = "4854310b-de5a-5eb6-a2a5-c1dee2bd17f9"
    NLSolvers = "337daf1e-9722-11e9-073e-8b9effe078ba"
    NLsolve = "2774e3e8-f4cf-5e23-947b-6d7e65073b56"
    SIAMFANLEquations = "084e46ad-d928-497d-ad5e-07fa361a48c4"
    SpeedMapping = "f1835b91-879b-4a3f-a438-e4baacf14412"
    Symbolics = "0c5d862f-8b57-4792-8d23-62f2024744c7"
    Zygote = "e88e6eb3-aa80-5325-afca-941959d7151f"

[[deps.OffsetArrays]]
git-tree-sha1 = "6a731f2b5c03157418a20c12195eb4b74c8f8621"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.13.0"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "a4ca623df1ae99d09bc9868b008262d0c0ac1e4f"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.4+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "67186a2bc9a90f9f85ff3cc8277868961fb57cbd"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.4.3"

[[deps.PackageExtensionCompat]]
git-tree-sha1 = "fb28e33b8a95c4cee25ce296c817d89cc2e53518"
uuid = "65ce6f38-6b18-4e1d-a461-8949797d7930"
version = "1.0.2"
weakdeps = ["Requires", "TOML"]

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "0fac6313486baae819364c52b4f483450a9d793f"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.12"

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
git-tree-sha1 = "71a22244e352aa8c5f0f2adde4150f62368a3f2e"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.58"

[[deps.Polyester]]
deps = ["ArrayInterface", "BitTwiddlingConvenienceFunctions", "CPUSummary", "IfElse", "ManualMemory", "PolyesterWeave", "Requires", "Static", "StaticArrayInterface", "StrideArraysCore", "ThreadingUtilities"]
git-tree-sha1 = "8df43bbe60029526dd628af7e9951f5af680d4d7"
uuid = "f517fe37-dbe3-4b94-8317-1923a5111588"
version = "0.7.10"

[[deps.PolyesterWeave]]
deps = ["BitTwiddlingConvenienceFunctions", "CPUSummary", "IfElse", "Static", "ThreadingUtilities"]
git-tree-sha1 = "240d7170f5ffdb285f9427b92333c3463bf65bf6"
uuid = "1d0040c9-8b98-4ee7-8388-3f51789ca0ad"
version = "0.2.1"

[[deps.PreallocationTools]]
deps = ["Adapt", "ArrayInterface", "ForwardDiff"]
git-tree-sha1 = "b6665214f2d0739f2d09a17474dd443b9139784a"
uuid = "d236fae5-4411-538c-8e31-a6e3d9e00b46"
version = "0.4.20"

    [deps.PreallocationTools.extensions]
    PreallocationToolsReverseDiffExt = "ReverseDiff"

    [deps.PreallocationTools.weakdeps]
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"

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

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "763a8ceb07833dd51bb9e3bbca372de32c0605ad"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.10.0"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "18e8f4d1426e965c7b532ddd260599e1510d26ce"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.0"

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

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecursiveArrayTools]]
deps = ["Adapt", "ArrayInterface", "DocStringExtensions", "GPUArraysCore", "IteratorInterfaceExtensions", "LinearAlgebra", "RecipesBase", "SparseArrays", "StaticArraysCore", "Statistics", "SymbolicIndexingInterface", "Tables"]
git-tree-sha1 = "a94d22ca9ad49a7a169ecbc5419c59b9793937cc"
uuid = "731186ca-8d62-57ce-b412-fbd966d074cd"
version = "3.12.0"

    [deps.RecursiveArrayTools.extensions]
    RecursiveArrayToolsFastBroadcastExt = "FastBroadcast"
    RecursiveArrayToolsForwardDiffExt = "ForwardDiff"
    RecursiveArrayToolsMeasurementsExt = "Measurements"
    RecursiveArrayToolsMonteCarloMeasurementsExt = "MonteCarloMeasurements"
    RecursiveArrayToolsReverseDiffExt = ["ReverseDiff", "Zygote"]
    RecursiveArrayToolsTrackerExt = "Tracker"
    RecursiveArrayToolsZygoteExt = "Zygote"

    [deps.RecursiveArrayTools.weakdeps]
    FastBroadcast = "7034ab61-46d4-4ed7-9d0f-46aef9175898"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    MonteCarloMeasurements = "0987c9cc-fe09-11e8-30f0-b96dd679fdca"
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"
    Zygote = "e88e6eb3-aa80-5325-afca-941959d7151f"

[[deps.RecursiveFactorization]]
deps = ["LinearAlgebra", "LoopVectorization", "Polyester", "PrecompileTools", "StrideArraysCore", "TriangularSolve"]
git-tree-sha1 = "8bc86c78c7d8e2a5fe559e3721c0f9c9e303b2ed"
uuid = "f2c3362d-daeb-58d1-803e-2bc74f2840b4"
version = "0.2.21"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.RuntimeGeneratedFunctions]]
deps = ["ExprTools", "SHA", "Serialization"]
git-tree-sha1 = "6aacc5eefe8415f47b3e34214c1d79d2674a0ba2"
uuid = "7e49a35a-f44a-4d26-94aa-eba1b4ca6b47"
version = "0.5.12"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMDTypes]]
git-tree-sha1 = "330289636fb8107c5f32088d2741e9fd7a061a5c"
uuid = "94e857df-77ce-4151-89e5-788b33177be4"
version = "0.1.0"

[[deps.SLEEFPirates]]
deps = ["IfElse", "Static", "VectorizationBase"]
git-tree-sha1 = "3aac6d68c5e57449f5b9b865c9ba50ac2970c4cf"
uuid = "476501e8-09a2-5ece-8869-fb82de89a1fa"
version = "0.6.42"

[[deps.SciMLBase]]
deps = ["ADTypes", "ArrayInterface", "CommonSolve", "ConstructionBase", "Distributed", "DocStringExtensions", "EnumX", "FunctionWrappersWrappers", "IteratorInterfaceExtensions", "LinearAlgebra", "Logging", "Markdown", "PrecompileTools", "Preferences", "Printf", "RecipesBase", "RecursiveArrayTools", "Reexport", "RuntimeGeneratedFunctions", "SciMLOperators", "SciMLStructures", "StaticArraysCore", "Statistics", "SymbolicIndexingInterface", "Tables"]
git-tree-sha1 = "48f724c6a3355f11dae5f762983073d367c8b934"
uuid = "0bca4576-84f4-4d90-8ffe-ffa030f20462"
version = "2.30.1"

    [deps.SciMLBase.extensions]
    SciMLBaseChainRulesCoreExt = "ChainRulesCore"
    SciMLBaseMakieExt = "Makie"
    SciMLBasePartialFunctionsExt = "PartialFunctions"
    SciMLBasePyCallExt = "PyCall"
    SciMLBasePythonCallExt = "PythonCall"
    SciMLBaseRCallExt = "RCall"
    SciMLBaseZygoteExt = "Zygote"

    [deps.SciMLBase.weakdeps]
    ChainRules = "082447d4-558c-5d27-93f4-14fc19e9eca2"
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    Makie = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
    PartialFunctions = "570af359-4316-4cb7-8c74-252c00c2016b"
    PyCall = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
    PythonCall = "6099a3de-0909-46bc-b1f4-468b9a2dfc0d"
    RCall = "6f49c342-dc21-5d91-9882-a32aef131414"
    Zygote = "e88e6eb3-aa80-5325-afca-941959d7151f"

[[deps.SciMLOperators]]
deps = ["ArrayInterface", "DocStringExtensions", "LinearAlgebra", "MacroTools", "Setfield", "SparseArrays", "StaticArraysCore"]
git-tree-sha1 = "10499f619ef6e890f3f4a38914481cc868689cd5"
uuid = "c0aeaf25-5076-4817-a8d5-81caf7dfa961"
version = "0.3.8"

[[deps.SciMLStructures]]
git-tree-sha1 = "5833c10ce83d690c124beedfe5f621b50b02ba4d"
uuid = "53ae85a6-f571-4167-b2af-e1d143709226"
version = "1.1.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.SimpleNonlinearSolve]]
deps = ["ADTypes", "ArrayInterface", "ConcreteStructs", "DiffEqBase", "DiffResults", "FastClosures", "FiniteDiff", "ForwardDiff", "LinearAlgebra", "MaybeInplace", "PrecompileTools", "Reexport", "SciMLBase", "StaticArraysCore"]
git-tree-sha1 = "a535ae5083708f59e75d5bb3042c36d1be9bc778"
uuid = "727e6d20-b764-4bd8-a329-72de5adea6c7"
version = "1.6.0"

    [deps.SimpleNonlinearSolve.extensions]
    SimpleNonlinearSolveChainRulesCoreExt = "ChainRulesCore"
    SimpleNonlinearSolvePolyesterForwardDiffExt = "PolyesterForwardDiff"
    SimpleNonlinearSolveReverseDiffExt = "ReverseDiff"
    SimpleNonlinearSolveStaticArraysExt = "StaticArrays"
    SimpleNonlinearSolveTrackerExt = "Tracker"
    SimpleNonlinearSolveZygoteExt = "Zygote"

    [deps.SimpleNonlinearSolve.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    PolyesterForwardDiff = "98d1487c-24ca-40b6-b7ab-df2af84e126b"
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"
    Zygote = "e88e6eb3-aa80-5325-afca-941959d7151f"

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

[[deps.SparseDiffTools]]
deps = ["ADTypes", "Adapt", "ArrayInterface", "Compat", "DataStructures", "FiniteDiff", "ForwardDiff", "Graphs", "LinearAlgebra", "PackageExtensionCompat", "Random", "Reexport", "SciMLOperators", "Setfield", "SparseArrays", "StaticArrayInterface", "StaticArrays", "Tricks", "UnPack", "VertexSafeGraphs"]
git-tree-sha1 = "a616ac46c38da60ac05cecf52064d44732edd05e"
uuid = "47a9eef4-7e08-11e9-0b38-333d64bd3804"
version = "2.17.0"

    [deps.SparseDiffTools.extensions]
    SparseDiffToolsEnzymeExt = "Enzyme"
    SparseDiffToolsPolyesterExt = "Polyester"
    SparseDiffToolsPolyesterForwardDiffExt = "PolyesterForwardDiff"
    SparseDiffToolsSymbolicsExt = "Symbolics"
    SparseDiffToolsZygoteExt = "Zygote"

    [deps.SparseDiffTools.weakdeps]
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"
    Polyester = "f517fe37-dbe3-4b94-8317-1923a5111588"
    PolyesterForwardDiff = "98d1487c-24ca-40b6-b7ab-df2af84e126b"
    Symbolics = "0c5d862f-8b57-4792-8d23-62f2024744c7"
    Zygote = "e88e6eb3-aa80-5325-afca-941959d7151f"

[[deps.Sparspak]]
deps = ["Libdl", "LinearAlgebra", "Logging", "OffsetArrays", "Printf", "SparseArrays", "Test"]
git-tree-sha1 = "342cf4b449c299d8d1ceaf00b7a49f4fbc7940e7"
uuid = "e56a9233-b9d6-4f03-8d0f-1825330902ac"
version = "0.3.9"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e2cfc4012a19088254b3950b85c3c1d8882d864d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.3.1"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.Static]]
deps = ["IfElse"]
git-tree-sha1 = "d2fdac9ff3906e27f7a618d47b676941baa6c80c"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.8.10"

[[deps.StaticArrayInterface]]
deps = ["ArrayInterface", "Compat", "IfElse", "LinearAlgebra", "PrecompileTools", "Requires", "SparseArrays", "Static", "SuiteSparse"]
git-tree-sha1 = "5d66818a39bb04bf328e92bc933ec5b4ee88e436"
uuid = "0d7ed370-da01-4f52-bd93-41d350b8b718"
version = "1.5.0"
weakdeps = ["OffsetArrays", "StaticArrays"]

    [deps.StaticArrayInterface.extensions]
    StaticArrayInterfaceOffsetArraysExt = "OffsetArrays"
    StaticArrayInterfaceStaticArraysExt = "StaticArrays"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "bf074c045d3d5ffd956fa0a461da38a44685d6b2"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.3"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StrideArraysCore]]
deps = ["ArrayInterface", "CloseOpenIntervals", "IfElse", "LayoutPointers", "ManualMemory", "SIMDTypes", "Static", "StaticArrayInterface", "ThreadingUtilities"]
git-tree-sha1 = "d6415f66f3d89c615929af907fdc6a3e17af0d8c"
uuid = "7792a7ef-975c-4747-a70f-980b88e8d1da"
version = "0.5.2"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.SymbolicIndexingInterface]]
deps = ["MacroTools", "RuntimeGeneratedFunctions"]
git-tree-sha1 = "f7b1fc9fc2bc938436b7684c243be7d317919056"
uuid = "2efcf032-c050-4f8e-a9bb-153293bab1f5"
version = "0.3.11"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "cb76cf677714c095e535e3501ac7954732aeea2d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.1"

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

[[deps.ThreadingUtilities]]
deps = ["ManualMemory"]
git-tree-sha1 = "eda08f7e9818eb53661b3deb74e3159460dfbc27"
uuid = "8290d209-cae3-49c0-8002-c8c24d57dab5"
version = "0.5.2"

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "34cc045dd0aaa59b8bbe86c644679bc57f1d5bd0"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.6.8"

[[deps.TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "f548a9e9c490030e545f72074a41edfd0e5bcdd7"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.23"

[[deps.TriangularSolve]]
deps = ["CloseOpenIntervals", "IfElse", "LayoutPointers", "LinearAlgebra", "LoopVectorization", "Polyester", "Static", "VectorizationBase"]
git-tree-sha1 = "fadebab77bf3ae041f77346dd1c290173da5a443"
uuid = "d5829a12-d9aa-46ab-831f-fb7c9ab06edf"
version = "0.1.20"

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.TruncatedStacktraces]]
deps = ["InteractiveUtils", "MacroTools", "Preferences"]
git-tree-sha1 = "ea3e54c2bdde39062abf5a9758a23735558705e1"
uuid = "781d530d-4396-4725-bb49-402e4bee1e77"
version = "1.4.0"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.VectorizationBase]]
deps = ["ArrayInterface", "CPUSummary", "HostCPUFeatures", "IfElse", "LayoutPointers", "Libdl", "LinearAlgebra", "SIMDTypes", "Static", "StaticArrayInterface"]
git-tree-sha1 = "7209df901e6ed7489fe9b7aa3e46fb788e15db85"
uuid = "3d5dd08c-fd9d-11e8-17fa-ed2836048c2f"
version = "0.21.65"

[[deps.VertexSafeGraphs]]
deps = ["Graphs"]
git-tree-sha1 = "8351f8d73d7e880bfc042a8b6922684ebeafb35c"
uuid = "19fa3120-7c27-5ec5-8db8-b0b0aa330d6f"
version = "0.2.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "d7015d2e18a5fd9a4f47de711837e980519781a4"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.43+1"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "libpng_jll"]
git-tree-sha1 = "d4f63314c8aa1e48cd22aa0c17ed76cd1ae48c3c"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.3+0"

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
# ╠═b7895bd2-7634-11eb-211e-ef876d23bd88
# ╟─230b0118-30b7-4035-ad31-520165a76fcc
# ╠═6b473b2d-4326-46b4-af38-07b61de287fc
# ╟─230cba36-9d0a-4726-9e55-7df2c6743968
# ╟─85fba8fb-a9ea-444d-831b-ec6489b58b4f
# ╟─890d30b9-2cd0-4d3a-99f6-f7d3d7858fda
# ╟─96766502-7a06-11eb-00cc-29849773dbcf
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
# ╟─5d656494-7a78-11eb-12e8-d17856bd8c4d
# ╟─b0e6d1ac-7a7d-11eb-0a9e-1310dcb5957f
# ╟─7e4ad37c-7a84-11eb-1490-25090e133a7c
# ╟─96f47252-7a84-11eb-3d18-e3ba79dd20c2
# ╟─ae5b3a32-7a84-11eb-04c0-337a74105a58
# ╟─c9f2b61e-7a84-11eb-3841-33739a226ff9
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
# ╠═30f522a0-7a8e-11eb-2181-8313760778ef
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
# ╟─c536dafb-4206-4689-ad6d-6935385d8fdf
# ╟─fb509fb4-9608-421d-9c40-a4375f459b3f
# ╠═55898e88-36a0-4f49-897f-e0850bd2b0df
# ╠═b754bae2-762f-11eb-1c6a-01251495a9bb
# ╠═83d45d42-7406-11eb-2a9c-e75efe62b12c
# ╟─2e8c4a48-d535-44ac-a1f1-4cb26c4aece6
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
