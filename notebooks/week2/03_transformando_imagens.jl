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

# ╔═╡ 86f770fe-74a1-11eb-01f7-5b3ecf057124
begin
	import Pkg
	Pkg.activate(mktempdir())
	Pkg.add([
		Pkg.PackageSpec(name="ImageIO", version="0.5"),
		Pkg.PackageSpec(name="ImageShow", version="0.2"),
		Pkg.PackageSpec(name="FileIO", version="1.6"),
		Pkg.PackageSpec(name="PNGFiles", version="0.3.6"),
		Pkg.PackageSpec(name="Colors", version="0.12"),
		Pkg.PackageSpec(name="ColorVectorSpace", version="0.8"),
		Pkg.PackageSpec(name="PlutoUI", version="0.7"),
		Pkg.PackageSpec(name="Unitful", version="1.6"),
		Pkg.PackageSpec(name="ImageFiltering", version="0.6"),
		Pkg.PackageSpec(name="OffsetArrays", version="1.6"),
		Pkg.PackageSpec(name="Plots", version="1.10"),
		Pkg.PackageSpec(name="Images")
	])

	using PlutoUI
	using Colors, ColorVectorSpace, ImageShow, FileIO
	using Unitful
	using ImageFiltering
	using OffsetArrays
	using Plots
end

# ╔═╡ b310756a-af08-48b0-ae10-ee2e8dd0c968
filter!(LOAD_PATH) do path
	path != "@v#.#"
end;

# ╔═╡ f5c464b6-663a-4c4d-9e93-30e469d3a496
md"Tradução livre de [`transforming_images.jl`](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week2/transforming_images.jl)"

# ╔═╡ 8d389d80-74a1-11eb-3452-f38eff03483b
PlutoUI.TableOfContents(aside=true)

# ╔═╡ 9f1a72da-7532-11eb-079c-b7baccc6614a
md"""
#### Intializing packages

_Ao executar esse notebook a primeira ele pode levar até 15 min, tenha paciência!_
"""

# ╔═╡ 4d332c7e-74f8-11eb-1f49-a518246d1db8
md"""
# Anúncio: As aulas serão de aproximadamente uma hora
"""

# ╔═╡ f7689472-74a8-11eb-32a1-8379ae5c88e1
rotabook = PlutoUI.Resource("https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1348902666l/1646354.jpg")

# ╔═╡ 0f2f9004-74a8-11eb-01a2-973dbe80f166
md"""
##  **Nunca passe do tempo** (um microséculo com Unitful)

Passa do tempo é um dos piores erros que um palestrante pode fazer. Vamos aqui
seguir a sugestão do von Neumann e tentar limitar nossas aulas a um microséculo.
Depois disso, ele dizia que a atenção da audiência se perdia mesmo se ele
estivesse apresentando uma demonstração de hipótese de Riemann. Um minuto de
estouro já pode arruinar uma ótima apresentação (de "Indiscrete Thoughts" by
Rota, Chpt 18, 10 Lessons I Wish I Had Been Taught).

Tá, mas porque estou falando isso. É só para mostrar mais um pacote de Julia.
Uma boa linguagem deve ter ao seu redor um rico ecosistema que extendam as
capacidades da linguagem para problemas além da biblioteca padrão. Isso é
verdade mesmo para Python (que já vem "com baterias inclusas"). Outra
característa interessante da linguagem é se ela disponibilizar ferramentas para
"estender  sintaxe" criando formas naturais de escrever código que expresse as
novas construções de forma natural.

O pacote `Unitful.jl` é um pacote para dar suporte a unidades de medida
(físicas) permitindo manter unidades associadas a valores de forma eficiente,
análise dimensional, entre outras funcionalidades. Vejamos ele em ação.
"""

# ╔═╡ 962143a8-74a7-11eb-26c3-c10548f326ee
century = 100u"yr" #  A u"yr" é uma string especial que denota a unidade de tempo "um ano"

# ╔═╡ c2964c80-74f8-11eb-3a74-b1bdd9e4ae02
century * 2

# ╔═╡ caf488d8-74f8-11eb-0075-0586d66c23c1
century/200

# ╔═╡ 02dd4a02-74f9-11eb-3d1e-53d83cee8062
century^2

# ╔═╡ 10ef13d2-74f9-11eb-2849-fb9f83db6ae9
g = 9.8u"m"/u"s"^2

# ╔═╡ b76a56f4-74a9-11eb-1739-fbfc5e4958e8

uconvert(u"minute", 1e-6*century) # Ôpa, aqui vemos quanto tempo é o microséculo!

# ╔═╡ 77fbf18a-74f9-11eb-1d9e-3f9d2097388f
PotentialEnergy = (10u"kg") * g * (50u"m")

# ╔═╡ bcb69db6-74f9-11eb-100a-29d1d23963ab
uconvert(u"J", PotentialEnergy)

# ╔═╡ fc70c4d2-74f8-11eb-33f5-539c278ed6b6
md"""
Adicionar a informação de unidades ao números em Julia *funciona naturalmente*
em Julia e isso é feito com cuidado para não penalizar o tempo de execução. Já o
uso de strings especiais definidas pelo usuário, que são marcadas por um código
antes do abre aspas como no caso de Markdown (md), LaTeX (L) e agora unidades de
medida (u), ajudarm a deixar o código legível. Essa é uma das muitas
características que fazem de Julia uma ótima linguagem para programar. Por
exemplo, com as unidades bem definidas, se no final de uma conta que deveria
calcular energia obtemos algo em m/s sabemos que há um erro em algum lugar e
temos até uma dica que qual tipo de erro para procurar. Durante esse curso
veremos outras funcionalidades da linguagem que ajudam a exprimir código
legível, eficiente e enxuto.
"""

# ╔═╡ 2f7cde78-74a2-11eb-1e2f-81b5b2465819
md"""
#### Lembrete

**Você pode trocar as figuras abaixos pelas suas próprias figuras**

Simplesmente troque a URL ou a localização do arquivo.
"""

# ╔═╡ e099815e-74a1-11eb-1541-033f6abe9f8e
md"""
# Transformando imagens
"""

# ╔═╡ e82a4dd8-74b0-11eb-1108-6b09e67a80c1
md"""
## 2.1. Downsampling / Upsampling (sei lá como traduz...)
"""

# ╔═╡ 39552b7a-74fb-11eb-04e0-3981ada52c92
md"""
Como pixelar um cachorro? A figura abaixo está online, mas vamos pixelar um
cachorro real.
"""

# ╔═╡ 14f2b85e-74ad-11eb-2682-d9de646aedf3
pixelated_corgi = load(download("https://i.redd.it/99lhfbnwpgd31.png"))

# ╔═╡ 516e73e2-74fb-11eb-213e-9dbd9472e0db
apolo =  load(download("https://www.ime.unicamp.br/~pjssilva/images/ensino/labcompsci/apolo1.png"))

# ╔═╡ b5d0ef90-74fb-11eb-3126-792f954c7be7
@bind r Slider(1:20, show_value=true, default=20)

# ╔═╡ 754c3704-74fb-11eb-1199-2b9798d7251f
downsample_apolo = apolo[1:r:end, 1:r:end]

# ╔═╡ 9eb917ba-74fb-11eb-0527-15e981ce9c6a
upsample_apolo = kron(downsample_apolo, ones(r, r))

# ╔═╡ 486d3022-74ff-11eb-1865-e15436bd9aad
md"""
  Vejam que para "ampliar" a mensagem usamos o [produto de
  Kronecker](https://en.wikipedia.org/wiki/Kronecker_product), implementado pela
  função `kron` e uma matriz de uns obtida com `ones`.
"""

# ╔═╡ b9da7332-74ff-11eb-241b-fb87e77d646a
md"""
Exercício: Use a ferramenta que usamos para selcionar o nariz do Apolo para
selicionar uma região retangular na imagem para ser pixelada.
"""

# ╔═╡ 339ccfca-74b1-11eb-0c35-774da6b189ed
md"""
## Combinações lineares (combinando imagens)
"""

# ╔═╡ 8711c698-7500-11eb-2505-d35a4de169b4
md"""
Uma das ideias funmentais de matemática são as _combinações linares_ tópico
fundamental do curso de Álgebra Linar. Lembrando uma combinação linear é
composta de operações do tipo:

- escalamento: multiplicar um objeto por um escalar de maneira a ampliá-lo,
  encolhê-lo e/ou invertê-lo.

- soma: comabinar dois objetos do mesmo tipo, obtendo uma combinação dos dois.
"""

# ╔═╡ 84350cb8-7501-11eb-095e-8f1a7e015f25
md"""
Mas a imagens nada mais são que matrizes e matrizes podem ser vistas como
vetores. Vamos agora combinar a imagem do Apolo.
"""

# ╔═╡ 91a1bca4-74aa-11eb-3917-1dfd73d0ad9c
apolohead = load(download("https://www.ime.unicamp.br/~pjssilva/images/ensino/labcompsci/cabeca_apolo.png"))

# ╔═╡ 8e698bdc-7501-11eb-1d2e-c336ccbde0b0
@bind c Slider(0:.1:3, show_value=true, default=1)

# ╔═╡ ab2bc924-7501-11eb-03ba-8dfc1ffe3f36
c .* apolohead  # scaling the apolohead changes intensity

# ╔═╡ e11d6300-7501-11eb-239a-135596309d20
md"""

Você deve estar pensando porque  fizemos questão de usar o **ponto vezes (.*)** na última expressão acima já que Julia sabe multiplicar um número por uma array. Isso foi feito porque internamente Julia tentar transformar operações que envolve operadores **element-a-elemento** em laços implícitos evitando a criação de grandes objetos temporários implicitamente. Isso de fato ocorre acima. Pense que o ponto enfatiza que a multiplicação por `c` está ocorrendo pixel-a-pixel e que o `c` está sendo difundido para atuar sobre todos os pixels.
"""

# ╔═╡ 9a66c07e-7503-11eb-3127-7fce91b3a24a
md"""
Multiplicar por números muito grande satura a imagem. Lembre que os valores máximos ara os canais r, g, b é 1, valores r, g, b ≥ 1, saturam em 1.
"""

# ╔═╡ 47d40406-7502-11eb-2f43-cd5c848f25a6
md"""
Vamos agora virar o Apolo de cabeça para baixo.
"""

# ╔═╡ 9ce0b980-74aa-11eb-0678-01209451fb65
upsidedown_apolohead = apolohead[end:-1:1 , :]

# ╔═╡ 68821bf4-7502-11eb-0d3c-03d7a00fdba4
md"""
Vamos somar versões escaladas das duas iamgens e ver o que ocorre.
"""

# ╔═╡ 447e7c9e-74b1-11eb-27ea-71aa4338b11a
(.5 * upsidedown_apolohead .+ .5 * apolohead)

# ╔═╡ c9dff6f4-7503-11eb-2715-0bf9d3ece9e1
md"""
### Combinações convexas
"""

# ╔═╡ d834103c-7503-11eb-1a94-1fbad43801ff
md"""
Se numa combinação linear os coeficientes são positivos e somam um dizemos que essa é uma _combinação convexa_. Pense nessa operação como uma média. Do ponto de vista vetorial seria encontrar um vetor que está no meio do caminho (ou segmento) que une os dois vetores.

Note que quando temos somente dois vetores, se um dos coeficiente é α ou outro será (1 - α) para somar 1. Note que também é necessário que $\alpha \in [0, 1]$, senão o outro coeficiente seria negativo.

Vamos escrever abaixo uma versão interativa do código acima que nos permite observar todas as combinações convexas das imagens dos vira-latas e sua inversão.
"""

# ╔═╡ aa541288-74aa-11eb-1edc-ab6d7786f271
    @bind α Slider(0:.01:1 , show_value=true, default = 1.0)

# ╔═╡ c9dcac48-74aa-11eb-31a6-23357180c1c8
α .* apolohead .+ (1-α) .* upsidedown_apolohead

# ╔═╡ 30b1c1f0-7504-11eb-1be7-a9463caea809
md"""
Algo intenressante que o prof. Edelman, autor desse caderno, notou e que também ocorre comigo é que olhando para essa imagem o meu cérebro parece preferir ver o Apolo "de pé" no lugar do Apolo "de cabeça-para-baixo". Mas a imavem é criada com a média aritmética dos dois, não há motivo "matemático" para isso ocorrer. Aqui é um dos momentos que o nosso cérebro tenta ser esperto e acaba "escolhendo" o que é mais natural para ele. Para mim eu preciso pegar numa combinação do tipo α = 0.4 (o peso da imagem em pé), para achar que as duas versões estão "equilibradas".


The moment I did this with α = .5, I noticed my brain's tendency to see the rightsisde-up apolohead even though both have equal weight.  For me maybe around α = .39 which gives weight .61 to the upside-down apolohead "feels" balanced to me.  I think this is what the field of psychology called psychometrics tries to measure -- perhaps someone can tell me if there are studies of the brain's tendency to use world experience to prefer rightside-up apolohead, and in particular to put a numerical value to this tendency.
"""

# ╔═╡ 1fe70e38-751b-11eb-25b8-c741e1726613
md"""
Há uma área do conhecimento que tenta lidar com isso, chamada psicometria. Ela tenta analisar como nosso cérebro usa as medidas para construir um modelo do mundo em torno de nós. Esse tipo de informação pode ser útil e é explorado em soluções tecnológicos. Por exemplo modelos [psicoacústicos](https://pt.wikipedia.org/wiki/Psicoac%C3%BAstica) são usados no desenvolveminto de codecs de audio como o MP3, Vorbis ou Celph.

Sobre esse fenômeno específico de imagens de rostos é certamente estudado. Ele é conhecido como [efeito de inversão de faces](https://en.wikipedia.org/wiki/Face_inversion_effect#:~:text=The%20face%20inversion%20effect%20is,same%20for%20non%2Dfacial%20objects.&text=The%20most%20supported%20explanation%20for,is%20the%20configural%20information%20hypothesis)
e está relacionado ao [efeito Thatcher](https://en.wikipedia.org/wiki/Thatcher_effect#:~:text=The%20Thatcher%20effect%20or%20Thatcher,obvious%20in%20an%20upright%20face).

... os artigos falam de faces humanas e sugerem que esse tipo de confusão não ocorre com objetos. é interessante, que o mesmo fenômeno ocorre com rostos de cães, sugerindo que a parte do nosso cérebro responsável pelo **processamento de rostos** é usada para processar as faces de alguns animais como cães. Será que é sempre assim? Será que o mesmo ocorre com a face de uma ave ou outr animal? Testem vocês, agora é fácil.
"""

# ╔═╡ 215291ec-74a2-11eb-3476-0dab43fd5a5e
md"""
## 2.3 Diversão com Gimp (ou Photoshop): o que é um "filtro" nesse contexto?
"""

# ╔═╡ 61db42c6-7505-11eb-1ddf-05e906234572
md"""
[Referência de filtros do Gimp](https://docs.gimp.org/en/filters.html)
"""

# ╔═╡ cdd4cffc-74b1-11eb-1aa4-e333cb8601d1
md"""
Se usamos um programa de processamento de imagens, como o Gimp ou Photoshop, vemos que ele disponibiliza vários filtros para ajudar na manipulação desses objetos.

Algums filtros que podemos destacar são:
1. Desfocagem (blur)
1. Nitidez (sharpen)
1. Bordas (Find edges)
1. Pixelar (Pixelate)
3. Distorções

Algumas dessas transformações, como desfocar, aumentar nitiditez ou encontrar bordas, são exempos de colvoluções que podem ser implementadas de forma muito eficiente e aparecem naturalmente em aplicações de aprendizagem de máquina, em particular em reconhecimento de imagens.
"""

# ╔═╡ 7489a570-74a3-11eb-1d0b-09d41604ffe1
md"""
## 2.4 Filtros de imagens (convoluções)
"""

# ╔═╡ 8a8e3f5e-74b2-11eb-3eed-e5468e573e45
md"""
Vamos começar vendo uma rápida introdução a filtros de covolução feitas pelo 3Blue1Brown (Grant Sanderson) em uma das versões originais desse curso. Vamos usar apenas uns trechos curtos e depois discutí-los com vocês. Mas é claro que podem assistir a versão completa do vídeo depois se quiserem.
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
O que são esses filtros de convoluções? Bom você pode ler a página da Wikepedia sobre [Kernels]
(https://en.wikipedia.org/wiki/Kernel_(image_processing)). Mas vou tentar fazer uma rápida explicação própria.

Um filtro de covolução é baseado na ideia de se contruir uma nova imagem cujos pixels são obtidos por uma conta simples feita entre pixels vizinhos. Isso pode ser feito imaginando, como no vídeo, que colocamos uma matriz centrada no pixel que queremos calcular. Essa matriz seleciona o pixel central e seus vizinhos e multiplica todos os pixels pelos valores de sua entrada calculando a sua média. Dependendo da estrutura matriz obtemos um efeito diferente. No exeplo do vídeo ela modelava a ideia de se calcular a média entre todos os vizinhos e isso gerava um efeito de desfocagem.

Outros efeitos são possíveis de acordo com os valores da entrada da matriz. Vamos ver alguns exemplos abaixo e pensar porque o efeito obtido ocorre.
"""

# ╔═╡ 54448d18-7528-11eb-209a-9717affa0d02
 kernelize(M) = OffsetArray(M, -1:1, -1:1)

# ╔═╡ acbc563a-7528-11eb-3c38-75a5b66c9241
begin
	identity = [0 0 0
		        0 1 0
		        0 0 0]
	edge_detect = [ 0 -1  0
		           -1  4 -1
		            0 -1  0]
	sharpen = identity .+ edge_detect # Superposition!
	box_blur = [1 1 1
		        1 1 1
		        1 1 1] / 9
	∇x = [-1 0 1
		  -1 0 1
		  -1 0 1] / 2 # centered deriv in x
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
	# Edge style filters can return negative values naturally.
	# Therefore we want the absolute value and it more sense in
	# Black and White.
	bwabs_filtered = Gray.(1.5 .* abs.(imfilter(apolohead, sel_kernel)))
	# Show both images side by side
	[filtered bwabs_filtered]
end

# ╔═╡ 275bf7ac-74b3-11eb-32c3-cda1e4f1f8c2
md"""
### Análise Complexidade (tempo de execução)

De uma forma geral o tempo de execução é dominando por acessar a imagem e fazer as operações necessárias (mulplicações e somas). Ele será proporcional então a:

**Número de pixels na imagem × Número de células no núcleo**

Nesse sentido os núcleos menores resultam em menor tempo de execução. Porém outro fator importante é que o tamanho natural do núcleo a ser usado deve também levar em consideração o tamanho da imagem. Afinal de contas núcleos muito pequenos em imagens grandes vão cobrir uma área uma muito pequena, acessando pouca informação.
"""

# ╔═╡ c6e340ee-751e-11eb-3ca7-69595b3693b7
md"""
### Arquitetura de hardware: GPUs (Unidades de processamento gráfico)

O uso de kernels de convolução em imagens é um exemplo típico de operações usadas em seu processamento. Elas normalmente resultam um um grupo de operações simples e bem estruturadas que devem ser realizadas em enorme quantidade e com pouca interdependência entre si. Para isso, com o tempo, os fabricantes de placas gráficas começaram a criar hardware específico que é capaz de realizar essas operações de forma muito rápida explorando o seu paralelismo intríncisco. Com isso nasceram as placas de aceleração para gráficos, as GPUs. Elas são compostas de uma grande quantidade de processadores que conseguem realizar esse tipo de operações de forma paralela e muito eficiente.

É interessante que com o tempo começou-se a usar as placas acelaradoras gráficas para realizar outras operações matemáticas que não estavam relacionadas diretamente ao processamento de imagens. Isso porque em outros domínios há algoritmos que também necessitam desse tipo de operações repetitivas, estruturadas e facilmente paralelizáveis. Assim, hoje em dia muitos dos supercomputadores são compostos por uma mistura de CPUs e GPUs que se adequam ao tipo de processamento que se pretende fazer. As CPUs funcionam melhor para lidar com operações de fluxo mais complexo, já as GPUs brilham com operações altamente estruturadas e repetitivas.
"""

# ╔═╡ 844ed844-74b3-11eb-2ee1-2de664b26bc6
md"""
  ### Filtros gaussianos
"""

# ╔═╡ 4ffe927c-74b4-11eb-23a7-a18d7e51c75b
md"""
Uma variação dos filtros de desfocagem que é muito útil são os filtros gaussianos. Neles dá-se maior peso ao centro do núcleo (onde está o pixel resultante) e continuamente ele se estedendem para as extremidades diminuido o peso a medida que se afastam do centro. Vamos mais uma vez pedir ajudao do nosso amigo Grant Sanderson (atenção ao trecho 4:35-7:00, com ênfase no instante 5:23):
"""

# ╔═╡ 91109e5c-74b3-11eb-1f31-c50e436bc6e0
html"""
<div notthestyle="position: relative; right: 0; top: 0; z-index: 300;"><iframe src="https://www.youtube.com/embed/8rrHTtUzyZA?start=275&end=420" width=400 height=250  frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div>
"""

# ╔═╡ 34109062-7525-11eb-10b3-d59d3a6dfda6
round.(Kernel.gaussian(1), digits=3)

# ╔═╡ 9ab89a3a-7525-11eb-186d-29e4b61deb7f
md"""
Acima usamos a rotina Kernel.gaussian que já está pronta no pacote `ImageFiltering.jl`, o mesmo que define a funlção `imfilter` que usamos para aplicar os filtros. Mas podemos também fazer as contas rapidamente, usando a função exponencial.
"""

# ╔═╡ 50034058-7525-11eb-345b-3334e71ac50e
begin
	G = [exp(-(i^2+j^2)/2) for i=-2:2, j=-2:2]
	round.(G ./ sum(G), digits=3)
end

# ╔═╡ c0aec7ae-7505-11eb-2822-a151aad48fc9
md"""
Esse tipo de filtro é conhecido como desfocagem gaussiana. O nome vem da fórmula usada na sua decinição. Veja por exemplo [um texto da Adobe sobre desfocagem gaussiana](https://www.adobe.com/creativecloud/photography/discover/gaussian-blur.html).
"""

# ╔═╡ 99eeb11c-7524-11eb-2154-df7d84976445
@bind gparam Slider(0:9, show_value=true, default=1)

# ╔═╡ 2ddcfb90-7520-11eb-2df7-172d07118b7e
kernel = Kernel.gaussian(gparam)

# ╔═╡ d62496b0-7524-11eb-3410-7177e7c7f8eb
plotly()

# ╔═╡ 6aa8a76e-7524-11eb-22b5-015aab4191b0
surface([kernel;])

# ╔═╡ ee93eeb2-7524-11eb-342d-0343d8aebf59
md"""
Obs: as linhas pretas são curvas de nível e a visão do gráfico com relação aos eixos.
"""

# ╔═╡ 662d73b6-74b3-11eb-333d-f1323a001000
md"""
### Computação: estrutura de dados: arrays com descolamento de índices (_offset_)
"""

# ╔═╡ d127303a-7521-11eb-3507-7341a416211f
kernel[0,0]

# ╔═╡ d4581b56-7522-11eb-2c15-991c0c790e67
kernel[-2,2]

# ╔═╡ 40c15c3a-7523-11eb-1f2a-bd90b127dad2
M = [ 1  2  3  4  5
	  6  7  8  9 10
	 11 12 13 14 15]

# ╔═╡ 08642690-7523-11eb-00dd-63d4cf6513dc
Z = OffsetArray(M, -1:1, -2:2)

# ╔═╡ deac4cf2-7523-11eb-2832-7b9d31389b08
the_indices = [c.I for c ∈ CartesianIndices(Z)]

# ╔═╡ 32887dfa-7524-11eb-35cd-051eff594fa9
Z[1,-2]

# ╔═╡ 0f765670-7506-11eb-2a37-931b15bb387f
md"""
## Contínuo vs discreto
"""

# ╔═╡ 82737d28-7507-11eb-1e39-c7dc12e18882
md"""
Muitas pessoas se sentem mais a vontade com objetos discretos e outros com matemática contínua (meu caso). Mas o computador mostra que a diferença nem sempre é muito clara e que muitos conceitos de uma área podem ser traduzidos para a outra. Os exemplo de núcleos de fato estão relacionados com isso.
"""

# ╔═╡ 40d538b2-7506-11eb-116b-efeb16b3478d
md"""
### Núcleos de desfocagem :: Integrais  × Detecção de bordas :: Derivadas
"""

# ╔═╡ df060a88-7507-11eb-034b-5346d67a0e0d
md"""
Para entender isso basata pensar na relação entre derivadas e integrais. Se substituirmos f(x) por g(x) = ∫ f(t) dt for x-r ≤ t ≤ x+r, vamos suavizar (ou desfocar, misturar) o comportamento de f. Já quando calculamos a derivadas, estamos olhando para as mudanças (as variações), assim vamos detectar momentos de rápidas mudanças e com isso "detectar as bordas".
"""

# ╔═╡ 60c8db60-7506-11eb-1468-c989809c933a
md"""
## Respeitando as fronteiras
"""

# ╔═╡ 8ed0be60-7506-11eb-2769-5f7da1c66243
md"""
Aplicar um filtro de convolução nas bordas exige cuidado, por esse é caso limite onde podemos "cair para fora da matriz" se não tomamos cuidado. De novo pode olhar o vídeo do Grant Sanderson, ele explica isso melhor que eu. Olhe os instantes 2:53-4:19.
"""

# ╔═╡ b9d636da-7506-11eb-37a6-3116d47b2787
html"""
<div notthestyle="position: relative; right: 0; top: 0; z-index: 300;"><iframe src="https://www.youtube.com/embed/8rrHTtUzyZA?start=173&end=259" width=400 height=250  frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div>
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
# ╠═91a1bca4-74aa-11eb-3917-1dfd73d0ad9c
# ╠═8e698bdc-7501-11eb-1d2e-c336ccbde0b0
# ╠═ab2bc924-7501-11eb-03ba-8dfc1ffe3f36
# ╟─e11d6300-7501-11eb-239a-135596309d20
# ╟─9a66c07e-7503-11eb-3127-7fce91b3a24a
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
# ╠═acbc563a-7528-11eb-3c38-75a5b66c9241
# ╠═995392ee-752a-11eb-3394-0de331e24f40
# ╠═d22903d6-7529-11eb-2dcd-132cd27104c2
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
# ╟─0f765670-7506-11eb-2a37-931b15bb387f
# ╟─82737d28-7507-11eb-1e39-c7dc12e18882
# ╟─40d538b2-7506-11eb-116b-efeb16b3478d
# ╟─df060a88-7507-11eb-034b-5346d67a0e0d
# ╟─60c8db60-7506-11eb-1468-c989809c933a
# ╟─8ed0be60-7506-11eb-2769-5f7da1c66243
# ╟─b9d636da-7506-11eb-37a6-3116d47b2787
