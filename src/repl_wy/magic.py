from __future__ import annotations

import sys
from typing import Mapping

import hy
from wy import convert_wy2hy, frame_hycode
from IPython.core.getipython import get_ipython
from IPython.core.magic import Magics, magics_class, line_cell_magic, needs_local_scope

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

        return hy.eval(
            hy.read_many(convert_wy2hy(code), filename=cell_filename),
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

        try:
            __transpiled = convert_wy2hy(code).strip('\n')
        except Exception as e:
            print("Transpilation Error:", e)
            return None
        print(frame_hycode(__transpiled, colored=True))
        return hy.eval(
            hy.read_many(__transpiled, filename=cell_filename),
            locals=local_ns,
            module=local_module,
        )

