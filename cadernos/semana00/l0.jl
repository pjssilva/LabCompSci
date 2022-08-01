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

# ╔═╡ 2f0e340d-4d19-406f-8104-596d9d76b388
begin
    # You use `using` to import the Package for local use
    # this imports all the names exported by the package
    using Compose
    using PlutoUI
end

# ╔═╡ fafae38e-e852-11ea-1208-732b4744e4c2
md"Lista 0, versão 1 -- 2º sem 2021_"

# ╔═╡ 7308bc54-e6cd-11ea-0eab-83f7535edf25
# Edite o código abaixo com o seu nome e email da DAC (sem o @unincamp.br)

student = (name = "João Ninguém", email_dac = "j000000")

# Preciosne o botão ▶ no canto inferior direito desta célula para rodar com os novos 
# dados ou use Shift+Enter

# POde ser necessário esperar que as outras células desse notebook rodem até  fim 
# Continue movendo a página para baixo para ver o que deve fazer

# ╔═╡ cdff6730-e785-11ea-2546-4969521b33a7
md"""

Submetido por: **_$(student.name)_** ($(student.email_dac)@unicamp.br)
"""

# ╔═╡ a2181260-e6cd-11ea-2a69-8d9d31d1ef0e
md"""
# Lista 0: Ficando pronto para o jogo

L0 data disponível: Terça, 10 de agosto de 2021.

**L0 data de entrega: Quinta 12 de agosto de 2021. Mas é melhor entregar na quarta para estar pronto para a aula da quinta**.

Em primeiro lugar: **bem vindo ao curso**. Estou muito animado em dividir com vocês ferramentas e ideias que uso cotidianamente para atacar probemas _reais_.

Espero que todos submetam essa **lista 0**, isso vai ajudar a saber quem conseguiu instalar o ambiente mínimo de uso do curso e tomar alguma atitude corretiva se for necessário. Mesm que você não tenha conseguido fazer muito, pelo menos coloque o seu nome e email da DAC e mande assim mesmo. A nota dessa lista não conta para o curso.🙂
"""

# ╔═╡ 31a8fbf8-e6ce-11ea-2c66-4b4d02b41995
md"""## Logística das listas

As listas serão feita com [notebooks PLuto](https://github.com/fonsp/Pluto.jl). Você deve completar o que for pedido e submeter o notebook no [Moodle](https://moodle.ggte.unicamp.br/course/view.php?id=11421).

As listas serão tipicamente disponibilizadas nas quintas e devem ser entregues na quinta seguint até as 11:59 da noite.

Homeworks will be released on Thursdays and due on Thursdays 11:59pm Eastern time.

O objetivo da L0 é você configurar o seu sistema corretament e testar a entrega. Vocẽ deve entregá-la mas ela não vai contar para a sua nota.
"""

# ╔═╡ f9d7250a-706f-11eb-104d-3f07c59f7174
md"## Requisitos desta lista

- Instalar Julia e Pluto.    
- Resolver o exercício 0.

Isso é tdo. se quiser pode também tentar fazer os outros exercícios quesão _opcionais_. "

# ╔═╡ 430a260e-6cbb-11eb-34af-31366543c9dc
md"""# Instalação

Para conseguir executar esse notebook a contento você terá que instalar a linguagem Julia e o Pluto, siga as istruções do vídeo da primeira aula. Veja-o no Moodle.

Uma vez instalado, inicie o Pluto a partir do REPL da Julia, digitando

```julia
import Pluto
Pluto.run()
```

Use o browser para carregar o arquivo do notebook e siga as instruções para resolver o exercício.

"""

# ╔═╡ a05d2bc8-7024-11eb-08cb-196543bbb8fd
md"## (Requerido) Exercício 0 - _Escrevendo sua prmeira função básica_

Calcule o quadrado de um número, isso é fácil basta mutiplicá-lo por si mesmo. 
##### Algoritmo:

Dado: $x$

Devolva: $x^2$

1. Multiplicando `x` por `x`"

# ╔═╡ e02f7ea6-7024-11eb-3672-fd59a6cff79b
function basic_square(x)
    return 1 # isso está errado, você deve preencher com seu código aqui!
end

# ╔═╡ 6acef56c-7025-11eb-2524-819c30a75d39
let
    result = basic_square(5)
    if !(result isa Number)
        md"""
      !!! warning "Não é um número"
          `basic_square` não retornou um número. Você esqueceu de escrever `return`?
      		"""
    elseif abs(result - 5 * 5) < 0.01
        md"""
      !!! correct
          Ótimo!
      		"""
    else
        md"""
      !!! warning "Incorreto"
          Continue tentando!
      		"""
    end
end

# ╔═╡ 348cea34-7025-11eb-3def-41bbc16c7512
md"Isso é tudo que deve ser feito nessa lista. Agora submita o notebook no Moodle. Nosso objetivo é saber se você tem um sistema que está funcionando.

Se quiser continuar e trabalhar um pouco mais, colocamos mais alguns exercícios abaixo."

# ╔═╡ b3c7a050-e855-11ea-3a22-3f514da746a4
if student.email_dac === "j000000"
    md"""
   !!! danger "Oops!"
       **Antes de submeter**, lembre de preencher o seu nome e o email da DAC no topo desse caderno!
   	"""
end

# ╔═╡ 339c2d5c-e6ce-11ea-32f9-714b3628909c
md"## (Opcional) Exercício 1 - _Raiz quadrada usando o método de Newton_

Calcular a raiz quadrada é fácil -- usando o que você aprendeu em Cálculo Numérico. 

Como isso é posível?

##### Algoritmo:

Dado: $x > 0$

Saída: $\sqrt{x}$

1. Comece com um valor `a` > 0
1. Divida `x` por `a`
1. Faça a = média `x/a` e `a`. (A raiz de `x` deve estar entre esses dois números. Porque?)
1. Continue até que `x/a` é aproximadamente igual a `a`. Devolta `a` como a raiz quadrada.

Pode ocorrer de você nunca obter `x/a` _exatamente igual_ a `a`, lembre de novo de cálculo numérico. Então se o seu código tentar continuar até que `x/a == a`, ele pode não parar nunca.

Então o seu algotimo deve possuir um parâmetro `error_margin`, que será usado para decidir quando `x/a` e `a` são tão parecidos que é permitido parar.
"

# ╔═╡ 56866718-e6ce-11ea-0804-d108af4e5653
md"### Exercício 1.1

O passo 3 do algoritimo define a próxima aproximação como a média entre o novo valor `x/a` e o anterior `a`.

Isso faz sentido porque a raiz desejada está entre esses dois números `x/a` e `a`. Porque?
"

# ╔═╡ bccf0e88-e754-11ea-3ab8-0170c2d44628
ex_1_1 = md"""
Escreva sua resposta aqui. Agora é uma boa hora para ler sobre Markdown.
"""

# ╔═╡ e7abd366-e7a6-11ea-30d7-1b6194614d0a
if !(@isdefined ex_1_1)
    md"""Do not change the name of the variable - write you answer as `ex_1_1 = "..."`"""
end

# ╔═╡ d62f223c-e754-11ea-2470-e72a605a9d7e
md"### Exercício 1.2

Escreava uma fnção `newton_sqrt` que implementa o algorimo descrito."

# ╔═╡ 4896bf0c-e754-11ea-19dc-1380bb356ab6
function newton_sqrt(x, error_margin = 0.01, a = x / 2) # a=x/2 é um chute padrão para o `a` inicial
    return x #  Isto está errado, complete com seu código.
end

# ╔═╡ 7a01a508-e78a-11ea-11da-999d38785348
newton_sqrt(2)

# ╔═╡ 682db9f8-e7b1-11ea-3949-6b683ca8b47b
let
    result = newton_sqrt(2, 0.01)
    if !(result isa Number)
        md"""
      !!! warning "Não é um número"
          `newton_sqrt` não retornou um número. Você esqueceu de digitar `return`?
      		"""
    elseif abs(result - sqrt(2)) < 0.01
        md"""
      !!! correct
          Muito bem!
      		"""
    else
        md"""
      !!! warning "Incorreto"
          Continue tentando!
      		"""
    end
end

# ╔═╡ 088cc652-e7a8-11ea-0ca7-f744f6f3afdd
md"""
!!! hint
    `abs(r - s)` é a distância entre `r` e `s`
"""

# ╔═╡ 5e24d95c-e6ce-11ea-24be-bb19e1e14657
md"## (Opcional) Exercício 2 - _triângulo de Sierpinksi_

O triângulo de Sierpinski triangle é definido _recursivamente_:

- Um triângulo Sierpinski de complexidade N é uma figura na forma de um triângulo que é formada por 3 figuras triângulares que são por sua vez triângulos de Sierpinski de complexidade N-1.

- Um triângulo Sierpinski de complexidade 0 é um triângulo sólido simples e equilátero.
"

# ╔═╡ 6b8883f6-e7b3-11ea-155e-6f62117e123b
md"Para desenhar um triângulo de Sierpinski, nós vamos usar um pacote externo, [_Compose.jl_](https://giovineitalia.github.io/Compose.jl/latest/tutorial). Vamos configurar o ambiente e instalar o pacote.

Um pacote é um software que possui um grupo de funcionalidades correlacionadas que podem ser usadas na forma de uma _caixa preta_ de acordo com sua especificação. Há [vários pacores Julia](https://juliahub.com/ui/Home).
"

# ╔═╡ dbc4da6a-e7b4-11ea-3b70-6f2abfcab992
md"Como na definição a função `sierpinksi` é _recursiva_: ela chama a si mesma."

# ╔═╡ 02b9c9d6-e752-11ea-0f32-91b7b6481684
complexity = 3

# ╔═╡ 1eb79812-e7b5-11ea-1c10-63b24803dd8a
if complexity == 3
    md"""
   Tente alterar valor de **`complexity` para `5`** na célular acima. 

   Aperte `Shift+Enter` para a mudança fazer efeito.
   	"""
else
    md"""
   **Muito bem!** Como você pode ver as diferentes células do caderno estão ligadas pelas variáveis que elas definem e usam, como numa planilha de cálculo!
   	"""
end

# ╔═╡ d7e8202c-e7b5-11ea-30d3-adcd6867d5f5
md"### Exercício 2.1

Como você pode ver a área total coberta pelos triângulos cheios diminui a medida que a complexidade aumenta."

# ╔═╡ f22222b4-e7b5-11ea-0ea0-8fa368d2a014
md"""
Você consegue escrever uma função que calcula a a área de `sierpinski(n)`, como uma fração da área de `sierpinski(0)`?

Teremos:
```
area_sierpinski(0) = 1.0
area_sierpinski(1) = 0.??
...
```
"""

# ╔═╡ ca8d2f72-e7b6-11ea-1893-f1e6d0a20dc7
function area_sierpinski(n)
    return 1.0 # Complete com sua implementação
end

# ╔═╡ 71c78614-e7bc-11ea-0959-c7a91a10d481
if area_sierpinski(0) == 1.0 && area_sierpinski(1) == 3 / 4
    md"""
   !!! correct
       Muito bem!
   	"""
else
    md"""
   !!! warning "Incorreto"
       Continue tentando!
   	"""
end

# ╔═╡ c21096c0-e856-11ea-3dc5-a5b0cbf29335
md"**Let's try it out below:**"

# ╔═╡ 52533e00-e856-11ea-08a7-25e556fb1127
md"Complexity = $(@bind n Slider(0:6, show_value=true))"

# ╔═╡ c1ecad86-e7bc-11ea-1201-23ee380181a1
md"""
!!! hint
    Você pode escrever a área `area_sierpinksi(n)` como uma função da `area_sierpinski(n-1)`?
"""

# ╔═╡ a60a492a-e7bc-11ea-0f0b-75d81ce46a01
md"Isso é tudo por enquanto, a gente se vê na próxima lista

## Apêndice
"

# ╔═╡ dfdeab34-e751-11ea-0f90-2fa9bbdccb1e
triangle() = compose(context(), polygon([(1, 1), (0, 1), (1 / 2, 0)]))

# ╔═╡ b923d394-e750-11ea-1971-595e09ab35b5
# Você pode mover a ordem das células, para facilitar a apresentação. 
# Pluto consegue manter a dependência entre trechos de código e executá-los 
# de maneira a obedecer a dependência entre os diversos trechos. Assim você
# está livre para reordenar trechos de código de forma a promover uma melhor
# organização / compreensão.

function place_in_3_corners(t)
    # Uses the Compose library to place 3 copies of t
    # in the 3 corners of a triangle.
    # treat this function as a black box,
    # or learn how it works from the Compose documentation here https://giovineitalia.github.io/Compose.jl/latest/tutorial/#Compose-is-declarative-1
    compose(
        context(),
        (context(1 / 4, 0, 1 / 2, 1 / 2), t),
        (context(0, 1 / 2, 1 / 2, 1 / 2), t),
        (context(1 / 2, 1 / 2, 1 / 2, 1 / 2), t),
    )
end

# ╔═╡ e2848b9a-e703-11ea-24f9-b9131434a84b
function sierpinski(n)
    if n == 0
        triangle()
    else
        t = sierpinski(n - 1) # constroi recursivamente um triângulo menor
        place_in_3_corners(t) # Coloca os três triângulos menores nos cantos 
        # para formar o triângulo maior.
    end
end

# ╔═╡ 9664ac52-e750-11ea-171c-e7d57741a68c
sierpinski(complexity)

# ╔═╡ df0a4068-e7b2-11ea-2475-81b237d492b3
sierpinski.(0:6)

# ╔═╡ 147ed7b0-e856-11ea-0d0e-7ff0d527e352
md"""

Sierpinski's triangle of complexity $(n)

 $(sierpinski(n))

has area **$(area_sierpinski(n))**

"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Compose = "a81c6b42-2e10-5240-aca2-a61377ecd94b"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
Compose = "~0.9.2"
PlutoUI = "~0.7.9"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "344f143fa0ec67e47917848795ab19c6a455f32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.32.0"

[[Compose]]
deps = ["Base64", "Colors", "DataStructures", "Dates", "IterTools", "JSON", "LinearAlgebra", "Measures", "Printf", "Random", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "c6461fc7c35a4bb8d00905df7adafcff1fe3a6bc"
uuid = "a81c6b42-2e10-5240-aca2-a61377ecd94b"
version = "0.9.2"

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

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
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

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "477bf42b4d1496b454c10cce46645bb5b8a0cf2c"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.2"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "44e225d5837e2a2345e69a1d1e01ac2443ff9fcb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.9"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "5f6c21241f0f655da3952fd60aa18477cf96c220"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.1.0"

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

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─fafae38e-e852-11ea-1208-732b4744e4c2
# ╟─cdff6730-e785-11ea-2546-4969521b33a7
# ╠═7308bc54-e6cd-11ea-0eab-83f7535edf25
# ╟─a2181260-e6cd-11ea-2a69-8d9d31d1ef0e
# ╟─31a8fbf8-e6ce-11ea-2c66-4b4d02b41995
# ╟─f9d7250a-706f-11eb-104d-3f07c59f7174
# ╟─430a260e-6cbb-11eb-34af-31366543c9dc
# ╟─a05d2bc8-7024-11eb-08cb-196543bbb8fd
# ╠═e02f7ea6-7024-11eb-3672-fd59a6cff79b
# ╟─6acef56c-7025-11eb-2524-819c30a75d39
# ╟─348cea34-7025-11eb-3def-41bbc16c7512
# ╟─b3c7a050-e855-11ea-3a22-3f514da746a4
# ╟─339c2d5c-e6ce-11ea-32f9-714b3628909c
# ╟─56866718-e6ce-11ea-0804-d108af4e5653
# ╠═bccf0e88-e754-11ea-3ab8-0170c2d44628
# ╟─e7abd366-e7a6-11ea-30d7-1b6194614d0a
# ╟─d62f223c-e754-11ea-2470-e72a605a9d7e
# ╠═4896bf0c-e754-11ea-19dc-1380bb356ab6
# ╠═7a01a508-e78a-11ea-11da-999d38785348
# ╟─682db9f8-e7b1-11ea-3949-6b683ca8b47b
# ╟─088cc652-e7a8-11ea-0ca7-f744f6f3afdd
# ╟─5e24d95c-e6ce-11ea-24be-bb19e1e14657
# ╟─6b8883f6-e7b3-11ea-155e-6f62117e123b
# ╠═2f0e340d-4d19-406f-8104-596d9d76b388
# ╟─dbc4da6a-e7b4-11ea-3b70-6f2abfcab992
# ╠═e2848b9a-e703-11ea-24f9-b9131434a84b
# ╠═9664ac52-e750-11ea-171c-e7d57741a68c
# ╠═02b9c9d6-e752-11ea-0f32-91b7b6481684
# ╟─1eb79812-e7b5-11ea-1c10-63b24803dd8a
# ╟─d7e8202c-e7b5-11ea-30d3-adcd6867d5f5
# ╠═df0a4068-e7b2-11ea-2475-81b237d492b3
# ╟─f22222b4-e7b5-11ea-0ea0-8fa368d2a014
# ╠═ca8d2f72-e7b6-11ea-1893-f1e6d0a20dc7
# ╟─71c78614-e7bc-11ea-0959-c7a91a10d481
# ╟─c21096c0-e856-11ea-3dc5-a5b0cbf29335
# ╟─52533e00-e856-11ea-08a7-25e556fb1127
# ╟─147ed7b0-e856-11ea-0d0e-7ff0d527e352
# ╟─c1ecad86-e7bc-11ea-1201-23ee380181a1
# ╟─a60a492a-e7bc-11ea-0f0b-75d81ce46a01
# ╠═dfdeab34-e751-11ea-0f90-2fa9bbdccb1e
# ╠═b923d394-e750-11ea-1971-595e09ab35b5
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
