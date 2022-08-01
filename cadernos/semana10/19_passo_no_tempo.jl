### A Pluto.jl notebook ###
# v0.16.4

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

# ╔═╡ 9a0cec14-08db-11eb-3cfa-4d1c327c63f1
using Plots, PlutoUI, StatsBase, Statistics


# ╔═╡ a8f82885-826d-4aac-90cb-8e7009d4136a
md"Tradução livre de [time_stepping.jl](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week10/time_stepping.jl)"

# ╔═╡ fb6cdc08-8b44-11eb-09f5-43c167aa53fd
PlutoUI.TableOfContents(title="Índice", aside=true)

# ╔═╡ 6f871ac0-716d-4bf8-a067-c798869c103f
md"""
# Modelando falhas de componentes: discreto e contínuo
"""

# ╔═╡ ae243395-521b-4834-b61e-19501e54b41c
md"""
Vamos retomar o nosso modelo simples de falhas de lâmpadas que derivamos a partir do modelo estocástico baseado em lâmpadas individuais. 

Inicialmente os componentes podiam falhar a qualquer momento, mas começamos verificando a condição deles ao final de cada dia e contar o número de falhas que ocorreram naquele dia. Depois começamos a verificar o que ocorria se diminuíssemos a janela de observação e verificássemos as falhas várias vezes ao dia. Esse ainda era um modelo **discreto**. Finalmente deduzimos como seria o modelo **contínuo** que aceita que a falha pode ocorrer em qualquer instante $t$.
"""

# ╔═╡ 8d2858a4-8c38-11eb-0b3b-61a913eed928
md"""
## Verificando as falhas diariamente (passos de tempos inteiros)
"""

# ╔═╡ e93c5f2f-d7c8-41ea-bdbb-7cf6587b6266
md"""
Vamos denominar $N_k$ o número (médio) de lâmpadas que ainda estão funcionando no início do dia $k$, a partir de um número inicial $N_0$.

Nós podemos encontrar a equação para o número $N_{k + 1}$, de lâmpadas que ainda funcionam no início do dia seguinte, estimando quantas lâmpadas devem falhar em um dado dia. Para isso, vamos denotar por $p$ a probabilidade de que cada bulbo, individualmente, falhe em um dia. Por exemplo, se 10% das lâmpadas falham por dia, $p = 0.1$. 

Se inicialmente havia 100 bulbos e 10% falham por dia, ao final do primeiro dia esperamos que falhem 10. Logo, 90 continuarão funcionando. Generalizando, se há $N_k$ lambdas funcionando no início de dia, esperamos que ao final haja $p N_k$ falhas. Desse modo,
$$N_{k+1} = N_k - p \, N_k$$

ou

$$N_{k+1} - N_k = - p N_k.$$

Esse é um modelo muito simples cuja recorrência conseguimos resolver (déjà vu). A expressão do número de lâmpadas ainda funcionando no início do dia $k + 1$:

$$N_{k+1} = (1 - p) N_k.$$

Deste modo,

$$N_k = (1 - p) N_{k-1} = (1 - p)^2 N_{k-2} = \cdots$$

E assim,

$$N_k = N_0 \, (1 - p)^k.$$
"""

# ╔═╡ 43f5ac88-7d07-429c-b27f-49908c30bdf9
md"""
## Verificando falhas $n$ vezes por dia
"""

# ╔═╡ b70465ab-9c7c-4533-9539-b414ef54a892
md"""
Agora suponha que estamos interessados em descobrir o número de bulbos que falham em _metade_ de um dia. Se a taxa de falhas é de 10% ao dia, parece natural pensar que o número de falhas em meio dia é de 5%. 

Entretanto, isso não está completamente correto, pois essa simplificação não considera o efeito de composição (como em juros compostos). Se 5% falham e das _lâmpadas restantes_ mais 5% falham, ao final temos
"""

# ╔═╡ 80c1a728-1784-4bb7-b2c3-e77b41929a78
(1 - 0.05) * (1 - 0.05)

# ╔═╡ a25cb8e6-f65d-4061-b90c-079814458c94
md"""
Portanto, _menos_ de 10% do total falharam, graças ao efeito de composição. De qualquer forma o resultado é suficiente bom, vamos continuar com essa aproximação.
"""

# ╔═╡ 4cc483e5-c322-44c8-83f1-802b6cb432aa
md"""
Agora vamos passar a subdividir em $n$ trechos. O mesmo raciocínio sugere que cerca de $p / n$ falham em cada um desses intervalos de tempo.

Portanto, o número de lâmpadas funcionando após a primeira verificação de falha é:
"""

# ╔═╡ 3ce501b4-76bc-49ab-b3b8-a41f29dbcc2b
md"""
$$N_{k + \frac{1}{n}} = \textstyle (1 - \frac{p}{n}) N_k$$

Aqui usamos um subscrito para enfatizar o fato que ainda estamos pensando de forma discreta. Se fosse em tempo contínuo seria, talvez, mas mais natural usar uma notação funcional:
Here we have used a subscript since we are in a discrete situation. We could also have written instead

$$N(k + \textstyle \frac{1}{n}).$$

Lembram dessa discussão? 

E após n medições chegamos ao valor de lâmpadas restantes no início do dia seguinte:
$$N_{k+1} = N_k \, (1 - \textstyle \frac{p}{n})^n.$$

Já a solução fechada que parte do valor inicial e considera $k$ dias é

$$N_k = N_0 \, \textstyle (1 - \frac{p}{n})^{nk}$$
"""

# ╔═╡ c539e622-d76d-489a-abb9-4ba47dfe9b90
md"""
Vamos graficar esses resultados para ver o que está ocorrendo.
"""

# ╔═╡ 95fe38c5-d717-47d0-8db7-5f8d53a6c6f1
md"""
n = $(n_slider = @bind n Slider(0:8, show_value=true))
"""

# ╔═╡ 2982c418-dad5-44cc-8194-5b607af84b16
p = 0.4

# ╔═╡ c97964d1-b5d2-4ee7-80cc-995b3f344aa1
let
	N0 = 100
	T = 20
	
	N = [N0 * (1 - p)^t for t in 0:T]
	
	plot(0:T, N, m=:o, alpha=0.5, ms=3, label="once daily", lw=2)
		
	N = [N0 * (1 - p/(2^n))^(t) for t in 0:(2^n)*T]
	plot!(0:(2.0^(-n)):T, N, m=:o, alpha=0.5, ms=2, label="$(2^n) times per day")
	
	xlabel!("days (k)")
	ylabel!("N_k")
	
	title!("$(2^n) times per day")
end

# ╔═╡ ba121b40-2bfc-42d4-81ee-5f90e18ec8de
md"""
## Tempo contínuo
"""

# ╔═╡ 74892ec6-6639-469d-8711-5039a140d833
md"""
Lembrando da aula sobre "o contínuo e o discreto", vemos estamos gerando mais e mais valores discretos intermediários. Já a curva gerada por esses valores quase não muda a partir de um certo ponto. Esse é um caso onde é razoável definir um objeto para representar o comportamento **limite**: o que ocorre se tomarmos passos cada vez menores de tempo (ou subdividirmos o dia em cada vez mais intervalos). Ou seja, queremos tomar o limite quando $n \to \infty$. 

Nesse caso, será possível calcular o número $N(t)$ que representa a média do número de bulbos que ainda estão funcionando no instante $t$, em que $t$ pode ser _any_ valor real positivo.
"""

# ╔═╡ fc6899d3-ea18-487a-add1-20be86ce9c74
md"""
Em cálculos aprendemos que
"""

# ╔═╡ 75a60bcf-3f77-49fb-a7ee-db4580aae6f3
md"""
$(1 - p/n)^n$ converges to $\exp(-p)$ as $n \to \infty$.
"""

# ╔═╡ 786beb46-d175-44b3-a63e-057150e53c66
md"""
Uma abordagem alternativa é olhar a evolução temporal em função de _diferenças_. Num intervalo de tempo de duração $1 / n$ uma proporção de $p / n$ falham. Nesse caso estamos pensando em $\delta t = 1 / n$ como o **intervalo de tempo** (ou **passo de tempo**) entre duas verificações consecutivas. Se houver $N(t)$ lâmpadas funcionando no tempo $t$ e o passo no tempo for pequeno, de comprimento $\delta t$, uma proporção $p \, \delta t$ deve queimar. Desse modo,
"""

# ╔═╡ 2d9f3aad-1d41-4918-a128-47dc58b667e3
md"""
$N(t + \delta t) - N(t) = -(p \, \delta t) \, N(t).$
"""

# ╔═╡ 17a23094-3975-49f4-8c7f-03fbc8afbbf2
md"""
Dividindo por $\delta t$ obtemos
"""

# ╔═╡ eaf6f4eb-b367-492e-a1be-81f9455252c4
md"""
$$\frac{N(t + \delta t) - N(t)}{\delta t} = -p \, N(t).$$
"""

# ╔═╡ 51c226b9-ab3d-46b4-a963-3548ad715d85
md"""
Podemos agora reconhecer o lado esquerdo da equação: ao tomarmos o limite, para $\delta t \to 0$, o que temos é exatamente a definição da **derivada** $\frac{dN(t)}{dt}$.

Portanto, tomando o limite obtemos
"""

# ╔═╡ 6c527098-ab53-4862-bda6-0c11b1564a11
md"""
$$\frac{dN(t)}{dt} = - p \, N(t)$$

com $N(0) = N_0$, o valor inicial. 

Essa é uma **equação diferencial ordinária**: uma equação que relaciona o valor da função $N(t)$ no instante $t$ com a derivada (inclinação) dessa função no mesmo instante. Essa relação deve valer para todo $t$. Se você nunca fez um curso de equações diferenciais, não é óbvio que esse tipo de equação faz sentido (apesar que a nossa derivação sugere que pelo menos esse caso particular seja razoável). Mas num curso de equações diferenciais vemos que equações desse tipo são razoáveis (sob certas condições técnicas) e definem completamente a função ao considerarmos a condição inicial. Essas equações são conhecidas como _equações diferenciais ordinárias (EDO) a valores iniciais_.
"""

# ╔═╡ 3c2b2f03-522c-40a0-ac1d-8054fe8e3fa2
md"""
Nesse caso particular, mais uma vez temos sorte e conseguimos encontrar a sua solução como uma fórmula analítica fechada: $N(t)$ é a função cuja derivada é um múltiplo da própria função, ou seja ele é uma exponencial:
"""

# ╔═╡ 5cec433e-ee71-44b5-b5d6-3feab80fa535
md"""
$N(t) = N_0 \exp(-p \, t)$
"""

# ╔═╡ 96b02ce7-ce16-4276-a147-ba94d7a2e160
md"""
Essa é uma forma alternativa de definir a função exponencial. Podemos adicioná-la na figura acima e ver o seu comportamento.
"""

# ╔═╡ d952db33-1f82-42f5-96af-8038c256715b
n_slider

# ╔═╡ 2b9276dc-fcca-4469-a62c-028a9eb3c2a9
let
	N0 = 100
	T = 20
	
	N = [N0 * (1 - p)^t for t in 0:T]
	
	plot(0:T, N, m=:o, alpha=0.5, ms=3, label="once daily", lw=2)
	
	N = [N0 * (1 - p/(2^n))^(t) for t in 0:(2^n)*T]
	plot!(0:(2.0^(-n)):T, N, m=:o, alpha=0.5, ms=2, label="$(2^n) times per day")
	
	xlabel!("days (k)")
	ylabel!("N_k")
	
	title!("$(2^n) times per day")
		
	plot!(t -> N0 * exp(-p * t), label="continuous", lw=2)
end

# ╔═╡ 754fe8c1-7021-48e8-9523-d5b22d0af93f
md"""
Vemos graficamente que de fato as curvas discretas têm como limite a curva contínua da exponencial. 
"""

# ╔═╡ ccb35ad7-db20-46fa-abff-a6e88ef999e0
md"""
Nesse contexto, $p$ é uma **taxa** (de variação). Ele é uma _probabilidade por unidade de tempo_, ou seja a razão entre probabilidade e tempo. Para recuperar a probabilidade de falha em um intervalo  $\delta t$, nós tivemos que *multiplicar* $p$ por $\delta t$.)
"""

# ╔═╡ d03d9bfc-20ea-49bc-bc7b-df22cc240ffe
md"""
Vamos resumir o que encontramos:
"""

# ╔═╡ dde3ffc7-b333-4305-b8e7-9888e4512c41
md"""
| Step type   | Time stepping     |  Difference    |   Solution  |
| ----------- | :-----------: | :-----------:  | :-----------: |
| Integer            | $N_{k+1} = (1 - p) N_k$  |  $N_{k+1} - N_k = -p N_k$  | $N_k = N_0 (1 - p)^k$
| Rational |  $N_{k + \frac{1}{n}} = \textstyle (1 - \frac{p}{n}) N_k$ | $N_{k + \frac{1}{n}} - N_k = \textstyle (- \frac{p}{n}) N_k$   | $N_k = N_0 (1 - \frac{p}{n})^{n k}$ 
| Continuous   | $N(t + \delta t) = (1 - p \, \delta t) N(t)$         |  $\frac{dN(t)}{dt} = - p \, N(t)$  |  $N(t) = N_0 \exp(-p \, t)$

"""

# ╔═╡ d74bace6-08f4-11eb-2a6b-891e52952f57
md"""
# Modelo SIR
"""

# ╔═╡ 76268535-e232-4e02-97cd-cf9b3ddec256
md"""
Agora vamos analisar um exempolo mais complicado, o modelo **SIR** de propagação de um epidemia, ou de um rumor, em uma população. Você certamente já viu que esse modelo foi usado muito para analisar a evolução da Covid-19.

Como na lista, podemos fazer um modelo estocástico discreto baseado em agentes. Nele definimos regras (microscópicas) que dizem como agentes individuais interagem. Quando simulamos esses modelos em sistemas suficientemente grandes, observamos que os resultados são bastante suaves. Uma alternativa é tentar escrever as equações discretas (macroscópicas) que governam o comportamento médio.

Muitas vezes é mais fácil entender sistemas em sua formulação contínua. Algumas pessoas preferem se manter no nível discreto porque eles são mais fieis ao fenômeno subjacente. Mas modelos contínuos muitas vezes capturam a informação mais importante e são mais simples de trabalhar. Além de serem, muitas vezes, computacionalmente mais eficientes. 
"""

# ╔═╡ 11e24e1d-39db-4b7e-96db-50458def72af
md"""
## Modelo SIR com tempos discretos
"""

# ╔═╡ dbdf2812-08f4-11eb-25e7-811522b24627
md"""
Vamos começar com o caso SI: agentes pode ser suscetíveis (S) ou infecciosos
(I). Uma pessoa sucetível pode se tornar infecciosa quando entra em contato com outra pessoa infecciosa, com alguma probabilidade.
"""

# ╔═╡ 238f0716-0903-11eb-1595-df71600f5de7
md"""
Vamos chamar $S_t$ e $I_t$ o número de indivíduos suscetíveis e infecciosos no intante $t$, respectivamente. Já $N$ será o número total de pessoas.

Vamos supor, que a cada passo de tempo, cada pessoa infecciosa tem a mesma chance de iteragir as outras pessoas (em média). A pessoa será escolhida aleatoriamente da população total de tamanho $N$. Uma nova infecção iera ocorrer apenas se a pessoa escolhida é suscetível, o que ocorre com probabilidade $S_t / N$ _e_ apenas se a oportunidade de infeccção for bem sucedida, digamos com probabilidade $b$.

Dessa forma a mudança que ocorrerá nesse passo tempo (em média) será 
"""

# ╔═╡ 8e771c8a-0903-11eb-1e34-39de4f45412b
md"""
$$\Delta I_t = I_{t+1} - I_t = b \, I_t \, \left(\frac{S_t}{N} \right)$$
"""

# ╔═╡ fb52c62d-15d3-46a2-8e3d-2de20c68ded4
md"""
Já o crescimento em $S_t$ será o mesmo, $\Delta I_t$.
"""

# ╔═╡ e83fc5b8-0904-11eb-096b-8da3a1acba12
md"""
Há ainda o caso da recuperação, que ocorre com probabilidade constante $c$ a cada passo do tempo, uma vez que o indivíduo está infectado.

É útil normalizar as quantidades por $N$, dessa forma definimos proporções da população que são sucetíveis, infecciosos e recuperados, por
$$s_t := \frac{S_t}{N}; \quad i_t := \frac{I_t}{N}; \quad r_t := \frac{R_t}{N}.$$
"""

# ╔═╡ d1fbea7a-0904-11eb-377d-690d7a16aa7b
md"""
Incluindo a recuperação com probailidade $c$ obtemos o modelo **SIR em tempo discreto**:
"""

# ╔═╡ dba896a4-0904-11eb-3c47-cbbf6c01e830
md"""
$$\begin{align}
s_{t+1} &= s_t - b \, s_t \, i_t \\
i_{t+1} &= i_t + b \, s_t \, i_t - c \, i_t\\
r_{t+1} &= r_t + c \, i_t
\end{align}$$
"""

# ╔═╡ cea2dcfb-b1eb-4269-81d7-8596969e9bd6
md"""
## Modelo SIR em tempo contínuo
"""

# ╔═╡ 08d166f1-3af0-45a8-bcad-6ee958497453
md"""
Agora estamos prontos para passar pelo mesmo processo que no modelo de falhas. Consideremos que os intervalos de tempo são encurtados para $\delta t$, e substituímos a probabilidades $b$ e $c$ com *taxas* $\beta$ e $\gamma$. Tomando o limite para $\delta t \to 0$ obtemos
"""

# ╔═╡ 72061c66-090d-11eb-14c0-df619958e2b6
md"""
$$\begin{align}
\frac{ds(t)}{dt} &= -\beta \, s(t) \, i(t) \\
\frac{di(t)}{dt} &= +\beta \, s(t) \, i(t) &- \gamma \, i(t)\\
\frac{dr(t)}{dt} &= &+ \gamma \, i(t)
\end{align}$$
"""

# ╔═╡ c07367be-0987-11eb-0680-0bebd894e1be
md"""
Esse modelo pode ser entendido como uma reação química com espécies S, I e R. Veja [**Lei de ação das massas**](https://en.wikipedia.org/wiki/Law_of_mass_action).

Note que não há solução analítica para essa (simples) EDO não linear como função do tempo. Mas há [soluções paramétricas](https://arxiv.org/abs/1403.2160).
"""

# ╔═╡ f8a28ba0-0915-11eb-12d1-336f291e1d84
md"""
Vejamos uma simulação do sistema a tempo-discreto.
"""

# ╔═╡ d994e972-090d-11eb-1b77-6d5ddb5daeab
begin
	NN = 100
	
	SS = NN - 1
	II = 1
	RR = 0
end

# ╔═╡ 050bffbc-0915-11eb-2925-ad11b3f67030
ss, ii, rr = SS/NN, II/NN, RR/NN

# ╔═╡ 1d0baf98-0915-11eb-2f1e-8176d14c06ad
p_infection, p_recovery = 0.1, 0.01

# ╔═╡ 349eb1b6-0915-11eb-36e3-1b9459c38a95
function discrete_SIR(s0, i0, r0, T=1000)

	s, i, r = s0, i0, r0
	
	results = [(s=s, i=i, r=r)]
	
	for t in 1:T

		Δi = p_infection * s * i
		Δr = p_recovery * i
		
		s_new = s - Δi
		i_new = i + Δi - Δr
		r_new = r      + Δr

		push!(results, (s=s_new, i=i_new, r=r_new))

		s, i, r = s_new, i_new, r_new
	end
	
	return results
end

# ╔═╡ 28e1ec24-0915-11eb-228c-4daf9abe189b
TT = 1000

# ╔═╡ 39c24ef0-0915-11eb-1a0e-c56f7dd01235
SIR = discrete_SIR(ss, ii, rr)

# ╔═╡ 442035a6-0915-11eb-21de-e11cf950f230
begin
	ts = 1:length(SIR)
	discrete_time_SIR_plot = plot(ts, [x.s for x in SIR], 
		m=:o, label="S", alpha=0.2, linecolor=:blue, leg=:right, size=(400, 300))
	plot!(ts, [x.i for x in SIR], m=:o, label="I", alpha=0.2)
	plot!(ts, [x.r for x in SIR], m=:o, label="R", alpha=0.2)
	
	xlims!(0, 500)
end

# ╔═╡ 5f5d7332-b5f8-4d05-971b-ec0564f1339b
md"""
# Passos no tempo: o método de Euler
"""

# ╔═╡ 7cf51986-5983-4094-a18f-f95f2f6993da
md"""
Vimos acima que podemos derivar equações diferenciais ordinárias como limites de modelos a tempo discreto no qual tomamos passos (curtos) no tempo.

Mas se já partimos de uma EDO, como resolvê-la numericamente? Para isso você fez o curso de cálculo numérico, não é mesmo?

Lá você viu que podemos fazer o "caminho contrário": **discretizar** a equação e reduzí-la a um sistema onde tomamos passos discretos no tempo.

Considere que a equação diferencial é

$$\dot{x} = f(x)$$

O método mais simples dessa classe é o **método de Euler**. Nele aproximamos a derivada usando passos de tempo pequeno $h$ (que acima nós denotamos por  $\delta t$):

$$\dot{x} \simeq \frac{x(t + h) - x(t)}{h}.$$

Substituindo de volta na EDO isso resulta em

$$x(t + \delta t) \simeq x(t) + h \, f(x).$$ 

O método de Euler, como passo de tempo constante, é descrito pela iteração

$$x_{k+1} = x_k + h \, f(x_k)$$

Se a EDO possui várias variáveis, podemos agrupá-las em um vetor e usar o _mesmo_ métodos, só que no caso vetorial. Ou seja, dada uma EDO vetorial

$$\dot{\mathbf{x}} = \mathbf{f}(\mathbf{x})$$

o método de Euler é

$$\mathbf{x}_{k+1} = \mathbf{x}_k + h \, \mathbf{f}(\mathbf{x}_k),$$

em que $\mathbf{f}$ representa a função que mapeia o vetor de variáveis no vetor que representa o lado direito da EDO.
"""

# ╔═╡ 763bbb15-c52e-4159-99b7-f3d17f47d56a
md"""
Entretanto, em geral, o método de Euler _não_ é um bom algoritmos para simular a dinâmica de uma equação diferencial. Nós podemos ver isso ao olhar os gráficos no íncio do nosso caderno: passos discretos constantes não conseguem recuperar uma boa aproximação da curva contínua. Esse é o domínio da análise numérica: o estudo de como obter boas aproximações da solução real de uma EDO de forma mais precisa e eficiente.

Julia possui um rico ecosistema de pacotes para resolver EDOs e outros tipos de equações diferenciais usando métodos do estado-da-arte  [SciML / DifferentialEquations.jl](https://diffeq.sciml.ai/stable/tutorials/ode_example/).
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
Plots = "~1.22.6"
PlutoUI = "~0.7.16"
StatsBase = "~0.33.12"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f2202b55d816427cd385a9a4f3ffb226bee80f99"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+0"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "d9e40e3e370ee56c5b57e0db651d8f92bce98fea"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.10.1"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

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
git-tree-sha1 = "31d0151f5716b655421d9d75b7fa74cc4e744df2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.39.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

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

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "dba1e8614e98949abfa60480b13653813d8f0157"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+0"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "d189c6d2004f63fd3c91748c458b09f26de0efaa"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.61.0"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "cafe0823979a5c9bff86224b3b8de29ea5a44b2e"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.61.0+0"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "7bf67e9a481712b3dbe9cb3dac852dc4b1162e02"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+0"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "14eece7a3308b4d8be910e265c724a6ba51a9798"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.16"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "8a954fed8ac097d5be04921d595f741115c1b2ad"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+0"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "f6532909bf3d40b308a0f360b6a0e626c0e263a8"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.1"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "f0c6489b12d28fb4c2103073ec7452f3423bd308"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.1"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

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

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "c7f1c695e06c01b95a67f0cd1d34994f3e7db104"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.2.1"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "669315d963863322302137c4591ffce3cb5b8e68"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.8"

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

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "761a393aeccd6aa92ec3515e428c26bf99575b3b"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+0"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "6193c3815f13ba1b78a51ce391db8be016ae9214"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.4"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "5a5bc6bf062f0f95e62d0fe0a2d99699fed82dd9"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.8"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7937eda4681660b4d6aeeecc2f7e1c81c8ee4e2f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+0"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "98f59ff3639b3d9485a03a72f3ab35bab9465720"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.6"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "b084324b4af5a438cd63619fd006614b3b20b87b"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.15"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs"]
git-tree-sha1 = "ba43b248a1f04a9667ca4a9f782321d9211aa68e"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.22.6"

[[PlutoUI]]
deps = ["Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "4c8a7d080daca18545c56f1cac28710c362478f3"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.16"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RecipesBase]]
git-tree-sha1 = "44a75aa7a527910ee3d1751d1f0e4148698add9e"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.2"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "7ad0dfa8d03b7bcf8c597f59f5292801730c55b8"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.4.1"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

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

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "eb35dcc66558b2dda84079b9a1be17557d32091a"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.12"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "fed34d0e71b91734bf0a7e10eb1bb05296ddbcd0"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll"]
git-tree-sha1 = "2839f1c1296940218e35df0bbb220f2a79686670"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.18.0+4"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "c45f4e40e7aafe9d086379e5578947ec8b95a8fb"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+0"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─a8f82885-826d-4aac-90cb-8e7009d4136a
# ╠═9a0cec14-08db-11eb-3cfa-4d1c327c63f1
# ╠═fb6cdc08-8b44-11eb-09f5-43c167aa53fd
# ╟─6f871ac0-716d-4bf8-a067-c798869c103f
# ╟─ae243395-521b-4834-b61e-19501e54b41c
# ╟─8d2858a4-8c38-11eb-0b3b-61a913eed928
# ╟─e93c5f2f-d7c8-41ea-bdbb-7cf6587b6266
# ╟─43f5ac88-7d07-429c-b27f-49908c30bdf9
# ╟─b70465ab-9c7c-4533-9539-b414ef54a892
# ╠═80c1a728-1784-4bb7-b2c3-e77b41929a78
# ╟─a25cb8e6-f65d-4061-b90c-079814458c94
# ╟─4cc483e5-c322-44c8-83f1-802b6cb432aa
# ╟─3ce501b4-76bc-49ab-b3b8-a41f29dbcc2b
# ╟─c539e622-d76d-489a-abb9-4ba47dfe9b90
# ╟─95fe38c5-d717-47d0-8db7-5f8d53a6c6f1
# ╠═2982c418-dad5-44cc-8194-5b607af84b16
# ╠═c97964d1-b5d2-4ee7-80cc-995b3f344aa1
# ╟─ba121b40-2bfc-42d4-81ee-5f90e18ec8de
# ╟─74892ec6-6639-469d-8711-5039a140d833
# ╟─fc6899d3-ea18-487a-add1-20be86ce9c74
# ╟─75a60bcf-3f77-49fb-a7ee-db4580aae6f3
# ╟─786beb46-d175-44b3-a63e-057150e53c66
# ╟─2d9f3aad-1d41-4918-a128-47dc58b667e3
# ╟─17a23094-3975-49f4-8c7f-03fbc8afbbf2
# ╟─eaf6f4eb-b367-492e-a1be-81f9455252c4
# ╟─51c226b9-ab3d-46b4-a963-3548ad715d85
# ╟─6c527098-ab53-4862-bda6-0c11b1564a11
# ╟─3c2b2f03-522c-40a0-ac1d-8054fe8e3fa2
# ╟─5cec433e-ee71-44b5-b5d6-3feab80fa535
# ╟─96b02ce7-ce16-4276-a147-ba94d7a2e160
# ╠═d952db33-1f82-42f5-96af-8038c256715b
# ╠═2b9276dc-fcca-4469-a62c-028a9eb3c2a9
# ╟─754fe8c1-7021-48e8-9523-d5b22d0af93f
# ╟─ccb35ad7-db20-46fa-abff-a6e88ef999e0
# ╟─d03d9bfc-20ea-49bc-bc7b-df22cc240ffe
# ╟─dde3ffc7-b333-4305-b8e7-9888e4512c41
# ╟─d74bace6-08f4-11eb-2a6b-891e52952f57
# ╟─76268535-e232-4e02-97cd-cf9b3ddec256
# ╟─11e24e1d-39db-4b7e-96db-50458def72af
# ╟─dbdf2812-08f4-11eb-25e7-811522b24627
# ╟─238f0716-0903-11eb-1595-df71600f5de7
# ╟─8e771c8a-0903-11eb-1e34-39de4f45412b
# ╟─fb52c62d-15d3-46a2-8e3d-2de20c68ded4
# ╟─e83fc5b8-0904-11eb-096b-8da3a1acba12
# ╟─d1fbea7a-0904-11eb-377d-690d7a16aa7b
# ╟─dba896a4-0904-11eb-3c47-cbbf6c01e830
# ╟─cea2dcfb-b1eb-4269-81d7-8596969e9bd6
# ╟─08d166f1-3af0-45a8-bcad-6ee958497453
# ╟─72061c66-090d-11eb-14c0-df619958e2b6
# ╟─c07367be-0987-11eb-0680-0bebd894e1be
# ╟─f8a28ba0-0915-11eb-12d1-336f291e1d84
# ╠═349eb1b6-0915-11eb-36e3-1b9459c38a95
# ╠═d994e972-090d-11eb-1b77-6d5ddb5daeab
# ╠═050bffbc-0915-11eb-2925-ad11b3f67030
# ╠═1d0baf98-0915-11eb-2f1e-8176d14c06ad
# ╠═28e1ec24-0915-11eb-228c-4daf9abe189b
# ╠═39c24ef0-0915-11eb-1a0e-c56f7dd01235
# ╠═442035a6-0915-11eb-21de-e11cf950f230
# ╟─5f5d7332-b5f8-4d05-971b-ec0564f1339b
# ╟─7cf51986-5983-4094-a18f-f95f2f6993da
# ╟─763bbb15-c52e-4159-99b7-f3d17f47d56a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
