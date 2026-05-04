
traitpath(src::CompiledParametersDB) = src.path

"""
    gettraits(src::CompiledParametersDB; taxon=nothing) → DataFrame

Load the compiled biophysical parameters Arrow database and return it as a DataFrame.
Each row is one `(taxon_name, parameter_struct, parameter_field)` with columns for
mean, SD, n, 95% CI, distribution family, and distribution params (JSON).

Pass `taxon` to filter to a single species name.
"""
function gettraits(src::CompiledParametersDB; taxon::Union{String, Nothing}=nothing)
    path = traitpath(src)
    isfile(path) || error(
        "Compiled parameters database not found at $path.\n" *
        "Run BiophysicalParameters.compile_parameters_database([\"taxon name\"]) to build it first."
    )
    df = DataFrame(Arrow.Table(path))
    taxon === nothing ? df : filter(r -> r.taxon_name == taxon, df)
end
