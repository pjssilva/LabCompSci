### A Pluto.jl notebook ###
# v0.19.42

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

# ╔═╡ 1c8d2d00-b7d9-11eb-35c4-47f2a2aa1593
begin
import Pkg
	ENV["JULIA_MARGO_LOAD_PYPLOT"] = "no thank you"
    Pkg.activate(mktempdir())
    Pkg.add([
        Pkg.PackageSpec(name="Plots", version="1"),
        Pkg.PackageSpec(name="ClimateMARGO", version=v"0.3.2"),
        Pkg.PackageSpec(name="PlutoUI", version="0.7"),
        Pkg.PackageSpec(name="HypertextLiteral", version="0.9"),
		Pkg.PackageSpec(name="Underscores", version="2"),
    ])
	
	using Plots
	using Plots.Colors
	using ClimateMARGO
	using ClimateMARGO.Models
	using ClimateMARGO.Optimization
	using ClimateMARGO.Diagnostics
	using PlutoUI
    using HypertextLiteral
	using Underscores
	
	Plots.default(linewidth=5)

	html"""
	<style> #loading-message { display: none; } </style>
	"""    
end;

# ╔═╡ 9a48a08e-7281-473c-8afc-7ad3e0771269
TableOfContents(title="Índice")

# ╔═╡ 94415ff2-32a2-4b0f-9911-3b93e202f548
initial_1 = Dict("M" => [2090, 6]);

# ╔═╡ e810a90f-f964-4d7d-acdb-fc3a159dc12e
initial_2 = Dict("M" => [2080, 0.7]);

# ╔═╡ a3422533-2b78-4bc2-92bd-737da3c8982d
initial_3 = Dict("M" => [2080, 0.7]);

# ╔═╡ bb66d347-99be-4a95-8ba8-57dc9d33384b
initial_4 = Dict(
    "M" => [2080, 0.7],
    "R" => [2120, 0.2],
);

# ╔═╡ 3094a9eb-074d-46c3-9c1e-0a9c94c6ad43
blob(el, color="red") = @htl("""<div style="
background: $(color);
padding: 1em 1em 1em 1em;
border-radius: 2em;
">$(el)</div>""")

# ╔═╡ 0b31eac2-8efd-47cd-9571-a2053846343b
function infeasablewarning(x)
    @htl("""
   <margo-infeasible>
   	$(x)
   	<margo-infeasible-label>No solution found</margo-infeasible-label>
   </margo-infeasible>

   <style>
   margo-infeasible > * {
   	opacity: .1;
   }
   margo-infeasible > margo-infeasible-label {
   	opacity: .7;
   	display: block;
   	position: absolute;
   	transform: translate(-50%, -50%);
   	font-family: "Vollkorn", system-ui;
   	font-style: italic;
   	font-size: 40px;
   	top: 50%;
   	left: 50%;
   	
       white-space: nowrap;
   }


   </style>
   	""")
end

# ╔═╡ ca104939-a6ca-4e70-a47a-1eb3c32db18f
status_ok(x) = x ∈ [
    "OPTIMAL",
    "LOCALLY_SOLVED",
    "ALMOST_OPTIMAL",
    "ALMOST_LOCALLY_SOLVED"
]

# ╔═╡ cf90139c-13d8-42a7-aba3-8c431e7854b8
feasibility_overlay(x) = status_ok(x.status) ? as_html : infeasablewarning

# ╔═╡ bd2bfa3c-a42e-4975-a543-84541f66b1c1
begin
    hidecloack(name) = HTML("""
    <style>
    plj-cloack.$(name) {
    	opacity: 0;
    	display: block;
    }
    </style>
    """)

    "A trick to hide a cell without creating a variable dependency, to make it simpler for PlutoSliderServer.jl."
    cloak(name) = x -> @htl("<plj-cloack class=$(name)>$(x)</plj-cloak>")
end

# ╔═╡ b81de514-2506-4243-8235-0b54dd4a7ec9
colors = (
    baseline=colorant"#dddddd",
    baseline_emissions=colorant"#dddddd",
    baseline_concentrations=colorant"#dddddd",
    baseline_temperature=colorant"#dddddd",
    baseline_damages=colorant"#dddddd",
    temperature=colorant"#edc949",
    above_paris=colorant"#e1575910",
    M=colorant"#4E79A7",
    R=colorant"#F28E2C",
    A=colorant"#59A14F",
    G=colorant"#E15759",
    T_max=colorant"#00000080",
    controls=colorant"#af7aa1",
    damages=colorant"#e15759",
    avoided_damages=colorant"#e49734",
    benefits=colorant"#7abf5e",
    emissions=colorant"brown",
    emissions_1=colorant"#4E79A7",
    concentrations=colorant"brown",
)

# ╔═╡ 73e01bd8-f56b-4bb5-a9a2-85ad223c9e9b
nnames = (
    baseline="Baseline",
    baseline_emissions="Baseline",
    baseline_concentrations="Baseline",
    baseline_temperature="Baseline",
    baseline_damages="Baseline",
    temperature="Temperature",
    above_paris="Above Paris",
    M="Mitigation",
    R="Removal",
    A="Adaptation",
    G="Geo-engineering",
    T_max="Goal temperature",
    controls="Controls",
    damages="Damages",
    avoided_damages="Avoided Damages",
    benefits="Benefits",
    emissions="Emissions",
    emissions_1="Emissions",
    concentrations="Concentrations",
)

# ╔═╡ ae92ba1f-5175-4704-8240-2de8432df752
@assert keys(colors) == keys(nnames)

# ╔═╡ 8ac04d55-9034-4c29-879b-3b10887a616d
begin
    struct BondDefault
        x
        default
    end

    Base.get(bd::BondDefault) = bd.default
    Base.show(io::IO, m::MIME"text/html", bd::BondDefault) = Base.show(io, m, bd.x)

    BondDefault
end

# ╔═╡ 29aa932b-9835-4d13-84e2-5ccf380a21ea
@bind which_graph_2 Select([
    "Emissions"
    "Concentrations"
    "Temperature"
])

# ╔═╡ 9d603716-3069-4032-9416-cd8ab2e272c6
@bind which_graph_4 Select([
    "Emissions"
    "Concentrations"
    "Temperature"
    "Costs and benefits"
])

# ╔═╡ 70173466-c9b5-4227-8fba-6256fc1ecace
Tmax_9_slider = @bind Tmax_9 Slider(0:0.1:5; default=2);

# ╔═╡ 6bcb9b9e-e0ab-45d3-b9b9-3d7282f89df6
allow_overshoot_9_cb = @bind allow_overshoot_9 CheckBox();

# ╔═╡ b428e2d3-e1a9-4e4e-a64f-61048572102f
function multiplier(unit::Real, factor::Real=2, suffix::String="%")
    h = @htl("""


    <script>
    	const unit = $(unit)
    	const factor = $(factor)
    	const suffix = $(suffix)
     const input = html`<input type=range min=-1 max=1 step=.01 value=0>`;
     const output = html`<input disabled style="width: 1.8em; display: inline-block;overflow-x: hidden;"></input>`;
     // const output = html``;

     const left = Math.round(100 / factor) + "%";
     const right = Math.round(100 * factor) + "%";

     const reset = html`<a href="#" title="Reset" style='padding-left: .5em'><img width="14" src="https://cdn.jsdelivr.net/gh/ionic-team/ionicons@5.0.0/src/svg/arrow-undo-sharp.svg"></img></a>`;
     const span = html`<div style="margin-left: 2em;">\${left}\${input}\${right}\${reset}</div>`;

     const on_slider = () => {
       output.value = Math.round(100 * Math.pow(factor, input.value));
       input.title = Math.round(100 * Math.pow(factor, input.value)) + "%";

       reset.style.opacity = input.valueAsNumber == 0 ? "0" : "1";
     };
     input.oninput = on_slider;
     on_slider();

     //   const on_box = () => {
     //     input.value = output.value;

     //     reset.style.opacity = input.valueAsNumber == 100 ? "0" : "1";
     //   };
     //   output.oninput = on_box;

     reset.onclick = (e) => {
       input.value = 0;
       on_slider();
    	e.preventDefault()
       span.dispatchEvent(new CustomEvent("input", {}));
     };

     Object.defineProperty(span, "value", {
       get: () => unit * Math.pow(factor, input.value),
       set: val => {
         input.value = Math.log2(val / unit) / Math.log2(factor);
         on_slider();
       }
     });

     return span;
    </script>
    """)

    BondDefault(h, unit)
end

# ╔═╡ 8cab3d28-a457-4ccc-b053-38cd003bf4d1
function Carousel(
    elementsList;
    wraparound::Bool=false,
    peek::Bool=true
)

    @assert peek

    carouselHTML = map(elementsList) do element
        @htl("""<div class="carousel-slide">
            $(element)
        </div>""")
    end

    h = @htl("""
<div>
    <style>
    .carousel-box{
        width: 100%;
        overflow: hidden;
    }
    .carousel-container{
        top: 0;
        left: 0;
        display: flex;
        width: 100%;
        flex-flow: row nowrap;
        transform: translate(10%, 0px);
        transition: transform 200ms ease-in-out;
    }
    .carousel-controls{
        display: flex;
        justify-content: center;
        align-items: center;
    }
    .carousel-controls button{
        margin: 8px;
        width: 6em;
    }
    .carousel-slide {
        min-width: 80%;
    }
    </style>
		
    <script>
        const div = currentScript.parentElement
        const buttons = div.querySelectorAll("button")
		
		const max = $(length(elementsList))

		let count = 0
		
		const mod = (n, m) => ((n % m) + m) % m
		const clamp = (x, a, b) => Math.max(Math.min(x, b), a)
		
		const update_ui = (count) => {
			buttons[0].disabled = !$(wraparound) && count === 0
			buttons[1].disabled = !$(wraparound) && count === max - 1
		
			div.querySelector(".carousel-container").style = `transform: translate(\${10-count*80}%, 0px)`;
		}
		
		const onclick = (e) => {
			const new_count = count + parseInt(e.target.dataset.value)
			if($(wraparound)){
				count = mod(new_count, max)
			} else {
				count = clamp(new_count, 0, max - 1)
			}
			
            
			div.value = count + 1
			div.dispatchEvent(new CustomEvent("input"))
			update_ui(div.value - 1)
            e.preventDefault()
        }
        buttons.forEach(button => button.addEventListener("click", onclick))
        div.value = count + 1
		update_ui(div.value - 1)
    </script>
		
    <div class="carousel-box">
        <div class="carousel-container">
            $(carouselHTML)
        </div>
    </div>
		
    <div class="carousel-controls">
        <button data-value="-1">Previous</button>
        <button data-value="1">Next</button>
    </div>
</div>
    """)

    BondDefault(h, 1)
end

# ╔═╡ c7cbc172-daed-406f-b24b-5da2cc234c29
preindustrial_concentrations = 280

# ╔═╡ b440cd13-36a9-4c54-9d80-ac3fa7c2900e
end_of_oil = 2150 # cannot mitigate when fossil fuels are depleted

# ╔═╡ ec760706-15ac-4a50-a67e-c338d70f3b0a
pp = (;
    ((k, (:color => c, :label => n))
     for (k, c, n) in zip(keys(nnames), colors, nnames))...
);

# ╔═╡ bb4b25e4-0db5-414b-a384-0a27fe7efb66
gauss_stdev = 30

# ╔═╡ 013807a0-bddb-448b-9300-f7f559e48a45
begin
    default_usage_error = :(error("Example usage:\n\n@intially [1,2] @bind x f(x)\n"))

    macro initially(::Any)
        default_usage_error
    end

    macro initially(default, bind_expr::Expr)
        if bind_expr.head != :macrocall || bind_expr.args[1] != Symbol("@bind")
            return default_usage_error
        end

        # warn if the first argument is a @bind
        if default isa Expr && default.head == :macrocall && default.args[1] == Symbol("@bind")
            return default_usage_error
        end

        esc(intially_function(default, bind_expr))
    end


    function intially_function(default, bind_expr)
        sym = bind_expr.args[3]
        @gensym setval bond

        quote
            if !@isdefined($sym)
                $sym = $default
            end

            $setval = $sym


            $bond = @bind $sym $(bind_expr.args[4])
            PlutoRunner.Bond

            if $sym isa Missing
                $sym = $setval
            end

            $bond
        end
    end
end

# ╔═╡ 4e91fb48-fc5e-409e-9a7e-bf846f1d211d
html"""
<style>

margo-knob {
	display: block;
	cursor: pointer;
	width: 32px;
	height: 32px;
	transform: translate(-8px, -16px);
	background: red;
	border-radius: 100%;
	border-width: 5px;
	border-style: solid;
	border-color: rgb(255 255 255 / 43%);
	border-opacity: .2;

    position: absolute;
	top: 0px;
	left: 0px;
}

margo-knob-label {
	transform: translate(32px, -8px);
    display: block;
    position: absolute;
    left: 0;
    top: 0;
	white-space: nowrap;
    background: #d6eccb;
    font-family: system-ui;
    padding: .4em;
    border-radius: 11px;
    font-weight: 600;
	pointer-events: none;
	opacity: 0;
}

.wiggle margo-knob {
	animation: wiggle 5s ease-in-out;
	animation-delay: 600ms;
}
.wiggle margo-knob-label {
	animation: fadeout 1s ease-in-out;
	animation-delay: 3s;
	animation-fill-mode: both;
}

@keyframes fadeout {
	from {
		opacity: 1;
	}
	to {
		opactiy: 0;
	}
}

@keyframes wiggle {
	0% {
		transform: translate(-8px, -16px);
	}
	2% {
		transform: translate(8px, -16px);
	}
	5% {
		transform: translate(-24px, -16px);
	}
	10% {
		transform: translate(-8px, -16px);
	}
	/* 15% {
		transform: translate(-8px, -16px);
	}
	17% {
		transform: translate(-8px, 0px);
	}
	20% {
		transform: translate(-8px, -32px);
	}
	25% {
		transform: translate(-8px, -16px);
	}*/
}

</style>
"""

# ╔═╡ 3c7271ab-ece5-4ae2-a8dd-dc3670f300f7
# initial_mrga_1 = Dict(
# 	"M" => [2070, 0.7],
# 	"R" => [2100, 0.4],
# 	"G" => [2170, 0.3],
# 	"A" => [2110, 0.1],
# )

# ╔═╡ dcf265c1-f09b-483e-a361-d54c6c7500c1
# @initially initial_mrga_1 @bind input_8 begin

# 	controls_8 = MRGA(
# 		gaussish(input_8["M"]...),
# 		gaussish(input_8["R"]...),
# 		gaussish(input_8["G"]...),
# 		gaussish(input_8["A"]...),
# 	)


# 	plotclicktracker2(
# 		plot_controls(controls_8),
# 		initial_mrga_1,
# 	)
# end

# ╔═╡ 10c015ec-780c-4453-83cb-12dd0f09f358
function plotclicktracker(p::Plots.Plot; draggable::Bool=false)

    # we need to render the plot before its dimensions are available:
    # plot_render = repr(MIME"image/svg+xml"(),  p)
    plot_render = repr(MIME"image/svg+xml"(), p)

    # these are the _bounding boxes_ of our plot
    big = bbox(p.layout)
    small = plotarea(p[1])

    # the axis limits
    xl = xlims(p)
    yl = ylims(p)

    # with this information, we can form the linear transformation from 
    # screen coordinate -> plot coordinate

    # this is done on the JS side, to avoid one step in the Julia side
    # we send the linear coefficients:
    r = (
        x_offset=xl[1] - (xl[2] - xl[1]) * small.x0[1] / small.a[1],
        x_scale=(big.a[1] / small.a[1]) * (xl[2] - xl[1]),
        y_offset=(yl[2] - yl[1]) + (small.x0[2] / small.a[2]) * (yl[2] - yl[1]) + yl[1],
        y_scale=-(big.a[2] / small.a[2]) * (yl[2] - yl[1]),
        x_min=xl[1], # TODO: add margin
        x_max=xl[2],
        y_min=yl[1],
        y_max=yl[2],
    )

    HTML("""<script id="hello">

     const body = $(PlutoRunner.publish_to_js(plot_render))
     const mime = "image/svg+xml"


     const img = this ?? document.createElement("img")


     let url = URL.createObjectURL(new Blob([body], { type: mime }))

     img.type = mime
     img.src = url
     img.draggable = false
     img.style.cursor = "pointer"

     const clamp = (x,a,b) => Math.min(Math.max(x, a), b)
     img.transform = f => [
     	clamp(f[0] * $(r.x_scale) + $(r.x_offset), $(r.x_min), $(r.x_max)),
     	clamp(f[1] * $(r.y_scale) + $(r.y_offset), $(r.y_min), $(r.y_max)),
     ]
     img.fired = false

     const val = {current: undefined }



     if(this == null) {

     Object.defineProperty(img, "value", {
     	get: () => val.current,
     	set: () => {},
     })

     const handle_mouse = (e) => {
     	const svgrect = img.getBoundingClientRect()
     	const f = [
     		(e.clientX - svgrect.left) / svgrect.width, 
     		(e.clientY - svgrect.top) / svgrect.height
     	]
     	if(img.fired === false){
     		img.fired = true
     		val.current = img.transform(f)
     		img.dispatchEvent(new CustomEvent("input"), {})
     	}
     }



     img.addEventListener("click", onclick)

     img.addEventListener("pointerdown", e => {
     	if($(draggable)){
     		img.addEventListener("pointermove", handle_mouse);
     	}
     	handle_mouse(e);
     });
     const mouseup = e => {
     	img.removeEventListener("pointermove", handle_mouse);
     };
     document.addEventListener("pointerup", mouseup);
     document.addEventListener("pointerleave", mouseup);
     }



     return img
     </script>""")
end

# ╔═╡ 7e540eaf-8700-4176-a96c-77ee2e4c384b
years = 2020:12.0:2200

# ╔═╡ 646591c4-cb60-41cd-beb9-506807ce17d2
function gaussish(mean, magnitude)
    my_stdev = gauss_stdev * (1 + magnitude)
    map(years) do t
        clamp(
            (1.5 *
             magnitude *
             (-0.4 +
              exp(
                 (-1 * ((t - mean) * (t - mean))) / (2 * my_stdev * my_stdev)
             ))) /
            (1.0 - 0.4),
            0.0,
            1.0
        )
    end
end

# ╔═╡ 8fa94ec9-1fab-41b9-a7e6-1917e975e4ff
function default_parameters()::ClimateModelParameters
    result = deepcopy(ClimateMARGO.IO.included_configurations["default"])
    result.domain = years isa Domain ? years : Domain(step(years), first(years), last(years))
    result.economics.baseline_emissions = ramp_emissions(result.domain)
    result.economics.extra_CO₂ = zeros(size(result.economics.baseline_emissions))
    return result
end

# ╔═╡ 8311d458-a1bb-484c-86e7-5a671d36f94d
default_parameters()

# ╔═╡ 785c428d-d4f7-431e-94d7-039b0708a78a
function opt_controls_temp(model_parameters=default_parameters(); opt_parameters...)

    model = ClimateModel(model_parameters)

    model_optimizer = optimize_controls!(model; opt_parameters..., print_raw_status=false)

    (
        result=model,
        status=ClimateMARGO.Optimization.JuMP.termination_status(model_optimizer) |> string,
    )
    # return Dict(
    #     :model_parameters => model_parameters,
    #     model_results(model)...
    # )
end

# ╔═╡ 254ce01c-7976-4fe8-a980-fea1a61d7406


# ╔═╡ 2dcd5669-c725-40b9-84c4-f8399f6e924b
bigbreak = html"""
<div style="height: 10em;"></div>
""";

# ╔═╡ eb7f34c3-1cd9-411d-8f34-d8547ba6ac29
bigbreak

# ╔═╡ cf5f7459-fbbe-4595-baa4-b6b85017005a
bigbreak

# ╔═╡ d796cb71-0e34-41ce-bc97-45c68812046d
bigbreak

# ╔═╡ 6ca2a32a-51de-4ff4-8023-843396f970ec
bigbreak

# ╔═╡ b8f9efec-63ac-4e58-93cf-9f7199b78451
function setfieldconvert!(value, name::Symbol, x)
    setfield!(value, name, convert(typeof(getfield(value, name)), x))
end

# ╔═╡ 371991c7-13dd-46f6-a730-ad89f43c6f0e
function enforce_maxslope!(controls;
    dt=step(years),
    max_slope=Dict("mitigate" => 1.0 / 40.0, "remove" => 1.0 / 40.0, "geoeng" => 1.0 / 80.0, "adapt" => 0.0)
)
    controls.mitigate[1] = 0.0
    controls.remove[1] = 0.0
    controls.geoeng[1] = 0.0
    # controls.adapt[1] = 0.0


    for i in 2:length(controls.mitigate)
        controls.mitigate[i] = clamp(
            controls.mitigate[i],
            controls.mitigate[i-1] - max_slope["mitigate"] * dt,
            controls.mitigate[i-1] + max_slope["mitigate"] * dt
        )
        controls.remove[i] = clamp(
            controls.remove[i],
            controls.remove[i-1] - max_slope["remove"] * dt,
            controls.remove[i-1] + max_slope["remove"] * dt
        )
        controls.geoeng[i] = clamp(
            controls.geoeng[i],
            controls.geoeng[i-1] - max_slope["geoeng"] * dt,
            controls.geoeng[i-1] + max_slope["geoeng"] * dt
        )
        controls.adapt[i] = clamp(
            controls.adapt[i],
            controls.adapt[i-1] - max_slope["adapt"] * dt,
            controls.adapt[i-1] + max_slope["adapt"] * dt
        )
    end
end


# ╔═╡ b7ca316b-6fa6-4c2e-b43b-cddb08aaabbb
function costs_dict(costs, model)
    Dict(
        :discounted => costs,
        :total_discounted => sum(costs .* model.domain.dt),
    )
end

# ╔═╡ 0a3be2ea-6af6-43c0-b8fb-e453bc2b703b

model_results(model::ClimateModel) = Dict(
    :controls => model.controls,
    :computed => Dict(
        :temperatures => Dict(
            :baseline => T_adapt(model),
            :M => T_adapt(model; M=true),
            :MR => T_adapt(model; M=true, R=true),
            :MRG => T_adapt(model; M=true, R=true, G=true),
            :MRGA => T_adapt(model; M=true, R=true, G=true, A=true),
        ),
        :emissions => Dict(
            :baseline => effective_emissions(model),
            :M => effective_emissions(model; M=true),
            :MRGA => effective_emissions(model; M=true, R=true),
        ),
        :concentrations => Dict(
            :baseline => c(model),
            :M => c(model; M=true),
            :MRGA => c(model; M=true, R=true),
        ),
        :damages => Dict(
            :baseline => costs_dict(damage(model; discounting=true), model),
            :MRGA => costs_dict(damage(model; M=true, R=true, G=true, A=true, discounting=true), model),
        ),
        :costs => Dict(
            :M => costs_dict(cost(model; M=true, discounting=true), model),
            :R => costs_dict(cost(model; R=true, discounting=true), model),
            :G => costs_dict(cost(model; G=true, discounting=true), model),
            :A => costs_dict(cost(model; A=true, discounting=true), model),
            :MRGA => costs_dict(cost(model; M=true, R=true, G=true, A=true, discounting=true), model),
        ),
    ),
)


# ╔═╡ ec5d87a6-354b-4f1d-bb73-b3db08589d9b
total_discounted(costs, model) = sum(costs .* model.domain.dt)

# ╔═╡ 70f01a4d-0aa3-4cd5-ad71-452c490c61ac
colors_js = Dict((k, string("#", hex(v))) for (k, v) in pairs(colors));

# ╔═╡ ac779b93-e19e-41de-94cb-6a2a919bcd2e
names_js = Dict(pairs(nnames));

# ╔═╡ 5c484595-4646-484f-9e75-a4a3b4c2af9b
function plotclicktracker2(p::Plots.Plot, initial::Dict; draggable::Bool=true)

    # we need to render the plot before its dimensions are available:
    # plot_render = repr(MIME"image/svg+xml"(),  p)
    plot_render = repr(MIME"image/svg+xml"(), p)

    # these are the _bounding boxes_ of our plot
    big = bbox(p.layout)
    small = plotarea(p[1])

    # the axis limits
    xl = xlims(p)
    yl = ylims(p)

    # with this information, we can form the linear transformation from 
    # screen coordinate -> plot coordinate

    # this is done on the JS side, to avoid one step in the Julia side
    # we send the linear coefficients:
    r = (
        x_offset=xl[1] - (xl[2] - xl[1]) * small.x0[1] / small.a[1],
        x_scale=(big.a[1] / small.a[1]) * (xl[2] - xl[1]),
        y_offset=(yl[2] - yl[1]) + (small.x0[2] / small.a[2]) * (yl[2] - yl[1]) + yl[1],
        y_scale=-(big.a[2] / small.a[2]) * (yl[2] - yl[1]),
        x_min=xl[1], # TODO: add margin
        x_max=xl[2],
        y_min=yl[1],
        y_max=yl[2],
    )

    @htl("""<script id="hello">

     const initial = $(initial)


     const colors = $(colors_js)
     const names = $(names_js)


     const body = $(HypertextLiteral.JavaScript(PlutoRunner.publish_to_js(plot_render)))
     const mime = "image/svg+xml"


     const knob = (name) => {
     	const k = html`<margo-knob id=\${name}><margo-knob-label>👈 Move me!</margo-knob-label></margo-knob>`
     	k.style.backgroundColor = colors[name]
     	return k
     }

     const wrapper = this ?? html`
     	<div>
     		<img>
     		\${Object.keys(initial).map(knob)}
     	</div>
     `
     const img = wrapper.firstElementChild

     let url = URL.createObjectURL(new Blob([body], { type: mime }))

     img.type = mime
     img.src = url
     img.draggable = false

     const clamp = (x,a,b) => Math.min(Math.max(x, a), b)
     wrapper.transform = f => [
     	clamp(f[0] * $(r.x_scale) + $(r.x_offset), $(r.x_min), $(r.x_max)),
     	clamp(f[1] * $(r.y_scale) + $(r.y_offset), $(r.y_min), $(r.y_max)),
     ]
     wrapper.inversetransform = f => [
     	(f[0] - $(r.x_offset)) / $(r.x_scale),
     	(f[1] - $(r.y_offset)) / $(r.y_scale),
     ]

     const set_knob_coord = (k, coord) => {
     	const svgrect = img.getBoundingClientRect()
     	const r = wrapper.inversetransform(coord)
     	k.style.left = `\${r[0] * svgrect.width}px`
     	k.style.top = `\${r[1] * svgrect.height}px`
     }


     wrapper.fired = false


     wrapper.last_render_time = Date.now()


     // If running for the first time
     if(this == null) {


     	// will contain the currently dragging HTMLElement
     	const dragging = { current: undefined }

     	const value = {...initial}

     	Object.defineProperty(wrapper, "value", {
     		get: () => value,
     		set: (x) => {
     			/* console.log("old", value, "new", x)
     			Object.assign(value, x)
     			Object.entries(value).forEach(([k,v]) => {
     				set_knob_coord(
     					wrapper.querySelector(`margo-knob#\${k}`),
     					v
     				)
     			}) */
     		},
     	})


     	
     	
     	////
     	// Event listener for pointer move

     	const on_pointer_move = (e) => {
     		if(Object.keys(initial).includes(dragging.current.id)){

     			const svgrect = img.getBoundingClientRect()
     			const f = [
     				(e.clientX - svgrect.left) / svgrect.width, 
     				(e.clientY - svgrect.top) / svgrect.height
     			]
     			if(wrapper.fired === false){
     				const new_coord = wrapper.transform(f)
     				value[dragging.current.id] = new_coord
     				set_knob_coord(dragging.current, new_coord)

     				wrapper.classList.toggle("wiggle", false)
     				wrapper.fired = true
     				wrapper.dispatchEvent(new CustomEvent("input"), {})
     			}
     		}
     	}

     	
     	////
     	// Add the listeners

     	wrapper.addEventListener("pointerdown", e => {
     		window.getSelection().empty()

     		
     		dragging.current = e.target
     		if($(draggable)){
     			wrapper.addEventListener("pointermove", on_pointer_move);
     		}
     		on_pointer_move(e);
     	});
     	const mouseup = e => {
     		wrapper.removeEventListener("pointermove", on_pointer_move);
     	};
     	document.addEventListener("pointerup", mouseup);
     	document.addEventListener("pointerleave", mouseup);
     	wrapper.onselectstart = () => false



     	////
     	// Set knobs to initial positions, using the inverse transformation

     	new Promise(r => {
     		img.onload = r
     	}).then(() => {
     		Array.from(wrapper.querySelectorAll("margo-knob")).forEach(k => {
     			set_knob_coord(k, initial[k.id])
     		})
     	})

     	////
     	// Intersection observer to trigger to wiggle animation
     	const observer = new IntersectionObserver((es) => {
     		es.forEach((e) => {
     			if(Date.now() - wrapper.last_render_time > 500){
     				wrapper.classList.toggle("wiggle", e.isIntersecting)
     			}
     		})
     	}, {
     		rootMargin: `20px`,
     		threshold: 1,
     	})

     	observer.observe(wrapper)
     	wrapper.classList.toggle("wiggle", true)
     }



     return wrapper
     </script>""")
end

# ╔═╡ 060cbeab-5503-4eda-95d8-3f554765b2ee
begin
    mutable struct MRGA{T}
        M::T
        R::T
        G::T
        A::T
    end
    # function MRGA(M::TM,R::TR=nothing,G::TG=nothing) where {TM,TR,TG}
    # 	MRGA{Union{TM,TR,TG,Nothing}}(M,R,G,nothing)
    # end
    function MRGA(; M::TM=nothing, R::TR=nothing, G::TG=nothing, A::TA=nothing) where {TM,TR,TG,TA}
        MRGA{Union{TM,TR,TG,TA}}(M, R, G, A)
    end

    MRGA(x) = MRGA(x, x, x, x)

    splat(mrga::MRGA) = (:M => mrga.M, :R => mrga.R, :G => mrga.G, :A => mrga.A)

    Base.collect(mrga::MRGA) = [mrga.M, mrga.R, mrga.G, mrga.A]

    Base.getindex(x::MRGA, pos::MRGA{Bool}) = collect(x)[collect(pos)]

    Base.getindex(x::MRGA, tech::Symbol) = getfield(x, tech)

    Base.eachindex(m::MRGA) = (:M, :R, :G, :A)

    Base.enumerate(mrga::MRGA) = ((:M, mrga.M), (:R, mrga.R), (:G, mrga.G), (:A, mrga.A))

    Base.any(m::MRGA{Bool}) = m.M || m.R || m.G || m.A

    Base.all(m::MRGA{Bool}) = m.M && m.R && m.G && m.A

    MRGA
end

# ╔═╡ f957229f-5e48-458d-bbbc-1efc1356d704
md"Tradução livre de [inverse\_climate\_model.jl](https://github.com/mitmath/18S191/blob/Spring21/notebooks/week14/inverse_climate_model.jl)."

# ╔═╡ 331c45b7-b5f2-4a78-b180-5b918d1806ee
md"""
# Mitigação de emissões e remoção de dióxido de carbono para minimizar o sofrimento climático

Esse caderno iterativo permite que *você* execute [MARGO](https://github.com/ClimateMARGO/ClimateMARGO.jl), um modelo climático simples, para explorar as ações que serão necessárias para evitar os impactos catastróficos do aquecimento global. Lembre-se que o código desse caderno é *reativo*, ou seja, os gráficos e números calculados serão automaticamente atualizados sempre que você alterar as entradas do modelo climático.

## _Você consegue limitar o aquecimento climático de causa humana "bem abaixo de 2ºC"?_
"""

# ╔═╡ 7553b243-226c-457c-9532-1297f1e8d869
md"## Como intervir?

### Mitigação

### Remoção

### Geo-engenharia

### Adaptação
"

# ╔═╡ 6533c123-34fe-4c0d-9ecc-7fef11379253
md"""
![image](https://user-images.githubusercontent.com/6933510/118835384-3ad36c80-b8c3-11eb-995d-70cba3b23846.png)

_From: [ClimateMARGO.jl](https://github.com/ClimateMARGO/ClimateMARGO.jl)_
"""

# ╔═╡ 50d24c91-61ae-4544-98fa-5749bafe3d41
md"""
## Visão geral do problema climático: das emissões de gases de efeito estufa ao sofrimento climático

As emissões humanas de gases de efeito estufa, principalmente Dióxido de Carbono (CO₂), aumentam seu estoque na atmosfera. Para cada molécula de CO₂ emitida, cerca de 50% são absorvidos pelas plantas, solos ou oceano em poucos anos. O restante permanece na atmosfera. (Vamos nos concentral em CO₂. Os efeitos de outros gases de efeito estufa, como metano e CFCs, e outros agentes forçantes, podem ser convertidos, aproximadamente, no "equivalente de CO₂" - ou concentrações de CO₂ₑ que levariam ao mesmo efeito climático).

Os gases de efeito estufa recebem esse nome porque impedem que parte da radiação de calor invisível emitida pela superfície da Terra e pela atmosfera escape para o espaço, de forma análoga às estufas que evitam que o ar quente suba quando é aquecido pelo sol. Este "efeito estufa" faz com que a temperatura aumente globalmente, embora alguns lugares aqueçam *mais* e *mais rápido* do que outros. As temperaturas mais altas exacerbam a frequência e a intensidade dos desastres "naturais", como ondas de calor, inundações costeiras causadas por grandes furacões e inundações internas causadas por chuvas torrenciais. Esses impactos climáticos levam a um maior sofrimento climático. A economia normalmente tenta quantificar o sofrimento em função de perda de dinheiro ou bem-estar.

No caderno abaixo, convidamos você a explorar os benefícios da mitigação de emissões e remoção de dióxido de carbono na redução do sofrimento climático e balaço que deve ser considerado com seus custos.
"""

# ╔═╡ ec325089-8418-4fed-ac0e-e8ae21b433ab
md"""
## Mitigação de emissões

As emissões humanas de gases de efeito estufa são o resultado da queima de combustíveis fósseis (para transporte, geração de eletricidade, aquecimento, indústria, etc.), agricultura insustentável e mudanças no uso da terra. Chamamos de *mitigação* quaisquer ações ou políticas que reduzam essas emissões.

O modelo MARGO agrupa todas as mitigações potenciais em um único número: a porcentagem de *emissões de linha de base* evitadas em um determinado ano. Emissões de linha de base são as emissões que surgiriam em um hipotético mundo futuro sem uma política climática. Em nosso hipotético mundo sem políticas, presumimos que as emissões chegarão a zero até 2150, mesmo sem uma política climática, talvez devido a preocupações de saúde pública em relação a outras formas de poluição do ar, o desenvolvimento de novas tecnologias de carbono zero ou ao esgotamento dos combustíveis fósseis.

* No gráfico abaixo, arraste o ponto azul * para alterar a quantidade e o tempo de mitigação e observe como essas mudanças afetam as principais variáveis ​​climáticas, usando o menu drop-box: emissões de CO₂ₑ, concentrações de CO₂ₑ e temperatura global.
"""

# ╔═╡ 30218715-6469-4a0f-bf90-f3243219e7b5
md"""
## Custos e prejuízos
"""

# ╔═╡ 8433cb38-915a-46c1-b3db-8e7905351c1b
@bind cost_benefits_narrative_slide Carousel([
        md"""### 1. Os custos do sofrimento climático

      Na ausência de ação climática, as temperaturas subiriam mais de 4,5ºC acima dos níveis pré-industriais (média de 1800 a 1850), causando impactos climáticos catastróficos. MARGO tenta quantificar esse sofrimento traduzindo o grau de aquecimento em danos econômicos (em \$ / ano). A curva abaixo mostra como os danos climáticos aumentam ao longo do tempo, como uma porcentagem do Produto Interno Bruto Mundial (WGDP) naquele ano, devido a aumentos descontrolados de temperatura.

      """, md"""### 2. Evitando danos climáticos

           A mitigação de emissões limita o aquecimento futuro e o sofrimento climático (curva de _Danos_). Os benefícios econômicos da mitigação são dados pela diferença nos danos em relação ao cenário sem política (curva _base_ menos curva _Danos_).

           Na figura abaixo, arraste ao redor do ponto azul para alterar a estratégia de mitigação futura e observe como os _Danos evitados_ (a área cinza) mudam!

           """, md"""### 3. Análise de custo-benefício

                Infelizmente, mitigar as emissões de CO₂ₑ também tem um custo. Em MARGO, o custo *marginal* de mitigação é proporcional à fração das emissões de CO₂ₑ que foram mitigadas em um determinado ano, aumentando até um máximo de $70 por tonelada métrica de CO₂ₑ a 100% de mitigação.

                Isso naturalmente leva a uma **análise de custo-benefício**. Procuramos o cenário mais benéfico ou *ideal*: aquele que possui os *benefícios atuais líquidos máximos*. Na figura abaixo, tente encontrar uma estratégia de mitigação que otimize esses _benefícios líquidos_.

                """
    ]; wraparound=false)

# ╔═╡ 11d62228-476c-4616-9e7d-de6c05a6a53d
if cost_benefits_narrative_slide == 1
    hidecloack("cost_benefits_narrative_input")
end

# ╔═╡ 4c7fccc5-450c-4903-96a6-ce36ff60d280
md"""
## Pegando o excesso: remoção de dióxido de carbono

Embora mitigações substanciais de emissões sejam necessárias para reduzir o sofrimento climático futuro, elas não podem compensar as centenas de bilhões de toneladas de CO₂ que os humanos já emitiram. No entanto, existem métodos naturais e tecnológicos para remover o CO₂ da atmosfera. Embora atualmente sejam minúsculos em comparação com a escala de dezenas de gigatoneladas das emissões globais, os especialistas acreditam que desempenharão um papel fundamental no futuro. O MARGO, não faz distinção entre os diferentes métodos de remoção de dióxido de carbono e, além disso, assume que o carbono é armazenado permanentemente.

*Arraste o ponto amarelo na figura abaixo para modificar a quantidade e o tempo de remoção do dióxido de carbono*. 
"""

# ╔═╡ b2d65726-df99-4710-9d03-9f6838036c87
md"""
## Otimização automatizada do MARGO

No exemplo acima, *você* ajustou manualmente o tempo e a quantidade de mitigação e remoção de dióxido de carbono, mas não teve muito controle sobre o formato das curvas. Usando um algoritmo de computador, podemos fazer esta etapa de otimização *automaticamente* e *mais rápido*, sem ter que assumir nada sobre a forma das curvas de mitigação e remoção de dióxido de carbono.
"""

# ╔═╡ a0a1bb20-ec9b-446d-a36a-272840b8d35c
blob(
    md"""
    #### Maximum temperature

    `0.0 °C` $(Tmax_9_slider) `5.0 °C`

    _Allow **temperature overshoot**:_ $(allow_overshoot_9_cb)
    """,
    "#c5710014"
)

# ╔═╡ 44ad72e3-efb7-48a3-bfd7-593312f4fd30
blob(md"Maximum allowed temperature increase = $Tmax_9.", "#c5710014")

# ╔═╡ 64c9f002-3d5d-4f14-b39a-980738fd824d
md"""
# Apêndice
"""

# ╔═╡ 14623e1f-7719-47b1-8854-8070d5ef8e17
md"""
## Funções para gráficos
"""

# ╔═╡ a9b1e7fa-0318-41d8-b720-b8615c047bcd
plot_controls(c::ClimateMARGO.Models.Controls) = plot_controls(MRGA(
    c.mitigate,
    c.remove,
    c.geoeng,
    c.adapt
))

# ╔═╡ d9d20714-0689-449f-8e52-603dc804c93f
yearticks = collect(2020:20:2200)

# ╔═╡ cabc3214-1036-433b-aae1-6964bb780be8
function finish!(p)
    plot!(p;
        xlim=(2020, 2201),
        xticks=yearticks,
        size=(680, 200),
        grid=false
    )
end

# ╔═╡ 2fec1e12-0218-4e93-a6b5-3711e6910d79
function plot_costs(result::ClimateModel;
    show_baseline::Bool=true,
    show_controls::Bool=true,
    show_damages::Bool=true,
    title="Control costs & climate damages"
)

    p = plot(;
        ylim=(0, 6.1),
        ylabel="trillion USD / year"
    )
    title === nothing || plot!(p; title=title)


    # baseline
    show_baseline && plot!(p,
        years, damage(result; discounting=true);
        pp.baseline_damages...,
        fillrange=zero(years),
        fillopacity=0.2,
        linestyle=:dash
    )

    # control costs
    controlled_damages = damage(result; M=true, R=true, G=true, A=true, discounting=true)

    show_controls && plot!(p,
        years, controlled_damages .+ cost(result; M=true, R=true, G=true, A=true, discounting=true);
        fillrange=controlled_damages,
        fillopacity=0.2,
        pp.controls...
    )


    # controlled damages
    show_damages && plot!(p,
        years, controlled_damages;
        fillrange=zero(years),
        fillopacity=0.2,
        pp.damages...
    )

    finish!(p)

end

# ╔═╡ cff9f952-4850-4d55-bb8d-c0a759d1b7d8
function plot_concentrations(result::ClimateModel;
    relative_to_preindustrial::Bool=true)
    Tmax = 5
    p = relative_to_preindustrial ? plot(;
        ylim=(0, 4.5),
        yticks=[1, 2, 3, 4],
        yformatter=x -> string(Int(x), "×"),
        title="Atmospheric CO₂ₑ concentration, relative to 1800-1850"
    ) : plot(;
        ylim=(0, 1400),
        ylabel="ppm",
        title="Atmospheric CO₂ₑ concentration"
    )

    factor = relative_to_preindustrial ? preindustrial_concentrations : 1

    # baseline
    plot!(p,
        years, c(result) ./ factor;
        pp.baseline_concentrations...,
        linestyle=:dash
    )
    # controlled temperature
    plot!(p,
        years, c(result; M=true, R=true) ./ factor;
        pp.concentrations...
    )


    finish!(p)
end

# ╔═╡ c73c89a7-f652-4554-95e9-20f47a818996
function plot_controls(controls::MRGA; title=nothing)

    p = plot(;
        ylim=(0, 1)
    )
    title === nothing || plot!(p; title=title)

    for (tech, c) in enumerate(controls)
        if c !== nothing
            which = tech === :M ? (years .< end_of_oil) : eachindex(years)

            plot!(p,
                years[which], c[which];
                pp[tech]...
            )
        end
    end

    finish!(p)

end

# ╔═╡ 6634bcf1-8af6-4000-9b00-a5b4c02596c6
function plot_emissions(result::ClimateModel)

    p = plot(;
        ylim=(-3, 11),
        ylabel="ppm / year",
        title="Global CO₂ₑ emissions"
    )




    # baseline
    plot!(p,
        years, effective_emissions(result);
        pp.baseline_emissions...,
        linestyle=:dash
    )
    # controlled
    plot!(p,
        years, effective_emissions(result; M=true, R=true);
        fillrange=zero(years),
        fillopacity=0.2,
        pp.emissions...
    )


    finish!(p)

end

# ╔═╡ 424940e1-06ef-453a-8ffb-deb24dadb334
function plot_emissions_pretty(result::ClimateModel)
    # offset the x values so that framestyle=:origin will make the y-axis pass through 2020 instead of 0. yuck
    R = x -> x + 2020
    L = x -> x - 2020

    Tmax = 5
    p = plot(;
        ylim=(-3, 11),
        ylabel="ppm / year",
        framestyle=:origin,
        xformatter=string ∘ Int ∘ R
    )




    # baseline
    plot!(p,
        L.(years), effective_emissions(result);
        pp.baseline_emissions...,
        linestyle=:dash
    )
    # controlled temperature
    plot!(p,
        L.(years), effective_emissions(result; M=true, R=true);
        fillrange=zero(L.(years)),
        fillopacity=0.2,
        pp.emissions...
    )


    finish!(p)

    plot!(p;
        xlim=L.(extrema(years)),
        xticks=L.(yearticks)
    )
end

# ╔═╡ 700f982d-85da-4dc1-9319-f3b2527d0308
function plot_temp(result::ClimateModel)
    Tmax = 5

    # setup
    p = plot(;
        ylim=(0, Tmax),
        yticks=[0, 1, 2, 3],
        yformatter=x -> string("+", Int(x), " °C"),
        title="Global warming relative to 1800-1850"
    )

    # shade dangerously high temperatures
    for a in [2, 3]
        plot!(p,
            collect(extrema(years)),
            [a, a],
            linewidth=0,
            label=nothing,
            fillrange=[Tmax, Tmax],
            fillcolor=colors.above_paris
        )
    end

    # baseline
    plot!(p,
        years, T_adapt(result; splat(MRGA(false))...);
        pp.baseline_temperature...,
        linestyle=:dash
    )
    # controlled temperature
    plot!(p,
        years, T_adapt(result; splat(MRGA(true))...);
        pp.temperature...
    )


    finish!(p)
end

# ╔═╡ ab557633-e0b5-4439-bc81-d274770f2e65
md"""
## "Mágica" para pegar informações com pontos em gráficos
"""

# ╔═╡ 2758b185-cd54-484e-bb7d-d4cfcd2d39f4
md"""
## Executando o modelo
"""

# ╔═╡ 611c25ab-a454-4d52-b8fb-a58b0d1f5ca6
function forward_controls_temp(controls::MRGA=MRGA(), model_parameters=default_parameters())


    model = ClimateModel(model_parameters)

    translations = Dict(
        :M => :mitigate,
        :R => :remove,
        :G => :geoeng,
        :A => :adapt,
    )
    for (k, v) in enumerate(controls)
        if v !== nothing
            setfieldconvert!(model.controls, translations[Symbol(k)], copy(v))
        end
    end

    enforce_maxslope!(model.controls)

    model
    # return Dict(
    #     :model_parameters => model_parameters,
    #     model_results(model)...
    # )
end

# ╔═╡ 9aa73ce0-cec6-4d53-bbbc-f5c85de7b521
@initially initial_1 @bind input_1 begin

    local t = input_1["M"][1]
    local y = input_1["M"][2]

    controls_1 = MRGA(
        M=gaussish(t, clamp(0.07 * (10 - y), 0, 1)),
        R=gaussish(t, clamp(0.07 * (10 - y) * 0.25, 0, 1)),
    )

    result_1 = forward_controls_temp(controls_1)

    plotclicktracker2(
        plot_emissions(result_1),
        initial_1
    )
end

# ╔═╡ 65d31fbf-322d-459a-a2dd-2894edbecc4d
plot_temp(result_1)

# ╔═╡ ff2b1c0a-e419-4f41-aa3b-d017642ffc13
@initially initial_2 @bind input_2 begin


    controls_2 = MRGA(
        M=gaussish(input_2["M"]...),
    )

    result_2 = forward_controls_temp(controls_2)

    plotclicktracker2(
        plot_controls(controls_2; title="Deployment of mitigation"),
        initial_2
    )
end

# ╔═╡ 02851ee9-8050-4821-b3c9-1f65c9b8135b
if which_graph_2 == "Emissions"
    plot_emissions(result_2)
elseif which_graph_2 == "Concentrations"
    plot_concentrations(result_2; relative_to_preindustrial=true)
else
    plot_temp(result_2)
end

# ╔═╡ f4203dcf-b251-4e2b-be07-922bc7c4496d
(@initially initial_3 @bind input_3 begin


    controls_3 = MRGA(
        M=gaussish(input_3["M"]...),
    )

    result_3 = forward_controls_temp(controls_3)

    plotclicktracker2(
        plot_controls(controls_3; title="Deployment of mitigation"),
        initial_3
    )
end) |> cloak("cost_benefits_narrative_input")

# ╔═╡ 3e26d311-6abc-4b2c-ada4-f8a3171d9f75
if cost_benefits_narrative_slide == 1
    local uncontrolled = ClimateModel(default_parameters())
    plot_costs(uncontrolled; show_controls=false, show_baseline=false)
elseif cost_benefits_narrative_slide == 2
    plot_costs(result_3; show_controls=false)
else
    plot_costs(result_3)
end

# ╔═╡ aac86adf-465f-464f-b258-406c2e55b82f
@initially initial_4 @bind input_4 begin


    controls_4 = MRGA(
        M=gaussish(input_4["M"]...),
        R=gaussish(input_4["R"]...),
    )

    result_4 = forward_controls_temp(controls_4)

    plotclicktracker2(
        plot_controls(controls_4; title="Deployment of mitigation"),
        initial_4
    )
end

# ╔═╡ a751fb75-952e-41d4-a8b5-aba512c10e55
if which_graph_4 == "Emissions"
    plot_emissions(result_4)
elseif which_graph_4 == "Concentrations"
    plot_concentrations(result_4; relative_to_preindustrial=true)
elseif which_graph_4 == "Temperature"
    plot_temp(result_4)
else
    plot_costs(result_4)
end

# ╔═╡ 89752d91-9c8e-4203-b6f1-bdad41386b31
shortname = MRGA("M", "R", "G", "A")

# ╔═╡ ff2709a4-516f-4066-b5b2-617ac0e5f20c
mediumname = MRGA("mitigate", "remove", "geoeng", "adapt")

# ╔═╡ 2821b722-75c2-4072-b142-d13553a84b7b
longname = MRGA("Mitigation", "Removal", "Geo-engineering", "Adaptation")

# ╔═╡ 8e89f521-c19d-4f87-9497-f9b61c19c176
let
    default_cost = let
        e = default_parameters().economics
        MRGA(e.mitigate_cost, e.remove_cost, e.geoeng_cost, e.adapt_cost)
    end
    blob(
        @htl("""
       <h4>Which controls?</h4>

       <style>

       .controltable thead th,
       .controltable tbody td {
         text-align: center;
       }

       .controltable input[type=range] {
         width: 10em;
       }

       </style>

       <table class="controltable">
       <thead>
       <th></th><th>Enabled?</th><th style="text-align: center;">Cost multiplier</th>
       </thead>
       <tbody>

       	<tr>
       	<th>$(longname.M)</th>
       	<td>$(@bind enable_M_9 CheckBox(;default=true))</td>
       	<td>$(@bind cost_M_9 multiplier(default_cost.M, 4))</td>
       	</tr>
       	
       	<tr>
       	<th>$(longname.R)</th>
       	<td>$(@bind enable_R_9 CheckBox(;default=true))</td>
       	<td>$(@bind cost_R_9 multiplier(default_cost.R, 4))</td>
       	</tr>
       	
       	<tr>
       	<th>$(longname.G)</th>
       	<td>$(@bind enable_G_9 CheckBox(;default=false))</td>
       	<td>$(@bind cost_G_9 multiplier(default_cost.G, 4))</td>
       	</tr>
       	
       	<tr>
       	<th>$(longname.A)</th>
       	<td>$(@bind enable_A_9 CheckBox(;default=false))</td>
       	<td>$(@bind cost_A_9 multiplier(default_cost.A, 4))</td>
       	</tr>
       	
       </tbody>
       </table>
       	"""),
        "#c500b40a"
    )
end

# ╔═╡ a83e47fa-4b48-4bbc-b210-382d1cf19f55
control_enabled_9 = MRGA(
    enable_M_9,
    enable_R_9,
    enable_G_9,
    enable_A_9,
)

# ╔═╡ 242f3109-244b-4884-a0e9-6ea8950ca47e
control_cost_9 = MRGA(
    Float64(cost_M_9),
    Float64(cost_R_9),
    Float64(cost_G_9),
    Float64(cost_A_9),
)

# ╔═╡ f861935a-8b03-426e-aebe-6963e034ad49
output_9 = let
    parameters = default_parameters()

    parameters.economics.mitigate_cost = control_cost_9.M
    parameters.economics.remove_cost = control_cost_9.R
    parameters.economics.geoeng_cost = control_cost_9.G
    parameters.economics.adapt_cost = control_cost_9.A

    # modify the parameters here!

    opt_controls_temp(parameters;
        temp_overshoot=allow_overshoot_9 ? 999.0 : Tmax_9,
        temp_goal=Tmax_9,
        max_deployment=let
            e = control_enabled_9
            Dict(
                "mitigate" => e.M ? 1.0 : 0.0,
                "remove" => e.R ? 1.0 : 0.0,
                "geoeng" => e.G ? 1.0 : 0.0,
                "adapt" => e.A ? 0.4 : 0.0,
            )
        end
    )
end

# ╔═╡ 6978acad-9cac-4490-85fb-7e43d9558aca
plot_controls(output_9.result.controls) |> feasibility_overlay(output_9)

# ╔═╡ 7a435e46-4f36-4037-a9a6-d296b20bf6ac
plot!(plot_temp(output_9.result),
    years, zero(years) .+ Tmax_9;
    lw=2,
    pp.T_max...
)

# ╔═╡ 7ffad0f8-082b-4ca1-84f7-37c08d5f7266
md"""
## Barras de custos
"""

# ╔═╡ 608b50e7-4419-4dfb-8d9e-5144d4034c05
function avoided_damages_bars(result)
    td(x) = total_discounted(x, result)

    baseline_damages = td(damage(result; discounting=true))
    controlled_damages = td(damage(result; splat(MRGA(true))..., discounting=true))

    avoided_damages = baseline_damages - controlled_damages

    costs = td(cost(result; splat(MRGA(true))..., discounting=true))

    @htl("""
   		
   		<script>
   		
   		const colors = $(colors_js)
   		const names = $(names_js)
   		
     const baseline_damages = $(baseline_damages);
     const controlled_damages = $(controlled_damages);
     const avoided_damages = $(avoided_damages);

     const costs = $(costs);

     const scale = 16.0;


     const bar = (offset, width, color) =>
       html`<span style="margin-left: \${offset}%; width: \${width}%; opacity: .7; display: inline-block; background: \${color}; height: 1.2em; margin-bottom: -.2em;"></span>`;

     return html`
      <div>
   \${bar(0, controlled_damages / scale, colors.damages)}
   <span style="opacity: .6;">Controlled damages: <b>\${Math.ceil(
       controlled_damages
     )} trillion USD</b>.
     </div>

   <div style="border-bottom: 2px solid #eee; margin-bottom: 4px;">
     \${bar(0, baseline_damages / scale, colors.baseline)}
     <span style="opacity: .6;">Baseline damages: <b>\${Math.ceil(
       baseline_damages
     )} trillion USD</b>.</span>
   </div>
   <div style="font-style: italic;">
   \${bar(
     controlled_damages / scale,
     avoided_damages / scale,
     colors.avoided_damages
   )}
   <span>Avoided damages: <b>\${Math.ceil(avoided_damages)} trillion USD</b>.</span>
   </div>
   `;

   	</script>
   		""")
end

# ╔═╡ 2c1416cf-9b6b-40a0-b714-16853c7e1f1d
if cost_benefits_narrative_slide >= 2
    avoided_damages_bars(result_3)
end

# ╔═╡ df1060d4-3aa6-4eea-bd9a-0f9f95d95a67
avoided_damages_bars(output_9.result)

# ╔═╡ 31a30755-1d8b-451b-8c9a-2c32a3a1d0b4
function cost_bars(result; offset_damages=false)
    td(x) = total_discounted(x, result)

    baseline_damages = td(damage(result; discounting=true))
    controlled_damages = td(damage(result; splat(MRGA(true))..., discounting=true))

    avoided_damages = baseline_damages - controlled_damages

    costs = td(cost(result; splat(MRGA(true))..., discounting=true))

    @htl("""
   		
   		<script>
   		
   		const colors = $(colors_js)
   		const names = $(names_js)
   		
     const baseline_damages = $(baseline_damages);
     const controlled_damages = $(controlled_damages);
     const avoided_damages = $(avoided_damages);

     const costs = $(costs);

     const scale = 16.0;

     const bar = (offset, width, color) =>
       html`<span style="margin-left: \${offset}%; width: \${width}%; opacity: .7; display: inline-block; background: \${color}; height: 1.2em; margin-bottom: -.2em;"></span>`;

     //   <div>
     // \${bar(0, baseline_damages / scale, colors.baseline)}
     // Baseline damages: <b>\${Math.ceil(baseline_damages)} trillion USD</b>.
     // </div>

     const extra_offset = $(offset_damages) ? controlled_damages / scale : 0;

     return html`

   <div>
   \${bar(extra_offset, costs / scale, colors.controls)}
   <span  style="opacity: .6;">Control costs: <b>\${Math.ceil(
       costs
     )} trillion USD</b>.</span>
   </div>
   <div style="border-bottom: 2px solid #eee; margin-bottom: 4px;">
   \${bar(extra_offset, avoided_damages / scale, colors.avoided_damages)}
   <span style="opacity: .6;">Avoided damages: <b>\${Math.ceil(
       avoided_damages
     )} trillion USD</b>.</span>
   </div>
   <div style="font-style: italic;" title="Net benefits: Avoided damages minus the cost of getting there.">
   \${bar(
     extra_offset + costs / scale,
     (avoided_damages - costs) / scale,
     colors.benefits
   )}
   <span>Net benefits: <b>\${Math.ceil(
       avoided_damages - costs
     )} trillion USD</b>.</span>
   </div>`;

   	</script>
   		""")
end

# ╔═╡ 470d2f6f-fe97-4edd-8aaa-142bc8046fe8
cost_bars(result_1)

# ╔═╡ 5154aac7-812d-447f-8435-b8209d45fe04
if cost_benefits_narrative_slide >= 3
    cost_bars(result_3; offset_damages=true)
else
    bigbreak
end

# ╔═╡ 0cbf23b9-78da-4cf8-b03a-d25b2fcd01a0
cost_bars(output_9.result; offset_damages=true)

# ╔═╡ 7f9df132-61de-4fec-a674-176c4a43335c
md"""
## Estrutura MRGA 
"""

# ╔═╡ 354b9d8a-7c3f-456b-9da9-4396ac975743
function MR(x::T, y::T) where {T}
    MRGA{T}(x, y, zero(x), zero(x))
end

# ╔═╡ Cell order:
# ╟─f957229f-5e48-458d-bbbc-1efc1356d704
# ╟─9a48a08e-7281-473c-8afc-7ad3e0771269
# ╟─331c45b7-b5f2-4a78-b180-5b918d1806ee
# ╠═9aa73ce0-cec6-4d53-bbbc-f5c85de7b521
# ╟─65d31fbf-322d-459a-a2dd-2894edbecc4d
# ╟─470d2f6f-fe97-4edd-8aaa-142bc8046fe8
# ╟─94415ff2-32a2-4b0f-9911-3b93e202f548
# ╟─eb7f34c3-1cd9-411d-8f34-d8547ba6ac29
# ╟─7553b243-226c-457c-9532-1297f1e8d869
# ╟─6533c123-34fe-4c0d-9ecc-7fef11379253
# ╟─50d24c91-61ae-4544-98fa-5749bafe3d41
# ╟─cf5f7459-fbbe-4595-baa4-b6b85017005a
# ╟─ec325089-8418-4fed-ac0e-e8ae21b433ab
# ╟─ff2b1c0a-e419-4f41-aa3b-d017642ffc13
# ╟─29aa932b-9835-4d13-84e2-5ccf380a21ea
# ╟─02851ee9-8050-4821-b3c9-1f65c9b8135b
# ╟─d796cb71-0e34-41ce-bc97-45c68812046d
# ╟─e810a90f-f964-4d7d-acdb-fc3a159dc12e
# ╟─30218715-6469-4a0f-bf90-f3243219e7b5
# ╟─8433cb38-915a-46c1-b3db-8e7905351c1b
# ╟─3e26d311-6abc-4b2c-ada4-f8a3171d9f75
# ╟─f4203dcf-b251-4e2b-be07-922bc7c4496d
# ╟─2c1416cf-9b6b-40a0-b714-16853c7e1f1d
# ╟─5154aac7-812d-447f-8435-b8209d45fe04
# ╟─11d62228-476c-4616-9e7d-de6c05a6a53d
# ╟─a3422533-2b78-4bc2-92bd-737da3c8982d
# ╟─4c7fccc5-450c-4903-96a6-ce36ff60d280
# ╟─aac86adf-465f-464f-b258-406c2e55b82f
# ╟─9d603716-3069-4032-9416-cd8ab2e272c6
# ╟─a751fb75-952e-41d4-a8b5-aba512c10e55
# ╟─6ca2a32a-51de-4ff4-8023-843396f970ec
# ╟─bb66d347-99be-4a95-8ba8-57dc9d33384b
# ╟─b2d65726-df99-4710-9d03-9f6838036c87
# ╟─70173466-c9b5-4227-8fba-6256fc1ecace
# ╟─6bcb9b9e-e0ab-45d3-b9b9-3d7282f89df6
# ╟─a0a1bb20-ec9b-446d-a36a-272840b8d35c
# ╟─44ad72e3-efb7-48a3-bfd7-593312f4fd30
# ╟─8e89f521-c19d-4f87-9497-f9b61c19c176
# ╟─a83e47fa-4b48-4bbc-b210-382d1cf19f55
# ╟─242f3109-244b-4884-a0e9-6ea8950ca47e
# ╟─6978acad-9cac-4490-85fb-7e43d9558aca
# ╟─7a435e46-4f36-4037-a9a6-d296b20bf6ac
# ╟─df1060d4-3aa6-4eea-bd9a-0f9f95d95a67
# ╠═0cbf23b9-78da-4cf8-b03a-d25b2fcd01a0
# ╟─f861935a-8b03-426e-aebe-6963e034ad49
# ╠═8311d458-a1bb-484c-86e7-5a671d36f94d
# ╟─64c9f002-3d5d-4f14-b39a-980738fd824d
# ╠═1c8d2d00-b7d9-11eb-35c4-47f2a2aa1593
# ╟─3094a9eb-074d-46c3-9c1e-0a9c94c6ad43
# ╟─b428e2d3-e1a9-4e4e-a64f-61048572102f
# ╟─0b31eac2-8efd-47cd-9571-a2053846343b
# ╟─ca104939-a6ca-4e70-a47a-1eb3c32db18f
# ╟─cf90139c-13d8-42a7-aba3-8c431e7854b8
# ╟─bd2bfa3c-a42e-4975-a543-84541f66b1c1
# ╟─8cab3d28-a457-4ccc-b053-38cd003bf4d1
# ╟─b81de514-2506-4243-8235-0b54dd4a7ec9
# ╟─73e01bd8-f56b-4bb5-a9a2-85ad223c9e9b
# ╟─ae92ba1f-5175-4704-8240-2de8432df752
# ╟─8ac04d55-9034-4c29-879b-3b10887a616d
# ╟─14623e1f-7719-47b1-8854-8070d5ef8e17
# ╠═2fec1e12-0218-4e93-a6b5-3711e6910d79
# ╟─cff9f952-4850-4d55-bb8d-c0a759d1b7d8
# ╟─c73c89a7-f652-4554-95e9-20f47a818996
# ╟─a9b1e7fa-0318-41d8-b720-b8615c047bcd
# ╟─6634bcf1-8af6-4000-9b00-a5b4c02596c6
# ╟─424940e1-06ef-453a-8ffb-deb24dadb334
# ╟─700f982d-85da-4dc1-9319-f3b2527d0308
# ╟─cabc3214-1036-433b-aae1-6964bb780be8
# ╟─d9d20714-0689-449f-8e52-603dc804c93f
# ╟─c7cbc172-daed-406f-b24b-5da2cc234c29
# ╟─b440cd13-36a9-4c54-9d80-ac3fa7c2900e
# ╟─ec760706-15ac-4a50-a67e-c338d70f3b0a
# ╟─ab557633-e0b5-4439-bc81-d274770f2e65
# ╟─bb4b25e4-0db5-414b-a384-0a27fe7efb66
# ╟─646591c4-cb60-41cd-beb9-506807ce17d2
# ╟─5c484595-4646-484f-9e75-a4a3b4c2af9b
# ╟─013807a0-bddb-448b-9300-f7f559e48a45
# ╟─4e91fb48-fc5e-409e-9a7e-bf846f1d211d
# ╟─3c7271ab-ece5-4ae2-a8dd-dc3670f300f7
# ╟─dcf265c1-f09b-483e-a361-d54c6c7500c1
# ╟─10c015ec-780c-4453-83cb-12dd0f09f358
# ╟─2758b185-cd54-484e-bb7d-d4cfcd2d39f4
# ╟─8fa94ec9-1fab-41b9-a7e6-1917e975e4ff
# ╟─611c25ab-a454-4d52-b8fb-a58b0d1f5ca6
# ╟─785c428d-d4f7-431e-94d7-039b0708a78a
# ╟─7e540eaf-8700-4176-a96c-77ee2e4c384b
# ╠═254ce01c-7976-4fe8-a980-fea1a61d7406
# ╟─89752d91-9c8e-4203-b6f1-bdad41386b31
# ╟─ff2709a4-516f-4066-b5b2-617ac0e5f20c
# ╟─2821b722-75c2-4072-b142-d13553a84b7b
# ╟─2dcd5669-c725-40b9-84c4-f8399f6e924b
# ╟─b8f9efec-63ac-4e58-93cf-9f7199b78451
# ╟─371991c7-13dd-46f6-a730-ad89f43c6f0e
# ╟─0a3be2ea-6af6-43c0-b8fb-e453bc2b703b
# ╟─b7ca316b-6fa6-4c2e-b43b-cddb08aaabbb
# ╟─7ffad0f8-082b-4ca1-84f7-37c08d5f7266
# ╟─608b50e7-4419-4dfb-8d9e-5144d4034c05
# ╟─31a30755-1d8b-451b-8c9a-2c32a3a1d0b4
# ╟─ec5d87a6-354b-4f1d-bb73-b3db08589d9b
# ╠═70f01a4d-0aa3-4cd5-ad71-452c490c61ac
# ╠═ac779b93-e19e-41de-94cb-6a2a919bcd2e
# ╟─7f9df132-61de-4fec-a674-176c4a43335c
# ╟─060cbeab-5503-4eda-95d8-3f554765b2ee
# ╟─354b9d8a-7c3f-456b-9da9-4396ac975743
