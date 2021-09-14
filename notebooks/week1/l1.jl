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

# ╔═╡ 29dfe3d6-c353-4081-8192-b12f374bf702
filter!(LOAD_PATH) do path
    path != "@v#.#"
end;

# ╔═╡ 65780f00-ed6b-11ea-1ecf-8b35523a7ac0
begin
    import ImageMagick
    using Images
    using PlutoUI
    using HypertextLiteral
end

# ╔═╡ ac8ff080-ed61-11ea-3650-d9df06123e1f
md"""

# **Lista 1** - _imagens and arrays_
`MS905`, 2º sem. 2021

`Data de entrega`: 24, 2021 às 08:00 da manhã**

Este caderno contem _verificações ativas das respostas_! Em alguns exercícios você verá uma caixa colorida que roda alguns casos de teste e provê retorno imediato para a sua solução. Edite sua solução, execute a célula e verifique se passou na verificação. Note que a verificação feita é simples. Para a correção serão verificados mais casos e você tem a obrigação de escrever código que funcione adequadamente.

Pergunte o quanto quiser (uso o fórum do Mooddle)!
"""

# ╔═╡ 911ccbce-ed68-11ea-3606-0384e7580d7c
# edite o código abaixo com seu nome e email da dac (sem o @dac.unicamp.br)

student = (name = "João Ninguém", email_dac = "j000000")

# aperte o botão ▶ no canto inferior direito da célula para executar o que você
# editou, ou use Shift+Enter

# Agora siga na página para ver o que deve fazer.

# ╔═╡ 8ef13896-ed68-11ea-160b-3550eeabbd7d
md"""

Submetido por: **_$(student.name)_** ($(student.email_dac)@dac.unicamp.br)
"""

# ╔═╡ 5f95e01a-ee0a-11ea-030c-9dba276aba92
md"""
#### Iniciando pacotes

_Quando você rodar esse notebook pela primeira vez, pode levar até 15 minutos instalando pacotes. Aguente firme!_
"""

# ╔═╡ 540ccfcc-ee0a-11ea-15dc-4f8120063397
md"""
## **Exercício 1** - _Manipulando vetores ("imagens" 1D)_

Um `Vector` (vetor) é um array 1D. Se quiser pense neles como uma "imagem" 1d.

"""

# ╔═╡ 467856dc-eded-11ea-0f83-13d939021ef3
example_vector = [0.5, 0.4, 0.3, 0.2, 0.1, 0.0, 0.7, 0.0, 0.7, 0.9]

# ╔═╡ ad6a33b0-eded-11ea-324c-cfabfd658b56
md"""
#### Exericício 1.1
👉 Crie um vetor chamado `random_vect` de comprimento 10 usando a função `rand`. Você pode olhar a definição dessa função usando o sistema de ajuda do Pluto.
"""

# ╔═╡ f51333a6-eded-11ea-34e6-bfbb3a69bcb0
random_vect = missing # replace `missing` with your code!

# ╔═╡ 5da8cbe8-eded-11ea-2e43-c5b7cc71e133
begin
    colored_line(x::Vector) = hcat(Gray.(Float64.(x)))'
    colored_line(x::Any) = nothing
end

# ╔═╡ 56ced344-eded-11ea-3e81-3936e9ad5777
colored_line(example_vector)

# ╔═╡ b18e2c54-edf1-11ea-0cbf-85946d64b6a2
colored_line(random_vect)

# ╔═╡ 77adb065-bfd4-4680-9c2a-ad4d92689dbf
md"#### Exercício 1.2
👉 Faça um função `my_sum`, usando um laço `for`, que calcula a soma total de um vetor de números."

# ╔═╡ bd907ee1-5253-4cae-b5a5-267dac24362a
function my_sum(xs)
    # seu código aqui!
    return missing
end

# ╔═╡ 6640110a-d171-4b32-8d12-26979a36b718
my_sum([1, 2, 3])

# ╔═╡ cf738088-eded-11ea-2915-61735c2aa990
md"#### Exercício 1.3
👉 Use sua função `my_sum` para escrever uma função `mean`, que calcula a média (aritmética) de um vetor de números."

# ╔═╡ 0ffa8354-edee-11ea-2883-9d5bfea4a236
function mean(xs)
    # seu código aqui!
    return missing
end

# ╔═╡ 1f104ce4-ee0e-11ea-2029-1d9c817175af
mean([1, 2, 3])

# ╔═╡ 1f229ca4-edee-11ea-2c56-bb00cc6ea53c
md"👉 Defina `m` como a média de `random_vect`."

# ╔═╡ 2a391708-edee-11ea-124e-d14698171b68
m = missing # substitua `missing` com seu código!

# ╔═╡ e2863d4c-edef-11ea-1d67-332ddca03cc4
md"""#### Exercício 1.4
👉 Escreva uma função `demean`, que recebe um vetor `xs` e subtrai de cada um dos seus elementos a sua média. Use sua função `mean`!
"""

# ╔═╡ ea8d92f8-159c-4161-8c54-bab7bc00f290
md"""
> ### Nota sobre _mutabilidade_
>
> Há duas formas de se pensar nesse exercício, uma é _modificar_ o vetor original e outra é criar um _novo vetor_ com a respota. Nós vamos, em geral, preferir a segunda opção para que os dados originais sejam preservados. Variantes que mudam o vetor original devem ser usadas apenas quando performance ou memória são importante. Isso porque esse tipo de solução deve ser escrita e usada com mais cuidado. **De uma maneira geral siga a regra: otimize somente se tiver certeza que precisa**. Há um ditato em computação: _A mãe de todos os males é a otimização prematura_. Isso é particularmente importante se você ainda não está bem familiarizado com a linguagem.
>
> Há também uma convenção interessante entre os programadores Julia. Funções que modificam os seus argumentos devem ter o nome terminado com um ponto de exclamação, como um lembrete para tomar cuidado, já que os dados não são preservados. Por exemplo, a função `sort(x)` não modifica o vetor de entrada, mas devolve uma cópia dele ordenada. Já `sort!(x)` ordena o próprio vetor de entrada, modificando-o.
>
> #### Dicas para escrever código "não-mutável".
> 1. _Reescrever_ uma função que altera seus parâmetros (mutável) em uma função que preserva os seus parâmetros pode parece algo tedioso e ineficiente. Muitas vezes é melhor encarar o que você está fazendo como a criação algo novo e não como a modificação de algo existente. Isso o colocará numa situação de achar o seu trabalho mais proveitoso e deixará os passos que deve seguir mais claros.
>
> 1. Um alternativa simples para transformar uma função que altera os parâmetros em uma que não altera é envolvê-la em uma outra função que inicia copiando o(s) parâmetro(s) que será(ão) alterado(s) e depois chamar a função que altera parâmetros com a(s) cópia(s).
>
>Julia oferece algumas construções insteressantes que podem substituir laços for e ainda deixar o código mais claro. Um bom exemplo é a [sintaxe de difusão com o operador ponto](https://docs.julialang.org/en/v1/manual/functions/#man-vectorized) (veja também [operadores matemáticos](https://docs.julialang.org/en/v1/manual/mathematical-operations/#man-dot-operators)), e os padrões [map e filter](https://www.youtube.com/watch?v=_O-HBDZMLrM). (Esse vídeo funciona bem se você pedir para olhar as legendas e configurar para traduzir para portuguẽs. Incrível!)
>
> Vamos revisitar esses tópicos em exercícios futuros!

"""

# ╔═╡ ec5efe8c-edef-11ea-2c6f-afaaeb5bc50c
function demean(xs)
    # seu código aqui!
    return missing
end

# ╔═╡ d6ddafdd-1a44-48c7-b49a-554073cdf331
test_vect = let

    # Sintaxe à vontade para mudar o caso de teste
    to_create = [-1.0, -1.5, 8.5]


    ####
    # Esta célula é meio estranho mas está aqui para evitar o problema comum
    # Ela gera novamente o mesmo vetor se você criou uma função que o altera

    # Ignore isso e continue com o seu exercício!

    demean
    to_create
end

# ╔═╡ 29e10640-edf0-11ea-0398-17dbf4242de3
md"Para verificar  a sua função, vamos veriricar se a média do vetor após `demean(test_vect)` é 0 : (_Devido a erros de arredondamento de ponto flutuante o valor pode *não* ser *exatamente* 0._)"

# ╔═╡ 38155b5a-edf0-11ea-3e3f-7163da7433fb
demeaned_test_vect = demean(test_vect)

# ╔═╡ 1267e961-5b75-4b55-8080-d45316a03b9b
mean(demeaned_test_vect)

# ╔═╡ a5f8bafe-edf0-11ea-0da3-3330861ae43a
md"""
#### Exercício 1.5

👉 Crie um vetor de 100 elements em que:
- Os 20 elementos centrais valem `1`, e
- todos os outros elementos valem `0`.
"""

# ╔═╡ b6b65b94-edf0-11ea-3686-fbff0ff53d08
function create_bar()
    # seu código aqui!
    return missing
end

# ╔═╡ 4a5e9d2c-dd90-4bb0-9e31-3f5c834406b4
create_bar()

# ╔═╡ d862fb16-edf1-11ea-36ec-615d521e6bc0
colored_line(create_bar())

# ╔═╡ 59414833-a108-4b1e-9a34-0f31dc907c6e
url = "https://www.ime.unicamp.br/~pjssilva/images/ensino/labcompsci/apolo1.png"

# ╔═╡ c5484572-ee05-11ea-0424-f37295c3072d
apolo_filename = download(url) # download to a local file. The filename is returned

# ╔═╡ c8ecfe5c-ee05-11ea-322b-4b2714898831
apolo = load(apolo_filename)

# ╔═╡ e86ed944-ee05-11ea-3e0f-d70fc73b789c
md"_Olá, Apolo_"

# ╔═╡ 6ccd8902-0dd9-4335-a11a-ee7f9a1a6c09
apolo_head = apolo[50:380, 100:480]

# ╔═╡ 15088baa-c337-405d-8885-19a6e2bfd6aa
md"""
Lembre da aula sobre imagens que em Julia, uma _imagem_ pode ser vista com um array 2D de objetos que representam cores:
"""

# ╔═╡ 7ad4f6bc-588e-44ab-8ca9-c87cd1048442
typeof(apolo)

# ╔═╡ a55bb5ca-600b-4aa0-b95f-7ece20845c9b
md"""
Cada pixel (os _elementos do array 2D_) são do tipo `RGB`:
"""

# ╔═╡ c5dc0cc8-9305-47e6-8b20-a9f8ef867799
apolo_pixel = apolo[400, 600]

# ╔═╡ de772e21-0bea-4fd2-868a-9a7d32550bc9
typeof(apolo_pixel)

# ╔═╡ 21bdc692-91ee-474d-ae98-455913a2342e
md"""
Pera pegar valores de um canal individual de cor use use os  _atributos_ `r`, `g` and `b`:
"""

# ╔═╡ 2ae3f379-96ce-435d-b863-deba4586ec71
apolo_pixel.r, apolo_pixel.g, apolo_pixel.b

# ╔═╡ c49ba901-d798-489a-963c-4cc113c7abfd
md"""
E, lembrando, para criar um objeto `RGB` você faz:
"""

# ╔═╡ 93451c37-77e1-4d4f-9788-c2a3da1401ee
RGB(0.1, 0.4, 0.7)

# ╔═╡ f52e4914-2926-4a42-9e45-9caaace9a7db
md"""
#### Exercício 2.1
👉 Escreva uma função **`get_red`** que pega um único pixel e retorna o valor de seu canal vermelho.
"""

# ╔═╡ a8b2270a-600c-4f83-939e-dc5ab35f4735
function get_red(pixel::AbstractRGB)
    # seu código aqui!
    return missing
end

# ╔═╡ c320b39d-4cea-4fa1-b1ce-053c898a67a6
get_red(RGB(0.8, 0.1, 0.0))

# ╔═╡ d8cf9bd5-dbf7-4841-acf9-eef7e7cabab3
md"""
#### Exercício 2.2
👉 Escreva uma função **`get_reds`** (note o `s` do final) que aceita um array de cores 2D chamado `image` e retorna um array 2D com o valor numérico do canal vermelho de cada pixel. (O resultado deve ser um array 2D de _números_) Use a função `get_red` do exercício anterior.
"""

# ╔═╡ ebe1d05c-f6aa-437d-83cb-df0ba30f20bf
function get_reds(image::AbstractMatrix)
    # seu código aqui!
    return missing
end

# ╔═╡ c427554a-6f6a-43f1-b03b-f83239887cee
get_reds(apolo_head)

# ╔═╡ 4fd07e01-2f8b-4ec9-9f4f-8a9e5ff56fb6
md"""

Ótimo! Observe que ao extrair o o valor de um único canal fomos de uma matriz de cores (RGB) para uma matriz de números.

#### Exercício 2.3
Vamos tentar visualizar essa matriz. Por enquanto ela é apenas uma matriz de número e portanto é visualizada de forma textual. Note que o sistema usa elipses para não mostra a matriz inteira, afinal de contas ela seria enorme. Será que conseguimos **visualizar a matriz como uma imagem**?

Isso é mais simples do que parece. Queremos apenas mapear cada número em uma cor RGB que tem o número no canal vermelho (e 0 no resto). Se fizermos isso para cada número da matriz com os valores de vermelhos voltamos para uma matriz de cores (objetos RGB) que podemos visualizar como imagem no Pluto.

Mais uma vez, vamos definir uma função que transforma um único _número_ numa _cor_.
"""

# ╔═╡ 97c15896-6d99-4292-b7d7-4fcd2353656f
function value_as_color(x)

    return RGB(x, 0, 0)
end

# ╔═╡ cbb9bf41-4c21-42c7-b0e0-fc1ce29e0eb1
value_as_color(0.0), value_as_color(0.6), value_as_color(1.0)

# ╔═╡ 3f1a670b-44c2-4cab-909c-65f4ae9ed14b
md"""
👉 Agora use as funções `get_reds` e `value_as_color` para visualizar o canal vermelho de `apolo_head`. Dica: pense em usar difusão (a sintaxe do ponto) para aplicar uma função _elemento-a-elemento_.

Use o botão ➕ do canto inferior esquerdo para adicionar mais células se for preciso..
"""

# ╔═╡ 21ba6e75-55a2-4614-9b5d-ea6378bf1d98


# ╔═╡ f7825c18-ff28-4e23-bf26-cc64f2f5049a
md"""

#### Exercício 2.4
👉 Escreva mais quatro funções, `get_green`, `get_greens`, `get_blue` e `get_blues`, como os equivaletes de `get_red` e `get_reds` para os canais verde e azul. Se precisar, use o ➕ botão para adicionar células.
"""

# ╔═╡ d994e178-78fd-46ab-a1bc-a31485423cad


# ╔═╡ c54ccdea-ee05-11ea-0365-23aaf053b7d7
md"""
#### Exercício 2.5
👉 Escreva uma função **`mean_color`** que recebe uma imagem `image`. Ela deve calcular a média dos valores dos canais vermelho, verde e azul e retornar a cor média. Reaproveite as funções dos exercícios anteriores ou escreva outras adaptando o que você fez.
"""

# ╔═╡ f6898df6-ee07-11ea-2838-fde9bc739c11
function mean_color(image)
    # seu código aqui!
    return missing
end

# ╔═╡ 5be9b144-ee0d-11ea-2a8d-8775de265a1d
mean_color(apolo)

# ╔═╡ 5f6635b4-63ed-4a62-969c-bd4084a8202f
md"""
_Ao final dessa lista você pode capturar uma imagem com a sua webcam e ver o resultado de todas as suas funções aplicada a essa nova foto!_
"""

# ╔═╡ 63e8d636-ee0b-11ea-173d-bd3327347d55
function invert(color::AbstractRGB)
    # seu código aqui!
    return missing
end

# ╔═╡ 2cc2f84e-ee0d-11ea-373b-e7ad3204bb00
md"Let's invert some colors:"

# ╔═╡ b8f26960-ee0a-11ea-05b9-3f4bc1099050
color_black = RGB(0.0, 0.0, 0.0)

# ╔═╡ 5de3a22e-ee0b-11ea-230f-35df4ca3c96d
invert(color_black)

# ╔═╡ 4e21e0c4-ee0b-11ea-3d65-b311ae3f98e9
color_red = RGB(0.8, 0.1, 0.1)

# ╔═╡ 6dbf67ce-ee0b-11ea-3b71-abc05a64dc43
invert(color_red)

# ╔═╡ 846b1330-ee0b-11ea-3579-7d90fafd7290
md"👉 Can you invert the picture of Apolo?"

# ╔═╡ 943103e2-ee0b-11ea-33aa-75a8a1529931
apolo_inverted = missing # replace `missing` with your code!

# ╔═╡ 55b138b7-19fb-4da1-9eb1-1e8304528251
md"""
_At the end of this homework, you can see all of your filters applied to your webcam image!_
"""

# ╔═╡ f68d4a36-ee07-11ea-0832-0360530f102e
md"""
#### Exercício 3.2
👉 Dê uma olhada na documentação da função `floor`. Use-a para escrever uma função`quantize(x::Number)` que recebe um valor $x$ (que você pode considerar que está entre 0 e 1) and "quantiza" esse valor para pacotes de largura 0.1. Por exemplo, verifique 0.267 é mapeado a 0.2.
"""

# ╔═╡ fbd1638d-8d7a-4d12-aff9-9c160cc3fd74
function quantize(x::Number)
    # seu código aqui!
    return missing
end

# ╔═╡ 7720740e-2d2b-47f7-98fd-500ed3eee479
md"""
#### Intermezzo: _Múltiplos métodos_

Em Julia chamamos de métodos versões concretas de funções de são escolhidas de acordo com os seus parâmetros (seja o número, seja o tipo). Daí, quando você pede para Julia dizer o que é uma função ele vai falar que é uma _função genérica_ com _XX métodos_. Vamos ver isso em ação.

Nesse primeiro exemplo temos dois _methods_ para a mesma função. Eles são diferentes porque possuem

> **o mesmo nome, mas diferentes tipos de parâmetros de entrada**

Obs: Note que definimos o tipo do parâmetro de entrada através do anotação `::Tipo` apos no nome do parâmtro.
"""

# ╔═╡ 90421bca-0804-4d6b-8bd0-3ddbd54cc5fe
function double(x::Number)

    return x * 2
end

# ╔═╡ b2329e4c-6204-453e-8998-2414b869b808
function double(x::Vector)

    return [x..., x...]
end

# ╔═╡ 23fcd65f-0182-41f3-80ec-d85b05136c47
md"""
Quando chamarmos a função `double`, Julia irá decidir qual método chamar de acordo com o tipo do parâmetro de entrada.
"""

# ╔═╡ 5055b74c-b98d-41fa-a0d8-cb36200d82cc
double(24)

# ╔═╡ 8db17b2b-0cf9-40ba-8f6f-2e53be7b6355
double([1, 2, 37])

# ╔═╡ a8a597e0-a01c-40cd-9902-d56430afd938
md"""
Isso é chamado de **despacho múltiplo** e e uma das características principais de Julia. Nesse curso veremos vários exemplos dessa ideia em ação como forma de criar abstrações flexíveis e fáceis de entender.
"""

# ╔═╡ f6b218c0-ee07-11ea-2adb-1968c4fd473a
md"""
#### Exercício 3.3
👉 Escreva um segundo **método** para a função `quantize`, isto é, uma nova *versão concreta* com o mesmo nome para uma função. Este método deve receber um objeto de cor do tipo`AbstractRGB`.

Aqui, `::AbstractRGB` é uma **anotação de tipo**. Ela garante que essa versão da função será chamada quando o objeto que estamos passado no parâmetro é um **subtipo**  de `AbstractRGB`. Por exemplo, ambos `RGB` e `RGBX` são subtipos de `AbstractRGB`.

Seu método deve retornar um objeto `RGB` com os valores de cada canal ($r$, $g$ and $b$) foram quantizados. Use sua versão anterior de `quantize`!
"""

# ╔═╡ 04e6b486-ceb7-45fe-a6ca-733703f16357
function quantize(color::AbstractRGB)
    # seu código aqui!
    return missing
end

# ╔═╡ f6bf64da-ee07-11ea-3efb-05af01b14f67
md"""
#### Exercício 3.4
👉 Escreva um método `quantize(image::AbstractMatrix)` que quantiza a imagem toda, quantizando cada pixel da imagem. (Você pode considerar que a matriz de entrada é uma matriz de cores.)
"""

# ╔═╡ 13e9ec8d-f615-4833-b1cf-0153010ccb65
function quantize(image::AbstractMatrix)
    # seu código aqui!
    return missing
end

# ╔═╡ f6a655f8-ee07-11ea-13b6-43ca404ddfc7
quantize(0.267), quantize(0.91)

# ╔═╡ 25dad7ce-ee0b-11ea-3e20-5f3019dd7fa3
md"Vamos aplicar o seu método!"

# ╔═╡ 9751586e-ee0c-11ea-0cbb-b7eda92977c9
quantize(apolo)

# ╔═╡ f6d6c71a-ee07-11ea-2b63-d759af80707b
md"""
#### Exercício 3.5
👉 Escreva uma função `noisify(x::Number, s)` que adiciona uma intensidade aleatória $s$ ao valor $x$, i.e. ela adiciona um valor aletório entre $-s$ e $+s$ a $x$. Se o valor cair fora do inervalo $[0, 1]$ você deve truncar a resposta para caber na faixa. (Julia tem uma função já pronta chamada `clamp` que vai lhe ajudar nisso, ou você pode escrever a sua função do zero.)
"""

# ╔═╡ f38b198d-39cf-456f-a841-1ba08f206010
function noisify(x::Number, s)
    # seu código aqui!
    return missing
end

# ╔═╡ f6fc1312-ee07-11ea-39a0-299b67aee3d8
md"""
👉  Escreva um segundo método `noisify(c::AbstractRGB, s)` para adicionar um ruído aleatório diferente de intensidade $s$ em cada um dos canais $(r, g, b)$ da cor.

Use sua versão anterior `noisify`. _(Lembre que Julia escolhe o método que será chamado baseado nos parâmetros de entrada. Então para chamar o método anterior o parâmetro que será passado deve ser um número.)_
"""

# ╔═╡ db4bad9f-df1c-4640-bb34-dd2fe9bdce18
function noisify(color::AbstractRGB, s)
    # seu código aqui!
    return missing
end

# ╔═╡ 0000b7f8-4c43-4dd8-8665-0dfe59e74c0a
md"""
Amplitude do ruído:
"""

# ╔═╡ 774b4ce6-ee1b-11ea-2b48-e38ee25fc89b
@bind color_noise Slider(0:0.01:1, show_value = true)

# ╔═╡ 14c020d1-aada-4e37-b019-e32a42ba7115
md"""
> ### Relembrando _compreensão de array_
> Já sbemos que há algumas formas de se criar um novo array a partir de outro (ou ranges):
> 1. podemos usar laço for e percorrer o array
> 1. podemos usar difusão de função sobre o array
> 1. podemos usar _**compreensão de arrays**_
>
> Essa última opção é demonstrada abaixo e está baseada na sintaxe:
>
> ```[função_para_aplicar(args) for args in algo_para_percorrer]```
>
> Isso cria um novo objeto que bate com o objeto percorrido. Abaixo mostramos um exemplo em que interemos dois ranges para criar uma matriz.
"""

# ╔═╡ f70823d2-ee07-11ea-2bb3-01425212aaf9
md"""
👉 Escreva um terceiro método `noisify(image::AbstractMatrix, s)` que adiciona ruídos a cada pixel na imagem. Tente fazer essa função em uma única linha!
"""

# ╔═╡ 21a5885d-00ab-428b-96c3-c28c98c4ca6d
function noisify(image::AbstractMatrix, s)
    # seu código aqui!
    return missing
end

# ╔═╡ 8464d42a-6a01-443e-82f4-0ebf9efcc54c
noisify(0.5, 0.1) # edit this test case!

# ╔═╡ 2e1f9fb5-ef43-44e9-92d3-6f5df18d33d4
(original = color_red, with_noise = noisify(color_red, color_noise))

# ╔═╡ 24dd001b-adf4-4d2b-8b04-62b973058ec0
[noisify(color_red, strength) for strength = 0:0.05:1, row = 1:10]'

# ╔═╡ d896b7fd-20db-4aa9-bbcf-81b1cd44ec46
md"""

#### Exercício 3.6
Mova o slider abaixo para escolher o nível de ruído para ser aplicado na imagem do Apolo.
"""

# ╔═╡ e70a84d4-ee0c-11ea-0640-bf78653ba102
@bind apolo_noise Slider(0:0.01:1, show_value = true)

# ╔═╡ ac15e0d0-ee0c-11ea-1eaf-d7f88b5df1d7
noisify(apolo_head, apolo_noise)

# ╔═╡ 9604bc44-ee1b-11ea-28f8-7f7af8d0cbb2
if apolo_noise == 1
    md"""
    > #### Como isso é possível?
    >
    > A intensidade do ruído é `1.0`, mas ainda conseguimos reconhecer o Apolo na imagem...
    >
    > 👉 Modifique a definição do slider para ir além de `1.0`.
    """
end

# ╔═╡ f714699e-ee07-11ea-08b6-5f5169861b57
md"""
👉 Para qual intensidade de ruído deixamos de reconhecer o cão?

Pode ser necessária uma intensidade maior que 1. Porque?

"""

# ╔═╡ bdc2df7c-ee0c-11ea-2e9f-7d2c085617c1
answer_about_noise_intensity = md"""
A imagem se torna irreconhecível com a partir da intensidade ...
"""

# ╔═╡ e87e0d14-43a5-490d-84d9-b14ece472061
md"""
### Resultados
"""

# ╔═╡ ee5f21fb-1076-42b6-8926-8bbb6ed0ad67
function custom_filter(pixel::AbstractRGB)

    # seu código aqui!

    return pixel
end

# ╔═╡ 9e5a08dd-332a-486b-94ab-15c49e72e522
function custom_filter(image::AbstractMatrix)

    return custom_filter.(image)
end

# ╔═╡ 5bd09d0d-2643-491a-a486-591657a857b3
if student.email_dac === "j000000"
    md"""
   !!! danger "Oops!"
       **Antes de submeter**, lembre de preencher seu nome e email DAC no topo desse caderno!
   	"""
end

# ╔═╡ 8ffe16ce-ee20-11ea-18bd-15640f94b839
if student.email_dac === "r000000"
    md"""
   !!! danger "Oops!"
       **Before you submit**, remember to fill in your name and kerberos ID at the top of this notebook!
   	"""
end

# ╔═╡ 756d150a-b7bf-4bf5-b372-5b0efa80d987
md"## Biblioteca de funções

Algumas funções para ajudar no notebook."

# ╔═╡ 4bc94bec-da39-4f8a-82ee-9953ed73b6a4
hint(text) = Markdown.MD(Markdown.Admonition("hint", "Dica", [text]))

# ╔═╡ b1d5ca28-edf6-11ea-269e-75a9fb549f1d
md"""
Voce pode saber mais sobre funções (como `rand`) selecionando o Live Docs no canto inferior direito e digitando o nome da função que você procura.

![image](https://user-images.githubusercontent.com/6933510/107848812-c934df80-6df6-11eb-8a32-663d802f5d11.png)


![image](https://user-images.githubusercontent.com/6933510/107848846-0f8a3e80-6df7-11eb-818a-7271ecb9e127.png)

Nós recomendamos que você deixe a janela de ajuda aberta, ele vai procurar continuamente por documentação de tudo o que você digitar!

#### Ajuda, eu não encontro a janela de documentação!

Tente o seguinte:

🙋 **Será que você está vendo uma versão estática da página?** A janela de ajuda somente fucniona de você estiver de fato _rodando_ o caderno.

🙋 **Sua hanela é muito pequena?** Tente redimensionar a janela ou diminuir o zoom.
""" |> hint

# ╔═╡ 24090306-7395-4f2f-af31-34f7486f3945
hint(md"""Veja essa página para lembrar a sintaxe básica de Julis:

 [Basic Julia Syntax](https://computationalthinking.mit.edu/Spring21/basic_syntax/)""")

# ╔═╡ aa1ff74a-4e78-4ef1-8b8d-3a60a168cf6d
hint(
    md"""
Na aula nós desenhamos um quadrado azul sobre a imagem do Apolo com um único comando... Veja o vídeo.
""",
)

# ╔═╡ 50e2b0fb-b06d-4ac1-bdfb-eab833466736
md"""
Esse exercíco será mais difícil se você usar laços `for` ou compressão de arrays.

Tente usar difusão [sintaxe do dot](https://docs.julialang.org/en/v1/manual/functions/#man-vectorized) para aplicar a função "elmento-por-elemento" em todo o array. Por exemplo, com essa função você calcula a raiz quadrada de `3`:

```
sqrt(3)
```

já assim você pega a raiz dos três valores 1, 2 e 3:

```
sqrt.([1, 2, 3])
```

""" |> hint

# ╔═╡ f6ef2c2e-ee07-11ea-13a8-2512e7d94426
hint(md"`rand()` gera um ponto-flutuante (uniformemente) no intervalo $0$ and $1$.")

# ╔═╡ 8ce6ad06-819c-4af5-bed7-56ecc08c97be
almost(text) = Markdown.MD(Markdown.Admonition("cuidado", "Quase lá!", [text]))

# ╔═╡ dfa40e89-03fc-4a7a-825e-92d67ee217b2
still_missing(text = md"Substitua `missing` com sua resposta.") =
    Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))

# ╔═╡ 086ec1ff-b62d-4566-9973-5b2cc3353409
keep_working(text = md"A resposta não está perfeita.") =
    Markdown.MD(Markdown.Admonition("perigo", "Continue tentando", [text]))

# ╔═╡ 2f6fb3a6-bb5d-4c7a-9297-84dd4b16c7c3
yays = [
    md"Ótimo!",
    md"Ôba ❤",
    md"Muito bom! 🎉",
    md"Bom trabalho!",
    md"Continue assim!",
    md"Perfeito!",
    md"Incrível!",
    md"Você acertou!",
    md"Podemos continuar para a próxima seção.",
]

# ╔═╡ c22f688b-dc04-4a94-b541-fe06266c5446
correct(text = rand(yays)) =
    Markdown.MD(Markdown.Admonition("correto", "Você acertou!", [text]))

# ╔═╡ 09102183-f9fb-4d89-b4f9-5d76af7b8e90
let
    result = get_red(RGB(0.2, 0.3, 0.4))
    if ismissing(result)
        still_missing()
    elseif isnothing(result)
        keep_working(md"Você esqueceu de escrevere `return`?")
    elseif result == 0.2
        correct()
    else
        keep_working()
    end
end

# ╔═╡ 63ac142e-6d9d-4109-9286-030a02c900b4
let
    test = [RGB(0.2, 0, 0) RGB(0.6, 0, 0)]
    result = get_reds(test)

    if ismissing(result)
        still_missing()
    elseif isnothing(result)
        keep_working(md"Você esqueceu de escrever`return`?")
    elseif result == [0.2 0.6]
        correct()
    else
        keep_working()
    end
end

# ╔═╡ 80a4cb23-49c9-4446-a3ec-b2203128dc27
let
    result = invert(RGB(1.0, 0.5, 0.25)) # I chose these values because they can be represented exactly by Float64
    shouldbe = RGB(0.0, 0.5, 0.75)

    if ismissing(result)
        still_missing()
    elseif isnothing(result)
        keep_working(md"Você esqueceu de escrever`return`?")
    elseif !(result isa AbstractRGB)
        keep_working(
            md"Você deve retornar uma _cor_, i.e. um objeto do type `RGB`. Use `RGB(r, g, b)` para criar uma cor com valores `r`, `g` e `b` nos canais.",
        )
    elseif !(result == shouldbe)
        keep_working()
    else
        correct()
    end
end

# ╔═╡ a6d9635b-85ed-4590-ad09-ca2903ea8f1d
let
    result = quantize(RGB(0.297, 0.1, 0.0))

    if ismissing(result)
        still_missing()
    elseif isnothing(result)
        keep_working(md"Você esqueceu de escrever`return`?")
    elseif !(result isa AbstractRGB)
        keep_working(
            md"Você deve retornar uma _cor_, i.e. um objeto do type `RGB`. Use `RGB(r, g, b)` para criar uma cor com valores `r`, `g` e `b` nos canais.",
        )
    elseif result != RGB(0.2, 0.1, 0.0)
        keep_working()
    else
        correct()
    end
end

# ╔═╡ 31ef3710-e4c9-4aa7-bd8f-c69cc9a977ee
let
    result = noisify(0.5, 0)

    if ismissing(result)
        still_missing()
    elseif isnothing(result)
        keep_working(md"Você esqueceu de escrever `return`?")
    elseif result == 0.5

        results = [noisify(0.9, 0.1) for _ = 1:1000]

        if 0.8 ≤ minimum(results) < 0.81 && 0.99 ≤ maximum(results) ≤ 1
            result = noisify(5, 3)

            if result == 1
                correct()
            else
                keep_working(md"O resultado deveria estar restrito ao intervalo ``[0,1]``.")
            end
        else
            keep_working()
        end
    else
        keep_working(md"Qual deveria ser o valor de `noisify(0.5, 0)`?")
        correct()
    end
end

# ╔═╡ ab3d1b70-88e8-4118-8d3e-601a8a68f72d
not_defined(variable_name) = Markdown.MD(
    Markdown.Admonition(
        "perigo",
        "Ooppss!",
        [
            md"Make sure that you define a variable called **$(Markdown.Code(string(variable_name)))**",
        ],
    ),
)

# ╔═╡ 397941fc-edee-11ea-33f2-5d46c759fbf7
if !@isdefined(random_vect)
    not_defined(:random_vect)
elseif ismissing(random_vect)
    still_missing()
elseif !(random_vect isa Vector)
    keep_working(md"`random_vect` should be a `Vector`.")
elseif eltype(random_vect) != Float64
    almost(
        md"""
  You gerou um vetor de inteiros aleatórios. Para os próximos exercícios você precisa de um vetor de pontos flutuantes (`Float64`).

  O primeiro argumento de `rand` (que é opcional) especifica o **tipo** dos elementos que ela gera. Por exemplo: `rand(Bool, 10)` gera dez valores que são `true` ou `false`. (Teste!)
  """,
    )
elseif length(random_vect) != 10
    keep_working(md"`random_vect` não tem o comprimento correto.")
elseif length(Set(random_vect)) != 10
    keep_working(md"`random_vect` não é 'suficientemente aleatório'")
else
    correct(md"Muito bem! Você pode rodar o seu código de novo para gerar um novo vetor!")
end

# ╔═╡ e0bfc973-2808-4f84-b065-fb3d05401e30
if !@isdefined(my_sum)
    not_defined(:my_sum)
else
    let
        result = my_sum([1, 2, 3])
        if ismissing(result)
            still_missing()
        elseif isnothing(result)
            keep_working(md"Você esqueceu de escrever`return`?")
        elseif result != 6
            keep_working()
        else
            correct()
        end
    end
end

# ╔═╡ 38dc80a0-edef-11ea-10e9-615255a4588c
if !@isdefined(mean)
    not_defined(:mean)
else
    let
        result = mean([1, 2, 3])
        if ismissing(result)
            still_missing()
        elseif isnothing(result)
            keep_working(md"Você esqueceu de escrever`return`?")
        elseif result != 2
            keep_working()
        else
            correct()
        end
    end
end

# ╔═╡ 2b1ccaca-edee-11ea-34b0-c51659f844d0
if !@isdefined(m)
    not_defined(:m)
elseif ismissing(m)
    still_missing()
elseif !(m isa Number)
    keep_working(md"`m` deveria ser um número.")
elseif m != mean(random_vect)
    keep_working()
else
    correct()
end

# ╔═╡ adf476d8-a334-4b35-81e8-cc3b37de1f28
if !@isdefined(mean)
    not_defined(:mean)
else
    let
        input = Float64[1, 2, 3]
        result = demean(input)

        if input === result
            almost(
                md"""
         Parerece que você **modificou** `xs` dentro da função.

         É preferível que você evite modificação dos dados dentro da função, porque você pode precisar do valore original depois.

         """,
            )
        elseif ismissing(result)
            still_missing()
        elseif isnothing(result)
            keep_working(md"Você esqueceu de escrever`return`?")
        elseif !(result isa AbstractVector) || length(result) != 3
            keep_working(md"Devolva um vetor do mesmo comprimento que `xs`.")
        elseif abs(sum(result) / 3) < 1e-10
            correct()
        else
            keep_working()
        end
    end
end

# ╔═╡ e3394c8a-edf0-11ea-1bb8-619f7abb6881
if !@isdefined(create_bar)
    not_defined(:create_bar)
else
    let
        result = create_bar()
        if ismissing(result)
            still_missing()
        elseif isnothing(result)
            keep_working(md"Você esqueceu de escrever`return`?")
        elseif !(result isa Vector) || length(result) != 100
            keep_working(md"O resultado deveria ser um `Vector` com 100 elementos.")
        elseif result[[1, 50, 100]] != [0, 1, 0]
            keep_working()
        else
            correct()
        end
    end
end

# ╔═╡ 4d0158d0-ee0d-11ea-17c3-c169d4284acb
if !@isdefined(mean_color)
    not_defined(:mean_color)
else
    let
        input = reshape([RGB(1.0, 1.0, 1.0), RGB(1.0, 1.0, 0.0)], (2, 1))

        result = mean_color(input)
        shouldbe = RGB(1.0, 1.0, 0.5)

        if ismissing(result)
            still_missing()
        elseif isnothing(result)
            keep_working(md"Você esqueceu de escrever`return`?")
        elseif !(result isa AbstractRGB)
            keep_working(
                md"Você deve retornar uma _cor_, i.e. um objeto do type `RGB`. Use `RGB(r, g, b)` para criar uma cor com valores `r`, `g` e `b` nos canais.",
            )
        elseif !(result ≈ shouldbe)
            keep_working()
        else
            correct()
        end
    end
end

# ╔═╡ c905b73e-ee1a-11ea-2e36-23b8e73bfdb6
if !@isdefined(quantize)
    not_defined(:quantize)
else
    let
        result = quantize(0.3)

        if ismissing(result)
            still_missing()
        elseif isnothing(result)
            keep_working(md"Você esqueceu de escrever`return`?")
        elseif result != 0.3
            if quantize(0.35) ≈ 0.3
                almost(md"Qual deveria ser o valor de quantize(`0.2`)?")
            else
                keep_working()
            end
        else
            correct()
        end
    end
end

# ╔═╡ 8cb0aee8-5774-4490-9b9e-ada93416c089
todo(text) = HTML("""<div
 style="background: rgb(220, 200, 255); padding: 2em; border-radius: 1em;"
 ><h1>TODO</h1>$(repr(MIME"text/html"(), text))</div>""")

# ╔═╡ 115ded8c-ee0a-11ea-3493-89487315feb7
bigbreak = html"<br><br><br><br><br>";

# ╔═╡ 54056a02-ee0a-11ea-101f-47feb6623bec
bigbreak

# ╔═╡ e083b3e8-ed61-11ea-2ec9-217820b0a1b4
md"""
 $(bigbreak)

## **Exercício 2** - _Manipulating images_

Neste exercício vamos nos familiarizar com matrizes (arrays 2D) em Julia, manipulando imagens.
Lembre que em Julia imagens são matrizes de objetos `RGB` que represetam cores.

Vamos carregar a imagem do Apolo novamente.
"""

# ╔═╡ f6cc03a0-ee07-11ea-17d8-013991514d42
md"""
 $(bigbreak)

## Exercício 3 - _Mais filtros_

Nos exercícios anteriores, aprendemos como usar a _sintaxe do ponto_ de Julia para aplicar um a função a _cada elemento_ de um array. Neste exercício, vamos usá-la para escrever mais filtros de iamgem e depois aplicá-los a sua imagem da webcam!

#### Exercício 3.1
👉 Escreva uma função `invert` que inverte uma cor, ou seja, mapeia $(r, g, b)$ em $(1 - r, 1-g, 1-b)$.
"""

# ╔═╡ 4139ee66-ee0a-11ea-2282-15d63bcca8b8
md"""
$(bigbreak)
### Camera input
"""

# ╔═╡ 87dabfd2-461e-4769-ad0f-132cb2370b88
md"""
$(bigbreak)
### Escreva seu próprio filtro

Pense em uma manipulação diferente que você gostaria de fazer na imagem e escreva o seu próprio filtro.
"""

# ╔═╡ 91f4778e-ee20-11ea-1b7e-2b0892bd3c0f
bigbreak

# ╔═╡ 5842895a-ee10-11ea-119d-81e4c4c8c53b
bigbreak

# ╔═╡ dfb7c6be-ee0d-11ea-194e-9758857f7b20
function camera_input(; max_size = 200, default_url = "https://i.imgur.com/SUmi94P.png")
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

# ╔═╡ 20402780-426b-4caa-af8f-ff1e7787b7f9
@bind cam_data camera_input()

# ╔═╡ e15ad330-ee0d-11ea-25b6-1b1b3f3d7888

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

# ╔═╡ ed9fb2ac-2680-42b7-9b00-591e45a5e105
cam_image = process_raw_camera_data(cam_data)

# ╔═╡ d38c6958-9300-4f7a-89cf-95ca9e899c13
mean_color(cam_image)

# ╔═╡ 82f1e006-60fe-4ad1-b9cb-180fafdeb4da
invert.(cam_image)

# ╔═╡ 54c83589-b8c6-422a-b5e9-d8e0ee72a224
quantize(cam_image)

# ╔═╡ 18e781f8-66f3-4216-bc84-076a08f9f3fb
noisify(cam_image, 0.5)

# ╔═╡ ebf3193d-8c8d-4425-b252-45067a5851d9
[
    invert.(cam_image) quantize(cam_image)
    noisify(cam_image, 0.5) custom_filter(cam_image)
]

# ╔═╡ 8917529e-fa7a-412b-8aea-54f92f6270fa
custom_filter(cam_image)

# ╔═╡ 83eb9ca0-ed68-11ea-0bc5-99a09c68f867
md"_Lista 1, version 8_"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
ImageMagick = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
Images = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
HypertextLiteral = "~0.9.0"
ImageMagick = "~1.2.1"
Images = "~0.24.1"
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

[[ArrayInterface]]
deps = ["IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "cdb00a6fb50762255021e5571cf95df3e1797a51"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.1.23"

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

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "79b9563ef3f2cc5fc6d3046a5ee1a57c9de52495"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.33.0"

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
git-tree-sha1 = "ee400abb2298bd13bfc3df1c412ed228061a2385"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.7.0"

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
git-tree-sha1 = "abe4ad222b26af3337262b8afb28fab8d215e9f8"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.3"

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
git-tree-sha1 = "f985af3b9f4e278b1d24434cbb546d6092fca661"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.3"

[[FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3676abafff7e4ff07bbd2c42b3d8201f31653dcc"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.9+8"

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

[[Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "2c1cf4df419938ece72de17f368a021ee162762e"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.0"

[[HypertextLiteral]]
git-tree-sha1 = "72053798e1be56026b81d4e2682dbe58922e5ec9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.0"

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
deps = ["FileIO", "Netpbm", "PNGFiles", "TiffImages", "UUIDs"]
git-tree-sha1 = "d067570b4d4870a942b19d9ceacaea4fb39b69a1"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.5.6"

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
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "3d682c07e6dd250ed082f883dc88aee7996bf2cc"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.0"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "c253236b0ed414624b083e6b72bfe891fbd2c7af"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+1"

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

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "4ea90bd5d3985ae1f9a908bd4500ae88921c5ce7"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.0"

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

[[Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "2276ac65f1e236e0a6ea70baff3f62ad4c625345"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.2"

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
git-tree-sha1 = "5f6c21241f0f655da3952fd60aa18477cf96c220"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.1.0"

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

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "fed1ec1e65749c4d96fc20dd13bea72b55457e62"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.9"

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
# ╟─8ef13896-ed68-11ea-160b-3550eeabbd7d
# ╟─ac8ff080-ed61-11ea-3650-d9df06123e1f
# ╠═911ccbce-ed68-11ea-3606-0384e7580d7c
# ╟─5f95e01a-ee0a-11ea-030c-9dba276aba92
# ╠═65780f00-ed6b-11ea-1ecf-8b35523a7ac0
# ╟─29dfe3d6-c353-4081-8192-b12f374bf702
# ╟─54056a02-ee0a-11ea-101f-47feb6623bec
# ╟─540ccfcc-ee0a-11ea-15dc-4f8120063397
# ╟─467856dc-eded-11ea-0f83-13d939021ef3
# ╠═56ced344-eded-11ea-3e81-3936e9ad5777
# ╟─ad6a33b0-eded-11ea-324c-cfabfd658b56
# ╠═f51333a6-eded-11ea-34e6-bfbb3a69bcb0
# ╟─b18e2c54-edf1-11ea-0cbf-85946d64b6a2
# ╟─397941fc-edee-11ea-33f2-5d46c759fbf7
# ╟─b1d5ca28-edf6-11ea-269e-75a9fb549f1d
# ╟─5da8cbe8-eded-11ea-2e43-c5b7cc71e133
# ╟─77adb065-bfd4-4680-9c2a-ad4d92689dbf
# ╠═bd907ee1-5253-4cae-b5a5-267dac24362a
# ╠═6640110a-d171-4b32-8d12-26979a36b718
# ╟─e0bfc973-2808-4f84-b065-fb3d05401e30
# ╟─24090306-7395-4f2f-af31-34f7486f3945
# ╟─cf738088-eded-11ea-2915-61735c2aa990
# ╠═0ffa8354-edee-11ea-2883-9d5bfea4a236
# ╠═1f104ce4-ee0e-11ea-2029-1d9c817175af
# ╟─38dc80a0-edef-11ea-10e9-615255a4588c
# ╟─1f229ca4-edee-11ea-2c56-bb00cc6ea53c
# ╠═2a391708-edee-11ea-124e-d14698171b68
# ╟─2b1ccaca-edee-11ea-34b0-c51659f844d0
# ╟─e2863d4c-edef-11ea-1d67-332ddca03cc4
# ╟─ea8d92f8-159c-4161-8c54-bab7bc00f290
# ╠═ec5efe8c-edef-11ea-2c6f-afaaeb5bc50c
# ╟─d6ddafdd-1a44-48c7-b49a-554073cdf331
# ╟─29e10640-edf0-11ea-0398-17dbf4242de3
# ╠═1267e961-5b75-4b55-8080-d45316a03b9b
# ╠═38155b5a-edf0-11ea-3e3f-7163da7433fb
# ╟─adf476d8-a334-4b35-81e8-cc3b37de1f28
# ╟─a5f8bafe-edf0-11ea-0da3-3330861ae43a
# ╠═b6b65b94-edf0-11ea-3686-fbff0ff53d08
# ╠═4a5e9d2c-dd90-4bb0-9e31-3f5c834406b4
# ╟─d862fb16-edf1-11ea-36ec-615d521e6bc0
# ╟─aa1ff74a-4e78-4ef1-8b8d-3a60a168cf6d
# ╟─e3394c8a-edf0-11ea-1bb8-619f7abb6881
# ╟─e083b3e8-ed61-11ea-2ec9-217820b0a1b4
# ╠═59414833-a108-4b1e-9a34-0f31dc907c6e
# ╠═c5484572-ee05-11ea-0424-f37295c3072d
# ╠═c8ecfe5c-ee05-11ea-322b-4b2714898831
# ╟─e86ed944-ee05-11ea-3e0f-d70fc73b789c
# ╠═6ccd8902-0dd9-4335-a11a-ee7f9a1a6c09
# ╟─15088baa-c337-405d-8885-19a6e2bfd6aa
# ╠═7ad4f6bc-588e-44ab-8ca9-c87cd1048442
# ╟─a55bb5ca-600b-4aa0-b95f-7ece20845c9b
# ╠═c5dc0cc8-9305-47e6-8b20-a9f8ef867799
# ╠═de772e21-0bea-4fd2-868a-9a7d32550bc9
# ╟─21bdc692-91ee-474d-ae98-455913a2342e
# ╠═2ae3f379-96ce-435d-b863-deba4586ec71
# ╟─c49ba901-d798-489a-963c-4cc113c7abfd
# ╠═93451c37-77e1-4d4f-9788-c2a3da1401ee
# ╟─f52e4914-2926-4a42-9e45-9caaace9a7db
# ╠═a8b2270a-600c-4f83-939e-dc5ab35f4735
# ╠═c320b39d-4cea-4fa1-b1ce-053c898a67a6
# ╟─09102183-f9fb-4d89-b4f9-5d76af7b8e90
# ╟─d8cf9bd5-dbf7-4841-acf9-eef7e7cabab3
# ╠═ebe1d05c-f6aa-437d-83cb-df0ba30f20bf
# ╠═c427554a-6f6a-43f1-b03b-f83239887cee
# ╟─63ac142e-6d9d-4109-9286-030a02c900b4
# ╟─50e2b0fb-b06d-4ac1-bdfb-eab833466736
# ╟─4fd07e01-2f8b-4ec9-9f4f-8a9e5ff56fb6
# ╠═97c15896-6d99-4292-b7d7-4fcd2353656f
# ╠═cbb9bf41-4c21-42c7-b0e0-fc1ce29e0eb1
# ╟─3f1a670b-44c2-4cab-909c-65f4ae9ed14b
# ╠═21ba6e75-55a2-4614-9b5d-ea6378bf1d98
# ╟─f7825c18-ff28-4e23-bf26-cc64f2f5049a
# ╠═d994e178-78fd-46ab-a1bc-a31485423cad
# ╟─c54ccdea-ee05-11ea-0365-23aaf053b7d7
# ╠═f6898df6-ee07-11ea-2838-fde9bc739c11
# ╠═5be9b144-ee0d-11ea-2a8d-8775de265a1d
# ╟─4d0158d0-ee0d-11ea-17c3-c169d4284acb
# ╟─5f6635b4-63ed-4a62-969c-bd4084a8202f
# ╟─f6cc03a0-ee07-11ea-17d8-013991514d42
# ╠═63e8d636-ee0b-11ea-173d-bd3327347d55
# ╟─80a4cb23-49c9-4446-a3ec-b2203128dc27
# ╟─2cc2f84e-ee0d-11ea-373b-e7ad3204bb00
# ╠═b8f26960-ee0a-11ea-05b9-3f4bc1099050
# ╠═5de3a22e-ee0b-11ea-230f-35df4ca3c96d
# ╠═4e21e0c4-ee0b-11ea-3d65-b311ae3f98e9
# ╠═6dbf67ce-ee0b-11ea-3b71-abc05a64dc43
# ╟─846b1330-ee0b-11ea-3579-7d90fafd7290
# ╠═943103e2-ee0b-11ea-33aa-75a8a1529931
# ╟─55b138b7-19fb-4da1-9eb1-1e8304528251
# ╟─f68d4a36-ee07-11ea-0832-0360530f102e
# ╠═fbd1638d-8d7a-4d12-aff9-9c160cc3fd74
# ╠═f6a655f8-ee07-11ea-13b6-43ca404ddfc7
# ╟─c905b73e-ee1a-11ea-2e36-23b8e73bfdb6
# ╟─7720740e-2d2b-47f7-98fd-500ed3eee479
# ╠═90421bca-0804-4d6b-8bd0-3ddbd54cc5fe
# ╠═b2329e4c-6204-453e-8998-2414b869b808
# ╟─23fcd65f-0182-41f3-80ec-d85b05136c47
# ╠═5055b74c-b98d-41fa-a0d8-cb36200d82cc
# ╠═8db17b2b-0cf9-40ba-8f6f-2e53be7b6355
# ╟─a8a597e0-a01c-40cd-9902-d56430afd938
# ╟─f6b218c0-ee07-11ea-2adb-1968c4fd473a
# ╠═04e6b486-ceb7-45fe-a6ca-733703f16357
# ╟─a6d9635b-85ed-4590-ad09-ca2903ea8f1d
# ╟─f6bf64da-ee07-11ea-3efb-05af01b14f67
# ╠═13e9ec8d-f615-4833-b1cf-0153010ccb65
# ╟─25dad7ce-ee0b-11ea-3e20-5f3019dd7fa3
# ╠═9751586e-ee0c-11ea-0cbb-b7eda92977c9
# ╟─f6d6c71a-ee07-11ea-2b63-d759af80707b
# ╠═f38b198d-39cf-456f-a841-1ba08f206010
# ╠═8464d42a-6a01-443e-82f4-0ebf9efcc54c
# ╟─31ef3710-e4c9-4aa7-bd8f-c69cc9a977ee
# ╟─f6ef2c2e-ee07-11ea-13a8-2512e7d94426
# ╟─f6fc1312-ee07-11ea-39a0-299b67aee3d8
# ╠═db4bad9f-df1c-4640-bb34-dd2fe9bdce18
# ╟─0000b7f8-4c43-4dd8-8665-0dfe59e74c0a
# ╠═774b4ce6-ee1b-11ea-2b48-e38ee25fc89b
# ╠═2e1f9fb5-ef43-44e9-92d3-6f5df18d33d4
# ╟─14c020d1-aada-4e37-b019-e32a42ba7115
# ╠═24dd001b-adf4-4d2b-8b04-62b973058ec0
# ╟─f70823d2-ee07-11ea-2bb3-01425212aaf9
# ╠═21a5885d-00ab-428b-96c3-c28c98c4ca6d
# ╟─d896b7fd-20db-4aa9-bbcf-81b1cd44ec46
# ╠═e70a84d4-ee0c-11ea-0640-bf78653ba102
# ╠═ac15e0d0-ee0c-11ea-1eaf-d7f88b5df1d7
# ╟─9604bc44-ee1b-11ea-28f8-7f7af8d0cbb2
# ╟─f714699e-ee07-11ea-08b6-5f5169861b57
# ╠═bdc2df7c-ee0c-11ea-2e9f-7d2c085617c1
# ╟─4139ee66-ee0a-11ea-2282-15d63bcca8b8
# ╠═20402780-426b-4caa-af8f-ff1e7787b7f9
# ╠═ed9fb2ac-2680-42b7-9b00-591e45a5e105
# ╟─e87e0d14-43a5-490d-84d9-b14ece472061
# ╠═d38c6958-9300-4f7a-89cf-95ca9e899c13
# ╠═82f1e006-60fe-4ad1-b9cb-180fafdeb4da
# ╠═54c83589-b8c6-422a-b5e9-d8e0ee72a224
# ╠═18e781f8-66f3-4216-bc84-076a08f9f3fb
# ╠═ebf3193d-8c8d-4425-b252-45067a5851d9
# ╟─87dabfd2-461e-4769-ad0f-132cb2370b88
# ╠═8917529e-fa7a-412b-8aea-54f92f6270fa
# ╠═ee5f21fb-1076-42b6-8926-8bbb6ed0ad67
# ╠═9e5a08dd-332a-486b-94ab-15c49e72e522
# ╟─91f4778e-ee20-11ea-1b7e-2b0892bd3c0f
# ╟─5bd09d0d-2643-491a-a486-591657a857b3
# ╟─8ffe16ce-ee20-11ea-18bd-15640f94b839
# ╟─5842895a-ee10-11ea-119d-81e4c4c8c53b
# ╟─756d150a-b7bf-4bf5-b372-5b0efa80d987
# ╟─4bc94bec-da39-4f8a-82ee-9953ed73b6a4
# ╟─8ce6ad06-819c-4af5-bed7-56ecc08c97be
# ╟─dfa40e89-03fc-4a7a-825e-92d67ee217b2
# ╟─086ec1ff-b62d-4566-9973-5b2cc3353409
# ╟─2f6fb3a6-bb5d-4c7a-9297-84dd4b16c7c3
# ╟─c22f688b-dc04-4a94-b541-fe06266c5446
# ╟─ab3d1b70-88e8-4118-8d3e-601a8a68f72d
# ╟─8cb0aee8-5774-4490-9b9e-ada93416c089
# ╟─115ded8c-ee0a-11ea-3493-89487315feb7
# ╟─dfb7c6be-ee0d-11ea-194e-9758857f7b20
# ╟─e15ad330-ee0d-11ea-25b6-1b1b3f3d7888
# ╟─83eb9ca0-ed68-11ea-0bc5-99a09c68f867
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
