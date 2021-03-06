__precompile__()

module PlotlyJS

using Compat; import Compat: String, readstring, view
using JSON
using Colors
using DocStringExtensions

# import LaTeXStrings and export the handy macros
using LaTeXStrings
export @L_mstr, @L_str

# export some names from JSON
export json

# globals for this package
const _js_path = joinpath(dirname(dirname(@__FILE__)),
                          "deps", "plotly-latest.min.js")
const _js_cdn_path = "https://cdn.plot.ly/plotly-latest.min.js"
const _mathjax_cdn_path = "https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_SVG"

const _autoresize = [true]
autoresize(b::Bool) = (_autoresize[1] = b; b)
autoresize() = _autoresize[1]

_isijulia() = isdefined(Main, :IJulia) && Main.IJulia.inited

# include these here because they are used below
include("traces_layouts.jl")
include("styles.jl")
abstract AbstractPlotlyDisplay

# core plot object
type Plot{TT<:AbstractTrace}
    data::Vector{TT}
    layout::AbstractLayout
    divid::Base.Random.UUID
    style::Style
end

# include the rest of the core parts of the package
include("display.jl")
include("json.jl")
include("subplots.jl")
include("api.jl")
include("convenience_api.jl")

# Set some defaults for constructing `Plot`s
function Plot(;style::Style=DEFAULT_STYLE[1])
    Plot(GenericTrace{Dict{Symbol,Any}}[], Layout(), Base.Random.uuid4(), style)
end

function Plot{T<:AbstractTrace}(data::Vector{T}, layout=Layout();
                                style::Style=DEFAULT_STYLE[1])
    Plot(data, layout, Base.Random.uuid4(), style)
end

function Plot(data::AbstractTrace, layout=Layout();
              style::Style=DEFAULT_STYLE[1])
    Plot([data], layout; style=style)
end

function docs()
    schema_path = joinpath(dirname(dirname(@__FILE__)), "deps", "schema.html")
    w = Blink.Window()
    Blink.content!(w, "html", open(readstring, schema_path), fade=false)
end

# NOTE: we export trace constructing types from inside api.jl
# NOTE: we export names of shapes from traces_layouts.jl
export

    # core types
    Plot, GenericTrace, Layout, Shape,
    AbstractTrace, AbstractLayout,

    # other methods
    savefig, svg_data, png_data, jpeg_data, webp_data, autoresize,

    # plotly.js api methods
    restyle!, relayout!, addtraces!, deletetraces!, movetraces!, redraw!,
    extendtraces!, prependtraces!,

    # non-!-versions (forks, then applies, then returns fork)
    restyle, relayout, addtraces, deletetraces, movetraces, redraw,
    extendtraces, prependtraces,

    # helper methods
    plot, fork, vline, hline, attr

    # styles
    use_style!, style, Style

end # module
