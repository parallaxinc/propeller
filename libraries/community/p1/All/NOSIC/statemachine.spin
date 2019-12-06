con
'' Stupidly simple state machine object

dat

GlobalState     long 0
GlobalStateNext long 0
GlobalStateLast long 0
GlobalStateCounter long 0

semabyte byte 1
var
long LocalState, LocalStateNext, LocalStateLast, LocalStateCounter

pub lcnt
    return LocalStateCounter
pub gcnt
    return GlobalStateCounter
pub lnow '' returns local current state
    return LocalState
pub gnow '' returns global current state
    return GlobalState
pub lnext  '' returns local next state
    return LocalStateNext
pub gnext  '' returns global next state
    return GlobalStateNext
pub llast '' returns local last state
    return LocalStateLast
pub glast '' returns global last state
    return GlobalStateLast

pub lset(state) '' sets local nextstate. returns old value for nextstate, in case we want to know it
    result := LocalStateNext
    LocalStateNext := state

pub gset(state) '' sets global nextstate. returns old value for nextstate, in case we want to know it
    repeat until semabyte ' make sure we're not ticking
    result := GlobalStateNext
    GlobalStateNext := state

pub ltick '' local tick
    result := LocalState
    if LocalStateNext <> LocalState
       LocalStateLast := LocalState
       LocalStateCounter~   
    else
       LocalStateCounter++   
    LocalState := LocalStateNext

pub gtick  '' global tick, waits for turn
    return globaltick(true)

pub globaltick(wait)
    result := GlobalState
    if wait
       repeat until semabyte
    if semabyte
       semabyte~
       if GlobalStateNext <> GlobalState
          GlobalStateLast := GlobalState
          GlobalStateCounter~   
       else
          GlobalStateCounter++   
       GlobalState := GlobalStateNext
       semabyte++
       return GlobalState
    else
       return -1
pub debug
    return GlobalState