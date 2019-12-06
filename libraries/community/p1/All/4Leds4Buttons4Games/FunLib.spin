obj
  'dbg: "debug"
  
var
  long prv
  
pub getRandom (mn,mx) | i
   i := cnt
   i?
   i := i // (mx-mn+1)
   if i < 0
      i := -1 * i
   i := i + mn
   prv := i
   return i

pub getRandomSeq(mn, mx) | r, _prv
    _prv := prv
    r:= getRandom(mn,mx)
    repeat until r <> _prv
      'dbg.print(string("r: "), r)
      r:= getRandom(mn,mx)
      
    return r
      
        