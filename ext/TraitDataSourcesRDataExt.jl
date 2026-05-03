module TraitDataSourcesRDataExt

using TraitDataSources
using DataFrames
using RData

function TraitDataSources._load_rds(path::String)::TraitDataSources.TraitsBuildDatabase
    isfile(path) || error("traits.build file not found: $path")
    raw = RData.load(path)
    _frame(key) = haskey(raw, key) ? DataFrame(raw[key]) : DataFrame()
    TraitDataSources.TraitsBuildDatabase(
        _frame("traits"),
        _frame("contexts"),
        _frame("methods"),
        _frame("locations"),
        _frame("definitions"),
        path,
    )
end

end
