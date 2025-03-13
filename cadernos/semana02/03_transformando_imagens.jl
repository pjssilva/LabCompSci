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

# ╔═╡ b310756a-af08-48b0-ae10-ee2e8dd0c968
filter!(LOAD_PATH) do path
    path != "@v#.#"
end;

# ╔═╡ 86f770fe-74a1-11eb-01f7-5b3ecf057124
begin
	using LinearAlgebra
    import PNGFiles
    import ImageIO
    import ImageMagick
    using PlutoUI
    using Colors, ColorVectorSpace, ImageShow, FileIO
    using Unitful
    using ImageFiltering
    using OffsetArrays
    using Plots
	import PlotlyBase
	import PlotlyKaleido
    using BenchmarkTools
	import Folds
end

# ╔═╡ f5c464b6-663a-4c4d-9e93-30e469d3a496
md"Tradução livre de [`transforming_images.jl`](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week2/transforming_images.jl) + parte final de bordas"

# ╔═╡ 8d389d80-74a1-11eb-3452-f38eff03483b
PlutoUI.TableOfContents(aside=true)

# ╔═╡ 9f1a72da-7532-11eb-079c-b7baccc6614a
md"""
#### Iniciando os pacotes

_Ao executar esse notebook a primeira ele pode levar até 15 min, tenha paciência!_
"""

# ╔═╡ 4d332c7e-74f8-11eb-1f49-a518246d1db8
md"""
# Aulas ideais seriam de aproximadamente uma hora (mas no lab há interrupções)
"""

# ╔═╡ f7689472-74a8-11eb-32a1-8379ae5c88e1
rotabook = PlutoUI.Resource(
    "https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1348902666l/1646354.jpg",
)

# ╔═╡ 0f2f9004-74a8-11eb-01a2-973dbe80f166
md"""
##  **Nunca passe do tempo** (um microséculo com Unitful)

Passar do tempo é um dos piores erros que um palestrante pode fazer. O ideal seria  seguir a sugestão do von Neumann e tentar limitar nossas aulas a um microséculo.  Depois disso, ele dizia que a atenção da audiência se perdia mesmo se ele estivesse apresentando uma demonstração da hipótese de Riemann. Mas isso porque ele não estava dando aula em um laboratório de computação para múltiplos alunos com várias "probleminhas" surgindo do nada. Ele dizia que um minuto de estouro já pode arruinar uma ótima apresentação (de "Indiscrete Thoughts" by Rota, Chpt 18, 10 Lessons I Wish I Had Been Taught).

Tá, mas porque estou falando isso? É só para mostrar mais um pacote de Julia.  Uma boa linguagem deve ter ao seu redor um rico ecossistema que estende as suas capacidades para problemas além da biblioteca padrão. Isso é verdade mesmo para Python, que tem o mantra de vir "com baterias inclusas". Outra característica interessante da linguagem é disponibilizar ferramentas para "estender sintaxe" criando formas naturais de escrever código que expresse as novas construções.

O pacote `Unitful.jl` é um pacote para dar suporte a unidades de medida (físicas) permitindo manter as unidades associadas a valores de forma eficiente,. Isso ajuda na análise dimensional e outras funcionalidades. Vejamos ele em ação.
"""

# ╔═╡ 962143a8-74a7-11eb-26c3-c10548f326ee
century = 100u"yr" #  A u"yr" é uma string especial que denota a unidade de tempo "um ano"

# ╔═╡ c2964c80-74f8-11eb-3a74-b1bdd9e4ae02
century * 2

# ╔═╡ caf488d8-74f8-11eb-0075-0586d66c23c1
century / 200

# ╔═╡ 02dd4a02-74f9-11eb-3d1e-53d83cee8062
century^2

# ╔═╡ 10ef13d2-74f9-11eb-2849-fb9f83db6ae9
g = 9.8u"m" / u"s"^2

# ╔═╡ b76a56f4-74a9-11eb-1739-fbfc5e4958e8

uconvert(u"minute", 1.0e-6 * century) # Ôpa, aqui vemos quanto tempo é o microséculo!

# ╔═╡ 77fbf18a-74f9-11eb-1d9e-3f9d2097388f
PotentialEnergy = 10u"kg" * g * 50u"m"

# ╔═╡ bcb69db6-74f9-11eb-100a-29d1d23963ab
uconvert(u"J", PotentialEnergy)

# ╔═╡ fc70c4d2-74f8-11eb-33f5-539c278ed6b6
md"""
Adicionar a informação de unidades ao números *funciona naturalmente* em Julia. Isso é feito com cuidado para não penalizar o tempo de execução. Já o uso de strings especiais definidas pelo usuário, marcadas por um código antes do abre aspas como no caso de Markdown (md), LaTeX (L) e agora unidades de medida (u), ajudaram a deixar o código legível. Essa é uma das muitas características que fazem de Julia uma ótima linguagem para programar. Por exemplo, com as unidades bem definidas, se no final de uma conta que deveria calcular energia obtemos algo em m/s (velocidade) sabemos que há um erro em algum lugar e temos até uma dica que qual tipo de erro para procurar. O sistema também ajuda a pegar situações onde você mistura unidades incompatíveis.
"""

# ╔═╡ c9ce62a6-f368-49f9-b473-fa88224e07e3
10u"kg" + 20u"m"

# ╔═╡ e1131709-136e-494d-9a37-be7225c87bf4
md"Outra coisa que o sistema faz é converter unidades compatíveis automaticamente."

# ╔═╡ 6aae9a23-c7cc-4b1a-8ea8-4ed853f74067
10.0u"m" + 5u"cm"

# ╔═╡ 0e81fe50-8264-4c1a-a9c4-a02c97281aae
md"Durante esse curso veremos outras funcionalidades da linguagem que ajudam a exprimir código legível, eficiente e enxuto."

# ╔═╡ 2f7cde78-74a2-11eb-1e2f-81b5b2465819
md"""
#### Lembrete

**Você pode trocar as figuras abaixo pelas suas próprias figuras**

Simplesmente troque a URL ou a localização do arquivo.
"""

# ╔═╡ e099815e-74a1-11eb-1541-033f6abe9f8e
md"""
# Transformando imagens
"""

# ╔═╡ e82a4dd8-74b0-11eb-1108-6b09e67a80c1
md"""
## Downsampling / Upsampling (sei lá como traduz...)
"""

# ╔═╡ 39552b7a-74fb-11eb-04e0-3981ada52c92
md"""
Como "pixelar" um cachorro? A figura abaixo está online, mas vamos pixelar um
cachorro real.
"""

# ╔═╡ 14f2b85e-74ad-11eb-2682-d9de646aedf3
pixelated_corgi = load(download("https://i.redd.it/99lhfbnwpgd31.png"))

# ╔═╡ 516e73e2-74fb-11eb-213e-9dbd9472e0db
apolo = load(
    download("https://www.ime.unicamp.br/~pjssilva/images/ensino/labcompsci/apolo1.png"),
)

# ╔═╡ b5d0ef90-74fb-11eb-3126-792f954c7be7
@bind r Slider(1:20, show_value=true, default=20)

# ╔═╡ 754c3704-74fb-11eb-1199-2b9798d7251f
downsample_apolo = apolo[1:r:end, 1:r:end]

# ╔═╡ 9eb917ba-74fb-11eb-0527-15e981ce9c6a
upsample_apolo = kron(downsample_apolo, ones(r, r))

# ╔═╡ 486d3022-74ff-11eb-1865-e15436bd9aad
md"""
Vejam que para "ampliar" a imagem usamos o [produto de Kronecker](https://en.wikipedia.org/wiki/Kronecker_product), implementado pela função `kron` e uma matriz de uns obtida com `ones`.
"""

# ╔═╡ b9da7332-74ff-11eb-241b-fb87e77d646a
md"""
**Exercício**: Modifique o notebook para acrescentar sliders, como fizemos para selecionar o nariz do Apolo, e assim escolher uma região retangular na imagem para ser pixelada.
"""

# ╔═╡ 339ccfca-74b1-11eb-0c35-774da6b189ed
md"""
## Combinações lineares (combinando imagens)
"""

# ╔═╡ 8711c698-7500-11eb-2505-d35a4de169b4
md"""
Uma das ideias fundamentais de Matemática são as _combinações lineares_. Tópico essencial do curso de Álgebra Linear. Lembrando, uma combinação linear é composta de operações do tipo:

- escalamento: multiplicar um objeto por um escalar de maneira a ampliá-lo, encolhê-lo e/ou invertê-lo.

- soma: combinar dois objetos do mesmo tipo, obtendo uma combinação dos dois.
"""

# ╔═╡ 84350cb8-7501-11eb-095e-8f1a7e015f25
md"""
Mas as imagens nada mais são que matrizes e matrizes podem ser vistas como vetores. Vamos agora combinar imagens do Apolo.
"""

# ╔═╡ 91a1bca4-74aa-11eb-3917-1dfd73d0ad9c
apolohead = load(
    download(
        "https://www.ime.unicamp.br/~pjssilva/images/ensino/labcompsci/cabeca_apolo.png",
    ),
)

# ╔═╡ 8e698bdc-7501-11eb-1d2e-c336ccbde0b0
@bind c Slider(0:0.1:3, show_value=true, default=1)

# ╔═╡ ab2bc924-7501-11eb-03ba-8dfc1ffe3f36
c .* apolohead  # scaling the apolohead changes intensity

# ╔═╡ e11d6300-7501-11eb-239a-135596309d20
md"""
Multiplicar por números muito grandes satura a imagem. Lembre que os valores máximos para os canais r, g, b é 1, valores r, g, b ≥ 1, saturam em 1.

Obs: Você deve estar pensando porque  fizemos questão de usar o **ponto vezes (.*)** na última expressão acima já que Julia sabe multiplicar um número por uma array. Isso foi feito porque internamente Julia tentar transformar operações que envolve operadores **element-a-elemento** em laços implícitos evitando a criação de grandes objetos temporários implicitamente. Isso de fato ocorre acima. Pense que o ponto enfatiza que a multiplicação por `c` está ocorrendo pixel-a-pixel e que o `c` está sendo difundido para atuar sobre todos os pixels.

Note que isso pode fazer diferença em alguns casos:
"""

# ╔═╡ 39c73cc7-2ca8-4e4e-8651-ec0b87f37e94
tmp = similar(1.5 * apolo);

# ╔═╡ e0988dbd-93ba-4428-8b47-fc5745fa85a8
@benchmark tmp = 1.5 * apolo

# ╔═╡ 6cb2a804-bd0c-4375-9dd6-4b74e2490380
@benchmark tmp .= 1.5 .* apolo

# ╔═╡ 47d40406-7502-11eb-2f43-cd5c848f25a6
md"""
Vamos agora virar o Apolo de cabeça para baixo.
"""

# ╔═╡ 9ce0b980-74aa-11eb-0678-01209451fb65
upsidedown_apolohead = apolohead[end:-1:1, :]

# ╔═╡ 68821bf4-7502-11eb-0d3c-03d7a00fdba4
md"""
Vamos somar versões escaladas das duas iamgens e ver o que ocorre.
"""

# ╔═╡ 447e7c9e-74b1-11eb-27ea-71aa4338b11a
(0.5 * upsidedown_apolohead .+ 0.5 * apolohead)

# ╔═╡ c9dff6f4-7503-11eb-2715-0bf9d3ece9e1
md"""
### Combinações convexas
"""

# ╔═╡ d834103c-7503-11eb-1a94-1fbad43801ff
md"""
Se numa combinação linear os coeficientes são positivos e somam um, dizemos que essa é uma _combinação convexa_. Pense nessa operação como uma média. Do ponto de vista vetorial seria encontrar um vetor que está no meio do caminho (ou segmento) que une os dois vetores.

Note que quando temos somente dois vetores, se um dos coeficiente é α ou outro será (1 - α) para somar 1. Note que também é necessário que $\alpha \in [0, 1]$, senão o outro coeficiente seria negativo.

Vamos escrever abaixo uma versão interativa do código acima que nos permite observar todas as combinações convexas das imagens dos vira-latas e sua inversão.
"""

# ╔═╡ aa541288-74aa-11eb-1edc-ab6d7786f271
@bind α Slider(0:0.01:1, show_value=true, default=1.0)

# ╔═╡ c9dcac48-74aa-11eb-31a6-23357180c1c8
α .* apolohead .+ (1 - α) .* upsidedown_apolohead

# ╔═╡ 30b1c1f0-7504-11eb-1be7-a9463caea809
md"""
Algo interessante que o prof. Edelman, autor desse caderno, notou e que também ocorre comigo é que olhando para essa imagem o meu cérebro parece preferir ver o Apolo "de pé" no lugar do Apolo "de cabeça-para-baixo". Mas a imagem é criada com a média aritmética dos dois, não há motivo "matemático" para isso ocorrer. Aqui é um dos momentos que o nosso cérebro tenta ser esperto e acaba "escolhendo" o que é mais natural para ele. Para mim eu preciso pegar numa combinação do tipo α = 0.4 (o peso da imagem em pé), para achar que as duas versões estão "equilibradas".
"""

# ╔═╡ 1fe70e38-751b-11eb-25b8-c741e1726613
md"""
Há uma área do conhecimento que tenta lidar com isso, chamada psicometria. Ela tenta analisar como nosso cérebro usa as medidas para construir um modelo do mundo em torno de nós. Esse tipo de informação pode ser útil e é explorado em soluções tecnológicas. Por exemplo modelos [psicoacústicos](https://pt.wikipedia.org/wiki/Psicoac%C3%BAstica) são usados no desenvolvimento de codecs de audio como o MP3, Vorbis ou Celph.

Sobre esse fenômeno específico de imagens de rostos é certamente estudado. Ele é conhecido como [efeito de inversão de faces](https://en.wikipedia.org/wiki/Face_inversion_effect#:~:text=The%20face%20inversion%20effect%20is,same%20for%20non%2Dfacial%20objects.&text=The%20most%20supported%20explanation%20for,is%20the%20configural%20information%20hypothesis)
e está relacionado ao [efeito Thatcher](https://en.wikipedia.org/wiki/Thatcher_effect#:~:text=The%20Thatcher%20effect%20or%20Thatcher,obvious%20in%20an%20upright%20face).

... os artigos falam de faces humanas e sugerem que esse tipo de confusão não ocorre com objetos. é interessante, que o mesmo fenômeno ocorre com rostos de cães, sugerindo que a parte do nosso cérebro responsável pelo **processamento de rostos** é usada para processar as faces de alguns animais como cães. Será que é sempre assim? Será que o mesmo ocorre com a face de uma ave ou outro animal? Testem vocês, agora é fácil.
"""

# ╔═╡ 215291ec-74a2-11eb-3476-0dab43fd5a5e
md"""
## Diversão com Gimp (ou Photoshop): o que é um "filtro" nesse contexto?
"""

# ╔═╡ 61db42c6-7505-11eb-1ddf-05e906234572
md"""
[Referência de filtros do Gimp](https://docs.gimp.org/en/filters.html)
"""

# ╔═╡ cdd4cffc-74b1-11eb-1aa4-e333cb8601d1
md"""
Se usamos um programa de processamento de imagens, como o Gimp ou Photoshop, vemos que ele disponibiliza vários filtros para ajudar na manipulação desses objetos. Algums filtros que podemos destacar são:

1. Desfocagem (blur)
1. Nitidez (sharpen)
1. Bordas (Find edges)
1. Pixelar (Pixelate)
3. Distorções

Algumas dessas transformações, como desfocar, aumentar nitidez ou encontrar bordas, são exemplos de convoluções que podem ser implementadas de forma muito eficiente e aparecem naturalmente em aplicações de aprendizado de máquina, em particular em reconhecimento de imagens.
"""

# ╔═╡ 7489a570-74a3-11eb-1d0b-09d41604ffe1
md"""
## Filtros de imagens (convoluções)
"""

# ╔═╡ 8a8e3f5e-74b2-11eb-3eed-e5468e573e45
md"""
Vamos começar vendo uma rápida introdução a filtros de covolução feitas pelo 3Blue1Brown (Grant Sanderson) em uma das versões originais desse curso. Vamos usar apenas uns trechos curtos e depois discuti-los com vocês. Mas é claro que podem assistir a versão completa do vídeo depois se quiserem.
"""

# ╔═╡ 5864294a-74a5-11eb-23ef-f38a582f2c2d
html"""
<div notthestyle="position: relative; right: 0; top: 0; z-index: 300;"><iframe src="https://www.youtube.com/embed/8rrHTtUzyZA?start=64&end=168" width=400 height=250  frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div>
"""

# ╔═╡ fa9c465e-74b2-11eb-2f3c-4be0e7f93bb5
md"""
### Definição de convoluções e núcleos
"""

# ╔═╡ 4fab4616-74b0-11eb-0088-6b50237d7d54
md"""
O que são esses filtros de convoluções? Bom você pode ler a página da Wikipedia sobre [Kernels]
(https://en.wikipedia.org/wiki/Kernel_(image_processing)). Mas vou tentar fazer uma rápida explicação própria.

Um filtro de convolução é baseado na ideia de sintetizar uma nova imagem cujos pixels são obtidos por uma "conta simples" feita entre pixels vizinhos. Isso pode ser feito imaginando, como no vídeo, que colocamos uma matriz centrada no pixel que queremos calcular. Essa matriz seleciona o pixel central e seus vizinhos e multiplica todos os pixels pelos valores de suas entradas e soma os resultados obtendo o valor final. Obtemos então um efeito diferente dependendo da estrutura (dimensões) da matriz e dos valores usados no produto. No exemplo do vídeo, a matriz modelava a ideia de se calcular a média entre todos os vizinhos e isso gerava um efeito de desfocagem.

Outros efeitos são possíveis de acordo com a matriz escolhida. Vamos ver alguns exemplos abaixo e pensar porque o efeito obtido ocorre.
"""

# ╔═╡ 54448d18-7528-11eb-209a-9717affa0d02
kernelize(M) = OffsetArray(M, -1:1, -1:1)

# ╔═╡ acbc563a-7528-11eb-3c38-75a5b66c9241
begin
    identity = [
        0 0 0
        0 1 0
        0 0 0
    ]
    edge_detect = [
        0 -1 0
        -1 4 -1
        0 -1 0
    ]
    sharpen = identity .+ edge_detect # Superposition!
    box_blur = [
        1 1 1
        1 1 1
        1 1 1
    ] / 9
    ∇x = [
        -1 0 1
        -1 0 1
        -1 0 1
    ] / 2 # centered deriv in x
    ∇y = ∇x'

    kernels = [identity, edge_detect, sharpen, box_blur, ∇x, ∇y]
    kernel_keys = ["identity", "edge_detect", "sharpen", "box_blur", "∇x", "∇y"]
    kernel_matrix = Dict(kernel_keys .=> kernels)
    md"$(@bind kernel_name Select(kernel_keys))"
end

# ╔═╡ 995392ee-752a-11eb-3394-0de331e24f40
sel_kernel = kernelize(kernel_matrix[kernel_name])

# ╔═╡ d22903d6-7529-11eb-2dcd-132cd27104c2
begin
    filtered = imfilter(apolohead, sel_kernel)
    if kernel_name in ["edge_detect", "∇x", "∇y"]
        # Edge style filters can return negative values naturally.
        # Therefore, we want absolute values and it makes more sense
        # to show the result in Black and White.
        filtered = Gray.(3.0 .* abs.(filtered))
    end
    # Show both images side by side
    [apolohead filtered]
end

# ╔═╡ 275bf7ac-74b3-11eb-32c3-cda1e4f1f8c2
md"""
### Análise Complexidade (tempo de execução)

De uma forma geral o tempo de execução é dominando por acessar a imagem e fazer as operações necessárias (multiplicações e somas). Ele será proporcional então ao

**Número de pixels na imagem × Número de células no núcleo**

Nesse sentido, os núcleos menores resultam em menor tempo de execução. Porém outro fator importante é que o tamanho natural do núcleo a ser usado deve também levar em consideração o tamanho da imagem. Afinal de contas núcleos muito pequenos em imagens grandes vão cobrir uma área uma muito pequena, acessando pouca informação.
"""

# ╔═╡ c6e340ee-751e-11eb-3ca7-69595b3693b7
md"""
### Arquitetura de hardware: GPUs (Unidades de processamento gráfico)

O uso de kernels de convolução em imagens é um exemplo típico de operações usadas em seu processamento. Elas normalmente resultam um um grupo de operações simples e bem estruturadas que devem ser realizadas em enorme quantidade e com pouca interdependência entre si. Para isso, com o tempo, os fabricantes de placas gráficas começaram a criar hardware específico que é capaz de realizar essas operações de forma muito rápida explorando o seu paralelismo intrínseco. Com isso nasceram as placas de aceleração para gráficos, as GPUs. Elas são compostas de uma grande quantidade de processadores que conseguem realizar esse tipo de operações de forma paralela e muito eficiente.

É interessante que com o tempo começou-se a usar as placas aceleradoras gráficas para realizar outras operações matemáticas que não estavam relacionadas diretamente ao processamento de imagens. Isso porque em outros domínios também há algoritmos que necessitam dessas de operações repetitivas, estruturadas e facilmente paralelizáveis. Assim, hoje em dia muitos dos supercomputadores são compostos por uma mistura de CPUs e GPUs que se adéquam ao tipo de processamento que se pretende fazer. As CPUs funcionam melhor para lidar com operações de fluxo mais complexo, já as GPUs brilham com operações altamente estruturadas e repetitivas.
"""

# ╔═╡ 844ed844-74b3-11eb-2ee1-2de664b26bc6
md"""
### Filtros gaussianos
"""

# ╔═╡ 4ffe927c-74b4-11eb-23a7-a18d7e51c75b
md"""
Uma variação dos filtros de desfocagem que é muito útil são os filtros gaussianos. Neles dá-se maior peso ao centro do núcleo (onde está o pixel resultante) e eles decaem continuamente para as extremidades diminuído o peso a medida que se afastam do centro. Vamos mais uma vez pedir ajuda ao nosso amigo Grant Sanderson (atenção ao trecho 4:35-7:00, com ênfase no instante 5:23):
"""

# ╔═╡ 91109e5c-74b3-11eb-1f31-c50e436bc6e0
html"""
<div notthestyle="position: relative; right: 0; top: 0; z-index: 300;"><iframe src="https://www.youtube.com/embed/8rrHTtUzyZA?start=275&end=420" width=400 height=250  frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div>
"""

# ╔═╡ 34109062-7525-11eb-10b3-d59d3a6dfda6
round.(Kernel.gaussian(1), digits=3)

# ╔═╡ 9ab89a3a-7525-11eb-186d-29e4b61deb7f
md"""
Acima usamos a rotina Kernel.gaussian que já está pronta no pacote `ImageFiltering.jl`, o mesmo que define a função `imfilter` que usamos para aplicar os filtros. Mas podemos também fazer as contas rapidamente, usando a função exponencial.
"""

# ╔═╡ 50034058-7525-11eb-345b-3334e71ac50e
begin
    G = [exp(-(i^2 + j^2) / 2) for i = -2:2, j = -2:2]
    round.(G ./ sum(G), digits=3)
end

# ╔═╡ c0aec7ae-7505-11eb-2822-a151aad48fc9
md"""
Esse tipo de filtro é conhecido como _desfocagem gaussiana_. O nome vem da fórmula usada na sua definição. Veja por exemplo [um texto da Adobe sobre desfocagem gaussiana](https://www.adobe.com/creativecloud/photography/discover/gaussian-blur.html).
"""

# ╔═╡ 99eeb11c-7524-11eb-2154-df7d84976445
@bind gparam Slider(0:9, show_value=true, default=1)

# ╔═╡ 2ddcfb90-7520-11eb-2df7-172d07118b7e
kernel = Kernel.gaussian(gparam)

# ╔═╡ d62496b0-7524-11eb-3410-7177e7c7f8eb
plotly()

# ╔═╡ 6aa8a76e-7524-11eb-22b5-015aab4191b0
surface(kernel)

# ╔═╡ ee93eeb2-7524-11eb-342d-0343d8aebf59
md"""
Obs: as linhas pretas são curvas de nível e a visão do gráfico com relação aos eixos.
"""

# ╔═╡ 662d73b6-74b3-11eb-333d-f1323a001000
md"""
### Computação: estrutura de dados: arrays com deslocamento de índices (_offset_)
"""

# ╔═╡ d127303a-7521-11eb-3507-7341a416211f
kernel[0, 0]

# ╔═╡ d4581b56-7522-11eb-2c15-991c0c790e67
kernel[-2, 2]

# ╔═╡ 40c15c3a-7523-11eb-1f2a-bd90b127dad2
M = [
    1 2 3 4 5
    6 7 8 9 10
    11 12 13 14 15
]

# ╔═╡ 08642690-7523-11eb-00dd-63d4cf6513dc
Z = OffsetArray(M, -1:1, -2:2)

# ╔═╡ deac4cf2-7523-11eb-2832-7b9d31389b08
the_indices = [c.I for c ∈ CartesianIndices(Z)]

# ╔═╡ 32887dfa-7524-11eb-35cd-051eff594fa9
Z[1, -2]

# ╔═╡ 0f765670-7506-11eb-2a37-931b15bb387f
md"""
## Contínuo vs discreto
"""

# ╔═╡ 82737d28-7507-11eb-1e39-c7dc12e18882
md"""
Muitas pessoas se sentem mais a vontade com objetos discretos e outros com matemática contínua (meu caso). Mas o computador mostra que a diferença nem sempre é muito clara e que muitos conceitos de uma área podem ser traduzidos para a outra. Os exemplos de núcleos estão relacionados com isso.
"""

# ╔═╡ 40d538b2-7506-11eb-116b-efeb16b3478d
md"""
### Núcleos de desfocagem ≈ Integrais × Detecção de bordas ≈ Derivadas
"""

# ╔═╡ df060a88-7507-11eb-034b-5346d67a0e0d
md"""
Para entender isso, basta pensar na relação entre derivadas e integrais. Se substituirmos f(x) por g(x) = ∫ f(t) dt for x-r ≤ t ≤ x+r, vamos suavizar (ou desfocar, misturar) o comportamento de f. Já quando calculamos a derivadas, estamos olhando para as mudanças (as variações), assim vamos detectar momentos de rápidas mudanças e com isso "detectar as bordas".
"""

# ╔═╡ 60c8db60-7506-11eb-1468-c989809c933a
md"""
## Respeitando as fronteiras
"""

# ╔═╡ 8ed0be60-7506-11eb-2769-5f7da1c66243
md"""
Aplicar um filtro de convolução nas bordas exige cuidado, próximos desse limite podemos "cair para fora da matriz" se não tomamos cuidado. De novo pode olhar o vídeo do Grant Sanderson, ele explica isso melhor que eu. Olhe os instantes 2:53-4:19.
"""

# ╔═╡ b9d636da-7506-11eb-37a6-3116d47b2787
html"""
<div notthestyle="position: relative; right: 0; top: 0; z-index: 300;"><iframe src="https://www.youtube.com/embed/8rrHTtUzyZA?start=173&end=259" width=400 height=250  frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div>
"""

# ╔═╡ 0fd8810a-3c1b-461b-a809-8ffb3bfcbb45
md"""
Como ele disse há algumas opções possíveis. Vejamos algumas um pouco mais formalmente, pois vamos implementá-las;

1. Aumentar a imagem, criando bordas falsas, que funcionem como salvaguardas, e aplicar o filtro somentre nos píxeis originais. Essa bordas falsas devem ser preenchidas com valores que façam algum sentido para o resultado ser bom como citado no vídeo. Como dito, uma opção muito natural é preencher as bordas com a cor do píxel mais próximo da imagem original.

1. Ao se tentar aplicar o filtro, calcular os índices que serão necessários e se estiverem fora da imagem, substituir os índices que apontam para fora pelos índices válidos mais próximos. Isso é equivalente às bordas de salvaguarda mas evitando usar memória extra.

1. Ao se tentar aplicar o filtro, calcular os índíces necessários e se algum deles estiver fora da imagem simplesmente devolver o píxel orignal sem alteração. Aqui a postura é que se evita circundar a imagem com bordas falsas e assim a solução natural é devolver o píxel intacto.

Vamos implementar duas rotinas que implementam as duas últimas estratégias para um único pixel.
"""

# ╔═╡ 33a998e8-3a53-44e5-a353-1ccf3bd2d41f
md"Obs: antes de começar deixa eu mostrar um comportamento interessante da função `imfilter` da biblioteca `ImageFiltering.jl`. Ela sempre converte os tipos de seus argumentos para a imagem baseada em `Float64`. Para ver isso vamos aplicar os filtros `identity` (que não deveria mudar nada) e `box_blur`  à imagem `apolohead` e verificar os tipos retornados." 

# ╔═╡ 5a1a4ca4-4223-4fe3-99ae-86453295dc52
typeof(apolohead)

# ╔═╡ bde5ca1c-44d6-446b-857e-bc39cacaea33
typeof(imfilter(apolohead, identity))

# ╔═╡ 3bb1c9b2-5ca5-46a4-8fcc-c11c5bd79139
typeof(imfilter(apolohead, box_blur))

# ╔═╡ edf08ce0-f47e-44d0-92c3-216bf187ad09
md"Como podemos ver parecer que ele sempre converte de `N0f8` para algum tipo de `Float`, possivelmente relacioando com o tipo presente no filtro. Vamos tentar deduzir uma forma de calcular o tipo correto.."

# ╔═╡ 54097a87-1233-4524-a263-4e7dfe0c6897
# Uses the automatic upcast system of Julia to convert to the right type
typeof(one(identity[1, 1])*apolohead)

# ╔═╡ 5a1c12be-bc67-4df2-9e69-35e0543d29d8
# Uses the automatic upcast system of Julia to convert to the right type
typeof(one(box_blur[1, 1])*apolohead)

# ╔═╡ 121d4880-c68c-44f1-a890-123928dd855b
typeof(one(box_blur[1, 1])*apolohead[1,1])

# ╔═╡ 2f5afff8-0ead-4840-a42d-5c39a2907b29
md"Esse tipo de conversão será usada no topo das nossas funções que aplicam filtros para conseguir um resultado comparável a `imfilter` original."

# ╔═╡ 592dab5b-efa2-44b7-a23b-cc5270a4870a
"""
    applyfilter1(K, M, i, j, m, n)

Applies filter `M` to `M[i, j]`, assume that `M` is of size `(m, n)`.

If `K` acts on pixels outside `M`, it just returns `M[i, j]`
"""
function applyfilter1(K, M, i, j, m, n)
	# This gets the zero of the correct type
	res = zero(M[1, 1])
	@inbounds for indK in CartesianIndices(K)
		# Compute the respective pixel in the image
		k, l = indK[1], indK[2]
		il, jl = i + k, j + l
		# if it leaves outside the image, abort the operatrion returning
		# the original pixel
		if il < 1 || il > m || jl < 1 || jl > n
			return M[i, j]
		end
		# Apply current weight
		res += K[k, l]*M[il, jl]
	end
	return res
end

# ╔═╡ 7020309a-5eb0-4210-a990-4ec71583d3c9
md"Using this function we can easily create a first version of imfilter."

# ╔═╡ 0d91923c-13d7-4fd1-b8da-fa549964024f
function myimfilter1(M, K)
	# Convert the image to the right type
	Ml = one(K[0, 0])*M
	m, n = size(Ml)
	res = similar(Ml)
	@inbounds for indM in CartesianIndices(M)
		res[indM] = applyfilter1(K, Ml, indM[1], indM[2], m, n)
	end
	return res
end

# ╔═╡ f5d57a7c-dabb-4672-8605-69661e9f434d
blur_kernel = kernelize(box_blur)

# ╔═╡ d56b81af-803b-4306-a24c-17c6c8afe63a
myimfilter1(apolohead, blur_kernel)

# ╔═╡ 0820f98f-ed3c-460e-822b-7ea5f375ac53
@benchmark myimfilter1(apolo, blur_kernel)

# ╔═╡ 2a41464f-b666-4ba1-8cc7-fb975b6c62b8
md"Agora vamos implementar a variante que aplica o filtro de qualquer forma usando o píxel mais próximo."

# ╔═╡ 74526d38-c8f7-4459-a625-882e1cb134b4
"""
    applyfilter2(K, M, i, j, m, n)

Applies filter `M` to `M[i, j]`, assume that `M` is of size `(m, n)`.

If `K` acts on pixels outside `M`, it just returns `M[i, j]`
"""
function applyfilter2(K, M, i, j, m, n)
	res = zero(M[1, 1])
	@inbounds for indK in CartesianIndices(K)
		# Compute the respective pixel in the image
		k, l = indK[1], indK[2]
		il, jl = clamp(i + k, 1, m), clamp(j + l, 1, n)
		# Apply current weight
		res += K[k, l]*M[il, jl] 
	end
	return res
end

# ╔═╡ 10e20805-126c-428c-a7a2-d45146140b5b
function myimfilter2(M, K)
	# Convert the image to the right type
	Ml = one(K[0, 0])*M
	m, n = size(Ml)
	res = similar(Ml)
	@inbounds for indM in CartesianIndices(Ml)
		res[indM] = applyfilter2(K, Ml, indM[1], indM[2], m, n)
	end
	return res
end

# ╔═╡ 6b360a92-e0dd-4cdd-bd39-2cc8b3300b99
myimfilter2(apolohead, blur_kernel)

# ╔═╡ aac35f1e-88ef-4030-91d8-d6917b766c68
@benchmark myimfilter2(apolo, blur_kernel)

# ╔═╡ 30880ced-75ea-4e20-acac-d00a0c081f4b
md"Tem algo estranho aí... O código das duas funções `myimfilter` é quase o mesmo. A única difereça é a função que é aplicada. Mas isso é feio, o ideal é não repetir código. Uma opção melhor é criar uma única função que receba a função a ser aplicada a cada píxel como parâmetro."

# ╔═╡ 1292aa60-c355-4442-a81f-b26039ee1126
function myimfilter(M, K, apply=applyfilter1)
	# Convert the image to the right type
	Ml = one(K[0, 0])*M
	m, n = size(Ml)
	res = similar(Ml)
	for indM in CartesianIndices(Ml)
		res[indM] = apply(K, Ml, indM[1], indM[2], m, n)
	end
	return res
end

# ╔═╡ 3fb66414-5c29-4e44-96be-db066bc6a763
@benchmark myimfilter(apolo, blur_kernel)

# ╔═╡ afa47a7b-4c45-4f87-a1cc-ffc92b8f6b69
@benchmark myimfilter(apolo, blur_kernel, applyfilter2)

# ╔═╡ 19797ee3-08ef-4700-8799-259620a4b154
md"Esse padrão de _percorrer um iterator aplicando uma função para obter uma versão modificada_ é comum. Isso pode ser feito também por uma compreensão de lista, por exemplo. Esse padrão tem um nome em computação. Ele é conhecido como aplicar um `map`. Julia também tem a rotina map para fazer isso, que deixa explícita esse intenção. Vamos ver uma implementação usando essa função."

# ╔═╡ 059b559a-e4db-4879-a9c5-14790918618b
function myimfiltermap1(M, K, apply=applyfilter1)
	Ml = one(K[0, 0])*M
	m, n = size(Ml)
	# Using an anonymous function.
	@inbounds return map(i -> apply(K, Ml, i[1], i[2], m, n), CartesianIndices(Ml))
end

# ╔═╡ 0cd1a998-521e-4e52-ac08-45bc99640500
@benchmark myimfiltermap1(apolo, blur_kernel)

# ╔═╡ 12f78a86-6abe-4e28-a6f8-6245f17b334a
@benchmark myimfiltermap1(apolo, blur_kernel, applyfilter2)

# ╔═╡ 3dfa0f35-a3b8-4964-a7ee-1cdf2c40ce68
md"Vamos agora comparar com a função da biblioteca `Imagefiltering.jl`"

# ╔═╡ c06b29a7-eeb3-4a85-8efe-c9f43eae7849
@benchmark imfilter(apolo, blur_kernel)

# ╔═╡ eded09fc-b838-43e2-9b6b-980d80af48b1
md"""
Muito mais rápido! Por quê?

## Um introdução ao paralelismo

Primeiro vamos rodar de novo o benchmark da rotina da `ImageFilterig.jl` e verificar quantos processadores estão sendo usado. Vemos que ela usa vários processadores ao mesmo tempo. Isso deve explicar a sua velocidade.

Para verificar isso vamos usar a biblioteca `Folds.jl` essa biblioteca reimplementa funções como `map` e `reduce` para usar múltiplos processadores ou mesmo múltiplos computadores em um cluster.
"""

# ╔═╡ e6fa4f26-6baa-48bd-a733-e9cc6847ef49
function myimfiltermap2(M, K, apply=applyfilter1)
	# Convert the image to the right type
	Ml = one(K[0, 0])*M
	m, n = size(Ml)
	# Using an anonymous function e a único
	@inbounds return Folds.map(i -> apply(K, Ml, i[1], i[2], m, n), CartesianIndices(Ml))
end

# ╔═╡ 56ed0197-e311-4ccc-ac4f-634ca6810553
@benchmark myimfiltermap2(apolo, blur_kernel)

# ╔═╡ 9d39577f-8300-4d71-8f24-6ff4cc798a3b
@benchmark myimfiltermap2(apolo, blur_kernel)

# ╔═╡ f98f7de4-f509-48c5-a9eb-ebe9eb3b75ff
md"Melhor, mas ainda mais lento.

Conseguimos chegar razoavelmente perto usando rotinas de alto nível e bibliotecas que permitem aproveitar o paralelismo inerente da operação de aplicar filtros em imagens de forma automática. Vamos tentar uma implementação mais explícita com laços encaixados para evitar algum overhead de chamada de função. Será que faz alguma diferença? Vou tentar adaptar a função mais rápida.
"

# ╔═╡ b555626b-822c-4695-a0c8-3c3a8eb94dda
function myimfilter3(M, K)
	# Convert the image to the right type
	Ml = one(K[0, 0])*M
	m, n = size(Ml)
	res = similar(Ml)
	for indM in CartesianIndices(Ml)
		i, j = indM[1], indM[2]
		res[indM] = 0.0
	    @inbounds for indK in CartesianIndices(K)
			# Compute the respective pixel in the image
			k, l = indK[1], indK[2]
			il, jl = i + k, j + l
			# if it leaves outside the image, abort the operatrion returning
			# the original pixel
			if il < 1 || il > m || jl < 1 || jl > n
				res[indM] = Ml[indM]
				continue
			end
			# Apply current weight
			res[indM] += K[k, l]*Ml[il, jl] 
		end
	end
	return res
end

# ╔═╡ 7eed1a6a-3d65-4d7a-b6d1-e0e144d75709
@benchmark myimfilter3(apolo, blur_kernel)

# ╔═╡ 4227f552-aba3-4eba-b725-d1e7dc85a8af
md"Não parece ter tido grande melhora com respeito à versão sequencial acima. Parece até ser um pouco mais lento. Podemos transformar essa versão em paralela prometendo para a Julia que as tarefas executadas nos laços são independentes e, portanto, podem ser paralilizadas. Para isso vou usar a macro `@threads`. Basta adicioná-las antes do primeiro laço e rodar de novo.

Mais uma vez muito parecido com a versão paralela, só que dessa vez um pouco mais rápida (isso pode variar de uma máquina para outra). Mas veio uma ideia. Olhando para o código, fica claro que ele só descobre que precisa copiar o valor original do píxel quando o filtro sai dos limites dentro do laço mais interno. Mas isso pode ser evitado se nós pré-calcularmos os índices que terão píxeis copiados. A rotina abaixo faz isso." 

# ╔═╡ 66a856c8-ea1d-4c35-8d37-2c548df3696c
function myimfilter4(M, K)
	# Convert the image to the right type
	Ml = one(K[0, 0])*M
	m, n = size(Ml)
	
	# Precomputes the bounds that will induce a pure copy from M
	Kstart = 1 .+ K.offsets
	Kend = size(K) .+ K.offsets
	lowi, upi = max(1, 1 - Kstart[1]), min(m, m - Kend[1])
	lowj, upj = max(1, 1 - Kstart[2]), min(n, n - Kend[2])

	# Now apply the filter explicitly
	res = zero(Ml)
	Threads.@threads for indM in CartesianIndices(M)
		i, j = indM[1], indM[2]
		if i < lowi || i > upi || j < lowj || j > upj
			@inbounds res[i, j] = M[i ,j]
			continue
		end
		for inds in CartesianIndices(K)
			k, w = inds[1], inds[2]
			@inbounds res[i, j] += K[k, w]*Ml[i + k, j + w]
		end
	end
	return res
end

# ╔═╡ d6178507-de1b-4e67-9bbc-40cb3854199d
@benchmark myimfilter4(apolohead, blur_kernel)

# ╔═╡ e3d9f172-522b-4a2e-b067-aa6450b7d6e9
md"""
Bingo! Ficou ainda mais rápido do que a versão da biblioteca! Vamos ver se elas geram o mesmo resultado.
"""

# ╔═╡ 4ffa5bec-8555-46c7-89c9-2e07a5b0c04d
res1, res2 = imfilter(apolo, blur_kernel), myimfilter4(apolo, blur_kernel);

# ╔═╡ 312b3d4b-9a50-44f7-8e8f-3ef9dd5c9ac0
norm(res1 - res2)/norm(res1)

# ╔═╡ bbe8f277-43ac-4333-abad-8dc9a28e43f0
norm(res1[2:end-1, 2:end-1] - res2[2:end-1, 2:end-1])/norm(res1)

# ╔═╡ e6cf9542-c3b8-46d4-ace9-e00e21070c2f
md"Vemos que as duas rotinas calculam os mesmos valores nas porções em que o filtro podia ser aplicado sem problemas. Mas há diferenças nas bordas. Será que a biblioteca usa a mesma estratégia que a nossa segunda rotina, repetindo os valores mais próximos fora da borda?"

# ╔═╡ 66e4c242-7c9b-46fd-a36a-d6815c38296f
res3 = myimfilter(apolo, blur_kernel, applyfilter2);

# ╔═╡ 9639eb79-3ebe-41ab-8512-c3bc9e37122c
norm(res1 - res3) / norm(res1)

# ╔═╡ 8baebaf5-4216-4d7d-a964-e4ade787fee8
md"Sim, parece que é isso mesmo. Mas a biblioteca é mais rápida. Talvez porque ela aloque um pouco mais de memória e aplique o filtro sem precisar verificar os limites. Ou seja, use a primeira opção discutida no topo desse caderno que nem chegamos a discutir. Vamos fazer uma implementação dessa abordagem para verificar. Leia a implementação com calma em casa para se convencer que ela está correta."

# ╔═╡ 56330752-59d1-4765-a2c1-f5b73ee13004
function myimfilter5(M, K)
	m, n = size(M)
	
	# Precomputes the bounds that will induce a pure copy from M
	Kstart = 1 .+ K.offsets
	Kend = size(K) .+ K.offsets
	lowi, upi = 1 + Kstart[1], m + Kend[1]
	lowj, upj = 1 + Kstart[2], n + Kend[2]

	# Create a copy of M that has the extra copied boundary
	oneK = one(K[0, 0])
	elemtype = typeof(oneK*M[1, 1])
	preOMl = Matrix{elemtype}(undef, upi - lowi + 1, upj - lowj + 1)
	OMl = OffsetArray(preOMl, lowi:upi, lowj:upj)
	Threads.@threads for indM in CartesianIndices(OMl)
		i, j = indM[1], indM[2]
		il, jl = clamp(i, 1, m), clamp(j, 1, n)
		@inbounds OMl[indM] = oneK*M[il, jl]
	end

	# Now apply the filter explicitly
	res = Matrix{elemtype}(undef, m, n)
	Threads.@threads for indM in CartesianIndices(res)
		i, j = indM[1], indM[2]
		res[indM] = 0 
		for indK in CartesianIndices(K)
			k, w = indK[1], indK[2]
			@inbounds res[indM] += K[indK]*OMl[i + k, j + w]
		end
	end
	return res
end

# ╔═╡ 62ad7d41-5928-48ec-a4bb-27cf176d263a
@benchmark myimfilter5(apolo, blur_kernel)

# ╔═╡ e939e881-ac7a-4cbc-a308-f97cdbbcdb40
res4 = myimfilter5(apolo, blur_kernel);

# ╔═╡ 4e72aeb3-86ae-4f3c-9481-3e59c96ae010
norm(res4 - res1) / norm(res1)

# ╔═╡ c57da07e-d874-41cd-8910-ec8336db754e
md"Ufa, tudo muito próximo do `imfilter` original!"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
ColorVectorSpace = "c3611d14-8923-5661-9e6a-0046d554d3a4"
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
Folds = "41a02a25-b8f0-4f67-bc48-60067656b558"
ImageFiltering = "6a3955dd-da59-5b1f-98d4-e7296123deb5"
ImageIO = "82e4d734-157c-48bb-816b-45c225c6df19"
ImageMagick = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
ImageShow = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
OffsetArrays = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
PNGFiles = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
PlotlyBase = "a03496cd-edff-5a9b-9e67-9cda94a718b5"
PlotlyKaleido = "f2990250-8cf9-495f-b13a-cce12b45703c"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[compat]
BenchmarkTools = "~1.5.0"
ColorVectorSpace = "~0.10.0"
Colors = "~0.12.10"
FileIO = "~1.16.3"
Folds = "~0.2.10"
ImageFiltering = "~0.7.8"
ImageIO = "~0.6.7"
ImageMagick = "~1.3.1"
ImageShow = "~0.3.8"
OffsetArrays = "~1.13.0"
PNGFiles = "~0.4.3"
PlotlyBase = "~0.8.19"
PlotlyKaleido = "~2.2.4"
Plots = "~1.40.2"
PlutoUI = "~0.7.58"
Unitful = "~1.19.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.3"
manifest_format = "2.0"
project_hash = "d220844ab9505a5d68343a5f21a4163126b8b65f"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "d92ad398961a3ed262d8bf04a1a2b8340f915fef"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.5.0"

    [deps.AbstractFFTs.extensions]
    AbstractFFTsChainRulesCoreExt = "ChainRulesCore"
    AbstractFFTsTestExt = "Test"

    [deps.AbstractFFTs.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.Accessors]]
deps = ["CompositionsBase", "ConstructionBase", "Dates", "InverseFunctions", "MacroTools"]
git-tree-sha1 = "3b86719127f50670efe356bc11073d84b4ed7a5d"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.42"

    [deps.Accessors.extensions]
    AxisKeysExt = "AxisKeys"
    IntervalSetsExt = "IntervalSets"
    LinearAlgebraExt = "LinearAlgebra"
    StaticArraysExt = "StaticArrays"
    StructArraysExt = "StructArrays"
    TestExt = "Test"
    UnitfulExt = "Unitful"

    [deps.Accessors.weakdeps]
    AxisKeys = "94b1ba4f-4ee9-5380-92f1-94cde586c3c5"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "cd8b948862abee8f3d3e9b73a102a9ca924debb0"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.2.0"
weakdeps = ["SparseArrays", "StaticArrays"]

    [deps.Adapt.extensions]
    AdaptSparseArraysExt = "SparseArrays"
    AdaptStaticArraysExt = "StaticArrays"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgCheck]]
git-tree-sha1 = "680b3b8759bd4c54052ada14e52355ab69e07876"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.4.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.ArrayInterface]]
deps = ["Adapt", "LinearAlgebra"]
git-tree-sha1 = "017fcb757f8e921fb44ee063a7aafe5f89b86dd1"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.18.0"

    [deps.ArrayInterface.extensions]
    ArrayInterfaceBandedMatricesExt = "BandedMatrices"
    ArrayInterfaceBlockBandedMatricesExt = "BlockBandedMatrices"
    ArrayInterfaceCUDAExt = "CUDA"
    ArrayInterfaceCUDSSExt = "CUDSS"
    ArrayInterfaceChainRulesCoreExt = "ChainRulesCore"
    ArrayInterfaceChainRulesExt = "ChainRules"
    ArrayInterfaceGPUArraysCoreExt = "GPUArraysCore"
    ArrayInterfaceReverseDiffExt = "ReverseDiff"
    ArrayInterfaceSparseArraysExt = "SparseArrays"
    ArrayInterfaceStaticArraysCoreExt = "StaticArraysCore"
    ArrayInterfaceTrackerExt = "Tracker"

    [deps.ArrayInterface.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    CUDSS = "45b445bb-4962-46a0-9369-b4df9d0f772e"
    ChainRules = "082447d4-558c-5d27-93f4-14fc19e9eca2"
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "16351be62963a67ac4083f748fdb3cca58bfd52f"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.7"

[[deps.BangBang]]
deps = ["Accessors", "ConstructionBase", "InitialValues", "LinearAlgebra"]
git-tree-sha1 = "26f41e1df02c330c4fa1e98d4aa2168fdafc9b1f"
uuid = "198e06fe-97b7-11e9-32a5-e1d131e6ad66"
version = "0.4.4"

    [deps.BangBang.extensions]
    BangBangChainRulesCoreExt = "ChainRulesCore"
    BangBangDataFramesExt = "DataFrames"
    BangBangStaticArraysExt = "StaticArrays"
    BangBangStructArraysExt = "StructArrays"
    BangBangTablesExt = "Tables"
    BangBangTypedTablesExt = "TypedTables"

    [deps.BangBang.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    Tables = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
    TypedTables = "9d95f2ec-7b3d-5a63-8d20-e2491e220bb9"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.Baselet]]
git-tree-sha1 = "aebf55e6d7795e02ca500a689d326ac979aaf89e"
uuid = "9718e550-a3fa-408a-8086-8db961cd8217"
version = "0.1.1"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "f1dff6729bc61f4d49e140da1af55dcd1ac97b2f"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.5.0"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1b96ea4a01afe0ea4090c5c8039690672dd13f2e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.9+0"

[[deps.CEnum]]
git-tree-sha1 = "389ad5c84de1ae7cf0e28e381131c98ea87d54fc"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.5.0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "009060c9a6168704143100f36ab08f06c2af4642"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.2+1"

[[deps.CatIndices]]
deps = ["CustomUnitRanges", "OffsetArrays"]
git-tree-sha1 = "a0f80a09780eed9b1d106a1bf62041c2efc995bc"
uuid = "aafaddc9-749c-510e-ac4f-586e18779b91"
version = "0.2.2"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "962834c22b66e32aa10f7611c08c8ca4e20749a9"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.8"

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

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

    [deps.ColorVectorSpace.weakdeps]
    SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "362a287c3aa50601b0bc359053d5c2468f0e7ce0"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.11"

[[deps.CommonWorldInvalidations]]
git-tree-sha1 = "ae52d1c52048455e85a387fbee9be553ec2b68d0"
uuid = "f70d9fcc-98c5-4d4a-abd7-e4cdeebd8ca8"
version = "1.0.0"

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

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"
weakdeps = ["InverseFunctions"]

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

[[deps.ComputationalResources]]
git-tree-sha1 = "52cb3ec90e8a8bea0e62e275ba577ad0f74821f7"
uuid = "ed09eef8-17a6-5b46-8889-db040fac31e3"
version = "0.3.2"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "d9d26935a0bcffc87d2613ce14c527c99fc543fd"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.5.0"

[[deps.ConstructionBase]]
git-tree-sha1 = "76219f1ed5771adbb096743bff43fb5fdd4c1157"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.8"
weakdeps = ["IntervalSets", "LinearAlgebra", "StaticArrays"]

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseLinearAlgebraExt = "LinearAlgebra"
    ConstructionBaseStaticArraysExt = "StaticArrays"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.CustomUnitRanges]]
git-tree-sha1 = "1a3f97f907e6dd8983b744d2642651bb162a3f7a"
uuid = "dc8bdbbb-1ca9-579f-8c36-e416f6a65cce"
version = "1.0.2"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "fc173b380865f70627d7dd1190dc2fce6cc105af"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.14.10+0"

[[deps.DefineSingletons]]
git-tree-sha1 = "0fba8b706d0178b4dc7fd44a96a92382c9065c2c"
uuid = "244e2a9f-e319-4986-a169-4d1fe445cd52"
version = "0.1.2"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"
version = "1.11.0"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a4be429317c42cfae6a7fc03c31bad1970c310d"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+1"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "d36f682e590a83d63d1c7dbd287573764682d12a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.11"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d55dffd9ae73ff72f1c0482454dcf2ec6c6c4a63"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.6.5+0"

[[deps.ExternalDocstrings]]
git-tree-sha1 = "1224740fc4d07c989949e1c1b508ebd49a65a5f6"
uuid = "e189563c-0753-4f5e-ad5c-be4293c83fb4"
version = "0.1.1"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "53ebe7511fa11d33bec688a9178fac4e49eeee00"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.2"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FFTViews]]
deps = ["CustomUnitRanges", "FFTW"]
git-tree-sha1 = "cbdf14d1e8c7c8aacbe8b19862e0179fd08321c2"
uuid = "4f61f5a4-77b1-5117-aa51-3ab5ef4ef0cd"
version = "0.3.2"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "7de7c78d681078f027389e067864a8d53bd7c3c9"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.8.1"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4d81ed14783ec49ce9f2e168208a12ce1815aa25"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+3"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "2dd20384bf8c6d411b5c7370865b1e9b26cb2ea3"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.6"
weakdeps = ["HTTP"]

    [deps.FileIO.extensions]
    HTTPExt = "HTTP"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Folds]]
deps = ["Accessors", "BangBang", "Baselet", "DefineSingletons", "Distributed", "ExternalDocstrings", "InitialValues", "MicroCollections", "Referenceables", "Requires", "Test", "ThreadedScans", "Transducers"]
git-tree-sha1 = "7eb4bc88d8295e387a667fd43d67c157ddee76cf"
uuid = "41a02a25-b8f0-4f67-bc48-60067656b558"
version = "0.2.10"

    [deps.Folds.extensions]
    FoldsOnlineStatsBaseExt = "OnlineStatsBase"

    [deps.Folds.weakdeps]
    OnlineStatsBase = "925886fa-5bf2-5e8e-b522-a9147a512338"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "21fac3c77d7b5a9fc03b0ec503aa1a6392c34d2b"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.15.0+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "786e968a8d2fb167f2e4880baba62e0e26bd8e4e"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.3+1"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "846f7026a9decf3679419122b49f8a1fdb48d2d5"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.16+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "fcb0584ff34e25155876418979d4c8971243bb89"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.4.0+2"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "8e2d86e06ceb4580110d9e716be26658effc5bfd"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.72.8"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "da121cbdc95b065da07fbb93638367737969693f"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.72.8+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "43ba3d3c82c18d88471cfd2924931658838c9d8f"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.0+4"

[[deps.Giflib_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6570366d757b50fabae9f4315ad74d2e40c0560a"
uuid = "59f7168a-df46-5410-90c8-f2779963d0ec"
version = "5.2.3+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "b0036b392358c80d2d2124746c2bf3d48d457938"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.82.4+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "01979f9b37367603e2848ea225918a3b3861b606"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+1"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "PrecompileTools", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "c67b33b085f6e2faf8bf79a61962e7339a81129c"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.15"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "55c53be97790242c29031e5cd45e8ac296dadda3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.5.0+0"

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

[[deps.IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

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

[[deps.ImageFiltering]]
deps = ["CatIndices", "ComputationalResources", "DataStructures", "FFTViews", "FFTW", "ImageBase", "ImageCore", "LinearAlgebra", "OffsetArrays", "PrecompileTools", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "TiledIteration"]
git-tree-sha1 = "33cb509839cc4011beb45bde2316e64344b0f92b"
uuid = "6a3955dd-da59-5b1f-98d4-e7296123deb5"
version = "0.7.9"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs", "WebP"]
git-tree-sha1 = "696144904b76e1ca433b886b4e7edd067d76cbf7"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.9"

[[deps.ImageMagick]]
deps = ["FileIO", "ImageCore", "ImageMagick_jll", "InteractiveUtils"]
git-tree-sha1 = "8e2eae13d144d545ef829324f1f0a5a4fe4340f3"
uuid = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
version = "1.3.1"

[[deps.ImageMagick_jll]]
deps = ["Artifacts", "Ghostscript_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "OpenJpeg_jll", "Pkg", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "8d2e786fd090199a91ecbf4a66d03aedd0fb24d4"
uuid = "c73af94c-d91f-53ed-93a7-00f77d67a9d7"
version = "6.9.11+4"

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

[[deps.InitialValues]]
git-tree-sha1 = "4da0f88e9a39111c2fa3add390ab15f3a44f3ca3"
uuid = "22cec73e-a1b8-11e9-2c92-598750a2cf9c"
version = "0.3.1"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl"]
git-tree-sha1 = "0f14a5456bdc6b9731a5682f439a672750a09e48"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2025.0.4+0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.IntervalSets]]
git-tree-sha1 = "dba9ddf07f77f60450fe5d2e2beb9854d9a49bd0"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.10"
weakdeps = ["Random", "RecipesBase", "Statistics"]

    [deps.IntervalSets.extensions]
    IntervalSetsRandomExt = "Random"
    IntervalSetsRecipesBaseExt = "RecipesBase"
    IntervalSetsStatisticsExt = "Statistics"

[[deps.InverseFunctions]]
git-tree-sha1 = "a779299d77cd080bf77b97535acecd73e1c5e5cb"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.17"
weakdeps = ["Dates", "Test"]

    [deps.InverseFunctions.extensions]
    InverseFunctionsDatesExt = "Dates"
    InverseFunctionsTestExt = "Test"

[[deps.IrrationalConstants]]
git-tree-sha1 = "e2222959fbc6c19554dc15174c81bf7bf3aa691c"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.4"

[[deps.IterTools]]
git-tree-sha1 = "42d5f897009e7ff2cf88db414a389e5ed1bdd023"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.10.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "71b48d857e86bf7a1838c4736545699974ce79a2"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.9"

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

[[deps.Kaleido_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "43032da5832754f58d14a91ffbe86d5f176acda9"
uuid = "f7e6163d-2fa5-5f23-b69c-1db539e41963"
version = "0.2.1+0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "170b660facf5df5de098d866564877e119141cbd"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.2+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "78211fb6cbc872f77cad3fc0b6cf647d923f4929"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.7+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1c602b1127f4751facb671441ca72715cc95938a"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.3+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.Latexify]]
deps = ["Format", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "cd714447457c660382fe634710fb56eb255ee42e"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.6"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"
version = "1.11.0"

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
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "27ecae93dd25ee0909666e6835051dd684cc035e"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+2"

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

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "89211ea35d9df5831fca5d33552c02bd33878419"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.40.3+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e888ad02ce716b319e6bdb985d2ef300e7089889"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.40.3+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.LittleCMS_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg"]
git-tree-sha1 = "110897e7db2d6836be22c18bffd9422218ee6284"
uuid = "d3a379c0-f9a3-5b72-a4c0-6bf4d2e8af0f"
version = "2.12.0+0"

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
version = "1.11.0"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "f02b56007b064fbfddb4c9cd60161b6dd0f40df3"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.1.0"

[[deps.MIMEs]]
git-tree-sha1 = "1833212fd6f580c20d4291da9c1b4e8a655b128e"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.0.0"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "oneTBB_jll"]
git-tree-sha1 = "5de60bc6cb3899cd318d80d627560fae2e2d99ae"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2025.0.1+1"

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
version = "1.11.0"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.MicroCollections]]
deps = ["Accessors", "BangBang", "InitialValues"]
git-tree-sha1 = "44d32db644e84c75dab479f1bc15ee76a1a3618f"
uuid = "128add7d-3638-4c79-886c-908ea0c25c34"
version = "0.2.0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "7b86a5d4d70a9f5cdf2dacb3cbe6d251d1a61dbe"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.4"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

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
git-tree-sha1 = "6a731f2b5c03157418a20c12195eb4b74c8f8621"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.13.0"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

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

[[deps.OpenJpeg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libtiff_jll", "LittleCMS_jll", "Pkg", "libpng_jll"]
git-tree-sha1 = "76374b6e7f632c130e78100b166e5a48464256f8"
uuid = "643b3616-a352-519d-856d-80112ee9badc"
version = "2.4.0+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "38cb508d080d21dc1128f7fb04f20387ed4c0af4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "ad31332567b189f508a3ea8957a2640b1147ab00"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.23+1"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6703a85cb3781bd5909d48730a67205f3f31a575"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.3+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "cc4054e898b852042d7b503313f7ad03de99c3dd"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.0"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

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

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "3b31172c032a1def20c98dae3f2cdc9d10e3b561"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.56.1+0"

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

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "35621f10a7531bc8fa58f74610b1bfb70a3cfc6b"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.43.4+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f9501cc0430a26bc3d156ae1b5b0c1b47af4d6da"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.3"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "41031ef3a1be6f5bbbf3e8073f210556daeae5ca"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.3.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "StableRNGs", "Statistics"]
git-tree-sha1 = "3ca9a356cd2e113c420f2c13bea19f8d3fb1cb18"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.3"

[[deps.PlotlyBase]]
deps = ["ColorSchemes", "Colors", "Dates", "DelimitedFiles", "DocStringExtensions", "JSON", "LaTeXStrings", "Logging", "Parameters", "Pkg", "REPL", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "90af5c9238c1b3b25421f1fdfffd1e8fca7a7133"
uuid = "a03496cd-edff-5a9b-9e67-9cda94a718b5"
version = "0.8.20"

    [deps.PlotlyBase.extensions]
    DataFramesExt = "DataFrames"
    DistributionsExt = "Distributions"
    IJuliaExt = "IJulia"
    JSON3Ext = "JSON3"

    [deps.PlotlyBase.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    JSON3 = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"

[[deps.PlotlyKaleido]]
deps = ["Artifacts", "Base64", "JSON", "Kaleido_jll"]
git-tree-sha1 = "ba551e47d7eac212864fdfea3bd07f30202b4a5b"
uuid = "f2990250-8cf9-495f-b13a-cce12b45703c"
version = "2.2.6"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "TOML", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "f202a1ca4f6e165238d8175df63a7e26a51e04dc"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.40.7"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

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
version = "1.11.0"

[[deps.Profile]]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"
version = "1.11.0"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "8f6bc219586aef8baf0ff9a5fe16ee9c70cb65e4"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.10.2"

[[deps.PtrArrays]]
git-tree-sha1 = "1d36ef11a9aaf1e8b74dacc6a731dd1de8fd493d"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.3.0"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "8b3fc30bc0390abdce15f8822c889f669baed73d"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.1"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Referenceables]]
deps = ["Adapt"]
git-tree-sha1 = "02d31ad62838181c1a3a5fd23a1ce5914a643601"
uuid = "42d2dcc6-99eb-4e98-b66c-637b7d73030e"
version = "0.1.3"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMD]]
deps = ["PrecompileTools"]
git-tree-sha1 = "fea870727142270bdf7624ad675901a1ee3b4c87"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.7.1"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "c5391c6ace3bc430ca630251d02ea9687169ca68"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.2"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

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
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.11.0"

[[deps.SplittablesBase]]
deps = ["Setfield", "Test"]
git-tree-sha1 = "e08a62abc517eb79667d0a29dc08a3b589516bb5"
uuid = "171d559e-b47b-412a-8079-5efa626c420e"
version = "0.1.15"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "83e6cce8324d49dfaf9ef059227f91ed4441a8e5"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.2"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.Static]]
deps = ["CommonWorldInvalidations", "IfElse", "PrecompileTools"]
git-tree-sha1 = "f737d444cb0ad07e61b3c1bef8eb91203c321eff"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "1.2.0"

[[deps.StaticArrayInterface]]
deps = ["ArrayInterface", "Compat", "IfElse", "LinearAlgebra", "PrecompileTools", "Static"]
git-tree-sha1 = "96381d50f1ce85f2663584c8e886a6ca97e60554"
uuid = "0d7ed370-da01-4f52-bd93-41d350b8b718"
version = "1.8.0"
weakdeps = ["OffsetArrays", "StaticArrays"]

    [deps.StaticArrayInterface.extensions]
    StaticArrayInterfaceOffsetArraysExt = "OffsetArrays"
    StaticArrayInterfaceStaticArraysExt = "StaticArrays"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "0feb6b9031bd5c51f9072393eb5ab3efd31bf9e4"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.13"

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

    [deps.StaticArrays.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StaticArraysCore]]
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "29321314c920c26684834965ec2ce0dacc9cf8e5"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.4"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.7.0+0"

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
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "598cd7c1f68d1e205689b1c2fe65a9f85846f297"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.0"

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
version = "1.11.0"

[[deps.ThreadedScans]]
deps = ["ArgCheck"]
git-tree-sha1 = "ca1ba3000289eacba571aaa4efcefb642e7a1de6"
uuid = "24d252fe-5d94-4a69-83ea-56a14333d47a"
version = "0.1.0"

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "SIMD", "UUIDs"]
git-tree-sha1 = "f21231b166166bebc73b99cea236071eb047525b"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.11.3"

[[deps.TiledIteration]]
deps = ["OffsetArrays", "StaticArrayInterface"]
git-tree-sha1 = "1176cc31e867217b06928e2f140c90bd1bc88283"
uuid = "06e1c1a7-607b-532d-9fad-de7d9aa2abac"
version = "0.5.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Transducers]]
deps = ["Accessors", "ArgCheck", "BangBang", "Baselet", "CompositionsBase", "ConstructionBase", "DefineSingletons", "Distributed", "InitialValues", "Logging", "Markdown", "MicroCollections", "Requires", "SplittablesBase", "Tables"]
git-tree-sha1 = "7deeab4ff96b85c5f72c824cae53a1398da3d1cb"
uuid = "28d57a85-8fef-5791-bfe6-a80928e7c999"
version = "0.4.84"

    [deps.Transducers.extensions]
    TransducersAdaptExt = "Adapt"
    TransducersBlockArraysExt = "BlockArrays"
    TransducersDataFramesExt = "DataFrames"
    TransducersLazyArraysExt = "LazyArrays"
    TransducersOnlineStatsBaseExt = "OnlineStatsBase"
    TransducersReferenceablesExt = "Referenceables"

    [deps.Transducers.weakdeps]
    Adapt = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
    BlockArrays = "8e7c35d0-a365-5155-bbbb-fb81a777f24e"
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    LazyArrays = "5078a376-72f3-5289-bfd5-ec5146d43c02"
    OnlineStatsBase = "925886fa-5bf2-5e8e-b522-a9147a512338"
    Referenceables = "42d2dcc6-99eb-4e98-b66c-637b7d73030e"

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
version = "1.11.0"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "352edac1ad17e018186881b051960bfca78a075a"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.19.1"
weakdeps = ["ConstructionBase", "InverseFunctions"]

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "975c354fcd5f7e1ddcc1f1a23e6e091d99e99bc8"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.4"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "85c7811eddec9e7f22615371c3cc81a504c508ee"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+2"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "5db3e9d307d32baba7067b13fc7b5aa6edd4a19a"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.36.0+0"

[[deps.WebP]]
deps = ["CEnum", "ColorTypes", "FileIO", "FixedPointNumbers", "ImageCore", "libwebp_jll"]
git-tree-sha1 = "aa1ca3c47f119fbdae8770c29820e5e6119b83f2"
uuid = "e3aaa7dc-3e4b-44e0-be63-ffb868ccd7c1"
version = "0.1.3"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "b8b243e47228b4a3877f1dd6aee0c5d56db7fcf4"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.6+1"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "7d1671acbe47ac88e981868a078bd6b4e27c5191"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.42+0"

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

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "807c226eaf3651e7b2c468f687ac788291f9a89b"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.3+0"

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

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "6fcc21d5aea1a0b7cce6cab3e62246abd1949b86"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.0+0"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "984b313b049c89739075b8e2a94407076de17449"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.8.2+0"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll"]
git-tree-sha1 = "a1a7eaf6c3b5b05cb903e35e8372049b107ac729"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.5+0"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "b6f664b7b2f6a39689d822a6300b14df4668f0f4"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.4+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "a490c6212a0e90d2d55111ac956f7c4fa9c277a6"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.11+1"

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

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "dbc53e4cf7701c6c7047c51e17d6e64df55dca94"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.2+1"

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
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "ab2221d309eda71020cdda67a973aa582aa85d69"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.6+1"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "691634e5453ad362044e2ad653e79f3ee3bb98c3"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.39.0+0"

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
git-tree-sha1 = "446b23e73536f84e8037f5dce465e92275f6a308"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6e50f145003024df4f5cb96c7fce79466741d601"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.56.3+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "522c1df09d05a71785765d19c9524661234738e9"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.11.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e17c115d55c5fbb7e52ebedb427a0dca79d4484e"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.2+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.libdecor_jll]]
deps = ["Artifacts", "Dbus_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pango_jll", "Wayland_jll", "xkbcommon_jll"]
git-tree-sha1 = "9bf7903af251d2050b467f76bdbe57ce541f7f4f"
uuid = "1183f4f0-6f2a-5f1a-908b-139f9cdfea6f"
version = "0.2.2+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a22cf860a7d27e4f3498a0fe0811a7957badb38"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.3+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "068dfe202b0a05b8332f1e8e6b4080684b9c7700"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.47+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "libpng_jll"]
git-tree-sha1 = "c1733e347283df07689d71d61e14be986e49e47a"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.5+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "490376214c4721cdaca654041f635213c6165cb3"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+2"

[[deps.libwebp_jll]]
deps = ["Artifacts", "Giflib_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libglvnd_jll", "Libtiff_jll", "libpng_jll"]
git-tree-sha1 = "ccbb625a89ec6195856a50aa2b668a5c08712c94"
uuid = "c5f90fcd-3b7e-5836-afba-fc50a0988cb2"
version = "1.4.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.oneTBB_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d5a767a3bb77135a99e433afe0eb14cd7f6914c3"
uuid = "1317d2d5-d96f-522e-a858-c73665f53c3e"
version = "2022.0.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

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
git-tree-sha1 = "63406453ed9b33a0df95d570816d5366c92b7809"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+2"
"""

# ╔═╡ Cell order:
# ╟─f5c464b6-663a-4c4d-9e93-30e469d3a496
# ╟─8d389d80-74a1-11eb-3452-f38eff03483b
# ╟─9f1a72da-7532-11eb-079c-b7baccc6614a
# ╠═86f770fe-74a1-11eb-01f7-5b3ecf057124
# ╟─b310756a-af08-48b0-ae10-ee2e8dd0c968
# ╟─4d332c7e-74f8-11eb-1f49-a518246d1db8
# ╟─f7689472-74a8-11eb-32a1-8379ae5c88e1
# ╟─0f2f9004-74a8-11eb-01a2-973dbe80f166
# ╠═962143a8-74a7-11eb-26c3-c10548f326ee
# ╠═c2964c80-74f8-11eb-3a74-b1bdd9e4ae02
# ╠═caf488d8-74f8-11eb-0075-0586d66c23c1
# ╠═02dd4a02-74f9-11eb-3d1e-53d83cee8062
# ╠═10ef13d2-74f9-11eb-2849-fb9f83db6ae9
# ╠═b76a56f4-74a9-11eb-1739-fbfc5e4958e8
# ╠═77fbf18a-74f9-11eb-1d9e-3f9d2097388f
# ╠═bcb69db6-74f9-11eb-100a-29d1d23963ab
# ╟─fc70c4d2-74f8-11eb-33f5-539c278ed6b6
# ╠═c9ce62a6-f368-49f9-b473-fa88224e07e3
# ╟─e1131709-136e-494d-9a37-be7225c87bf4
# ╠═6aae9a23-c7cc-4b1a-8ea8-4ed853f74067
# ╟─0e81fe50-8264-4c1a-a9c4-a02c97281aae
# ╟─2f7cde78-74a2-11eb-1e2f-81b5b2465819
# ╟─e099815e-74a1-11eb-1541-033f6abe9f8e
# ╟─e82a4dd8-74b0-11eb-1108-6b09e67a80c1
# ╟─39552b7a-74fb-11eb-04e0-3981ada52c92
# ╠═14f2b85e-74ad-11eb-2682-d9de646aedf3
# ╠═516e73e2-74fb-11eb-213e-9dbd9472e0db
# ╠═b5d0ef90-74fb-11eb-3126-792f954c7be7
# ╠═754c3704-74fb-11eb-1199-2b9798d7251f
# ╠═9eb917ba-74fb-11eb-0527-15e981ce9c6a
# ╟─486d3022-74ff-11eb-1865-e15436bd9aad
# ╟─b9da7332-74ff-11eb-241b-fb87e77d646a
# ╟─339ccfca-74b1-11eb-0c35-774da6b189ed
# ╟─8711c698-7500-11eb-2505-d35a4de169b4
# ╟─84350cb8-7501-11eb-095e-8f1a7e015f25
# ╟─91a1bca4-74aa-11eb-3917-1dfd73d0ad9c
# ╠═8e698bdc-7501-11eb-1d2e-c336ccbde0b0
# ╠═ab2bc924-7501-11eb-03ba-8dfc1ffe3f36
# ╟─e11d6300-7501-11eb-239a-135596309d20
# ╠═39c73cc7-2ca8-4e4e-8651-ec0b87f37e94
# ╠═e0988dbd-93ba-4428-8b47-fc5745fa85a8
# ╠═6cb2a804-bd0c-4375-9dd6-4b74e2490380
# ╟─47d40406-7502-11eb-2f43-cd5c848f25a6
# ╠═9ce0b980-74aa-11eb-0678-01209451fb65
# ╟─68821bf4-7502-11eb-0d3c-03d7a00fdba4
# ╠═447e7c9e-74b1-11eb-27ea-71aa4338b11a
# ╟─c9dff6f4-7503-11eb-2715-0bf9d3ece9e1
# ╟─d834103c-7503-11eb-1a94-1fbad43801ff
# ╠═aa541288-74aa-11eb-1edc-ab6d7786f271
# ╠═c9dcac48-74aa-11eb-31a6-23357180c1c8
# ╟─30b1c1f0-7504-11eb-1be7-a9463caea809
# ╟─1fe70e38-751b-11eb-25b8-c741e1726613
# ╟─215291ec-74a2-11eb-3476-0dab43fd5a5e
# ╟─61db42c6-7505-11eb-1ddf-05e906234572
# ╟─cdd4cffc-74b1-11eb-1aa4-e333cb8601d1
# ╟─7489a570-74a3-11eb-1d0b-09d41604ffe1
# ╟─8a8e3f5e-74b2-11eb-3eed-e5468e573e45
# ╟─5864294a-74a5-11eb-23ef-f38a582f2c2d
# ╟─fa9c465e-74b2-11eb-2f3c-4be0e7f93bb5
# ╟─4fab4616-74b0-11eb-0088-6b50237d7d54
# ╠═54448d18-7528-11eb-209a-9717affa0d02
# ╟─acbc563a-7528-11eb-3c38-75a5b66c9241
# ╠═995392ee-752a-11eb-3394-0de331e24f40
# ╟─d22903d6-7529-11eb-2dcd-132cd27104c2
# ╟─275bf7ac-74b3-11eb-32c3-cda1e4f1f8c2
# ╟─c6e340ee-751e-11eb-3ca7-69595b3693b7
# ╟─844ed844-74b3-11eb-2ee1-2de664b26bc6
# ╟─4ffe927c-74b4-11eb-23a7-a18d7e51c75b
# ╟─91109e5c-74b3-11eb-1f31-c50e436bc6e0
# ╠═34109062-7525-11eb-10b3-d59d3a6dfda6
# ╟─9ab89a3a-7525-11eb-186d-29e4b61deb7f
# ╠═50034058-7525-11eb-345b-3334e71ac50e
# ╟─c0aec7ae-7505-11eb-2822-a151aad48fc9
# ╠═99eeb11c-7524-11eb-2154-df7d84976445
# ╠═2ddcfb90-7520-11eb-2df7-172d07118b7e
# ╠═d62496b0-7524-11eb-3410-7177e7c7f8eb
# ╠═6aa8a76e-7524-11eb-22b5-015aab4191b0
# ╟─ee93eeb2-7524-11eb-342d-0343d8aebf59
# ╟─662d73b6-74b3-11eb-333d-f1323a001000
# ╠═d127303a-7521-11eb-3507-7341a416211f
# ╠═d4581b56-7522-11eb-2c15-991c0c790e67
# ╠═40c15c3a-7523-11eb-1f2a-bd90b127dad2
# ╠═08642690-7523-11eb-00dd-63d4cf6513dc
# ╠═deac4cf2-7523-11eb-2832-7b9d31389b08
# ╠═32887dfa-7524-11eb-35cd-051eff594fa9
# ╠═0f765670-7506-11eb-2a37-931b15bb387f
# ╟─82737d28-7507-11eb-1e39-c7dc12e18882
# ╟─40d538b2-7506-11eb-116b-efeb16b3478d
# ╟─df060a88-7507-11eb-034b-5346d67a0e0d
# ╟─60c8db60-7506-11eb-1468-c989809c933a
# ╟─8ed0be60-7506-11eb-2769-5f7da1c66243
# ╟─b9d636da-7506-11eb-37a6-3116d47b2787
# ╟─0fd8810a-3c1b-461b-a809-8ffb3bfcbb45
# ╟─33a998e8-3a53-44e5-a353-1ccf3bd2d41f
# ╠═5a1a4ca4-4223-4fe3-99ae-86453295dc52
# ╠═bde5ca1c-44d6-446b-857e-bc39cacaea33
# ╠═3bb1c9b2-5ca5-46a4-8fcc-c11c5bd79139
# ╟─edf08ce0-f47e-44d0-92c3-216bf187ad09
# ╠═54097a87-1233-4524-a263-4e7dfe0c6897
# ╠═5a1c12be-bc67-4df2-9e69-35e0543d29d8
# ╠═121d4880-c68c-44f1-a890-123928dd855b
# ╟─2f5afff8-0ead-4840-a42d-5c39a2907b29
# ╠═592dab5b-efa2-44b7-a23b-cc5270a4870a
# ╟─7020309a-5eb0-4210-a990-4ec71583d3c9
# ╠═0d91923c-13d7-4fd1-b8da-fa549964024f
# ╠═f5d57a7c-dabb-4672-8605-69661e9f434d
# ╠═d56b81af-803b-4306-a24c-17c6c8afe63a
# ╠═0820f98f-ed3c-460e-822b-7ea5f375ac53
# ╟─2a41464f-b666-4ba1-8cc7-fb975b6c62b8
# ╠═74526d38-c8f7-4459-a625-882e1cb134b4
# ╠═10e20805-126c-428c-a7a2-d45146140b5b
# ╠═6b360a92-e0dd-4cdd-bd39-2cc8b3300b99
# ╠═aac35f1e-88ef-4030-91d8-d6917b766c68
# ╟─30880ced-75ea-4e20-acac-d00a0c081f4b
# ╠═1292aa60-c355-4442-a81f-b26039ee1126
# ╠═3fb66414-5c29-4e44-96be-db066bc6a763
# ╠═afa47a7b-4c45-4f87-a1cc-ffc92b8f6b69
# ╟─19797ee3-08ef-4700-8799-259620a4b154
# ╠═059b559a-e4db-4879-a9c5-14790918618b
# ╠═0cd1a998-521e-4e52-ac08-45bc99640500
# ╠═12f78a86-6abe-4e28-a6f8-6245f17b334a
# ╟─3dfa0f35-a3b8-4964-a7ee-1cdf2c40ce68
# ╠═c06b29a7-eeb3-4a85-8efe-c9f43eae7849
# ╟─eded09fc-b838-43e2-9b6b-980d80af48b1
# ╠═e6fa4f26-6baa-48bd-a733-e9cc6847ef49
# ╠═56ed0197-e311-4ccc-ac4f-634ca6810553
# ╠═9d39577f-8300-4d71-8f24-6ff4cc798a3b
# ╟─f98f7de4-f509-48c5-a9eb-ebe9eb3b75ff
# ╠═b555626b-822c-4695-a0c8-3c3a8eb94dda
# ╠═7eed1a6a-3d65-4d7a-b6d1-e0e144d75709
# ╟─4227f552-aba3-4eba-b725-d1e7dc85a8af
# ╠═66a856c8-ea1d-4c35-8d37-2c548df3696c
# ╠═d6178507-de1b-4e67-9bbc-40cb3854199d
# ╟─e3d9f172-522b-4a2e-b067-aa6450b7d6e9
# ╠═4ffa5bec-8555-46c7-89c9-2e07a5b0c04d
# ╠═312b3d4b-9a50-44f7-8e8f-3ef9dd5c9ac0
# ╠═bbe8f277-43ac-4333-abad-8dc9a28e43f0
# ╟─e6cf9542-c3b8-46d4-ace9-e00e21070c2f
# ╠═66e4c242-7c9b-46fd-a36a-d6815c38296f
# ╠═9639eb79-3ebe-41ab-8512-c3bc9e37122c
# ╟─8baebaf5-4216-4d7d-a964-e4ade787fee8
# ╠═56330752-59d1-4765-a2c1-f5b73ee13004
# ╠═62ad7d41-5928-48ec-a4bb-27cf176d263a
# ╠═e939e881-ac7a-4cbc-a308-f97cdbbcdb40
# ╠═4e72aeb3-86ae-4f3c-9481-3e59c96ae010
# ╟─c57da07e-d874-41cd-8910-ec8336db754e
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
