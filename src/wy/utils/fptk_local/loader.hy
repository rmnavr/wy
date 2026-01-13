
    (defmacro load_fptk [#* args]
        (setv actions [])
        (when (in '"core" args)
              (actions.append `(import  wy.utils.fptk_local.core *)) 
              (actions.append `(require wy.utils.fptk_local.core *)))
        ;
        (when (in '"lenses" args)
              (actions.append `(import  wy.utils.fptk_local.lenses *))
              (actions.append `(require wy.utils.fptk_local.lenses *)))
        ;
        (when (in '"maybeM" args)
              (actions.append `(import  wy.utils.fptk_local.monads.maybeM *)))
        (when (in '"resultM" args)
              (actions.append `(import  wy.utils.fptk_local.monads.resultM *)))
        ;
        (when (in '"strict_types" args)
              (actions.append `(import  wy.utils.fptk_local.strict.types *)))
        (when (in '"resultM_strict" args)
              (actions.append `(import  wy.utils.fptk_local.strict.resultM *)))
        (when (in '"maybeM_strict" args)
              (actions.append `(import  wy.utils.fptk_local.strict.maybeM *)))
        ;
       `(do ~@ actions))

        
