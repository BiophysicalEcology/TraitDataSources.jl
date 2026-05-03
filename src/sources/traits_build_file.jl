
"""
    traitpath(source::TraitsBuildFile) → String

Return the path stored in the `TraitsBuildFile` source.
"""
traitpath(src::TraitsBuildFile) = src.path
