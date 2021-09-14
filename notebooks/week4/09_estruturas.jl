### A Pluto.jl notebook ###
# v0.16.0

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

# ╔═╡ 864e1180-f693-11ea-080e-a7d5aabc9ca5
begin
    import ImageIO, PNGFiles
    using Colors, ColorVectorSpace, ImageShow, FileIO
    using ImageShow.ImageCore
    using ColorSchemes

    using InteractiveUtils, PlutoUI
    using LinearAlgebra, SparseArrays, Statistics
end

# ╔═╡ bd88de2a-60c8-4df8-91aa-960efb470f0e
md"Tradução livre de [structure.jl](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week4/structure.jl)."

# ╔═╡ ca1a1072-81b6-11eb-1fee-e7df687cc314
PlutoUI.TableOfContents(aside = true)

# ╔═╡ b0ba5b8c-f5d1-11ea-1304-3f0e47f935fe
md"# Exemplos de estrututura"

# ╔═╡ 261c4df2-f5d2-11ea-2c72-7d4b09c46098
md"""
# Vetores _One-hot_

Esse é um exemplo de aprendizatem de máquina.
"""

# ╔═╡ 3cada3a0-81cc-11eb-04c8-bde26d36a84e
md"""
O pessoal de aprendizagem de máquina adora dar nomes para objetos que já conhecemos. Por exemplo, eles chamam de vetores _one-hot_ (não consigo pensar em uma tradução razoável para isso), vetores que possuem um único elemento "quente". Isto é, vetores que possuem um único 1 em um "mar" de zeros. Nós, chamamos isso de vetores canônicos...

Por exemplo:
"""

# ╔═╡ fe2028ba-f6dc-11ea-0228-938a81a91ace
myonehatvector = [0, 1, 0, 0, 0, 0]

# ╔═╡ 8d2c6910-f5d4-11ea-1928-1baf09815687
md"""Quanta "informação" você precisa para rpresentar vetores _1-hot_? Seriam n valores ou apenas dois?
"""

# ╔═╡ 54649792-81cc-11eb-1038-9161a4037acf
md"""
Obs: também podemos falar de votores "1-cold": 
"""

# ╔═╡ 0a902426-f6dd-11ea-0ae4-fb0c47863fe7
# also one "cold"
1 .- myonehatvector

# ╔═╡ 4794e860-81b7-11eb-2c91-8561c20f308a
md"""
## Julia: `structs` (criando novos tipos em Julia)
"""

# ╔═╡ 67827da8-81cc-11eb-300e-278104d2d958
md"""
Julia permite a criação de novos tipos. Como exemplo, vamos criar um tipo para representar vetores _1-hot_. Ele será um subtipo de `AbstractVector`. Isso significa que ele deve se *comportar como* um vetor.
"""

# ╔═╡ 4624cd26-f5d3-11ea-1cf8-7d6555eae5fa
struct OneHot <: AbstractVector{Int}
    n::Int
    k::Int
end

# ╔═╡ 9bdabef8-81cc-11eb-14a1-67a9a7d968c0
md"""
Pronto, decicimos por manter uma implementação que economiza memória (o que é meio que óbvio nesse caso). Agora a nossa tarefa é implementar os métodos que lidam com vetores. Dessa maneira eles poderão ser usados como vetores. O segredo aqui é usar o despacho múltiplo, especializando funções em métodos específicos para o nosso novo tipo. Isso é similar ao que foi feito na aula sobre otimização diâmica, quando criamos nosso próprio iterador que gerava todos os possíveis caminhos descendentes.

Inicialmente vamos definir a função que diz qual o comprimento do vetor:
"""

# ╔═╡ 397ac764-f5fe-11ea-20cc-8d7cab19d410
Base.size(x::OneHot) = (x.n,)

# ╔═╡ a22dcd2c-81cc-11eb-1252-13ace134192d
md"""
Agora, a função que extrai o i-ésimo componente. Essa é a função que é chamada quando indexamos um vetor usando colchetes:
"""

# ╔═╡ 82c7046c-f5d3-11ea-04e2-ef7c0f4db5da
Base.getindex(x::OneHot, i::Int) = Int(x.k == i)

# ╔═╡ b024c318-81cc-11eb-018c-e1f7830ff51b
md"""
Obs: `x.k == i` devolve um valor booleando: `true` ou `false`. Mas o vetor _1-hot_ é um vetor de inteiros, então convertemos esse valor para inteiro passando o resultado para `Int`.
"""

# ╔═╡ 93bfe3ac-f756-11ea-20fb-8f7d586b42f3
myonehotvector = OneHot(6, 2)

# ╔═╡ 175039aa-f758-11ea-251a-5db57d7c4b32
myonehotvector[3]

# ╔═╡ c2a4b0a2-81cc-11eb-37a7-db601a6ddfdf
myonehotvector[2]

# ╔═╡ c5ed7d3e-81cc-11eb-3386-15b72db8155d
md"""
Uma variável desse tipo se comporta como se fosse um vetor, mas estamos apenas armazenando dois inteiros ao invés de n deles. Esse é um exemplo interessante de quando é melhor criar e usar sua própria estrutura.
"""

# ╔═╡ e2e354a8-81b7-11eb-311a-35151063c2a7
md"""
## Julia: dump and Dump
"""

# ╔═╡ dc5a96ba-81cc-11eb-3189-25920df48afa
md"""
Julia possui a função `dump` que apresenta os dados que estão armazenados no objeto que ela recebe como parâmetro:
"""

# ╔═╡ af0d3c22-f756-11ea-37d6-11b630d2314a
with_terminal() do
    dump(myonehotvector)
end

# ╔═╡ 06e3a842-26b8-4417-9cf5-8a083ccdb264
md"""
Porém, `dump` consegue apenas escrever em um terminal e por isso não podemos usá-la diretamente dentro do Pluto. Por isso passamos o código que queremos rodar para a função `with_terminal` (definida em `PlutoUI`) que captura a saída e apresenta em uma pequena janela de terminal. `PlutoUI` tem também a função `Dump` que captura a saída de dump e devolve num formato que Pluto entende:
"""

# ╔═╡ 91172a3e-81b7-11eb-0953-9f5e0207f863
Dump(myonehotvector)

# ╔═╡ 4bbf3f58-f788-11ea-0d24-6b0fb070829e
myonehotvector

# ╔═╡ fe70d104-81b7-11eb-14d0-eb5237d8ea6c
md"""
### Visualizando um vetor _1-hot_
"""

# ╔═╡ ef8f44b2-f5fc-11ea-1e4d-bd873cd39d6c
md"""
nn=$(@bind nn Slider(1:20, show_value=true))
"""

# ╔═╡ fd9211c0-f5fc-11ea-1745-7f2dae88af9e
md"""
kk=$(@bind kk Slider(1:nn, default=1, show_value=true))
"""

# ╔═╡ f1154df8-f693-11ea-3b16-f32835fcc470
x = OneHot(nn, kk)

# ╔═╡ 81c35324-f5d4-11ea-2338-9f982d38732c
md"# Matrizes diagonais"

# ╔═╡ 2cfda0dc-f5d5-11ea-16c4-b5a33b90e37f
md"Outro exemplo é o de matrizes diagonais. Uma primeiar forma inocente de represetá-las é usar matrizes usuais, colocando zero fora da diagonal:"

# ╔═╡ 150432d4-f5d5-11ea-32b2-19a2a91d9637
denseD = [
    5 0 0
    0 6 0
    0 0 -10
]

# ╔═╡ 44215aa4-f695-11ea-260e-b564c6fbcd4a
md"Mas Julia possui uma forma melhor de armazená-las:"

# ╔═╡ 21328d1c-f5d5-11ea-288e-4171ad35326d
D = Diagonal(denseD)

# ╔═╡ 75761cc0-81cd-11eb-1186-7d47debd68ca
md"""
Ela ainda se apresenta de forma simpática, com pontos no lugar dos zeros.

Ah, e é claro que podemos criar uma matriz diagonal simplesmente a partir dos valores que aparecem na diagonal:
"""

# ╔═╡ 6bd8a886-f758-11ea-2587-870a3fa9d710
Diagonal([5, 6, -10])

# ╔═╡ 4c533ac6-f695-11ea-3724-b955eaaeee49
md"Quanta informação é armazenada na sua representação interna? De novo podemos usar `Dump` para descobrir."

# ╔═╡ 466901ea-f5d5-11ea-1db5-abf82c96eabf
Dump(denseD)

# ╔═╡ b38c4aae-f5d5-11ea-39b6-7b0c7d529019
Dump(D)

# ╔═╡ 93e04ed8-81cd-11eb-214a-a761ef8c406f
md"""
Como podemos ver `Diagonal` armazena apenas os elementos da diagonal e não os zeros.
"""

# ╔═╡ e90c55fc-f5d5-11ea-10f1-470ff772985d
md"""Isso nos lembra que devemos sempre que possível procurar e aproveitar estrutura especial quando ela existir."""

# ╔═╡ 19775c3c-f5d6-11ea-15c2-89618e654a1e
md"# Matrizes esparsas"

# ╔═╡ 653792a8-f695-11ea-1ae0-43761c502583
md"A generalização natural dessa ideia é uma _matriz esparsa_. Um matriz é chamada de esparsa quando possui muitos zeros. Nesse caso pode ser melhor armazená-las em um formato que leve em conta a esparsidade:"

# ╔═╡ 79c94d2a-f75a-11ea-031d-09d70d229e15
denseM = [0 0 9; 0 0 0; 12 0 4]

# ╔═╡ 10bc5d50-81b9-11eb-2ac7-354a6c6c826b
md"""
De novo Julia já está preparada para essa situação e possui um tipo de matriz esparsa que armazena apenas os valores não nulos:
"""

# ╔═╡ 77d6a952-81ba-11eb-24e3-cb6510a59455
M = sparse(denseM)

# ╔═╡ 1f3ba55a-81b9-11eb-001f-593b9d8639ca
md"""
Há várias formas de se armazenar matrizes esparsas. A mais natural seria guardar triplas `(linhas, coluna, valor)`. Mas o pacote `SparseArrays.jl` de Julia usa um outro formato que é mais compacto, chamado de _colunas esparsas comprimidas` (_compressed sparse column_). Esse formato é mais favorável para operações matriciais tpipicas como produtos matriz vetor ou para obter rapidamente colunas da matriz. Nesse formato armazena-se:

* `nzval` contém o número de elementos não nulos da matriz
* `rowval` representa o índice `i` ou a linha de cada um dos `nzval` valores armazendados. Em particular:
  * `length(rowval) == length(nzval)`
* `colptr[j]` diz onde está o primeiro valor de cada coluna `j` ou da primeira coluna não nula posterior.
* A última entrada de `colptr` aponta para além de `nzval` para indicar que as colunas acabaram.
  * `length(colptr) == number of columns + 1`
"""

# ╔═╡ 3d4a702e-f75a-11ea-031c-333d591fc442
Dump(sparse(M))

# ╔═╡ 80ff4010-81bb-11eb-374e-215a57defb0b
md"""
Note que o formato CSC pode não ser ideal se houver muitas colunas "vazias", já que há sempre um valor armazenado em `colptr` por coluna:
"""

# ╔═╡ 5de72b7c-f5d6-11ea-1b6f-35b830b5fb34
# Creates a sparse matriz from row indices (I), column Indices (J), and values (V)
M2 = sparse([1, 2, 10^6], [4, 9, 10^6], [7, 8, 9])

# ╔═╡ 8b60629e-f5d6-11ea-27c8-d934460d3a57
with_terminal() do
    dump(M2)
end

# ╔═╡ 89baf831-84b9-4fa6-9374-a7acccfcdef1
md"E lembre, matrizes esparsas podem ser usadas como matrizes usuais:"

# ╔═╡ 2fd7e52e-f5d7-11ea-3b5a-1f338e2451e0
M3 = [1 0 2 0 10; 0 3 4 0 9; 0 0 0 5 8; 0 0 0 0 7]

# ╔═╡ 2e87d4fe-81bc-11eb-0d16-b988bcedcc73
M4 = 0 .* M3

# ╔═╡ cde79f38-f5d6-11ea-3297-0b5b240f7b9e
Dump(sparse(M4))

# ╔═╡ aa09c008-f5d8-11ea-1bdc-b51ee6eb2478
sparse(M4)

# ╔═╡ 62a6ec62-f5d9-11ea-071e-ed33c5dea0cd
md"""# Vetores aleatórios
"""

# ╔═╡ 7f63daf6-f695-11ea-0b80-8702a83103a4
md"Quanta estrutura há em um vetor _aleatório_?"

# ╔═╡ 67274c3c-f5d9-11ea-3475-c9d228e3bd5a
# Notem o detalhe do _ para separar dígitos em grupos de três e facilitar a leitura!
v = rand(1:9, 1_000_000)

# ╔═╡ 765c6552-f5d9-11ea-29d3-bfe7b4b04612
md"""Num primeiro momento, podemos pensar que não há "nenhuma estrutura". Por outro lado a aleatoridade em si é um tipo de estrutura. Isso porque essa aleatoridade obedece a uma lei de formação bem estabelicida (os números são obtidos de uma distribuição uniforme).

Por exemplo, alguns podem dizer que estrura da sequência aleatória é capturada pela média e o desvio padrão.

"""

# ╔═╡ 126fb3ea-f5da-11ea-2f7d-0b3259a296ce
mean(v), std(v), 5, sqrt(10 * 2 / 3)

# ╔═╡ ed0b2358-81ce-11eb-3339-93abcc06fd91
md"""
De fato, mesmo que repitamos a conta, gerando uma nova amostra de número aleatórios, a média e o desvio padrão mantém cerca de 3 a 4 dígitos inalterados. Eles são muito próximos dos respectivos valores teóricos que são os dois números da direita.
"""

# ╔═╡ 24ce92fa-81cf-11eb-30f0-b1e357d79d53
md"""
Podemos também contar quantas vezes cada dígito ocorre:
"""

# ╔═╡ 2d4500e0-81cf-11eb-1699-d310074fddf5
[sum(v .== i) for i = 1:9]

# ╔═╡ 3546ff30-81cf-11eb-3afc-05c5db61366f
md"""
E, como esperado, os dígitos ocorrem, grosseiramente, o mesmo número de vezes.
"""

# ╔═╡ 9b9e2c2a-f5da-11ea-369b-b513b196515b
md"Em suma, em alguns casos, estatíticos podem considerar que toda a informação necessária está resumida na mede e na variância. O resto poderia ser jogado fora."

# ╔═╡ e68b98ea-f5da-11ea-1a9d-db45e4f80241
m = sum(v) / length(v)  # mean

# ╔═╡ f20ccac4-f5da-11ea-0e69-413b5e49f423
σ² = sum((v .- m) .^ 2) / (length(v) - 1)

# ╔═╡ 12a2e96c-f5db-11ea-1c3e-494ae7446886
σ = sqrt(σ²)

# ╔═╡ 22487ce2-f5db-11ea-32e9-6f70ab2c0353
std(v)

# ╔═╡ 389ae62e-f5db-11ea-1557-c3adbbee0e5c
md"Mas é claro que em alguns casos isso não é o suficiente."

# ╔═╡ 0c2b6408-f5d9-11ea-2b7f-7fece2eecc1f
md"# Tabelas de multiplicação (ou matrizes de posto 1)"

# ╔═╡ 5d767290-f5dd-11ea-2189-81198fd216ce
outer(v, w) = [x * y for x ∈ v, y ∈ w]  # just a multiplication table

# ╔═╡ 587790ce-f6de-11ea-12d9-fde2a17ae314
outer(1:10, 1:10)

# ╔═╡ a39e8256-f6de-11ea-3170-c923b56609da
md"Fala a verdade: você ainda lembra de ficar decorando isso?"

# ╔═╡ 8c84edd0-f6de-11ea-2180-61c6b81aac3b
@bind k Slider(1:14, show_value = true)

# ╔═╡ 22b73baa-f6df-11ea-197f-bbb4bd1a7ef5
outer(1:k, 1:k)

# ╔═╡ b2332814-f6e6-11ea-1c7d-556c7d4687f1
outer([2, 4, 6], [10, 100, 1000])

# ╔═╡ 9ab7a72e-81cf-11eb-2b78-073ff51cae58
md"""
Uma tabela de multiplicação é claramente um tipo especial de estrutura, mas ela não é esparsa. Não há zeros. Por outro lado, é claro que podemos armazená-las usando muito menos informação e reconstruir um elemento arbitrário da matriz rapidamente.
"""

# ╔═╡ fd8dd108-f6df-11ea-2f7c-3d99d054ac15
md"No cado das tabelas simples 1:k times 1:k, toda informação é dada pelo número k."

# ╔═╡ 165788b2-f601-11ea-3e69-cdbbb6558e54
md"""Mas em casos mais gerais, que envolvem dois vetores "genéricos", a situação não é tão clara se olhamos os números."""

# ╔═╡ 22941bb8-f601-11ea-1d6e-0d955297bc2e
outer(rand(3), rand(4))  # but it's just a multiplication table

# ╔═╡ c33bf00e-81cf-11eb-1e1a-e5a879a45093
md"""
Já olhando uma representação por imagens, a hipótese parece mais plausível.
"""

# ╔═╡ 7ff664f0-f74b-11ea-0d2d-b53f19e4f4bf
md"Podemos tentar fatorar uma tabela de multiplicação se ela de fator for real:"

# ╔═╡ a0611eaa-81bc-11eb-1d23-c12ab14138b1
md"""
### Julia: exceções são lançadas (geradas) usando a função  `error`.

Uma exceção é qualquer coisa que leva a interrupção de um programa, por exemplo a identificação de dados inválidos ou uma divisão por 0.
"""

# ╔═╡ a4728944-f74b-11ea-03c3-9123908c1f8e
function factor(mult_table)
    v = mult_table[:, 1]
    w = mult_table[1, :]

    if v[1] ≠ 0
        w /= v[1]
    end

    # Good code has a check:
    if outer(v, w) ≈ mult_table
        return v, w
    else
        error("Input is not a multiplication table")
    end
end

# ╔═╡ cdbcd7ad-0f3d-4724-b207-f4d610672c5e
md"""
Mas notem que a fatoração não é única. De fato, a fatoração obtida é tal que o primeiro número do segundo vetor, `w`, é sempre 1.0.
"""

# ╔═╡ 05c35402-f752-11ea-2708-59cf5ef74fb4
factor(outer([1, 2, 3], [2, 2, 2]))

# ╔═╡ 8c11b19e-81bc-11eb-184b-bf6ffefe29de
md"""
Uma matriz aleatória 2x2 dificilmente será uma tabela de multiplicação. Assim como a maioria das matrizes.
"""

# ╔═╡ 8baaa994-f752-11ea-18d9-b3d0a6b9f7d9
factor(rand(2, 2))

# ╔═╡ d92bece4-f754-11ea-0242-99f198bb5b7b
md"Vamos somar duas (ou mais) tabelas de multiplicação:"

# ╔═╡ e740999c-f754-11ea-2089-4b7a9aec6030
A = sum(outer(rand(3), rand(3)) for i = 1:2)

# ╔═╡ 0a79a7b4-f755-11ea-1b2d-21173567b257
md"Será que é possível, a partir da matriz, recuperar a sua estrutura como soma de produtos externos (ou tabelas de multiplicação, ou matrizes de posto 1)?"

# ╔═╡ 5adb98c2-f6e0-11ea-1fde-53b0fd6639c3
md"A resposta é sim: para isso usamos a **decomposição em valores singulares** (SVD)."

# ╔═╡ 487d6f9c-81d0-11eb-3bb0-336a4beb9b38
md"""
Vamos tomar a SVD e calcular a soma de dois produtos externos:
"""

# ╔═╡ 5a493052-f601-11ea-2f5f-f940412905f2
begin
    U, Σ, V = svd(A)

    outer(U[:, 1], V[:, 1] * Σ[1]) + outer(U[:, 2], V[:, 2] * Σ[2])
end

# ╔═╡ 55b76aee-81d0-11eb-0bcc-413f5bd14360
md"""
E vemos que ela pode recuperar a matriz original!"
"""

# ╔═╡ 709bf30a-f755-11ea-2e82-bd511e598c77
B = rand(3, 3)

# ╔═╡ 782532b0-f755-11ea-1385-cd1a28c4b9d5
begin
    UU, ΣΣ, VV = svd(B)
    outer(UU[:, 1], VV[:, 1] * ΣΣ[1]) + outer(UU[:, 2], VV[:, 2] * ΣΣ[2])
end

# ╔═╡ 5bc4ab0a-f755-11ea-0fad-4987ad9fc02f
md"e ela consegue aproximar também!"

# ╔═╡ ebd72fb8-f5e0-11ea-0630-573337dff753
md"""
# Singular Value Decomposition (SVD): A tool to find structure
"""

# ╔═╡ b6478e1a-f5f6-11ea-3b92-6d4f067285f4
tree_url = "https://user-images.githubusercontent.com/6933510/110924885-d7f1b200-8322-11eb-9df7-7abf29c8db7d.png"

# ╔═╡ f2c11f88-f5f8-11ea-3e02-c1d4fa22031e
image = load(download(tree_url))

# ╔═╡ 29062f7a-f5f9-11ea-2682-1374e7694e32
picture = Float64.(channelview(image));

# ╔═╡ 5471fd30-f6e2-11ea-2cd7-7bd48c42db99
size(picture)

# ╔═╡ 6156fd1e-f5f9-11ea-06a9-211c7ab813a4
pr, pg, pb = eachslice(picture, dims = 1)

# ╔═╡ a9766e68-f5f9-11ea-0019-6f9d02050521
[RGB.(pr, 0, 0) RGB.(0, pg, 0) RGB.(0, 0, pb)]

# ╔═╡ 0c0ee362-f5f9-11ea-0f75-2d2810c88d65
begin
    Ur, Σr, Vr = svd(pr)
    Ug, Σg, Vg = svd(pg)
    Ub, Σb, Vb = svd(pb)
end;

# ╔═╡ b95ce51a-f632-11ea-3a64-f7c218b9b3c9
@bind n Slider(1:200, show_value = true)

# ╔═╡ 7ba6e6a6-f5fa-11ea-2bcd-616d5a3c898b
RGB.(
    sum(outer(Ur[:, i], Vr[:, i]) .* Σr[i] for i = 1:n),
    sum(outer(Ug[:, i], Vg[:, i]) .* Σg[i] for i = 1:n),
    sum(outer(Ub[:, i], Vb[:, i]) .* Σb[i] for i = 1:n),
)

# ╔═╡ 8df84fcc-f5d5-11ea-312f-bf2a3b3ce2ce
md"# Apêndice"

# ╔═╡ 0edd7cca-834f-11eb-0232-ff0850027f76
md"## O que aprendemos de Julia"

# ╔═╡ 69be8194-81b7-11eb-0452-0bc8b9f22286
md"""
O que aprendemos:

* Usamos `struct` para criar novos tipos que representam algum tipo específico.
* `dump` e `Dump`: são usados para ver o que está armazenada numa estrutura.
* `Diagonal`, `sparse`
* `error` (lança uma exceção)
* `svd` (Decomposição por valores singulare)
"""

# ╔═╡ 5813e1b2-f5ff-11ea-2849-a1def74fc065
begin
    show_image(M) = get.([ColorSchemes.rainbow], M ./ maximum(M))
    show_image(x::AbstractVector) = show_image(x')
end

# ╔═╡ 982590d4-f5ff-11ea-3802-73292c75ad6c
show_image(x)

# ╔═╡ 2f75df7e-f601-11ea-2fc2-aff4f335af33
show_image(outer(rand(10), rand(10)))

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ColorSchemes = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
ColorVectorSpace = "c3611d14-8923-5661-9e6a-0046d554d3a4"
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
ImageIO = "82e4d734-157c-48bb-816b-45c225c6df19"
ImageShow = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
InteractiveUtils = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PNGFiles = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
ColorSchemes = "~3.14.0"
ColorVectorSpace = "~0.9.5"
Colors = "~0.12.8"
FileIO = "~1.11.0"
ImageIO = "~0.5.8"
ImageShow = "~0.3.2"
PNGFiles = "~0.3.9"
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
git-tree-sha1 = "30ee06de5ff870b45c78f529a6b093b3323256a3"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.3.1"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "9995eb3977fbf67b86d0a0a0508e83017ded03f2"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.14.0"

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

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "727e463cfebd0c7b999bbf3e9e7e16f254b94193"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.34.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

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

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "2c1cf4df419938ece72de17f368a021ee162762e"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.0"

[[ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "4d4c9c69972c6f4db99a70d71c5cc074dd2abbf1"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.3"

[[ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "595155739d361589b3d074386f77c107a8ada6f7"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.2"

[[ImageIO]]
deps = ["FileIO", "Netpbm", "OpenEXR", "PNGFiles", "TiffImages", "UUIDs"]
git-tree-sha1 = "13c826abd23931d909e4c5538643d9691f62a617"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.5.8"

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
deps = ["ChainRulesCore", "DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "1f5097e3bce576e1cdf6dc9f051ab8c6e196b29e"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.1"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

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
git-tree-sha1 = "c870a0d713b51e4b49be6432eff0e26a4325afee"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.6"

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
git-tree-sha1 = "e14c485f6beee0c7a8dcf6128bf70b85f1fe201e"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.9"

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
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

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
# ╟─bd88de2a-60c8-4df8-91aa-960efb470f0e
# ╟─ca1a1072-81b6-11eb-1fee-e7df687cc314
# ╟─b0ba5b8c-f5d1-11ea-1304-3f0e47f935fe
# ╠═864e1180-f693-11ea-080e-a7d5aabc9ca5
# ╟─261c4df2-f5d2-11ea-2c72-7d4b09c46098
# ╟─3cada3a0-81cc-11eb-04c8-bde26d36a84e
# ╠═fe2028ba-f6dc-11ea-0228-938a81a91ace
# ╟─8d2c6910-f5d4-11ea-1928-1baf09815687
# ╟─54649792-81cc-11eb-1038-9161a4037acf
# ╟─0a902426-f6dd-11ea-0ae4-fb0c47863fe7
# ╟─4794e860-81b7-11eb-2c91-8561c20f308a
# ╟─67827da8-81cc-11eb-300e-278104d2d958
# ╠═4624cd26-f5d3-11ea-1cf8-7d6555eae5fa
# ╟─9bdabef8-81cc-11eb-14a1-67a9a7d968c0
# ╠═397ac764-f5fe-11ea-20cc-8d7cab19d410
# ╟─a22dcd2c-81cc-11eb-1252-13ace134192d
# ╠═82c7046c-f5d3-11ea-04e2-ef7c0f4db5da
# ╟─b024c318-81cc-11eb-018c-e1f7830ff51b
# ╠═93bfe3ac-f756-11ea-20fb-8f7d586b42f3
# ╠═175039aa-f758-11ea-251a-5db57d7c4b32
# ╠═c2a4b0a2-81cc-11eb-37a7-db601a6ddfdf
# ╟─c5ed7d3e-81cc-11eb-3386-15b72db8155d
# ╟─e2e354a8-81b7-11eb-311a-35151063c2a7
# ╟─dc5a96ba-81cc-11eb-3189-25920df48afa
# ╠═af0d3c22-f756-11ea-37d6-11b630d2314a
# ╟─06e3a842-26b8-4417-9cf5-8a083ccdb264
# ╠═91172a3e-81b7-11eb-0953-9f5e0207f863
# ╠═4bbf3f58-f788-11ea-0d24-6b0fb070829e
# ╠═fe70d104-81b7-11eb-14d0-eb5237d8ea6c
# ╟─ef8f44b2-f5fc-11ea-1e4d-bd873cd39d6c
# ╟─fd9211c0-f5fc-11ea-1745-7f2dae88af9e
# ╠═f1154df8-f693-11ea-3b16-f32835fcc470
# ╠═982590d4-f5ff-11ea-3802-73292c75ad6c
# ╠═81c35324-f5d4-11ea-2338-9f982d38732c
# ╟─2cfda0dc-f5d5-11ea-16c4-b5a33b90e37f
# ╠═150432d4-f5d5-11ea-32b2-19a2a91d9637
# ╠═44215aa4-f695-11ea-260e-b564c6fbcd4a
# ╠═21328d1c-f5d5-11ea-288e-4171ad35326d
# ╟─75761cc0-81cd-11eb-1186-7d47debd68ca
# ╠═6bd8a886-f758-11ea-2587-870a3fa9d710
# ╠═4c533ac6-f695-11ea-3724-b955eaaeee49
# ╠═466901ea-f5d5-11ea-1db5-abf82c96eabf
# ╠═b38c4aae-f5d5-11ea-39b6-7b0c7d529019
# ╟─93e04ed8-81cd-11eb-214a-a761ef8c406f
# ╟─e90c55fc-f5d5-11ea-10f1-470ff772985d
# ╟─19775c3c-f5d6-11ea-15c2-89618e654a1e
# ╟─653792a8-f695-11ea-1ae0-43761c502583
# ╠═79c94d2a-f75a-11ea-031d-09d70d229e15
# ╟─10bc5d50-81b9-11eb-2ac7-354a6c6c826b
# ╠═77d6a952-81ba-11eb-24e3-cb6510a59455
# ╟─1f3ba55a-81b9-11eb-001f-593b9d8639ca
# ╠═3d4a702e-f75a-11ea-031c-333d591fc442
# ╟─80ff4010-81bb-11eb-374e-215a57defb0b
# ╠═5de72b7c-f5d6-11ea-1b6f-35b830b5fb34
# ╠═8b60629e-f5d6-11ea-27c8-d934460d3a57
# ╟─89baf831-84b9-4fa6-9374-a7acccfcdef1
# ╠═2fd7e52e-f5d7-11ea-3b5a-1f338e2451e0
# ╠═2e87d4fe-81bc-11eb-0d16-b988bcedcc73
# ╠═cde79f38-f5d6-11ea-3297-0b5b240f7b9e
# ╠═aa09c008-f5d8-11ea-1bdc-b51ee6eb2478
# ╟─62a6ec62-f5d9-11ea-071e-ed33c5dea0cd
# ╟─7f63daf6-f695-11ea-0b80-8702a83103a4
# ╠═67274c3c-f5d9-11ea-3475-c9d228e3bd5a
# ╟─765c6552-f5d9-11ea-29d3-bfe7b4b04612
# ╠═126fb3ea-f5da-11ea-2f7d-0b3259a296ce
# ╟─ed0b2358-81ce-11eb-3339-93abcc06fd91
# ╟─24ce92fa-81cf-11eb-30f0-b1e357d79d53
# ╠═2d4500e0-81cf-11eb-1699-d310074fddf5
# ╟─3546ff30-81cf-11eb-3afc-05c5db61366f
# ╠═9b9e2c2a-f5da-11ea-369b-b513b196515b
# ╠═e68b98ea-f5da-11ea-1a9d-db45e4f80241
# ╠═f20ccac4-f5da-11ea-0e69-413b5e49f423
# ╠═12a2e96c-f5db-11ea-1c3e-494ae7446886
# ╠═22487ce2-f5db-11ea-32e9-6f70ab2c0353
# ╟─389ae62e-f5db-11ea-1557-c3adbbee0e5c
# ╠═0c2b6408-f5d9-11ea-2b7f-7fece2eecc1f
# ╠═5d767290-f5dd-11ea-2189-81198fd216ce
# ╠═587790ce-f6de-11ea-12d9-fde2a17ae314
# ╟─a39e8256-f6de-11ea-3170-c923b56609da
# ╠═8c84edd0-f6de-11ea-2180-61c6b81aac3b
# ╠═22b73baa-f6df-11ea-197f-bbb4bd1a7ef5
# ╠═b2332814-f6e6-11ea-1c7d-556c7d4687f1
# ╟─9ab7a72e-81cf-11eb-2b78-073ff51cae58
# ╟─fd8dd108-f6df-11ea-2f7c-3d99d054ac15
# ╠═165788b2-f601-11ea-3e69-cdbbb6558e54
# ╠═22941bb8-f601-11ea-1d6e-0d955297bc2e
# ╟─c33bf00e-81cf-11eb-1e1a-e5a879a45093
# ╠═2f75df7e-f601-11ea-2fc2-aff4f335af33
# ╟─7ff664f0-f74b-11ea-0d2d-b53f19e4f4bf
# ╟─a0611eaa-81bc-11eb-1d23-c12ab14138b1
# ╠═a4728944-f74b-11ea-03c3-9123908c1f8e
# ╟─cdbcd7ad-0f3d-4724-b207-f4d610672c5e
# ╠═05c35402-f752-11ea-2708-59cf5ef74fb4
# ╟─8c11b19e-81bc-11eb-184b-bf6ffefe29de
# ╠═8baaa994-f752-11ea-18d9-b3d0a6b9f7d9
# ╟─d92bece4-f754-11ea-0242-99f198bb5b7b
# ╠═e740999c-f754-11ea-2089-4b7a9aec6030
# ╟─0a79a7b4-f755-11ea-1b2d-21173567b257
# ╟─5adb98c2-f6e0-11ea-1fde-53b0fd6639c3
# ╟─487d6f9c-81d0-11eb-3bb0-336a4beb9b38
# ╠═5a493052-f601-11ea-2f5f-f940412905f2
# ╠═55b76aee-81d0-11eb-0bcc-413f5bd14360
# ╠═709bf30a-f755-11ea-2e82-bd511e598c77
# ╠═782532b0-f755-11ea-1385-cd1a28c4b9d5
# ╟─5bc4ab0a-f755-11ea-0fad-4987ad9fc02f
# ╟─ebd72fb8-f5e0-11ea-0630-573337dff753
# ╠═b6478e1a-f5f6-11ea-3b92-6d4f067285f4
# ╠═f2c11f88-f5f8-11ea-3e02-c1d4fa22031e
# ╠═29062f7a-f5f9-11ea-2682-1374e7694e32
# ╠═5471fd30-f6e2-11ea-2cd7-7bd48c42db99
# ╠═6156fd1e-f5f9-11ea-06a9-211c7ab813a4
# ╠═a9766e68-f5f9-11ea-0019-6f9d02050521
# ╠═0c0ee362-f5f9-11ea-0f75-2d2810c88d65
# ╠═b95ce51a-f632-11ea-3a64-f7c218b9b3c9
# ╠═7ba6e6a6-f5fa-11ea-2bcd-616d5a3c898b
# ╟─8df84fcc-f5d5-11ea-312f-bf2a3b3ce2ce
# ╟─0edd7cca-834f-11eb-0232-ff0850027f76
# ╟─69be8194-81b7-11eb-0452-0bc8b9f22286
# ╠═5813e1b2-f5ff-11ea-2849-a1def74fc065
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
