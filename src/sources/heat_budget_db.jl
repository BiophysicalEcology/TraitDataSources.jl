
# ── HeatBudgetDB path resolution ───────────────────────────────────────────────

function _heat_budget_db_relpath(::Type{GeometryDomain})
    joinpath("geometryDB", "export", "data", "current_DB", "Morphometry_geometry.rds")
end

function _heat_budget_db_relpath(::Type{InsulationDomain})
    joinpath("insulationDB", "export", "data", "current_DB", "Morphology_insulation.rds")
end

function _heat_budget_db_relpath(::Type{RadiationDomain})
    joinpath("radiationDB", "export", "data", "current_DB", "Morphology_radiative_properties.rds")
end

function _heat_budget_db_relpath(::Type{RespirationDomain})
    joinpath("respirationDB", "export", "data", "current_DB", "Physiology_respirometry.rds")
end

"""
    traitpath(source) → String

Return the absolute path to the `.rds` file for the given source.

For `HeatBudgetDB`, the root directory is read from `ENV["HEATBUDGETDB_PATH"]`
(e.g. `~/Dropbox/Current Research Projects/trait_database/heat_budget_databases`).
"""
function traitpath(::HeatBudgetDB{D}) where D <: TraitDomain
    root = get(ENV, "HEATBUDGETDB_PATH", nothing)
    if root === nothing
        error(
            "Set ENV[\"HEATBUDGETDB_PATH\"] to the root of the heat budget databases.\n" *
            "  Example: ENV[\"HEATBUDGETDB_PATH\"] = \"/Users/mrke/Dropbox/Current Research Projects/" *
            "trait_database/heat_budget_databases\""
        )
    end
    joinpath(root, _heat_budget_db_relpath(D))
end
