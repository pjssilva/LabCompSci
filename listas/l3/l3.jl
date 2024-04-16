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

# ╔═╡ a4937996-f314-11ea-2ff9-615c888afaa8
begin
    using Colors
    using PlutoUI
    using Compose
    using LinearAlgebra
    import Unicode
end

# ╔═╡ 85cfbd10-f384-11ea-31dc-b5693630a4c5
md"""
# **Lista 3**: _Estrutura e linguagem_
`MS513`, 1º sem. 2024

`Data de entrega`: **23/04, 2024**

Este caderno contém _verificações ativas das respostas_! Em alguns exercícios você verá uma caixa colorida que roda alguns casos simples de teste e provê retorno imediato para a sua solução. Edite sua solução, execute a célula e verifique se passou na verificação. Note que a verificação feita é apenas superficial. Para a correção serão verificados mais casos e você tem a obrigação de escrever código que funcione adequadamente.

Pergunte o quanto quiser (use o Discord)!
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

_Quando executado a primeira vez pode demorar por instalar pacotes._
"""

# ╔═╡ c75856a8-1f36-4659-afb2-7edb14894ea1
md"""
# Introdução
"""

# ╔═╡ c9a8b35d-2183-4da1-ae35-d2552020e8a8
md"""
Até agora no curso nós lidamos principalmente com dados em formatos de imagens. Mas existem muitas outras formas de dados e esse notebook vai introduzir outro formato, o **texto**. Nesse sentido, essa lista vai também avaliar a sua capacidade de aprender à medida que resolve os exercícios usando o que já aprendeu e o que irá aprender com a leitura.

Haverá um certo enfoque em texto escrito em _linguagem natural_ (para contrastar com a linguagens típicas de computadores).

Vamos tentar analisar e gerar texto em linguagem natural, por vezes em português e em inglês. De fato o processamento e geração de linguagem natural é uma área muito ativa de Inteligência Artificial, como é o caso de modelos de redes neurais profundas como o [ChatGPT](https://en.wikipedia.org/wiki/ChatGPT).
"""

# ╔═╡ 6f9df800-f92d-11ea-2d49-c1aaabd2d012
md"""
## **Exercício 1:** _Detecção de idioma_

Nesse primeiro exercício vamos criar uma _inteligência artificial_ bastante simples. A linguagem natural é bastante complexa, mas há uma estrutura subjacente que podemos explorar. 

Vamos começar com uma estrutura muito simples de textos em português ou inglês (e outras línguas ocidentais): o conjunto de caracteres usando na escrita. Se gerarmos texto aleatório gerando caracteres `Char` quaisquer, quase com certeza não iremos obter algo reconhecível:
"""

# ╔═╡ 3206c771-495a-43a9-b707-eaeb828a8545
rand(Char, 5)   # Amostra 5 caracteres aleatórios em toda tabela UTF-8

# ╔═╡ b61722cc-f98f-11ea-22ae-d755f61f78c3
String(rand(Char, 40))   # Une 40 caracteres aleatórios em uma 
# cadeia de caractes (string)

# ╔═╡ 59f2c600-2b64-4562-9426-2cfed9a864e4
md"""
(`Char` em Julia é o tipo para um caracter [Unicode](https://en.wikipedia.org/wiki/Unicode). Unicode contém muitos conjuntos diferentes de caracteres, que cobrem a maioria das línguas do planeta (como caracteres latinos, gregos, cirílico, chinês) e de fora do planeta (tem Klingon, pelo menos) e até emojis. Daí, os caracteres latinos são minoria e por isso aparecem raramente em amostras aleatórias.)
"""

# ╔═╡ f457ad44-f990-11ea-0e2d-2bb7627716a8
md"""
Para contornar isso, vamos definir um vetor de caracteres, que vamos chamar de `alphabet`. Ele irá conter apenas as letras usuais. Para deixar as coisas bem simples, vamos considerar apenas caracteres minúsculos e o espaço em branco, sem acentos, sem pontuação. Vamos então usar apenas 27 caracteres. Observer que usamos notação de concatenação de vetores abaixo.
"""

# ╔═╡ 4efc051e-f92e-11ea-080e-bde6b8f9295a
alphabet = ['a':'z'; ' ']   # inclui o espaço em branco

# ╔═╡ 38d1ace8-f991-11ea-0b5f-ed7bd08edde5
md"""
Podemos agora amostrar de forma aleatória desse vetor.
"""

# ╔═╡ ddf272c8-f990-11ea-2135-7bf1a6dca0b7
String(rand(alphabet, 40))

# ╔═╡ 3cc688d2-f996-11ea-2a6f-0b4c7a5b74c2
md"""
Já parece melhor, mas ainda está bem longe de um texto natural em português ou inglês. Vamos tentar fazer melhor.

## Tabelas de frequência

Palavras em uma língua não são obtidas escolhendo-se os caracteres de forma aleatória. Em particular, podemos partir da observação que *algumas letras são mais comuns que outras*. Podemos operacionalizar isso obtendo uma tabela de frequência dos caracteres a partir de uma amostra de texto que seja representativa da linguagem.

As amostras a seguir foram obtidas da Wikipedia. Sinta-se à vontade de testar com sua própria amostra. 

Lembre-se que o símbolo $(html"<img src='https://cdn.jsdelivr.net/gh/ionic-team/ionicons@5.0.0/src/svg/eye-outline.svg' style='width: 1em; height: 1em; margin-bottom: -.2em;'>") do lado direito de cada célula é usado para esconder ou mostrar o código que gerou o resultado. Note o uso da função `unaccent` que tira os acentos da amostra em português. Você poderá ver a implementação dela mais abaixo.

Nós também incluímos uma amostra de inglês, que será usada depois.
"""

# ╔═╡ d67034d0-f92d-11ea-31c2-f7a38ebb412f
samples = (
    Portuguese = """
  Floresta é uma área com alta densidade de árvores.[1] Segundo dados da Organização das Nações Unidas para a Alimentação e a Agricultura, as florestas ocupavam em 2006 cerca de 4 bilhões de hectares ou aproximadamente 30% da superfície terrestre.[2] As florestas são vitais para a vida do ser humano, devido a muitos fatores principalmente de ordem climática.[3][4][2] As florestas são o ecossistema terrestre dominante da Terra e são distribuídas ao redor do globo.[5] De acordo com a definição amplamente utilizada, da Organização para a Alimentação e a Agricultura, as florestas cobriam 41 milhões de km² do globo em 1990 e 39,9 milhões de km² em 2016.[6]

  A mais conhecida floresta é a floresta Amazônica, maior que muitos países. Erroneamente considerada o Pulmão do Mundo, não é, pois foi comprovado cientificamente que a floresta Amazônica consome cerca de 65% do oxigênio que produz (com a fotossíntese) com a respiração e transpiração das plantas. A taiga siberiana é a maior floresta do mundo, sendo que este bioma estende-se para além da Sibéria, nomeadamente, pelo Alasca, Canadá, Groenlândia, Norte da Europa e Japão.[7] 
  	
  A origem das árvores e florestas no Devoniano Central foi um ponto de virada na história da Terra, marcando mudanças permanentes na ecologia terrestre, ciclos geoquímicos, níveis atmosféricos de CO2 e clima. Um sistema de raízes amplo, em solos fósseis na região de Catskill, perto do Cairo, Nova York, mostrando a presença de árvores com folhas e madeira, evidenciaram árvores de 385 milhões de anos que existiam durante o período devoniano.[8]	
  """,
    English = """
   Although the word forest is commonly used, there is no universally recognised precise definition, with more than 800 definitions of forest used around the world.[4] Although a forest is usually defined by the presence of trees, under many definitions an area completely lacking trees may still be considered a forest if it grew trees in the past, will grow trees in the future,[9] or was legally designated as a forest regardless of vegetation type.[10][11]
   	
   The word forest derives from the Old French forest (also forès), denoting "forest, vast expanse covered by trees"; forest was first introduced into English as the word denoting wild land set aside for hunting[14] without the necessity in definition of having trees on the land.[15] Possibly a borrowing, probably via Frankish or Old High German, of the Medieval Latin foresta, denoting "open wood", Carolingian scribes first used foresta in the Capitularies of Charlemagne specifically to denote the royal hunting grounds of the King. The word was not endemic to Romance languages, e. g. native words for forest in the Romance languages derived from the Latin silva, which denoted "forest" and "wood(land)" (confer the English sylva and sylvan); confer the Italian, Spanish, and Portuguese selva; the Romanian silvă; and the Old French selve, and cognates in Romance languages, e. g. the Italian foresta, Spanish and Portuguese floresta, etc., are all ultimately derivations of the French word. 
   """,
)

# ╔═╡ a094e2ac-f92d-11ea-141a-3566552dd839
md"""
#### Exercise 1.1 - _Limpeza de dados_

Olhando a amostra, podemos ver que mesmo após a retirada dos acentos ela ainda possui muitos outros caracteres que não estão considerados em `alphabet` (letras sem acentos em minúsculas e espaço em branco): sinais de pontuação, colchetes, alguns números, etc. 

Vamos limpar os dados usando a função `filter` do Julia.
"""

# ╔═╡ 27c9a7f4-f996-11ea-1e46-19e3fc840ad9
filter(isodd, [6, 7, 8, 9, -5])

# ╔═╡ f2a4edfa-f996-11ea-1a24-1ba78fd92233
md"""
`filter` recebe dois argumentos. uma **função** e uma **coleção**. A função é então aplicada em cada elemento da coleção. Ela deve retornar `true` ou `false` para cada elemento. (Esse tipo de função pode ser chamada de um **predicado**). Ao final ela devolve uma coleção com os elementos para o qual o resultado da função foi `true`.

Uma coisa interessante é lembrar que em Julia funções são _objetos_ como outros quaisquer. Eles podem ser atribuídos à variáveis ou passados a outras funções sem necessitar de nenhuma sintaxe especial.


$(html"<br>")

Abaixo apresentamos a função `isinalphabet`, que recebe um caracter e decide se ele está no nosso alfabeto ou não:
"""

# ╔═╡ 5c74a052-f92e-11ea-2c5b-0f1a3a14e313
function isinalphabet(character)
    character ∈ alphabet
end

# ╔═╡ dcc4156c-f997-11ea-3e6f-057cd080d9db
isinalphabet('a'), isinalphabet('+')

# ╔═╡ 129fbcfe-f998-11ea-1c96-0fd3ccd2dcf8
md"👉 Use `filter` para extrair apenas os caracteres que estão no `alphabet` da frase `messy_sentence_1`:"

# ╔═╡ 3a5ee698-f998-11ea-0452-19b70ed11a1d
messy_sentence_1 = "#wow 2020 ¥500 (blingbling!)"

# ╔═╡ 75694166-f998-11ea-0428-c96e1113e2a0
cleaned_sentence_1 = missing

# ╔═╡ 05f0182c-f999-11ea-0a52-3d46c65a049e
md"""
Nós também não estamos interessados em diferenciar letras maiúsculas de minúsculas. Então, queremos *mapear* letras maiúsculas na respectiva letra minúscula antes de aplicar o filtro. Se não o fizermos, as letras maiúsculas serão apagadas.

Julia possui uma função `map` que faz exatamente isso. Ela é parecida com `filter` ao receber uma função como primeiro argumento e uma coleção como segundo. Mas agora o que ela faz é construir uma nova coleção com os valores da função dada no primeiro argumento aplicada sobre os elementos da coleção.

Já para o caso particular, converter letras para minúsculas, Julia possui uma função pronta chamada `lowercase`. Ela também pode receber uma `String` de entrada e converter cada caracter, assim como faríamos com `map`. Então, abaixo, você nem precisa usar `map`. Mas eu não podia deixar de comentar sobre a existência de `map` já nessa primeira oportunidade.  
"""

# ╔═╡ 98266882-f998-11ea-3270-4339fb502bc7
md"👉 Use a função `lowercase` para converter `messy_sentence_2` em minúsculas e depois use `filter` para extrair apenas os caracteres do nosso alfabeto."

# ╔═╡ d3c98450-f998-11ea-3caf-895183af926b
messy_sentence_2 = "Awesome! 😍"

# ╔═╡ d3a4820e-f998-11ea-2a5c-1f37e2a6dd0a
cleaned_sentence_2 = missing

# ╔═╡ aad659b8-f998-11ea-153e-3dae9514bfeb
md"""
Por fim, precisamos lidar com **acentos**: simplesmente apagar caracteres acentuados dos textos vai acabar alterando as frequências demais, particularmente em português. Uma opção seria adicionar caracteres acentuados a nosso alfabeto, mas vamos fazer algo ainda mais simples: vamos substituir os caracteres acentuados por sua versão sem acentos. Julia já tem uma rotina que faz quase isso e vamos usá-la para como base da função `unaccent` abaixo.
"""

# ╔═╡ 734851c6-f92d-11ea-130d-bf2a69e89255
"""
Turn `"áéíóúüñ asdf"` into `"aeiouun asdf"`.
"""
unaccent(str) = Unicode.normalize(str, stripmark = true)

# ╔═╡ d236b51e-f997-11ea-0c55-abb11eb35f4d
french_word = "Égalité!"

# ╔═╡ a56724b6-f9a0-11ea-18f2-991e0382eccf
unaccent(french_word)

# ╔═╡ 8d3bc9ea-f9a1-11ea-1508-8da4b7674629
md"""
👉 Agora vamos colocar tudo junto. Escreva uma função chamada `clean` que recebe uma cadeia de caracteres e retorna sua versão "limpa" onde:
- caracteres acentuados são substituídos por sua versão sem acentos;
- letras maiúsculas são convertidas para minúsculas;
- elimina (filtra) caracteres que não estão contidos em `alphabet`.
"""

# ╔═╡ 4affa858-f92e-11ea-3ece-258897c37e51
function clean(text)

    return "missing" * join('a':'z')  # Change with your solution
end

# ╔═╡ e00d521a-f992-11ea-11e0-e9da8255b23b
clean("Crème brûlée est mon plat préféré.")

# ╔═╡ eaa8c79e-f9a2-11ea-323f-8bb2bd36e11c
md"""
#### Exercício 1.2 - _Frequência de letras_

Nós vamos agora contar a _frequência_ com que as letras aparecem na amostra após aplicarmos a função `clean`. Será que você sabe qual é a mais frequente?
"""

# ╔═╡ 2680b506-f9a3-11ea-0849-3989de27dd9f
first_sample = clean(first(samples))

# ╔═╡ 571d28d6-f960-11ea-1b2e-d5977ecbbb11
function letter_frequencies(txt)
    ismissing(txt) && return missing
    f = count.(string.(alphabet), txt)
    f ./ sum(f)
end

# ╔═╡ 11e9a0e2-bc3d-4130-9a73-7c2003595caa
alphabet

# ╔═╡ 6a64ab12-f960-11ea-0d92-5b88943cdb1a
sample_freqs = letter_frequencies(first_sample)

# ╔═╡ 603741c2-f9a4-11ea-37ce-1b36ecc83f45
md"""
O resultado é um vetor de 27 elementos com valores entre 0.0 e 1.0. Esses valores correspondem à frequência de cada letra. 

`sample_freqs[i] == 0.0` indica que a $i$-ésima letra não apareceu na amostra, e
`sample_freqs[i] == 0.1` indica que 10% das letras na amostra correspondiam a $i$-ésima letra.

Para facilitar a conversão entre um caracter do alfabeto e um índice, nós temos a rotina abaixo:
"""

# ╔═╡ b3de6260-f9a4-11ea-1bae-9153a92c3fe5
index_of_letter(letter) = findfirst(isequal(letter), alphabet)

# ╔═╡ a6c36bd6-f9a4-11ea-1aba-f75cecc90320
index_of_letter('a'), index_of_letter('b'), index_of_letter(' ')

# ╔═╡ 6d3f9dae-f9a5-11ea-3228-d147435e266d
md"""
$(html"<br>")

👉 Quais letras do alfabeto não ocorreram na amostra?
"""

# ╔═╡ 92bf9fd2-f9a5-11ea-25c7-5966e44db6c6
unused_letters = ['a', 'b', 'c'] # Substitua com sua solução

# ╔═╡ dcffd7d2-f9a6-11ea-2230-b1afaecfdd54
md"""
Agora que conhecemos as frequências das letras em português, podemos gerar textos aleatórios que se parecem um pouco mais com nossa língua. Compare.

**Letras aleatórios em `alphabet`:**
"""

# ╔═╡ 01215e9a-f9a9-11ea-363b-67392741c8d4
md"""
**Letras aleatórias com as frequências corretas:**
"""

# ╔═╡ 8ae13cf0-f9a8-11ea-3919-a735c4ed9e7f
md"""
Simplesmente considerando _frequências_ corretas, já conseguimos ver o nosso modelo dando respostas mais razoáveis.

Nossa próxima observação é que algumas **combinações de letras são mais comuns que outras**. O nosso modelo considera ainda que "sapato" é tão comum quando "aaotps". Na próxima seção vamos considerar também essas _frequências de transição_ e usá-las para melhorar o modelo.
"""

# ╔═╡ 343d63c2-fb58-11ea-0cce-efe1afe070c2


# ╔═╡ 77623f3e-f9a9-11ea-2f46-ff07bd27cd5f
md"""
#### Exercício 1.3 - _Frequências de transição_

Nos exercícios anteriores nós calculamos a frequência de cada letra na amostra _contando_ suas ocorrências e depois dividindo pelo o número total de letras.

Neste exercícios nós vamos contar o _as transições entre letras_, como `aa`, `as`, `rt`, `rr`. Duas letras isoladas podem ser comuns, como `a`  e `e`, mas a sua combinação `ae`  bem mais rara.

Para quantificar essa observação vamos fazer o mesmo que no último exercício: vamos contar as ocorrências em uma _amostra de texto_ e criar uma **matriz de frequências de transição**.
"""

# ╔═╡ fbb7c04e-f92d-11ea-0b81-0be20da242c8
function transition_counts(cleaned_sample)
    [count(string(a, b), cleaned_sample) for a in alphabet, b in alphabet]
end

# ╔═╡ 80118bf8-f931-11ea-34f3-b7828113ffd8
normalize_array(x) = x ./ sum(x)

# ╔═╡ 7f4f6ce4-f931-11ea-15a4-b3bec6a7e8b6
transition_frequencies = normalize_array ∘ transition_counts;

# ╔═╡ d40034f6-f9ab-11ea-3f65-7ffd1256ae9d
transition_frequencies(first_sample)

# ╔═╡ 689ed82a-f9ae-11ea-159c-331ff6660a75
md"O que obtemos é uma **matriz 27 × 27**. Cada entrada corresponde a um par de caracteres. A _linha_ representa o primeiro caracter, já a _coluna_ o segundo. Vamos visualizar essa disposição:"

# ╔═╡ aa2a73f6-0c1d-4be1-a414-05a6f8ce04bd
md"""
O brilho no fundo de cada par de letras indica o quão frequente o par é. O espaço é representado por `_`. Note que as duas matrizes acima só ficam interessantes quando você implementar a função `clean` do exercício 1.1. Caso contrário o texto processador é simplesmente `missing` que quase não tem informação interessante.
"""

# ╔═╡ 0b67789c-f931-11ea-113c-35e5edafcbbf
md"""
Responda as perguntas a seguir com respeito à **amostra limpa de português**, que chamamos de `first_sample`. Vamos também dar um nome para a matriz de transição:
"""

# ╔═╡ 6896fef8-f9af-11ea-0065-816a70ba9670
sample_freq_matrix = transition_frequencies(first_sample);

# ╔═╡ 39152104-fc49-11ea-04dd-bb34e3600f2f
if first_sample === missing
    md"""
    !!! danger "Don't worry!"
        👆 These errors will disappear automatically once you have completed the earlier exercises!
    """
end

# ╔═╡ e91c6fd8-f930-11ea-01ac-476bbde79079
md"""👉 Qual a frequência da combinação `"lh"`?"""

# ╔═╡ 1b4c0c28-f9ab-11ea-03a6-69f69f7f90ed
lh_frequency = missing

# ╔═╡ 1f94e0a2-f9ab-11ea-1347-7dd906ebb09d
md"""👉 E de `"hl"`?"""

# ╔═╡ 41b2df7c-f931-11ea-112e-ede3b16f357a
hl_frequency = missing

# ╔═╡ 1dd1e2f4-f930-11ea-312c-5ff9e109c7f6
md"""
👉 Escreva código que devolve um vetor com letras aparecem repetidas (por exemplo o `r` que está associado ao padrão repetido `rr`) na amostra.
"""

# ╔═╡ 65c92cac-f930-11ea-20b1-6b8f45b3f262
double_letters = ['a', 'b', 'c'] # replace with your answer

# ╔═╡ 4582ebf4-f930-11ea-03b2-bf4da1a8f8df
md"""
👉 Qual a primeira letra de `alphabet` com chance máxima de seguir um **B**?

_Faça isso à mão ou com código, o que for mais fácil para você!_
"""

# ╔═╡ 7898b76a-f930-11ea-2b7e-8126ec2b8ffd
most_likely_to_follow_w = 'x' # replace with your answer

# ╔═╡ 458cd100-f930-11ea-24b8-41a49f6596a0
md"""
👉 Qual a primeira letra de `alphabet` com chance máxima de preceder um **B**?
"""

# ╔═╡ bc401bee-f931-11ea-09cc-c5efe2f11194
most_likely_to_precede_w = 'x' # replace with your answer

# ╔═╡ 45c20988-f930-11ea-1d12-b782d2c01c11
md"""
👉 Qual a soma de cada linha? E qual a soma de cada coluna? Qual a soma de todos os elementos da matriz? Como podemos interpretar esses valores"
"""

# ╔═╡ 58428158-84ac-44e4-9b38-b991728cd98a
row_sums = missing

# ╔═╡ 4a0314a6-7dc0-4ee9-842b-3f9bd4d61fb1
col_sums = missing

# ╔═╡ cc62929e-f9af-11ea-06b9-439ac08dcb52
row_col_answer = md"""

Blablabla
"""

# ╔═╡ 2f8dedfc-fb98-11ea-23d7-2159bdb6a299
md"""
Nós podemos então usar as frequências de transição para gerar texto aleatoriamente de forma que obedeça as essas frequências. Note, que o texto fica muito parecido com linguagem natural! Aos poucos vamos melhorando o nosso modelo.

Já deve até ser possível usar nosso modelo para gerar senhas aleatórias pronunciáveis!
"""

# ╔═╡ b7446f34-f9b1-11ea-0f39-a3c17ba740e5
@bind ex23_sample Select(
    [v => String(k) for (k, v) in zip(fieldnames(typeof(samples)), samples)],
)

# ╔═╡ 4f97b572-f9b0-11ea-0a99-87af0797bf28
md"""
**Letras aleatórias de alphabet:**
"""

# ╔═╡ 4e8d327e-f9b0-11ea-3f16-c178d96d07d9
md"""
**Letras aleatórias obedecendo as frequências corretas:**
"""

# ╔═╡ d83f8bbc-f9af-11ea-2392-c90e28e96c65
md"""
**Letras aleatórias obedecendo as frequências de transição corretas:**
"""

# ╔═╡ b5b8dd18-f938-11ea-157b-53b145357fd1
function rand_sample(frequencies)
    x = rand()
    findfirst(z -> z >= x, cumsum(frequencies ./ sum(frequencies)))
end

# ╔═╡ 0e872a6c-f937-11ea-125e-37958713a495
function rand_sample_letter(frequencies)
    alphabet[rand_sample(frequencies)]
end

# ╔═╡ 0e465160-f937-11ea-0ebb-b7e02d71e8a8
function sample_text(A, n)

    first_index = rand_sample(vec(sum(A, dims = 1)))
	
    indices = reduce(1:n; init = [first_index]) do word, _
        prev = last(word)
		col = A[prev, :]
		if sum(col) > 0.0
        	freq = normalize_array(col)
		else
			col_len = length(col)
			freq = ones(col_len) / col_len
		end
        next = rand_sample(freq)
        [word..., next]
    end

    String(alphabet[indices])
end

# ╔═╡ 6718d26c-f9b0-11ea-1f5a-0f22f7ddffe9
md"""
#### Exercício 1.4 - _Detecção de língua_
"""

# ╔═╡ 141af892-f933-11ea-1e5f-154167642809
md"""
Parece que temos agora um modelo de língua descente, no sentido que ele pelo menos entende quais são as _frequências de transição_ presentes. No exemplo acima tente alternar entre $(join(string.(fieldnames(typeof(samples))), " e ")) -- o texto claramente vai se parecer mais com a língua escolhida do que com a(s) outra(s), demonstrando que o modelo captura diferenças importantes entre as duas línguas. Isso apesar do nossos "dados de treinamento" terem sido extratos bem pequenos de texto.

Nesse exercício, vamos usar o nosso modelo para gerar um **classificador**: programa que decide automaticamente se um novo texto está em  $(join(string.(fieldnames(typeof(samples))), " ou ")). 

Essa não é uma tarefa difícil -- você sempre pode usar dicionários das duas línguas e verificar onde há mais ocorrências -- mas vamos fazer algo mais interessante e mais próximo de técnicas modernas de IA. Vamos treinar o nosso programa e, baseado no _modelo de linguagem_ que desenvolvemos, obter o classificador.
"""

# ╔═╡ 7eed9dde-f931-11ea-38b0-db6bfcc1b558
html"<h4 id='mystery-detect'>Exemplo misterioso</h4>
<p>Entre com um texto qualquer abaixo -- nós vamos descobrir em qual língua ele foi escrito!</p>" # dont delete me

# ╔═╡ 7e3282e2-f931-11ea-272f-d90779264456
@bind mystery_sample TextField(
    (70, 8),
    default = """
Small boats are typically found on inland waterways such as rivers and lakes, or in protected coastal areas. However, some boats, such as the whaleboat, were intended for use in an offshore environment. In modern naval terms, a boat is a vessel small enough to be carried aboard a ship. Anomalous definitions exist, as lake freighters 1,000 feet (300 m) long on the Great Lakes are called "boats". 
""",
)

# ╔═╡ 7df55e6c-f931-11ea-33b8-fdc3be0b6cfa
mystery_sample

# ╔═╡ 292e0384-fb57-11ea-0238-0fbe416fc976
md"""
Vamos calcular as frequências de transição na amostra misteriosa! Digite alguma coisa na caixa de texto acima e observe que a matriz de frequência atualiza automaticamente.
"""

# ╔═╡ 7dabee08-f931-11ea-0cb2-c7d5afd21551
transition_frequencies(mystery_sample)

# ╔═╡ 3736a094-fb57-11ea-1d39-e551aae62b1d
md"""
Nosso modelo irá **comparar as frequências de transição da amostra misteriosa** com as frequência que já temos das duas linguagens. Aquela que for a mais próxima será escolhida como provável linguagem do novo texto.

Mas como comparar duas matrizes? Queremos usar uma _distância_ de matrizes, uma medida de proximidade entre os seus elementos.

👉 Escreva uma função chamada `matrix_distance` que recebe duas matrizes de mesma dimensão e calcula a distância entre eles através de:

1. Subtrai elementos correspondentes;
2. Obtém o módulo de cada diferença;
3. Soma esses módulos.
"""

# ╔═╡ 13c89272-f934-11ea-07fe-91b5d56dedf8
function matrix_distance(A, B)

    return missing # do something with A .- B
end

# ╔═╡ 7d60f056-f931-11ea-39ae-5fa18a955a77
distances = map(samples) do sample
    matrix_distance(transition_frequencies(mystery_sample), transition_frequencies(sample))
end

# ╔═╡ 7d1439e6-f931-11ea-2dab-41c66a779262
try
    @assert !ismissing(distances.English)
    """<h2>Parece que esse texto está em *$(argmin(distances))*!</h2>""" |> HTML
catch
end

# ╔═╡ 8c7606f0-fb93-11ea-0c9c-45364892cbb8
md"""
Acima escrevemos código que calcula a distância com respeito às amostras originais. Se deu tudo certo o valor menor estará relacionado com a língua correta. Dê uma olhada no código. Se não conhece ainda o comando `do` de Julia, [veja o manual](https://docs.julialang.org/en/v1/base/base/#do).

#### Se quiser ler mais
Um fenômeno interessante é ver que a decomposição SVD da matriz de transição é capaz de agrupar o alfabeto em consoantes e vogais, sem precisar de mais informação sobre a língua. Veja esse [paper](http://languagelog.ldc.upenn.edu/myl/Moler1983.pdf) se quiser tentar sozinho! Como dica sugerimos tirar o espaço em branco `alphabet` (como é feito no paper) para obter resultados melhores.
"""

# ╔═╡ 82e0df62-fb54-11ea-3fff-b16c87a7d45b
md"""
## **Exercício 2** - _Geração de Línguas_

O modelo do exercício 1 tem a propriedade que ele pode ser usado para _gerar_ texto. Se por um lado isso é interessante para mostrar que ele captura alguma estrutura da língua original, o texto produzido é totalmente sem sentido: ainda não conseguimos acertar as palavras e muito menos a estrutura de frases.

Para ir um pouco além com nosso modelo, nós vamos _generalizar_ o que já fizemos. Ao invés de trabalhar com _pares de letras_, vamos trabalhar com _combinações de palavras_. E ao invés de analisarmos frequências em bigramas, vamos trabalhar com [_$n$-gramas_ ](https://pt.wikipedia.org/wiki/N-grama).


#### Conjunto de dados

Isso também quer dizer que vamos precisar de um conjunto de dados maior para treinar o modelo: o número de palavras (e suas combinações) é muito maior do que o número de letras. 

Para isso nós vamos treinar o nosso modelo no livro "Dom Casmurro" de Machado de Assis que será baixado do [Projeto Gutemberg](https://www.gutenberg.org/ebooks/55752). Esse texto clássico está em domínio público então não há problemas de fazer isso. Abaixo, nós pegamos o livro diretamente da Internet, limpamos os trechos iniciais e finais e dividimos o texto em palavras e sinais de pontuação.
"""

# ╔═╡ b7601048-fb57-11ea-0754-97dc4e0623a1
dom_casmurro = let
    raw_text = read(
        download("https://www.ime.unicamp.br/~pjssilva/research/dom_casmurro.txt"),
        String,
    )

    first_words = "Dom Casmurro"
    last_words = "FIM"
    start_index = findfirst(first_words, raw_text)[1]
    stop_index = findlast(last_words, raw_text)[end]

    raw_text[start_index:stop_index]
end;

# ╔═╡ cc42de82-fb5a-11ea-3614-25ef961729ab
function splitwords(text)
    # clean up whitespace
    cleantext = replace(text, r"\s+" => " ")

    # split on whitespace or other word boundaries
    tokens = split(cleantext, r"(\s|\b)")
end

# ╔═╡ d66fe2b2-fb5a-11ea-280f-cfb12b8296ac
dc_words = splitwords(dom_casmurro)

# ╔═╡ 4ca8e04a-fb75-11ea-08cc-2fdef5b31944
sample_words = splitwords(samples.Portuguese)

# ╔═╡ 6f613cd2-fb5b-11ea-1669-cbd355677649
md"""
#### Exercício 2.1 - _Digramas revisitados_

O objetivo dos próximos exercícios é **generalizar** o que fizemos no exercício 1. Para manter as coisas simples, vamos _dividir o nosso problema_ em problemas menores (como deve ser feito para resolver qualquer problema computacional não trivial). 

Inicialmente, aqui está uma função que pega um vetor e devolve um vetor composto de todos os **pares de vizinhos** presentes no array original. Por exemplo

```julia
bigrams([1, 2, 3, 42])
```
gera

```julia
[[1,2], [2,3], [3,42]]
```

(Aqui, usamos inteiros como se fossem as "palavras", mas a função abaixo funciona com qualquer tipo de "palavra".)
"""

# ╔═╡ 91e87974-fb78-11ea-3ce4-5f64e506b9d2
function bigrams(words)
    starting_positions = 1:length(words)-1

    map(starting_positions) do i
        words[i:i+1]
    end
end

# ╔═╡ 9f98e00e-fb78-11ea-0f6c-01206e7221d6
bigrams([1, 2, 3, 42])

# ╔═╡ d7d8cd0c-fb6a-11ea-12bf-2d1448b38162
md"""
👉 Agora é sua vez. Escreva uma função mais geral (inspirada na nossa) `ngrams` que recebe um array e um número $n$ e retorna todas as **subsequências de comprimentos $n$**. Por exemplo,

```julia
ngrams([1, 2, 3, 42], 3)
```
deve devolver

```julia
[[1,2,3], [2,3,42]]
```
e

```julia
ngrams([1, 2, 3, 42], 2) == bigrams([1, 2, 3, 42])
```
"""

# ╔═╡ 7be98e04-fb6b-11ea-111d-51c48f39a4e9
function ngrams(words, n)

    return bigrams(words) # Substitute with a solution that uses n
end

# ╔═╡ 052f822c-fb7b-11ea-382f-af4d6c2b4fdb
ngrams([1, 2, 3, 42], 3)

# ╔═╡ 067f33fc-fb7b-11ea-352e-956c8727c79f
ngrams(sample_words, 4)

# ╔═╡ 7b10f074-fb7c-11ea-20f0-034ddff41bc3
md"""
#### Exercício 2.2 - _Revisitando a matriz de frequências_
No exercício 1 usamos um array 2D para guardar as frequências dos bigramas, onde cada linha e coluna correspondia a um caracter do alfabeto. para usar trigramas, podemos então usar arrays 3D e assim por diante.

Porém, ao contar palavras no lugar de letras temos um problema: Um array 3D com uma linha, uma coluna e uma camada extra por palavra dá combinações demais para armazenar na memória do computador!
"""

# ╔═╡ 24ae5da0-fb7e-11ea-3480-8bb7b649abd5
md"""
_Dom Casmurro_ possui $(
	length(Set(dc_words))
) palavras únicas. Isso significa que existem $(
	Int(floor(length(Set(dc_words))^3 / 10^9))
) bilhões de possíveis trigramas - isso é demais!
"""

# ╔═╡ 47836744-fb7e-11ea-2305-3fa5819dc154
md"""
$(html"<br>")

Mas pensando bem, esse array enorme teria a grande *maioria das entradas iguais a zero*. Por exemplo, _"Capitú"_ é uma palavra comum no livro, mas _"Capitú Capitú Capitú"_ não ocorre no livro. Podemos usar esse fato para armazenar os dados em uma estrutura especial que não guarda os zeros, em um tipo de _matriz esparsa_.

Julia possui o pacote [`SparseArrays.jl`](https://docs.julialang.org/en/v1/stdlib/SparseArrays/index.html) que parece uma boa ideia nesse caso. Mas ele apenas lida com arrays 1D e 2D. Além disse vamos querer indexar os arrays diretamente com strings e não índices inteiros. Para isso vamos usar os **dicionários** da linguagem ou `Dict`.

Dê uma olhada no exemplo a seguir. Observe que você pode clicar na saída para ver melhor a resposta.
"""

# ╔═╡ df4fc31c-fb81-11ea-37b3-db282b36f5ef
healthy = Dict("fruits" => ["🍎", "🍊"], "vegetables" => ["🌽", "🎃", "🍕"])

# ╔═╡ c83b1770-fb82-11ea-20a6-3d3a09606c62
healthy["fruits"]

# ╔═╡ 52970ac4-fb82-11ea-3040-8bd0590348d2
md"""
(Você notou uma coisa: os dicionários não têm ordem garantida. Assim ao imprimir o dicionário os dados usados em sua criação apareceram em ordem trocada.)

Você pode adicionar ou modificar os dados de um `Dict` a qualquer momento simplesmente associando um (possivelmente novo) valor a `my_dict[key]`. Você pode verificar se um valor existe usando `haskey(my_dict, key)`.

👉 Use essas duas técnicas para escrever uma rotina chamada `word_counts` que pega um array de palavras e retorna um `Dict` com as entradas `palavra => número_de_ocorrências`.

Por exemplo,
```julia
word_counts(["to", "be", "or", "not", "to", "be"])
```
deve retornar
```julia
Dict(
	"to" => 2, 
	"be" => 2, 
	"or" => 1, 
	"not" => 1
)
```
"""

# ╔═╡ 8ce3b312-fb82-11ea-200c-8d5b12f03eea
function word_counts(words::Vector)
    counts = Dict()

    # your code here

    return counts
end

# ╔═╡ a2214e50-fb83-11ea-3580-210f12d44182
word_counts(["to", "be", "or", "not", "to", "be"])

# ╔═╡ 808abf6e-fb84-11ea-0785-2fc3f1c4a09f
md"""
👉 Escreva código para calcular quantas vezes a palavra "Capitu" aparece no Dom Casmurro.
"""

# ╔═╡ 953363dc-fb84-11ea-1128-ebdfaf5160ee
capitu_count = missing

# ╔═╡ 294b6f50-fb84-11ea-1382-03e9ab029a2d
md"""
Ótimo! Agora podemos voltar aos n-gramas. Com o objetivo de gerar texto, vamos armazenar uma _memória de completamento_. Este é um dicionário onde cada chave é um $(n - 1)$-grama, e o valor corresponde é um vetor com todas as palavras que podem completá-lo a um $n$-grama válido. Vejamos um exemplo:

```julia
let
	trigrams = ngrams(split("to be or not to be that is the question", " "), 3)
	cache = completions_cache(trigrams)
	cache == Dict(
		["to", "be"] => ["or", "that"],
		["be", "or"] => ["not"],
		["or", "not"] => ["to"],
		...
	)
end
```

Assim, para trigramas, as chaves são as primeiras duas palavras de um trigrama, e os 
valores são vetores contendo as terceiras palavras que aparecem nesses trigramas.

Se um trigrama aparece múltiplas vezes, como por exemplo "Capitu falou sorrindo", então a última palavra ("sorrindo") deve ser armazenada múltiplas vezes. Isso vai nos permitir gerar trigramas com as mesmas frequências que o texto original.

👉 Escreva a função `completion_cache`, que recebe um array de n-gramas (um array de arrays de palavras como o resultado da função `ngram`), e retorna um dicionário de completamento, como descrito acima.
"""

# ╔═╡ b726f824-fb5e-11ea-328e-03a30544037f
function completion_cache(grams)
    cache = Dict()

    # Add correct code below 
    cache = Dict(g[1:end - 1] => [g[end]] for g in grams)
end

# ╔═╡ 18355314-fb86-11ea-0738-3544e2e3e816
let
    trigrams = ngrams(split("to be or not to be that is the question", " "), 3)
    completion_cache(trigrams)
end

# ╔═╡ 472687be-995a-4cf9-b9f6-6b56ae159539
md"""
Qual informação está nessa cache? No exemplo, as palavras "to be" podem ser seguidas de "or" ou de "that". Então se estivermos gerando texto e as últimas duas palavras forem "to be", podemos olhar no cache e ver que nossas escolhas naturais para a próxima palavra é "or" ou "that".
"""

# ╔═╡ 3d105742-fb8d-11ea-09b0-cd2e77efd15c
md"""
#### Exercício 2.3 - _Escreva um romance_

Nós temos tudo o que precisamos para gerar nosso próprio romance. O passo final é selecionar n-gramas aleatoriamente de modo que o próximo n-grama tem uma intersecção com o anterior. Nós fizemos isso na função  `generate_from_ngrams` abaixo. Dê uma olhada no código ou escreva a sua própria versão.
"""

# ╔═╡ a72fcf5a-fb62-11ea-1dcc-11451d23c085
"""
	generate_from_ngrams(grams, num_words)

Given an array of ngrams (i.e. an array of arrays of words), generate a sequence of `num_words` words by sampling random ngrams.
"""
function generate_from_ngrams(grams, num_words)
    n = length(first(grams))
    cache = completion_cache(grams)

    # we need to start the sequence with at least n-1 words.
    # a simple way to do so is to pick a random ngram!
    sequence = [rand(grams)...]

    # we iteratively add one more word at a time
    for i ∈ n+1:num_words
        # the previous n-1 words
        tail = sequence[end-(n-2):end]

        # possible next words
        completions = cache[tail]

        choice = rand(completions)
        push!(sequence, choice)
    end
    sequence
end

# ╔═╡ f83991c0-fb7c-11ea-0e6f-1f80709d00c1
"Compute the ngrams of an array of words, but add the first n-1 at the end, to ensure that every ngram ends in the the beginning of another ngram."
function ngrams_circular(words, n)
    ngrams([words..., words[1:n-1]...], n)
end

# ╔═╡ abe2b862-fb69-11ea-08d9-ebd4ba3437d5
completion_cache(ngrams_circular(sample_words, 3))

# ╔═╡ 4b27a89a-fb8d-11ea-010b-671eba69364e
"""
	generate(source_text::AbstractString, num_token; n=3, use_words=true)

Given a source text, generate a `String` that "looks like" the original text by satisfying the same ngram frequency distribution as the original.
"""
function generate(source_text::AbstractString, s; n = 3, use_words = true)
    preprocess = if use_words
        splitwords
    else
        collect
    end

    words = preprocess(source_text)
    if length(words) < n
        ""
    else
        grams = ngrams_circular(words, n)
        result = generate_from_ngrams(grams, s)
        if use_words
            join(result, " ")
        else
            String(result)
        end
    end
end

# ╔═╡ d7b7a14a-fb90-11ea-3e2b-2fd8f379b4d8
md"
#### Demonstração iterativa

Entre com o seu próprio texto na caixa abaixo e use-o como dado de treinamento para gerar outros textos!
"

# ╔═╡ 1939dbea-fb63-11ea-0bc2-2d06b2d4b26c
@bind generate_demo_sample TextField((50, 5), default = samples.Portuguese)

# ╔═╡ 70169682-fb8c-11ea-27c0-2dad2ff3080f
md"""Using $(@bind generate_sample_n_letters NumberField(1:5, default = 2))grams for characters"""

# ╔═╡ 6a7c5425-c86c-4f22-982a-345234df15cb
NumberField

# ╔═╡ 402562b0-fb63-11ea-0769-375572cc47a8
md"""Using $(@bind generate_sample_n_words NumberField(1:5, default = 2))grams for words"""

# ╔═╡ 2521bac8-fb8f-11ea-04a4-0b077d77529e
md"""
### Machado de Assis automático

Descomente a célula abaixo para gerar texto machadiano:
"""

# ╔═╡ 49b69dc2-fb8f-11ea-39af-030b5c5053c3
# generate(dom_casmurro, 100; n=4) |> Quote

# ╔═╡ cc07f576-fbf3-11ea-2c6f-0be63b9356fc
if student.email_dac === "j000000"
    md"""
   !!! danger "Oops!"
       **Antes de submeter**, lembre de preencher seu nome e email DAC no topo desse caderno!
   	"""
end

# ╔═╡ 6b4d6584-f3be-11ea-131d-e5bdefcc791b
md"## Function library

Just some helper functions used in the notebook."

# ╔═╡ 54b1e236-fb53-11ea-3769-b382ef8b25d6
function Quote(text::AbstractString)
    text |> Markdown.Paragraph |> Markdown.BlockQuote |> Markdown.MD
end

# ╔═╡ 7e09011c-71b5-4f05-ae4a-025d48daca1d
samples.Portuguese |> Quote

# ╔═╡ b3dad856-f9a7-11ea-1552-f7435f1cb605
String(rand(alphabet, 400)) |> Quote

# ╔═╡ be55507c-f9a7-11ea-189c-4ffe8377212e
if sample_freqs !== missing
    String([rand_sample_letter(sample_freqs) for _ = 1:400]) |> Quote
end

# ╔═╡ 46c905d8-f9b0-11ea-36ed-0515e8ed2621
String(rand(alphabet, 400)) |> Quote

# ╔═╡ 489b03d4-f9b0-11ea-1de0-11d4fe4e7c69
String([rand_sample_letter(letter_frequencies(ex23_sample)) for _ = 1:400]) |> Quote

# ╔═╡ fd202410-f936-11ea-1ad6-b3629556b3e0
sample_text(transition_frequencies(clean(ex23_sample)), 400) |> Quote

# ╔═╡ b5dff8b8-fb6c-11ea-10fc-37d2a9adae8c
generate(generate_demo_sample, 400; n = generate_sample_n_letters, use_words = false) |>
Quote

# ╔═╡ ee8c5808-fb5f-11ea-19a1-3d58217f34dc
generate(generate_demo_sample, 100; n = generate_sample_n_words, use_words = true) |> Quote

# ╔═╡ ddef9c94-fb96-11ea-1f17-f173a4ff4d89
function compimg(
    img,
    labels = [
        c * d for c in replace(alphabet, ' ' => "_"), d in replace(alphabet, ' ' => "_")
    ],
)
    xmax, ymax = size(img)
    xmin, ymin = 0, 0
    arr = [(j - 1, i - 1) for i = 1:ymax, j = 1:xmax]

    compose(
        context(units = UnitBox(xmin, ymin, xmax, ymax)),
        fill(vec(img)),
        compose(
            context(),
            fill("white"),
            font("monospace"),
            text(first.(arr) .+ 0.1, last.(arr) .+ 0.6, labels),
        ),
        rectangle(first.(arr), last.(arr), fill(1.0, length(arr)), fill(1.0, length(arr))),
    )
end

# ╔═╡ b7803a28-fb96-11ea-3e30-d98eb322d19a
function show_pair_frequencies(A)
    imshow = let
        to_rgb(x) = RGB(0.36x, 0.82x, 0.8x)
        to_rgb.(2.0 * A ./ maximum(abs.(A)))
    end
    compimg(imshow)
end

# ╔═╡ ace3dc76-f9ae-11ea-2bee-3d0bfa57cfbc
show_pair_frequencies(transition_frequencies(first_sample))

# ╔═╡ ffc17f40-f380-11ea-30ee-0fe8563c0eb1
hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))

# ╔═╡ 7df7ab82-f9ad-11ea-2243-21685d660d71
hint(
    md"Você pode responder essa questão mesmo sem escrever código se tiver paciẽncia de olhar com calma o vetor `sample_freqs`.",
)

# ╔═╡ 7711ecc5-9132-4223-8ed4-4d0417b5d5c1
hint(md"Dê uma olhada na imagem de frequências de pares")

# ╔═╡ e467c1c6-fbf2-11ea-0d20-f5798237c0a6
hint(
    md"Comece com o código de `bigrams` e use a documentação de Julia para entender como ele funciona. Sabendo disso, pense em como generalizar `bigram` para obter a função `ngram`. Pode facilitar começar numa folha de papel primeiro.",
)

# ╔═╡ ffc40ab2-f380-11ea-2136-63542ff0f386
almost(text) = Markdown.MD(Markdown.Admonition("warning", "Quase lá!", [text]))

# ╔═╡ ffceaed6-f380-11ea-3c63-8132d270b83f
still_missing(text = md"Substitua `missing` com sua solução.") =
    Markdown.MD(Markdown.Admonition("warning", "Aqui vamos nós!", [text]))

# ╔═╡ ffde44ae-f380-11ea-29fb-2dfcc9cda8b4
keep_working(text = md"A resposta não está certa ainda.") =
    Markdown.MD(Markdown.Admonition("danger", "Continue tentando!", [text]))

# ╔═╡ ffe326e0-f380-11ea-3619-61dd0592d409
yays = [
    md"Fantastic!",
    md"Splendid!",
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
correct(text = rand(yays)) =
    Markdown.MD(Markdown.Admonition("correct", "Deu certo!", [text]))

# ╔═╡ 954fc466-fb7b-11ea-2724-1f938c6b93c6
let
    output = ngrams([1, 2, 3, 42], 2)

    if output isa Missing
        still_missing()
    elseif !(output isa Vector{<:Vector})
        keep_working(md"Verifique que `ngrams` devolve um array de arrays.")
    elseif output == [[1, 2], [2, 3], [3, 42]]
        if ngrams([1, 2, 3], 1) == [[1], [2], [3]]
            if ngrams([1, 2, 3], 3) == [[1, 2, 3]]
                if ngrams(["a"], 1) == [["a"]]
                    correct()
                else
                    keep_working(
                        md"`ngrams` deve funcionar com qualquer tipo, não apenas inteiros!",
                    )
                end
            else
                keep_working(md"`ngrams(x, 3)` não devolveu o resultado correto.")
            end
        else
            keep_working(md"`ngrams(x, 1)` não devolveu o resultado correto.")
        end
    else
        keep_working(
            md"`ngrams(x, 2)` não devolveu os bigramas corretos. Comece a partir do código de `bigrams`.",
        )
    end
end

# ╔═╡ a9ffff9a-fb83-11ea-1efd-2fc15538e52f
let
    output = word_counts(["to", "be", "or", "not", "to", "be"])

    if output === nothing
        keep_working(md"Você esqueceu de escrever `return`?")
    elseif output == Dict()
        still_missing(md"Escreva a função `word_counts` acima.")
    elseif !(output isa Dict)
        keep_working(md"Verifique que `word_counts` returna um `Dict`.")
    elseif output == Dict("to" => 2, "be" => 2, "or" => 1, "not" => 1)
        correct()
    else
        keep_working()
    end
end

# ╔═╡ b8af4d06-b38a-4675-9399-81fb5977f077
if capitu_count isa Missing
    still_missing()
elseif capitu_count == 337
    correct()
else
    keep_working()
end

# ╔═╡ 00026442-f381-11ea-2b41-bde1fff66011
not_defined(variable_name) = Markdown.MD(
    Markdown.Admonition(
        "danger",
        "Oopsie!",
        [
            md"Vertifique que você definiu a variável chamada **$(Markdown.Code(string(variable_name)))**",
        ],
    ),
)

# ╔═╡ 6fe693c8-f9a1-11ea-1983-f159131880e9
if !@isdefined(messy_sentence_1)
    not_defined(:messy_sentence_1)
elseif !@isdefined(cleaned_sentence_1)
    not_defined(:cleaned_sentence_1)
else
    if cleaned_sentence_1 isa Missing
        still_missing()
    elseif cleaned_sentence_1 isa Vector{Char}
        keep_working(
            md"Use `String(x)` para transformar um array de caracteres `x` em uma `String`.",
        )
    elseif cleaned_sentence_1 == filter(isinalphabet, messy_sentence_1)
        correct()
    else
        keep_working()
    end
end

# ╔═╡ cee0f984-f9a0-11ea-2c3c-53fe26156ea4
if !@isdefined(messy_sentence_2)
    not_defined(:messy_sentence_2)
elseif !@isdefined(cleaned_sentence_2)
    not_defined(:cleaned_sentence_2)
else
    if cleaned_sentence_2 isa Missing
        still_missing()
    elseif cleaned_sentence_2 isa Vector{Char}
        keep_working(
            md"Use `String(x)` para transformar um array de caracteres `x` em uma `String`.",
        )
    elseif cleaned_sentence_2 == filter(isinalphabet, lowercase(messy_sentence_2))
        correct()
    else
        keep_working()
    end
end

# ╔═╡ ddfb1e1c-f9a1-11ea-3625-f1170272e96a
if !@isdefined(clean)
    not_defined(:clean)
else
    let
        input = "Aè !!!  x1"
        output = clean(input)


        if output isa Missing || startswith(output, "missing")
            still_missing()
        elseif output isa Vector{Char}
            keep_working(
                md"Use `String(x)` to turn an array of characters `x` into a `String`.",
            )
        elseif output == "ae   x"
            correct()
        else
            keep_working()
        end
    end
end

# ╔═╡ 95b81778-f9a5-11ea-3f51-019430bc8fa8
if !@isdefined(unused_letters)
    not_defined(:unused_letters)
else
    if sample_freqs === missing
        md"""
        !!! warning "Oopsie!"
            Você precisa completar o exercício anterior antes.
        """
    elseif unused_letters isa Missing
        still_missing()
    elseif unused_letters isa String
        keep_working(md"Use `collect` transformar uma string em um vetor de caracteres.")
    elseif Set(index_of_letter.(unused_letters)) == Set(findall(isequal(0.0), sample_freqs))
        correct()
    else
        keep_working()
    end
end

# ╔═╡ 489fe282-f931-11ea-3dcb-35d4f2ac8b40
if !@isdefined(lh_frequency)
    not_defined(:lh_frequency)
elseif !@isdefined(hl_frequency)
    not_defined(:hl_frequency)
else
    if lh_frequency isa Missing || hl_frequency isa Missing
        still_missing()
    elseif lh_frequency < hl_frequency
        keep_working(
            md"Parece que você inverteu as repostas. Qual combinação é mais comum em português?",
        )
    elseif lh_frequency == sample_freq_matrix[index_of_letter('l'), index_of_letter('h')] &&
           hl_frequency == sample_freq_matrix[index_of_letter('h'), index_of_letter('l')]
        correct()
    else
        keep_working()
    end
end

# ╔═╡ 671525cc-f930-11ea-0e71-df9d4aae1c05
if !@isdefined(double_letters)
    not_defined(:double_letters)
else
    let
        result = double_letters
        if result isa Missing
            still_missing()
        elseif result isa String
            keep_working(md"Use `collect` to turn a string into an array of characters.")
        elseif !(result isa AbstractVector{Char} || result isa AbstractSet{Char})
            keep_working(md"Make sure that `double_letters` is a `Vector`.")
        elseif Set(result) == Set(alphabet[diag(sample_freq_matrix).!=0])
            correct()
        elseif push!(Set(result), ' ') == Set(alphabet[diag(sample_freq_matrix).!=0])
            almost(
                md"We also consider the space (`' '`) as one of the letters in our `alphabet`.",
            )
        else
            keep_working()
        end
    end
end

# ╔═╡ a5fbba46-f931-11ea-33e1-054be53d986c
if !@isdefined(most_likely_to_follow_w)
    not_defined(:most_likely_to_follow_w)
else
    let
        result = most_likely_to_follow_w
        if result isa Missing
            still_missing()
        elseif !(result isa Char)
            keep_working(
                md"Make sure that you return a `Char`. You might want to use the `alphabet` to index a character.",
            )
        elseif result == alphabet[map(alphabet) do c
            sample_freq_matrix[index_of_letter('b'), index_of_letter(c)]
        end|>argmax] #==#
            correct()
        else
            keep_working()
        end
    end
end

# ╔═╡ ba695f6a-f931-11ea-0fbb-c3ef1374270e
if !@isdefined(most_likely_to_precede_w)
    not_defined(:most_likely_to_precede_w)
else
    let
        result = most_likely_to_precede_w
        if result isa Missing
            still_missing()
        elseif !(result isa Char)
            keep_working(
                md"Make sure that you return a `Char`. You might want to use the `alphabet` to index a character.",
            )
        elseif result == alphabet[map(alphabet) do c
            sample_freq_matrix[index_of_letter(c), index_of_letter('b')]
        end|>argmax] #==#
            correct()
        else
            keep_working()
        end
    end
end

# ╔═╡ b09f5512-fb58-11ea-2527-31bea4cee823
if !@isdefined(matrix_distance)
    not_defined(:matrix_distance)
else
    try
        let
            A = rand(Float64, (5, 4))
            B = rand(Float64, (5, 4))

            output = matrix_distance(A, B)

            if output isa Missing
                still_missing()
            elseif !(output isa Number)
                keep_working(md"Make sure that `matrix_distance` returns a nunmber.")
            elseif output == 0.0
                keep_working(md"Two different matrices should have non-zero distance.")
            else
                if matrix_distance(A, B) < 0 || matrix_distance(B, A) < 0
                    keep_working(
                        md"The distance between two matrices should always be positive.",
                    )
                elseif matrix_distance(A, A) != 0
                    almost(md"The distance between two identical matrices should be zero.")
                elseif matrix_distance([1 -1], [0 0]) == 0.0
                    almost(md"`matrix_distance([1 -1], [0 0])` should not be zero.")
                else
                    correct()
                end
            end
        end
    catch
        keep_working(md"The function errored.")
    end
end

# ╔═╡ 20c0bfc0-a6ce-4290-95e1-d01264114cb1
todo(text) = HTML("""<div
 style="background: rgb(220, 200, 255); padding: 2em; border-radius: 1em;"
 ><h1>TODO</h1>$(repr(MIME"text/html"(), text))</div>""")

# ╔═╡ 00115b6e-f381-11ea-0bc6-61ca119cb628
bigbreak = html"<br><br><br><br><br>";

# ╔═╡ 7f341c4e-fb54-11ea-1919-d5421d7a2c75
bigbreak

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
Compose = "a81c6b42-2e10-5240-aca2-a61377ecd94b"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Unicode = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[compat]
Colors = "~0.12.10"
Compose = "~0.9.5"
PlutoUI = "~0.7.58"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.2"
manifest_format = "2.0"
project_hash = "d7f092602ebc0f331a2851945210d05c3bc57235"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "297b6b41b66ac7cbbebb4a740844310db9fd7b8c"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

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

[[deps.Compose]]
deps = ["Base64", "Colors", "DataStructures", "Dates", "IterTools", "JSON", "LinearAlgebra", "Measures", "Printf", "Random", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "bf6570a34c850f99407b494757f5d7ad233a7257"
uuid = "a81c6b42-2e10-5240-aca2-a61377ecd94b"
version = "0.9.5"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "97d79461925cdb635ee32116978fc735b9463a39"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.19"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

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

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IterTools]]
git-tree-sha1 = "42d5f897009e7ff2cf88db414a389e5ed1bdd023"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.10.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

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

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

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

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

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

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

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

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

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
# ╟─ec66314e-f37f-11ea-0af4-31da0584e881
# ╟─85cfbd10-f384-11ea-31dc-b5693630a4c5
# ╠═33e43c7c-f381-11ea-3abc-c942327456b1
# ╟─938185ec-f384-11ea-21dc-b56b7469f798
# ╠═a4937996-f314-11ea-2ff9-615c888afaa8
# ╟─c75856a8-1f36-4659-afb2-7edb14894ea1
# ╟─c9a8b35d-2183-4da1-ae35-d2552020e8a8
# ╟─6f9df800-f92d-11ea-2d49-c1aaabd2d012
# ╠═3206c771-495a-43a9-b707-eaeb828a8545
# ╠═b61722cc-f98f-11ea-22ae-d755f61f78c3
# ╟─59f2c600-2b64-4562-9426-2cfed9a864e4
# ╟─f457ad44-f990-11ea-0e2d-2bb7627716a8
# ╠═4efc051e-f92e-11ea-080e-bde6b8f9295a
# ╟─38d1ace8-f991-11ea-0b5f-ed7bd08edde5
# ╠═ddf272c8-f990-11ea-2135-7bf1a6dca0b7
# ╟─3cc688d2-f996-11ea-2a6f-0b4c7a5b74c2
# ╟─d67034d0-f92d-11ea-31c2-f7a38ebb412f
# ╠═7e09011c-71b5-4f05-ae4a-025d48daca1d
# ╟─a094e2ac-f92d-11ea-141a-3566552dd839
# ╠═27c9a7f4-f996-11ea-1e46-19e3fc840ad9
# ╟─f2a4edfa-f996-11ea-1a24-1ba78fd92233
# ╠═5c74a052-f92e-11ea-2c5b-0f1a3a14e313
# ╠═dcc4156c-f997-11ea-3e6f-057cd080d9db
# ╟─129fbcfe-f998-11ea-1c96-0fd3ccd2dcf8
# ╠═3a5ee698-f998-11ea-0452-19b70ed11a1d
# ╠═75694166-f998-11ea-0428-c96e1113e2a0
# ╟─6fe693c8-f9a1-11ea-1983-f159131880e9
# ╟─05f0182c-f999-11ea-0a52-3d46c65a049e
# ╠═98266882-f998-11ea-3270-4339fb502bc7
# ╠═d3c98450-f998-11ea-3caf-895183af926b
# ╠═d3a4820e-f998-11ea-2a5c-1f37e2a6dd0a
# ╟─cee0f984-f9a0-11ea-2c3c-53fe26156ea4
# ╟─aad659b8-f998-11ea-153e-3dae9514bfeb
# ╠═734851c6-f92d-11ea-130d-bf2a69e89255
# ╠═d236b51e-f997-11ea-0c55-abb11eb35f4d
# ╠═a56724b6-f9a0-11ea-18f2-991e0382eccf
# ╟─8d3bc9ea-f9a1-11ea-1508-8da4b7674629
# ╠═4affa858-f92e-11ea-3ece-258897c37e51
# ╠═e00d521a-f992-11ea-11e0-e9da8255b23b
# ╟─ddfb1e1c-f9a1-11ea-3625-f1170272e96a
# ╟─eaa8c79e-f9a2-11ea-323f-8bb2bd36e11c
# ╠═2680b506-f9a3-11ea-0849-3989de27dd9f
# ╟─571d28d6-f960-11ea-1b2e-d5977ecbbb11
# ╟─11e9a0e2-bc3d-4130-9a73-7c2003595caa
# ╠═6a64ab12-f960-11ea-0d92-5b88943cdb1a
# ╟─603741c2-f9a4-11ea-37ce-1b36ecc83f45
# ╠═b3de6260-f9a4-11ea-1bae-9153a92c3fe5
# ╠═a6c36bd6-f9a4-11ea-1aba-f75cecc90320
# ╟─6d3f9dae-f9a5-11ea-3228-d147435e266d
# ╠═92bf9fd2-f9a5-11ea-25c7-5966e44db6c6
# ╟─95b81778-f9a5-11ea-3f51-019430bc8fa8
# ╟─7df7ab82-f9ad-11ea-2243-21685d660d71
# ╟─dcffd7d2-f9a6-11ea-2230-b1afaecfdd54
# ╟─b3dad856-f9a7-11ea-1552-f7435f1cb605
# ╟─01215e9a-f9a9-11ea-363b-67392741c8d4
# ╟─be55507c-f9a7-11ea-189c-4ffe8377212e
# ╟─8ae13cf0-f9a8-11ea-3919-a735c4ed9e7f
# ╟─343d63c2-fb58-11ea-0cce-efe1afe070c2
# ╟─77623f3e-f9a9-11ea-2f46-ff07bd27cd5f
# ╠═fbb7c04e-f92d-11ea-0b81-0be20da242c8
# ╠═80118bf8-f931-11ea-34f3-b7828113ffd8
# ╠═7f4f6ce4-f931-11ea-15a4-b3bec6a7e8b6
# ╠═d40034f6-f9ab-11ea-3f65-7ffd1256ae9d
# ╟─689ed82a-f9ae-11ea-159c-331ff6660a75
# ╠═ace3dc76-f9ae-11ea-2bee-3d0bfa57cfbc
# ╟─aa2a73f6-0c1d-4be1-a414-05a6f8ce04bd
# ╟─0b67789c-f931-11ea-113c-35e5edafcbbf
# ╠═6896fef8-f9af-11ea-0065-816a70ba9670
# ╟─39152104-fc49-11ea-04dd-bb34e3600f2f
# ╟─e91c6fd8-f930-11ea-01ac-476bbde79079
# ╠═1b4c0c28-f9ab-11ea-03a6-69f69f7f90ed
# ╟─1f94e0a2-f9ab-11ea-1347-7dd906ebb09d
# ╠═41b2df7c-f931-11ea-112e-ede3b16f357a
# ╟─489fe282-f931-11ea-3dcb-35d4f2ac8b40
# ╟─1dd1e2f4-f930-11ea-312c-5ff9e109c7f6
# ╠═65c92cac-f930-11ea-20b1-6b8f45b3f262
# ╟─671525cc-f930-11ea-0e71-df9d4aae1c05
# ╟─7711ecc5-9132-4223-8ed4-4d0417b5d5c1
# ╟─4582ebf4-f930-11ea-03b2-bf4da1a8f8df
# ╠═7898b76a-f930-11ea-2b7e-8126ec2b8ffd
# ╟─a5fbba46-f931-11ea-33e1-054be53d986c
# ╟─458cd100-f930-11ea-24b8-41a49f6596a0
# ╠═bc401bee-f931-11ea-09cc-c5efe2f11194
# ╟─ba695f6a-f931-11ea-0fbb-c3ef1374270e
# ╟─45c20988-f930-11ea-1d12-b782d2c01c11
# ╠═58428158-84ac-44e4-9b38-b991728cd98a
# ╠═4a0314a6-7dc0-4ee9-842b-3f9bd4d61fb1
# ╠═cc62929e-f9af-11ea-06b9-439ac08dcb52
# ╟─2f8dedfc-fb98-11ea-23d7-2159bdb6a299
# ╟─b7446f34-f9b1-11ea-0f39-a3c17ba740e5
# ╟─4f97b572-f9b0-11ea-0a99-87af0797bf28
# ╟─46c905d8-f9b0-11ea-36ed-0515e8ed2621
# ╟─4e8d327e-f9b0-11ea-3f16-c178d96d07d9
# ╟─489b03d4-f9b0-11ea-1de0-11d4fe4e7c69
# ╟─d83f8bbc-f9af-11ea-2392-c90e28e96c65
# ╠═0e872a6c-f937-11ea-125e-37958713a495
# ╠═fd202410-f936-11ea-1ad6-b3629556b3e0
# ╟─b5b8dd18-f938-11ea-157b-53b145357fd1
# ╟─0e465160-f937-11ea-0ebb-b7e02d71e8a8
# ╟─6718d26c-f9b0-11ea-1f5a-0f22f7ddffe9
# ╟─141af892-f933-11ea-1e5f-154167642809
# ╟─7eed9dde-f931-11ea-38b0-db6bfcc1b558
# ╟─7e3282e2-f931-11ea-272f-d90779264456
# ╟─7d1439e6-f931-11ea-2dab-41c66a779262
# ╟─7df55e6c-f931-11ea-33b8-fdc3be0b6cfa
# ╟─292e0384-fb57-11ea-0238-0fbe416fc976
# ╠═7dabee08-f931-11ea-0cb2-c7d5afd21551
# ╟─3736a094-fb57-11ea-1d39-e551aae62b1d
# ╠═13c89272-f934-11ea-07fe-91b5d56dedf8
# ╟─7d60f056-f931-11ea-39ae-5fa18a955a77
# ╟─b09f5512-fb58-11ea-2527-31bea4cee823
# ╟─8c7606f0-fb93-11ea-0c9c-45364892cbb8
# ╟─82e0df62-fb54-11ea-3fff-b16c87a7d45b
# ╠═b7601048-fb57-11ea-0754-97dc4e0623a1
# ╟─cc42de82-fb5a-11ea-3614-25ef961729ab
# ╠═d66fe2b2-fb5a-11ea-280f-cfb12b8296ac
# ╠═4ca8e04a-fb75-11ea-08cc-2fdef5b31944
# ╟─6f613cd2-fb5b-11ea-1669-cbd355677649
# ╠═91e87974-fb78-11ea-3ce4-5f64e506b9d2
# ╠═9f98e00e-fb78-11ea-0f6c-01206e7221d6
# ╟─d7d8cd0c-fb6a-11ea-12bf-2d1448b38162
# ╠═7be98e04-fb6b-11ea-111d-51c48f39a4e9
# ╠═052f822c-fb7b-11ea-382f-af4d6c2b4fdb
# ╠═067f33fc-fb7b-11ea-352e-956c8727c79f
# ╟─954fc466-fb7b-11ea-2724-1f938c6b93c6
# ╟─e467c1c6-fbf2-11ea-0d20-f5798237c0a6
# ╟─7b10f074-fb7c-11ea-20f0-034ddff41bc3
# ╟─24ae5da0-fb7e-11ea-3480-8bb7b649abd5
# ╟─47836744-fb7e-11ea-2305-3fa5819dc154
# ╠═df4fc31c-fb81-11ea-37b3-db282b36f5ef
# ╠═c83b1770-fb82-11ea-20a6-3d3a09606c62
# ╟─52970ac4-fb82-11ea-3040-8bd0590348d2
# ╠═8ce3b312-fb82-11ea-200c-8d5b12f03eea
# ╠═a2214e50-fb83-11ea-3580-210f12d44182
# ╟─a9ffff9a-fb83-11ea-1efd-2fc15538e52f
# ╟─808abf6e-fb84-11ea-0785-2fc3f1c4a09f
# ╠═953363dc-fb84-11ea-1128-ebdfaf5160ee
# ╟─b8af4d06-b38a-4675-9399-81fb5977f077
# ╟─294b6f50-fb84-11ea-1382-03e9ab029a2d
# ╠═b726f824-fb5e-11ea-328e-03a30544037f
# ╠═18355314-fb86-11ea-0738-3544e2e3e816
# ╟─472687be-995a-4cf9-b9f6-6b56ae159539
# ╠═abe2b862-fb69-11ea-08d9-ebd4ba3437d5
# ╟─3d105742-fb8d-11ea-09b0-cd2e77efd15c
# ╟─a72fcf5a-fb62-11ea-1dcc-11451d23c085
# ╟─f83991c0-fb7c-11ea-0e6f-1f80709d00c1
# ╟─4b27a89a-fb8d-11ea-010b-671eba69364e
# ╟─d7b7a14a-fb90-11ea-3e2b-2fd8f379b4d8
# ╟─1939dbea-fb63-11ea-0bc2-2d06b2d4b26c
# ╟─70169682-fb8c-11ea-27c0-2dad2ff3080f
# ╟─b5dff8b8-fb6c-11ea-10fc-37d2a9adae8c
# ╠═6a7c5425-c86c-4f22-982a-345234df15cb
# ╟─402562b0-fb63-11ea-0769-375572cc47a8
# ╟─ee8c5808-fb5f-11ea-19a1-3d58217f34dc
# ╟─2521bac8-fb8f-11ea-04a4-0b077d77529e
# ╠═49b69dc2-fb8f-11ea-39af-030b5c5053c3
# ╟─7f341c4e-fb54-11ea-1919-d5421d7a2c75
# ╟─cc07f576-fbf3-11ea-2c6f-0be63b9356fc
# ╟─6b4d6584-f3be-11ea-131d-e5bdefcc791b
# ╟─54b1e236-fb53-11ea-3769-b382ef8b25d6
# ╟─b7803a28-fb96-11ea-3e30-d98eb322d19a
# ╟─ddef9c94-fb96-11ea-1f17-f173a4ff4d89
# ╠═ffc17f40-f380-11ea-30ee-0fe8563c0eb1
# ╟─ffc40ab2-f380-11ea-2136-63542ff0f386
# ╟─ffceaed6-f380-11ea-3c63-8132d270b83f
# ╟─ffde44ae-f380-11ea-29fb-2dfcc9cda8b4
# ╟─ffe326e0-f380-11ea-3619-61dd0592d409
# ╟─fff5aedc-f380-11ea-2a08-99c230f8fa32
# ╟─00026442-f381-11ea-2b41-bde1fff66011
# ╟─20c0bfc0-a6ce-4290-95e1-d01264114cb1
# ╟─00115b6e-f381-11ea-0bc6-61ca119cb628
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
