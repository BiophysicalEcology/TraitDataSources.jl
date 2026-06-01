module TraitDataSources

using Arrow
using DataFrames

# ── Exports ───────────────────────────────────────────────────────────────────

# Domain types
export TraitDataSource, TraitDomain
export GeometryDomain, InsulationDomain, RadiationDomain, RespirationDomain

# Source types
export HeatBudgetDB, TraitsBuildFile, CompiledParametersDB, DEBTraitDB

# Primary interface
export gettraits, traitnames, traitpath, available_traits, getspeciesmetadata

# traits.build utilities (also re-exported from BiophysicalParameters)
export join_contexts

# ── Includes ──────────────────────────────────────────────────────────────────

include("types.jl")
include("join_contexts.jl")
include("interface.jl")
include("sources/heat_budget_db.jl")
include("sources/traits_build_file.jl")
include("sources/compiled_parameters_db.jl")
include("sources/deb_trait_db.jl")

end
