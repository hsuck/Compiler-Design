lexer grammar mylexer;

options {
  language = Java;
}

/*----------------------*/
/*   Reserved Keywords  */
/*----------------------*/
VOID_TYPE : 'void';
CHAR_TYPE : 'char';
SHORT_TYPE : 'short';
INT_TYPE : 'int';
LONG_TYPE : 'long';
FLOAT_TYPE : 'float';
DOUBLE_TYPE : 'double';
SIGNED_TYPE : 'signed';
UNSIGNED_TYPE : 'unsigned';
STRUCT_TYPE : 'struct';

EXTERN_TYPE : 'extern';
STATIC_TYPE : 'static';
VOLATILE_TYPE : 'volatile';

GOTO_TYPE : 'goto';
BREAK_TYPE : 'break';
COUNTINUE_TYPE : 'continue';
RETURN_TYPE : 'return';

FOR_TYPE : 'for';
WHILE_TYPE : 'while';
IF_TYPE : 'if';
ELSEIF_TYPE : 'else if';
ELSE_TYPE : 'else';

/*----------------------*/
/* Assignment Operators */
/*----------------------*/

ASSIGN_OP 
    : '='
    | '+='
    | '-='
    | '*='
    | '/='
    | '%='
    | '&='
    | '|='
    | '^='
    | '<<=' 
    | '>>='
    ;

/*----------------------*/
/* Arithmetic Operators */
/*----------------------*/

ARITH_OP
    : '+'
    | '-'
    | '*'
    | '/'
    | '%'
    | '++'
    | '--'
    ;

/*----------------------*/
/* Comparison Operators */
/*----------------------*/

CMP_OP 
    : '<'
    | '>'
    | '<='
    | '>='
    | '=='
    | '!='
    ;


/*----------------------*/
/*   logical Operators  */
/*----------------------*/

LOG_OP
    : '!'
    | '&&'
    | '||'
    ;


/*----------------------*/
/*   Bitwise Operators  */
/*----------------------*/

BIT_OP
    : '~'
    | '&'
    | '|'
    | '^'
    | '<<'
    | '>>'
    ;

/*----------------------*/
/*      Separators      */
/*----------------------*/
LPARENTHESIS : '(';
RPARENTHESIS : ')';
LBRACKET : '[';
RBRACKET : ']';
LCURLY_BRACKET : '{';
RCURLY_BRACKET : '}';
SEMI_COLON : ';';
COMMA : ',';
POUND_SIGN: '#';

/*----------------------*/
/*   Pointer Operator   */
/*----------------------*/
POINTER_OP
    : '->'
    | '.'
    ;

/*----------------------*/
/*      Identifier      */
/*----------------------*/
ID : ( LETTER )( LETTER | DIGIT )*;

/*----------------------*/
/*        Number        */
/*----------------------*/
DEC_NUM : ( '0' | ( '1'..'9' )( DIGIT )* );
HEX_NUM : '0'( 'x' | 'X' )HEXDIGIT+;

FLOAT_NUM : ( FLOAT_NUM1 | FLOAT_NUM2 | FLOAT_NUM3 )( FLOATTYPESUFFIX? );
fragment FLOAT_NUM1 : ( DIGIT )+'.'( DIGIT )*;
fragment FLOAT_NUM2 : '.'( DIGIT )+;
fragment FLOAT_NUM3 : ( DIGIT )+;
fragment FLOATTYPESUFFIX : ( 'f' | 'F' | 'd' | 'D' );

EXPONET : ( 'e' | 'E' )( '+' | '-' )?( '0'..'9' )+;

/*----------------------*/
/*       Literal        */
/*----------------------*/
CHAR_LITERAL : '\''( ESCAPESEQ | ~( '\'' | '\\' ) )'\'';
STR_LITERAL : '"'( ESCAPESEQ | ~( '\\' | '"' ) )*'"';

fragment HEXDIGIT : ( '0'..'9' | 'a'..'f' | 'A'..'F' );
fragment ESCAPESEQ : '\\'( 'b' | 't' | 'n' | 'f' | 'r' | '\"' | '\'' | '\\' );
 
/* Comments */
COMMENT1 : '//'(.)*'\n';
COMMENT2 : '/*' (options{greedy=false;}: .)* '*/';

fragment LETTER : 'a'..'z' | 'A'..'Z' | '_';
fragment DIGIT : '0'..'9';

WS  : ( ' ' | '\r' | '\t' | '\n' )+;
