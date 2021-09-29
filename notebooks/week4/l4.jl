### A Pluto.jl notebook ###
# v0.16.1

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

# ╔═╡ a4937996-f314-11ea-2ff9-615c888afaa8
begin
    import ImageMagick
    using Images, TestImages, ImageFiltering, Statistics, PlutoUI, BenchmarkTools
end

# ╔═╡ e6b6760a-f37f-11ea-3ae1-65443ef5a81a
md"Tradução livre de [hw4.jl](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week4/hw4.jl)"

# ╔═╡ 85cfbd10-f384-11ea-31dc-b5693630a4c5
md"""
# **Lista 4**: _Otimização dinâmica_
`MS905`, 2º sem 2021

`Data de entrega`: 23 de setembro às 23:59.

Este caderno contém verificações _simples_ para ajudar você a saber se o que fez faz sentido. Essas verificações são incompletas e não corrigem completamente os exercícios. Mas, se elas disserem que algo não está bom, você sabe que tem que tentar de novo.

_Para os alunos regulares:_ as listas serão corrigidas com exemplos mais sofisticados e gerais do que aqueles das verificações incluídas. 

Sintam-se livres de fazer perguntas no fórum.
"""

# ╔═╡ 33e43c7c-f381-11ea-3abc-c942327456b1
# edite o código abaixo com seu nome e email da dac (sem o @dac.unicamp.br)

student = (name = "João Ninguém", email_dac = "j000000")

# aperte o botão ▶ no canto inferior direito da célula para executar o que você
# editou, ou use Shift+Enter

# Agora siga na página para ver o que deve fazer.

# ╔═╡ ec66314e-f37f-11ea-0af4-31da0584e881
md"""

Submetido por: **_$(student.name)_** ($(student.email_dac)@unicamp.br)
"""

# ╔═╡ 938185ec-f384-11ea-21dc-b56b7469f798
md"""
#### Iniciando pacotes
Quando executado a primeira vez pode demorar por instalar pacotes.
"""

# ╔═╡ 0f271e1d-ae16-4eeb-a8a8-37951c70ba31
all_image_urls = [
    "https://wisetoast.com/wp-content/uploads/2015/10/The-Persistence-of-Memory-salvador-deli-painting.jpg" =>
        "Salvador Dali — A Persistência da Memória (réplica)",
    "https://i.imgur.com/4SRnmkj.png" =>
        "Frida Kahlo — A Noiva que se Espanta ao Ver a Vida Aberta",
    "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Hilma_af_Klint_-_Group_IX_SUW%2C_The_Swan_No._1_%2813947%29.jpg/477px-Hilma_af_Klint_-_Group_IX_SUW%2C_The_Swan_No._1_%2813947%29.jpg" =>
        "Hilma Klint - O Cisne No. 1",
    "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Piet_Mondriaan%2C_1930_-_Mondrian_Composition_II_in_Red%2C_Blue%2C_and_Yellow.jpg/300px-Piet_Mondriaan%2C_1930_-_Mondrian_Composition_II_in_Red%2C_Blue%2C_and_Yellow.jpg" =>
        "Piet Mondriaan - Composição com Vermelho, Azul e Amarelo",
    "https://user-images.githubusercontent.com/6933510/110993432-950df980-8377-11eb-82e7-b7ce4a0d04bc.png" =>
        "Mario",
]

# ╔═╡ 6dabe5e2-c851-4a2e-8b07-aded451d8058
md"""
### Escolha a sua imagem

 $(@bind image_url Select(all_image_urls))

Maximum image size: $(@bind max_height_str Select(string.([50,100,200,500]))) pixels. _(Usar uma imagem maior pode levar a tempos longos de execução nos exercícios abaixo.)_
"""

# ╔═╡ 0d144802-f319-11ea-0028-cd97a776a3d0
img_original = load(download(image_url));

# ╔═╡ a5271c38-ba45-416b-94a4-ba608c25b897
max_height = parse(Int, max_height_str)

# ╔═╡ 365349c7-458b-4a6d-b067-5112cb3d091f
"Decimate an image such that its new height is at most `height`."
function decimate_to_height(img, height)
    factor = max(1, 1 + size(img, 1) ÷ height)
    img[1:factor:end, 1:factor:end]
end

# ╔═╡ ab276048-f34b-42dd-b6bf-0b83c6d99e6a
img = decimate_to_height(img_original, max_height)

# ╔═╡ b49e8cc8-f381-11ea-1056-91668ac6ae4e
md"""
## Cortando uma costura.

Abaixo você encontra uma função chamada  `remove_in_each_row(img, pixels)`. Ela recebe uma matriz `img` e um vetor de interios, `pixels`, e reduz a imagem de um pixel na largura eleminando o elemento `img[i, pixels[i]]` de cada linha. Essa função foi um dos elementos principais do algoritmo de "entalhando com costuras" que vimos em aula.

Leia atentamente a função e entenda como ela funciona.
"""

# ╔═╡ 90a22cc6-f327-11ea-1484-7fda90283797
function remove_in_each_row(img::Matrix, column_numbers::Vector)
    m, n = size(img)
    @assert m == length(column_numbers) # same as the number of rows

    local img′ = similar(img, m, n - 1) # create a similar image with one column less

    for (i, j) in enumerate(column_numbers)
        img′[i, 1:j-1] .= @view img[i, 1:(j-1)]   # The @view avois unecessary copies
        img′[i, j:end] .= @view img[i, (j+1):end] # when indexing a matriz with ranges
    end
    img′
end

# ╔═╡ 5370bf57-1341-4926-b012-ba58780217b1
removal_test_image = Gray.(rand(4, 4))

# ╔═╡ c075a8e6-f382-11ea-2263-cd9507324f4f
md"Vamos usar a função para remover a diagonal da imagem. Observe o resultado com calma e compare com a imagem original. A diagonal foi removida. "

# ╔═╡ 52425e53-0583-45ab-b82b-ffba77d444c8
let
    seam = [1, 2, 3, 4]
    remove_in_each_row(removal_test_image, seam)
end

# ╔═╡ a09aa706-6e35-4536-a16b-494b972e2c03
md"""
Já remover a costura `[1,1,1,1]` equivale a remover a primeira coluna:
"""

# ╔═╡ 268546b2-c4d5-4aa5-a57f-275c7da1450c
let
    seam = [1, 1, 1, 1]
    remove_in_each_row(removal_test_image, seam)
end

# ╔═╡ 6aeb2d1c-8585-4397-a05f-0b1e91baaf67
md"""
Se removermos a primeira costura duas vezes, então eliminaremos as duas primeiras colunas.
"""

# ╔═╡ 2f945ca3-e7c5-4b14-b618-1f9da019cffd
let
    seam = [1, 1, 1, 1]

    result1 = remove_in_each_row(removal_test_image, seam)
    result2 = remove_in_each_row(result1, seam)
    result2
end

# ╔═╡ 318a2256-f369-11ea-23a9-2f74c566549b
md"""
## _Brilho e energia_
"""

# ╔═╡ 7a44ba52-f318-11ea-0406-4731c80c1007
md"""
Como já vimos, vamos rapidamente definir um função de `brilho` para um pixel usando a ideia simplificada da média dos valores nos canais R, G e B.

Você deve usar essa função sempre que o problema pedir para você calcular o _brilho_ de um pixel.
"""

# ╔═╡ 6c7e4b54-f318-11ea-2055-d9f9c0199341
begin
    brightness(c::RGB) = mean((c.r, c.g, c.b))
    brightness(c::RGBA) = mean((c.r, c.g, c.b))
    brightness(c::Gray) = gray(c)
end

# ╔═╡ 74059d04-f319-11ea-29b4-85f5f8f5c610
Gray.(brightness.(img))

# ╔═╡ 0b9ead92-f318-11ea-3744-37150d649d43
md"""Abaixo, nós denimos a função `convolve` de forma preguiçosa: usando a rotina pré definida da biblioteca `ImageFiltering.jl`. Ela tem o mesmo comportamento da função completa que vocês podem encontrar na aula original.
"""

# ╔═╡ d184e9cc-f318-11ea-1a1e-994ab1330c1a
# Uses ImageFiltering.jl package to define the convolve function.
# Behaves the same way as the `convolve` function used in our lectures.
convolve(img, k) = imfilter(img, reflect(k))

# ╔═╡ cdfb3508-f319-11ea-1486-c5c58a0b9177
float_to_color(x) = RGB(max(0, -x), max(0, x), 0)

# ╔═╡ 5fccc7cc-f369-11ea-3b9e-2f0eca7f0f0e
md"""
Por fim, definimos a função `energy` que usa as derivadas parciais nas direções x e y calculando a sua norma (filtro de Sobel).
"""

# ╔═╡ e9402079-713e-4cfd-9b23-279bd1d540f6
energy(∇x, ∇y) = sqrt.(∇x .^ 2 .+ ∇y .^ 2)

# ╔═╡ 6f37b34c-f31a-11ea-2909-4f2079bf66ec
function energy(img)
    ∇y = convolve(brightness.(img), Kernel.sobel()[1])
    ∇x = convolve(brightness.(img), Kernel.sobel()[2])
    energy(∇x, ∇y)
end

# ╔═╡ 9fa0cd3a-f3e1-11ea-2f7e-bd73b8e3f302
float_to_color.(energy(img))

# ╔═╡ 87afabf8-f317-11ea-3cb3-29dced8e265a
md"""
## **Exercício 1** - _Movendo-se em direção da otimização dinâmica_

Neste exercício, e nos seguintes, vamos usar a ideia computacional de entralhar com costura. A ideia é partir de soluções mais simples so problema e, paulatinamente, chegar a solução final baseada em otimização dinâmica. 

Esperamos que esse processo ajude-o a entender melhor todo o processo, o tempo de execução e a precisão possíveis nas operações. 

### Como implementar as soluções:

Para cada variação do algoritmo, seu trabalho é escrever uma função que pega a matriz de energias e um índice de um píxel na primeira linha, e calcula a costura (vertical) começando nesse píxel.

A função deve retornar um vertor de comprimento igual ao número de linhas de imagem. Cada entrada desse vetor representa a coluna do píxel que deve ser eliminado na respectiva linha. (Ele será usado como entrada da função `remove_in_each_row`).
"""

# ╔═╡ 8ba9f5fc-f31b-11ea-00fe-79ecece09c25
md"""
#### Exercício 1.1 - _A abordagem gulosa_

A primeira abordagem é chamada de _abordagem gulosa_: começamos no pixel do topo e escolhe entre os três píxeis inferiores aquele que tem a menor energia (sem olhar o que vem para frente).

**Obs: Em alguns momentos vou sugerir para vocês verem um vídeo do 3Blue1Brown que descreve detalhes do que deve ser feito nessa lista. Lembre que você sempre pode clicar em "Assistir no YouTube e lá selecionar a engrenagem e pedir para o sistema gerar a tradução automática do vídeo.**

"""

# ╔═╡ f5a74dfc-f388-11ea-2577-b543d31576c6
html"""
<iframe width="100%" height="450px" src="https://www.youtube.com/embed/rpB6zQNsbQU?start=777&end=833" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
"""

# ╔═╡ 2f9cbea8-f3a1-11ea-20c6-01fd1464a592
random_seam(m, n, i) =
    reduce((a, b) -> [a..., clamp(last(a) + rand(-1:1), 1, n)], 1:m-1; init = [i])

# ╔═╡ c3543ea4-f393-11ea-39c8-37747f113b96
md"""
👉 Implement the greedy approach.
"""

# ╔═╡ abf20aa0-f31b-11ea-2548-9bea4fab4c37
function greedy_seam(energies, starting_pixel::Int)
    m, n = size(energies)
    # Você pode apagar o corpo dessa função. Está aqui só para gerar algo
	# e evitar erros abaixo.
    random_seam(size(energies)..., starting_pixel)
end

# ╔═╡ 5430d772-f397-11ea-2ed8-03ee06d02a22
md"Antes de aplicar a sua função à imagem de teste, vamos testá-la em uma matriz de energias pequena (que está abaixo em escalas de cinza, com preto represetando pouca energia e branco muita). Se quiser ver o vídeo acima ele mostra um exemplo disso."

# ╔═╡ a4d14606-7e58-4770-8532-66b875c97b70
grant_example =
    [
        1 8 8 3 5 4
        7 8 1 0 8 4
        8 0 4 7 2 9
        9 0 0 5 9 4
        2 4 0 2 4 5
        2 4 2 5 3 0
    ] ./ 10

# ╔═╡ 6f52c1a2-f395-11ea-0c8a-138a77f03803
md"Starting pixel: $(@bind greedy_starting_pixel Slider(1:size(grant_example, 2); show_value=true, default=5))"

# ╔═╡ 5057652e-2f88-40f1-82f0-55b1b5bca6f6
greedy_seam_result = greedy_seam(grant_example, greedy_starting_pixel)

# ╔═╡ 2643b00d-2bac-4868-a832-5fb8ad7f173f
let
    s = sum(grant_example[i, j] for (i, j) in enumerate(greedy_seam_result))
    md"""
    **Total energy:** $(round(s,digits=1))
    """
end

# ╔═╡ 38f70c35-2609-4599-879d-e032cd7dc49d
Gray.(grant_example)

# ╔═╡ 9945ae78-f395-11ea-1d78-cf6ad19606c8
md"_Agora vamos tentar na imagem maior!_"

# ╔═╡ 87efe4c2-f38d-11ea-39cc-bdfa11298317
begin
    # reactive references to uncheck the checkbox when the functions are updated
    greedy_seam, img, grant_example

    md"Calcule a imagem reduzida: $(@bind shrink_greedy CheckBox())
	
	Obs: Ao selecionar para calcular você irá disparar o algoritmo implementadona imagem, se o algoritmo demorar muito o caderdo pode ficar _travado_. O mesmo vale abaixo nas outras opções para ligar o cálculo.
	"
end

# ╔═╡ 52452d26-f36c-11ea-01a6-313114b4445d
md"""
#### Exercício 1.2 - _Recursão_

Um parão comum para desenvolvimento de algoritmos é a ideia de resolver um problema combinando as soluções de subproblemas (menores).

Um dos exemplos mais clássicos e a geração de [Números de Fibonacci](https://en.wikipedia.org/wiki/Fibonacci_number).

A sua implementação com recurssão pode ser vista abaixo.
"""

# ╔═╡ 2a98f268-f3b6-11ea-1eea-81c28256a19e
function fib(n)
    # base case (basis)
    if n == 0 || n == 1      # `||` means "or"
        return 1
    end

    # recursion (induction)
    return fib(n - 1) + fib(n - 2)
end

# ╔═╡ 32e9a944-f3b6-11ea-0e82-1dff6c2eef8d
md"""
Observe que você pode chamar a função a partir de si mesma: é o que chamamos de recurssão. Isso, é claro, deve ser feito com cuidado para evitar uma sequência de chamadas infinitas. Tipicamente as chamadas recursivas são feitas para subproblemas menores até que sejam atingidos casos bases para os quais já sabemos resolver o problema. 

No caso da função Fibonacci, os sub problemas "menores" são as chamadas para a função com valores estritamente inferiores `fib(n-1)` e `fib(n-2)`. Os seus resultados são então combinados, através da adição, para produzir `fib(n)`.

Há uma clara analogia com a ideia de indução finita em matemática. Assim como em indução matemática, há três passos para se construir uma solução recursiva:

- Definir um, ou mais, caso(s) base.
- Pensar como quebrar um problema maior em problemas menores (para fazer a chamada recursiva).
- Enteder como combinar a solução dos problemas menores para gerar a solução do problema completo.

"""

# ╔═╡ 9101d5a0-f371-11ea-1c04-f3f43b96ca4a
md"""
👉 Defina uma função `least_energy` que retorna:
1. O menor valor possível da energia total (até a base) para uma costura iniciando no píxel da posição $(i, j)$;
2. A coluna destino na prórima linha ($i + 1$), que deve ser $j - 1$, $j$ ou $j + 1$, respeitando as condições de fronteira (não se pode sair da imagem).

Retorne esses dois valores em uma tupla.
"""

# ╔═╡ 8ec27ef8-f320-11ea-2573-c97b7b908cb7
## Retorna o a menor soma das energias partindo do píxel (i, j), e a coluna para onde ir na próxima linha, i + 1.
function least_energy(energies, i, j)
	sum(energies)
    m, n = size(energies)

    ## Caso base
    # if i == something
    #    return (energies[...], ...) # Não há necessidade de chamadas recursivas nesse caso!
    # end

    ## Indução
    # Combine os resultados de chamadas recursivas com a energia do píxel atual para obter o resultado.
end

# ╔═╡ ad524df7-29e2-4f0d-ad72-8ecdd57e4f02
least_energy(grant_example, 1, 4)

# ╔═╡ 1add9afd-5ff5-451d-ad81-57b0e929dfe8
grant_example

# ╔═╡ 447e54f8-d3db-4970-84ee-0708ab8a9244
md"""
#### Saída esperada
Como você pode ver no vídeo, a costura ideal partindo do ponto (1, 4) é:
"""

# ╔═╡ 8b8da8e7-d3b5-410e-b100-5538826c0fde
grant_example_optimal_seam = [4, 3, 2, 2, 3, 3]

# ╔═╡ e1074d35-58c4-43c0-a6cb-1413ed194e25
md"""
Portanto, o saída esperada da sua função `least_energy(grant_example, 1, 4)` deveria ser:
"""

# ╔═╡ 281b950f-2331-4666-9e45-8fd117813f45
(
    sum(grant_example[i, grant_example_optimal_seam[i]] for i = 1:6),
    grant_example_optimal_seam[2],
)

# ╔═╡ a7f3d9f8-f3bb-11ea-0c1a-55bbb8408f09
md"""
Isso é elegante e correto, mas ineficiente! Vamos computador o número de acessos à matriz de energias necessários para encontrar a costura de menor energia de uma imagem 10 × 10.
"""

# ╔═╡ 18e0fd8a-f3bc-11ea-0713-fbf74d5fa41a
md"Caramba! Temos que otimizar isso depois!"

# ╔═╡ cbf29020-f3ba-11ea-2cb0-b92836f3d04b
# Create an alternative array type that count every time you access a value
# using the indexes

begin
    struct AccessTrackerArray{T,N} <: AbstractArray{T,N}
        data::Array{T,N}
        accesses::Ref{Int}  # Structs in Julia are not mutable, hence I need a pointer
    end

    Base.IndexStyle(::Type{AccessTrackerArray}) = IndexLinear()
    Base.size(x::AccessTrackerArray) = size(x.data)
    Base.getindex(x::AccessTrackerArray, i::Int...) = (x.accesses[] += 1; x.data[i...])
    Base.setindex!(x::AccessTrackerArray, v, i...) = (x.accesses[] += 1; x.data[i...] = v)


    track_access(x) = AccessTrackerArray(x, Ref(0))
    function track_access(f::Function, x::Array)
        tracked = track_access(x)
        f(tracked)
        tracked.accesses[]
    end
end

# ╔═╡ fa8e2772-f3b6-11ea-30f7-699717693164
track_access(rand(10, 10)) do tracked
    least_energy(tracked, 1, 5)
end

# ╔═╡ 8bc930f0-f372-11ea-06cb-79ced2834720
md"""
#### Exercise 1.3 - _Busca exaustiva com recursão_

Agora use a função `least_energy` que você escreveu e implemente a função `recursive_seam` que recebe a matriz de energia para cada píxel e calcula a costura de energia total mínima começando naquele píxel.

Esse processo todo, calular a matriz com `least_energy` e depois calular a costura ótima, está intimamente ligado à geração exaustiva de todos os possíveis caminhos que foi vista na aula inicial sobre programação dinâmica.
"""

# ╔═╡ 85033040-f372-11ea-2c31-bb3147de3c0d
function recursive_seam(energies, starting_pixel)
    m, n = size(energies)
    # Substitua a linha a seguir com o seu código.
    [rand(1:starting_pixel) for i = 1:m]
end

# ╔═╡ f92ac3e4-fa70-4bcf-bc50-a36792a8baaa
md"""
Veja que tomamos o cuidado de não usar essa função para reduzir a imagem completa, ele é certamente muito ineficiente (o notebook poderia ficar travado). Mas vamos tentar usá-lo sobre uma matriz pequena e verificar se ela encontra a costura ótima.
"""

# ╔═╡ 7ac5eb8d-9dba-4700-8f3a-1e0b2addc740
recursive_seam_test = recursive_seam(grant_example, 4)

# ╔═╡ c572f6ce-f372-11ea-3c9a-e3a21384edca
md"""
#### Exercício 1.4

- Diga porque esse algoritmo olha todos os possíveis caminhos. 
- Como o número de possíveis costura aumenta com o tamanho `m × n` da imagem? Pode usar uma notação grande O, ou dar uma aproximação que capture quão rápido é o crescimento.
"""

# ╔═╡ 6d993a5c-f373-11ea-0dde-c94e3bbd1552
exhaustive_observation = md"""
<your answer here>
"""

# ╔═╡ ea417c2a-f373-11ea-3bb0-b1b5754f2fac
md"""
## **Exercício 2** - _Memoização (memoization)_

**Memoização** é o nome dado à tecnica de armazenar resultados de chamadas a função computacionalmente caras que serão acessadas mais de uma vez.

Como comentado no vídeo, e como vocês devem ter explicado em sua resposta do exercício 1.4, a função `least_energy` é chamada repetidas vezes com os mesmos argumenos. De fato ela é chamadas muitas mais vezes do que as reais $m \times n$ possibilidades para uma dada matriz de energia.

Vamos implementar memoização apra essa função. Inicialmente iremos usar um [dicionário](https://docs.julialang.org/en/v1/base/collections/#Dictionaries) para armazenar os valores.
"""

# ╔═╡ 56a7f954-f374-11ea-0391-f79b75195f4d
md"""
#### Exercise 2.1 - _Armazenação em dicionário_

Vamos criar uma primeira versão memoizada da função `least_energy` que recebe um dicionário e primeiro veritica se ele já contem a resposta para o par `(i, j)`de sua lista de argumentos de entrada. Se sim, basta retonar o valor armazenado. Se não, o cálculo completo é executado, o resultado armazenado e depois retornardo. A assinatura da função fica algo como:

`memoized_least_energy(energies, i, j, memory)`

Essa função deve ainda ser recursiva e passar nas chamadas o mesmo objeto de memória que recebeu como argumento. 

Você deve ler e compreender a documentação sobre [dicionários de Julia](https://docs.julialang.org/en/v1/base/collections/#Dictionaries) e descobrir como:

1. Criar um dicionário.
2. Verificar se uma chave está no dicionário.
3. Acessar os elementos armazenados no dicionário através de sua chave.
"""

# ╔═╡ b1d09bc8-f320-11ea-26bb-0101c9a204e2
function memoized_least_energy(energies, i, j, memory::Dict)
    m, n = size(energies)

    # Você deve começar copiando a sua versão orginal da função 
	# least_energy (não memoizada).

end

# ╔═╡ 1947f304-fa2c-4019-8584-01ef44ef2859
memoized_least_energy_test = memoized_least_energy(grant_example, 1, 4, Dict())

# ╔═╡ 8992172e-c5b6-463e-a06e-5fe42fb9b16b
md"""
Vasmos ver gora quantos acessos à matriz ocorrem:
"""

# ╔═╡ b387f8e8-dced-473a-9434-5334829ecfd1
track_access(rand(10, 10)) do tracked
    memoized_least_energy(tracked, 1, 5, Dict())
end

# ╔═╡ 3e8b0868-f3bd-11ea-0c15-011bbd6ac051
function memoized_recursive_seam(energies, starting_pixel)
    # Aqui já deixamos a memória inicializada. Note que definimos o tipo da chave
	# (Tuple{Int,Int}) e dos valores que serão armazenados (Tuple{Float64,Int}). 
    # Isso é para aumentar a eficiência já que nesse caso o compilador sabe os tipos
	# do que está dentro do dicionário. 
	# Também é possível criar dicionários sem especificar os tipos simples com Dict()
    memory = Dict{Tuple{Int,Int},Tuple{Float64,Int}}()

    m, n = size(energies)

    # Substitua as próximas linhas com seu código.

    # É uma boa ideia começar copiando a versão (não memoizada) da função
	# recursive_seam.
end

# ╔═╡ d941c199-ed77-47dd-8b5a-e34b864f9a79
memoized_recursive_seam(grant_example, 4)

# ╔═╡ 726280f0-682f-4b05-bf5a-688554a96287
grant_example_optimal_seam

# ╔═╡ cf39fa2a-f374-11ea-0680-55817de1b837
md"""
### Exercise 2.2 - _Armazenamento em matriz_ (opcional)

Usar um dicionário para armazenar a memória em casos gerais, quando não sabemos quais as possíveis combinações de parâmetros que serão usados para chamar a matriz é uma boa ideia. Mas no nosso caso sabemos que os pares $(i, j)$ representam posições de píxeis e a função será chamada para todos os píxeis da imagem. 

Nesse caso é muito mais natural usar uma matriz como memória da memoização. Ela certamente será o tipo de dados mais eficiente para guardar os valores, tando do ponto de vista de tempo quando do ponto de vista de memória.

👉 Escreva uma variação de `matrix_memoized_least_energy` e `matrix_memoized_seam` que usa matrizes para armazenamento. 
"""

# ╔═╡ c8724b5e-f3bd-11ea-0034-b92af21ca12d
function matrix_memoized_least_energy(energies, i, j, memory::Matrix)
    m, n = size(energies)

    # Substitua com seu código.
end

# ╔═╡ be7d40e2-f320-11ea-1b56-dff2a0a16e8d
function matrix_memoized_seam(energies, starting_pixel)
    memory = fill((-1.0, -1), size(energies))

    # Você pode usar outros tipos se quiser, como:
    # memory = Matrix{Any}(nothing, size(energies))


    m, n = size(energies)

    # Substitua a linha a seguir pelo seu código.
    [starting_pixel for i = 1:m]


end

# ╔═╡ 507f3870-f3c5-11ea-11f6-ada3bb087634
begin
    matrix_memoized_seam, img

    md"Calcule a imagem reduzida: $(@bind shrink_matrix CheckBox())"
end

# ╔═╡ 24792456-f37b-11ea-07b2-4f4c8caea633
md"""
## **Exercise 3** - _Otimização dinâmica sem a recursão_ 

Agora deve ser "fácil" ver que o algoritmo descrito acima é equivalente a popular a matriz sem usar recursão e diretamente de um loop `for`.

#### Exercício 3.1

👉 Escreva uma função que recebe a matriz de energias e retorna uma matriz com as energias totais mínimas da melhor costura partindo de cada píxel. Eu sei que já fiz algo próximo a isso em aula, mas tente escrever a sua própria versão.
"""

# ╔═╡ ff055726-f320-11ea-32f6-2bf38d7dd310
function least_energy_matrix(energies)
    result = copy(energies)
    m, n = size(energies)

    # Complete com seu código aqui.


    return result
end

# ╔═╡ d3e69cf6-61b1-42fc-9abd-42d1ae7d61b2
img_brightness = brightness.(img);

# ╔═╡ 51731519-1831-46a3-a599-d6fc2f7e4224
le_test = least_energy_matrix(img_brightness)

# ╔═╡ e06d4e4a-146c-4dbd-b742-317f638a3bd8
spooky(A::Matrix{<:Real}) =
    map(sqrt.(A ./ maximum(A))) do x
        RGB(0.8x, x, 0.8x)
    end

# ╔═╡ 99efaf6a-0109-4b16-89b8-f8149b6b69c2
spooky(le_test)

# ╔═╡ 92e19f22-f37b-11ea-25f7-e321337e375e
md"""
#### Exercício 3.2

👉 Escreva uma rotina que, dada a matriz retornada por `least_energy_matrix` e um píxel de partida (na primeira linha), calcula a costura de energia mínima que nasce nesse píxel.
"""

# ╔═╡ 795eb2c4-f37b-11ea-01e1-1dbac3c80c13
function seam_from_precomputed_least_energy(energies, starting_pixel::Int)
    least_energies = least_energy_matrix(energies)
    m, n = size(least_energies)

    # Substitua com seu código.
    [starting_pixel for i = 1:m]

end

# ╔═╡ 51df0c98-f3c5-11ea-25b8-af41dc182bac
begin
    img, seam_from_precomputed_least_energy
    md"Calcule a imagem reduzida: $(@bind shrink_bottomup CheckBox())"
end

# ╔═╡ 0fbe2af6-f381-11ea-2f41-23cd1cf930d9
if student.email_dac === "j000000"
    md"""
   !!! danger "Oops!"
       **Antes de submeter**, lembre de preencer seu nome e email dac no topo desse caderno!
   	"""
end

# ╔═╡ 6b4d6584-f3be-11ea-131d-e5bdefcc791b
md"## Function library

Just some helper functions used in the notebook."

# ╔═╡ ef88c388-f388-11ea-3828-ff4db4d1874e
function mark_path(img, path)
    img′ = RGB.(img) # also makes a copy
    m = size(img, 2)
    for (i, j) in enumerate(path)
        if size(img, 2) > 50
            # To make it easier to see, we'll color not just
            # the pixels of the seam, but also those adjacent to it
            for j′ = j-1:j+1
                img′[i, clamp(j′, 1, m)] = RGB(1, 0, 1)
            end
        else
            img′[i, j] = RGB(1, 0, 1)
        end
    end
    img′
end

# ╔═╡ 437ba6ce-f37d-11ea-1010-5f6a6e282f9b
function shrink_n(
    min_seam::Function,
    img::Matrix{<:Colorant},
    n,
    imgs = [];
    show_lightning = true,
)

    n == 0 && return push!(imgs, img)

    e = energy(img)
    seam_energy(seam) = sum(e[i, seam[i]] for i = 1:size(img, 1))
    _, min_j = findmin(map(j -> seam_energy(min_seam(e, j)), 1:size(e, 2)))
    min_seam_vec = min_seam(e, min_j)
    img′ = remove_in_each_row(img, min_seam_vec)
    if show_lightning
        push!(imgs, mark_path(img, min_seam_vec))
    else
        push!(imgs, img′)
    end
    shrink_n(min_seam, img′, n - 1, imgs; show_lightning = show_lightning)
end

# ╔═╡ f6571d86-f388-11ea-0390-05592acb9195
if shrink_greedy
    local n = min(200, size(img, 2))
    greedy_carved = shrink_n(greedy_seam, img, n)
    md"Reduza de: $(@bind greedy_n Slider(1:n; show_value=true))"
end

# ╔═╡ f626b222-f388-11ea-0d94-1736759b5f52
if shrink_greedy
    greedy_carved[greedy_n]
end

# ╔═╡ 4e3bcf88-f3c5-11ea-3ada-2ff9213647b7
begin
    # reactive references to uncheck the checkbox when the functions are updated
    img, memoized_recursive_seam, shrink_n

    md"Calcula a imagem reduzida $(@bind shrink_dict CheckBox())"
end

# ╔═╡ 4e3ef866-f3c5-11ea-3fb0-27d1ca9a9a3f
if shrink_dict
    local n = min(20, size(img, 2))
    dict_carved = shrink_n(memoized_recursive_seam, img, n)
    md"Reduza de: $(@bind dict_n Slider(1:n, show_value=true))"
end

# ╔═╡ 6e73b1da-f3c5-11ea-145f-6383effe8a89
if shrink_dict
    dict_carved[dict_n]
end

# ╔═╡ 50829af6-f3c5-11ea-04a8-0535edd3b0aa
if shrink_matrix
    local n = min(20, size(img, 2))
    matrix_carved = shrink_n(matrix_memoized_seam, img, n)
    md"Reduza de: $(@bind matrix_n Slider(1:n, show_value=true))"
end

# ╔═╡ 9e56ecfa-f3c5-11ea-2e90-3b1839d12038
if shrink_matrix
    matrix_carved[matrix_n]
end

# ╔═╡ 51e28596-f3c5-11ea-2237-2b72bbfaa001
if shrink_bottomup
    local n = min(40, size(img, 2))
    bottomup_carved = shrink_n(seam_from_precomputed_least_energy, img, n)
    md"Reduza de: $(@bind bottomup_n Slider(1:n, show_value=true))"
end

# ╔═╡ 0a10acd8-f3c6-11ea-3e2f-7530a0af8c7f
if shrink_bottomup
    bottomup_carved[bottomup_n]
end

# ╔═╡ ef26374a-f388-11ea-0b4e-67314a9a9094
function pencil(X)
    f(x) = RGB(1 - x, 1 - x, 1 - x)
    map(f, X ./ maximum(X))
end

# ╔═╡ 6bdbcf4c-f321-11ea-0288-fb16ff1ec526
function decimate(img, n)
    img[1:n:end, 1:n:end]
end

# ╔═╡ ffc17f40-f380-11ea-30ee-0fe8563c0eb1
hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))

# ╔═╡ 9f18efe2-f38e-11ea-0871-6d7760d0b2f6
hint(
    md"Você pode chamar a função `least_energy` recursivamente para obter a energia total mínima das células inferiores adjacentes e adicionar à energia da célula atual para obter a melhor energia total dessa célula.",
)

# ╔═╡ 6435994e-d470-4cf3-9f9d-d00df183873e
hint(
    md"Eu recomento usara uma matriz de tipo `Tuple{Float64,Int}}`, inicializada com `(-1.0, -1)` já que esses valores são inválidos. Você pode verificar então que a matriz ainda não tem um valor válido usando uma comparação como initialized to all `nothing`s. You can check whether the value at `(i,j)` has been computed before using `memory[i,j] != nothing`.",
)

# ╔═╡ ffc40ab2-f380-11ea-2136-63542ff0f386
almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))

# ╔═╡ ffceaed6-f380-11ea-3c63-8132d270b83f
still_missing(text = md"Replace `missing` with your answer.") =
    Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))

# ╔═╡ ffde44ae-f380-11ea-29fb-2dfcc9cda8b4
keep_working(text = md"The answer is not quite right.") =
    Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))

# ╔═╡ 1413d047-099f-48c9-bbb0-ff0a3ddb4888
begin
    function visualize_seam_algorithm(
        test_energies,
        algorithm::Function,
        starting_pixel::Integer,
    )
        seam = algorithm(test_energies, starting_pixel)
        visualize_seam_algorithm(test_energies, seam)
    end
    function visualize_seam_algorithm(test_energies, seam::Vector)
        display_img = RGB.(test_energies)
        for (i, j) in enumerate(seam)
            try
                display_img[i, j] = RGB(0.9, 0.3, 0.6)
            catch ex
                if ex isa BoundsError
                    return keep_working("")
                end
                # the solution might give an illegal index
            end
        end
        display_img
    end
end

# ╔═╡ 2a7e49b8-f395-11ea-0058-013e51baa554
visualize_seam_algorithm(grant_example, greedy_seam_result)

# ╔═╡ ffe326e0-f380-11ea-3619-61dd0592d409
yays = [
    md"Great!",
    md"Yay ❤",
    md"Great! 🎉",
    md"Well done!",
    md"Keep it up!",
    md"Good job!",
    md"Awesome!",
    md"You got the right answer!",
    md"Let's move on to the next section.",
]

# ╔═╡ fff5aedc-f380-11ea-2a08-99c230f8fa32
correct(text = rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))

# ╔═╡ 9ff0ce41-327f-4bf0-958d-309cd0c0b6e5
if recursive_seam_test == grant_example_optimal_seam
    correct()
else
    keep_working()
end

# ╔═╡ 344964a8-7c6b-4720-a624-47b03483263b
let
    result = track_access(rand(10, 10)) do tracked
        memoized_least_energy(tracked, 1, 5, Dict())
    end
    if result == 0
        nothing
    elseif result < 200
        correct()
    else
        keep_working(
            md"Ainda estão ocorrendo acessos demais! Você lembrou de guardar os resultados na memória (`memory`)?"
        )
    end
end

# ╔═╡ c1ab3d5f-8e6c-4702-ad40-6c7f787f1c43
let
    aresult = track_access(rand(10, 10)) do tracked
        memoized_recursive_seam(tracked, 5)
    end
    if aresult < 200
        if memoized_recursive_seam(grant_example, 4) == grant_example_optimal_seam
            correct()
        else
            keep_working(
                md"A costura retornada não é a correta. A versão não memoizada estava certa?",
            )
        end
    else
        keep_working(
            md"Cuidado! Sua `memoized_recursive_seam` ainda está executando acessos demais a memória. Você pode deve evitar rodar a visualização abaixo ou ela pode travar o caderno.",
        )
    end
end

# ╔═╡ 00026442-f381-11ea-2b41-bde1fff66011
not_defined(variable_name) = Markdown.MD(
    Markdown.Admonition(
        "danger",
        "Oopsie!",
        [
            md"Make sure that you define a variable called **$(Markdown.Code(string(variable_name)))**",
        ],
    ),
)

# ╔═╡ 414dd91b-8d05-44f0-8bbd-b15981ce1210
if !@isdefined(least_energy)
    not_defined(:least_energy)
else
    let
        result1 = least_energy(grant_example, 6, 4)

        if !(result1 isa Tuple)
            keep_working(md"Sua função deve retornar uma _tupla_, como `(1.2, 5)`.")
        elseif !(result1 isa Tuple{Float64,Int})
            keep_working(md"Sua função deve retornar uma _tupla_, como `(1.2, 5)`.")
        else
            result = least_energy(grant_example, 1, 4)
            if !(result isa Tuple{Float64,Int})
                keep_working(md"Sua função deve retornar uma _tupla_, como `(1.2, 5)`.")
            else
                a, b = result

                if a ≈ 0.3 && b == 4
                    almost(
                        md"Busque apenas nas três células (no máximo) que estão sob alcance.",
                    )
                elseif a ≈ 0.6 && b == 3
                    correct()
                else
                    keep_working()
                end
            end
        end
    end
end

# ╔═╡ e0622780-f3b4-11ea-1f44-59fb9c5d2ebd
if !@isdefined(least_energy_matrix)
    not_defined(:least_energy_matrix)
elseif !(le_test isa Matrix{<:Real})
    keep_working(md"`least_energy_matrix` should return a 2D array of Float64 values.")
end

# ╔═╡ 946b69a0-f3a2-11ea-2670-819a5dafe891
if !@isdefined(seam_from_precomputed_least_energy)
    not_defined(:seam_from_precomputed_least_energy)
end

# ╔═╡ fbf6b0fa-f3e0-11ea-2009-573a218e2460
function hbox(x, y, gap = 16; sy = size(y), sx = size(x))
    w, h = (max(sx[1], sy[1]), gap + sx[2] + sy[2])

    slate = fill(RGB(1, 1, 1), w, h)
    slate[1:size(x, 1), 1:size(x, 2)] .= RGB.(x)
    slate[1:size(y, 1), size(x, 2)+gap.+(1:size(y, 2))] .= RGB.(y)
    slate
end

# ╔═╡ f010933c-f318-11ea-22c5-4d2e64cd9629
hbox(
    float_to_color.(convolve(brightness.(img), Kernel.sobel()[1])),
    float_to_color.(convolve(brightness.(img), Kernel.sobel()[2])),
)

# ╔═╡ 256edf66-f3e1-11ea-206e-4f9b4f6d3a3d
vbox(x, y, gap = 16) = hbox(x', y')'

# ╔═╡ 00115b6e-f381-11ea-0bc6-61ca119cb628
bigbreak = html"<br><br><br><br><br>";

# ╔═╡ c086bd1e-f384-11ea-3b26-2da9e24360ca
bigbreak

# ╔═╡ f7eba2b6-f388-11ea-06ad-0b861c764d61
bigbreak

# ╔═╡ 4f48c8b8-f39d-11ea-25d2-1fab031a514f
bigbreak

# ╔═╡ 48089a00-f321-11ea-1479-e74ba71df067
bigbreak

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
ImageFiltering = "6a3955dd-da59-5b1f-98d4-e7296123deb5"
ImageMagick = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
Images = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
TestImages = "5e47fb64-e119-507b-a336-dd2b206d9990"

[compat]
BenchmarkTools = "~1.1.4"
ImageFiltering = "~0.6.21"
ImageMagick = "~1.2.1"
Images = "~0.24.1"
PlutoUI = "~0.7.9"
TestImages = "~1.6.1"
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
git-tree-sha1 = "d84c956c4c0548b4caf0e4e96cf5b6494b5b1529"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.1.32"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "a4d07a1c313392a77042855df46c5f534076fab9"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.0"

[[AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "d127d5e4d86c7680b20c35d40b503c74b9a39b5e"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.4"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Statistics", "UUIDs"]
git-tree-sha1 = "42ac5e523869a84eac9669eaceed9e4aa0e1587b"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.1.4"

[[CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[CatIndices]]
deps = ["CustomUnitRanges", "OffsetArrays"]
git-tree-sha1 = "a0f80a09780eed9b1d106a1bf62041c2efc995bc"
uuid = "aafaddc9-749c-510e-ac4f-586e18779b91"
version = "0.2.2"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "4ce9393e871aca86cc457d9f66976c3da6902ea7"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.4.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "a66a8e024807c4b3d186eb1cab2aff3505271f8e"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.6"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "4866e381721b30fac8dda4c8cb1d9db45c8d2994"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.37.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[ComputationalResources]]
git-tree-sha1 = "52cb3ec90e8a8bea0e62e275ba577ad0f74821f7"
uuid = "ed09eef8-17a6-5b46-8889-db040fac31e3"
version = "0.3.2"

[[CoordinateTransformations]]
deps = ["LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "6d1c23e740a586955645500bbec662476204a52c"
uuid = "150eb455-5306-5404-9cee-2592286d6298"
version = "0.6.1"

[[CustomUnitRanges]]
git-tree-sha1 = "1a3f97f907e6dd8983b744d2642651bb162a3f7a"
uuid = "dc8bdbbb-1ca9-579f-8c36-e416f6a65cce"
version = "1.0.2"

[[DataAPI]]
git-tree-sha1 = "bec2532f8adb82005476c141ec23e921fc20971b"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.8.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "9f46deb4d4ee4494ffb5a40a27a2aced67bdd838"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.4"

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

[[EllipsisNotation]]
deps = ["ArrayInterface"]
git-tree-sha1 = "8041575f021cba5a099a456b4163c9a08b566a02"
uuid = "da5c29d0-fa7d-589e-88eb-ea29b0a81949"
version = "1.1.0"

[[FFTViews]]
deps = ["CustomUnitRanges", "FFTW"]
git-tree-sha1 = "70a0cfd9b1c86b0209e38fbfe6d8231fd606eeaf"
uuid = "4f61f5a4-77b1-5117-aa51-3ab5ef4ef0cd"
version = "0.3.1"

[[FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "d7ba5d3df9453b3516ebdd341db238e6e67b94ff"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.4"

[[FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3676abafff7e4ff07bbd2c42b3d8201f31653dcc"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.9+8"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "3c041d2ac0a52a12a27af2782b34900d9c3ee68c"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.11.1"

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

[[IdentityRanges]]
deps = ["OffsetArrays"]
git-tree-sha1 = "be8fcd695c4da16a1d6d0cd213cb88090a150e3b"
uuid = "bbac6d45-d8f3-5730-bfe4-7a449cd117ca"
version = "0.3.1"

[[IfElse]]
git-tree-sha1 = "28e837ff3e7a6c3cdb252ce49fb412c8eb3caeef"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.0"

[[ImageAxes]]
deps = ["AxisArrays", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "794ad1d922c432082bc1aaa9fa8ffbd1fe74e621"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.9"

[[ImageContrastAdjustment]]
deps = ["ColorVectorSpace", "ImageCore", "ImageTransformations", "Parameters"]
git-tree-sha1 = "2e6084db6cccab11fe0bc3e4130bd3d117092ed9"
uuid = "f332f351-ec65-5f6a-b3d1-319c6670881a"
version = "0.3.7"

[[ImageCore]]
deps = ["AbstractFFTs", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "db645f20b59f060d8cfae696bc9538d13fd86416"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.8.22"

[[ImageDistances]]
deps = ["ColorVectorSpace", "Distances", "ImageCore", "ImageMorphology", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "6378c34a3c3a216235210d19b9f495ecfff2f85f"
uuid = "51556ac3-7006-55f5-8cb3-34580c88182d"
version = "0.2.13"

[[ImageFiltering]]
deps = ["CatIndices", "ColorVectorSpace", "ComputationalResources", "DataStructures", "FFTViews", "FFTW", "ImageCore", "LinearAlgebra", "OffsetArrays", "Requires", "SparseArrays", "StaticArrays", "Statistics", "TiledIteration"]
git-tree-sha1 = "bf96839133212d3eff4a1c3a80c57abc7cfbf0ce"
uuid = "6a3955dd-da59-5b1f-98d4-e7296123deb5"
version = "0.6.21"

[[ImageIO]]
deps = ["FileIO", "Netpbm", "OpenEXR", "PNGFiles", "TiffImages", "UUIDs"]
git-tree-sha1 = "13c826abd23931d909e4c5538643d9691f62a617"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.5.8"

[[ImageMagick]]
deps = ["FileIO", "ImageCore", "ImageMagick_jll", "InteractiveUtils", "Libdl", "Pkg", "Random"]
git-tree-sha1 = "5bc1cb62e0c5f1005868358db0692c994c3a13c6"
uuid = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
version = "1.2.1"

[[ImageMagick_jll]]
deps = ["JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "1c0a2295cca535fabaf2029062912591e9b61987"
uuid = "c73af94c-d91f-53ed-93a7-00f77d67a9d7"
version = "6.9.10-12+3"

[[ImageMetadata]]
deps = ["AxisArrays", "ColorVectorSpace", "ImageAxes", "ImageCore", "IndirectArrays"]
git-tree-sha1 = "ae76038347dc4edcdb06b541595268fca65b6a42"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.5"

[[ImageMorphology]]
deps = ["ColorVectorSpace", "ImageCore", "LinearAlgebra", "TiledIteration"]
git-tree-sha1 = "68e7cbcd7dfaa3c2f74b0a8ab3066f5de8f2b71d"
uuid = "787d08f9-d448-5407-9aad-5290dd7ab264"
version = "0.2.11"

[[ImageQualityIndexes]]
deps = ["ColorVectorSpace", "ImageCore", "ImageDistances", "ImageFiltering", "OffsetArrays", "Statistics"]
git-tree-sha1 = "1198f85fa2481a3bb94bf937495ba1916f12b533"
uuid = "2996bd0c-7a13-11e9-2da2-2f5ce47296a9"
version = "0.2.2"

[[ImageShow]]
deps = ["Base64", "FileIO", "ImageCore", "OffsetArrays", "Requires", "StackViews"]
git-tree-sha1 = "832abfd709fa436a562db47fd8e81377f72b01f9"
uuid = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
version = "0.3.1"

[[ImageTransformations]]
deps = ["AxisAlgorithms", "ColorVectorSpace", "CoordinateTransformations", "IdentityRanges", "ImageCore", "Interpolations", "OffsetArrays", "Rotations", "StaticArrays"]
git-tree-sha1 = "e4cc551e4295a5c96545bb3083058c24b78d4cf0"
uuid = "02fcd773-0e25-5acc-982a-7f6622650795"
version = "0.8.13"

[[Images]]
deps = ["AxisArrays", "Base64", "ColorVectorSpace", "FileIO", "Graphics", "ImageAxes", "ImageContrastAdjustment", "ImageCore", "ImageDistances", "ImageFiltering", "ImageIO", "ImageMagick", "ImageMetadata", "ImageMorphology", "ImageQualityIndexes", "ImageShow", "ImageTransformations", "IndirectArrays", "OffsetArrays", "Random", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "StatsBase", "TiledIteration"]
git-tree-sha1 = "8b714d5e11c91a0d945717430ec20f9251af4bd2"
uuid = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
version = "0.24.1"

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

[[IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "61aa005707ea2cebf47c8d780da8dc9bc4e0c512"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.4"

[[IntervalSets]]
deps = ["Dates", "EllipsisNotation", "Statistics"]
git-tree-sha1 = "3cc368af3f110a767ac786560045dceddfc16758"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.5.3"

[[IrrationalConstants]]
git-tree-sha1 = "f76424439413893a832026ca355fe273e93bce94"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.0"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

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

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

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

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "86197a8ecb06e222d66797b0c2d2f0cc7b69e42b"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.2"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "5455aef09b40e5020e1520f551fa3135040d4ed0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+2"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "5a5bc6bf062f0f95e62d0fe0a2d99699fed82dd9"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.8"

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

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "2ca267b08821e86c5ef4376cffed98a46c2cb205"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.1"

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
deps = ["ColorVectorSpace", "FileIO", "ImageCore"]
git-tree-sha1 = "09589171688f0039f13ebe0fdcc7288f50228b52"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.1"

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

[[Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "2276ac65f1e236e0a6ea70baff3f62ad4c625345"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.2"

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

[[RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[Ratios]]
deps = ["Requires"]
git-tree-sha1 = "7dff99fbc740e2f8228c6878e2aad6d7c2678098"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.1"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[Rotations]]
deps = ["LinearAlgebra", "StaticArrays", "Statistics"]
git-tree-sha1 = "2ed8d8a16d703f900168822d83699b8c3c1a5cd8"
uuid = "6038ab10-8711-5258-84ad-4b1120ba62dc"
version = "1.0.2"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

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
git-tree-sha1 = "a8f30abc7c64a39d389680b74e749cf33f872a70"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.3.3"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3240808c6d463ac46f1c1cd7638375cd22abbccb"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.12"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "8cbbc098554648c84f79a463c9ff0fd277144b6c"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.10"

[[StringDistances]]
deps = ["Distances"]
git-tree-sha1 = "a4c05337dfe6c4963253939d2acbdfa5946e8e31"
uuid = "88034a9c-02f8-509d-84a9-84ec65e18404"
version = "0.10.0"

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

[[TestImages]]
deps = ["AxisArrays", "ColorTypes", "FileIO", "OffsetArrays", "Pkg", "StringDistances"]
git-tree-sha1 = "db28237376a6b7ae9c9fe05880ece0ab8bb90b75"
uuid = "5e47fb64-e119-507b-a336-dd2b206d9990"
version = "1.6.1"

[[TiffImages]]
deps = ["ColorTypes", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "OffsetArrays", "OrderedCollections", "PkgVersion", "ProgressMeter"]
git-tree-sha1 = "632a8d4dbbad6627a4d2d21b1c6ebcaeebb1e1ed"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.4.2"

[[TiledIteration]]
deps = ["OffsetArrays"]
git-tree-sha1 = "52c5f816857bfb3291c7d25420b1f4aca0a74d18"
uuid = "06e1c1a7-607b-532d-9fad-de7d9aa2abac"
version = "0.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "59e2ad8fd1591ea019a5259bd012d7aee15f995c"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

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
# ╟─e6b6760a-f37f-11ea-3ae1-65443ef5a81a
# ╟─ec66314e-f37f-11ea-0af4-31da0584e881
# ╟─85cfbd10-f384-11ea-31dc-b5693630a4c5
# ╠═33e43c7c-f381-11ea-3abc-c942327456b1
# ╟─938185ec-f384-11ea-21dc-b56b7469f798
# ╠═a4937996-f314-11ea-2ff9-615c888afaa8
# ╟─0f271e1d-ae16-4eeb-a8a8-37951c70ba31
# ╟─6dabe5e2-c851-4a2e-8b07-aded451d8058
# ╠═ab276048-f34b-42dd-b6bf-0b83c6d99e6a
# ╠═0d144802-f319-11ea-0028-cd97a776a3d0
# ╟─a5271c38-ba45-416b-94a4-ba608c25b897
# ╟─365349c7-458b-4a6d-b067-5112cb3d091f
# ╟─b49e8cc8-f381-11ea-1056-91668ac6ae4e
# ╠═90a22cc6-f327-11ea-1484-7fda90283797
# ╠═5370bf57-1341-4926-b012-ba58780217b1
# ╟─c075a8e6-f382-11ea-2263-cd9507324f4f
# ╠═52425e53-0583-45ab-b82b-ffba77d444c8
# ╟─a09aa706-6e35-4536-a16b-494b972e2c03
# ╠═268546b2-c4d5-4aa5-a57f-275c7da1450c
# ╟─6aeb2d1c-8585-4397-a05f-0b1e91baaf67
# ╠═2f945ca3-e7c5-4b14-b618-1f9da019cffd
# ╟─c086bd1e-f384-11ea-3b26-2da9e24360ca
# ╟─318a2256-f369-11ea-23a9-2f74c566549b
# ╟─7a44ba52-f318-11ea-0406-4731c80c1007
# ╠═6c7e4b54-f318-11ea-2055-d9f9c0199341
# ╠═74059d04-f319-11ea-29b4-85f5f8f5c610
# ╟─0b9ead92-f318-11ea-3744-37150d649d43
# ╠═d184e9cc-f318-11ea-1a1e-994ab1330c1a
# ╠═cdfb3508-f319-11ea-1486-c5c58a0b9177
# ╠═f010933c-f318-11ea-22c5-4d2e64cd9629
# ╟─5fccc7cc-f369-11ea-3b9e-2f0eca7f0f0e
# ╠═e9402079-713e-4cfd-9b23-279bd1d540f6
# ╠═6f37b34c-f31a-11ea-2909-4f2079bf66ec
# ╠═9fa0cd3a-f3e1-11ea-2f7e-bd73b8e3f302
# ╟─f7eba2b6-f388-11ea-06ad-0b861c764d61
# ╟─87afabf8-f317-11ea-3cb3-29dced8e265a
# ╟─8ba9f5fc-f31b-11ea-00fe-79ecece09c25
# ╠═f5a74dfc-f388-11ea-2577-b543d31576c6
# ╟─2f9cbea8-f3a1-11ea-20c6-01fd1464a592
# ╟─c3543ea4-f393-11ea-39c8-37747f113b96
# ╠═abf20aa0-f31b-11ea-2548-9bea4fab4c37
# ╟─5430d772-f397-11ea-2ed8-03ee06d02a22
# ╟─6f52c1a2-f395-11ea-0c8a-138a77f03803
# ╠═5057652e-2f88-40f1-82f0-55b1b5bca6f6
# ╠═2a7e49b8-f395-11ea-0058-013e51baa554
# ╟─2643b00d-2bac-4868-a832-5fb8ad7f173f
# ╟─a4d14606-7e58-4770-8532-66b875c97b70
# ╠═38f70c35-2609-4599-879d-e032cd7dc49d
# ╟─1413d047-099f-48c9-bbb0-ff0a3ddb4888
# ╟─9945ae78-f395-11ea-1d78-cf6ad19606c8
# ╟─87efe4c2-f38d-11ea-39cc-bdfa11298317
# ╟─f6571d86-f388-11ea-0390-05592acb9195
# ╟─f626b222-f388-11ea-0d94-1736759b5f52
# ╟─52452d26-f36c-11ea-01a6-313114b4445d
# ╠═2a98f268-f3b6-11ea-1eea-81c28256a19e
# ╟─32e9a944-f3b6-11ea-0e82-1dff6c2eef8d
# ╟─9101d5a0-f371-11ea-1c04-f3f43b96ca4a
# ╠═8ec27ef8-f320-11ea-2573-c97b7b908cb7
# ╠═ad524df7-29e2-4f0d-ad72-8ecdd57e4f02
# ╠═1add9afd-5ff5-451d-ad81-57b0e929dfe8
# ╟─414dd91b-8d05-44f0-8bbd-b15981ce1210
# ╟─447e54f8-d3db-4970-84ee-0708ab8a9244
# ╠═8b8da8e7-d3b5-410e-b100-5538826c0fde
# ╟─e1074d35-58c4-43c0-a6cb-1413ed194e25
# ╠═281b950f-2331-4666-9e45-8fd117813f45
# ╟─9f18efe2-f38e-11ea-0871-6d7760d0b2f6
# ╟─a7f3d9f8-f3bb-11ea-0c1a-55bbb8408f09
# ╠═fa8e2772-f3b6-11ea-30f7-699717693164
# ╟─18e0fd8a-f3bc-11ea-0713-fbf74d5fa41a
# ╟─cbf29020-f3ba-11ea-2cb0-b92836f3d04b
# ╟─8bc930f0-f372-11ea-06cb-79ced2834720
# ╠═85033040-f372-11ea-2c31-bb3147de3c0d
# ╟─f92ac3e4-fa70-4bcf-bc50-a36792a8baaa
# ╠═7ac5eb8d-9dba-4700-8f3a-1e0b2addc740
# ╟─9ff0ce41-327f-4bf0-958d-309cd0c0b6e5
# ╟─c572f6ce-f372-11ea-3c9a-e3a21384edca
# ╠═6d993a5c-f373-11ea-0dde-c94e3bbd1552
# ╟─ea417c2a-f373-11ea-3bb0-b1b5754f2fac
# ╟─56a7f954-f374-11ea-0391-f79b75195f4d
# ╠═b1d09bc8-f320-11ea-26bb-0101c9a204e2
# ╠═1947f304-fa2c-4019-8584-01ef44ef2859
# ╟─8992172e-c5b6-463e-a06e-5fe42fb9b16b
# ╟─b387f8e8-dced-473a-9434-5334829ecfd1
# ╟─344964a8-7c6b-4720-a624-47b03483263b
# ╠═3e8b0868-f3bd-11ea-0c15-011bbd6ac051
# ╠═d941c199-ed77-47dd-8b5a-e34b864f9a79
# ╠═726280f0-682f-4b05-bf5a-688554a96287
# ╟─c1ab3d5f-8e6c-4702-ad40-6c7f787f1c43
# ╟─4e3bcf88-f3c5-11ea-3ada-2ff9213647b7
# ╟─4e3ef866-f3c5-11ea-3fb0-27d1ca9a9a3f
# ╟─6e73b1da-f3c5-11ea-145f-6383effe8a89
# ╟─cf39fa2a-f374-11ea-0680-55817de1b837
# ╠═c8724b5e-f3bd-11ea-0034-b92af21ca12d
# ╠═6435994e-d470-4cf3-9f9d-d00df183873e
# ╠═be7d40e2-f320-11ea-1b56-dff2a0a16e8d
# ╟─507f3870-f3c5-11ea-11f6-ada3bb087634
# ╟─50829af6-f3c5-11ea-04a8-0535edd3b0aa
# ╟─9e56ecfa-f3c5-11ea-2e90-3b1839d12038
# ╟─4f48c8b8-f39d-11ea-25d2-1fab031a514f
# ╟─24792456-f37b-11ea-07b2-4f4c8caea633
# ╠═ff055726-f320-11ea-32f6-2bf38d7dd310
# ╟─e0622780-f3b4-11ea-1f44-59fb9c5d2ebd
# ╠═51731519-1831-46a3-a599-d6fc2f7e4224
# ╠═99efaf6a-0109-4b16-89b8-f8149b6b69c2
# ╠═d3e69cf6-61b1-42fc-9abd-42d1ae7d61b2
# ╟─e06d4e4a-146c-4dbd-b742-317f638a3bd8
# ╠═92e19f22-f37b-11ea-25f7-e321337e375e
# ╠═795eb2c4-f37b-11ea-01e1-1dbac3c80c13
# ╟─51df0c98-f3c5-11ea-25b8-af41dc182bac
# ╟─51e28596-f3c5-11ea-2237-2b72bbfaa001
# ╟─0a10acd8-f3c6-11ea-3e2f-7530a0af8c7f
# ╟─946b69a0-f3a2-11ea-2670-819a5dafe891
# ╟─0fbe2af6-f381-11ea-2f41-23cd1cf930d9
# ╟─48089a00-f321-11ea-1479-e74ba71df067
# ╟─6b4d6584-f3be-11ea-131d-e5bdefcc791b
# ╟─437ba6ce-f37d-11ea-1010-5f6a6e282f9b
# ╟─ef88c388-f388-11ea-3828-ff4db4d1874e
# ╟─ef26374a-f388-11ea-0b4e-67314a9a9094
# ╟─6bdbcf4c-f321-11ea-0288-fb16ff1ec526
# ╟─ffc17f40-f380-11ea-30ee-0fe8563c0eb1
# ╟─ffc40ab2-f380-11ea-2136-63542ff0f386
# ╟─ffceaed6-f380-11ea-3c63-8132d270b83f
# ╟─ffde44ae-f380-11ea-29fb-2dfcc9cda8b4
# ╟─ffe326e0-f380-11ea-3619-61dd0592d409
# ╟─fff5aedc-f380-11ea-2a08-99c230f8fa32
# ╟─00026442-f381-11ea-2b41-bde1fff66011
# ╟─fbf6b0fa-f3e0-11ea-2009-573a218e2460
# ╟─256edf66-f3e1-11ea-206e-4f9b4f6d3a3d
# ╟─00115b6e-f381-11ea-0bc6-61ca119cb628
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
