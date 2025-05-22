### A Pluto.jl notebook ###
# v0.20.8

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 15187690-0403-11eb-2dfd-fd924faa3513
begin
    using Plots
	using PlutoUI
	using Statistics
	import Random
end

# ╔═╡ 01341648-0403-11eb-2212-db450c299f35
md"Tradução livre de [hw7.jl](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week7/hw7.jl)"

# ╔═╡ 095cbf46-0403-11eb-0c37-35de9562cebc
# edite o código abaixo com seu nome e email da dac (sem o @dac.unicamp.br)

student = (name = "João Ninguém", email_dac = "j000000")

# aperte o botão ▶ no canto inferior direito da célula para executar o que você
# editou, ou use Shift+Enter

# Agora siga na página para ver o que deve fazer.

# ╔═╡ 03a85970-0403-11eb-334a-812b59c0905b
md"""

Submetido por: **_$(student.name)_** ($(student.email_dac)@unicamp.br)
"""

# ╔═╡ 06f30b2a-0403-11eb-0f05-8badebe1011d
md"""

# **Lista 7**: _Modelagem de epidemias_

`Data de entrega`: 29/05/2025.

Este caderno contém verificações _simples_ para ajudar você a saber se o que fez faz sentido. Essas verificações são incompletas e não corrigem completamente os exercícios. Mas, se elas disserem que algo não está bom, você sabe que tem que tentar de novo.

_Lembrem as listas serão corrigidas com exemplos mais sofisticados e gerais do que aqueles das verificações incluídas_. 

Sintam-se livres de fazer perguntas no Discord.
"""

# ╔═╡ 107e65a4-0403-11eb-0c14-37d8d828b469
md"Vamos importar alguns pacotes que serão úteis e definir uma função que pode lhe ajudar."

# ╔═╡ d8797684-0414-11eb-1869-5b1e2c469011
# Might come handy below
function bernoulli(p::Number)
	rand() < p
end

# ╔═╡ 61789646-0403-11eb-0042-f3b8308f11ba
md"""
## **Exercício 1:** _Modelo baseado em agentes para um surto epidêmico -- tipos_

Nesta lista vamos desenvolver um modelo estocástico simples da infecção e recuperação em uma população que está passando por um **surto epidêmico** (ou seja, um rápido crescimento no número de pessoas infectadas). Uma das hipóteses fundamentais que vamos fazer é que a população está _bem misturada_, ou seja, todos estão em contato com todos. Um exemplo seria uma pequena escola ou universidade em que as pessoas estão constantemente se movendo e interagindo umas com as outras. 

O modelo é **baseado em indivíduos**, ou *agentes**. Vamos manter informação explícita sobre cada indivíduo, ou agente, da população e sua situação de saúde. Nesse modelo não vamos simular a sua posição no espaço. Vamos apenas considerar que existe alguma forma de interação entre os indivíduos que não está sendo detalhada. 

#### Exercício 1.1

Cada agente terá o seu próprio **estado interno**, que modela o seu estágio com relação à doença, podendo ser "suscetível", "infectado" ou "recuperado". Vamos codificar esses estados com os valores `S`, `I` ou `R`. Uma forma de fazer isso é usando um [**tipo enumerado**](https://en.wikipedia.org/wiki/Enumerated_type) ou **enum**. Variáveis desse tipo podem apenas assumir um entre um subconjunto predefinido de valores. A sintaxe para isso em Julia é:
"""

# ╔═╡ 26f84600-041d-11eb-1856-b12a3e5c1dc7
@enum InfectionStatus S I R

# ╔═╡ 271ec5f0-041d-11eb-041b-db46ec1465e0
md"""
Acabamos de definir um novo tipo `InfectionStatus`, assim como os nomes `S`, `I` e `R` que são os únicos valores que variáveis desse tipo podem assumir.

👉 Defina a variável `test_status` cujo valor é `S` (Se tiver dúvidas de como fazer isso procure informação na Internet).
"""

# ╔═╡ 7f4e121c-041d-11eb-0dff-cd0cbfdfd606
test_status = missing

# ╔═╡ 7f744644-041d-11eb-08a0-3719cc0adeb7
md"""
👉 Use a função `typeof` para encontrar o tipo de `test_status`.
"""

# ╔═╡ 88c53208-041d-11eb-3b1e-31b57ba99f05


# ╔═╡ 847d0fc2-041d-11eb-2864-79066e223b45
md"""
👉 Converta `test_status` para um inteiro usando a função `Integer`. Qual o valor obtido? Quais valores tem `I` e `R`?
"""

# ╔═╡ f2792ff5-b0b6-4fcd-94aa-0b6ef048f6ab


# ╔═╡ 860790fc-0403-11eb-2f2e-355f77dcc7af
md"""
#### Exercício 1.2

Para cada agente, vamos querer manter o seu estágio de doença e o número de **outros** agentes que ele infectou durante a simulação. Uma boa solução para esse é definir um **novo tipo** `Agent` que armazena a informação necessária, como fazemos a seguir:
"""

# ╔═╡ ae4ac4b4-041f-11eb-14f5-1bcde35d18f2
mutable struct Agent
	status::InfectionStatus
	num_infected::Int64
end

# ╔═╡ ae70625a-041f-11eb-3082-0753419d6d57
md"""
Quando você define um novo tipo, Julia automaticamente define um ou mais **construtores**, que são métodos de uma função genérica com o **mesmo nome** que o tipo. Eles são usados para criar objetos desse novo tipo.

👉 Use a função `methods` para descobrir quantos construtores foram pré-definidos para o tipo `Agent`.
"""

# ╔═╡ 60a8b708-04c8-11eb-37b1-3daec644ac90


# ╔═╡ 189cae1e-0424-11eb-2666-65bf297d8bdd
md"""
👉 Crie um gente `test_agent` com status `S` e `num_infected` valendo 0.
"""

# ╔═╡ 18d308c4-0424-11eb-176d-49feec6889cf
test_agent = missing

# ╔═╡ 190deebc-0424-11eb-19fe-615997093e14
md"""
👉 Por conveniência, defina um novo construtor (ou seja, um novo método para a função com nome do tipo) que não recebe argumentos e cria um `Agent` com status `S` e número de infectados 0. Essa função deve chamar o construtor default que Julia cria. Esse método está sendo definido depois (fora) da definição do tipo e por isso é conhecido como **construtor externo**.

(No Pluto, a definição de uma estrutura (_struct_) e os respectivos construtores (externos) devem ser combinados em uma única célula usando um bloco `begin end`, então faça essa parte do exercício na célula acima)

Vamos verificar que os novo método funciona corretamente. Quantos métodos de construtor existem agora?
"""

# ╔═╡ 82f2580a-04c8-11eb-1eea-bdb4e50eee3b
# Uncomment and test your new Agent constructor
# Agent()

# ╔═╡ 8631a536-0403-11eb-0379-bb2e56927727
md"""
#### Exercício 1.3
👉 Escreva funções `set_status!(a)` e `inc_num_infected!(a)` que modificam o campo `status` de  `Agent` para `a` e adiciona um no campo `num_infected` respectivamente. Verifique que funciona. Note a convenção de usar o ponto de exclamação no final do nome das funções como forma de indicar que elas _alteram_ os seus argumentos.
"""

# ╔═╡ 98beb336-0425-11eb-3886-4f8cfd210288
function set_status!(agent::Agent, new_status::InfectionStatus)
	# your code here
end

# Não se esqueça de adicionar outra célula abaixo para definir a função set_num_infected.

# ╔═╡ 866299e8-0403-11eb-085d-2b93459cc141
md"""
👉 Nós também vamos precisar das funções `is_susceptible` e `is_infected` que verificam se um dado agente está em um desses estados (respectivamente). Além disso, defina a função `get_num_infected` que simplesmente devolve o número de infectados pelo agente.
"""

# ╔═╡ 9a837b52-0425-11eb-231f-a74405ff6e23
function is_susceptible(agent::Agent)
	
	return missing
end

# ╔═╡ a8dd5cae-0425-11eb-119c-bfcbf832d695
function is_infected(agent::Agent)
	
	return missing
end

# ╔═╡ 46977c5a-e176-45f6-87bb-23bc964d25e6
function get_num_infected(agent::Agent)
	
	return missing
end

# ╔═╡ 8692bf42-0403-11eb-191f-b7d08895274f
md"""
#### Exercício 1.4
👉 Escreva uma função `generate_agents(N)` que retorna um vetor com `N` agentes novos. Eles devem todos ser inicializados como suscetíveis, menos 1, que deve ser escolhido aleatoriamente entre todos de maneira uniforme. Esse agente especial deve ser iniciado como infectado.
"""

# ╔═╡ 7946d83a-04a0-11eb-224b-2b315e87bc84
function generate_agents(N::Integer)
	
	# Substitute the single agent below by the right solution
	return [Agent(S, 0)]
end

# ╔═╡ 488771e2-049f-11eb-3b0a-0de260457731
generate_agents(3)

# ╔═╡ 86d98d0a-0403-11eb-215b-c58ad721a90b
md"""
Vamos também precisar de novos tipos representando diferentes surtos infecciosos.

Definimos abaixo uma `struct` (imutável) chamada `InfectionRecovery` com parâmetros `p_infection` e `p_recovery` representando as probabilidades de um encontro com um infeccioso gerar uma infecção e a chance de um doente se recuperar, respectivamente. Ela será um subtipo de um tipo abstrato `AbstractInfection`. Depois iremos definir outras variações desse tipo.
"""

# ╔═╡ 223933a4-042c-11eb-10d3-852229f25a35
abstract type AbstractInfection end

# ╔═╡ 1a654bdc-0421-11eb-2c38-7d35060e2565
struct InfectionRecovery <: AbstractInfection
	p_infection
	p_recovery
end

# ╔═╡ 2d3bba2a-04a8-11eb-2c40-87794b6aeeac
md"""
#### Exercício 1.5
👉 Escreva uma função `interact!` que recebe um agente (`agent`) do tipo  `Agent` que será afetado, uma fonte, `source`, do tipo `Agent` e um surto (`infection`) do tipo `InfectionRecovery`. Ela irá implementar uma única iteração (unidirecional) entre dois agentes:

- Se `agent` está suscetível e a fonte `source` está infectada, então a fonte `source` infecta o `agent` com a probabilidade de infecção definida pelo surto. Se a fonte `source` infectar o outro agente, então o seu `num_infected` deve ser atualizado.
- Se `agent` já está infectado, então ele se recupera com a respectiva probabilidade definida no surto.
- Caso contrário, nada ocorre.

Obs: para decidir se um evento ocorre com uma dada probabilidade você pode usar a função `bernoulli` definida no início deste caderno (ou escrever seu próprio código, é claro).

$(html"<span id=interactfunction></span>")
"""

# ╔═╡ 9d0f9564-e393-401f-9dd5-affa4405a9c6
function interact!(agent::Agent, source::Agent, infection::InfectionRecovery)
	
	# your code here
end

# ╔═╡ b21475c6-04ac-11eb-1366-f3b5e967402d
md"""
Brinque um pouco com o caso de teste abaixo para verificar o funcionamento de sua função. Tente trocar as definições de `agent`, `source` e `infection` para testar os diversos casos. Como estamos usando aleatoriedade, pode ser necessário rodar o código mais de uma vez para cada caso para ver o que ocorre.
"""

# ╔═╡ 9c39974c-04a5-11eb-184d-317eb542452c
let
	agent = Agent(S, 0)
	source = Agent(I, 0)
	infection = InfectionRecovery(0.9, 0.5)
	
	interact!(agent, source, infection)
	
	(agent=agent, source=source)
end

# ╔═╡ 619c8a10-0403-11eb-2e89-8b0974fb01d0
md"""
## **Exercício 2:** _Modelo baseado em agentes de um surto epidêmico -- Simulação de Monte Carlo_

Neste exercício vamos usar o que você fez no exercício 1 para escrever uma simulação de Monte Carlo de como uma infecção se propaga em uma população.

Você deve re-utilizar as funções que já escreveu e, se achar necessário, criar funções auxiliares. Funções curtas são mais simples de entender e enfatizam a introdução de novas funcionalidades paulatinamente.

Você não deve usar nenhuma variável global dentro de suas funções. Cada função deve receber em seus argumentos toda informação que precisa para realizar a sua tarefa. Deste modo, devemos pensar cuidadosamente o que cada função precisa receber.

#### Exercício 2.1

👉 Escreva uma função `step!` que recebe um vetor de agentes `agents` e uma descrição de surto `infection` do tipo `InfectionRecovery`. Ela deve implementar um único passo da dinâmica do surto seguindo as regras:

- Escolha dois agentes aleatoriamente: um fará o papel de `agent` e o outro de `source`.
- Execute `interact!(agent, source, infection)`.

Obs: Note que apesar da função não retornar nada, o vetor `agents` é modificado "no local". Isso é condizente com o que ocorre em outras linguagens, onde a alteração de um tipo complexo é o resultado de uma função.
"""

# ╔═╡ 2ade2694-0425-11eb-2fb2-390da43d9695
function step!(agents::Vector{Agent}, infection::InfectionRecovery)
	
end

# ╔═╡ 955321de-0403-11eb-04ce-fb1670dfbb9e
md"""
👉 Escreva uma função `sweep!`. Ela deve executar `step!` $N$ vezes, em que $N$ é o número de agentes. Assim, cada agente age, em média, uma vez por varrida. Uma varrida é portanto a unidade de tempo da nossa simulação de  Monte Carlo.
"""

# ╔═╡ 46133a74-04b1-11eb-0b46-0bc74e564680
function sweep!(agents::Vector{Agent}, infection::AbstractInfection)
	
end

# ╔═╡ 95771ce2-0403-11eb-3056-f1dc3a8b7ec3
md"""
👉 Escreva uma função `simulation` que faz o seguinte:

1. Cria $N$ agentes.

2. Executa `sweep!` $T$ vezes. Calcula e armazena o número total de agentes após cada estado a cada passagem (`sweep!`) nos vetores `S_counts`, `I_counts` e `R_counts`. Note que o valor inicial, antes do primeiro `sweep` não deve ser devolvido.

3. Retorna os vetores `S_counts`, `I_counts` e `R_counts` usando uma **tupla nomeada** com chaves `S`, `I` e `R`.

Você já viu tuplas nomeadas. De fato a variável `student` no topo deste caderno é uma!
"""

# ╔═╡ 887d27fc-04bc-11eb-0ab9-eb95ef9607f8
function simulation(N::Integer, T::Integer, infection::AbstractInfection)
    # Change the constant vectors below by the right values computed by your code
	return (S=[99, 98], I=[1, 1], R=[0, 1])
end

# ╔═╡ b92f1cec-04ae-11eb-0072-3535d1118494
simulation(3, 20, InfectionRecovery(0.9, 0.2))

# ╔═╡ 2c62b4ae-04b3-11eb-0080-a1035a7e31a2
simulation(100, 1000, InfectionRecovery(0.005, 0.2))

# ╔═╡ 28db9d98-04ca-11eb-3606-9fb89fa62f36
@bind run_basic_sir Button("Run simulation again!")

# ╔═╡ c5156c72-04af-11eb-1106-b13969b036ca
let
	run_basic_sir
	
	N = 100
	T = 1000
	sim = simulation(N, T, InfectionRecovery(0.02, 0.002))
	T = length(sim.S)
	
	result = plot(sim.S, ylim=(0, N), label="Susceptible")
	plot!(result, sim.I, ylim=(0, N), label="Infectious")
	plot!(result, sim.R, ylim=(0, N), label="Recovered")
end

# ╔═╡ bf6fd176-04cc-11eb-008a-2fb6ff70a9cb
md"""
#### Exercício 2.2
Ótimo, você chegou até aqui! Toda vez que executamos a simulação conseguimos resultados diferentes, justamente porque ela é aleatória. Mas ao repetir a simulação várias vezes, começamos a ter uma ideia melhor de qual é o comportamento médio do modelo. Esta é a essência do método e Monte de Carlo. Você usa aleatoriedade gerada no computador para gerar as suas amostras.

Ao invés de apertar o botão várias vezes, podemos fazer o computador repetir a simulação. Nas próximas células a simulação será executada  `num_simulations=20` vezes com $N = 100$, $p_\text{infection} = 0.02$, $p_\text{recovery} = 0.002$ e $T = 1000$. 

Cada simulação retorna com a tupla nomeada com as contagens dos estados. Assim o resultado dessas múltiplas simulações serão um array desses resultados. Dê uma olhada "dentro" do resultado,  `simulations`, e assegure-se que você entendeu sua estrutura.
"""

# ╔═╡ 38b1aa5a-04cf-11eb-11a2-930741fc9076
function repeat_simulations(N, T, infection, num_simulations)
	map(1:num_simulations) do _
		simulation(N, T, infection)
	end
end

# ╔═╡ 80c2cd88-04b1-11eb-326e-0120a39405ea
begin
	Random.seed!(1)
	simulations = repeat_simulations(100, 1000, InfectionRecovery(0.02, 0.002), 20)
end

# ╔═╡ 80e6f1e0-04b1-11eb-0d4e-475f1d80c2bb
md"""
Na célula abaixo, apresentamos a evolução do número de indivíduos infectados $I$ como uma função do tempo nas várias simulações todas ao mesmo tempo usando transparência (`alpha=0.5` no comando que gera o gráfico).
"""

# ╔═╡ 9cd2bb00-04b1-11eb-1d83-a703907141a7
let
	p = plot()
	
	for sim in simulations
		plot!(p, sim.I, alpha=.5, label=nothing)
	end
	
	p
end

# ╔═╡ 95c598d4-0403-11eb-2328-0175ed564915
md"""
👉 Escreva uma função `sir_mean_plot` que retorna o gráfico das médias de $S$, $I$ e $R$ em função do tempo como uma única figura.
"""

# ╔═╡ 843fd63c-04d0-11eb-0113-c58d346179d6
function sir_mean_plot(simulations::Vector{<:NamedTuple})
	# you might need T for this function, here's a trick to get it:
	T = length(first(simulations).S)
	
	return missing
end

# ╔═╡ 7f635722-04d0-11eb-3209-4b603c9e843c
sir_mean_plot(simulations)

# ╔═╡ a4c9ccdc-12ca-11eb-072f-e34595520548
let
	Random.seed!(0)
	simulations2 = repeat_simulations(100, 1000, InfectionRecovery(0.02, 0.002), 200)
	T = length(first(simulations2).S)
	
	all_S_counts = map(result -> result.S, simulations2)
	all_I_counts = map(result -> result.I, simulations2)
	all_R_counts = map(result -> result.R, simulations2)
	
	mean_states = (
		S=round.(sum(all_S_counts) ./ length(simulations2) ./ 100, digits=4),
		I=round.(sum(all_I_counts) ./ length(simulations2) ./ 100, digits=4),
		R=round.(sum(all_R_counts) ./ length(simulations2) ./ 100, digits=4)
	)
end

# ╔═╡ dfb99ace-04cf-11eb-0739-7d694c837d59
md"""
👉 Brinque um pouco com os valores de $p_\text{infection}$ e $p_\text{recovery}$ na célula acima. Com um dos valores fixados, encontre o outro valor para o qual o surto fica sob controle no sentido que a média de infectados não passa de 2. Para isso você vai ter que alterar o código acima para ver o número máximo de infectados.
"""

# ╔═╡ 1c6aa208-04d1-11eb-0b87-cf429e6ff6d0
md"Escreva os valores que você encontrou acima."

# ╔═╡ 95eb9f88-0403-11eb-155b-7b2d3a07cff0
md"""
👉 Escreva uma função `sir_mean_error_plot` que faz o mesmo que `sir_mean_plot`, mas também calcula **o desvio padrão** $\sigma$ de $S$, $I$, $R$ a cada passo. Adicione essa informação usado **faixas de erro**, através da opção `ribbon=σ` no comando `plot`; use transparência.

Isso deve confirmar que as distribuição de $S, I$ e $R$ a cada passo são bastantes dispersas!
"""

# ╔═╡ 287ee7aa-0435-11eb-0ca3-951dbbe69404
function sir_mean_error_plot(simulations::Vector{<:NamedTuple})
	# you might need T for this function, here's a trick to get it:
	T = length(first(simulations).S)
	
	return missing
end

# ╔═╡ 9611ca24-0403-11eb-3582-b7e3bb243e62
md"""
#### Exercício 2.3

👉 Grafique a distribuição de probabilidade dos valores `num_infected`. Ela possui um formato reconhecível? Se quiser aumente o número de agentes para ter uma ideia melhor das estatísticas.

"""

# ╔═╡ 26e2978e-0435-11eb-0d61-25f552d2771e
begin
	# The simulation below returns the agents instead of the counts of status
	function simulation2(N::Integer, T::Integer, infection::AbstractInfection)
		agents = generate_agents(N)
		for t = 1:T
			sweep!(agents, infection)
		end
		return agents
	end
	
	infection = InfectionRecovery(0.02, 0.002)
	# Increase n_agents if needed
	n_agents, duration = 20, 1000
	agents = simulation2(n_agents, duration, infection)
	
	# Process agents and plot the distribution of num_infected
	# add your code here
end

# ╔═╡ 61c00724-0403-11eb-228d-17c11670e5d1
md"""
## **Exercício 3:** _Reinfecção_

Este exercício vai *re-utilizar* a nossa infraestrutura de simulação para estudar uma dinâmica de um tipo diferente de infecção. Nela não se atinge imunidade, ou seja ninguém se recupera de forma definitiva, as pessoas podem se **reinfectar**.

#### Exercício 3.1
👉 Crie um noto tipo `Reinfection` para representar esse novo tipo de surto. Ele deve ter os mesmos dois campos que  `InfectionRecovery` (`p_infection` e `p_recovery`). Entretanto, "recuperação" agora significa "tornar-se suscetível de novo", ao invés de se mover para a classe `R`. 

Esse novo tipo `Reinfection` deve também ser **subtipo** de `AbstractInfection`. Isso nos permite usar as funções anteriores que foram definidas para o tipo "pai", ou super-tipo. Por isso que as assinaturas (parâmetros e seus tipos) das funções já foram fornecidas.
"""

# ╔═╡ 8dd97820-04a5-11eb-36c0-8f92d4b859a8


# ╔═╡ 99ef7b2a-0403-11eb-08ef-e1023cd151ae
md"""
👉 Crie um novo **método** para a função `interact!` que aceita o novo tipo de surto reutilizando ao máximo a funcionalidade anterior, mas dando a nova interpretação da situação de recuperação: voltar ao estado suscetível (ninguém se recupera). 
"""

# ╔═╡ bbb103d5-c8f9-485b-9337-40892bb60506


# ╔═╡ 9a13b17c-0403-11eb-024f-9b37e95e211b
md"""
#### Exercício 3.2
👉 Use o código abaixo para rodar a simulação 20 vezes. Note que ele chama a rotina `repeat_simulation` que, por sua vez, chama `sweep!` e `simulation`. Todas essas funções podem ser genéricas e funcionar com qualquer `AbstractInfection`. (Se elas não estavam assim, ajuste-as). A única rotina que realmente depende do tipo específico de surto é a `interact!` que você adaptou logo acima. Assim, o código abaixo deveria funcionar. Para testar isso comente a primeira linha, que está copiando o resultado das simulações anteriores, e descomente a linha seguinte para rodar o novo código. Ele deveria funcionar. Se não funcionar faça ajustes no seu código acima conforme necessário.
"""

# ╔═╡ 1ac4b33a-0435-11eb-36f8-8f3f81ae7844
# Comment the line below and uncomment the next line it should run
simulations_reinf = copy(simulations)
# simulations_reinf = repeat_simulations(100, 1000, Reinfection(0.02, 0.002), 20)

# ╔═╡ 9a377b32-0403-11eb-2799-e7e59caa6a45
md"""
👉 Depois de rodar a simulação acima, desenhe o $I$ (médio entre todas as rodadas) como uma função do tempo. O comportamento é o mesmo de antes? Descreva o que você vê.
"""

# ╔═╡ 21c50840-0435-11eb-1307-7138ecde0691
let
	p = plot()
	
	for sim in simulations_reinf
		plot!(p, sim.I, alpha=.5, color = :red,  label=nothing)
	end
	
	# Adapt to plot the mean behavior here as before
	
	p
end

# ╔═╡ cdd25106-e4b3-44d8-a4a0-d1e7dd1f6db9
if student.name == "João Ninguém"
	md"""
	!!! danger "Antes de submeter"
	    Lembre de preencher seu **nome** e **email DAC** no topo deste caderno.
	"""
end

# ╔═╡ 531d13c2-0414-11eb-0acd-4905a684869d
if student.name == "Jazzy Doe"
	md"""
	!!! danger "Before you submit"
	    Remember to fill in your **name** and **Kerberos ID** at the top of this notebook.
	"""
end

# ╔═╡ 4f19e872-0414-11eb-0dfd-e53d2aecc4dc
md"## Function library

Just some helper functions used in the notebook."

# ╔═╡ 48a16c42-0414-11eb-0e0c-bf52bbb0f618
hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))

# ╔═╡ 9cf9080a-04b1-11eb-12a0-17013f2d37f5
md"""
👉 Calcule o **número médio de agentes infectados a cada instante do tempo** nas simulações. Adicione essa informação ao gráfico usando uma linha mais espessa (`lw=3` para "linewidth") modificando a célula acima.

Verifique a solução você mesmo: a sua curva segue a tendência média?

Obs: Se você achar que a média está baixa, lembre-se de olhar para baixo na figura e ver que há um grupo simulações onde o surto não ocorre, porque o primeiro paciente fica curado antes de infectar outros pacientes. Pense um pouco sobre isso e veja as probabilidades de infecção e cura. 

$(hint(md"Este exercício exige um pouco de criatividade com os arrays, funções anônimas, `map`, ou o que mais você achar necessário! E lembre-se, não tenha medo de laços. Em Julia laços são eficientes."))
"""

# ╔═╡ 461586dc-0414-11eb-00f3-4984b57bfac5
almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))

# ╔═╡ 43e6e856-0414-11eb-19ca-07358aa8b667
still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))

# ╔═╡ 41cefa68-0414-11eb-3bad-6530360d6f68
keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))

# ╔═╡ 3f5e0af8-0414-11eb-34a7-a71e7aaf6443
yays = [md"Fantastic!", md"Splendid!", md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next section."]

# ╔═╡ 3d88c056-0414-11eb-0025-05d3aff1588b
correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))

# ╔═╡ 3c0528a0-0414-11eb-2f68-a5657ab9e73d
not_defined(variable_name) = Markdown.MD(Markdown.Admonition("danger", "Oopsie!", [md"Make sure that you define a variable called **$(Markdown.Code(string(variable_name)))**"]))

# ╔═╡ 7c515a7a-04d5-11eb-0f36-4fcebff709d5
if !@isdefined(set_status!)
	not_defined(:set_status!)
else
	let
		agent = Agent(I,2)
		
		set_status!(agent, R)
		
		if agent.status == R
			correct()
		else
			keep_working()
		end
	end
end

# ╔═╡ c4a8694a-04d4-11eb-1eef-c9e037e6b21f
if !@isdefined(is_susceptible)
	not_defined(:is_susceptible)
else
	let
		result1 = is_susceptible(Agent(I,2))
		result2 = is_infected(Agent(I,2))
		result3 = get_num_infected(Agent(I, 2))
		
		if result1 isa Missing || result2 isa Missing || result3 isa Missing
			still_missing()
		elseif !(result1 isa Bool) || !(result2 isa Bool)
			keep_working(md"Make sure that you return either `true` or `false`.")
		elseif !(result3 isa Int)
			keep_working(md"For `get_num_infected` return an `Int`.")
		elseif result1 === false && result2 === true && result3 == 2
			if is_susceptible(Agent(S,3)) && !is_infected(Agent(R,9))
				correct()
			else
				keep_working()
			end
		else
			keep_working()
		end
	end
end

# ╔═╡ 393041ec-049f-11eb-3089-2faf378445f3
if !@isdefined(generate_agents)
	not_defined(:generate_agents)
else
	let
		result = generate_agents(4)
		
		if result isa Missing
			still_missing()
		elseif result isa Nothing
			keep_working("The function returned `nothing`. Did you forget to return something?")
		elseif !(result isa Vector) || !all(x -> x isa Agent, result)
			keep_working(md"Make sure that you return an array of objects of the type `Agent`.")
		elseif length(result) != 4
			almost(md"Make sure that you return `N` agents.")
		elseif length(Set(result)) != 4
			almost(md"You returned the **same** agent `N` times. You need to call the `Agent` constructor `N` times, not once.")
		else
			if sum(a -> a.status == I, result) != 1
				almost(md"Exactly one of the agents should be infectious.")
			else
				correct()
			end
		end
	end
end

# ╔═╡ 759bc42e-04ab-11eb-0ab1-b12e008c02a9
if !@isdefined(interact!)
	not_defined(:interact!)
else
	let
		agent = Agent(S, 9)
		source = Agent(I, 0)
		interact!(agent, source, InfectionRecovery(0.0, 1.0))
		
		if source.status != I || source.num_infected != 0
			keep_working(md"The `source` should not be modified if no infection occured.")
		elseif agent.status != S
			keep_working(md"The `agent` should get infected with the right probability.")
		else
			agent = Agent(S, 9)
			source = Agent(S, 0)
			interact!(agent, source, InfectionRecovery(1.0, 1.0))

			if source.status != S || source.num_infected != 0 || agent.status != S
				keep_working(md"The `agent` should get infected with the right probability if the source is infectious.")
			else
				agent = Agent(S, 9)
				source = Agent(I, 3)
				interact!(agent, source, InfectionRecovery(1.0, 1.0))

				if agent.status == R
					almost(md"The agent should not recover immediately after becoming infectious.")
				elseif agent.status == S
					keep_working(md"The `agent` should recover from an infectious state with the right probability.")
				elseif source.status != I || source.num_infected != 4
					almost(md"The `source` did not get updated correctly after infecting the `agent`.")
				else
					correct(md"Your function treats the **susceptible** agent case correctly!")
				end
			end
		end
	end
end

# ╔═╡ 1491a078-04aa-11eb-0106-19a3cf1e94b0
if !@isdefined(interact!)
	not_defined(:interact!)
else
	let
		agent = Agent(I, 9)
		source = Agent(S, 0)

		interact!(agent, source, InfectionRecovery(1.0, 1.0))
		
		if source.status != S || source.num_infected != 0
			keep_working(md"The `source` should not be modified if `agent` is infectious.")
		elseif agent.status != R
			keep_working(md"The `agent` should recover from an infectious state with the right probability.")
		elseif agent.num_infected != 9
			keep_working(md"`agent.num_infected` should not be modified if `agent` is infectious.")
		else
			let
				agent = Agent(I, 9)
				source = Agent(R, 0)

				interact!(agent, source, InfectionRecovery(1.0, 0.0))
				
				if agent.status == R
					keep_working(md"The `agent` should recover from an infectious state with the right probability.")
				else
					correct(md"Your function treats the **infectious** agent case correctly!")
				end
			end
		end
	end
end

# ╔═╡ f8e05d94-04ac-11eb-26d4-6f1d2c5ed272
if !@isdefined(interact!)
	not_defined(:interact!)
else
	let
		agent = Agent(R, 9)
		source = Agent(I, 0)
		interact!(agent, source, InfectionRecovery(1.0, 1.0))
		
		if source.status != I || source.num_infected != 0
			keep_working(md"The `source` should not be modified if no infection occured.")
		elseif agent.status != R || agent.num_infected != 9
			keep_working(md"The `agent` should not be momdified if it is in a recoved state.")
		else
			correct(md"Your function treats the **recovered** agent case correctly!")
		end
	end
end

# ╔═╡ 39dffa3c-0414-11eb-0197-e72b299e9c63
bigbreak = html"<br><br><br><br><br>";

# ╔═╡ 5689841e-0414-11eb-0492-63c77ddbd136
bigbreak

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
Plots = "~1.40.4"
PlutoUI = "~0.7.59"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.9"
manifest_format = "2.0"
project_hash = "2ab862d0d4bffe98fac562d004181398d60c8b9a"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1b96ea4a01afe0ea4090c5c8039690672dd13f2e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.9+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "2ac646d71d0d24b44f3f8c84da8c9f4d70fb67df"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.4+0"

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
git-tree-sha1 = "64e15186f0aa277e174aa81798f7eb8598e0157e"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.0"

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

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "d9d26935a0bcffc87d2613ce14c527c99fc543fd"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.5.0"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "4e1fe97fdaed23e9dc21d4d664bea76b65fc50a0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.22"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "473e9afc9cf30814eb67ffa5f2db7df82c3ad9fd"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.16.2+0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.DocStringExtensions]]
git-tree-sha1 = "e7b7e6f178525d17c720ab9c081e4ef04429f860"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.4"

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

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "53ebe7511fa11d33bec688a9178fac4e49eeee00"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.2"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "466d45dc38e15794ec7d5d63ec03d776a9aff36e"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.4+1"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "301b5d5d731a0654825f1f2e906990f7141a106b"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.16.0+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "2c5512e11c791d1baed2049c5652441b28fc6a31"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7a214fdac5ed5f59a22c2d9a885a16da1c74bbc7"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.17+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "fcb0584ff34e25155876418979d4c8971243bb89"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.4.0+2"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Preferences", "Printf", "Qt6Wayland_jll", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "p7zip_jll"]
git-tree-sha1 = "7ffa4049937aeba2e5e1242274dc052b0362157a"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.14"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "98fc192b4e4b938775ecd276ce88f539bcec358e"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.14+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "b0036b392358c80d2d2124746c2bf3d48d457938"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.82.4+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a6dbda1fd736d60cc477d99f2e7a042acfa46e8"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.15+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "PrecompileTools", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "f93655dc73d7a0b4a368e3c0bce296ae035ad76e"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.16"

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

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IrrationalConstants]]
git-tree-sha1 = "e2222959fbc6c19554dc15174c81bf7bf3aa691c"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.4"

[[deps.JLFzf]]
deps = ["REPL", "Random", "fzf_jll"]
git-tree-sha1 = "82f7acdc599b65e0f8ccd270ffa1467c21cb647b"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.11"

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

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "eac1206917768cb54957c65a615460d87b455fc1"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.1.1+0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "170b660facf5df5de098d866564877e119141cbd"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.2+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aaafe88dccbd957a8d82f7d05be9b69172e0cee3"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.0.1+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "eb62a3deb62fc6d8822c0c4bef73e4412419c5d8"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.8+0"

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
git-tree-sha1 = "cd10d2cc78d34c0e2a3a36420ab607b611debfbb"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.7"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

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

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "27ecae93dd25ee0909666e6835051dd684cc035e"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+2"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "d36c21b9e7c172a44a10484125024495e2625ac0"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.1+1"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "be484f5c92fad0bd8acfef35fe017900b0b73809"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.18.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a31572773ac1b745e0343fe5e2c8ddda7a37e997"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.41.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "4ab7581296671007fc33f07a721631b8855f4b1d"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.1+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "321ccef73a96ba828cd51f2ab5b9f917fa73945a"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.41.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

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

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "f02b56007b064fbfddb4c9cd60161b6dd0f40df3"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.1.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "9b8215b1ee9e78a293f99797cd31375471b2bcae"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.3"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+4"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "f1a7e086c677df53e064e0fdd2c9d0b0833e3f6e"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.5.0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "9216a80ff3682833ac4b733caa8c00390620ba5d"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.0+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6703a85cb3781bd5909d48730a67205f3f31a575"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.3+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "05868e21324cede2207c6f0f466b4bfef6d5e7ee"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "3b31172c032a1def20c98dae3f2cdc9d10e3b561"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.56.1+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "7d2f8f21da5db6a806faf7b9b292296da42b2810"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.3"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "db76b1ecd5e9715f3d043cec13b2ec93ce015d53"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.44.2+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

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

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "TOML", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "809ba625a00c605f8d00cd2a9ae19ce34fc24d68"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.40.13"

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
git-tree-sha1 = "d3de2694b52a01ce61a036f18ea9c0f61c4a9230"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.62"

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

[[deps.PtrArrays]]
git-tree-sha1 = "1d36ef11a9aaf1e8b74dacc6a731dd1de8fd493d"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.3.0"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "492601870742dcd38f233b23c3ec629628c1d724"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.7.1+1"

[[deps.Qt6Declarative_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6ShaderTools_jll"]
git-tree-sha1 = "e5dd466bf2569fe08c91a2cc29c1003f4797ac3b"
uuid = "629bc702-f1f5-5709-abd5-49b8460ea067"
version = "6.7.1+2"

[[deps.Qt6ShaderTools_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "1a180aeced866700d4bebc3120ea1451201f16bc"
uuid = "ce943373-25bb-56aa-8eca-768745ed7b5a"
version = "6.7.1+1"

[[deps.Qt6Wayland_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6Declarative_jll"]
git-tree-sha1 = "729927532d48cf79f49070341e1d918a65aba6b0"
uuid = "e99dba38-086e-5de3-a5b1-6e4c66e897c3"
version = "6.7.1+1"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

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

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "95af145932c2ed859b63329952ce8d633719f091"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.3"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "b81c5035922cc89c2d9523afc6c54be512411466"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.5"

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

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "6cae795a5a9313bbb4f60683f7263318fc7d1505"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.10"

[[deps.URIs]]
git-tree-sha1 = "cbbebadbcc76c5ca1cc4b4f3b0614b3e603b5000"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "d62610ec45e4efeabf7032d67de2ffdea8344bed"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.22.1"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "975c354fcd5f7e1ddcc1f1a23e6e091d99e99bc8"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.4"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

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

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "b8b243e47228b4a3877f1dd6aee0c5d56db7fcf4"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.6+1"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "fee71455b0aaa3440dfdd54a9a36ccef829be7d4"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.8.1+0"

[[deps.Xorg_libICE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a3ea76ee3f4facd7a64684f9af25310825ee3668"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.1.2+0"

[[deps.Xorg_libSM_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libICE_jll"]
git-tree-sha1 = "9c7ad99c629a44f81e7799eb05ec2746abb5d588"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.6+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "b5899b25d17bf1889d25906fb9deed5da0c15b3b"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.12+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aa1261ebbac3ccc8d16558ae6799524c450ed16b"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.13+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "6c74ca84bbabc18c4547014765d194ff0b4dc9da"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.4+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "52858d64353db33a56e13c341d7bf44cd0d7b309"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.6+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "a4c0ee07ad36bf8bbce1c3bb52d21fb1e0b987fb"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.7+0"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "9caba99d38404b285db8801d5c45ef4f4f425a6d"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.1+0"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "a376af5c7ae60d29825164db40787f15c80c7c54"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.8.3+0"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll"]
git-tree-sha1 = "a5bc75478d323358a90dc36766f3c99ba7feb024"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.6+0"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "aff463c82a773cb86061bce8d53a0d976854923e"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.5+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "7ed9347888fac59a618302ee38216dd0379c480d"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.12+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXau_jll", "Xorg_libXdmcp_jll"]
git-tree-sha1 = "bfcaf7ec088eaba362093393fe11aa141fa15422"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.1+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "e3150c7400c41e207012b41659591f083f3ef795"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.3+0"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "04341cb870f29dcd5e39055f895c39d016e18ccd"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.4+0"

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
git-tree-sha1 = "801a858fc9fb90c11ffddee1801bb06a738bda9b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.7+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "00af7ebdc563c9217ecc67776d1bbf037dbcebf4"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.44.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a63799ff68005991f9d9491b6e95bd3478d783cb"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.6.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "446b23e73536f84e8037f5dce465e92275f6a308"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "gperf_jll"]
git-tree-sha1 = "431b678a28ebb559d224c0b6b6d01afce87c51ba"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.9+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6a34e0e0960190ac2a4363a1bd003504772d631"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.61.1+0"

[[deps.gperf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "3cad2cf2c8d80f1d17320652b3ea7778b30f473f"
uuid = "1a1c6b14-54f6-533d-8383-74cd7377aa70"
version = "3.3.0+0"

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

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "141fe65dc3efabb0b1d5ba74e91f6ad26f84cc22"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.11.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a22cf860a7d27e4f3498a0fe0811a7957badb38"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.3+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "ad50e5b90f222cfe78aa3d5183a20a12de1322ce"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.18.0+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "002748401f7b520273e2b506f61cab95d4701ccf"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.48+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "490376214c4721cdaca654041f635213c6165cb3"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+2"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "814e154bdb7be91d78b6802843f76b6ece642f11"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.6+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

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
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "c950ae0a3577aec97bfccf3381f66666bc416729"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.8.1+0"
"""

# ╔═╡ Cell order:
# ╟─01341648-0403-11eb-2212-db450c299f35
# ╟─03a85970-0403-11eb-334a-812b59c0905b
# ╠═095cbf46-0403-11eb-0c37-35de9562cebc
# ╟─06f30b2a-0403-11eb-0f05-8badebe1011d
# ╟─107e65a4-0403-11eb-0c14-37d8d828b469
# ╠═15187690-0403-11eb-2dfd-fd924faa3513
# ╠═d8797684-0414-11eb-1869-5b1e2c469011
# ╟─61789646-0403-11eb-0042-f3b8308f11ba
# ╠═26f84600-041d-11eb-1856-b12a3e5c1dc7
# ╟─271ec5f0-041d-11eb-041b-db46ec1465e0
# ╠═7f4e121c-041d-11eb-0dff-cd0cbfdfd606
# ╟─7f744644-041d-11eb-08a0-3719cc0adeb7
# ╠═88c53208-041d-11eb-3b1e-31b57ba99f05
# ╟─847d0fc2-041d-11eb-2864-79066e223b45
# ╠═f2792ff5-b0b6-4fcd-94aa-0b6ef048f6ab
# ╟─860790fc-0403-11eb-2f2e-355f77dcc7af
# ╠═ae4ac4b4-041f-11eb-14f5-1bcde35d18f2
# ╟─ae70625a-041f-11eb-3082-0753419d6d57
# ╠═60a8b708-04c8-11eb-37b1-3daec644ac90
# ╟─189cae1e-0424-11eb-2666-65bf297d8bdd
# ╠═18d308c4-0424-11eb-176d-49feec6889cf
# ╟─190deebc-0424-11eb-19fe-615997093e14
# ╠═82f2580a-04c8-11eb-1eea-bdb4e50eee3b
# ╟─8631a536-0403-11eb-0379-bb2e56927727
# ╠═98beb336-0425-11eb-3886-4f8cfd210288
# ╟─7c515a7a-04d5-11eb-0f36-4fcebff709d5
# ╟─866299e8-0403-11eb-085d-2b93459cc141
# ╠═9a837b52-0425-11eb-231f-a74405ff6e23
# ╠═a8dd5cae-0425-11eb-119c-bfcbf832d695
# ╠═46977c5a-e176-45f6-87bb-23bc964d25e6
# ╟─c4a8694a-04d4-11eb-1eef-c9e037e6b21f
# ╟─8692bf42-0403-11eb-191f-b7d08895274f
# ╠═7946d83a-04a0-11eb-224b-2b315e87bc84
# ╠═488771e2-049f-11eb-3b0a-0de260457731
# ╟─393041ec-049f-11eb-3089-2faf378445f3
# ╟─86d98d0a-0403-11eb-215b-c58ad721a90b
# ╠═223933a4-042c-11eb-10d3-852229f25a35
# ╠═1a654bdc-0421-11eb-2c38-7d35060e2565
# ╟─2d3bba2a-04a8-11eb-2c40-87794b6aeeac
# ╠═9d0f9564-e393-401f-9dd5-affa4405a9c6
# ╟─b21475c6-04ac-11eb-1366-f3b5e967402d
# ╠═9c39974c-04a5-11eb-184d-317eb542452c
# ╟─759bc42e-04ab-11eb-0ab1-b12e008c02a9
# ╟─1491a078-04aa-11eb-0106-19a3cf1e94b0
# ╟─f8e05d94-04ac-11eb-26d4-6f1d2c5ed272
# ╟─619c8a10-0403-11eb-2e89-8b0974fb01d0
# ╠═2ade2694-0425-11eb-2fb2-390da43d9695
# ╟─955321de-0403-11eb-04ce-fb1670dfbb9e
# ╠═46133a74-04b1-11eb-0b46-0bc74e564680
# ╟─95771ce2-0403-11eb-3056-f1dc3a8b7ec3
# ╠═887d27fc-04bc-11eb-0ab9-eb95ef9607f8
# ╠═b92f1cec-04ae-11eb-0072-3535d1118494
# ╠═2c62b4ae-04b3-11eb-0080-a1035a7e31a2
# ╟─28db9d98-04ca-11eb-3606-9fb89fa62f36
# ╠═c5156c72-04af-11eb-1106-b13969b036ca
# ╟─bf6fd176-04cc-11eb-008a-2fb6ff70a9cb
# ╠═38b1aa5a-04cf-11eb-11a2-930741fc9076
# ╠═80c2cd88-04b1-11eb-326e-0120a39405ea
# ╟─80e6f1e0-04b1-11eb-0d4e-475f1d80c2bb
# ╠═9cd2bb00-04b1-11eb-1d83-a703907141a7
# ╟─9cf9080a-04b1-11eb-12a0-17013f2d37f5
# ╟─95c598d4-0403-11eb-2328-0175ed564915
# ╠═843fd63c-04d0-11eb-0113-c58d346179d6
# ╠═7f635722-04d0-11eb-3209-4b603c9e843c
# ╠═a4c9ccdc-12ca-11eb-072f-e34595520548
# ╟─dfb99ace-04cf-11eb-0739-7d694c837d59
# ╟─1c6aa208-04d1-11eb-0b87-cf429e6ff6d0
# ╟─95eb9f88-0403-11eb-155b-7b2d3a07cff0
# ╠═287ee7aa-0435-11eb-0ca3-951dbbe69404
# ╟─9611ca24-0403-11eb-3582-b7e3bb243e62
# ╠═26e2978e-0435-11eb-0d61-25f552d2771e
# ╟─61c00724-0403-11eb-228d-17c11670e5d1
# ╠═8dd97820-04a5-11eb-36c0-8f92d4b859a8
# ╟─99ef7b2a-0403-11eb-08ef-e1023cd151ae
# ╠═bbb103d5-c8f9-485b-9337-40892bb60506
# ╟─9a13b17c-0403-11eb-024f-9b37e95e211b
# ╠═1ac4b33a-0435-11eb-36f8-8f3f81ae7844
# ╟─9a377b32-0403-11eb-2799-e7e59caa6a45
# ╠═21c50840-0435-11eb-1307-7138ecde0691
# ╟─cdd25106-e4b3-44d8-a4a0-d1e7dd1f6db9
# ╟─5689841e-0414-11eb-0492-63c77ddbd136
# ╟─531d13c2-0414-11eb-0acd-4905a684869d
# ╟─4f19e872-0414-11eb-0dfd-e53d2aecc4dc
# ╟─48a16c42-0414-11eb-0e0c-bf52bbb0f618
# ╟─461586dc-0414-11eb-00f3-4984b57bfac5
# ╟─43e6e856-0414-11eb-19ca-07358aa8b667
# ╟─41cefa68-0414-11eb-3bad-6530360d6f68
# ╟─3f5e0af8-0414-11eb-34a7-a71e7aaf6443
# ╟─3d88c056-0414-11eb-0025-05d3aff1588b
# ╟─3c0528a0-0414-11eb-2f68-a5657ab9e73d
# ╟─39dffa3c-0414-11eb-0197-e72b299e9c63
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
