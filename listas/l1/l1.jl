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

# ╔═╡ 911ccbce-ed68-11ea-3606-0384e7580d7c
# edite o código abaixo com seu nome e email da dac (sem o @dac.unicamp.br)
student = (name="João Ninguém", email_dac="j000000")

# aperte o botão ▶ no canto inferior direito da célula para executar o que você
# editou, ou use Shift+Enter

# Agora siga na página para ver o que deve fazer.

# ╔═╡ 8ef13896-ed68-11ea-160b-3550eeabbd7d
md"""

Submetido por: **_$(student.name)_** ($(student.email_dac)@dac.unicamp.br)
"""

# ╔═╡ ac8ff080-ed61-11ea-3650-d9df06123e1f
md"""

# **Lista 1** - _imagens and arrays_
`MS513`, 1º sem. 2024

`Data de entrega`: **28/03, 2024 às 23:59**

Este caderno contem _verificações ativas das respostas_! Em alguns exercícios você verá uma caixa colorida que roda alguns casos simples de teste e provê retorno imediato para a sua solução. Edite sua solução, execute a célula e verifique se passou na verificação. Note que a verificação feita é apenas superficial. Para a correção serão verificados mais casos e você tem a obrigação de escrever código que funcione adequadamente.

Pergunte o quanto quiser (use o Discord)!
"""

# ╔═╡ 5f95e01a-ee0a-11ea-030c-9dba276aba92
md"""
#### Iniciando pacotes

_Quando você rodar esse notebook pela primeira vez, pode levar até 15 minutos instalando pacotes. Aguente firme!_
"""

# ╔═╡ 467856dc-eded-11ea-0f83-13d939021ef3
example_vector = [0.5, 0.4, 0.3, 0.2, 0.1, 0.0, 0.7, 0.0, 0.7, 0.9]

# ╔═╡ ad6a33b0-eded-11ea-324c-cfabfd658b56
md"""
#### Exercício 1.1
👉 Escreva uma função que cria um vetor de `Float64` chamado `random_vec` de comprimento 10 usando a função pré-definida `rand`. Você pode olhar a definição de `rand` usando o sistema de ajuda do Pluto.
"""

# ╔═╡ f51333a6-eded-11ea-34e6-bfbb3a69bcb0
random_vec() = missing # replace `missing` with your code!

# ╔═╡ 5da8cbe8-eded-11ea-2e43-c5b7cc71e133
begin
    colored_line(x::Vector) = Gray.(Float64.(x))'
    colored_line(x::Any) = nothing
end

# ╔═╡ 56ced344-eded-11ea-3e81-3936e9ad5777
colored_line(example_vector)

# ╔═╡ b18e2c54-edf1-11ea-0cbf-85946d64b6a2
colored_line(random_vec())

# ╔═╡ 77adb065-bfd4-4680-9c2a-ad4d92689dbf
md"#### Exercício 1.2
👉 Faça um função `mysum`, usando um laço `for`, que calcula a soma total de um vetor ou uma matriz de números. Para poder tratar os dois tipos da mesma forma use a função `eachindex`. Procure a documentação dessa função no manual de Julia."

# ╔═╡ bd907ee1-5253-4cae-b5a5-267dac24362a
function mysum(xs)
    # seu código aqui!
    return missing
end

# ╔═╡ 6640110a-d171-4b32-8d12-26979a36b718
mysum([1, 2, 3])

# ╔═╡ cf738088-eded-11ea-2915-61735c2aa990
md"#### Exercício 1.3
👉 Use sua `mysum` para escrever uma função `mymean`, que calcula a média (aritmética) de um vetor ou matriz de números. Para descobrir o número total de elementos use a função `length`."

# ╔═╡ 0ffa8354-edee-11ea-2883-9d5bfea4a236
function mymean(xs)
    # seu código aqui!
    return missing
end

# ╔═╡ 1f104ce4-ee0e-11ea-2029-1d9c817175af
mymean([1, 2, 3])

# ╔═╡ 1f229ca4-edee-11ea-2c56-bb00cc6ea53c
md"👉 Defina `a_rand` como um vetor aleatório usando `random_vec` e o valor `med` como sua média."

# ╔═╡ 2a117896-6abe-4d7b-be5b-f43cecae86e4
a_rand = missing # Substitua com seu código!

# ╔═╡ 2a391708-edee-11ea-124e-d14698171b68
med = missing # substitua `missing` com seu código!

# ╔═╡ e2863d4c-edef-11ea-1d67-332ddca03cc4
md"""#### Exercício 1.4
👉 Escreva uma função `demean`, que recebe um vetor `xs` e subtrai de cada um dos seus elementos a sua média. Use sua função `mymean`!
"""

# ╔═╡ ea8d92f8-159c-4161-8c54-bab7bc00f290
md"""
> ### Nota sobre _mutabilidade_
>
> Há duas formas de se pensar nesse exercício, uma é _modificar_ o vetor original e outra é criar um _novo vetor_ com a respota. Nós vamos, em geral, preferir a segunda opção para que os dados originais sejam preservados. Variantes que mudam o vetor original devem ser usadas apenas quando performance ou memória são importantes. Isso porque esse tipo de solução deve ser escrita e usada com mais cuidado. **De uma maneira geral siga a regra: otimize somente se tiver certeza que precisa**. Há um ditato em computação: _A mãe de todos os males é a otimização prematura_. Isso é particularmente importante se você ainda não está bem familiarizado com programação.
>
> Há também uma convenção interessante entre os programadores Julia. Funções que modificam os seus argumentos devem ter o nome terminado com um ponto de exclamação, como um lembrete para tomar cuidado, já que os dados não são preservados. Por exemplo, a função `sort(x)` não modifica o vetor de entrada, mas devolve uma cópia dele ordenada. Já `sort!(x)` ordena o próprio vetor de entrada, modificando-o.
>
> #### Dicas para escrever código "não-mutável".
> 1. _Reescrever_ uma função que altera seus parâmetros (_mutável_) em uma função que preserva os seus parâmetros pode parece algo tedioso e ineficiente. Muitas vezes é melhor encarar o que você está fazendo como a criação algo novo e não como a modificação de algo existente. Isso o colocará numa situação de achar o seu trabalho mais proveitoso e deixará os passos que deve seguir mais claros.
>
> 1. Uma alternativa simples para transformar uma função que altera os parâmetros em uma que não altera é envolvê-la em uma outra função que inicia copiando o(s) parâmetro(s) que será(ão) alterado(s) e depois chamar a função que altera parâmetros com a(s) cópia(s).
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
    # Esta célula é meio estranha mas está aqui para evitar um problema comum.
    # Ela gera novamente o mesmo vetor se você criou uma função que o altera

    # Ignore isso e continue com o seu exercício!

    demean
    to_create
end

# ╔═╡ 29e10640-edf0-11ea-0398-17dbf4242de3
md"Para verificar a sua função, vamos verificar se a média do vetor após `demean(test_vect)` é 0 : (_Devido a erros de arredondamento de ponto flutuante o valor pode *não* ser *exatamente* 0._)"

# ╔═╡ 38155b5a-edf0-11ea-3e3f-7163da7433fb
demeaned_test_vect = demean(test_vect)

# ╔═╡ 1267e961-5b75-4b55-8080-d45316a03b9b
mymean(demeaned_test_vect)

# ╔═╡ a5f8bafe-edf0-11ea-0da3-3330861ae43a
md"""
#### Exercício 1.5

👉 Escreva uma função que cria um vetor de 100 elements em que:
- Os 20 elementos centrais valem `1`, e
- todos os outros elementos valem `0`.
"""

# ╔═╡ b6b65b94-edf0-11ea-3686-fbff0ff53d08
function create_a_bar()
    # seu código aqui!
    return missing
end

# ╔═╡ 4a5e9d2c-dd90-4bb0-9e31-3f5c834406b4
create_a_bar()

# ╔═╡ d862fb16-edf1-11ea-36ec-615d521e6bc0
colored_line(create_a_bar())

# ╔═╡ 59414833-a108-4b1e-9a34-0f31dc907c6e
url = "https://www.ime.unicamp.br/~pjssilva/images/ensino/labcompsci/apolo1.png"

# ╔═╡ c5484572-ee05-11ea-0424-f37295c3072d
apolo_filename = download(url) # download to a local file. The filename is returned

# ╔═╡ c8ecfe5c-ee05-11ea-322b-4b2714898831
apolo = convert(Matrix{RGB{Float64}}, load(apolo_filename))

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
Para pegar valores de um canal individual de cor use use os  _atributos_ `r`, `g` and `b`:
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
👉 Escreva uma função **`get_r`** que pega um único pixel e retorna o valor de seu canal vermelho.
"""

# ╔═╡ a8b2270a-600c-4f83-939e-dc5ab35f4735
function get_r(pixel::AbstractRGB)
    # seu código aqui!
    return missing
end

# ╔═╡ c320b39d-4cea-4fa1-b1ce-053c898a67a6
get_r(RGB(0.8, 0.1, 0.0))

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
Vamos tentar visualizar essa matriz. Por enquanto, ela é apenas uma matriz de números e portanto é visualizada de forma textual. Note que o sistema usa elipses para não mostrar a matriz inteira, afinal de contas ela seria enorme. 

Mas, será que conseguimos **visualizar a matriz como uma imagem**?

Isso é mais simples do que parece. Queremos apenas mapear cada número em uma cor RGB que tem o número no canal vermelho (e 0 no resto). Se fizermos isso para cada número da matriz com os valores de vermelhos, voltamos para uma matriz de cores (objetos RGB) que podemos visualizar como imagem no Pluto.

Mais uma vez, vamos definir uma função que transforma um único _número_ numa _cor_.
"""

# ╔═╡ 97c15896-6d99-4292-b7d7-4fcd2353656f
function value2color(x)

    return RGB(x, zero(x), zero(x))
end

# ╔═╡ cbb9bf41-4c21-42c7-b0e0-fc1ce29e0eb1
value2color(0.0), value2color(0.6), value2color(1.0)

# ╔═╡ 3f1a670b-44c2-4cab-909c-65f4ae9ed14b
md"""
👉 Agora use as funções `get_reds` e `value2color` para visualizar o canal vermelho de `apolo_head`. Dica: pense em usar difusão (a sintaxe do ponto) para aplicar uma função _elemento-a-elemento_.

Use o botão ➕ do canto inferior esquerdo para adicionar mais células se for preciso..
"""

# ╔═╡ 21ba6e75-55a2-4614-9b5d-ea6378bf1d98


# ╔═╡ f7825c18-ff28-4e23-bf26-cc64f2f5049a
md"""

#### Exercício 2.4
👉 Escreva mais quatro funções, `get_g`, `get_greens`, `get_b` e `get_blues`, como os equivaletes de `get_r` e `get_reds` para os canais verde e azul. Se precisar, use o ➕ botão para adicionar células.
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
md"Vamos inverter algumas cores:"

# ╔═╡ b8f26960-ee0a-11ea-05b9-3f4bc1099050
color_black = RGB(0.0, 0.0, 0.0)

# ╔═╡ 5de3a22e-ee0b-11ea-230f-35df4ca3c96d
invert(color_black)

# ╔═╡ 4e21e0c4-ee0b-11ea-3d65-b311ae3f98e9
color_red = RGB(0.8, 0.1, 0.1)

# ╔═╡ 6dbf67ce-ee0b-11ea-3b71-abc05a64dc43
invert(color_red)

# ╔═╡ 846b1330-ee0b-11ea-3579-7d90fafd7290
md"👉 Você consegue inverter a imagem do Apolo"

# ╔═╡ 943103e2-ee0b-11ea-33aa-75a8a1529931
apolo_inv = missing # replace `missing` with your code!

# ╔═╡ 55b138b7-19fb-4da1-9eb1-1e8304528251
md"""
_Ao final desse caderno você poderá ver os seus filtros aplicados à imagem que capturou com a webcam!_
"""

# ╔═╡ f68d4a36-ee07-11ea-0832-0360530f102e
md"""
#### Exercício 3.2
👉 Dê uma olhada na documentação da função `floor`. Use-a para escrever uma função`quantize(x::Number)` que recebe um valor $x$ (que você pode considerar que está entre 0 e 1) e "quantiza" esse valor para pacotes de largura 0.1. Por exemplo, verifique 0.267 é mapeado a 0.2 e 0.91 para 0.9.
"""

# ╔═╡ fbd1638d-8d7a-4d12-aff9-9c160cc3fd74
function quantize(x::Number)
    # seu código aqui!
    return missing
end

# ╔═╡ 7720740e-2d2b-47f7-98fd-500ed3eee479
md"""
#### Intermezzo: _Múltiplos métodos_

Em Julia, chamamos as versões concretas de funções de métodos. Eles são escolhidas de acordo com os seus parâmetros (seja o número, seja o tipo). Daí, quando você pede para Julia dizer o que é uma função ele vai falar que é uma _função genérica_ com _XX métodos_. Vamos ver isso em ação.

Nesse primeiro exemplo temos dois _métodos_ para a mesma função. Eles são diferentes porque possuem

> **o mesmo nome, mas diferentes tipos de parâmetros de entrada**

Obs: Note que definimos o tipo do parâmetro de entrada através do anotação `::Tipo` após no nome do parâmetro.
"""

# ╔═╡ 90421bca-0804-4d6b-8bd0-3ddbd54cc5fe
function double(x::Number)

    return x * 2
end

# ╔═╡ b2329e4c-6204-453e-8998-2414b869b808
function double(x::Vector)

    return vcat(x, x)
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
Isso é chamado de **despacho múltiplo** e é uma das características principais de Julia. Nesse curso veremos vários exemplos dessa ideia em ação como forma de criar abstrações flexíveis e fáceis de entender.
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
👉 Escreva uma função `addnoise(x::Number, s)` que adiciona uma intensidade aleatória $s$ ao valor $x$, i.e. ela adiciona um valor aleatório uniforme no intervalo $[-s, +s]$ a $x$. Se, após a soma, o valor cair fora do intervalo $[0, 1]$ você deve truncar a resposta para caber nessa faixa. (Julia tem uma função já pronta chamada `clamp` que vai lhe ajudar nisso, ou você pode escrever a sua função do zero.)
"""

# ╔═╡ f38b198d-39cf-456f-a841-1ba08f206010
function addnoise(x::Number, s)
    # seu código aqui!
    return missing
end

# ╔═╡ f6fc1312-ee07-11ea-39a0-299b67aee3d8
md"""
👉  Escreva um segundo método `addnoise(c::AbstractRGB, s)` para adicionar um ruído aleatório diferente de intensidade $s$ em cada um dos canais $(r, g, b)$ da cor.

Use sua versão anterior `addnoise`. _(Lembre que Julia escolhe o método que será chamado baseado nos parâmetros de entrada. Então para chamar o método anterior o parâmetro que será passado deve ser um número.)_
"""

# ╔═╡ db4bad9f-df1c-4640-bb34-dd2fe9bdce18
function addnoise(color::AbstractRGB, s)
    # seu código aqui!
    return missing
end

# ╔═╡ 0000b7f8-4c43-4dd8-8665-0dfe59e74c0a
md"""
Amplitude do ruído:
"""

# ╔═╡ 774b4ce6-ee1b-11ea-2b48-e38ee25fc89b
@bind color_noise Slider(0:0.01:1, default=0.1, show_value=true)

# ╔═╡ 14c020d1-aada-4e37-b019-e32a42ba7115
md"""
> ### Relembrando _compreensão de array_
> Já sabemos que há algumas formas de se criar um novo array a partir de outro (ou partindo de `ranges`):
> 1. podemos usar laço for e percorrer o array
> 1. podemos usar difusão de função sobre o array
> 1. podemos usar _**compreensão de arrays**_
>
> Essa última opção é demonstrada abaixo e está baseada na sintaxe:
>
> ```[função_para_aplicar(args) for args in algo_para_percorrer]```
>
> Isso cria um novo objeto que bate com o objeto percorrido. Abaixo mostramos um exemplo em que percorremos dois ranges para criar uma matriz.
"""

# ╔═╡ f70823d2-ee07-11ea-2bb3-01425212aaf9
md"""
👉 Escreva um terceiro método `addnoise(image::AbstractMatrix, s)` que adiciona ruídos a cada pixel na imagem. Tente fazer essa função em uma única linha!
"""

# ╔═╡ 21a5885d-00ab-428b-96c3-c28c98c4ca6d
function addnoise(image::AbstractMatrix, s)
    # seu código aqui!
    return missing
end

# ╔═╡ 8464d42a-6a01-443e-82f4-0ebf9efcc54c
addnoise(0.5, 0.1) # edit this test case!

# ╔═╡ 2e1f9fb5-ef43-44e9-92d3-6f5df18d33d4
(original=color_red, with_noise=addnoise(color_red, color_noise))

# ╔═╡ 24dd001b-adf4-4d2b-8b04-62b973058ec0
[addnoise(color_red, strength) for strength = 0:0.05:1, row = 1:10]'

# ╔═╡ d896b7fd-20db-4aa9-bbcf-81b1cd44ec46
md"""

#### Exercício 3.6
Mova o slider abaixo para escolher o nível de ruído para ser aplicado na imagem do Apolo.
"""

# ╔═╡ e70a84d4-ee0c-11ea-0640-bf78653ba102
@bind apolo_noise Slider(0:0.01:1, show_value=true)

# ╔═╡ ac15e0d0-ee0c-11ea-1eaf-d7f88b5df1d7
addnoise(apolo_head, apolo_noise)

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
function my_filter(pixel::AbstractRGB)

    # seu código aqui!

    return pixel
end

# ╔═╡ 9e5a08dd-332a-486b-94ab-15c49e72e522
function my_filter(image::AbstractMatrix)

    return my_filter.(image)
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

🙋 **Sua janela é muito pequena?** Tente redimensionar a janela ou diminuir o zoom.
""" |> hint

# ╔═╡ 24090306-7395-4f2f-af31-34f7486f3945
hint(md"""Veja essa página para lembrar a sintaxe básica de Julia:

 [Basic Julia Syntax](https://computationalthinking.mit.edu/Spring21/basic_syntax/)""")

# ╔═╡ aa1ff74a-4e78-4ef1-8b8d-3a60a168cf6d
hint(
    md"""
Na aula nós desenhamos um quadrado azul sobre a imagem do Apolo com um único comando... Veja o vídeo.
""",
)

# ╔═╡ 50e2b0fb-b06d-4ac1-bdfb-eab833466736
md"""
Esse exercíco será mais difícil se você usar laços `for` ou compreensão de arrays.

Tente usar difusão [(sintaxe do dot)](https://docs.julialang.org/en/v1/manual/functions/#man-vectorized) para aplicar a função "elemento-por-elemento" em todo o array. Por exemplo, com essa função você calcula a raiz quadrada de `3`:

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
still_missing(text=md"Substitua `missing` com sua resposta.") =
    Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))

# ╔═╡ 086ec1ff-b62d-4566-9973-5b2cc3353409
keep_working(text=md"A resposta não está perfeita.") =
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
correct(text=rand(yays)) =
    Markdown.MD(Markdown.Admonition("correto", "Você acertou!", [text]))

# ╔═╡ 09102183-f9fb-4d89-b4f9-5d76af7b8e90
let
    result = get_r(RGB(0.2, 0.3, 0.4))
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
    result = addnoise(0.5, 0)

    if ismissing(result)
        still_missing()
    elseif isnothing(result)
        keep_working(md"Você esqueceu de escrever `return`?")
    elseif result == 0.5

        results = [addnoise(0.9, 0.1) for _ = 1:1000]

        if 0.8 ≤ minimum(results) < 0.81 && 0.99 ≤ maximum(results) ≤ 1
            result = addnoise(5, 3)

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
if !@isdefined(random_vec)
    not_defined(:random_vec)
elseif ismissing(random_vec())
    still_missing()
elseif !(random_vec() isa Vector)
    keep_working(md"`random_vec` deve ser um `Vector`.")
elseif eltype(random_vec()) != Float64
    almost(
        md"""
  You gerou um vetor. Mas você precisa de um vetor de pontos flutuantes (`Float64`).

  O primeiro argumento de `rand` (que é opcional) especifica o **tipo** dos elementos que ela gera. Por exemplo: `rand(Bool, 10)` gera dez valores que são `true` ou `false`. (Teste!)
  """,
    )
elseif length(random_vec()) != 10
    keep_working(md"`random_vec` não tem o comprimento correto.")
elseif length(Set(random_vec())) != 10
    keep_working(md"`random_vec` não é 'suficientemente aleatório'")
else
    correct(md"Muito bem! Você pode rodar o seu código de novo para gerar um novo vetor!")
end

# ╔═╡ e0bfc973-2808-4f84-b065-fb3d05401e30
if !@isdefined(mysum)
    not_defined(:mysum)
else
    let
        result = mysum([1, 2, 3])
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
if !@isdefined(mymean)
    not_defined(:mymean)
else
    let
        result = mymean([1, 2, 3])
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
if !@isdefined(med)
    not_defined(:med)
elseif ismissing(med)
    still_missing()
elseif !(med isa Number)
    keep_working(md"`med` deveria ser um número.")
elseif med != mymean(a_rand)
    keep_working()
else
    correct()
end

# ╔═╡ adf476d8-a334-4b35-81e8-cc3b37de1f28
if !@isdefined(mymean)
    not_defined(:mymean)
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
if !@isdefined(create_a_bar)
    not_defined(:create_a_bar)
else
    let
        result = create_a_bar()
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

# ╔═╡ 540ccfcc-ee0a-11ea-15dc-4f8120063397
md"""
$(bigbreak)

## **Exercício 1** - _Manipulando vetores ("imagens" 1D)_

Um `Vector` (vetor) é um array 1D. Se quiser pense neles como uma "imagem" 1d.

"""

# ╔═╡ e083b3e8-ed61-11ea-2ec9-217820b0a1b4
md"""
 $(bigbreak)

## **Exercício 2** - _Manipulando imagens_

Neste exercício vamos nos familiarizar com matrizes (arrays 2D) em Julia, manipulando imagens. Lembre que, em Julia, as imagens são matrizes de objetos `RGB` que represetam cores.

Vamos carregar a imagem do Apolo novamente.
"""

# ╔═╡ f6cc03a0-ee07-11ea-17d8-013991514d42
md"""
 $(bigbreak)

## Exercício 3 - _Mais filtros_

Nos exercícios anteriores, aprendemos como usar a _sintaxe do ponto_ de Julia para aplicar uma função a _cada elemento_ de um array. Neste exercício, vamos usá-la para escrever mais filtros de imagem e depois aplicá-los a sua imagem da webcam!

#### Exercício 3.1
👉 Escreva uma função `invert` que inverte uma cor, ou seja, mapeia $(r, g, b)$ em $(1 - r, 1-g, 1-b)$.
"""

# ╔═╡ 4139ee66-ee0a-11ea-2282-15d63bcca8b8
md"""
$(bigbreak)
### Camera input

Aqui você pode ver o resultado dos filtros na imagem da câmera. Se você não usar a câmera, a imagem que será manipulada será um simples quadrado 2 x 2 todo branco.
"""

# ╔═╡ 87dabfd2-461e-4769-ad0f-132cb2370b88
md"""
$(bigbreak)
### Escreva seu próprio filtro (opcional)

Pense em uma manipulação diferente que você gostaria de fazer na imagem e escreva o seu próprio filtro.
"""

# ╔═╡ 91f4778e-ee20-11ea-1b7e-2b0892bd3c0f
bigbreak

# ╔═╡ 5842895a-ee10-11ea-119d-81e4c4c8c53b
bigbreak

# ╔═╡ dfb7c6be-ee0d-11ea-194e-9758857f7b20
function camera_input(; max_size=200, default_url="https://i.imgur.com/SUmi94P.png")
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

# ╔═╡ 86b9f767-71f2-49a8-ad2d-2489293d4127
function process_raw_camera_data(raw_camera_data::Missing)
    # Avoid error when running without webcam by returning a simple white image.
    reds = [1.0 1.0; 1.0 1.0]
    greens = [1.0 1.0; 1.0 1.0]
    blues = [1.0 1.0; 1.0 1.0]
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
addnoise(cam_image, 0.5)

# ╔═╡ 8917529e-fa7a-412b-8aea-54f92f6270fa
my_filter(cam_image)

# ╔═╡ 83eb9ca0-ed68-11ea-0bc5-99a09c68f867
md"_Lista 1, version 11_"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
ImageMagick = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
Images = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
HypertextLiteral = "~0.9.4"
ImageMagick = "~1.3.1"
Images = "~0.25.2"
PlutoUI = "~0.7.39"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.4"
manifest_format = "2.0"
project_hash = "4010300179928478be0e9eee6249ab62acb0570e"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "d92ad398961a3ed262d8bf04a1a2b8340f915fef"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.5.0"
weakdeps = ["ChainRulesCore", "Test"]

    [deps.AbstractFFTs.extensions]
    AbstractFFTsChainRulesCoreExt = "ChainRulesCore"
    AbstractFFTsTestExt = "Test"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "cde29ddf7e5726c9fb511f340244ea3481267608"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.7.2"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "d57bd3762d308bded22c3b82d033bff85f6195c6"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.4.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "16351be62963a67ac4083f748fdb3cca58bfd52f"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.7"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.CEnum]]
git-tree-sha1 = "389ad5c84de1ae7cf0e28e381131c98ea87d54fc"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.5.0"

[[deps.CatIndices]]
deps = ["CustomUnitRanges", "OffsetArrays"]
git-tree-sha1 = "a0f80a09780eed9b1d106a1bf62041c2efc995bc"
uuid = "aafaddc9-749c-510e-ac4f-586e18779b91"
version = "0.2.2"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "1713c74e00545bfe14605d2a2be1712de8fbcb58"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.25.1"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "Random", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "3e22db924e2945282e70c33b75d4dde8bfa44c94"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.15.8"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "b5278586822443594ff615963b0c09755771b3e0"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.26.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "600cc5508d66b78aae350f7accdb58763ac18589"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.10"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "362a287c3aa50601b0bc359053d5c2468f0e7ce0"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.11"

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

[[deps.ComputationalResources]]
git-tree-sha1 = "52cb3ec90e8a8bea0e62e275ba577ad0f74821f7"
uuid = "ed09eef8-17a6-5b46-8889-db040fac31e3"
version = "0.3.2"

[[deps.CoordinateTransformations]]
deps = ["LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "a692f5e257d332de1e554e4566a4e5a8a72de2b2"
uuid = "150eb455-5306-5404-9cee-2592286d6298"
version = "0.6.4"

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

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "c7e3a542b999843086e2f29dac96a618c105be1d"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.12"
weakdeps = ["ChainRulesCore", "SparseArrays"]

    [deps.Distances.extensions]
    DistancesChainRulesCoreExt = "ChainRulesCore"
    DistancesSparseArraysExt = "SparseArrays"

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
git-tree-sha1 = "b66970a70db13f45b7e57fbda1736e1cf72174ea"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.17.0"

    [deps.FileIO.extensions]
    HTTPExt = "HTTP"

    [deps.FileIO.weakdeps]
    HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "43ba3d3c82c18d88471cfd2924931658838c9d8f"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.0+4"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "a641238db938fff9b2f60d08ed9030387daf428c"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.3"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "1dc470db8b1131cfc7fb4c115de89fe391b9e780"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.12.0"

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

[[deps.ImageAxes]]
deps = ["AxisArrays", "ImageBase", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "2e4520d67b0cef90865b3ef727594d2a58e0e1f8"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.11"

[[deps.ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "b51bb8cae22c66d0f6357e3bcb6363145ef20835"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.5"

[[deps.ImageContrastAdjustment]]
deps = ["ImageBase", "ImageCore", "ImageTransformations", "Parameters"]
git-tree-sha1 = "eb3d4365a10e3f3ecb3b115e9d12db131d28a386"
uuid = "f332f351-ec65-5f6a-b3d1-319c6670881a"
version = "0.3.12"

[[deps.ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "acf614720ef026d38400b3817614c45882d75500"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.4"

[[deps.ImageDistances]]
deps = ["Distances", "ImageCore", "ImageMorphology", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "08b0e6354b21ef5dd5e49026028e41831401aca8"
uuid = "51556ac3-7006-55f5-8cb3-34580c88182d"
version = "0.2.17"

[[deps.ImageFiltering]]
deps = ["CatIndices", "ComputationalResources", "DataStructures", "FFTViews", "FFTW", "ImageBase", "ImageCore", "LinearAlgebra", "OffsetArrays", "PrecompileTools", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "TiledIteration"]
git-tree-sha1 = "3447781d4c80dbe6d71d239f7cfb1f8049d4c84f"
uuid = "6a3955dd-da59-5b1f-98d4-e7296123deb5"
version = "0.7.6"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "437abb322a41d527c197fa800455f79d414f0a3c"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.8"

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
git-tree-sha1 = "355e2b974f2e3212a75dfb60519de21361ad3cb7"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.9"

[[deps.ImageMorphology]]
deps = ["ImageCore", "LinearAlgebra", "Requires", "TiledIteration"]
git-tree-sha1 = "e7c68ab3df4a75511ba33fc5d8d9098007b579a8"
uuid = "787d08f9-d448-5407-9aad-5290dd7ab264"
version = "0.3.2"

[[deps.ImageQualityIndexes]]
deps = ["ImageContrastAdjustment", "ImageCore", "ImageDistances", "ImageFiltering", "LazyModules", "OffsetArrays", "PrecompileTools", "Statistics"]
git-tree-sha1 = "783b70725ed326340adf225be4889906c96b8fd1"
uuid = "2996bd0c-7a13-11e9-2da2-2f5ce47296a9"
version = "0.3.7"

[[deps.ImageSegmentation]]
deps = ["Clustering", "DataStructures", "Distances", "Graphs", "ImageCore", "ImageFiltering", "ImageMorphology", "LinearAlgebra", "MetaGraphs", "RegionTrees", "SimpleWeightedGraphs", "StaticArrays", "Statistics"]
git-tree-sha1 = "44664eea5408828c03e5addb84fa4f916132fc26"
uuid = "80713f31-8817-5129-9cf8-209ff8fb23e1"
version = "1.8.1"

[[deps.ImageShow]]
deps = ["Base64", "ColorSchemes", "FileIO", "ImageBase", "ImageCore", "OffsetArrays", "StackViews"]
git-tree-sha1 = "3b5344bcdbdc11ad58f3b1956709b5b9345355de"
uuid = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
version = "0.3.8"

[[deps.ImageTransformations]]
deps = ["AxisAlgorithms", "ColorVectorSpace", "CoordinateTransformations", "ImageBase", "ImageCore", "Interpolations", "OffsetArrays", "Rotations", "StaticArrays"]
git-tree-sha1 = "8717482f4a2108c9358e5c3ca903d3a6113badc9"
uuid = "02fcd773-0e25-5acc-982a-7f6622650795"
version = "0.9.5"

[[deps.Images]]
deps = ["Base64", "FileIO", "Graphics", "ImageAxes", "ImageBase", "ImageContrastAdjustment", "ImageCore", "ImageDistances", "ImageFiltering", "ImageIO", "ImageMagick", "ImageMetadata", "ImageMorphology", "ImageQualityIndexes", "ImageSegmentation", "ImageShow", "ImageTransformations", "IndirectArrays", "IntegralArrays", "Random", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "StatsBase", "TiledIteration"]
git-tree-sha1 = "5fa9f92e1e2918d9d1243b1131abe623cdf98be7"
uuid = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
version = "0.25.3"

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

[[deps.IntegralArrays]]
deps = ["ColorTypes", "FixedPointNumbers", "IntervalSets"]
git-tree-sha1 = "b842cbff3f44804a84fda409745cc8f04c029a20"
uuid = "1d092043-8f09-5a30-832f-7509e371ab51"
version = "0.1.6"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl"]
git-tree-sha1 = "0f14a5456bdc6b9731a5682f439a672750a09e48"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2025.0.4+0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "721ec2cf720536ad005cb38f50dbba7b02419a15"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.14.7"

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

[[deps.IrrationalConstants]]
git-tree-sha1 = "e2222959fbc6c19554dc15174c81bf7bf3aa691c"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.4"

[[deps.IterTools]]
git-tree-sha1 = "42d5f897009e7ff2cf88db414a389e5ed1bdd023"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.10.0"

[[deps.JLD2]]
deps = ["FileIO", "MacroTools", "Mmap", "OrderedCollections", "PrecompileTools", "Requires", "TranscodingStreams"]
git-tree-sha1 = "89e1e5c3d43078d42eed2306cab2a11b13e5c6ae"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.54"

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

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

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

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

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

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.MetaGraphs]]
deps = ["Graphs", "JLD2", "Random"]
git-tree-sha1 = "1130dbe1d5276cb656f6e1094ce97466ed700e5a"
uuid = "626554b9-1ddb-594c-aa3c-2596fe9399a5"
version = "0.7.2"

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

[[deps.NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "8a3271d8309285f4db73b4f662b1b290c715e85e"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.21"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore", "ImageMetadata"]
git-tree-sha1 = "d92b107dbb887293622df7697a2223f9f8176fcd"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.1.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
git-tree-sha1 = "5e1897147d1ff8d98883cda2be2187dcf57d8f0c"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.15.0"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

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
version = "0.8.1+4"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "cc4054e898b852042d7b503313f7ad03de99c3dd"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.0"

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

[[deps.Quaternions]]
deps = ["LinearAlgebra", "Random", "RealDot"]
git-tree-sha1 = "994cc27cdacca10e68feb291673ec3a76aa2fae9"
uuid = "94ee1d12-ae83-5a48-8b1c-48b8ff168ae0"
version = "0.7.6"

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

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "1342a47bf3260ee108163042310d26f2be5ec90b"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.5"
weakdeps = ["FixedPointNumbers"]

    [deps.Ratios.extensions]
    RatiosFixedPointNumbersExt = "FixedPointNumbers"

[[deps.RealDot]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9f0a1b71baaf7650f4fa8a1d168c7fb6ee41f0c9"
uuid = "c1ae055f-0cd5-4b69-90a6-9a35b1a98df9"
version = "0.1.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RegionTrees]]
deps = ["IterTools", "LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "4618ed0da7a251c7f92e869ae1a19c74a7d2a7f9"
uuid = "dee08c22-ab7f-5625-9660-a9af2021b33f"
version = "0.3.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.Rotations]]
deps = ["LinearAlgebra", "Quaternions", "Random", "StaticArrays"]
git-tree-sha1 = "5680a9276685d392c87407df00d57c9924d9f11e"
uuid = "6038ab10-8711-5258-84ad-4b1120ba62dc"
version = "1.7.1"

    [deps.Rotations.extensions]
    RotationsRecipesBaseExt = "RecipesBase"

    [deps.Rotations.weakdeps]
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMD]]
deps = ["PrecompileTools"]
git-tree-sha1 = "fea870727142270bdf7624ad675901a1ee3b4c87"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.7.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"
version = "1.11.0"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.SimpleWeightedGraphs]]
deps = ["Graphs", "LinearAlgebra", "Markdown", "SparseArrays"]
git-tree-sha1 = "4b33e0e081a825dbfaf314decf58fa47e53d6acb"
uuid = "47aef6b3-ad0c-573a-a1e2-d07658019622"
version = "1.4.0"

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

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "64cca0c26b4f31ba18f13f6c12af7c85f478cfde"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.5.0"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "0feb6b9031bd5c51f9072393eb5ab3efd31bf9e4"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.13"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

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

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "SIMD", "UUIDs"]
git-tree-sha1 = "38f139cc4abf345dd4f22286ec000728d5e8e097"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.10.2"

[[deps.TiledIteration]]
deps = ["OffsetArrays"]
git-tree-sha1 = "5683455224ba92ef59db72d10690690f4a8dc297"
uuid = "06e1c1a7-607b-532d-9fad-de7d9aa2abac"
version = "0.3.1"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

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

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "5f24e158cf4cee437052371455fe361f526da062"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.6"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "446b23e73536f84e8037f5dce465e92275f6a308"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

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
"""

# ╔═╡ Cell order:
# ╟─8ef13896-ed68-11ea-160b-3550eeabbd7d
# ╠═911ccbce-ed68-11ea-3606-0384e7580d7c
# ╟─ac8ff080-ed61-11ea-3650-d9df06123e1f
# ╟─5f95e01a-ee0a-11ea-030c-9dba276aba92
# ╠═65780f00-ed6b-11ea-1ecf-8b35523a7ac0
# ╟─29dfe3d6-c353-4081-8192-b12f374bf702
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
# ╠═2a117896-6abe-4d7b-be5b-f43cecae86e4
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
# ╠═d862fb16-edf1-11ea-36ec-615d521e6bc0
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
# ╠═e15ad330-ee0d-11ea-25b6-1b1b3f3d7888
# ╠═86b9f767-71f2-49a8-ad2d-2489293d4127
# ╟─83eb9ca0-ed68-11ea-0bc5-99a09c68f867
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
