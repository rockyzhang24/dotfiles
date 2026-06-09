(module_declaration
    (upper_case_qid) @name
    (#set! "kind" "Module")) @symbol

(type_declaration
    (upper_case_identifier) @name
    (#set! "kind" "Enum")) @symbol

(type_alias_declaration
    (upper_case_identifier) @name
    (#set! "kind" "Struct")) @symbol

(value_declaration
    (function_declaration_left
        (lower_case_identifier) @name)
    (#set! "kind" "Function")) @symbol

(value_declaration
    (pattern) @name
    (#set! "kind" "Function")) @symbol

(port_annotation
    (lower_case_identifier) @name
    (#set! "kind" "Function")) @symbol
