using Base.Iterators:flatmap

_inject(search :: Symbol, replace_with :: Any, into :: Any) = into
_inject(search :: Symbol, replace_with :: Any, into :: Union{Tuple, Array}) = replace(into, search=>replace_with)
_inject(search :: Symbol, replace_with :: Any, into :: Expr) = 
    Expr( into.head, _inject(search, replace_with, into.args)...)

# pipe: the function that transforms a sequence of expressions into the correct form for the @> macro
pipe(s :: Symbol, e) =  e
pipe(s :: Symbol, expr1, expr2, exprs...) = pipe(s, pipe(s, expr1, expr2), exprs...)
pipe(s :: Symbol, expr, expr2 :: Any) = Expr(:call, expr2, expr)

pipe(s :: Symbol, expr, expr2 :: Expr) = begin 
    varname = gensym(s)
    body = _inject(s, varname, expr2)
    quote
        let $varname = $expr 
            $body
        end
    end
end




const default_symbol = Symbol("_")
macro >(e1, stuff...)
    # first, flatten out any begin ... end blocks
    arg_to_iter(arg) = 
        if arg isa Expr && arg.head == :block
            filter(l -> !(l isa LineNumberNode), arg.args)
        else
            (arg,)
        end
    args = flatmap(arg_to_iter, stuff) 

    if e1 isa Symbol
        pipe(e1, args...)
    else
        pipe(default_symbol, arg_to_iter(e1)..., args...)
    end
end
