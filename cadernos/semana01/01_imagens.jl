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

# ╔═╡ 74b008f6-ed6b-11ea-291f-b3791d6d1b35
begin
    import ImageIO
    import PlotlyBase
    using Colors, ColorVectorSpace, ImageShow, FileIO
    using PlutoUI
    using HypertextLiteral
end

# ╔═╡ 75b96e8c-fa48-4b78-a7dc-587a676f04e2
md"Tradução livre de [`images.jl`](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week1/images.jl)"

# ╔═╡ edf900be-601b-11eb-0456-3f7cfc5e876b
md"_Aula 3, 1º Sem 2024, version 1_"

# ╔═╡ d07fcdb0-7afc-4a25-b68a-49fd1e3405e7
PlutoUI.TableOfContents(title="Índice", aside=true)

# ╔═╡ 9b49500c-0164-4556-a17b-7595e35c5ede
md"""
#### Inicializando os pacotes

_Lembre que quando você executa esse caderno pela primeira vez, ele pode levar um tempo para instalar pacotes e baixar arquivos da Internet. Em casos extremos isso pode levar até 15 minutos. Tenha paciência!_
"""

# ╔═╡ ca1b507e-6017-11eb-34e6-6b85cd189002
md"""
# Imagens como um exemplo de dados que estão por todo lado

Bem vindos ao Laboratório de Computação Científica usando Julia. Esse é um curso baseado no _Computational Thinking using Julia for Real-World Problems_ do MIT com uma pitada pessoal.

O objetivo do curso é unir conceitos de Ciência da Computação e Matemática Aplicada com código escrito em linguagem moderna e ágil chamada **Julia**. Vamos então usar essas ideias em um curso no estilo "mãos à obra" olhando para aplicações interessantes e procurando nos divertir no processo.

Com isso, buscamos levar as pessoas interessadas em Matemática Aplicada e Computação Científica a aprender um pouco mais de Ciência da Computação e vice-versa. Vamos ainda introduzir uma linguagem que traz novos conceitos e uma abordagem interessante para a Computação Científica. Então aqui vamos nós, buscar aprender um pouco de tudo, exprimindo-se por código.
"""

# ╔═╡ 9111db10-6bc3-11eb-38e5-cf3f58536914
md"""
## O que é computação científica?
"""

# ╔═╡ fb8a99ac-6bc1-11eb-0835-3146734a1c99
md"""
Aplicações de computação no mundo real usam **dados**, isto é, informações que podemos **medir** de alguma forma. Esses dados podem ser de vários tipos, como:

- Números que variam no tempo (**séries temporais**):
  - Preços de ações por segundo / minuto / dia;
  - Número diário / semanal de novos casos de uma epidemia;
  - Temperatura global média por mês.

- Vídeo:
  - A visão da câmera de um carro autônomo;
  - As imagens de uma câmera de segurança;
  - Ultrassom: um exame pré-natal, por exemplo.

- Imagens:
  - Imagens de exames médicos com exemplos de tecidos sadios e doentes;
  - Fotos do seu animal de estimação.
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
Para usar uma fonte de dados, precisamos entrar com essa informação no computador.  Por exemplo, baixando informação da Internet e lendo o arquivo obtido. Os dados devem ser convertidos em uma forma que facilite as manipulações que desejamos fazer. Eles são então **processados** para obtermos a informação desejada. Muitas vezes, também, desejamos **visualizar** a informação obtida e **armazená-la**.

Tipicamente o processamento está baseado em algum **modelo matemático** ou computacional que nos ajuda a entender os dados e extrair a informação de interesse.

>O objetivo desse curso é usar programação, Ciência da computação e Matemática Aplicada para nos ajudar a atingir esses objetivos.
"""

# ╔═╡ 132f6596-6bc6-11eb-29f1-1b2478c929af
md"""
# Dados: Imagens como um exemplo de dados que estão por todo lado

Vamos começar visualizando **imagens** e aprendendo como processá-las. Nosso objetivo é processar e/ou extrair a informações presentes na imagem. Isso pode ser feito utilizando **algoritmos** específicos.

Deixo aqui um vídeo do 3Blue-1Brown (Grant Sanderson) apresentando uma pequena variação dessa aula na versão original do curso oferecida no MIT no outono 2020. Pois é, não dá para concorrer...
"""

# ╔═╡ 635a03dd-abd7-49c8-a3d2-e68c7d83cc9b
html"""
<div notthestyle="position: relative; right: 0; top: 0; z-index: 300;"><iframe src="https://www.youtube.com/embed/DGojI9xcCfg" width=400 height=250  frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div>
"""

# ╔═╡ 9eb6efd2-6018-11eb-2db8-c3ce41d9e337
md"""
Ao abrir uma imagem no computador e ampliar, iremos ver que elas são armazenadas como uma matriz de pequenos quadrados chamados de **píxeis** (que vem do inglês "picture elements"). Cada píxel é preenchido com uma cor única. Eles são então organizados em uma grade retangular bidimensional.

Como tudo no computador, essas cores são representadas por números. Nesse caso, usamos o formato RGB (níveis de cor em três canais, representáveis numericamente, de cores de tom vermelho (Red), verde (Green) e azul (Blue)). Essas cores vem do fato que o olho humano possui três [cones fotorreceptores](https://en.wikipedia.org/wiki/Cone_cell): tecidos especiais que funcionam como receptor de luz e que são sensíveis, aproximadamente, a essas três frequências. 

Lembrem-se que imagens no computador são apenas representações **aproximadas** da realidade. Elas são discretas e bidimensionais e tentam capturar uma realidade tridimensional e contínua.
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
Passo 1: (da Internet) devemos definir um URL (endereço web) de onde baixar:

>Obs: Pluto coloca o resultado antes do código que os gera porque o seu desenvolvedor considera que a saída é mais interessante (ou importante) que o código. Isso pode exigir um tempo de adaptação, principalmente para quem está acostumado com Jupyter.
"""

# ╔═╡ 34ee0954-601e-11eb-1912-97dc2937fd52
url = "https://www.ime.unicamp.br/~pjssilva/images/ensino/labcompsci/apolo1.png"

# ╔═╡ 9180fbcc-601e-11eb-0c22-c920dc7ee9a9
md"""
Passo 2: Agora podemos usar a função `download` (essa é fácil de lembrar!) para baixar o arquivo de imagem no computador. (Apolo era o cachorro SRD de casa, ele faleceu no segundo semestre de 2023. Que saudades!)
"""

# ╔═╡ 34ffc3d8-601e-11eb-161c-6f9a07c5fd78
apolo_filename = download(url) # Baixa para um arquivo local, retornando o nome do arquivo onde ele foi armazenado.

# ╔═╡ abaaa980-601e-11eb-0f71-8ff02269b775
md"""
Passo 3:

Usando o pacote `Images.jl` (carregado lá no topo desse caderno, dê uma olhada) podemos **carregar** o arquivo na memória. Isso o transforma automaticamente em uma categoria de dado que a linguagem consegue manipular. Armazenamos essa informação em uma variável. (Lembre que o código aparece depois da saída.)
"""

# ╔═╡ aafe76a6-601e-11eb-1ff5-01885c5238da
apolo = load(apolo_filename)

# ╔═╡ e86ed944-ee05-11ea-3e0f-d70fc73b789c
md"_Oi, Apolo!_ 🤩️"

# ╔═╡ c99d2aa8-601e-11eb-3469-497a246db17c
md"""
O caderno Pluto reconheceu e apresentou o objeto que representa a imagem do Apolo. Ele será usado com exemplo nesse curso algumas vezes, substituindo o corgi do professor Edelman, um dos autores originais deste caderno.

Pobre Apolo, ele vai ter que passar por várias "transformações" ao longo de nosso curso!
"""

# ╔═╡ 11dff4ce-6bca-11eb-1056-c1345c796ed4
md"""
- Exercício : troque a URL para uma outra imagem na Internet.
- Exercício: adapte o código para usar outro arquivo de imagem que já esteja em seu computador.
"""

# ╔═╡ efef3a32-6bc9-11eb-17e9-dd2171be9c21
md"""
## Capturando uma imagem de sua webcam
"""

# ╔═╡ e94dcc62-6d4e-11eb-3d53-ff9878f0091e
md"""
Outra possibilidade divertida é capturar uma imagem usando a webcam de seu computador. Tente selecionar o botão abaixo e dê permissão para o caderno acessar a sua webcam (ele está rodando em sua máquina). Depois basta selecionar o botão da câmera para captar imagens. Você pode até pressionar várias vezes o botão e ver que a imagem capturada se move junto. Tudo em tempo real.
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
A primeira coisa que vamos fazer é pegar o tamanho da imagem:
"""

# ╔═╡ 75c5c85a-602c-11eb-2fb1-f7e7f2c5d04b
apolo_size = size(apolo)

# ╔═╡ 77f93eb8-602c-11eb-1f38-efa56cc93ca5
md"""
Julia retorna dois números. Eles representam a altura e a largura da imagem, ou seja, o número de píxeis na vertical e na horizontal respectivamente.
"""

# ╔═╡ 96b7d801-c427-4e27-ab1f-e2fd18fc24d0
apolo_height = apolo_size[1]

# ╔═╡ f08d02af-6e38-4ace-8b11-7af4930b64ea
apolo_width = apolo_size[2]

# ╔═╡ f9244264-64c6-11eb-23a6-cfa76f8aff6d
md"""
### Indexando para selecionar posições na imagem

De uma forma geral, você pode imaginar que a imagem é uma matriz que contem píxeis com valores RGB. Assim a forma natural de selecionar porções da imagem, ou um píxel específico, é usar indexação. A ideia é que você passe as coordenadas definindo qual linha e coluna quer selecionar. Isso é feito em Julia usando colchetes `[` e `]`.
"""

# ╔═╡ bd22d09a-64c7-11eb-146f-67733b8be241
a_pixel = apolo[400, 600]

# ╔═╡ 28860d48-64c8-11eb-240f-e1232b3638df
md"""
Vemos que Julia nos mostra um bloco de cor sólida como representação de um píxel.

Lembrando, o primeiro número representa a *linha* na imagem, começando do topo e descendo. Já o segundo é a coluna na imagem, da esquerda para direita. Em Julia os índices começam em 1, diferente de outras linguagens em que os índices começam no 0.
"""

# ╔═╡ a510fc33-406e-4fb5-be83-9e4b5578717c
md"""
É claro que podemos usar variáveis no lugar dos índices.
"""

# ╔═╡ 13844ebf-52c4-47e9-bda4-106a02fad9d7
md"""
...e para fazer tudo mais divertido essas variáveis podem ser controladas por _sliders_!
"""

# ╔═╡ 08d61afb-c641-4aa9-b995-2552af89f3b8
@bind row_i Slider(1:apolo_height, show_value=true)

# ╔═╡ 6511a498-7ac9-445b-9c15-ec02d09783fe
@bind col_i Slider(1:apolo_width, show_value=true)

# ╔═╡ 94b77934-713e-11eb-18cf-c5dc5e7afc5b
row_i, col_i

# ╔═╡ ff762861-b186-4eb0-9582-0ce66ca10f60
apolo[row_i, col_i]

# ╔═╡ c9ed950c-dcd9-4296-a431-ee0f36d5b557
md"""
### Regiões em uma imagem: faixas de índices

Vemos que ao usar um valor para a linha e outro para coluna conseguimos selecionar um píxel individual na imagem. Agora vamos pegar uma faixa inteira de índices. Em Julia é possível selecionar múltiplas linhas e colunas de uma matriz obtendo uma nova matriz que representa a região selecionada:
"""

# ╔═╡ f0796032-8105-4f6d-b5ee-3647b052f2f6
apolo[550:650, 1:apolo_width] # You can use 'end' instead of apolo_width

# ╔═╡ b9be8761-a9c9-49eb-ba1b-527d12097362
md"""
Nesse caso, usamos `a:b` para representar _todos os números de `a` até `b`_ (incluindo os extremos). Por exemplo:

"""

# ╔═╡ d515286b-4ad4-449b-8967-06b9b4c87684
collect(2:10)

# ╔═╡ eef8fbc8-8887-4628-8ba8-114575d6b91f
md"""

Se usar apenas `:` Julia vai entender que você quer _todos os índices_. Isso pode simplificar um pouco a expressão acima.
"""

# ╔═╡ 4e6a31d6-1ef8-4a69-b346-ad58cfc4d8a5
apolo[550:650, :]

# ╔═╡ e11f0e47-02d9-48a6-9b1a-e313c18db129
md"""
Podemos também selecionar uma única linha ou coluna.
"""

# ╔═╡ 9e447eab-14b6-45d8-83ab-1f7f1f1c70d2
apolo[:, 500]

# ╔═╡ c926435c-c648-419c-9951-ac8a1d4f3b92
apolo_head = apolo[50:380, 100:480]

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

Agora que já sabemos como armazenar e manipular a imagem, podemos começar a **processá-la** para extrair informações e/ou modificá-la de alguma forma.

Podemos, por exemplo, querer identificar objetos na imagem como um tumor numa imagem médica. Para sermos capazes de atingir esse tipo de objetivo de alto nível, precisamos saber inicialmente fazer coisas mais simples, como detectar arestas ou selecionar objetos de acordo com sua cor. Essas operações podem, por sua vez, ser reduzidas a operações ainda mais elementares como comparar a cor de píxeis vizinhos ou decidir se eles são suficientemente "distintos".
"""

# ╔═╡ 4504577c-64c8-11eb-343b-3369b6d10d8b
md"""
## Representando cores

Uma primeira tarefa que iremos experimentar é *modificar* a cor de um píxel. Para conseguir isso, precisamos ver com mais cuidado como essas cores são representadas.

Cores são, no fundo, um conceito complexo que mistura as propriedades físicas (a frequência do feixe de luz), biológicas (quais cores os cones de luz que temos nos nossos olhos são capazes de captar) e até os processos cerebrais que traduzem os sinais adquiridos na nossa concepção mental de cor.

Mas aqui nós vamos ignorar esses nuances e iremos no ater ao método padrão de presentar as cores como uma **tripla RGB**. Cada cor é representada por três números $(r, g, b)$ que capturam "quanto" vermelho, verde e azul uma tom possui. Esses são números reais entre 0 (representando _ausência_) e 1 (representado _totalidade_). A cor final que percebemos vem justamente de misturarmos essas três informações em nosso cérebro. Isso tudo é fascinante, mas não iremos ver os detalhes aqui.
"""

# ╔═╡ 40886d36-64c9-11eb-3c69-4b68673a6dde
md"""
A maneira mais simples de criar um cor em Julia é usar:
"""

# ╔═╡ 552235ec-64c9-11eb-1f7f-f76da2818cb3
RGB(1.0, 0.0, 0.0)

# ╔═╡ 393a4a57-967d-4d01-985e-4247725acae1


# ╔═╡ c2907d1a-47b1-4634-8669-a68022706861
begin
    md"""
    Já um píxel com $(@bind test_r Scrubbable(0:0.1:1; default=0.1)) de vermelho, $(@bind test_g Scrubbable(0:0.1:1; default=0.5)) de verde e $(@bind test_b Scrubbable(0:0.1:1; default=1.0)) de azul tem a seguinte cor:
    """
end


# ╔═╡ ff9eea3f-cab0-4030-8337-f519b94316c5
RGB(test_r, test_g, test_b)

# ╔═╡ f6cc03a0-ee07-11ea-17d8-013991514d42
md"""
#### Exercício 1.1
👉 Escreva uma função `invert` que inverte uma cor, ou seja, leva $(r, g, b)$ em $(1 - r, 1-g, 1-b)$.

!!! hint
    A função `fieldnames` recebe um tipo e devolve o nome dos campos disponíveis.
"""

# ╔═╡ 63e8d636-ee0b-11ea-173d-bd3327347d55
function invert(color::AbstractRGB)

    return missing
end

# ╔═╡ 2cc2f84e-ee0d-11ea-373b-e7ad3204bb00
md"Vamos inverter algumas cores:"

# ╔═╡ b8f26960-ee0a-11ea-05b9-3f4bc1099050
black = RGB(0.0, 0.0, 0.0)

# ╔═╡ 5de3a22e-ee0b-11ea-230f-35df4ca3c96d
invert(black)

# ╔═╡ 4e21e0c4-ee0b-11ea-3d65-b311ae3f98e9
red = RGB(0.8, 0.1, 0.1)

# ╔═╡ 6dbf67ce-ee0b-11ea-3b71-abc05a64dc43
invert(red)

# ╔═╡ 846b1330-ee0b-11ea-3579-7d90fafd7290
md"Você é capaz inverter a imagem do Apolo?"

# ╔═╡ 943103e2-ee0b-11ea-33aa-75a8a1529931
apolo_inverted = missing

# ╔═╡ 2ee543b2-64d6-11eb-3c39-c5660141787e
md"""

## Modificando um píxel

Vamos começar pensando como modificar uma imagem, por exemplo para esconder alguma informação sensível: a famosa tarja preta.

Podemos fazer isso trocando a cor de um píxel:
"""

# ╔═╡ 53bad296-4c7b-471f-b481-0e9423a9288a
let
    temp = copy(apolo_head)
    temp[40, 100] = RGB(0.0, 0.0, 1.0)
    temp
end

# ╔═╡ 81b88cbe-64c9-11eb-3b26-39011efb2089
md"""
**Cuidado: O código acima, de fato, *modificou* a imagem armazenada na variável `temp` mesmo que não consigamos ver a modificação já que um único píxel foi alterado. Por isso mesmo que a imagem original, `apolo_head`, foi copiada antes da modificação.**
"""

# ╔═╡ ab9af0f6-64c9-11eb-13d3-5dbdb75a69a7
md"""
## Grupos de píxeis

Nós podemos ter também o interesse de examinar e modificar vários píxeis de uma vez. Por exemplo, vamos extrair uma faixa horizontal com um píxel de altura:
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
E, de forma análoga, modificamos um bloco retangular de píxeis:
"""

# ╔═╡ 1bd53326-d705-4d1a-bf8f-5d7f2a4e696f
let
    temp = copy(apolo_head)
    temp[100:180, 100:200] .= RGB(0.0, 0.0, 1.0)
    temp
end

# ╔═╡ 7d9fd32a-7d36-4674-9b1f-8e2758a314b9
md"**Obs: Note que acima pode parecer que modificamos a mesma variável `temp` três vezes. Mas ao olhar a saída e lembrar que Pluto é reativo, vemos que não deve ser bem assim. Isso ocorreu porque usamos blocos `let`. Variáveis criadas dentro de blocos `let` são locais ao bloco, não existindo fora dele. Assim todas as variáveis `temp` são independentes entre si.**"

# ╔═╡ a5f8bafe-edf0-11ea-0da3-3330861ae43a
md"""
#### Exercício 1.2

👉 Gere um vetor de 100 zeros e altere os 20 elementos centrais para 1.
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
Podemos também querer reduzir o tamanho da imagem, já que ela é um pouco grande. Para isso uma ideia simples é pegar um píxel a cada 10 linhas e 10 colunas e gerar uma nova imagem com o resultado.
"""

# ╔═╡ ae542fe4-64cc-11eb-29fc-73b7a66314a9
reduced_image = apolo[1:10:end, 1:10:end]

# ╔═╡ c29292b8-64cc-11eb-28db-b52c46e865e6
md"""
Observando com calma a imagem não parece tão boa, ela perdeu muitos detalhes.

#### Exercício

> Tente pensar como seria possível reduzir a imagem sem perder tanto detalhe.
"""

# ╔═╡ 5319c03c-64cc-11eb-0743-a1612476e2d3
md"""
# Saída: Gravando uma imagem em arquivo

Finamente, nós podemos querer gravar nossa nova criação em um arquivo. Para isso, você pode **apertar o botão direito** do mouse sobre uma imagem e salvá-la para um arquivo. Mas você também pode querer salvar a imagem usado Julia. Basta usar a função `save` que recebe o nome do arquivo destino e a imagem a ser guardada.
"""

# ╔═╡ 3db09d92-64cc-11eb-0333-45193c0fd1fe
save("reduced_apolo.png", reduced_image)

# ╔═╡ dd183eca-6018-11eb-2a83-2fcaeea62942
md"""
# Ciência da computação: arrays

Uma imagem é um exemplo concreto de uma ideia geral e fundamental em computação, o **array**.

Ela é uma malha retangular em que cada elemento contém uma cor. Um array é uma malha indexada por um, ou mais valores, usada para armazenar dados de um _único tipo_. Os dados são armazenados e recuperados usando índices, exatamente como no exemplo das imagens: cada célula da malha pode armazenar uma "única unidade" de um certo tipo.

## Dimensão de um array

OK, isso é um pouco confuso para um matemático. Mas em programação chamamos de dimensão de um array o número de eixos que usamos na indexação. Assim, o que costumamos de chamar de vetor teria dimensão **um**. Já uma matriz tem duas dimensões. É possível criar arrays com mais de duas dimensões, que em Matemática levaria a tensores. Além da dimensão (número de eixos), precisamos definir o comprimento de cada eixo e quais são de fato os índices que podem ser usados. Em Julia a convenção é que os índices começam em 1 e vão até o comprimento daquele eixo. Mas é também possível definir outras indexações se isso for estritamente necessário.

## Arrays como estrutura dados

Arrays são um exemplo simples de **estruturas de dados**. Elas são formas de armazenar dados e acessá-los. Diferentes estruturas de dados podem ser usada em diferentes situações. O importante é usar a estrutura adequada, que é aquela que facilita as manipulações que você deseja fazer com os dados. Por exemplo, arrays são ótimos para acessar qualquer porção dos dados com posição conhecida. Mas eles já não são tão bons se desejamos procurar uma informação.

Os arrays tem essa noção de posição que os torna naturais na representação de informação que tem estrutura posicional, como as imagens. Em imagens porções distintas de um mesmo objeto estão próximas (como o piso ou o nariz do Apolo). Dessa forma, podemos esperar que píxeis próximos tenham cores semelhantes e quando isso não ocorre podemos imaginar que estamos "trocando" de objetos e encontrando uma fronteira, uma aresta de um novo objeto. Essa estrutura será aproveitada nas próximas aulas.
"""

# ╔═╡ 8ddcb286-602a-11eb-3ae0-07d3c77a0f8c
md"""
# Julia: construindo arrays

## Criando vetores e matrices
Julia lida muito bem com arrays de qualquer dimensão.

Vetores, que são arrays uni-dimensionais, podem ser criados usando uma notação com colchetes e vírgulas:
"""

# ╔═╡ f4b0aa23-2d76-4d88-b2a4-3807e88d27ce
[1, 20, "hello"]

# ╔═╡ 1b2b2b18-64d4-11eb-2d43-e31cb8bc25d1
[RGB(1, 0, 0), RGB(0, 1, 0), RGB(0, 0, 1)]

# ╔═╡ 2b0e6450-64d4-11eb-182b-ff1bd515b56f
md"""
Já matrizes, que são bidimensionais, também usam colchetes. Mas nelas elementos de uma mesma linha são separados por espaços e as linhas em si por quebra de linha ou ponto-e-vírgula:
"""

# ╔═╡ 3b2b041a-64d4-11eb-31dd-47d7321ee909
[
    RGB(1, 0, 0) RGB(0, 1, 0)
    RGB(0, 0, 1) RGB(0.5, 0.5, 0.5)
]

# ╔═╡ 0f35603a-64d4-11eb-3baf-4fef06d82daa
md"""

## Compreensões de arrays

Quando queremos criar arrays com mais de um punhado de elementos, já não é tão prático usar a notação acima que exige escrever explicitamente cada elemento . Uma forma de *automatizar* esse processo e criar o novo array seguindo algum tipo de padrão. Por exemplo, podemos querer criar um gradiente de cores.

Para isso vamos interpolar linearmente entre dois valores. No exemplo abaixo o valor inicial seria o `RGB(0, 0, 0)`, que representa o preto, e o final o vermelho, `RGB(1, 0, 0)`. Como apenas um valor está mudando (ou mais formalmente os valores estão mudando em uma direção específica), é possível armazenar o resultado num vetor.

Uma forma espera de fazer isso é usar uma **compreensão de array**, que é criar um novo array a partir de uma modificação de elementos de um outro array (ou iterador).

Vejamos o exemplo:
"""

# ╔═╡ e69b02c6-64d6-11eb-02f1-21c4fb5d1043
[RGB(x, 0, 0) for x = 0:0.1:1]

# ╔═╡ fce76132-64d6-11eb-259d-b130038bbae6
md"""
Nele, `0:0.1:1` é um **range** (uma faixa de números). O primeiro valor diz onde a faixa começa, o último onde termina e o do meio, quando existir, o passo que deve ser dado entre os números.
"""

# ╔═╡ 17a69736-64d7-11eb-2c6c-eb5ebf51b285
md"""
Podemos criar de maneira similar matrizes, usamos aqui um `for` que percorre dois ranges, o primeiro variando as linhas e o segundo as colunas. Os dois ranges devem ser separados por vírgula (`,`). No lugar dos ranges, podem estar outros objetos que sabemos percorrer, como vetores ou mesmo (uma única) matriz.
"""

# ╔═╡ 291b04de-64d7-11eb-1ee0-d998dccb998c
[RGB(i, j, 0) for i = 0:0.1:1, j = 0:0.1:1]

# ╔═╡ 647fddf2-60ee-11eb-124d-5356c7014c3b
md"""
## Concatenando matrizes

Para concatenar matrizes podemos usar a justaposição usando uma sintaxe semelhante à criação de arrays:
"""

# ╔═╡ 7d9ad134-60ee-11eb-1b2a-a7d63f3a7a2d
[apolo_head apolo_head]

# ╔═╡ 8433b862-60ee-11eb-0cfc-add2b72997dc
[
    apolo_head reverse(apolo_head, dims=2)
    reverse(apolo_head, dims=1) rot180(apolo_head)
]

# ╔═╡ 5e52d12e-64d7-11eb-0905-c9038a404e24
md"""
# Pluto: Iteratividade usando _sliders_
"""

# ╔═╡ 6aba7e62-64d7-11eb-2c49-7944e9e2b94b
md"""
Pluto tem algumas ferramentas para criar cadernos com iteratividade sem que o leitor precise alterar código.

Por exemplo, suponha que queremos ver o efeito de alterar um valor, digamos o número de tons de vermelho que usaremos no nosso gradiente. É claro que isso pode ser feito ajustando o passo no `range`.

Mas Pluto nos permite também associar o valor de uma variável à posição de um slider (vimos outros exemplos durante a aula) e usar isso para definir o número de tons de vermelho que veremos no resultado.

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
Obs: O tipo `Slider` é definido no pacote `PlutoUI.jl` que foi carregado no topo do caderno.
"""

# ╔═╡ cfc55140-64d7-11eb-0ff6-e59c70d01d67
md"""
Isso cria uma nova variável chamada `number_reds` cujo valor é obtido a partir do valor que está no slider. Ao mover o slider, alteramos o valor e a variável tem seu conteúdo atualizado. Isso ocorre em tempo real, devido à **reatividade** de Pluto. Todas as células do caderno que usam esse valor são alteradas! Tudo ocorre automaticamente sem que nós precisemos intervir.
"""

# ╔═╡ fca72490-64d7-11eb-1464-f5e0582c4d18
md"""
Aqui está o código que gera o gradiente a partir do número de tons de vermelhos que é definido pelo slider. Notem que preto vai estar sempre lá.
"""

# ╔═╡ 88933746-6028-11eb-32de-13eb6ff43e29
[RGB(red_value / number_reds, 0, 0) for red_value = 0:number_reds]

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
Vamos resumir as principais ideias desse caderno:

- Imagens são como **arrays** (mais precisamente matrizes) de cores.
- Podemos acessar e modificar arrays usando **índices**.
- Podemos criar arrays explicitamente ou através de funções ou usando **compreensões de arrays**.
"""

# ╔═╡ 45815734-ee0a-11ea-2982-595e1fc0e7b1
md"# Apêndice"

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
still_missing(text=md"Substitua `missing` com sua resposta.") =
    Markdown.MD(Markdown.Admonition("aviso", "Vamos lá!", [text]))

# ╔═╡ e08ecb84-601b-11eb-0e25-152ed3a262f7
keep_working(text=md"The answer is not quite right.") =
    Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))

# ╔═╡ e09036a4-601b-11eb-1a8b-ef70105ab91c
yays = [
    md"Ótimo!",
    md"Oba ❤",
    md"Muito bom! 🎉",
    md"Bom trabalho!",
    md"Continue assim!",
    md"Perfeito!",
    md"Incrível!",
    md"Você acertou!",
    md"Podemos continuar para a próxima seção.",
]

# ╔═╡ e09af1a2-601b-11eb-14c8-57a46546f6ce
correct(text=rand(yays)) =
    Markdown.MD(Markdown.Admonition("correto", "Você entendeu!", [text]))

# ╔═╡ e0a4fc10-601b-11eb-211d-03570aca2726
not_defined(variable_name) = Markdown.MD(
    Markdown.Admonition(
        "perigo",
        "Ooppss!",
        [
            md"Verifique que você definiu uma variável chamada **$(Markdown.Code(string(variable_name)))**",
        ],
    ),
)

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
        elseif result[[1, 50, 100]] != [0, 1, 0]
            keep_working()
        else
            correct()
        end
    end
end

# ╔═╡ e0a6031c-601b-11eb-27a5-65140dd92897
bigbreak = html"<br><br><br><br><br>";

# ╔═╡ e0b15582-601b-11eb-26d6-bbf708933bc8
function camera_input(; max_size=150, default_url="https://i.imgur.com/SUmi94P.png")
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
    myface1 myface1[:, end:-1:1]
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
exercise(x, number="") = @htl("""
                          <ct-exercise class="exercise">
                          <h4>Exercise <span>$(number)</span></h4>
                          <section>$(x)
                          </section>
                          </ct-exercise>
                          """)

# ╔═╡ a9fef6c9-e911-4d8c-b141-a4832b40a260
quick_question(x, number, options, correct) =
    let
        name = join(rand('a':'z', 16))
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

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ColorVectorSpace = "c3611d14-8923-5661-9e6a-0046d554d3a4"
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
ImageIO = "82e4d734-157c-48bb-816b-45c225c6df19"
ImageShow = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
PlotlyBase = "a03496cd-edff-5a9b-9e67-9cda94a718b5"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
ColorVectorSpace = "~0.10.0"
Colors = "~0.12.10"
FileIO = "~1.16.3"
HypertextLiteral = "~0.9.5"
ImageIO = "~0.6.7"
ImageShow = "~0.3.8"
PlotlyBase = "~0.8.19"
PlutoUI = "~0.7.58"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.2"
manifest_format = "2.0"
project_hash = "df8fcdb2b0a1ac0ac103f15d110f06b22ba55408"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "0f748c81756f2e5e6854298f11ad8b2dfae6911a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.0"

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

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

    [deps.ColorVectorSpace.weakdeps]
    SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

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

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "0f4b5d62a88d8f59003e43c25a8a90de9eb76317"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.18"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

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
git-tree-sha1 = "82d8afa92ecf4b52d78d869f038ebfb881267322"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.3"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

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

[[deps.IterTools]]
git-tree-sha1 = "42d5f897009e7ff2cf88db414a389e5ed1bdd023"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.10.0"

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

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

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

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

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
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "a4ca623df1ae99d09bc9868b008262d0c0ac1e4f"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.4+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "67186a2bc9a90f9f85ff3cc8277868961fb57cbd"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.4.3"

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

[[deps.PlotlyBase]]
deps = ["ColorSchemes", "Dates", "DelimitedFiles", "DocStringExtensions", "JSON", "LaTeXStrings", "Logging", "Parameters", "Pkg", "REPL", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "56baf69781fc5e61607c3e46227ab17f7040ffa2"
uuid = "a03496cd-edff-5a9b-9e67-9cda94a718b5"
version = "0.8.19"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "71a22244e352aa8c5f0f2adde4150f62368a3f2e"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.58"

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

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

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
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "34cc045dd0aaa59b8bbe86c644679bc57f1d5bd0"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.6.8"

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

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
# ╟─75b96e8c-fa48-4b78-a7dc-587a676f04e2
# ╟─edf900be-601b-11eb-0456-3f7cfc5e876b
# ╟─d07fcdb0-7afc-4a25-b68a-49fd1e3405e7
# ╟─9b49500c-0164-4556-a17b-7595e35c5ede
# ╠═74b008f6-ed6b-11ea-291f-b3791d6d1b35
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
# ╟─e11f0e47-02d9-48a6-9b1a-e313c18db129
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
# ╠═393a4a57-967d-4d01-985e-4247725acae1
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
# ╟─7d9fd32a-7d36-4674-9b1f-8e2758a314b9
# ╟─a5f8bafe-edf0-11ea-0da3-3330861ae43a
# ╠═b6b65b94-edf0-11ea-3686-fbff0ff53d08
# ╟─d862fb16-edf1-11ea-36ec-615d521e6bc0
# ╟─e3394c8a-edf0-11ea-1bb8-619f7abb6881
# ╟─693af19c-64cc-11eb-31f3-57ab2fbae597
# ╟─6361d102-64cc-11eb-31b7-fb631b632040
# ╠═ae542fe4-64cc-11eb-29fc-73b7a66314a9
# ╟─c29292b8-64cc-11eb-28db-b52c46e865e6
# ╟─5319c03c-64cc-11eb-0743-a1612476e2d3
# ╠═3db09d92-64cc-11eb-0333-45193c0fd1fe
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
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
