    
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1
    
    (import os)
    
    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))
    
    (require hyrule [of as-> -> ->> doto case branch unless lif do_n list_n ncut])
    (import _hyextlink *)
    (require _hyextlink [f:: fm p> pluckm lns &+ &+> l> l>=])
    
; _____________________________________________________________________________/ }}}1
; Classes ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1
    
    (setv #_ DC FileBody str)
    (setv #_ DC FileName str #_ "like < pupos.nau >")
    (setv #_ DC FileNameWithPath str #_ "like < journal//pupos.nau >")
    (setv #_ DC DirPath str #_ "like < journal//folder1 >")
    
    (import datetime [date])
    (setv #_ DC Date date; just a renaming to Uppercase
    ); works as: (Date :year 2025 :month 3 :day 33)
    
    ; # Tag
    ; # Category Tag
    
    (defclass [dataclass] JTag []
        ( #^ (of Optional str) category)
        ( #^ (of Optional str) tag))
    
    (defclass [dataclass] JFile []
        ( #^ FileName name)
        ( #^ DirPath path)
        ( #^ (of List JTag) tags)
        ( #^ FileBody content)
        ( #^ (of Optional Date) date
        );
        (defn __str__ [self] f"<{self.path}//{self.name} | {self.date} | {self.tags}>")
        (defn __repr__ [self] (self.__str__)))
    
    (setv #_ DC IFilesReader (f:: DirPath -> (of List str) => (of List JFile)))
    
    
    
; _____________________________________________________________________________/ }}}1
    
; scan dir for files ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1
    
    (defn #^ (of List FileNameWithPath)
        flatscan_for_files
        [ #^ DirPath directory
          #^ (of List str) [extensions []]]
        (first (flatscan_for_dirs_and_files directory extensions)))
    
    (defn #^ #((of List FileNameWithPath) (of List DirPath))
        flatscan_for_dirs_and_files
        [ #^ DirPath directory
          #^ (of List str) [extensions []]]
        "flat means does not perform nested search"
        (setv _fullNames (lmap (partial sconcat f"{directory}//") (os.listdir directory)))
        (setv _dirs (lfilter os.path.isdir _fullNames))
        (setv _files (lfilter os.path.isfile _fullNames))
        (setv _files (lfilter (rpartial does_extension_match extensions) _files))
        (return #(_files _dirs)))
    
    (defn #^ bool
        does_extension_match
        [ #^ FileNameWithPath fullFileName
          #^ (of List str) [extensions []] #_ "like [nau txt]"]
        "Returns True if no extensions are provided. When extensions are provided, returns True only if matches some extension."
        (when (eq extensions []) (return True))
        (any
            (lfor ext (lmap lowercase extensions)
                 (-> fullFileName (lowercase)
                                   (endswith f".{ext}")))))
    
    
; _____________________________________________________________________________/ }}}1
; extract date ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1
    
    (defn #^ (of Optional Date)
        extract_date_from_filename
        [ #^ FileName filename
        ]; check if 1st 6 symbols are numbers:
        (setv dateString (get filename (slice 0 6)))
        (unless (dateString.isdigit) (return None)
        ); if validated:
        (setv year (sconcat "20" (get filename :slice 0 2 )))
        (setv month (get filename (slice 2 4 )))
        (setv day (get filename (slice 4 6 )))
        (setv [y m d] (lmap int [year month day]))
        (when (zeroQ m) (setv m 1)); / because I sometimes use date 240000
        (when (zeroQ d) (setv d 1); \
        ); return Date if numbers are valid date:
        (try
            (Date :year y
                 :month m
                 :day d)
            (except [e Exception] None)))
    
; _____________________________________________________________________________/ }}}1
; file to content ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1
    
    (defn #^ FileBody
        file_to_content
        [ #^ FileNameWithPath fullFileName]
        (with
            [ file
              (open fullFileName
                   "r"
                   :encoding "utf-8")]
            (setv outp (file.read)))
        (return outp))
    
; _____________________________________________________________________________/ }}}1
    
    (defn #^ (of List JFile)
        build_jfiles #_ IO
        [ #^ DirPath directory
            #^ (of List str) [extensions []]]
        (setv filenames (flatscan_for_files directory extensions))
        (lfor &fn filenames
            :setv [_path _name] (os.path.split &fn)
            :setv _content (file_to_content &fn)
            :setv _date (extract_date_from_filename _name)
            :setv _tags (produce_tags _content)
            (JFile :name _name
                  :path _path
                  :tags _tags
                  :content _content
                  :date _date)))
    
     