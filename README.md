# Pipe.jl

Exports a single macro `@>` wich threads the result of one function call into the placeholder within the next expresseion. Default Placeholder is `_`. Flattens any `begin ... end` block.

Example:
```julia
julia> @> [1, 2, 3] begin
    map( sin, _)
    reverse
end
```

    
