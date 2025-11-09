"""Evaluate Wy code cells using %wy, %%wy, %wy_spy and %%wy_spy magics."""

from __future__ import annotations

from typing import Protocol

import hy
from .magic import WyMagics

__version__ = '0.2.0'

class MagicsRegistry(Protocol):
    """Surrogate for InteractiveShell

    `InteractiveShell.register_magics` is actually added dynamically at runtime.
    Therefore it doesn't help much to use `InteractiveShell` as the input type.
    https://github.com/ipython/ipython/blob/a72418e2dc/IPython/core/interactiveshell.py#L2200
    """
    def register_magics(self, cls: type) -> None: ...

def load_ipython_extension(ipython: MagicsRegistry) -> None:
    ipython.register_magics(WyMagics)

