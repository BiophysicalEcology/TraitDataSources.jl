
"""
    DEBTraitDB(path)
    DEBTraitDB()

Long-format Arrow database of DEB trait observations derived from the AddMyPet
collection.  Each row is a single (species, trait, value) observation, with
columns for the observation temperature, typical temperature, independent
variable (for univariate traits), per-point weight, entry author, and
taxonomy/ecology metadata.

When called with no arguments the path is resolved as:
`joinpath(ENV["DEB_TRAITS_PATH"], "export", "data", "traits_build.arrow")`

`gettraits` returns a DataFrame filtered to one taxon via the `taxon` keyword.
`available_traits` prints a summary table and returns the available trait symbols.

# Examples
```julia
using TraitDataSources

db = DEBTraitDB()                                    # ENV["DEB_TRAITS_PATH"] must be set
db = DEBTraitDB("/path/to/traits_build_julia.arrow")  # explicit path

# All rows for one species
df = gettraits(db; taxon="Emydura_macquarii")

# Discover what traits are available
traits = available_traits(db, "Emydura_macquarii")

# Filter to a specific submitter
df = gettraits(db; taxon="Emydura_macquarii", submitter="Kearney")
```
"""
struct DEBTraitDB <: TraitDataSource
    path::String
end

function DEBTraitDB()
    root = get(ENV, "DEB_TRAITS_PATH", nothing)
    root === nothing && error(
        "Set ENV[\"DEB_TRAITS_PATH\"] to the DEB traits database root directory, " *
        "or pass the path explicitly: DEBTraitDB(\"/path/to/traits_build_julia.arrow\")"
    )
    DEBTraitDB(joinpath(root, "export", "data", "traits_build_julia.arrow"))
end

traitpath(src::DEBTraitDB) = src.path

"""
    gettraits(src::DEBTraitDB; taxon=nothing, submitter=nothing) → DataFrame

Load the DEB trait Arrow database and return a long-format DataFrame.

- `taxon`: filter to one species name (underscore format, e.g. `"Emydura_macquarii"`)
- `submitter`: filter to one entry author (e.g. `"Kearney"`)
"""
function gettraits(
    src::DEBTraitDB;
    taxon::Union{String, Nothing}=nothing,
    submitter::Union{String, Nothing}=nothing,
)
    path = traitpath(src)
    isfile(path) || error(
        "DEB trait database not found at: $path\n" *
        "Generate it from R with: arrow::write_arrow(traits_build_julia, \"$path\")"
    )
    df = DataFrame(Arrow.Table(path))
    # taxon_name_underscore is the canonical underscore-format column
    if taxon !== nothing
        col = hasproperty(df, :taxon_name_underscore) ? :taxon_name_underscore : :taxon_name
        df = filter(r -> getproperty(r, col) == taxon, df)
    end
    if submitter !== nothing
        if hasproperty(df, :entry_author)
            df = filter(r -> r.entry_author == submitter, df)
        else
            @warn "entry_author column not present in database — submitter filter ignored"
        end
    end
    df
end

"""
    available_traits(src::DEBTraitDB, taxon::String) → Tuple{Vararg{Symbol}}

Print a summary table of traits available for `taxon` in the database, then
return a sorted tuple of their symbols.  Use this to discover what data exists
before writing a `TraitQuery`.

# Example
```julia
db = DEBTraitDB()
traits = available_traits(db, "Emydura_macquarii")
# ab            n=   2  unit=d             (AmP_zerovariate)
# am            n=   1  unit=d             (AmP_zerovariate)
# tL            n=  24  unit=cm            (AmP_univariate)
# ...
```
"""
function available_traits(src::DEBTraitDB, taxon::String)
    rows = gettraits(src; taxon)
    isempty(rows) && error("No data found in the database for taxon: \"$taxon\"")
    names = sort(unique(rows.trait_name))
    println("Available traits for \"$taxon\":")
    println(rpad("trait", 14), rpad("n", 6), rpad("unit", 22), "type")
    println("-"^60)
    for t in names
        trows  = filter(r -> r.trait_name == t, rows)
        n      = nrow(trows)
        unit   = first(trows.unit)
        dtype  = first(trows.dataset_id)
        println(rpad(t, 14), rpad(n, 6), rpad(unit, 22), dtype)
    end
    Tuple(Symbol.(names))
end

"""
    getspeciesmetadata(src::DEBTraitDB, species::String) → NamedTuple

Return a `NamedTuple` with all species-level metadata for `species` from the companion
`traits_build_julia_species_metadata.arrow` file (one row per species).

Fields: `taxon_name`, `taxon_name_underscore`, `phylum`, `class`, `order`, `family`,
`species_en`, `climate`, `ecozone`, `habitat`, `embryo`, `migrate`, `food`, `gender`,
`reprod`, `T_typical`, `class_chemistry_group`.

The metadata file is resolved from the `DEBTraitDB` path by replacing the filename:
`traits_build_julia.arrow` → `traits_build_julia_species_metadata.arrow`

# Example
```julia
db  = DEBTraitDB()
row = getspeciesmetadata(db, "Emydura_macquarii")
row.phylum              # "Chordata"
row.class               # "Reptilia"
row.class_chemistry_group  # "vertebrate"
row.T_typical           # 295.15
```
"""
function getspeciesmetadata(src::DEBTraitDB, species::String)
    meta_path = replace(src.path, "traits_build_julia.arrow" => "traits_build_julia_species_metadata.arrow")
    isfile(meta_path) || error(
        "Species metadata file not found at: $meta_path\n" *
        "Generate it from R with the traits.build pipeline."
    )
    df   = DataFrame(Arrow.Table(meta_path))
    rows = filter(r -> !ismissing(r.taxon_name_underscore) && r.taxon_name_underscore == species, df)
    isempty(rows) && error("Species \"$species\" not found in species metadata database at: $meta_path")
    r = first(eachrow(rows))
    _s(x) = coalesce(x, "")
    _f(x) = coalesce(x, NaN)
    (;
        taxon_name            = _s(r.taxon_name),
        taxon_name_underscore = _s(r.taxon_name_underscore),
        phylum                = _s(r.phylum),
        class                 = _s(r.class),
        order                 = _s(r.order),
        family                = _s(r.family),
        species_en            = _s(r.species_en),
        climate               = _s(r.climate),
        ecozone               = _s(r.ecozone),
        habitat               = _s(r.habitat),
        embryo                = _s(r.embryo),
        migrate               = _s(r.migrate),
        food                  = _s(r.food),
        gender                = _s(r.gender),
        reprod                = _s(r.reprod),
        T_typical             = _f(r.T_typical),
        class_chemistry_group = _s(r.class_chemistry_group),
    )
end
