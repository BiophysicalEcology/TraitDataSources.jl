
"""
    join_contexts(traits, contexts) → DataFrame

Join context variables from a traits.build `contexts` table onto the long-format
`traits` table, adding one column per context property (e.g. `temperature_ambient`,
`MR_estimate_type`, `body_region`).

This is the Julia equivalent of `traits.build::join_context_properties()` used in R
analysis scripts.  Context variables are stored separately in `contexts` and must be
joined before the data can be filtered or pivoted.

# Arguments
- `traits`: the `traits` slot from a traits.build `.rds` file (loaded via RData.jl)
- `contexts`: the `contexts` slot from the same file

# Returns
A copy of `traits` with additional columns for each unique `context_property` found in
the contexts table.  Values are strings; convert to numeric types after pivoting to wide
format as needed.
"""
function join_contexts(traits::DataFrame, contexts::DataFrame)
    isempty(contexts) && return copy(traits)

    result = copy(traits)
    for property_name in unique(contexts.context_property)
        property_rows = filter(r -> r.context_property == property_name, contexts)
        link_column   = Symbol(first(property_rows.link_id))

        # Context IDs are scoped per dataset — key on (dataset_id, link_vals) to avoid
        # collisions when multiple datasets share the same numeric context IDs.
        lookup = Dict{Tuple{String,String}, String}(
            (r.dataset_id, r.link_vals) => r.value
            for r in eachrow(property_rows)
        )

        result[!, Symbol(property_name)] = [
            (ismissing(row[link_column]) ||
             !haskey(lookup, (row.dataset_id, row[link_column]))) ?
                missing : lookup[(row.dataset_id, row[link_column])]
            for row in eachrow(result)
        ]
    end
    return result
end
