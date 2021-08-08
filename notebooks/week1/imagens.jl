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

# ╔═╡ 74b008f6-ed6b-11ea-291f-b3791d6d1b35
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
		Pkg.PackageSpec(name="HypertextLiteral", version="0.5")
	])

	using Colors, ColorVectorSpace, ImageShow, FileIO
	using PlutoUI
	using HypertextLiteral
end

# ╔═╡ 71a1e08a-6abc-48d5-b177-5184dbdd76a8
filter!(LOAD_PATH) do path
	path != "@v#.#"
end;

# ╔═╡ 75b96e8c-fa48-4b78-a7dc-587a676f04e2
md"Esta é uma tradução livre de [images.jl](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week1/images.jl)"

# ╔═╡ d07fcdb0-7afc-4a25-b68a-49fd1e3405e7
PlutoUI.TableOfContents(title="Índice", aside=true)

# ╔═╡ 9b49500c-0164-4556-a17b-7595e35c5ede
md"""
#### Inicializando os pacotes

_Lembre que quando executa esse caderno pela primeira vez pode levar um tempo para instalar pacotes e baixar arquivos da Internet. Em casos extremos isso pode levar até 15 minutos. Tenha paciência!_
"""

# ╔═╡ ca1b507e-6017-11eb-34e6-6b85cd189002
md"""
# Imagens como exemplo de dados que estão por todo lado

Bem vindos ao Laboratório de Computação Científica usando Julia para problemas reais. Esse é um curso baseado no _Computational Thinking using Julia for Real-World Problems_ do MIT com uma pitada pessoal.

O objetivo do curso é juntar conceitos de ciência da computação e matemática aplicada e código em liguagem moderna e ágil chamada **Julia**. A ideia é usar essas ideias em um curso no estilo "mãos-à-obra" olhando para aplicações interessantes e se divertir no processo.

A ideia é tocar os estudos interessados em matemática aplicada e computação científica aprederem um pouco mais de ciência da computação e vice-versa. A ainda introduzir uma nova linguagem que traz novos conceitos e uma abordagem interessante para a computação científica. Então vamos lá aprender um pouco de tudo, exprimindo-se por código.

"""

# ╔═╡ 9111db10-6bc3-11eb-38e5-cf3f58536914
md"""
## O que é computação científica?
"""

# ╔═╡ fb8a99ac-6bc1-11eb-0835-3146734a1c99
md"""
Aplicações de computação no mundo real usam **dados**, isto é, informções que podemos **medir** de alguma forma. Esses dados podem ser de vários tipos, como por exemplo:

- Números que variam no tempo (**séries temporais**):
  - Preços de ações por segundo / minuto /dia
  - Número diário / semanal de novos casos de uma epidemia 
  - Temperatura global média por mês

- Vídeo:
  - A vista da câmera de um carro autônomo
  - As imagens de uma câmera de segurança
  - Ultrasom, por exemplo um exame pré-natal

- Imagens:
  - Imagens de exames médicos com exemplos de tecidos sadios e doentes
  - Fotos do seu animal de estimação
"""

# ╔═╡ b795dcb4-6bc3-11eb-20ec-db2cc4b89bfb
md"""
#### Exercício:
> Tente imaginar outros exemplos em cada categoria. Você consegue também pensar em outras categorias de dados?
"""

# ╔═╡ 8691e434-6bc4-11eb-07d1-8169158484e6
md"""
Assim, processos computacionais geralmente seguem o seguinte fluxo simplificado:
"""

# ╔═╡ 546db74c-6d4e-11eb-2e27-f5bed9dbd9ba
md"""
## dados ⟶  entrada  ⟶ processamento ⟶ modelagem ⟶ visualização ⟶ saída
"""

# ╔═╡ 6385d174-6d4e-11eb-093b-6f6fafb79f84
md"""
Para usar uma fonte de dados, precisamos conseguir entrar com esses dados no nosso computador, por exemplo baixando a informação da Internet e lendo o arquivo obtido. Ele então deve ser convertido em uma forma que facilite as manipulações que desejamos fazer. Os dados são então **processados** de alguma forma para obter a informação desejada. Muitas vezes, também, desejemamos **visualizar** a informção obtida e **armazená-la** de alguma forma. 

Tipicamente o processamento está baseado em algum modelo matemático ou computacional que nos ajuda a entender os dados e extrair a informação de interesse.

>O objetivo desse cuso é usar programção, ciência da computação e matemática aplicada para nos ajudar a atingir esses objetivos.
"""

# ╔═╡ 132f6596-6bc6-11eb-29f1-1b2478c929af
md"""
# Dados: Imagens como um exemplo de dados

Vamos começar visualizando **imagens** e aprendendo como processá-las. Our objetivo é processar os dados presentes na imagem de algum momento. Isso pode ser feito utilizando **algoritmos** específicos.

Deixo aqui um vídeo do 3-Blue-1-Brown (Grant Sanderson) apresentando uma pequena variação dessa aula na versão oritinal do curso oferecida no MIT no outono 2020. Pois é não dá para concorrer...
"""

# ╔═╡ 635a03dd-abd7-49c8-a3d2-e68c7d83cc9b
html"""
<div notthestyle="position: relative; right: 0; top: 0; z-index: 300;"><iframe src="https://www.youtube.com/embed/DGojI9xcCfg" width=400 height=250  frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div>
"""

# ╔═╡ 9eb6efd2-6018-11eb-2db8-c3ce41d9e337
md"""

Ao abrirmos uma imagem no computador e ampliarmos o suficientes, iremos ver que elas são armazenadas como uma matriz de pequenos quadrados chmados de **pixels** (que vem do inglês "picture elements"). Cada pixel é preenchido com uma or única. Eles são então organizados em uma grade retangular bi-deimensional.

Como tudo no computador, essas cores são representadas no computador em formato RGB (três canais, números, de cores de tom vermelho (Red), verde (Green) e azul (Blue)). 

Lembrem-se que muitas imagens são apenas respresentações **aproximadas** da realidade. Elas são discretas e bi-dimensionais e tentam capturar uma realidade tri-dimensional.

"""

# ╔═╡ e37e4d40-6018-11eb-3e1d-093266c98507
md"""
# Entrada e visualização: carregando e visualizando uma imagem (em Julia)
"""

# ╔═╡ e1c9742a-6018-11eb-23ba-d974e57f78f9
md"""
Vamos usar Julia para carregar imagens reais e manipulá-las. Podemos baixar imagens da Internet, ler de um arquivo ou mesmo usar sua webcam para tirar uma foto.
"""

# ╔═╡ 9b004f70-6bc9-11eb-128c-914eadfc9a0e
md"""
## Baixando uma imagem da Internet ou lendo de um arquivo local. 

Vamos usar o pacote `Images.jl` e ler imagens em três passos simples.
"""

# ╔═╡ 62fa19da-64c6-11eb-0038-5d40a6890cf5
md"""
Passo 1: (da Internet) devemos definir uma URL (endereço web) de onde baixar:
$(html"<br>")
(observe que Pluto coloca as resultado antes do código que os gera porque o seu desenvolverdor considera que a saída é mais interessante (ou importante) que o código. Isso pode exigir um tempo de adaptação, principalmente para quem está acostumado com Jupyter.)
"""

# ╔═╡ 34ee0954-601e-11eb-1912-97dc2937fd52
url = "https://www.ime.unicamp.br/~pjssilva/images/ensino/labcompsci/apolo1.png"

# ╔═╡ 9180fbcc-601e-11eb-0c22-c920dc7ee9a9
md"""
Passo 2: Agora podemos usar a função `download` (essa é fácil de lembrar!) para baixar o arquivo de imagem no computador. (Apolo é o meu cachorro SRD.)
"""

# ╔═╡ 34ffc3d8-601e-11eb-161c-6f9a07c5fd78
apolo_filename = download(url) # Baixa para um arquivo local, retornando o nome do arquivo onde ele foi armazenado.

# ╔═╡ abaaa980-601e-11eb-0f71-8ff02269b775
md"""
Passo 3:
Usando o pacote `Images.jl` (que foi carregado lá no topo desse cardeno, dê uma olhada) podemos **carregar** o arquivo na memória. Isso o transforma automaticamente em um tipo de dado que a linguagem consegue manipular. Armazenamos essa informação em uma variável. (Lembre que o código aparece depois da saída.)
"""

# ╔═╡ aafe76a6-601e-11eb-1ff5-01885c5238da
apolo = load(apolo_filename)

# ╔═╡ e86ed944-ee05-11ea-3e0f-d70fc73b789c
md"_Oi Apolo!_"

# ╔═╡ c99d2aa8-601e-11eb-3469-497a246db17c
md"""
O caderno Plutio reconheceu e apresentou o objeto que representa a imagem do Apolo, um cão SRD que vive comigo. O pobre Apolo será usado com exemplo nesse curso algumas vezes substituindo o crogi do professor Eldelman, autor original desses cadernos.

Pobre Apolo, ele vai ter que passar por várias "transformações" ao longo de nosso curso!
"""

# ╔═╡ 11dff4ce-6bca-11eb-1056-c1345c796ed4
md"""
- Exercício : troque a url para uma outra imagem na Internet.
- Exercício: adapte o código para usar outro arquivo de imagem que já esteja em seu computador.
"""

# ╔═╡ efef3a32-6bc9-11eb-17e9-dd2171be9c21
md"""
## Capturando uma imagem de sua webcam
"""

# ╔═╡ e94dcc62-6d4e-11eb-3d53-ff9878f0091e
md"""
Outra possibilidade divertida é capaturar uma imagem usando a webcam de seu computador. Tente selecionar o botão abaixo e dê permissão para o caderno acessar a sua webcam (ele está rodando em sua máquina). Depois basta selecionar o botão da câmera para capturar imagens. Você pode até pressionar várias vezes o botão enquanto se você e ver que a imagem capturada se move junto. Tudo em tempo real.
"""

# ╔═╡ cef1a95a-64c6-11eb-15e7-636a3621d727
md"""
## Analisando o dado (a imagem)
"""

# ╔═╡ f26d9326-64c6-11eb-1166-5d82586422ed
md"""
### Dimensões da imagem
"""

# ╔═╡ 6f928b30-602c-11eb-1033-71d442feff93
md"""
A primeira coisa que vamos faer é pegar o tamanho da imagem:
"""

# ╔═╡ 75c5c85a-602c-11eb-2fb1-f7e7f2c5d04b
apolo_size = size(apolo)

# ╔═╡ 77f93eb8-602c-11eb-1f38-efa56cc93ca5
md"""
Julia retorna dois números. Eles representam a altura e a largura da imagem, ou seja o número de pixels na vertical e na horizontal respectivamente.
"""

# ╔═╡ 96b7d801-c427-4e27-ab1f-e2fd18fc24d0
apolo_height = apolo_size[1]

# ╔═╡ f08d02af-6e38-4ace-8b11-7af4930b64ea
apolo_width = apolo_size[2]

# ╔═╡ f9244264-64c6-11eb-23a6-cfa76f8aff6d
md"""
### Indexando para selecionar posições na imagem

De uma forma geral, você pode imaginar que a imagem é uma matriz que contem valores RGB. Assim a forma natural de selecionar porções da imagem ou um pixel específico é usar indexação. A ideia é que vocês possam as coordenadas definindo qual linha e coluna querem selecionar. Isso é feito em Julia usando colchetes `[` e `]`. 
"""

# ╔═╡ bd22d09a-64c7-11eb-146f-67733b8be241
a_pixel = apolo[400, 600]

# ╔═╡ 28860d48-64c8-11eb-240f-e1232b3638df
md"""
Vemos que Julia nos mostra um bloco de cor sólida como representação de um pixel.

Lembrando, o primeiro número representa a *linha* na imagem, começando do topo e descendo. Já o segundo é a coluna na imagem, da esquera da para direita. Em Julia os índices começam em 1, diferenet de outras linguagens em que os índices começam no 0.
"""

# ╔═╡ 4ef99715-4d8d-4f9d-bf0b-8df9907a14cf


# ╔═╡ a510fc33-406e-4fb5-be83-9e4b5578717c
md"""
É claro que podemos usar variáveis no lugar dos indices.
"""

# ╔═╡ 13844ebf-52c4-47e9-bda4-106a02fad9d7
md"""
...e para fazer tudo mais divertido essas variáveis podem ser controladas por _sliders_!
"""

# ╔═╡ 08d61afb-c641-4aa9-b995-2552af89f3b8
@bind row_i Slider(1:size(apolo)[1], show_value=true)

# ╔═╡ 6511a498-7ac9-445b-9c15-ec02d09783fe
@bind col_i Slider(1:size(apolo)[2], show_value=true)

# ╔═╡ 94b77934-713e-11eb-18cf-c5dc5e7afc5b
row_i, col_i

# ╔═╡ ff762861-b186-4eb0-9582-0ce66ca10f60
apolo[row_i, col_i]

# ╔═╡ c9ed950c-dcd9-4296-a431-ee0f36d5b557
md"""
### Regiões em uma imagem: faixas de índices

Vemos que ao usar um valor para a linha e outro para coluna conseguimos selecionar um pixel individual na imamgem. Agora vamos pegar uma faixa iteira de índices. Em Julia é possível selecionar múltiplas linhas e colunas de uma matriz obtendo uma nova matriz que presenta a região selecionada:
"""

# ╔═╡ f0796032-8105-4f6d-b5ee-3647b052f2f6
apolo[550:650, 1:apolo_width]

# ╔═╡ b9be8761-a9c9-49eb-ba1b-527d12097362
md"""
Nesse caso, usamos `a:b` para representar _todos os números de `a` até `b`_ (incluindo ambos extremos). Por exemplo:

"""

# ╔═╡ d515286b-4ad4-449b-8967-06b9b4c87684
collect(2:10)

# ╔═╡ eef8fbc8-8887-4628-8ba8-114575d6b91f
md"""

Se usar apenas `:` Julia vai enteder que você quer _todos os índices_. Isso pode simplificar um pouco a expressão acima.
"""

# ╔═╡ 4e6a31d6-1ef8-4a69-b346-ad58cfc4d8a5
apolo[550:650, :]

# ╔═╡ e11f0e47-02d9-48a6-9b1a-e313c18db129
md"""
Podemos também elecionar uma única linha ou coluna.
"""

# ╔═╡ 9e447eab-14b6-45d8-83ab-1f7f1f1c70d2
apolo[:, 500]

# ╔═╡ c926435c-c648-419c-9951-ac8a1d4f3b92
apolo_head = apolo[140:1000, 250:1250]

# ╔═╡ 32e7e51c-dd0d-483d-95cb-e6043f2b2975
md"""
#### Selecione o nariz do Apolo!

Use o selecionador abaixo para achar a faixa que pega justamente o nariz do Apolo. Você pode ajustar os dois lados.
"""

# ╔═╡ 4b64e1f2-d0ca-4e22-a89d-1d9a16bd6788
@bind range_rows RangeSlider(1:size(apolo_head)[1])

# ╔═╡ 85919db9-1444-4904-930f-ba572cff9460
@bind range_cols RangeSlider(1:size(apolo_head)[2])

# ╔═╡ 2ac47b91-bbc3-49ae-9bf5-4def30ff46f4
nose = apolo_head[range_rows, range_cols]

# ╔═╡ 5a0cc342-64c9-11eb-1211-f1b06d652497
md"""
# Processamento: Modificando uma imagem

Agora que já sabemos como armazenar e manipular a imagem, podemos começar a **processá-la** para extrair informções e/ou moddificá-la de alguma forma.

Podemos, por exemplo, querer identificar objetos na imagem. Por exemplo buscar um tumor numa imagem médica. Para ser capaz de atingir esse tipo de objetivo de alto nível, precisamos saber inicialmente fazer coisas mais simples, como detectar arestas ou selecionar objetos de acordo com sua cor. Essas operações podem, por sua vez, ser reduzidas a operações ainda mais elementares como comparar a cor de pixels vizinhos ou decidir se eles são suficientemnte "distindos".

"""

# ╔═╡ 4504577c-64c8-11eb-343b-3369b6d10d8b
md"""
## Representando cores

Uma primeira coisa que iremos fazer é *modificar* a cor de um pixel. Para conseguir isso precisamos ver com mais calma como essas cores são representadas.

Cores são no fundo um conceito complexo que mistura as propriedades físicas (a frequẽncia), biológicas (quais cores os cones de luz que temos nos nossos olhos são capazes de captar) e até os processos cerebrais que traduzem os sinais adquiridos na nossa concepção mental dde cor. 

Mas aqui nós vamos ignorar esses nuances e iremos no ater ao método padrão de presentar as cores como uma **tripla RGB**. Ela é basicamente formada de três números $(r, g, b)$ que represetam "quanto" vermelho, verde e azul uma cor possui. Esses são números reais entre 0 (representando _ausência_) e 1 (representado _tudo_). A cor final que percebemos vem justamente de juntarmos essas três informações em nosso cérebro. Isso tudo é facinante, mas não podemos ver os detalhes aqui.
"""

# ╔═╡ 40886d36-64c9-11eb-3c69-4b68673a6dde
md"""
A maneira mais simples de criar um cor em Julia é usar:
"""

# ╔═╡ 552235ec-64c9-11eb-1f7f-f76da2818cb3
RGB(1.0, 0.0, 0.0)

# ╔═╡ c2907d1a-47b1-4634-8669-a68022706861
begin
	md"""
	Já um pixel com $(@bind test_r Scrubbable(0:0.1:1; default=0.1)) de vermelho, $(@bind test_g Scrubbable(0:0.1:1; default=0.5)) de verde e $(@bind test_b Scrubbable(0:0.1:1; default=1.0)) de azul tem a seguinte cor:
	"""
end


# ╔═╡ ff9eea3f-cab0-4030-8337-f519b94316c5
RGB(test_r, test_g, test_b)

# ╔═╡ f6cc03a0-ee07-11ea-17d8-013991514d42
md"""
#### Exercício 1.1
👉 Escreva uma função `invert` que inverte uma cor, ou seja, leva $(r, g, b)$ em $(1 - r, 1-g, 1-b)$.

Dica: a função `fieldnames` recebe um tipo e devolve o nome dos campos disponíveis.
"""

# ╔═╡ 63e8d636-ee0b-11ea-173d-bd3327347d55
function invert(color::AbstractRGB)

	return missing
end

# ╔═╡ 2cc2f84e-ee0d-11ea-373b-e7ad3204bb00
md"Let's invert some colors:"

# ╔═╡ b8f26960-ee0a-11ea-05b9-3f4bc1099050
black = RGB(0.0, 0.0, 0.0)

# ╔═╡ 5de3a22e-ee0b-11ea-230f-35df4ca3c96d
invert(black)

# ╔═╡ 4e21e0c4-ee0b-11ea-3d65-b311ae3f98e9
red = RGB(0.8, 0.1, 0.1)

# ╔═╡ 6dbf67ce-ee0b-11ea-3b71-abc05a64dc43
invert(red)

# ╔═╡ 846b1330-ee0b-11ea-3579-7d90fafd7290
md"Can you invert the picture of apolo?"

# ╔═╡ 943103e2-ee0b-11ea-33aa-75a8a1529931
apolo_inverted = missing

# ╔═╡ 2ee543b2-64d6-11eb-3c39-c5660141787e
md"""

## Modificando um pixel

Vamos começar pensando como modificar uma imagem, por exemplo para esconder alguma informação sensível.

Podemos fazer isso trocando a code de um pixel:
"""

# ╔═╡ 53bad296-4c7b-471f-b481-0e9423a9288a
let
	temp = copy(apolo_head)
	temp[100, 200] = RGB(0.0, 0.0, 1.0)
	temp
end

# ╔═╡ 81b88cbe-64c9-11eb-3b26-39011efb2089
md"""
Cuidado: nós de fatos estamos *modificando* a imagem mesmo que não consigamos de fato ver a modificação já que um único pixel foi alterado.
"""

# ╔═╡ ab9af0f6-64c9-11eb-13d3-5dbdb75a69a7
md"""
## Grupos de pixels

Nós podemos ter também o interesse de examinar e modificar vários pixels de uma vez. Por exemplo, vamos extrair uma faixa horizontal com um pixel de altura:
"""

# ╔═╡ e29b7954-64cb-11eb-2768-47de07766055
apolo_head[250, 25:300]

# ╔═╡ 8e7c4866-64cc-11eb-0457-85be566a8966
md"""
Nesse caso, Julia mostra a faixa como um conjunto de retângulos em uma linha.
"""

# ╔═╡ f2ad501a-64cb-11eb-1707-3365d05b300a
md"""
Podemos também modificar essa faixa.
"""

# ╔═╡ 4f03f651-56ed-4361-b954-e6848ac56089
let
	temp = copy(apolo_head)
	temp[250, 25:300] .= RGB(0.0, 0.0, 1.0)
	temp
end

# ╔═╡ 2808339c-64cc-11eb-21d1-c76a9854aa5b
md"""
E, de forma análoga, modificamos um bloco retangular de pixels:
"""

# ╔═╡ 1bd53326-d705-4d1a-bf8f-5d7f2a4e696f
let
	temp = copy(apolo_head)
	temp[100:180, 100:200] .= RGB(0.0, 0.0, 1.0)
	temp
end

# ╔═╡ a5f8bafe-edf0-11ea-0da3-3330861ae43a
md"""
#### Exercício 1.2

👉 Gere um vetor de 100 zeros e altere o 20 elementos centrais para 1.
"""

# ╔═╡ b6b65b94-edf0-11ea-3686-fbff0ff53d08
function create_bar()

	return missing
end

# ╔═╡ 693af19c-64cc-11eb-31f3-57ab2fbae597
md"""
## Reduzindo o tamanho da imagem
"""

# ╔═╡ 6361d102-64cc-11eb-31b7-fb631b632040
md"""
Podemos também querer reduzir o tamanho da imagem, já que ela é um pouco grande. Podemos, por exeplo, pegar o um pixel a cada 10 linhas e 10 colunas e gerar uma nova imagem com o resultado.
"""

# ╔═╡ ae542fe4-64cc-11eb-29fc-73b7a66314a9
reduced_image = apolo[1:10:end, 1:10:end]

# ╔═╡ c29292b8-64cc-11eb-28db-b52c46e865e6
md"""
Observando com calma a imagem não parece tão boa, ela perdeu muitos detalhes.

#### Exercício

> Tente pensar como seria possível reduzir a imagem sem perder tanto detalhe.
"""

# ╔═╡ 7b04331a-6bcb-11eb-34fa-1f5b151e5510
md"""
# Modelagem: Criando imagens sintéticas

Pense no seu filme favorita da Pixar (por exemplo Monstros S. A.). Quadros desses filmes são imagens geradas a partir de modelos matemáticos complexos. Uma das técnicas que são usadas é o Ray tracing (que talvez vejamos nesse curso). Essa é uma técnica muito usada na geração de imagens que parecem realísticas.
"""

# ╔═╡ 5319c03c-64cc-11eb-0743-a1612476e2d3
md"""
# Saída: Gravando uma imagem em arquivo

Finamente, nós podemos querer gravar nossa nova criação em um arquivo. Para isso, você pode **aperta com o botão direito** sobre uma imagem e salvá-la para um arquivo. Mas você também pode querer salvar a imagem usado Julia, basta usar a função `save` que recebe o nome do arquivo destino e a imagem a ser guardada.
"""

# ╔═╡ 3db09d92-64cc-11eb-0333-45193c0fd1fe
save("reduced_apolo.png", reduced_image)

# ╔═╡ 61606acc-6bcc-11eb-2c80-69ceec9f9702
md"""
# $(html"<br>")
"""

# ╔═╡ dd183eca-6018-11eb-2a83-2fcaeea62942
md"""
# Ciência da computação: arrays

Um imagem é um exemplo concreto de uma ideia geral e fundamental em computação, o **aray**. 

Uma imagem é uma malha retangular em que cada elemento contém uma cor. Um array é uma malha retangular para armazenar dados de um _único tipo_. Os dados são armazenados e recuperados usando índices, exatamente como no exemplo das imagens: cada célula da malha pode armazenar uma "única unidade" de um certo tipo.

## Dimensão de um array

OK, isso é um pouco confuso para um matemático. Mas em programação chamamos de dimensão de um array o número de eixos que usamos na indexação. Assim, o que costumamos de chamar de vetor teria uma dimensão. Já uma matriz duas. É possível criar arrays com mais de duas dimensões, que em matemática levaria a tensores. Além da dimensão (número de eixos), precisamos definir o comprimento de cada eixo e quais são de fato os índices que podem ser usados. Em Julia a convenção é que os índices começam em 1 e vão até o comprimento daquele eixo. Mas é também possível definir outras indexações se isso for estritamente necessário.

## Arrays como estrutura dados

Arrays são um exemplo simples de **estruturas de dados**. Elas são formas de armazenar dados e acessá-los. Diferentes estruturas de dados podem ser usada em diferentes situações. O importante é usar a estratura adequada, que é aquela que facilita as manipulações que você deseja fazer nos dados. Por exemplo, arrays são ótimos para acessar qualquer porção dos dados com posição conhecida. Mas eles já não são tão bons se desejamos procurar uma informação.

Os arrays tem essa noção de posição que os torna natural na representação de informação que tem essa estrutura posicional, como as imagens. Em imagens objetos distinos estão próximos (como o piso ou o nariz do Apolo). Dessa forma podemos esperar que pixels próximos tenham cores semelhantes e quando isso não ocorre podemos imaginar que estamos "trocando" de objetos e encontrando uma fronteira, uma aresta de um novo objeto. Essa estrutura será aproveitada nas próximas aulas.
"""

# ╔═╡ 8ddcb286-602a-11eb-3ae0-07d3c77a0f8c
md"""
# Julia: construindo arrays

## Criando vetores e matrices
Julia lida muito bem com arrays de qualquer dimensão.

Vetores, que são arrays uni-demensionais, podem ser criados usando uma notação com colchetes e vírgulas:
"""

# ╔═╡ f4b0aa23-2d76-4d88-b2a4-3807e88d27ce
[1, 20, "hello"]

# ╔═╡ 1b2b2b18-64d4-11eb-2d43-e31cb8bc25d1
[RGB(1, 0, 0), RGB(0, 1, 0), RGB(0, 0, 1)]

# ╔═╡ 2b0e6450-64d4-11eb-182b-ff1bd515b56f
md"""
Já matrizes, que são bi-dimensionais, também usam colchetes.Matrices, mas separam elementos de uma mesma linha por espaços e as linhas em si por quabra de linha ou ponto-e-vírgula:
"""

# ╔═╡ 3b2b041a-64d4-11eb-31dd-47d7321ee909
[RGB(1, 0, 0)  RGB(0, 1, 0)
 RGB(0, 0, 1)  RGB(0.5, 0.5, 0.5)]

# ╔═╡ 0f35603a-64d4-11eb-3baf-4fef06d82daa
md"""

## Compreensões de arrays

Quando queremos criar arrays com mais de um punhado de elemento já não é tão prático usar a notação acima. Uma forma de *automatizar* esse processo e criar o novo array seguindo algum tipo de padrão. Por exemplo, podemos querer criar todo um gradiente de cores.

Para isso vamos interpolar linearmente entre dois valores. No exemplo abaixo o valor inicial seria o `RGB(0, 0, 0)`, que representa o preto, e o final o vermelho, `RGB(1, 0, 0)`. Como apenas um valor está mudando (ou mais formalmente os valores estão mudando em uma direção específica), é possível armazenar o resultado num vetor.

Uma forma espera de fazer isso é usar uma **compreensão de array**, que é criar um novo array a partir de uma modificação de elements de um outro array (ou iterador). 

Vejamos o exemplo:
"""

# ╔═╡ e69b02c6-64d6-11eb-02f1-21c4fb5d1043
[RGB(x, 0, 0) for x in 0:0.1:1]

# ╔═╡ fce76132-64d6-11eb-259d-b130038bbae6
md"""
Nele, `0:0.1:1` é um **range** (uma faixa de números). O primeiro valor diz onde começa, o último onde termina e o do meio, quando existir, o passo que deve ser dados.
"""

# ╔═╡ 17a69736-64d7-11eb-2c6c-eb5ebf51b285
md"""
Podemos criar de maneira similar matrizes que são bimensionais, usamos aqui um `for` que pecorre dois ranges, o primeiro variando as linhas e o segundo as colunas. Os dois ranges deve ser separados por vírgula (`,`). No lugar dos ranges, podem estar outros objetos que sabemos percorrer, como vetores ou mesmo (uma única) matriz.
"""

# ╔═╡ 291b04de-64d7-11eb-1ee0-d998dccb998c
[RGB(i, j, 0) for i in 0:0.1:1, j in 0:0.1:1]

# ╔═╡ 647fddf2-60ee-11eb-124d-5356c7014c3b
md"""
## Concatenando matrizes

Para concatenar matrizes podemos usar a justaposição usando uma sintaxe selhante à criação de arrays:
"""

# ╔═╡ 7d9ad134-60ee-11eb-1b2a-a7d63f3a7a2d
[apolo_head  apolo_head]

# ╔═╡ 8433b862-60ee-11eb-0cfc-add2b72997dc
[apolo_head                   reverse(apolo_head, dims=2)
 reverse(apolo_head, dims=1)  rot180(apolo_head)]

# ╔═╡ 5e52d12e-64d7-11eb-0905-c9038a404e24
md"""
# Pluto: Iteratividade usando _sliders_
"""

# ╔═╡ 6aba7e62-64d7-11eb-2c49-7944e9e2b94b
md"""
Pluto tem algumas ferramentas para criar cadernos com iteratividade sem que o leitor precise alterar código. 

Por exemplo, suponha que queremos ver o efeito de se alterar um valor, digamos o número de tons de vermelho que usaremos no nosso gradiente. É claro que isso pode ser feito ajustando o range.

Mas Pluto nos permite também associar o valor de uma variável a posição de um slider (vimos outros exemplos durante a aula) e usar isso para definir o número de tons de vermehor que veremos no resultado.

Isso é um exemplo de se usar um elemento de **interface gráfica** em uma página web para torná-la iterativa. Vamos ver como funciona.
"""

# ╔═╡ afc66dac-64d7-11eb-1ad0-7f62c20ffefb
md"""
Nós definimos o slider através de
"""

# ╔═╡ b37c9868-64d7-11eb-3033-a7b5d3065f7f
@bind number_reds Slider(1:100, show_value=true)

# ╔═╡ b1dfe122-64dc-11eb-1104-1b8852b2c4c5
md"""
[O tipo `Slider` é definido n pacote `PlutoUI.jl`.]
"""

# ╔═╡ cfc55140-64d7-11eb-0ff6-e59c70d01d67
md"""
Isso cira uma nova variável chamada `number_reds` cujo valor é obtido a partir do valor que está no slider. Ao mover o slider, altermos o valor e a variável tem seu conteúdo atualizado. Isso resulta, devido à **reatividade** de Pluto, em mudanças em todas as células do caderno que usam esse valor! Isso tudo ocorre automaticamente sem que nós precisemos intervir!
"""

# ╔═╡ fca72490-64d7-11eb-1464-f5e0582c4d18
md"""
Aqui está o código que gera o gradiente a partir do número de tons de vermelhos que escolhido no slider. Notem que preto vai estar sempre lá.
"""

# ╔═╡ 88933746-6028-11eb-32de-13eb6ff43e29
[RGB(red_value / number_reds, 0, 0) for red_value in 0:number_reds]

# ╔═╡ 1c539b02-64d8-11eb-3505-c9288357d139
md"""
Ao mover o slider, vemos que o gradiente se ajusta automaticamente.
"""

# ╔═╡ 82a8314c-64d8-11eb-1acb-e33625381178
md"""
#### Exercício

>Crie três sliders para pegar três valores RGB e cria um bloco de cor com os valores selecionados. 

Obs: Pluto não permite criar variáveis com o mesmo nome em células diferente. Isso é fundamental para permitir a reatividade e a reordenação de células.
"""

# ╔═╡ 576d5e3a-64d8-11eb-10c9-876be31f7830
md"""
Dá também para estender o exemplo da matriz de cores acima usando sliders para definir o número de linhas e colunas. Tente você mesmo!
"""

# ╔═╡ a7cbbca2-324a-4d3e-ae03-c1e07f80f7e4
md"Obs: O código para pegar a imagem da webcam não está em `PlutoUI` ele está abaixo e usa diretamente HTML. Se quiser usar isso em outro lugar, você terá que copiar e colar ou colocar em uma biblioteca."

# ╔═╡ ace86c8a-60ee-11eb-34ef-93c54abc7b1a
md"""
# Resumo
"""

# ╔═╡ b08e57e4-60ee-11eb-0e1a-2f49c496668b
md"""
Vamos resumid as principais ideias desse caderno:

- Imagens são como **arrays** (mais precisamente matrizes) de cores.
- Nós podemos acessar e modificar arrays unsando **índices**.
- Noós podemos criar arrays explícitamente ou através de funções ou usando **compreensões de arrays**.
"""

# ╔═╡ 9025a5b4-6066-11eb-20e8-099e9b8f859e
md"""
----
"""

# ╔═╡ 5da8cbe8-eded-11ea-2e43-c5b7cc71e133
begin
	colored_line(x::Vector{<:Real}) = Gray.(Float64.((hcat(x)')))
	colored_line(x::Any) = nothing
end

# ╔═╡ d862fb16-edf1-11ea-36ec-615d521e6bc0
colored_line(create_bar())

# ╔═╡ e074560a-601b-11eb-340e-47acd64f03b2
hint(text) = Markdown.MD(Markdown.Admonition("dica", "Dica", [text]))

# ╔═╡ e0776548-601b-11eb-2563-57ba2cf1d5d1
almost(text) = Markdown.MD(Markdown.Admonition("aviso", "Quase lá!", [text]))

# ╔═╡ e083bef6-601b-11eb-2134-e3063d5c4253
still_missing(text=md"Substitua `missing` com sua resposta.") = Markdown.MD(Markdown.Admonition("aviso", "Vamos lá!", [text]))

# ╔═╡ e08ecb84-601b-11eb-0e25-152ed3a262f7
keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))

# ╔═╡ e09036a4-601b-11eb-1a8b-ef70105ab91c
yays = [md"Ótimo!", md"Ôba ❤", md"Muito bom! 🎉", md"Bom trabalho!", md"Continue assim!", md"Perfeito!", md"Incrível!", md"Você acertou!", md"Podemos continuar para a próxima seção."]

# ╔═╡ e09af1a2-601b-11eb-14c8-57a46546f6ce
correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correto", "Você entendeu!", [text]))

# ╔═╡ e0a4fc10-601b-11eb-211d-03570aca2726
not_defined(variable_name) = Markdown.MD(Markdown.Admonition("perigo", "Ooppss!", [md"Verifique que você definiu uma variável chamada **$(Markdown.Code(string(variable_name)))**"]))

# ╔═╡ e3394c8a-edf0-11ea-1bb8-619f7abb6881
if !@isdefined(create_bar)
	not_defined(:create_bar)
else
	let
		result = create_bar()
		if ismissing(result)
			still_missing()
		elseif isnothing(result)
			keep_working(md"Did you forget to write `return`?")
		elseif !(result isa Vector) || length(result) != 100
			keep_working(md"The result should be a `Vector` with 100 elements.")
		elseif result[[1,50,100]] != [0,1,0]
			keep_working()
		else
			correct()
		end
	end
end

# ╔═╡ e0a6031c-601b-11eb-27a5-65140dd92897
bigbreak = html"<br><br><br><br><br>";

# ╔═╡ 45815734-ee0a-11ea-2982-595e1fc0e7b1
bigbreak

# ╔═╡ e0b15582-601b-11eb-26d6-bbf708933bc8
function camera_input(;max_size=150, default_url="https://i.imgur.com/SUmi94P.png")
"""
<span class="pl-image waiting-for-permission">
<style>

	.pl-image.popped-out {
		position: fixed;
		top: 0;
		right: 0;
		z-index: 5;
	}

	.pl-image #video-container {
		width: 250px;
	}

	.pl-image video {
		border-radius: 1rem 1rem 0 0;
	}
	.pl-image.waiting-for-permission #video-container {
		display: none;
	}
	.pl-image #prompt {
		display: none;
	}
	.pl-image.waiting-for-permission #prompt {
		width: 250px;
		height: 200px;
		display: grid;
		place-items: center;
		font-family: monospace;
		font-weight: bold;
		text-decoration: underline;
		cursor: pointer;
		border: 5px dashed rgba(0,0,0,.5);
	}

	.pl-image video {
		display: block;
	}
	.pl-image .bar {
		width: inherit;
		display: flex;
		z-index: 6;
	}
	.pl-image .bar#top {
		position: absolute;
		flex-direction: column;
	}

	.pl-image .bar#bottom {
		background: black;
		border-radius: 0 0 1rem 1rem;
	}
	.pl-image .bar button {
		flex: 0 0 auto;
		background: rgba(255,255,255,.8);
		border: none;
		width: 2rem;
		height: 2rem;
		border-radius: 100%;
		cursor: pointer;
		z-index: 7;
	}
	.pl-image .bar button#shutter {
		width: 3rem;
		height: 3rem;
		margin: -1.5rem auto .2rem auto;
	}

	.pl-image video.takepicture {
		animation: pictureflash 200ms linear;
	}

	@keyframes pictureflash {
		0% {
			filter: grayscale(1.0) contrast(2.0);
		}

		100% {
			filter: grayscale(0.0) contrast(1.0);
		}
	}
</style>

	<div id="video-container">
		<div id="top" class="bar">
			<button id="stop" title="Stop video">✖</button>
			<button id="pop-out" title="Pop out/pop in">⏏</button>
		</div>
		<video playsinline autoplay></video>
		<div id="bottom" class="bar">
		<button id="shutter" title="Click to take a picture">📷</button>
		</div>
	</div>

	<div id="prompt">
		<span>
		Enable webcam
		</span>
	</div>

<script>
	// based on https://github.com/fonsp/printi-static (by the same author)

	const span = currentScript.parentElement
	const video = span.querySelector("video")
	const popout = span.querySelector("button#pop-out")
	const stop = span.querySelector("button#stop")
	const shutter = span.querySelector("button#shutter")
	const prompt = span.querySelector(".pl-image #prompt")

	const maxsize = $(max_size)

	const send_source = (source, src_width, src_height) => {
		const scale = Math.min(1.0, maxsize / src_width, maxsize / src_height)

		const width = Math.floor(src_width * scale)
		const height = Math.floor(src_height * scale)

		const canvas = html`<canvas width=\${width} height=\${height}>`
		const ctx = canvas.getContext("2d")
		ctx.drawImage(source, 0, 0, width, height)

		span.value = {
			width: width,
			height: height,
			data: ctx.getImageData(0, 0, width, height).data,
		}
		span.dispatchEvent(new CustomEvent("input"))
	}

	const clear_camera = () => {
		window.stream.getTracks().forEach(s => s.stop());
		video.srcObject = null;

		span.classList.add("waiting-for-permission");
	}

	prompt.onclick = () => {
		navigator.mediaDevices.getUserMedia({
			audio: false,
			video: {
				facingMode: "environment",
			},
		}).then(function(stream) {

			stream.onend = console.log

			window.stream = stream
			video.srcObject = stream
			window.cameraConnected = true
			video.controls = false
			video.play()
			video.controls = false

			span.classList.remove("waiting-for-permission");

		}).catch(function(error) {
			console.log(error)
		});
	}
	stop.onclick = () => {
		clear_camera()
	}
	popout.onclick = () => {
		span.classList.toggle("popped-out")
	}

	shutter.onclick = () => {
		const cl = video.classList
		cl.remove("takepicture")
		void video.offsetHeight
		cl.add("takepicture")
		video.play()
		video.controls = false
		console.log(video)
		send_source(video, video.videoWidth, video.videoHeight)
	}


	document.addEventListener("visibilitychange", () => {
		if (document.visibilityState != "visible") {
			clear_camera()
		}
	})


	// Set a default image

	const img = html`<img crossOrigin="anonymous">`

	img.onload = () => {
	console.log("helloo")
		send_source(img, img.width, img.height)
	}
	img.src = "$(default_url)"
	console.log(img)
</script>
</span>
""" |> HTML
end

# ╔═╡ d6742ea0-1106-4f3c-a5b8-a31a48d33f19
@bind webcam_data1 camera_input()

# ╔═╡ e891fce0-601b-11eb-383b-bde5b128822e

function process_raw_camera_data(raw_camera_data)
	# the raw image data is a long byte array, we need to transform it into something
	# more "Julian" - something with more _structure_.

	# The encoding of the raw byte stream is:
	# every 4 bytes is a single pixel
	# every pixel has 4 values: Red, Green, Blue, Alpha
	# (we ignore alpha for this notebook)

	# So to get the red values for each pixel, we take every 4th value, starting at
	# the 1st:
	reds_flat = UInt8.(raw_camera_data["data"][1:4:end])
	greens_flat = UInt8.(raw_camera_data["data"][2:4:end])
	blues_flat = UInt8.(raw_camera_data["data"][3:4:end])

	# but these are still 1-dimensional arrays, nicknamed 'flat' arrays
	# We will 'reshape' this into 2D arrays:

	width = raw_camera_data["width"]
	height = raw_camera_data["height"]

	# shuffle and flip to get it in the right shape
	reds = reshape(reds_flat, (width, height))' / 255.0
	greens = reshape(greens_flat, (width, height))' / 255.0
	blues = reshape(blues_flat, (width, height))' / 255.0

	# we have our 2D array for each color
	# Let's create a single 2D array, where each value contains the R, G and B value of
	# that pixel

	RGB.(reds, greens, blues)
end

# ╔═╡ 1d7375b7-7ea6-4d67-ab73-1c69d6b8b87f
myface1 = process_raw_camera_data(webcam_data1);

# ╔═╡ 6224c74b-8915-4983-abf0-30e6ba04a46d
[
	myface1              myface1[   :    , end:-1:1]
	myface1[end:-1:1, :] myface1[end:-1:1, end:-1:1]
]

# ╔═╡ 3ef77236-1867-4d02-8af2-ff4777fcd6d9
exercise_css = html"""
<style>

ct-exercise > h4 {
    background: #73789a;
    color: white;
    padding: 0rem 1.5rem;
    font-size: 1.2rem;
    border-radius: .6rem .6rem 0rem 0rem;
	margin-left: .5rem;
	display: inline-block;
}
ct-exercise > section {
	    background: #31b3ff1a;
    border-radius: 0rem 1rem 1rem 1rem;
    padding: .7rem;
    margin: .5rem;
    margin-top: 0rem;
    position: relative;
}


/*ct-exercise > section::before {
	content: "👉";
    display: block;
    position: absolute;
    left: 0px;
    top: 0px;
    background: #ffffff8c;
    border-radius: 100%;
    width: 1rem;
    height: 1rem;
    padding: .5rem .5rem;
    font-size: 1rem;
    line-height: 1rem;
    left: -1rem;
}*/


ct-answer {
	display: flex;
}
</style>

"""

# ╔═╡ 61b29e7d-5aba-4bc8-870b-c1c43919c236
exercise(x, number="") =
@htl("""
	<ct-exercise class="exercise">
	<h4>Exercise <span>$(number)</span></h4>
	<section>$(x)
	</section>
	</ct-exercise>
	""")

# ╔═╡ a9fef6c9-e911-4d8c-b141-a4832b40a260
quick_question(x, number, options, correct) = let
	name = join(rand('a':'z',16))
@htl("""
	<ct-exercise class="quick-question">
	<h4>Quick Question <span>$(number)</span></h4>
	<section>$(x)
	<ct-answers>
	$(map(enumerate(options)) do (i, o)
		@htl("<ct-answer><input type=radio name=$(name) id=$(i) >$(o)</ct-answer>")
	end)
	</ct-answers>
	</section>
	</ct-exercise>
	""")
end

# ╔═╡ edf900be-601b-11eb-0456-3f7cfc5e876b
md"_Aula 1, 2º Sem 2021, version 0_"

# ╔═╡ Cell order:
# ╟─75b96e8c-fa48-4b78-a7dc-587a676f04e2
# ╟─d07fcdb0-7afc-4a25-b68a-49fd1e3405e7
# ╟─9b49500c-0164-4556-a17b-7595e35c5ede
# ╠═74b008f6-ed6b-11ea-291f-b3791d6d1b35
# ╟─71a1e08a-6abc-48d5-b177-5184dbdd76a8
# ╟─ca1b507e-6017-11eb-34e6-6b85cd189002
# ╟─9111db10-6bc3-11eb-38e5-cf3f58536914
# ╟─fb8a99ac-6bc1-11eb-0835-3146734a1c99
# ╟─b795dcb4-6bc3-11eb-20ec-db2cc4b89bfb
# ╟─8691e434-6bc4-11eb-07d1-8169158484e6
# ╟─546db74c-6d4e-11eb-2e27-f5bed9dbd9ba
# ╟─6385d174-6d4e-11eb-093b-6f6fafb79f84
# ╟─132f6596-6bc6-11eb-29f1-1b2478c929af
# ╟─635a03dd-abd7-49c8-a3d2-e68c7d83cc9b
# ╟─9eb6efd2-6018-11eb-2db8-c3ce41d9e337
# ╟─e37e4d40-6018-11eb-3e1d-093266c98507
# ╟─e1c9742a-6018-11eb-23ba-d974e57f78f9
# ╟─9b004f70-6bc9-11eb-128c-914eadfc9a0e
# ╟─62fa19da-64c6-11eb-0038-5d40a6890cf5
# ╠═34ee0954-601e-11eb-1912-97dc2937fd52
# ╟─9180fbcc-601e-11eb-0c22-c920dc7ee9a9
# ╠═34ffc3d8-601e-11eb-161c-6f9a07c5fd78
# ╟─abaaa980-601e-11eb-0f71-8ff02269b775
# ╠═aafe76a6-601e-11eb-1ff5-01885c5238da
# ╟─e86ed944-ee05-11ea-3e0f-d70fc73b789c
# ╟─c99d2aa8-601e-11eb-3469-497a246db17c
# ╟─11dff4ce-6bca-11eb-1056-c1345c796ed4
# ╟─efef3a32-6bc9-11eb-17e9-dd2171be9c21
# ╟─e94dcc62-6d4e-11eb-3d53-ff9878f0091e
# ╠═d6742ea0-1106-4f3c-a5b8-a31a48d33f19
# ╠═1d7375b7-7ea6-4d67-ab73-1c69d6b8b87f
# ╠═6224c74b-8915-4983-abf0-30e6ba04a46d
# ╟─cef1a95a-64c6-11eb-15e7-636a3621d727
# ╟─f26d9326-64c6-11eb-1166-5d82586422ed
# ╟─6f928b30-602c-11eb-1033-71d442feff93
# ╠═75c5c85a-602c-11eb-2fb1-f7e7f2c5d04b
# ╟─77f93eb8-602c-11eb-1f38-efa56cc93ca5
# ╠═96b7d801-c427-4e27-ab1f-e2fd18fc24d0
# ╠═f08d02af-6e38-4ace-8b11-7af4930b64ea
# ╟─f9244264-64c6-11eb-23a6-cfa76f8aff6d
# ╠═bd22d09a-64c7-11eb-146f-67733b8be241
# ╟─28860d48-64c8-11eb-240f-e1232b3638df
# ╟─4ef99715-4d8d-4f9d-bf0b-8df9907a14cf
# ╟─a510fc33-406e-4fb5-be83-9e4b5578717c
# ╠═94b77934-713e-11eb-18cf-c5dc5e7afc5b
# ╠═ff762861-b186-4eb0-9582-0ce66ca10f60
# ╟─13844ebf-52c4-47e9-bda4-106a02fad9d7
# ╠═08d61afb-c641-4aa9-b995-2552af89f3b8
# ╠═6511a498-7ac9-445b-9c15-ec02d09783fe
# ╟─c9ed950c-dcd9-4296-a431-ee0f36d5b557
# ╠═f0796032-8105-4f6d-b5ee-3647b052f2f6
# ╟─b9be8761-a9c9-49eb-ba1b-527d12097362
# ╠═d515286b-4ad4-449b-8967-06b9b4c87684
# ╟─eef8fbc8-8887-4628-8ba8-114575d6b91f
# ╠═4e6a31d6-1ef8-4a69-b346-ad58cfc4d8a5
# ╠═e11f0e47-02d9-48a6-9b1a-e313c18db129
# ╠═9e447eab-14b6-45d8-83ab-1f7f1f1c70d2
# ╠═c926435c-c648-419c-9951-ac8a1d4f3b92
# ╟─32e7e51c-dd0d-483d-95cb-e6043f2b2975
# ╠═4b64e1f2-d0ca-4e22-a89d-1d9a16bd6788
# ╠═85919db9-1444-4904-930f-ba572cff9460
# ╠═2ac47b91-bbc3-49ae-9bf5-4def30ff46f4
# ╟─5a0cc342-64c9-11eb-1211-f1b06d652497
# ╟─4504577c-64c8-11eb-343b-3369b6d10d8b
# ╟─40886d36-64c9-11eb-3c69-4b68673a6dde
# ╠═552235ec-64c9-11eb-1f7f-f76da2818cb3
# ╟─c2907d1a-47b1-4634-8669-a68022706861
# ╠═ff9eea3f-cab0-4030-8337-f519b94316c5
# ╟─f6cc03a0-ee07-11ea-17d8-013991514d42
# ╠═63e8d636-ee0b-11ea-173d-bd3327347d55
# ╟─2cc2f84e-ee0d-11ea-373b-e7ad3204bb00
# ╟─b8f26960-ee0a-11ea-05b9-3f4bc1099050
# ╠═5de3a22e-ee0b-11ea-230f-35df4ca3c96d
# ╠═4e21e0c4-ee0b-11ea-3d65-b311ae3f98e9
# ╠═6dbf67ce-ee0b-11ea-3b71-abc05a64dc43
# ╟─846b1330-ee0b-11ea-3579-7d90fafd7290
# ╠═943103e2-ee0b-11ea-33aa-75a8a1529931
# ╟─2ee543b2-64d6-11eb-3c39-c5660141787e
# ╠═53bad296-4c7b-471f-b481-0e9423a9288a
# ╟─81b88cbe-64c9-11eb-3b26-39011efb2089
# ╟─ab9af0f6-64c9-11eb-13d3-5dbdb75a69a7
# ╠═e29b7954-64cb-11eb-2768-47de07766055
# ╟─8e7c4866-64cc-11eb-0457-85be566a8966
# ╟─f2ad501a-64cb-11eb-1707-3365d05b300a
# ╠═4f03f651-56ed-4361-b954-e6848ac56089
# ╟─2808339c-64cc-11eb-21d1-c76a9854aa5b
# ╠═1bd53326-d705-4d1a-bf8f-5d7f2a4e696f
# ╟─a5f8bafe-edf0-11ea-0da3-3330861ae43a
# ╠═b6b65b94-edf0-11ea-3686-fbff0ff53d08
# ╟─d862fb16-edf1-11ea-36ec-615d521e6bc0
# ╟─e3394c8a-edf0-11ea-1bb8-619f7abb6881
# ╟─693af19c-64cc-11eb-31f3-57ab2fbae597
# ╟─6361d102-64cc-11eb-31b7-fb631b632040
# ╠═ae542fe4-64cc-11eb-29fc-73b7a66314a9
# ╟─c29292b8-64cc-11eb-28db-b52c46e865e6
# ╟─7b04331a-6bcb-11eb-34fa-1f5b151e5510
# ╟─5319c03c-64cc-11eb-0743-a1612476e2d3
# ╠═3db09d92-64cc-11eb-0333-45193c0fd1fe
# ╟─61606acc-6bcc-11eb-2c80-69ceec9f9702
# ╟─dd183eca-6018-11eb-2a83-2fcaeea62942
# ╟─8ddcb286-602a-11eb-3ae0-07d3c77a0f8c
# ╠═f4b0aa23-2d76-4d88-b2a4-3807e88d27ce
# ╠═1b2b2b18-64d4-11eb-2d43-e31cb8bc25d1
# ╟─2b0e6450-64d4-11eb-182b-ff1bd515b56f
# ╠═3b2b041a-64d4-11eb-31dd-47d7321ee909
# ╟─0f35603a-64d4-11eb-3baf-4fef06d82daa
# ╠═e69b02c6-64d6-11eb-02f1-21c4fb5d1043
# ╟─fce76132-64d6-11eb-259d-b130038bbae6
# ╟─17a69736-64d7-11eb-2c6c-eb5ebf51b285
# ╠═291b04de-64d7-11eb-1ee0-d998dccb998c
# ╟─647fddf2-60ee-11eb-124d-5356c7014c3b
# ╠═7d9ad134-60ee-11eb-1b2a-a7d63f3a7a2d
# ╠═8433b862-60ee-11eb-0cfc-add2b72997dc
# ╟─5e52d12e-64d7-11eb-0905-c9038a404e24
# ╟─6aba7e62-64d7-11eb-2c49-7944e9e2b94b
# ╟─afc66dac-64d7-11eb-1ad0-7f62c20ffefb
# ╠═b37c9868-64d7-11eb-3033-a7b5d3065f7f
# ╟─b1dfe122-64dc-11eb-1104-1b8852b2c4c5
# ╟─cfc55140-64d7-11eb-0ff6-e59c70d01d67
# ╟─fca72490-64d7-11eb-1464-f5e0582c4d18
# ╠═88933746-6028-11eb-32de-13eb6ff43e29
# ╟─1c539b02-64d8-11eb-3505-c9288357d139
# ╟─82a8314c-64d8-11eb-1acb-e33625381178
# ╟─576d5e3a-64d8-11eb-10c9-876be31f7830
# ╟─a7cbbca2-324a-4d3e-ae03-c1e07f80f7e4
# ╟─ace86c8a-60ee-11eb-34ef-93c54abc7b1a
# ╟─b08e57e4-60ee-11eb-0e1a-2f49c496668b
# ╟─9025a5b4-6066-11eb-20e8-099e9b8f859e
# ╟─45815734-ee0a-11ea-2982-595e1fc0e7b1
# ╠═5da8cbe8-eded-11ea-2e43-c5b7cc71e133
# ╠═e074560a-601b-11eb-340e-47acd64f03b2
# ╠═e0776548-601b-11eb-2563-57ba2cf1d5d1
# ╠═e083bef6-601b-11eb-2134-e3063d5c4253
# ╟─e08ecb84-601b-11eb-0e25-152ed3a262f7
# ╠═e09036a4-601b-11eb-1a8b-ef70105ab91c
# ╠═e09af1a2-601b-11eb-14c8-57a46546f6ce
# ╠═e0a4fc10-601b-11eb-211d-03570aca2726
# ╠═e0a6031c-601b-11eb-27a5-65140dd92897
# ╠═e0b15582-601b-11eb-26d6-bbf708933bc8
# ╟─e891fce0-601b-11eb-383b-bde5b128822e
# ╠═3ef77236-1867-4d02-8af2-ff4777fcd6d9
# ╠═61b29e7d-5aba-4bc8-870b-c1c43919c236
# ╠═a9fef6c9-e911-4d8c-b141-a4832b40a260
# ╠═edf900be-601b-11eb-0456-3f7cfc5e876b
