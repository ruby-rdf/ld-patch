# This file is automatically generated by ebnf version 2.1.0
# Derived from etc/ld-patch.ebnf
module LD::Patch::Meta
  RULES = [
    EBNF::Rule.new(:ldpatch, "1", [:seq, :prologue, :_ldpatch_1]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_ldpatch_1, "1.1", [:star, :statement]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:prologue, "2", [:star, :prefixID]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:statement, "3", [:alt, :bind, :add, :addNew, :delete, :deleteExisting, :cut, :updateList]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:bind, "4", [:seq, :_bind_1, :VAR1, :value, :_bind_2, "."]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_bind_1, "4.1", [:alt, "Bind", "B"]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_bind_2, "4.2", [:opt, :path]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:add, "5", [:seq, :_add_1, "{", :graph, "}", "."]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_add_1, "5.1", [:alt, "Add", "A"]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:addNew, "6", [:seq, :_addNew_1, "{", :graph, "}", "."]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_addNew_1, "6.1", [:alt, "AddNew", "AN"]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:delete, "7", [:seq, :_delete_1, "{", :graph, "}", "."]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_delete_1, "7.1", [:alt, "Delete", "D"]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:deleteExisting, "8", [:seq, :_deleteExisting_1, "{", :graph, "}", "."]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_deleteExisting_1, "8.1", [:alt, "DeleteExisting", "DE"]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:cut, "9", [:seq, :_cut_1, :VAR1, "."]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_cut_1, "9.1", [:alt, "Cut", "C"]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:updateList, "10", [:seq, :_updateList_1, :varOrIRI, :predicate, :slice, :collection, "."]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_updateList_1, "10.1", [:alt, "UpdateList", "UL"]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:varOrIRI, "11", [:alt, :iri, :VAR1]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:value, "12", [:alt, :iri, :literal, :VAR1]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:path, "13", [:star, :_path_1]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_path_1, "13.1", [:alt, :_path_2, :constraint]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_path_2, "13.2", [:seq, "/", :step]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:step, "14", [:alt, :_step_1, :iri, :INTEGER]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_step_1, "14.1", [:seq, "^", :iri]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:constraint, "15", [:alt, :_constraint_1, "!"]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_constraint_1, "15.1", [:seq, "[", :path, :_constraint_2, "]"]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_constraint_2, "15.2", [:opt, :_constraint_3]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_constraint_3, "15.3", [:seq, "=", :value]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:slice, "16", [:seq, :_slice_1, "..", :_slice_2]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_slice_1, "16.1", [:opt, :INTEGER]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_slice_2, "16.2", [:opt, :INTEGER]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:VAR1, "143s", [:seq, "?", :VARNAME], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:VARNAME, "166s", [:seq, :_VARNAME_1, :_VARNAME_2], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_VARNAME_1, "166s.1", [:alt, :PN_CHARS_U, :_VARNAME_3], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_VARNAME_3, "166s.3", [:range, "0-9"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_VARNAME_2, "166s.2", [:star, :_VARNAME_4], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_VARNAME_4, "166s.4", [:alt, :PN_CHARS_U, :_VARNAME_5, :_VARNAME_6, :_VARNAME_7, :_VARNAME_8], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_VARNAME_5, "166s.5", [:range, "0-9"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_VARNAME_6, "166s.6", [:hex, "#x00B7"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_VARNAME_7, "166s.7", [:range, "#x0300-#x036F"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_VARNAME_8, "166s.8", [:range, "#x203F-#x2040"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:prefixID, "4t", [:seq, "@prefix", :PNAME_NS, :IRIREF, "."]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:graph, "18", [:seq, :triples, :_graph_1]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_graph_1, "18.1", [:star, :_graph_2]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_graph_2, "18.2", [:seq, ".", :_graph_3]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_graph_3, "18.3", [:opt, :triples]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:triples, "6t", [:alt, :_triples_1, :_triples_2]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_triples_1, "6t.1", [:seq, :subject, :predicateObjectList]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_triples_2, "6t.2", [:seq, :blankNodePropertyList, :_triples_3]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_triples_3, "6t.3", [:opt, :predicateObjectList]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:predicateObjectList, "7t", [:seq, :verb, :objectList, :_predicateObjectList_1]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_predicateObjectList_1, "7t.1", [:star, :_predicateObjectList_2]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_predicateObjectList_2, "7t.2", [:seq, ";", :_predicateObjectList_3]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_predicateObjectList_3, "7t.3", [:opt, :_predicateObjectList_4]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_predicateObjectList_4, "7t.4", [:seq, :verb, :objectList]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:objectList, "8t", [:seq, :object, :_objectList_1]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_objectList_1, "8t.1", [:star, :_objectList_2]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_objectList_2, "8t.2", [:seq, ",", :object]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:verb, "9t", [:alt, :predicate, "a"]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:subject, "10t", [:alt, :iri, :BlankNode, :collection, :VAR1]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:predicate, "11t", [:seq, :iri]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:object, "12t", [:alt, :iri, :BlankNode, :collection, :blankNodePropertyList, :literal, :VAR1]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:literal, "13t", [:alt, :RDFLiteral, :NumericLiteral, :BooleanLiteral]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:blankNodePropertyList, "14t", [:seq, "[", :predicateObjectList, "]"]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:collection, "15t", [:seq, "(", :_collection_1, ")"]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_collection_1, "15t.1", [:star, :object]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:NumericLiteral, "16t", [:alt, :INTEGER, :DECIMAL, :DOUBLE]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:RDFLiteral, "128s", [:seq, :String, :_RDFLiteral_1]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_RDFLiteral_1, "128s.1", [:opt, :_RDFLiteral_2]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_RDFLiteral_2, "128s.2", [:alt, :LANGTAG, :_RDFLiteral_3]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_RDFLiteral_3, "128s.3", [:seq, "^^", :iri]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:BooleanLiteral, "133s", [:alt, "true", "false"]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:String, "17", [:alt, :STRING_LITERAL_QUOTE, :STRING_LITERAL_SINGLE_QUOTE, :STRING_LITERAL_LONG_SINGLE_QUOTE, :STRING_LITERAL_LONG_QUOTE]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:iri, "135s", [:alt, :IRIREF, :PrefixedName]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:PrefixedName, "136s", [:alt, :PNAME_LN, :PNAME_NS]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:BlankNode, "137s", [:alt, :BLANK_NODE_LABEL, :ANON]).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:IRIREF, "18", [:seq, "<", :_IRIREF_1, ">"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_IRIREF_1, "18.1", [:star, :_IRIREF_2], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_IRIREF_2, "18.2", [:alt, :_IRIREF_3, :UCHAR], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_IRIREF_3, "18.3", [:range, "^#x00-#x20<>\"{}|^`\\"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:PNAME_NS, "139s", [:seq, :_PNAME_NS_1, ":"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PNAME_NS_1, "139s.1", [:opt, :PN_PREFIX], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:PNAME_LN, "140s", [:seq, :PNAME_NS, :PN_LOCAL], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:BLANK_NODE_LABEL, "141s", [:seq, "_:", :_BLANK_NODE_LABEL_1, :_BLANK_NODE_LABEL_2], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_BLANK_NODE_LABEL_1, "141s.1", [:alt, :PN_CHARS_U, :_BLANK_NODE_LABEL_3], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_BLANK_NODE_LABEL_3, "141s.3", [:range, "0-9"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_BLANK_NODE_LABEL_2, "141s.2", [:opt, :_BLANK_NODE_LABEL_4], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_BLANK_NODE_LABEL_4, "141s.4", [:seq, :_BLANK_NODE_LABEL_5, :PN_CHARS], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_BLANK_NODE_LABEL_5, "141s.5", [:star, :_BLANK_NODE_LABEL_6], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_BLANK_NODE_LABEL_6, "141s.6", [:alt, :PN_CHARS, "."], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:LANGTAG, "144s", [:seq, "@", :_LANGTAG_1, :_LANGTAG_2], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_LANGTAG_1, "144s.1", [:plus, :_LANGTAG_3], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_LANGTAG_3, "144s.3", [:range, "a-zA-Z"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_LANGTAG_2, "144s.2", [:star, :_LANGTAG_4], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_LANGTAG_4, "144s.4", [:seq, "-", :_LANGTAG_5], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_LANGTAG_5, "144s.5", [:plus, :_LANGTAG_6], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_LANGTAG_6, "144s.6", [:range, "a-zA-Z0-9"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:INTEGER, "19", [:seq, :_INTEGER_1, :_INTEGER_2], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_INTEGER_1, "19.1", [:opt, :_INTEGER_3], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_INTEGER_3, "19.3", [:range, "+-"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_INTEGER_2, "19.2", [:plus, :_INTEGER_4], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_INTEGER_4, "19.4", [:range, "0-9"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:DECIMAL, "20", [:seq, :_DECIMAL_1, :_DECIMAL_2, ".", :_DECIMAL_3], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_DECIMAL_1, "20.1", [:opt, :_DECIMAL_4], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_DECIMAL_4, "20.4", [:range, "+-"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_DECIMAL_2, "20.2", [:star, :_DECIMAL_5], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_DECIMAL_5, "20.5", [:range, "0-9"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_DECIMAL_3, "20.3", [:plus, :_DECIMAL_6], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_DECIMAL_6, "20.6", [:range, "0-9"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:DOUBLE, "21", [:seq, :_DOUBLE_1, :_DOUBLE_2], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_DOUBLE_1, "21.1", [:opt, :_DOUBLE_3], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_DOUBLE_3, "21.3", [:range, "+-"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_DOUBLE_2, "21.2", [:alt, :_DOUBLE_4, :_DOUBLE_5, :_DOUBLE_6], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_DOUBLE_4, "21.4", [:seq, :_DOUBLE_7, ".", :_DOUBLE_8, :EXPONENT], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_DOUBLE_7, "21.7", [:plus, :_DOUBLE_9], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_DOUBLE_9, "21.9", [:range, "0-9"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_DOUBLE_8, "21.8", [:star, :_DOUBLE_10], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_DOUBLE_10, "21.10", [:range, "0-9"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_DOUBLE_5, "21.5", [:seq, ".", :_DOUBLE_11, :EXPONENT], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_DOUBLE_11, "21.11", [:plus, :_DOUBLE_12], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_DOUBLE_12, "21.12", [:range, "0-9"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_DOUBLE_6, "21.6", [:seq, :_DOUBLE_13, :EXPONENT], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_DOUBLE_13, "21.13", [:plus, :_DOUBLE_14], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_DOUBLE_14, "21.14", [:range, "0-9"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:EXPONENT, "154s", [:seq, :_EXPONENT_1, :_EXPONENT_2, :_EXPONENT_3], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_EXPONENT_1, "154s.1", [:range, "eE"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_EXPONENT_2, "154s.2", [:opt, :_EXPONENT_4], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_EXPONENT_4, "154s.4", [:range, "+-"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_EXPONENT_3, "154s.3", [:plus, :_EXPONENT_5], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_EXPONENT_5, "154s.5", [:range, "0-9"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:STRING_LITERAL_QUOTE, "22", [:seq, "\"", :_STRING_LITERAL_QUOTE_1, "\""], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_STRING_LITERAL_QUOTE_1, "22.1", [:star, :_STRING_LITERAL_QUOTE_2], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_STRING_LITERAL_QUOTE_2, "22.2", [:alt, :_STRING_LITERAL_QUOTE_3, :ECHAR, :UCHAR], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_STRING_LITERAL_QUOTE_3, "22.3", [:range, "^#x22#x5C#xA#xD"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:STRING_LITERAL_SINGLE_QUOTE, "23", [:seq, "'", :_STRING_LITERAL_SINGLE_QUOTE_1, "'"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_STRING_LITERAL_SINGLE_QUOTE_1, "23.1", [:star, :_STRING_LITERAL_SINGLE_QUOTE_2], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_STRING_LITERAL_SINGLE_QUOTE_2, "23.2", [:alt, :_STRING_LITERAL_SINGLE_QUOTE_3, :ECHAR, :UCHAR], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_STRING_LITERAL_SINGLE_QUOTE_3, "23.3", [:range, "^#x27#x5C#xA#xD"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:STRING_LITERAL_LONG_SINGLE_QUOTE, "24", [:seq, "'''", :_STRING_LITERAL_LONG_SINGLE_QUOTE_1, "'''"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_STRING_LITERAL_LONG_SINGLE_QUOTE_1, "24.1", [:star, :_STRING_LITERAL_LONG_SINGLE_QUOTE_2], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_STRING_LITERAL_LONG_SINGLE_QUOTE_2, "24.2", [:seq, :_STRING_LITERAL_LONG_SINGLE_QUOTE_3, :_STRING_LITERAL_LONG_SINGLE_QUOTE_4], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_STRING_LITERAL_LONG_SINGLE_QUOTE_3, "24.3", [:opt, :_STRING_LITERAL_LONG_SINGLE_QUOTE_5], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_STRING_LITERAL_LONG_SINGLE_QUOTE_5, "24.5", [:alt, "'", "''"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_STRING_LITERAL_LONG_SINGLE_QUOTE_4, "24.4", [:alt, :_STRING_LITERAL_LONG_SINGLE_QUOTE_6, :ECHAR, :UCHAR], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_STRING_LITERAL_LONG_SINGLE_QUOTE_6, "24.6", [:range, "^'\\"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:STRING_LITERAL_LONG_QUOTE, "25", [:seq, "\"\"\"", :_STRING_LITERAL_LONG_QUOTE_1, "\"\"\""], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_STRING_LITERAL_LONG_QUOTE_1, "25.1", [:star, :_STRING_LITERAL_LONG_QUOTE_2], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_STRING_LITERAL_LONG_QUOTE_2, "25.2", [:seq, :_STRING_LITERAL_LONG_QUOTE_3, :_STRING_LITERAL_LONG_QUOTE_4], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_STRING_LITERAL_LONG_QUOTE_3, "25.3", [:opt, :_STRING_LITERAL_LONG_QUOTE_5], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_STRING_LITERAL_LONG_QUOTE_5, "25.5", [:alt, "\"", "\"\""], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_STRING_LITERAL_LONG_QUOTE_4, "25.4", [:alt, :_STRING_LITERAL_LONG_QUOTE_6, :ECHAR, :UCHAR], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_STRING_LITERAL_LONG_QUOTE_6, "25.6", [:range, "^\"\\"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:UCHAR, "26", [:alt, :_UCHAR_1, :_UCHAR_2], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_UCHAR_1, "26.1", [:seq, "\\\\u", :HEX, :HEX, :HEX, :HEX], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_UCHAR_2, "26.2", [:seq, "\\\\U", :HEX, :HEX, :HEX, :HEX, :HEX, :HEX, :HEX, :HEX], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:ECHAR, "159s", [:seq, "\\", :_ECHAR_1], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_ECHAR_1, "159s.1", [:range, "tbnrf\"'\\"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:WS, "161s", [:alt, :_WS_1, :_WS_2, :_WS_3, :_WS_4], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_WS_1, "161s.1", [:hex, "#x20"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_WS_2, "161s.2", [:hex, "#x9"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_WS_3, "161s.3", [:hex, "#xD"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_WS_4, "161s.4", [:hex, "#xA"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:ANON, "162s", [:seq, "[", :_ANON_1, "]"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_ANON_1, "162s.1", [:star, :WS], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:PN_CHARS_BASE, "163s", [:alt, :_PN_CHARS_BASE_1, :_PN_CHARS_BASE_2, :_PN_CHARS_BASE_3, :_PN_CHARS_BASE_4, :_PN_CHARS_BASE_5, :_PN_CHARS_BASE_6, :_PN_CHARS_BASE_7, :_PN_CHARS_BASE_8, :_PN_CHARS_BASE_9, :_PN_CHARS_BASE_10, :_PN_CHARS_BASE_11, :_PN_CHARS_BASE_12, :_PN_CHARS_BASE_13, :_PN_CHARS_BASE_14], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_CHARS_BASE_1, "163s.1", [:range, "A-Z"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_CHARS_BASE_2, "163s.2", [:range, "a-z"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_CHARS_BASE_3, "163s.3", [:range, "#x00C0-#x00D6"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_CHARS_BASE_4, "163s.4", [:range, "#x00D8-#x00F6"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_CHARS_BASE_5, "163s.5", [:range, "#x00F8-#x02FF"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_CHARS_BASE_6, "163s.6", [:range, "#x0370-#x037D"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_CHARS_BASE_7, "163s.7", [:range, "#x037F-#x1FFF"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_CHARS_BASE_8, "163s.8", [:range, "#x200C-#x200D"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_CHARS_BASE_9, "163s.9", [:range, "#x2070-#x218F"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_CHARS_BASE_10, "163s.10", [:range, "#x2C00-#x2FEF"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_CHARS_BASE_11, "163s.11", [:range, "#x3001-#xD7FF"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_CHARS_BASE_12, "163s.12", [:range, "#xF900-#xFDCF"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_CHARS_BASE_13, "163s.13", [:range, "#xFDF0-#xFFFD"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_CHARS_BASE_14, "163s.14", [:range, "#x10000-#xEFFFF"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:PN_CHARS_U, "164s", [:alt, :PN_CHARS_BASE, "_"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:PN_CHARS, "166s", [:alt, :PN_CHARS_U, "-", :_PN_CHARS_1, :_PN_CHARS_2, :_PN_CHARS_3, :_PN_CHARS_4], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_CHARS_1, "166s.1", [:range, "0-9"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_CHARS_2, "166s.2", [:hex, "#x00B7"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_CHARS_3, "166s.3", [:range, "#x0300-#x036F"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_CHARS_4, "166s.4", [:range, "#x203F-#x2040"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:PN_PREFIX, "167s", [:seq, :PN_CHARS_BASE, :_PN_PREFIX_1], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_PREFIX_1, "167s.1", [:opt, :_PN_PREFIX_2], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_PREFIX_2, "167s.2", [:seq, :_PN_PREFIX_3, :PN_CHARS], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_PREFIX_3, "167s.3", [:star, :_PN_PREFIX_4], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_PREFIX_4, "167s.4", [:alt, :PN_CHARS, "."], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:PN_LOCAL, "168s", [:seq, :_PN_LOCAL_1, :_PN_LOCAL_2], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_LOCAL_1, "168s.1", [:alt, :PN_CHARS_U, ":", :_PN_LOCAL_3, :PLX], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_LOCAL_3, "168s.3", [:range, "0-9"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_LOCAL_2, "168s.2", [:opt, :_PN_LOCAL_4], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_LOCAL_4, "168s.4", [:seq, :_PN_LOCAL_5, :_PN_LOCAL_6], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_LOCAL_5, "168s.5", [:star, :_PN_LOCAL_7], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_LOCAL_7, "168s.7", [:alt, :PN_CHARS, ".", ":", :PLX], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_LOCAL_6, "168s.6", [:alt, :PN_CHARS, ":", :PLX], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:PLX, "169s", [:alt, :PERCENT, :PN_LOCAL_ESC], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:PERCENT, "170s", [:seq, "%", :HEX, :HEX], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:HEX, "171s", [:alt, :_HEX_1, :_HEX_2, :_HEX_3], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_HEX_1, "171s.1", [:range, "0-9"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_HEX_2, "171s.2", [:range, "A-F"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_HEX_3, "171s.3", [:range, "a-f"], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:PN_LOCAL_ESC, "172s", [:seq, "\\", :_PN_LOCAL_ESC_1], kind: :terminal).extend(EBNF::PEG::Rule),
    EBNF::Rule.new(:_PN_LOCAL_ESC_1, "172s.1", [:alt, "_", "~", ".", "-", "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "=", "/", "?", "#", "@", "%"], kind: :terminal).extend(EBNF::PEG::Rule),
  ]
end

