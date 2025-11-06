
# Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

from __future__ import annotations

import sys
from typing import Mapping

from IPython.core.getipython import get_ipython
from IPython.core.magic import Magics, magics_class, line_cell_magic, needs_local_scope

import hy

from wy import run_wy2hy_transpilation, frame_hycode
from wy.utils.fptk_local import unwrapR, unwrapE, failureQ

# _____________________________________________________________________________/ }}}1

@magics_class
class WyMagics(Magics):

    @line_cell_magic
    @needs_local_scope
    def wy(
        self,
        line: str | None,
        cell: str | None = None,
        local_ns: Mapping[str, object] | None = None,
    ) -> object:
        """Magic to execute Hy code within a Python kernel."""
        ipython = get_ipython()
        if ipython is None:
            # The last element of `In`, i.e. the just-executed cell
            cell_number = -1
        else:
            cell_number = ipython.execution_count
        cell_filename = f'IPython:In[{cell_number}]'

        code = (line or "") + (cell or "")

        local_module = sys.modules[local_ns['__name__']]

        transpilationResult = run_wy2hy_transpilation(code)
        if failureQ(transpilationResult):
            print("wy -> hy transpilation failed:")
            print(unwrapE(transpilationResult).msg)
            return None
        else:
            hycode = unwrapR(transpilationResult)
            return hy.eval(
                hy.read_many(hycode, filename=cell_filename),
                locals=local_ns,
                module=local_module,
            )

    @line_cell_magic
    @needs_local_scope
    def wy_spy(
        self,
        line: str | None,
        cell: str | None = None,
        local_ns: Mapping[str, object] | None = None,
    ) -> object:
        """Magic to execute Hy code within a Python kernel."""
        ipython = get_ipython()
        if ipython is None:
            # The last element of `In`, i.e. the just-executed cell
            cell_number = -1
        else:
            cell_number = ipython.execution_count
        cell_filename = f'IPython:In[{cell_number}]'

        code = (line or "") + (cell or "")

        local_module = sys.modules[local_ns['__name__']]

        transpilationResult = run_wy2hy_transpilation(code)
        if failureQ(transpilationResult):
            print("wy -> hy transpilation failed:")
            print(unwrapE(transpilationResult).msg)
            return None
        hycode = unwrapR(transpilationResult)
        if hycode != "":
           print(frame_hycode(hycode.strip('\n'), colored=True))
        return hy.eval(
            hy.read_many(hycode.strip('\n'), filename=cell_filename),
            locals=local_ns,
            module=local_module,
        )

