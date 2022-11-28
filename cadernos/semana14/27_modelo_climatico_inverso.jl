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

# ╔═╡ 1c8d2d00-b7d9-11eb-35c4-47f2a2aa1593
begin
    ENV["JULIA_MARGO_LOAD_PYPLOT"] = "no thank you"
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

As emissões humanas de gases de efeito estufa, principalmente Dióxido de Carbono (CO₂), aumentam seu estoque na atmosfera. Para cada molécula de CO₂ emitida, cerca de 50% são absorvidos pelas plantas, solos ou oceano em poucos anos. O restante permanece na atmosfera. (Os efeitos de outros gases de efeito estufa, como metano e CFCs, e outros agentes forçantes, podem ser convertidos, aproximadamente, no "equivalente de CO₂" - ou concentrações de CO₂ₑ que levariam ao mesmo efeito climático).

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

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ClimateMARGO = "d3f62095-a717-45bf-aadc-ac9dfc258fa6"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Underscores = "d9a01c3f-67ce-4d8c-9b55-35f6e4050bb1"

[compat]
ClimateMARGO = "~0.3.3"
HypertextLiteral = "~0.9.4"
Plots = "~1.36.6"
PlutoUI = "~0.7.48"
Underscores = "~3.0.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "7b8b5dda92fd86f4e27e790c6b8b58b29ab3e48d"

[[deps.ASL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6252039f98492252f9e47c312c8ffda0e3b9e78d"
uuid = "ae81ac8f-d209-56e5-92de-9978fef736f9"
version = "0.1.3+0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "d9a9701b899b30332bbcb3e1679c41cce81fb0e8"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.2"

[[deps.BinDeps]]
deps = ["Libdl", "Pkg", "SHA", "URIParser", "Unicode"]
git-tree-sha1 = "1289b57e8cf019aede076edab0587eb9644175bd"
uuid = "9e28174c-4ba2-5203-b857-d8d62c4213ee"
version = "1.0.2"

[[deps.BinaryProvider]]
deps = ["Libdl", "Logging", "SHA"]
git-tree-sha1 = "ecdec412a9abc8db54c0efc5548c64dfce072058"
uuid = "b99e7846-7c00-51b0-8f62-c81ae34c0232"
version = "0.5.10"

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

[[deps.ClimateMARGO]]
deps = ["CompilerSupportLibraries_jll", "DiffResults", "DiffRules", "ForwardDiff", "Ipopt", "JSON2", "JuMP", "PyPlot", "Revise"]
git-tree-sha1 = "f958c49f3f4f812d6eb2725f102896a0ead72172"
uuid = "d3f62095-a717-45bf-aadc-ac9dfc258fa6"
version = "0.3.3"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "cc4bd91eba9cdbbb4df4746124c22c0832a460d6"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.1.1"

[[deps.CodecBzip2]]
deps = ["Bzip2_jll", "Libdl", "TranscodingStreams"]
git-tree-sha1 = "2e62a725210ce3c3c2e1a3080190e7ca491f18d7"
uuid = "523fee87-0ab8-5b00-afb7-3ecf72e48cfd"
version = "0.7.2"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random", "SnoopPrecompile"]
git-tree-sha1 = "aa3edc8f8dea6cbfa176ee12f7c2fc82f0608ed3"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.20.0"

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

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "aaabba4ce1b7f8a9b34c015053d3b1edf60fa49c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.4.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Conda]]
deps = ["Downloads", "JSON", "VersionParsing"]
git-tree-sha1 = "6e47d11ea2776bc5627421d59cdcc1296c058071"
uuid = "8f4d0f93-b110-5947-807f-2305c1781a2d"
version = "1.7.0"

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

[[deps.DiffResults]]
deps = ["StaticArrays"]
git-tree-sha1 = "da24935df8e0c6cf28de340b958f6aac88eaa0cc"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.0.2"

[[deps.DiffRules]]
deps = ["NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "eb0c34204c8410888844ada5359ac8b96292cfd1"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.0.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

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

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "NaNMath", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "1d090099fb82223abc48f7ce176d3f7696ede36d"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.12"

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
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "051072ff2accc6e0e87b708ddee39b18aa04a0bc"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.71.1"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "501a4bf76fd679e7fcd678725d5072177392e756"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.71.1+0"

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

[[deps.Ipopt]]
deps = ["Ipopt_jll", "MathOptInterface"]
git-tree-sha1 = "14a305ededd75330246aaa0380130561d8924120"
uuid = "b6b21f68-93f8-5de0-b562-5493be1d77c9"
version = "1.1.0"

[[deps.Ipopt_jll]]
deps = ["ASL_jll", "Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "MUMPS_seq_jll", "OpenBLAS32_jll", "Pkg"]
git-tree-sha1 = "e3e202237d93f18856b6ff1016166b0f172a49a8"
uuid = "9cc047cb-c261-5740-88fc-0cf96f7bdcc7"
version = "300.1400.400+0"

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

[[deps.JSON2]]
deps = ["Dates", "Parsers", "Test"]
git-tree-sha1 = "dcc3c2d9bdc036677a031ea97b76925983ca1f18"
uuid = "2535ab7d-5cd8-5a07-80ac-9b1792aadce3"
version = "0.3.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.JuMP]]
deps = ["LinearAlgebra", "MathOptInterface", "MutableArithmetics", "OrderedCollections", "Printf", "SparseArrays"]
git-tree-sha1 = "9a57156b97ed7821493c9c0a65f5b72710b38cf7"
uuid = "4076af6c-e467-56ae-b986-b466b2749572"
version = "1.4.0"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "a79c4cf60cc7ddcdcc70acbb7216a5f9b4f8d188"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.16"

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
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

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

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "dedbebe234e06e1ddad435f5c6f4b85cd8ce55f7"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "2.2.2"

[[deps.METIS_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "1fd0a97409e418b78c53fac671cf4622efdf0f21"
uuid = "d00139f3-1899-568f-a2f0-47f597d42d70"
version = "5.1.2+0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MUMPS_seq_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "METIS_jll", "OpenBLAS32_jll", "Pkg"]
git-tree-sha1 = "29de2841fa5aefe615dea179fcde48bb87b58f57"
uuid = "d7ed1dd3-d0ae-5e8e-bfb4-87a502085b8d"
version = "5.4.1+0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MathOptInterface]]
deps = ["BenchmarkTools", "CodecBzip2", "CodecZlib", "DataStructures", "ForwardDiff", "JSON", "LinearAlgebra", "MutableArithmetics", "NaNMath", "OrderedCollections", "Printf", "SparseArrays", "SpecialFunctions", "Test", "Unicode"]
git-tree-sha1 = "192e86391e40d8006ef821a04403faa762e84ed4"
uuid = "b8f27783-ece8-5eb3-8dc8-9495eed66fee"
version = "1.10.0"

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

[[deps.MutableArithmetics]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "aa532179d4a643d4bd9f328589ca01fa20a0d197"
uuid = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"
version = "1.1.0"

[[deps.NaNMath]]
git-tree-sha1 = "b086b7ea07f8e38cf122f5016af580881ac914fe"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.7"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS32_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c6c2ed4b7acd2137b878eb96c68e63b76199d0f"
uuid = "656ef2d0-ae68-5445-9ca0-591084a874a2"
version = "0.3.17+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

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
git-tree-sha1 = "6a9521b955b816aa500462951aa67f3e4467248a"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.36.6"

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

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.PyCall]]
deps = ["Conda", "Dates", "Libdl", "LinearAlgebra", "MacroTools", "Serialization", "VersionParsing"]
git-tree-sha1 = "53b8b07b721b77144a0fbbbc2675222ebf40a02d"
uuid = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
version = "1.94.1"

[[deps.PyPlot]]
deps = ["Colors", "LaTeXStrings", "PyCall", "Sockets", "Test", "VersionParsing"]
git-tree-sha1 = "f9d953684d4d21e947cb6d642db18853d43cb027"
uuid = "d330b81b-6aea-500a-939a-2ce795aea3ee"
version = "2.11.0"

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

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "dad726963ecea2d8a81e26286f625aee09a91b7c"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.4.0"

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
deps = ["BinDeps", "BinaryProvider", "Libdl"]
git-tree-sha1 = "3bdd374b6fd78faf0119b8c5d538788dbf910c6e"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "0.8.0"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "da4cf579416c81994afd6322365d00916c79b8ae"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "0.12.5"

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

[[deps.URIParser]]
deps = ["Unicode"]
git-tree-sha1 = "53a9f49546b8d2dd2e688d216421d050c9a31d0d"
uuid = "30578b45-9adc-5946-b283-645ec420af67"
version = "0.4.1"

[[deps.URIs]]
git-tree-sha1 = "ac00576f90d8a259f2c9d823e91d1de3fd44d348"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Underscores]]
git-tree-sha1 = "6e6de5a5e7116dcff8effc99f6f55230c61f6862"
uuid = "d9a01c3f-67ce-4d8c-9b55-35f6e4050bb1"
version = "3.0.0"

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

[[deps.VersionParsing]]
git-tree-sha1 = "58d6e80b4ee071f5efd07fda82cb9fbe17200868"
uuid = "81def892-9a0e-5fdd-b105-ffc91e053289"
version = "1.3.0"

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
# ╟─f957229f-5e48-458d-bbbc-1efc1356d704
# ╠═1c8d2d00-b7d9-11eb-35c4-47f2a2aa1593
# ╟─9a48a08e-7281-473c-8afc-7ad3e0771269
# ╟─331c45b7-b5f2-4a78-b180-5b918d1806ee
# ╟─9aa73ce0-cec6-4d53-bbbc-f5c85de7b521
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
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
