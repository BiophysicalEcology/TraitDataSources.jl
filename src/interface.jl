
# ── RData loading stub ─────────────────────────────────────────────────────────
# Method bodies live in ext/TraitDataSourcesRDataExt.jl.
# Calling without loading RData gives an informative error instead of a MethodError.

function _load_rds(path::String)::TraitsBuildDatabase
    error(
        "Loading .rds files requires RData.jl.  Add `using RData` before calling gettraits.\n" *
        "  (add RData to your environment with `] add RData` if not already installed)"
    )
end

# ── gettraits ──────────────────────────────────────────────────────────────────

"""
    gettraits(source; taxon=nothing) → DataFrame

Load a traits.build database and return a joined long-format DataFrame (traits table
with context variables merged in as columns).

# Arguments
- `source`: a `HeatBudgetDB{D}()` or `TraitsBuildFile(path)`
- `taxon`: optional String; if given, only rows with `taxon_name == taxon` are returned

# Examples
```julia
using TraitDataSources, RData

# Full respiration database
resp = gettraits(HeatBudgetDB{RespirationDomain}())

# Filtered to one taxon
pogona = gettraits(HeatBudgetDB{RadiationDomain}(); taxon="Pogona vitticeps")

# Any local .rds file
df = gettraits(TraitsBuildFile("/path/to/my_database.rds"))
```

Requires `ENV["HEATBUDGETDB_PATH"]` for `HeatBudgetDB` sources.
Requires `using RData` to activate the file loading extension.
"""
function gettraits(source::TraitDataSource; taxon::Union{String, Nothing}=nothing)
    path = traitpath(source)
    db   = _load_rds(path)
    df   = join_contexts(db.traits, db.contexts)
    taxon === nothing ? df : filter(r -> r.taxon_name == taxon, df)
end

# ── traitnames ─────────────────────────────────────────────────────────────────

"""
    traitnames(df) → Vector{String}

Return the unique trait names present in a joined long-format traits DataFrame.
"""
traitnames(df::DataFrame) = unique(df.trait_name)
