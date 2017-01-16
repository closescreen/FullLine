module FullLine

type EachFullLine
 source_iter::EachLine
 sep::Char
 need_fields_count::Int
 warn::Bool
 skip::Bool
end

Base.eltype(i::EachFullLine) = Array{SubString{String},1}
 
"each_full_line( i::EachLine, '*', 10)"
eachFullLine( iter::EachLine, sep::Char, need_fields_count::Int; warn::Bool=true, skip::Bool=true) = 
  EachFullLine( iter, sep, need_fields_count, warn, skip)
 
"filename|> eachline |> each_full_line( '*', 10)"
each_full_line( sep::Char, need_fields_count::Int; warn::Bool=true, skip::Bool=true ) = 
  iter::EachLine->EachFullLine( iter, sep, need_fields_count, warn, skip)


function Base.next( j::EachFullLine, state)
 
 (newline, newstate) = next( j.source_iter, state)
 
 rvv = split( chomp(newline), j.sep )

 length(rvv)==j.need_fields_count && return( rvv, newstate)

 while length(rvv) < j.need_fields_count
   if done( j.source_iter, newstate)
    j.warn && warn("Fields count $(length(rvv)) less then need: $(j.need_fields_count):\n$rvv")
    if j.skip
     return(fill( SubString{String}(""), j.need_fields_count ),newstate)
    else 
     return(rvv,newstate)
    end 
   end    
   (newline, newstate) = next( j.source_iter, newstate)
   rvv2 = split( chomp(newline), j.sep )

   rvv[end] = rvv[end]*shift!(rvv2)
   append!( rvv, rvv2 )
 end
 
 if length(rvv)==j.need_fields_count
  return( rvv, newstate)
 
 elseif length(rvv)>j.need_fields_count
  if j.warn
   warn("Count of fields=$(length(rvv)) (must be = j.need_fields_count): joined line:\n$rvv")
  end
  
  if j.skip
   if !done( j.source_iter, newstate)
    return next( j, newstate)
   else
    return ( fill( SubString{String}(""), j.need_fields_count ))
   end    
  
  else
   return (rvv, newstate)
  end
 end
 
 
end


Base.start( j::EachFullLine) = start( j.source_iter)

Base.done( j::EachFullLine, state) = done( j.source_iter, state)


end # module

