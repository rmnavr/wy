from time import time as _get_time
import importlib

_show_startup_times = False
#
_import_lenses      = True
_import_strictT     = False
_import_monads      = True

# Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1
_tGlob = _get_time()
# ================================================================

# hy (import)
_t = _get_time()
import hy
_r1 = f"{(_get_time() - _t) :.3f} sec | hy (will be 0 if called from hy file)"

# core funcs (import)
_t = _get_time()
from wy.utils.fptk_local.core.funcs import *
_r2 = f"{(_get_time() - _t) :.3f} sec | core funcs"

# core macros (require)
_t = _get_time()
hy.eval(hy.read(f"(require wy.utils.fptk_local.core.funcs :macros *)"))
_r3 = f"{(_get_time() - _t) :.3f} sec | core macros"

if _import_lenses:
    _t = _get_time()
    from wy.utils.fptk_local.lenses import *
    _r4 = f"{(_get_time() - _t) :.3f} sec | lenses"

if _import_strictT:
    _t = _get_time()
    from wy.utils.fptk_local.strict import *
    _r5 = f"{(_get_time() - _t) :.3f} sec | strict"

if _import_monads:
    _t = _get_time()
    from wy.utils.fptk_local.monads import *
    _r6 = f"{(_get_time() - _t) :.3f} sec | monads"

# ================================================================
_rGlob = f"{(_get_time() - _tGlob) :.3f} sec | Total time"
# _____________________________________________________________________________/ }}}1

# Final print ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

if _show_startup_times:
    print(_r1)
    print(_r2)
    print(_r3)
    _import_lenses  and print(_r4) # this is syntax for one-liner if-then
    _import_strictT and print(_r5)
    _import_monads  and print(_r6)
    print("-------------")
    print(_rGlob)

# _____________________________________________________________________________/ }}}1
