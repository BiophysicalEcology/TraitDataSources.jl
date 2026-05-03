
# ── Abstract types ─────────────────────────────────────────────────────────────

"Abstract supertype for all trait data sources."
abstract type TraitDataSource end

"Abstract supertype for the four heat-budget measurement domains."
abstract type TraitDomain end

# ── Domain singletons ──────────────────────────────────────────────────────────

"Animal body geometry — shape measurements, surface areas, body dimensions."
struct GeometryDomain    <: TraitDomain end

"Fur, feather, and fat insulation — fibre properties, coat depth, fat fraction."
struct InsulationDomain  <: TraitDomain end

"Radiative properties — spectral reflectance, thermal emissivity."
struct RadiationDomain   <: TraitDomain end

"Metabolic rate and respirometry — oxygen consumption, CO₂ production, body temperature."
struct RespirationDomain <: TraitDomain end

# ── Concrete source types ──────────────────────────────────────────────────────

"""
    HeatBudgetDB{D<:TraitDomain}()

One of the four canonical heat-budget trait databases (geometry, insulation, radiation,
respiration).  The root directory is read from `ENV["HEATBUDGETDB_PATH"]` at call time.
"""
struct HeatBudgetDB{D<:TraitDomain} <: TraitDataSource end

"""
    TraitsBuildFile(path)

Any local traits.build `.rds` file.  `gettraits` loads the file, joins contexts, and
returns a joined long-format DataFrame.

Requires `using RData` to activate the loading extension.
"""
struct TraitsBuildFile <: TraitDataSource
    path::String
end

# ── TraitsBuildDatabase ────────────────────────────────────────────────────────

"""
    TraitsBuildDatabase

Internal wrapper around the tables loaded from a traits.build `.rds` file.  Users
receive a joined long-format DataFrame from `gettraits`; this struct is only visible
to the extension and loading code.
"""
struct TraitsBuildDatabase
    traits      ::DataFrame
    contexts    ::DataFrame
    methods     ::DataFrame
    locations   ::DataFrame
    definitions ::DataFrame
    source      ::String
end
