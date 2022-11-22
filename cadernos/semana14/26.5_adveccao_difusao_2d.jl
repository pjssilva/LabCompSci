### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try
            Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value
        catch
            b -> missing
        end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 3874b4b0-9e54-4668-8cc5-bd23b5e89993
begin
    using Statistics
    using Plots
    using PlutoUI
    # using Images
    using OffsetArrays
end

# ╔═╡ 8f4aa925-a163-4a4e-b49a-5e90439b5646
TableOfContents(; title="📚 Índice", aside=true)

# ╔═╡ 0f8db6f4-2113-11eb-18b4-21a469c67f3a
md"# EDPs em 2D: transporte de calor por correntes marítimas"

# ╔═╡ ed741ec6-1f75-11eb-03be-ad6284abaab8
html"""
<iframe width="700" height="394" src="https://www.youtube-nocookie.com/embed/6_GQuVopmUM?start=15" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
"""

# ╔═╡ 629a966a-c4cb-4f8e-9598-25ae2bd18297
md"## Relembrando a convecção e difusão 1D"

# ╔═╡ ac759b96-2114-11eb-24cb-d50b556f4142
md"""
## Convecção e difusão 1D

Vamos relembrar o modelo da última aula em que modelamos os fenômenos de **convecção e difusão** unidimensional

$\frac{\partial T(x,t)}{\partial t} = -U \frac{\partial T}{\partial x} + \kappa \frac{\partial^{2} T}{\partial x^{2}},$

em que $T(x, t)$ é a temperatura, $U$ é uma *velocidade advectiva* constante e  $\kappa$ é a *difusividade térmica*.

## Convecção-difusão bidimensional

O caso bidimensional adiciona operadores de advecção e difusão atuando também em uma *segunda dimensão espacial* $y$ que é perpendicular a $x$. O campo de temperaturas é agora uma função $T = T(x, y, t)$ e a EDP passar a ser:

$\frac{\partial T(x,y,t)}{\partial t} = u(x,y) \frac{\partial T}{\partial x} + v(x,y) \frac{\partial T}{\partial y} + \kappa \left( \frac{\partial^{2} T}{\partial x^{2}} + \frac{\partial^{2} T}{\partial y^{2}} \right),$

em que $\vec{u}(x,y) = (u, v) = u\,\mathbf{\hat{x}} + v\,\mathbf{\hat{y}}$ é um campo velocidade e cada derivada parcial é também função de $t$, $x$ e $y$.

No caso de modelos climáticos, podemos imaginar que $x$ é a *direção da longitude* (positiva de oeste para leste) e $y$ representa a *direção da latitude* (positiva de sul para norte).
"""

# ╔═╡ 3a4a1aea-2118-11eb-30a9-57b87f2ddfae
begin
    reviewBox = @bind show_review CheckBox(; default=false)
    md"""
    ##### Revisão de algumas identidades e notação de cálculo multivariado.

    *Selecione a caixa para acessar a revisão* $(reviewBox)
    """
end

# ╔═╡ 023779a0-2a95-11eb-35b5-7be93c43afaf
if show_review
    md"""
    A equação bidimensional de advecção e difusão é escrita de forma sucinta como 

    $$\frac{\partial T(x,y,t)}{\partial t} = - \vec{u} \cdot \nabla T + \kappa \nabla^{2} T,$$

    usando a notação compacta descrita abaixo.

    O operador **gradiente** é definido por

    $\nabla \equiv \left( \frac{\partial}{\partial x}, \frac{\partial }{\partial y} \right)$

    tal que

    $\nabla T = \left( \frac{\partial T}{\partial x}, \frac{\partial T}{\partial y} \right)$ e

    $\vec{u} \cdot \nabla T = (u, v) \cdot \left( \frac{\partial T}{\partial x}, \frac{\partial T}{\partial y} \right) = u \frac{\partial T}{\partial x} + v\frac{\partial T}{\partial y}.$

    O operador **Laplaciano** $\nabla^{2}$, por vezes denotado com $\Delta$, é definido como

    $\nabla^{2} = \frac{\partial^{2}}{\partial x^{2}} + \frac{\partial^{2}}{\partial y^{2}}$

    tal que

    $\nabla^{2} T = \frac{\partial^{2} T}{\partial x^{2}} + \frac{\partial^{2} T}{\partial y^{2}}.$

    O operador **divergência* é definido como $\nabla \cdot [\quad]$, tal que

    $\nabla \cdot \vec{u} = \left(\frac{\partial}{\partial x}, \frac{\partial}{\partial x} \right) \cdot (u,v) = \frac{\partial u}{\partial x} + \frac{\partial v}{\partial y}.$

    **Obs:** Como a água do mar é basicamente **incompressível**, temos que $\nabla \cdot \vec{u} = \frac{\partial u}{\partial x} + \frac{\partial v}{\partial y} = 0$. Ou seja, as correntes oceânicas são aproximadamente *fluxo não-divergentes*. Entre outras aplicações isso nos permite ver que:
    ```math
    \begin{align}
    \vec{u} \cdot \nabla T&=
    u\frac{\partial T(x,y,t)}{\partial x} + v\frac{\partial T(x,y,t)}{\partial y}\newline &=
    u\frac{\partial T}{\partial x} + v\frac{\partial T}{\partial y} + T\left(\frac{\partial u}{\partial x} + \frac{\partial v}{\partial y}\right)\newline &=
    \left( u\frac{\partial T}{\partial x} + T\frac{\partial u}{\partial x} \right) +
    \left( v\frac{\partial T}{\partial y} + T\frac{\partial v}{\partial y} \right)
    \newline &=
    \frac{\partial (uT)}{\partial x} + \frac{\partial (vT)}{\partial x}\newline &=
    \nabla \cdot (\vec{u}T)
    \end{align}
    ```

    usando a regra do produto (separadamente em ambos $x$ e $y$).

    #####  A equação de advecção-difusão e forma de fluxo dimensional

    Assim podemos, finalmente, reescrever a EDP como:

    $\frac{\partial T}{\partial t} = - \nabla \cdot (\vec{u}T) + \kappa \nabla^{2} T,$

    que é forma que vamos usar no algoritmo abaixo.
    """
end

# ╔═╡ b1b5625e-211a-11eb-3ee1-3ba9c9cc375a
md"""
## Solução numérica da equação bidimensional

Vamos apresentar uma solução numérica baseada em diferenças finitas, como fizemos antes. 

##### Discretizando a advecção em duas dimensões

Nas aulas anteriores vimos que podemos aproximar a derivada parcial usando *diferenças centradas*:

$\frac{\partial T(x_{i}, t_{n})}{\partial x} \approx \frac{T_{i+1}^{n} - T_{i-1}^{n}}{2 \Delta x}.$

Em duas dimensões, fazemos o mesmo. A única modificação é que temos agora  mais de uma derivada parcial para aproximar. Com isso surge mais um índice para denotar os nós. Usaremos $j$ para o índice associado à dimensão $y$. Obtemos:

$\frac{\partial T(x_{i}, y_{j}, t_{n})}{\partial x} \approx \frac{T_{i+1,\, j}^{n} - T_{i-1,\,j}^{n}}{2 \Delta x}.$

Vamos implementar isso usando as ideias de estênceis (ou filtros de convolução). Começamos definindo o *núcleo gradiente-x*, usando `OffsetArray`. A implementação está abaixo e, naturalmente, lembra a implementação dos núcleos de *detecção de bordas* e *nitidez* que vimos no início do curso.
"""

# ╔═╡ 3578b158-2a97-11eb-0771-bf6d82d3b6d1
md"""
Já a derivada parcial de primeira ordem em $y$ pode ser discretizada de forma análoga;

$\frac{\partial T(x_{i}, y_{j}, t_{n})}{\partial y} \approx \frac{T_{i,\, j+1}^{n} - T_{i,\,j-1}^{n}}{2 \Delta y}.$

O núcleo é apresentado abaixo.
"""

# ╔═╡ 7f3c9550-2a97-11eb-1549-455009025872
md"""
Agora que temos as duas derivadas discretizadas, podemos escrever o termo com a *tendência advectiva* (que representa o "movimento" de advecção) para calcular  $T_{i, j, n+1}$ como

$u\frac{\partial T}{\partial x} + v\frac{\partial T}{\partial y} \approx u_{i,\, j}^{n} \frac{T_{i,\, j+1}^{n} - T_{i,\,j-1}^{n}}{2 \Delta y} + v_{i,\, j}^{n} \frac{T_{i,\, j+1}^{n} - T_{i,\,j-1}^{n}}{2 \Delta y}.$

Vamos implementar isso em Julia como uma série de métodos da função `advect`. O primeiro método calcula a tendência advectiva de uma única célula $(i, j)$ da malha (como um único número `Float64`). O método seguinte aplica esse método a todos os pontos da malha retornando um array das tendências.

Obs: Note que não calculamos a tendência na fronteira. Falaremos disso em um momento específico mais abaixo.
"""

# ╔═╡ 0127bca6-2a99-11eb-16a0-8d7af66694f8
md"""
#####  Discretizando a difusão em duas dimensões

Agora fazemos o mesmo para o termo de advecção, aproximando os operadores de difusão por diferenças. Lembre que isso tem que ser feito para cada dimensão espacial $x$ e $y$.

$\kappa \left( \frac{\partial^{2} T}{\partial x^{2}} + \frac{\partial^{2} T}{\partial y^{2}} \right) \approx \kappa \left(
\frac{T_{i+1,\;j}^{n} - 2T_{i,\;j}^{n} + T_{i-1,\;j}^{n}}{\left( \Delta x \right)^{2}} +
\frac{T_{i,\;j+1}^{n} - 2T_{i,\;j}^{n} + T_{i,\;j-1}^{n}}{\left( \Delta y \right)^{2}}
\right)$

Os núcleos de derivada segunda em $x$ e $y$ são definidos abaixo.
"""

# ╔═╡ eac507ce-2a99-11eb-3eba-0780a4a7e078
md"""
Agora, seguindo o modelo da advecção, implementamos os métodos que calculam o termo completo da difusão.
"""

# ╔═╡ 09f179c0-2a9a-11eb-1d0f-e59012f9e77b
md"""##### Condições de fronteira sem fluxo

As fronteiras no nosso modelo vão representar "continentes" e não há fluxo do oceano para os continentes, então é natural impor condições que impeçam que ocorra esse fluxo. Ou seja, queremos que 

$u\frac{\partial T}{\partial x} = \kappa \frac{\partial^2 T}{\partial^2 x} = 0$ 

nas fronteiras horizontais. Já nas fronteiras verticais deve valer

$v\frac{\partial T}{\partial y} = \kappa \frac{\partial^2 T}{\partial^2 y} = 0$.

Para impor isso, vamos tratar de $i = 1$ and $i = N_{x}$ como *células fantasmas*, que tem como função apenas ajudar a impor essas condições de fronteira. Do ponto de vista discreto, os fluxos na fronteira entre $i = 1$ e $i = 2$ será nula se

$\dfrac{T_{2,\,j}^{n} -T_{1,\,j}^{n}}{\Delta x} = 0$ 

ou, simplificando,

$T_{1,\,j}^{n} = T_{2,\,j}^{n}.$

Assim, podemos implementar essas condições de fronteira atualizando a temperaturas das células fantasmas para coincidirem com os valores de seus vizinhos interiores.
"""

# ╔═╡ 7caca2fa-2a9a-11eb-373f-156a459a1637
function update_ghostcells!(A::Array{Float64,2}; option="no-flux")
    if option == "no-flux"
        A[1, :] .= A[2, :]
        A[end, :] .= A[end-1, :]
        A[:, 1] .= A[:, 2]
        A[:, end] .= A[:, end-1]
    end
end

# ╔═╡ 1f06bc34-2a9b-11eb-1030-ff12d103176c
md"Vejamos isso em ação:"

# ╔═╡ 2ef2f0cc-2a9b-11eb-03c6-5d8b4c6ae822
as_svg(begin
    A = rand(Float64, 6, 6)
    heatmap(A; size=(200, 200))
end)

# ╔═╡ 4558d4f8-2a9b-11eb-1f56-416975bcd180
as_svg(begin
    Acopy = copy(A)
    update_ghostcells!(Acopy)
    heatmap(Acopy; size=(200, 200))
end)

# ╔═╡ 74aa7512-2a9c-11eb-118c-c7a5b60eac1b
md"""
#####  Passos no tempo
"""

# ╔═╡ 13eb3966-2a9a-11eb-086c-05510a3f5b80
md"""
##### Estruturas de dados
"""

# ╔═╡ cd2ee4ca-2a06-11eb-0e61-e9a2ecf72bd6
struct Grid
    N::Int64
    L::Float64

    Δx::Float64
    Δy::Float64

    x::Array{Float64,2}
    y::Array{Float64,2}

    Nx::Int64
    Ny::Int64

    function Grid(N, L)
        Δx = L / N # [m]
        Δy = L / N # [m]

        x = (0.0-Δx/2.0):Δx:(L+Δx/2.0)
        x = reshape(x, (1, size(x, 1)))
        y = (-L-Δy/2.0):Δy:(L+Δy/2.0)
        y = reshape(y, (size(y, 1), 1))

        Nx, Ny = size(x, 2), size(y, 1)

        return new(N, L, Δx, Δy, x, y, Nx, Ny)
    end
end

# ╔═╡ 2a93145e-2a09-11eb-323b-01817062aa89
struct Parameters
    κ::Float64
end

# ╔═╡ 32663184-2a81-11eb-0dd1-dd1e10ed9ec6
abstract type ClimateModel end

# ╔═╡ f92086c4-2a74-11eb-3c72-a1096667183b
begin
    mutable struct ClimateModelSimulation{ModelType<:ClimateModel}
        model::ModelType

        T::Array{Float64,2}
        Δt::Float64

        iteration::Int64
    end

    function ClimateModelSimulation(C::ModelType, T, Δt) where {ModelType}
        return ClimateModelSimulation{ModelType}(C, T, Δt, 0)
    end
end

# ╔═╡ 31cb0c2c-2a9a-11eb-10ba-d90a00d8e03a
md"""
## Simulando o transporte de calor por correntes oceânicas advectivas e difusão
"""

# ╔═╡ 981ef38a-2a8b-11eb-08be-b94be2924366
md"**Controles da simulação**"

# ╔═╡ d042d25a-2a62-11eb-33fe-65494bb2fad5
begin
    quiverBox = @bind show_quiver CheckBox(; default=false)
    anomalyBox = @bind show_anomaly CheckBox(; default=false)
    md"""
    *Selecione para mostrar o campo velocidade* $(quiverBox) *ou para mostrar **anomalias** de temperatura ao invés de valores absolutos* $(anomalyBox)
    """
end

# ╔═╡ c20b0e00-2a8a-11eb-045d-9db88411746f
begin
    U_ex_Slider = @bind U_ex Slider(-4:1:8; default=0, show_value=false)
    md"""
    $(U_ex_Slider)
    """
end

# ╔═╡ 6dbc3d34-2a89-11eb-2c80-75459a8e237a
begin
    md"*Varia a velocidade da corrente U:*  $(2. ^U_ex) [× referência]"
end

# ╔═╡ 933d42fa-2a67-11eb-07de-61cab7567d7d
begin
    κ_ex_Slider = @bind κ_ex Slider(0.0:1.e3:1.e5; default=1.e4, show_value=true)
    md"""
    *Varia a difusidade κ:* $(κ_ex_Slider) [m²/s]
    """
end

# ╔═╡ c9ea0f72-2a67-11eb-20ba-376ca9c8014f
@bind go_ex Clock(0.1)

# ╔═╡ c3f086f4-2a9a-11eb-0978-27532cbecebf
md"""
**Alguns tested de unidade para verificação**
"""

# ╔═╡ ad7b7ed6-2a9c-11eb-06b7-0f5595167575
function CFL_adv(sim::ClimateModelSimulation)
    return maximum(sqrt.(sim.model.u .^ 2 + sim.model.v .^ 2)) * sim.Δt / sim.model.G.Δx
end

# ╔═╡ a04d3dee-2a9c-11eb-040e-7bd2facb2eaa
md"""
# Apêndice
"""

# ╔═╡ 16905a6a-2a78-11eb-19ea-81adddc21088
Nvec = 1:25

# ╔═╡ c0e46442-27fb-11eb-2c94-15edbda3f84d
function plot_state(
    sim::ClimateModelSimulation;
    clims=(-1.1, 1.1),
    show_quiver=true,
    show_anomaly=false,
    IC=nothing
)
    model = sim.model
    grid = sim.model.G

    p = plot(;
        xlabel="longitudinal distance [km]",
        ylabel="latitudinal distance [km]",
        clabel="Temperature",
        yticks=(((-grid.L):1000e3:(grid.L)), Int64.(1e-3 * ((-grid.L):1000e3:(grid.L)))),
        xticks=((0:1000e3:(grid.L)), Int64.(1e-3 * (0:1000e3:(grid.L)))),
        xlims=(0.0, grid.L),
        ylims=(-grid.L, grid.L)
    )

    X = repeat(grid.x, grid.Ny, 1)
    Y = repeat(grid.y, 1, grid.Nx)
    if show_anomaly
        arrow_col = :black
        maxdiff = maximum(abs.(sim.T .- IC))
        heatmap!(
            p,
            grid.x[:],
            grid.y[:],
            sim.T .- IC;
            clims=(-1.1, 1.1),
            color=:balance,
            colorbar_title="Temperature anomaly [°C]",
            linewidth=0.0,
            size=(400, 530)
        )
    else
        arrow_col = :white
        heatmap!(
            p,
            grid.x[:],
            grid.y[:],
            sim.T;
            color=:thermal,
            levels=clims[1]:((clims[2]-clims[1])/21.0):clims[2],
            colorbar_title="Temperature [°C]",
            clims=clims,
            linewidth=0.0,
            size=(400, 520)
        )
    end

    annotate!(
        p,
        50e3,
        6170e3,
        text(
            string("t = ", Int64(round(sim.iteration * sim.Δt / (60 * 60 * 24))), " days"),
            color=:black,
            :left,
            9,
        ),
    )

    if show_quiver
        Nq = grid.N ÷ 5
        quiver!(
            p,
            X[((Nq+1)÷2):Nq:end],
            Y[((Nq+1)÷2):Nq:end];
            quiver=grid.L * 4 .*
                   (model.u[((Nq+1)÷2):Nq:end], model.v[((Nq+1)÷2):Nq:end]),
            color=arrow_col,
            alpha=0.7
        )
    end

    return as_png(p)
end

# ╔═╡ c0298712-2a88-11eb-09af-bf2c39167aa6
md"""##### Computing the velocity field for a single circular vortex
"""

# ╔═╡ df706ebc-2a63-11eb-0b09-fd9f151cb5a8
function impose_no_flux!(u, v)
    u[1, :] .= 0.0
    v[1, :] .= 0.0
    u[end, :] .= 0.0
    v[end, :] .= 0.0
    u[:, 1] .= 0.0
    v[:, 1] .= 0.0
    u[:, end] .= 0.0
    return v[:, end] .= 0.0
end

# ╔═╡ bb084ace-12e2-11eb-2dfc-111e90eabfdd
md"""##### Computing a quasi-realistic ocean velocity field $\vec{u} = (u, v)$
Our velocity field is given by an analytical solution to the classic wind-driven gyre
problem, which is given by solving the fourth-order partial differential equation:

$- \epsilon_{M} \hat{\nabla}^{4} \hat{\Psi} + \frac{\partial \hat{\Psi} }{ \partial \hat{x}} = \nabla \times \hat{\tau} \mathbf{z},$

where the hats denote that all of the variables have been non-dimensionalized and all of their constant coefficients have been bundles into the single parameter $\epsilon_{M} \equiv \dfrac{\nu}{\beta L^3}$.

The solution makes use of an advanced *asymptotic method* (valid in the limit that $\epsilon \ll 1$) known as *boundary layer analysis* (see MIT course 18.305 to learn more). 
"""

# ╔═╡ e59d869c-2a88-11eb-2511-5d5b4b380b80
md"""
##### Some simple initial temperature fields
"""

# ╔═╡ c4424838-12e2-11eb-25eb-058344b39c8b
linearT(G) = 0.5 * (1.0 .+ [-(y / G.L) for y in G.y[:, 1], x in G.x[1, :]])

# ╔═╡ 2908988e-2a9a-11eb-2cf7-494972f93152
Base.zeros(G::Grid) = zeros(G.Ny, G.Nx)

# ╔═╡ d3796644-2a05-11eb-11b8-87b6e8c311f9
begin
    struct OceanModel <: ClimateModel
        G::Grid
        P::Parameters

        u::Array{Float64,2}
        v::Array{Float64,2}
    end

    OceanModel(G, P) = OceanModel(G, P, zeros(G), zeros(G))
    OceanModel(G) = OceanModel(G, Parameters(1.e4), zeros(G), zeros(G))
end;

# ╔═╡ e3ee80c0-12dd-11eb-110a-c336bb978c51
begin
    ∂x(ϕ, Δx) = (ϕ[:, 2:end] - ϕ[:, 1:(end-1)]) / Δx
    ∂y(ϕ, Δy) = (ϕ[2:end, :] - ϕ[1:(end-1), :]) / Δy

    xpad(ϕ) = hcat(zeros(size(ϕ, 1)), ϕ, zeros(size(ϕ, 1)))
    ypad(ϕ) = vcat(zeros(size(ϕ, 2))', ϕ, zeros(size(ϕ, 2))')

    xitp(ϕ) = 0.5 * (ϕ[:, 2:end] + ϕ[:, 1:(end-1)])
    yitp(ϕ) = 0.5 * (ϕ[2:end, :] + ϕ[1:(end-1), :])

    function diagnose_velocities(ψ, G)
        u = xitp(∂y(ψ, G.Δy / G.L))
        v = yitp(-∂x(ψ, G.Δx / G.L))
        return u, v
    end
end

# ╔═╡ e2e4cfac-2a63-11eb-1b7f-9d8d5d304b43
function PointVortex(G; Ω=1.0, a=0.2, x0=0.5, y0=0.0)
    x = reshape((0.0-G.Δx/(G.L)):(G.Δx/G.L):(1.0+G.Δx/(G.L)), (1, G.Nx + 1))
    y = reshape((-1.0-G.Δy/(G.L)):(G.Δy/G.L):(1.0+G.Δy/(G.L)), (G.Ny + 1, 1))

    function ψ̂(x, y)
        r = sqrt.((y .- y0) .^ 2 .+ (x .- x0) .^ 2)

        stream = -Ω / 4 * r .^ 2
        stream[r.>a] = -Ω * a^2 / 4 * (1.0 .+ 2 * log.(r[r.>a] / a))

        return stream
    end

    u, v = diagnose_velocities(ψ̂(x, y), G)
    impose_no_flux!(u, v)

    return u, v
end

# ╔═╡ ecaab27e-2a16-11eb-0e99-87c91e659cf3
function DoubleGyre(G; β=2e-11, τ₀=0.1, ρ₀=1.e3, ν=1.e5, κ=1.e5, H=1000.0)
    ϵM = ν / (β * G.L^3)
    ϵ = ϵM^(1 / 3.0)
    x = reshape((0.0-G.Δx/(G.L)):(G.Δx/G.L):(1.0+G.Δx/(G.L)), (1, G.Nx + 1))
    y = reshape((-1.0-G.Δy/(G.L)):(G.Δy/G.L):(1.0+G.Δy/(G.L)), (G.Ny + 1, 1))

    function ψ̂(x, y)
        return π *
               sin.(π * y) *
               (
                   1 .- x -
                   exp.(-x / (2 * ϵ)) .*
                   (cos.(√3 * x / (2 * ϵ)) .+ (1.0 / √3) * sin.(√3 * x / (2 * ϵ))) .+
                   ϵ * exp.((x .- 1.0) / ϵ)
               )
    end

    u, v = (τ₀ / ρ₀) / (β * G.L * H) .* diagnose_velocities(ψ̂(x, y), G)
    impose_no_flux!(u, v)

    return u, v
end

# ╔═╡ 3d12c114-2a0a-11eb-131e-d1a39b4f440b
function InitBox(G; value=1.0, nx=2, ny=2, xspan=false, yspan=false)
    T = zeros(G)
    T[(G.Ny÷2-ny):(G.Ny÷2+ny), (G.Nx÷2-nx):(G.Nx÷2+nx)] .= value
    if xspan
        T[(G.Ny÷2-ny):(G.Ny÷2+ny), :] .= value
    end
    if yspan
        T[:, (G.Nx÷2-nx):(G.Nx÷2+nx)] .= value
    end
    return T
end

# ╔═╡ 863a6330-2a08-11eb-3992-c3db439fb624
begin
    G = Grid(10, 6.e6)
    P = Parameters(κ_ex)

    # Choose initial condition
    # u, v = zeros(G), zeros(G)
    # u, v = PointVortex(G, Ω=0.5)
    u, v = DoubleGyre(G)

    # Choose inigial condition
    #IC = InitBox(G)
    IC = InitBox(G; xspan=true)
    #IC = linearT(G)

    model = OceanModel(G, P, u * 2.0^U_ex, v * 2.0^U_ex)
    Δt = 12 * 60 * 60

    ocean_sim = ClimateModelSimulation(model, copy(IC), Δt)
end;

# ╔═╡ dc9d12d0-2a9a-11eb-3dae-85b3b6029658
begin
    go_ex
    heat_capacity = 51.0
    total_heat_content =
        sum(heat_capacity * ocean_sim.T * (ocean_sim.model.G.Δx * ocean_sim.model.G.Δy)) *
        1e-15
    mean_temp = mean(ocean_sim.T)
end;

# ╔═╡ bff89550-2a9a-11eb-3038-d70249c96219
md"""
Vamos verificar que o modelo conserva razoavelmente bem a energia. Nós não adicionamos nenhuma energia ao sistema: advecção e difusão somente movem energia de um lugar para o outro. O total de calor é $(round(total_heat_content, digits=3)) peta-Joules e a temperatura média é $(round(mean_temp, digits=2)) °C.
"""

# ╔═╡ d9e23a5a-2a8b-11eb-23f1-73ff28be9f12
md"[**A condição CFL**](https://en.wikipedia.org/wiki/Courant%E2%80%93Friedrichs%E2%80%93Lewy_condition)

A condição CFL é definida por $\text{CFL} = \dfrac{\max\left(\sqrt{u² + v²}\right)Δt}{Δx} =$ $(round(CFL_adv(ocean_sim), digits=2))
"

# ╔═╡ 0bffa27f-598f-40d9-be75-129ef0883579
CFL_adv(ocean_sim)

# ╔═╡ 6b3b6030-2066-11eb-3343-e19284638efb
function plot_kernel(A)
    return heatmap(
        collect(A);
        color=:bluesreds,
        clims=(-maximum(abs.(A)), maximum(abs.(A))),
        colorbar=false,
        xticks=false,
        yticks=false,
        size=(30 + 30 * size(A, 2), 30 + 30 * size(A, 1)),
        xaxis=false,
        yaxis=false
    )
end

# ╔═╡ 1e8d37ee-2a97-11eb-1d45-6b426b25d4eb
begin
    xgrad_kernel = OffsetArray(reshape([-1.0, 0, 1.0], 1, 3), 0:0, -1:1)
    plot_kernel(xgrad_kernel)
end

# ╔═╡ 682f2530-2a97-11eb-3ee6-99a7c79b3767
begin
    ygrad_kernel = OffsetArray(reshape([-1.0, 0, 1.0], 3, 1), -1:1, 0:0)
    plot_kernel(ygrad_kernel)
end

# ╔═╡ f4c884fc-2a97-11eb-1ba9-01bf579f8b43
begin
    function advect(T, u, v, Δy, Δx, j, i)
        return -(
            u[j, i] * sum(xgrad_kernel[0, -1:1] .* T[j, (i-1):(i+1)]) / (2Δx) +
            v[j, i] * sum(ygrad_kernel[-1:1, 0] .* T[(j-1):(j+1), i]) / (2Δy),
        )
    end
    function advect(T, u, v, Δy, Δx)
        return [
            advect(T, u, v, Δy, Δx, j, i) for j in 2:(size(T, 1)-1),
            i in 2:(size(T, 2)-1)
        ]
    end

    advect(T, O::OceanModel) = advect(T, O.u, O.v, O.G.Δy, O.G.Δx)
end

# ╔═╡ b629d89a-2a95-11eb-2f27-3dfa45789be4
begin
    xdiff_kernel = OffsetArray(reshape([1.0, -2.0, 1.0], 1, 3), 0:0, -1:1)
    ydiff_kernel = OffsetArray(reshape([1.0, -2.0, 1.0], 3, 1), -1:1, 0:0)

    [plot_kernel(xdiff_kernel), plot_kernel(ydiff_kernel)]
end

# ╔═╡ ee6716c8-2a95-11eb-3a00-319ee69dd37f
begin
    function diffuse(T, κ, Δy, Δx, j, i)
        return κ * (
            sum(xdiff_kernel[0, -1:1] .* T[j, (i-1):(i+1)]) / (Δx^2) +
            sum(ydiff_kernel[-1:1, 0] .* T[(j-1):(j+1), i]) / (Δy^2)
        )
    end
    function diffuse(T, κ, Δy, Δx)
        return [
            diffuse(T, κ, Δy, Δx, j, i) for j in 2:(size(T, 1)-1), i in 2:(size(T, 2)-1)
        ]
    end

    diffuse(T, O::OceanModel) = diffuse(T, O.P.κ, O.G.Δy, O.G.Δx)
end

# ╔═╡ 81bb6a4a-2a9c-11eb-38bb-f7701c79afa2
function timestep!(sim::ClimateModelSimulation{OceanModel})
    update_ghostcells!(sim.T)
    tendencies = advect(sim.T, sim.model) .+ diffuse(sim.T, sim.model)
    sim.T[2:(end-1), 2:(end-1)] .+= sim.Δt * tendencies
    return sim.iteration += 1
end;

# ╔═╡ 3b24e1b0-2b46-11eb-383b-c57cbf3e68f1
let
    go_ex
    if ocean_sim.iteration == 0
        timestep!(ocean_sim)
    else
        for i in 1:50
            timestep!(ocean_sim)
        end
    end
    plot_state(
        ocean_sim;
        clims=(-0.1, 1),
        show_quiver=show_quiver,
        show_anomaly=show_anomaly,
        IC=IC
    )
end

# ╔═╡ 8346b590-2b41-11eb-0bc1-1ba79bb77dfb
tvec = map(Nvec) do Npower
    G = Grid(8 * Npower, 6.e6)
    P = Parameters(κ_ex)

    #u, v = DoubleGyre(G)
    #u, v = PointVortex(G, Ω=0.5)
    u, v = zeros(G), zeros(G)

    model = OceanModel(G, P, u, v)

    IC = InitBox(G)
    #IC = InitBox(G, nx=G.Nx÷2-1)
    #IC = linearT(G)

    Δt = 6 * 60 * 60
    S = ClimateModelSimulation(model, copy(IC), Δt)

    return @elapsed timestep!(S)
end

# ╔═╡ 794c2148-2a78-11eb-2756-5bd28b7726fa
as_svg(begin
    plot(
        8 * Nvec,
        tvec;
        xlabel="Number of Grid Cells (in x-direction)",
        ylabel="elapsed time per timestep [s]"
    )
end)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
OffsetArrays = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
OffsetArrays = "~1.12.8"
Plots = "~1.36.3"
PlutoUI = "~0.7.48"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "1b3c852134cbd52328ab6ed9e52272dacc4949f3"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e7ff6cadf743c098e08fca25c91103ee4303c9bb"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.6"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "1fd869cc3875b57347f7027521f561cf46d1fcd8"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.19.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "d08c20eef1f2cbc6e60fd3612ac4340b89fea322"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.9"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "aaabba4ce1b7f8a9b34c015053d3b1edf60fa49c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.4.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.DataAPI]]
git-tree-sha1 = "e08915633fcb3ea83bf9d6126292e5bc5c739922"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.13.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "c36550cb29cbe373e95b3f40486b9a4148f89ffd"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.2"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "00a9d4abadc05b9476e937a5557fcce476b9e547"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.69.5"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "bc9f7725571ddb4ab2c4bc74fa397c1c5ad08943"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.69.1+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "fb83fbe02fe57f2c068013aa94bcdf6760d3a7a7"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+1"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "e1acc37ed078d99a714ed8376446f92a5535ca65"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.5.5"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "f377670cda23b6b7c1c0b3893e37451c5c1a2185"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.5"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "ab9aa169d2160129beb241cb2750ca499b4e90e9"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.17"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "946607f84feb96220f480e0422d3484c49c00239"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.19"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "f71d8950b724e9ff6110fc948dff5a329f901d64"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.8"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "df6830e37943c7aaa10023471ca47fb3065cc3c4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.3.2"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6e9dba33f9f2c44e08a020b0caf6903be540004"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.19+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "b64719e8b4504983c7fca6cc9db3ebc8acc2a4d6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.1"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "21303256d239f6b484977314674aef4bb1fe4420"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.1"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SnoopPrecompile", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "b72f499415dae304ba39cdc0822c850cebdfdfa6"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.36.3"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "efc140104e6d0ae3e7e30d56c98c4a927154d684"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.48"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "d12e612bba40d189cead6ff857ddb67bd2e6a387"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.1"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase", "SnoopPrecompile"]
git-tree-sha1 = "e974477be88cb5e3040009f3767611bc6357846f"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.11"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "8a75929dcd3c38611db2f8d08546decb514fcadf"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.9"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "e59ecc5a41b000fa94423a578d29290c7266fc10"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.0"

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

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

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
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

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
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9ebfc140cc56e8c2156a15ceac2f0302e327ac0a"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+0"
"""

# ╔═╡ Cell order:
# ╠═3874b4b0-9e54-4668-8cc5-bd23b5e89993
# ╟─8f4aa925-a163-4a4e-b49a-5e90439b5646
# ╟─0f8db6f4-2113-11eb-18b4-21a469c67f3a
# ╟─ed741ec6-1f75-11eb-03be-ad6284abaab8
# ╟─629a966a-c4cb-4f8e-9598-25ae2bd18297
# ╟─ac759b96-2114-11eb-24cb-d50b556f4142
# ╟─3a4a1aea-2118-11eb-30a9-57b87f2ddfae
# ╟─023779a0-2a95-11eb-35b5-7be93c43afaf
# ╟─b1b5625e-211a-11eb-3ee1-3ba9c9cc375a
# ╠═1e8d37ee-2a97-11eb-1d45-6b426b25d4eb
# ╟─3578b158-2a97-11eb-0771-bf6d82d3b6d1
# ╠═682f2530-2a97-11eb-3ee6-99a7c79b3767
# ╟─7f3c9550-2a97-11eb-1549-455009025872
# ╠═f4c884fc-2a97-11eb-1ba9-01bf579f8b43
# ╟─0127bca6-2a99-11eb-16a0-8d7af66694f8
# ╠═b629d89a-2a95-11eb-2f27-3dfa45789be4
# ╟─eac507ce-2a99-11eb-3eba-0780a4a7e078
# ╠═ee6716c8-2a95-11eb-3a00-319ee69dd37f
# ╟─09f179c0-2a9a-11eb-1d0f-e59012f9e77b
# ╠═7caca2fa-2a9a-11eb-373f-156a459a1637
# ╟─1f06bc34-2a9b-11eb-1030-ff12d103176c
# ╠═2ef2f0cc-2a9b-11eb-03c6-5d8b4c6ae822
# ╠═4558d4f8-2a9b-11eb-1f56-416975bcd180
# ╟─74aa7512-2a9c-11eb-118c-c7a5b60eac1b
# ╠═81bb6a4a-2a9c-11eb-38bb-f7701c79afa2
# ╟─13eb3966-2a9a-11eb-086c-05510a3f5b80
# ╠═cd2ee4ca-2a06-11eb-0e61-e9a2ecf72bd6
# ╠═2a93145e-2a09-11eb-323b-01817062aa89
# ╠═32663184-2a81-11eb-0dd1-dd1e10ed9ec6
# ╠═d3796644-2a05-11eb-11b8-87b6e8c311f9
# ╠═f92086c4-2a74-11eb-3c72-a1096667183b
# ╟─31cb0c2c-2a9a-11eb-10ba-d90a00d8e03a
# ╠═863a6330-2a08-11eb-3992-c3db439fb624
# ╟─981ef38a-2a8b-11eb-08be-b94be2924366
# ╟─d042d25a-2a62-11eb-33fe-65494bb2fad5
# ╟─6dbc3d34-2a89-11eb-2c80-75459a8e237a
# ╟─c20b0e00-2a8a-11eb-045d-9db88411746f
# ╟─933d42fa-2a67-11eb-07de-61cab7567d7d
# ╠═c9ea0f72-2a67-11eb-20ba-376ca9c8014f
# ╠═3b24e1b0-2b46-11eb-383b-c57cbf3e68f1
# ╟─c3f086f4-2a9a-11eb-0978-27532cbecebf
# ╟─bff89550-2a9a-11eb-3038-d70249c96219
# ╟─dc9d12d0-2a9a-11eb-3dae-85b3b6029658
# ╟─d9e23a5a-2a8b-11eb-23f1-73ff28be9f12
# ╠═ad7b7ed6-2a9c-11eb-06b7-0f5595167575
# ╠═0bffa27f-598f-40d9-be75-129ef0883579
# ╟─a04d3dee-2a9c-11eb-040e-7bd2facb2eaa
# ╠═16905a6a-2a78-11eb-19ea-81adddc21088
# ╠═8346b590-2b41-11eb-0bc1-1ba79bb77dfb
# ╠═794c2148-2a78-11eb-2756-5bd28b7726fa
# ╠═c0e46442-27fb-11eb-2c94-15edbda3f84d
# ╠═c0298712-2a88-11eb-09af-bf2c39167aa6
# ╠═e2e4cfac-2a63-11eb-1b7f-9d8d5d304b43
# ╠═e3ee80c0-12dd-11eb-110a-c336bb978c51
# ╠═df706ebc-2a63-11eb-0b09-fd9f151cb5a8
# ╟─bb084ace-12e2-11eb-2dfc-111e90eabfdd
# ╠═ecaab27e-2a16-11eb-0e99-87c91e659cf3
# ╠═e59d869c-2a88-11eb-2511-5d5b4b380b80
# ╠═c4424838-12e2-11eb-25eb-058344b39c8b
# ╠═3d12c114-2a0a-11eb-131e-d1a39b4f440b
# ╟─2908988e-2a9a-11eb-2cf7-494972f93152
# ╠═6b3b6030-2066-11eb-3343-e19284638efb
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
