### A Pluto.jl notebook ###
# v0.19.39

using Markdown
using InteractiveUtils

# ╔═╡ 75c8f825-d988-4f9e-8038-6b4dd2e24181
begin
    using HypertextLiteral
	using PlutoTest
	using PlutoUI
end

# ╔═╡ 89f23045-e484-437c-9f96-ce1389cfc4c3
md"Tradução livre de [how\_to\_collaborate\_on\_software.jl](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week12/how_to_collaborate_on_software.jl)."

# ╔═╡ ef4eea24-bc1c-43be-b9b6-d073ac2433cf
md"""
# Como colaborar em software

A solução mais simples para colaborar na rede? Para alguns é _enviar arquivos de um lado para o outro_, seja por e-mail, seja por outra forma (Dropbox, Googledrive, etc.). Isso até funciona em projetos pequenos, mas a partir de um certo ponto é interessante pensar em outras soluções. Alguns exemplos:
* Uma enciclopédia -- um sistema wiki.
* Um artigo acadêmico -- Google Drive (ou assemelhados) ou Overleaf.
* **Um projeto de software** -- Soluções baseadas em Git (Github, Gitlab, Bitbucket).

Para projetos de software é comum usar soluções baseadas em git como meio principal de colaboração. Um dos nossos objetivos hoje é explicar os motivos dessa escolha.

Eu sou também fã do git para artigos acadêmicos basedos em LaTeX. Nesse caso, os arquivos são textos puros e funcionam bem em sistemas pensados para código como o Git. Diferente do que ocorre em arquivos de editores de texto mais usuais como o Word ou LibreOffice.
"""

# ╔═╡ 69b8490f-cf04-4e73-bc7b-639b1fc0e2d6
TableOfContents(title="Índice"; aside=false, depth=1)

# ╔═╡ cbe5fcba-3ed7-41a6-8932-2693e370c16c
md"""
# Porque não usar Google Drive (ou Dropbox, ou Nextcloud, ou Syncthing)?
"""

# ╔═╡ 56db20a5-0e8d-4d34-b3ba-c3ab1b8de58e
md"""
Ferramentas como Google Drive, Dropbox e Syncthing (esse é software livre e auto-hospedado) são plataformas de _compartilhamento de arquivos em tempo real_. Além de sincronizar arquivos individuais, essas ferramentas permitem sincronizar árvores de diretórios completas entre computadores e a nuvem. Mas, nem por isso, programadores experientes usam essas ferramentas para colaboração. 

Projetos de software têm características específicas que demandam ferramentas diferentes. **Assim antes de apresentar o fluxo de trabalho com git vamos começar entendendo algumas dessas demandas especiais** e, desse modo, entender porque ferramentas como Google Drive ou Dropbox não são ideais para essa tarefa. 

Para isso, vamos começar analisando características do Google Drive e entender algumas limitações das suas escolhas que o fazem menos adequado para lidar com colaboração em projetos de software.
"""

# ╔═╡ 83d0162f-5960-4938-8353-91c4cd220459
md"""
## Motivo 1: sensibilidade a mudanças

> **Motivo 1:** Em projetos de software pequenas mudanças em um local podem gerar grandes impactos **em todo o programa**. Ou seja, mudanças aparentemente locais não são locais e acabam tendo um impacto global. 

Por exemplo, veja o que ocorre com Pluto.jl após realizarmos uma mudança de **um único caractere** em seu código-fonte:
"""

# ╔═╡ 604837c5-b017-4d6c-a5c5-dab50d5f3f61
md"""
Enquanto um único caractere pode representar um desastre, essa _sensibilidade_ também ajuda a explicar porque linguagens de programação são tão poderosas. O mesmo trecho de código pode ser usado em várias partes e assim mudanças pequenas podem resolver grandes problemas.
"""

# ╔═╡ 8678b5e1-0b67-4097-82ba-0daa4e878032
md"""
### Sincronização de cada alteração

Essa sensibilidade a mudanças faz com que sincronização em tempo real seja indesejável para projetos de programação. Para entender isso digamos que vamos mudar `sqrt` para `log` no código abaixo:

"""

# ╔═╡ 02905480-8864-4e56-af3a-6c7c0789ce6f


# ╔═╡ 2ef5db21-0092-4523-b930-0ec99c459ffa
md"""
Se cada mudança fosse sincronizada à medida que editamos (removendo as letras `s`, `q`, `r`, `t`, e digitando a seguir `l`, `o`, `g`), então você estaria publicando código que não funciona para um repositório na rede. Isso faria com que outras pessoas que estão colaborando enfrentem problemas com esses estados intermediários problemáticos. Certamente isso não é desejável.
"""

# ╔═╡ 51114dc9-cb32-4d31-b780-6f5e372f8763
md"""
##### Sincronizado cada _pressionar de tecla_
"""

# ╔═╡ 3c8abdfc-cf68-4f10-a3e9-08d24803535b


# ╔═╡ dfb316ca-0502-4419-93c2-6d455b7b2f98
md"""
Por outro lado, se pudéssemos publicar código apenas _manualmente_, podemos garantir que nunca publicamos código que não funciona. Isso faz com que os meus colaboradores, que podem estar trabalhando no projeto concomitantemente, não precisem lidar com erros gerados pelo estado intermediário de minhas modificações.
"""

# ╔═╡ ae28cad6-2ffe-48b4-895b-fab1bd2f2443
md"""
##### Sincronização manual
"""

# ╔═╡ ee5a3219-4547-4a9d-b527-3489a2925f68
md"""
### Trechos ainda maiores

No exemplo anterior, vimos porque devemos evitar código com _sintaxe inválida_ evitando a sincronização automática de ferramentas como o Google Drive e usando um controle manual do que será publicado.
"""

# ╔═╡ e5f2b4e1-f05a-4457-b2e9-091a86ef86bb
md"""
##### Sincronizando cada _gravação_
"""

# ╔═╡ 1421f832-9f97-4ec3-b967-64618983349b
md"""
##### Sincronizando manualmente
"""

# ╔═╡ e5bab2e1-be9e-4654-844a-d50285e330c8
pass2 = html"<span style='opacity: .3'>✅</span>"

# ╔═╡ 47c67fa6-1490-4134-9e0c-5754cb273d1e
pass = "✅" |> HTML

# ╔═╡ 79ab206d-2140-4c78-8fd4-a874fe2551e1
fail = "❌" |> HTML

# ╔═╡ 38261f04-f410-440e-a1cf-218fa240a0ae
md"""

### Motivo 2: _ramificações_ e _bifurcações (ou forks)_

> **Motivo 2:** Deveria ser fácil separar um projeto em múltiplas _ramificações_: **cópias divergentes de uma base de código** que podem ser trabalhadas separadamente. Depois de um tempo, podemos **comparar ramificações** e mesclar as modificações ao final criando uma versão com novas funcionalidades.

Algo que pode ser interessante de fazer: criar uma cópia de sua `apresentação.odp` chamada `apresentação-com-figuras.odp` antes de adicionar as imagens. Se não ficar bom, será fácil retornar à forma original. 

Isso parece uma boa solução: mas se o seu amigo de grupo também fizer uma cópia `apresentação-com-página-de-título.odp` onde ele vai trabalhar também. Nesse caso já não será tão fácil combinar os dois grupos de modificações na `apresentação-final.odp`.

Esse é também um bom exemplo que usar formatos baseados em textos pode ser muito mais interessante do que trabalhar com formatos binários opacos.

Já sobre as _bifurcações ou forks_ iremos falar mais abaixo.
"""

# ╔═╡ a0a97cd2-838c-4a2c-9233-969b3274764c
md"""
### Motivo 3: automação

> **Motivo 3:** Git é uma plataforma criada para *automação*. Nela é possível disparar automaticamente testes, revisar alterações, disponibilizar versões semanais, entre várias outras tarefas.

Programadores _adoram_ automatizar tarefas e git ajuda nisso. Num primeiro momento, esse fluxo de trabalho pode _intimidar_ e irá demorar um bom tempo até que você aprenda todos os truques. Existem até profissionais especializados nisso, chamados de  _Engenheiros [DevOps](https://en.wikipedia.org/wiki/DevOps)_. Não se preocupe com isso, o importante é começar a dar os primeiros passos e tentar aprender, pedindo ajuda quando necessário.
"""

# ╔═╡ 0faa4042-42f5-4c74-9270-fbf2205920ca
md"""
##### Teste automáticos

Apesar de não recomendarmos que você tente aprender _automação com git_ de início, você provavelmente vai encontrar a existência de testes automáticos se tentar colaborar com um projeto de software aberto. De fato, a ideia de criar baterias de testes é uma das estratégias fundamentais para permitir a colaboração por grupos heterogêneos. Vamos falar mais sobre isso depois.
"""

# ╔═╡ 167cbd94-851f-4147-9b9d-9b46c7959785
bigbreak = html"""
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
""";

# ╔═╡ 4d303641-0299-44d7-ba74-6daea0026b09
md"""
# Como usar o GitHub

Agora vamos ver como criar um repositório no Github.
"""

# ╔═╡ 2c456900-047d-432c-a62a-87f8eeaba8d5
md"""
##### Requisitos

Para seguir essa introdução você vai precisar de:
* Criar uma conta no [github.com](github.com). Adicione algumas linhas para o seu perfil e uma foto!

* Para usuários Windows & MacOS, vocês podem baixar o programa [GitHub Desktop](https://desktop.github.com/), uma interface gráfica para lidar com repositório git que pode ser mais fácil para quem não está acostumado com a linha de comando. Usuários Linux podem usar diretamente a linha de comando ou o programa de janela (um pouco mais avançado) [GitKraken](https://www.gitkraken.com/). Há ainda muitas outras opções disponíveis para a sua distribuição.

* Um editor de texto. Se você ainda não escolheu um editor de textos ou ainda está usado programas como  Notepad, gedit or Notepad++, _sugerimos fortemente o [VS Code](https://code.visualstudio.com/)_. Ele é um editor de código aberto, de fácil uso, com várias funcionalidades e possibilidades de expansão. Ele pode parecer complicado no início, mas é relativamente fácil de usar e pode ser estendido gradualmente. Ele tem também ótimas funcionalidades para quem programa, sendo capaz de "entender" o seu código e lhe auxiliar em tarefas típicas de programação. Hoje em dia ele também tem um assistente de programação baseado em IA chamado CoPilot que é gratuido para alunos da Unicamp.
"""

# ╔═╡ dc112303-061e-4e53-8f58-cf9ea0f556f1
md"""
> Agora vamos criar o repositório ao vivo.
"""

# ╔═╡ d400d538-4f73-4490-ad68-aedbb57cd70f


# ╔═╡ e3fe649e-2733-455a-897d-d4d2d70b9dc6
md"""
# Uma primeira contribuição _documentação_

Vamos tentar ver como é o fluxo de colaboração em projetos de código aberto. Uma das melhores maneiras de fazer isso inicialmente é tentar contribuir para melhorar a _documentação_ de um projeto. No nosso exemplo de hoje vamos usar o próprio repositório do curso e vamos corrigir essssssssssssse tttttttttexxxxxxxxxxxxxto aaaaaaaaaaaaaqqqqqqqqqqqui. Lembrem-se, o código dos cadernos e listas de nosso curso estão no [site da disciplina no Github](https://github.com/pjssilva/LabCompSci).

O Github, além de fornecer o repositório para o código, também possui outras facilidades como um sistema para lidar com [requisições](https://github.com/pjssilva/LabCompSci/issues) — e para aceitar contribuições de terceiros - chamadas de [_Pull Request_](https://github.com/pjssilva/LabCompSci/pulls). Vamos fazer agora o nosso primeiro _Pull Request_!
"""

# ╔═╡ 2dd5d359-eb44-4696-bc83-f257eff95618
md"""
### O que é um _Pull Request_?

Os pacotes de Julia são de _código aberto_, isso diz que você pode (e é mesmo encorajado) fazer sua própria cópia do código-fonte (isso é chamado de uma ramificação ou um _fork_) e modificá-lo.

Se você fez mudanças úteis na sua ramificação você pode sugerir que suas mudanças sejam incorporadas ao projeto original enviando o seu código como um _**Pull Request (PR)**_ (requisição para puxar). Essa é uma funcionalidade presente no Github (pode ter nomes diferentes em outros ambientes de hospedagem). Essa é a forma típica de colaboração na rede.
"""

# ╔═╡ 3229f0aa-54d1-43f4-a6aa-cf212620ae13
md"""
> Agora vamos sair do caderno e fazer o _pull request_ ao vivo.

> Dica (para mim - para usar outro usuário): `export GIT_SSH_COMMAND='ssh -i private_key_file -o PasswordAuthentication=no'`
"""

# ╔═╡ b83ade3d-6f8d-4ac8-9255-956d0a348416
md"""
Como um exemplo de um caso real de _pull request_ no mundo real podemos analisar esse feito para  `JuliaLang/julia`: [github.com/JuliaLang/julia/pull/40596](https://github.com/JuliaLang/julia/pull/40596). A mudança no código não é o importante nesse momento. Para nós é interessante ver a comunicação que ocorreu entre as partes envolvidas.
"""

# ╔═╡ bbb59b45-de20-41c1-b5dd-079fc51655f2
md"""
##  Após o _Pull Request_

Submeter o _pull request_ é recompensador, mas não é o último passo. Após a sua submissão o PR será revisado pelos autores do projeto e eles podem deixar um retorno. É comum que o PR não seja _mesclado_ (aceito) na primeira tentativa, mas que você receba pedidos de pequenas modificações. 

Isso é possível porque um _pull request_ não é estático - você pode fazer novas modificações e atualizá-lo. Lembre-se que um PR é de uma _bifurcação para outra_. Você pode alterar seu PR simplesmente alterando a sua ramificação e subindo o resultado para o Github.
"""

# ╔═╡ 67cf205a-3d89-4cd9-ab5e-febc85ea8af1
md"""
## ⛑ Problemas com o Git!

Em algum momento você vai enfrentar _problemas com o git_. Ele ao detectar problemas, como conflitos de versões, não toma atitudes sozinhos. Ele para e pede intervenção manual. O caso mais comum é 

#### `🤐 conflito de mesclagem`.

Isso quer dizer que alguém modificou um arquivo que você também modificou, nesse caso você deve usar ferramentas para ver as diferenças e escolher a melhor solução. O git pode tentar fazer automaticamente a mescla se as mudanças ocorreram em posições diferentes do código (mas tome cuidado com isso, lembre que mudanças em um local do código pode gerar consequências em outros locais). Mas certamente você terá que intervir se as mudanças ocorrerem na mesma região. Uma boa ferramenta para isso é o `meld`, ele também é útil para você ver as mudanças que você fez na versão antes do último _commit_. O VS Code também tem boas ferramentas para isso.
"""

# ╔═╡ c4442667-072a-4e17-94a4-104a8ec33bd0


# ╔═╡ d8c5273f-7ebc-4399-b893-36f742162938
md"""
### Dica do Fonsi para resolver alguns problems com Git™

Muitos problemas com o git possuem soluções "oficiais" que podem levar um tempo para aprender. Enquanto isso, o Fonsi sugere os seguintes passos que podem lhe tirar de apuros muitas vezes:
"""

# ╔═╡ cc1149de-4895-48aa-8335-6dcc78d882c9
md"""
##### Passo 1

Use o GitHub Desktop para ver quais foram os arquivos que você modificou. Você quer de fato guardar as mudanças, elas são importantes?

##### Passo 2

Pegue os arquivos que você quer guardar e os copie em um diretório diferente, por exemplo no seu desktop.

##### Passo 3

**Apague a sua cópia local do repositório e mova quaisquer arquivos que sobraram para a lixeira.

##### Passo 4

Clone the repository novamente e copie os arquivos modificados de volta no local original, sobre-escrevendo os arquivos clonados. Agora você tem um repositório com o mínimo de modificações possíveis para recuperar o seu trabalho. 

Obs: antes de copiar os seus arquivos modificados pode ser interessante criar uma ramificação, um _branch_, para as modificações.
"""

# ╔═╡ aeafbdbb-4aeb-452e-a21b-d2c8ec48c64e
md"""
### Testes

Muitas pessoas escrevem _testes_ para o seu código! Assim, alguns repositórios de código irão possuir um diretório chamado `test` para guardar programas que irão importar o código original e executar as verificações.
"""

# ╔═╡ 40f9fe4d-ddae-4bdb-aee2-7999e288931a
function double(x)
	x + x
end

# ╔═╡ f7425775-55aa-4e46-a11f-7d981a4cfacc
@test double(3) == 6

# ╔═╡ 91b6151d-284e-4f06-954c-ce648fec3327
@test double(0) == 0

# ╔═╡ ddab6132-7d4d-41e8-81f3-ab0fc24cbeeb
md"""
Um dos motivos para escrever testes é para _assegurar_  um comportamento específico, protegendo o código de modificá-lo inadvertidamente. Por exemplo, imagine que você acaba de consertar um bug em que a função `double(2)` (no sentido de duplicar) devolvia `40` no lugar de `4`. Você pode adicionar um teste para verificar esse caso e assim você evita que outra modificação futura volte a introduzir o mesmo problema.  

"""

# ╔═╡ 0d76ea2f-18a9-46d1-8328-f077482d5d1f
md"""
#### Executando testes

Você pode executar os testes de um pacote de Julia abrindo o REPL e executando:
```julia
julia> ]

(v1.10) pkg> test Example
```
Como já mencionamos, vários projetos usam _automatização do github_ para executar os testes em um servidor após cada mudança e você pode ver os resultados online. Uma aplicação importante dessa execução automática de testes é verificar se um _pull request_ não quebrou algo. Ou seja, testes robustos facilitam a cooperação porque permitem verificar a cada instante que o código está em um estado razoável, sem problemas aparentes.

De fato, muitas filosofias de programação colocam os testes como um dos seus pilares, por vezes exigindo que testes sejam escritos antes de escrever código. Isso é comum em métodos ágeis, como programação eXtrema. Veja o comentário ao lado. 
"""

# ╔═╡ de95e033-932a-4de9-8e1b-36fcf22c7e20
bigbreak

# ╔═╡ 6efa4ee8-b477-4d47-8d42-5b87f3aa02d2
md"""
# Últimas dicas
"""

# ╔═╡ f26e39cc-c175-4439-868a-0686250e8e29
md"""
Contribuir não é apenas escrever código! [https://opensource.guide/how-to-contribute/](https://opensource.guide/how-to-contribute/)


"""

# ╔═╡ b16a228e-5056-44a0-ab57-0dea5082669d
md"""
Crie um repositório de "teste", crie vários, familiarize-se com o processo.
"""

# ╔═╡ 436c9fa2-b770-4dee-82a6-23e9baa551e4
md"""
# Apêndice
"""

# ╔═╡ d92d55a3-8fbc-4178-81b4-7ddc379ef7c7
function ingredients(path::String)
	# this is from the Julia source code (evalfile in base/loading.jl)
	# but with the modification that it returns the module instead of the last object
	name = Symbol(basename(path))
	m = Module(name)
	Core.eval(m,
        Expr(:toplevel,
             :(eval(x) = $(Expr(:core, :eval))($name, x)),
             :(include(x) = $(Expr(:top, :include))($name, x)),
             :(include(mapexpr::Function, x) = $(Expr(:top, :include))(mapexpr, $name, x)),
             :(include($path))))
	m
end

# ╔═╡ 089c9a6c-f4ef-4815-9a99-cb4023b42225
# Layout = ingredients(download("https://raw.githubusercontent.com/fonsp/disorganised-mess/5a59ad7cff1e760b997a54ffa0f8fa202ac16db3/Layout.jl"))

# ╔═╡ 4ea69625-0064-42da-a75a-a54fbd106f78
stackrows(x) = permutedims(hcat(x...),(2,1))

# ╔═╡ dd4855a0-0b7c-40a5-8565-94b40948f86d
flex(x::Union{AbstractVector,Base.Generator}; kwargs...) = flex(x...; kwargs...)

# ╔═╡ d31f0e84-dce9-4f81-8643-ef08684530d2
begin
	Base.@kwdef struct Div
		contents
		style=Dict()
	end
	
	Div(x) = Div(contents=x)
	
	function Base.show(io::IO, m::MIME"text/html", d::Div)
		h = @htl("""
			<div style=$(d.style)>
			$(d.contents)
			</div>
			""")
		show(io, m, h)
	end
end

# ╔═╡ 3c0059b7-7a99-4c1c-a2bf-e47bdd06a252
outline(x) = Div(x, Dict(
		"border" => "3px solid rgba(0,0,0,.3)",
		"border-radius" => "3px",
		"padding" => "5px",
		))

# ╔═╡ 0bf51d8c-7adf-4231-8b2d-c976484a3e7c
Div(
	[md"""
	```julia
	function height(p)
		c1 * sqrt(p * c2)
	end
	```
	""",
	md"to",
	md"""
	```julia
	function height(p)
		c1 * log(p * c2)
	end
	```
	"""],
	Dict(
		"display" => "flex",
		"justify-content" => "space-evenly",
		"align-items" => "center",
	))

# ╔═╡ 574448b8-2ff1-4bff-8580-33bfcba860e8
function flex(args...; kwargs...)
	Div(;
		contents=collect(args),
		style=Dict("display" => "flex", ("flex-" * String(k) => string(v) for (k,v) in kwargs)...)
		)
end

# ╔═╡ 51448106-3e0e-4abf-84fc-7e6e81425d12
flex(
	md"""
	#### Before:
	
	![Schermafbeelding 2021-05-04 om 18 51 27](https://user-images.githubusercontent.com/6933510/117040056-c10b8280-ad09-11eb-9384-d211156440b1.png)
	""",
	md"""
	#### After a single change:
	
	![Schermafbeelding 2021-05-04 om 18 50 00](https://user-images.githubusercontent.com/6933510/117039958-a46f4a80-ad09-11eb-90fa-c1264d896648.png)
	"""
	) |> outline

# ╔═╡ 676ac6ff-1b7e-4c88-b850-45f4375a8d58
function grid(items::AbstractMatrix; fill_width::Bool=true)
	Div(
		contents=Div.(vec(permutedims(items, [2,1]))), 
		style=Dict(
			"display" => fill_width ? "grid" : "inline-grid", 
			"grid-template-columns" => "repeat($(size(items,2)), auto)",
			"column-gap" => "1em",
		),
	)
end

# ╔═╡ 8b24ce23-4ead-4fbc-875e-a8261f671abe
grid([
	nothing                  md"`sqrt`" md"`sq`" md"` `" md"`lo`" md"`log`"
	"Your computer (local):" pass fail fail fail pass
	"Online (remote): " pass fail fail fail pass
])

# ╔═╡ 86e4b0dd-9bf5-4711-bf3f-b55ed2627a03
grid([
	nothing                  md"`sqrt`" md"`sq`" md"` `" md"`lo`" md"`log`"
	md"Your computer _(local)_:" pass fail fail fail pass
	md"Online _(remote)_: " pass nothing nothing nothing pass
		])

# ╔═╡ efbd6d1c-d2c9-48a9-9d6c-dc9ce6af0b5b
grid([
	nothing                  md"`sqrt`" md"Let's try `sin`" md"Let's try `cos`" md"Try `log`"
	"Your computer (local):" pass fail fail pass
	"Online (remote): " pass fail fail pass
		])

# ╔═╡ b139e8ea-88ad-4df4-9f13-c867edfc2db0
grid([
	nothing                  md"`sqrt`" md"Let's try `sin`" md"Let's try `cos`" md"Try `log`"
	"Your computer (local):" pass fail fail pass
	"Online (remote): " pass nothing nothing pass
		])

# ╔═╡ 13c0fbf3-08c6-4515-b710-f16b55165a2d
vocabulary(x) = grid(stackrows((
		[@htl("<span style='font-size: 1.2rem; font-weight: 700;'><code>$(k)</code></span>"), v]
		for (k,v) in x
		)); fill_width=false)

# ╔═╡ b2e49cd5-49d5-4ac7-a3ae-9820a97720fb
[
	@htl("<em>remote</em>") => md"A versão que está em um servidor da Internet, você navega no _remote_ localizado no github.com.",
	@htl("<em>local</em>") => md"A cópia que está no seu computador. Use `pull`, `commit` e `push` para sincronizar essa cópia com o _remote_."
	] |> vocabulary

# ╔═╡ a98993b9-a5c0-4260-b96e-2655c472ccba
[
	"fetch" => md"Torna o seu git local ciente de modificações que ocorreram online. Faça isso sempre!",
	"pull" => md"Pegue as mudanças remotas e incorpore à sua cópia local. Isso vai sincronizar as cópias. Faça isso sempre!",
	"stage/commit" => md"Cria uma coleção de arquivos modificados que estão prontos para serem enviados ao _remote_.",
	"push" => md"Publique os `commit`s locais para o _remote_.",
	] |> vocabulary

# ╔═╡ d43abe78-5a9d-4a22-999d-0ee85eb5ab7f
function aside(x)
	@htl("""
		<style>
		
		
		@media (min-width: calc(700px + 30px + 300px)) {
			aside.plutoui-aside-wrapper {
				position: absolute;
				right: -11px;
				width: 0px;
				transform: translate(0, -40%);
			}
			aside.plutoui-aside-wrapper > div {
				width: 300px;
			}
		}
		</style>
		
		<aside class="plutoui-aside-wrapper">
		<div>
		$(x)
		</div>
		</aside>
		
		""")
end

# ╔═╡ 812002d3-8603-4ffa-8695-2b2da7f0766a
html"""
<p>
Se você não usou o Google Drive antes, aqui está uma pequena demonstranção:</p>
<video src="https://user-images.githubusercontent.com/6933510/117038375-d8497080-ad07-11eb-8260-34e96414131a.mov" data-canonical-src="https://user-images.githubusercontent.com/6933510/117038375-d8497080-ad07-11eb-8260-34e96414131a.mov" controls="controls" muted="muted" class="d-block rounded-bottom-2 width-fit" style="max-height:640px;"></video>
""" |> aside

# ╔═╡ 8ea1ca6b-4bb7-4f53-907d-0e5ca83e5761
md"""
[^notalateral]:

    _Nota lateral sobre desenho de linguagens:_ _Existem_ linguagens que foram desenhadas pra serem robustas com respeito à pequenas mudanças abrindo espaço para colaboração em tempo real. Exemplos são [glitch.com](glitch.com) para edição colaborativa de HTML e CSS _(essas linguagens podem ignorar erros de sintaxe e continuar)_. Há ainda a linguagem experimental [_Dark_](https://darklang.com/) _(ela usa um editor especial que não permite que você digite código com erros)_.
""" |> aside

# ╔═╡ 7af9e69c-2b81-4a90-861c-ed737a4a9ec4
md"""
[^1]:
	Se você está trabalhando em um _fork_, então ao criar um PR você também está dando aos autores do projeto original acesso para fazer mudanças na ramificação do PR. Essa é uma funcionalidade útil, permitindo trabalho colaborativo de forma mais simples.
""" |> aside

# ╔═╡ 7174076d-5eba-4380-8d76-292935014d90
md"""
> ##### Programação baseada em testes
> 
> Como mencionei antes, algumas pessoas _primeiro_ escrevem testes que começam falhando e depois escrevem o código que irá resolver de fato o problema. À medida que o código é escrito ele é continuamente testado até que todos as verificações retornem verde. Essa pode ser uma forma efetiva e agradável de programar.
> 
> De fato, quando você fizer as listas, você irá se deparar várias vezes essa abordagem. Muitos exercícios possuem testes específicos e o seu objetivo é, no mínimo, escrever código capaz de passar nesses testes simples.
""" |> aside

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
HypertextLiteral = "~0.9.5"
PlutoTest = "~0.2.2"
PlutoUI = "~0.7.58"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.2"
manifest_format = "2.0"
project_hash = "ab59edaf731ee671d6a84507f1dccb93f54c76c4"

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

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.0+0"

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

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlutoTest]]
deps = ["HypertextLiteral", "InteractiveUtils", "Markdown", "Test"]
git-tree-sha1 = "17aa9b81106e661cffa1c4c36c17ee1c50a86eda"
uuid = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
version = "0.2.2"

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
# ╟─89f23045-e484-437c-9f96-ce1389cfc4c3
# ╟─ef4eea24-bc1c-43be-b9b6-d073ac2433cf
# ╟─69b8490f-cf04-4e73-bc7b-639b1fc0e2d6
# ╟─cbe5fcba-3ed7-41a6-8932-2693e370c16c
# ╟─812002d3-8603-4ffa-8695-2b2da7f0766a
# ╟─56db20a5-0e8d-4d34-b3ba-c3ab1b8de58e
# ╟─83d0162f-5960-4938-8353-91c4cd220459
# ╟─51448106-3e0e-4abf-84fc-7e6e81425d12
# ╟─3c0059b7-7a99-4c1c-a2bf-e47bdd06a252
# ╟─604837c5-b017-4d6c-a5c5-dab50d5f3f61
# ╟─8678b5e1-0b67-4097-82ba-0daa4e878032
# ╟─0bf51d8c-7adf-4231-8b2d-c976484a3e7c
# ╟─02905480-8864-4e56-af3a-6c7c0789ce6f
# ╟─2ef5db21-0092-4523-b930-0ec99c459ffa
# ╟─51114dc9-cb32-4d31-b780-6f5e372f8763
# ╟─8b24ce23-4ead-4fbc-875e-a8261f671abe
# ╟─3c8abdfc-cf68-4f10-a3e9-08d24803535b
# ╟─dfb316ca-0502-4419-93c2-6d455b7b2f98
# ╟─ae28cad6-2ffe-48b4-895b-fab1bd2f2443
# ╟─86e4b0dd-9bf5-4711-bf3f-b55ed2627a03
# ╟─8ea1ca6b-4bb7-4f53-907d-0e5ca83e5761
# ╟─ee5a3219-4547-4a9d-b527-3489a2925f68
# ╟─e5f2b4e1-f05a-4457-b2e9-091a86ef86bb
# ╟─efbd6d1c-d2c9-48a9-9d6c-dc9ce6af0b5b
# ╟─1421f832-9f97-4ec3-b967-64618983349b
# ╟─b139e8ea-88ad-4df4-9f13-c867edfc2db0
# ╟─e5bab2e1-be9e-4654-844a-d50285e330c8
# ╟─47c67fa6-1490-4134-9e0c-5754cb273d1e
# ╟─79ab206d-2140-4c78-8fd4-a874fe2551e1
# ╟─38261f04-f410-440e-a1cf-218fa240a0ae
# ╟─a0a97cd2-838c-4a2c-9233-969b3274764c
# ╟─0faa4042-42f5-4c74-9270-fbf2205920ca
# ╟─167cbd94-851f-4147-9b9d-9b46c7959785
# ╟─7af9e69c-2b81-4a90-861c-ed737a4a9ec4
# ╟─4d303641-0299-44d7-ba74-6daea0026b09
# ╟─2c456900-047d-432c-a62a-87f8eeaba8d5
# ╟─dc112303-061e-4e53-8f58-cf9ea0f556f1
# ╟─b2e49cd5-49d5-4ac7-a3ae-9820a97720fb
# ╟─d400d538-4f73-4490-ad68-aedbb57cd70f
# ╟─a98993b9-a5c0-4260-b96e-2655c472ccba
# ╟─e3fe649e-2733-455a-897d-d4d2d70b9dc6
# ╟─2dd5d359-eb44-4696-bc83-f257eff95618
# ╟─3229f0aa-54d1-43f4-a6aa-cf212620ae13
# ╟─b83ade3d-6f8d-4ac8-9255-956d0a348416
# ╟─bbb59b45-de20-41c1-b5dd-079fc51655f2
# ╟─67cf205a-3d89-4cd9-ab5e-febc85ea8af1
# ╟─c4442667-072a-4e17-94a4-104a8ec33bd0
# ╟─d8c5273f-7ebc-4399-b893-36f742162938
# ╟─cc1149de-4895-48aa-8335-6dcc78d882c9
# ╟─aeafbdbb-4aeb-452e-a21b-d2c8ec48c64e
# ╠═40f9fe4d-ddae-4bdb-aee2-7999e288931a
# ╠═f7425775-55aa-4e46-a11f-7d981a4cfacc
# ╠═91b6151d-284e-4f06-954c-ce648fec3327
# ╟─ddab6132-7d4d-41e8-81f3-ab0fc24cbeeb
# ╟─7174076d-5eba-4380-8d76-292935014d90
# ╟─0d76ea2f-18a9-46d1-8328-f077482d5d1f
# ╟─de95e033-932a-4de9-8e1b-36fcf22c7e20
# ╟─6efa4ee8-b477-4d47-8d42-5b87f3aa02d2
# ╟─f26e39cc-c175-4439-868a-0686250e8e29
# ╟─b16a228e-5056-44a0-ab57-0dea5082669d
# ╟─436c9fa2-b770-4dee-82a6-23e9baa551e4
# ╠═75c8f825-d988-4f9e-8038-6b4dd2e24181
# ╟─d92d55a3-8fbc-4178-81b4-7ddc379ef7c7
# ╟─089c9a6c-f4ef-4815-9a99-cb4023b42225
# ╟─4ea69625-0064-42da-a75a-a54fbd106f78
# ╟─13c0fbf3-08c6-4515-b710-f16b55165a2d
# ╟─574448b8-2ff1-4bff-8580-33bfcba860e8
# ╟─dd4855a0-0b7c-40a5-8565-94b40948f86d
# ╟─d31f0e84-dce9-4f81-8643-ef08684530d2
# ╟─676ac6ff-1b7e-4c88-b850-45f4375a8d58
# ╟─d43abe78-5a9d-4a22-999d-0ee85eb5ab7f
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
