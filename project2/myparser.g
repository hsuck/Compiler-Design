grammar myparser;

options {
   language = Java;
}

@header {
    // import packages here.
}

@members {
    boolean TRACEON = true;
}

program
    : ( type_specifier ID LPARENTHESIS ( type_specifier ID ( COMMA )* )*  RPARENTHESIS LCURLY_BRACKET declarations statements RCURLY_BRACKET ) program?
    { if (TRACEON) System.out.println( "type_specifier ID () { declarations statements }" ); };

declarations
    : declaration_specifiers init_declarator_list SEMI_COLON declarations
    | 
    { if (TRACEON) System.out.println("declarations: "); }
    ;

declaration_specifiers
    :   (     storage_class_specifier
			| type_specifier
			| type_qualifier
        )+
    ;

init_declarator_list
    : init_declarator ( COMMA init_declarator )*
    ;

init_declarator
    : ID ( LBRACKET constant RBRACKET )?
    { if (TRACEON) System.out.println("declaration: " + $ID.text + " non-initialize"); }
    | ID ( LBRACKET constant RBRACKET )? ASSIGN_OP initializer
    { if (TRACEON) System.out.println("declaration: " + $ID.text + " initialize"); }
    | 
    ;

initializer
    : constant
    | ID
    | LCURLY_BRACKET constant ( COMMA constant )* RCURLY_BRACKET
    { if (TRACEON) System.out.println("array"); }
    ;

storage_class_specifier
    : EXTERN_TYPE
    | STATIC_TYPE
    ;

type_specifier
    : VOID_TYPE
    | CHAR_TYPE
    | SHORT_TYPE
    | INT_TYPE
    | LONG_TYPE
    | FLOAT_TYPE
    | DOUBLE_TYPE
    | SIGNED_TYPE
    | UNSIGNED_TYPE
    ;

type_qualifier
    : CONST_TYPE
    | VOLATILE_TYPE
    ;

// Expressions

add_expr
    : ( multi_expr ) ( '+' multi_expr | '-' multi_expr )*
    ;

multi_expr
    : ( postfix_expr ) ( '*' postfix_expr | '/' postfix_expr | '%' postfix_expr )*
    ;

unary_expr
    : ID(     '.' ID
            | '->' ID
            | '++'
            | '--' )*
    ;

postfix_expr
    :   ( primary_expr | '-' primary_expr )
		(     LBRACKET expression RBRACKET
			| '.' ID
			| '->' ID
			| '++'
			| '--' )*
    ;

primary_expr
    : ID
    | constant
    | LPARENTHESIS add_expr RPARENTHESIS
    ;

constant
    :   HEX_NUM
    |   DEC_NUM
    |	CHAR_LITERAL
    |	STR_LITERAL
    |   FLOAT_NUM
    ;

/////

expression
    : assign_expr ( COMMA assign_expr )*
    ;

assign_expr
    : lvalue ASSIGN_OP assign_expr
    { if (TRACEON) System.out.println("assignment expression"); }
    | conditional_expr
    { if (TRACEON) System.out.println("conditional expression"); }
    ;
	
lvalue
    : unary_expr
    ;

conditional_expr
    : logical_or_expr ( '?' expression ':' conditional_expr )?
    ;

logical_or_expr
    : logical_and_expr ( '||' logical_and_expr )*
    ;

logical_and_expr
    : inclusive_or_expr ( '&&' inclusive_or_expr )*
    ;

inclusive_or_expr
    : exclusive_or_expr ( '|' exclusive_or_expr )*
    ;

exclusive_or_expr
    : and_expr ( '^' and_expr )*
    ;

and_expr
    : equality_expr ( '&' equality_expr )*
    ;

equality_expr
    : relational_expr ( ( '==' | '!=' ) relational_expr )*
    ;

relational_expr
    : shift_expr ( ( '<' | '>' | '<=' | '>=' ) shift_expr )*
    ;

shift_expr
    : add_expr ( ( '<<' | '>>' ) add_expr )*
    ;
				  
// Statements
statements
    :statement statements
    |;

statement
    : selection_statement
    | iteration_statement
    | jump_statement
    | compound_statement
    | expression_statement
    | printf_statement
    ;

expression_statement
    : SEMI_COLON   
    | expression SEMI_COLON  
    ;

compound_statement
    : LCURLY_BRACKET  declarations statement_list? RCURLY_BRACKET
    ;

statement_list
    : statement+
    ;

selection_statement 
    : IF_TYPE LPARENTHESIS expression RPARENTHESIS statement ( (ELSE_TYPE) => ELSE_TYPE statement )? { if(TRACEON) System.out.println("type: IF_TYPE");}
    { if(TRACEON) System.out.println( "selection: " + $IF_TYPE.text ); }
    ;

jump_statement
    : GOTO_TYPE ID SEMI_COLON 
    { if(TRACEON) System.out.println( "jump: " + $GOTO_TYPE.text ); }
    | CONTINUE_TYPE SEMI_COLON 
    { if(TRACEON) System.out.println( "jump: " + $CONTINUE_TYPE.text ); }
    | BREAK_TYPE SEMI_COLON 
    { if(TRACEON) System.out.println( "jump: " + $BREAK_TYPE.text ); }
    | RETURN_TYPE SEMI_COLON 
    { if(TRACEON) System.out.println( "jump: " + $RETURN_TYPE.text ); }
    | RETURN_TYPE expression SEMI_COLON
    { if(TRACEON) System.out.println( "jump: " + $RETURN_TYPE.text ); }
    ;

iteration_statement
    : WHILE_TYPE LPARENTHESIS expression RPARENTHESIS statement   
    { if(TRACEON) System.out.println( "iteration: " + $WHILE_TYPE.text ); }
    | DO_TYPE statement WHILE_TYPE LPARENTHESIS expression RPARENTHESIS SEMI_COLON 
    { if(TRACEON) System.out.println( "iteration: " + $DO_TYPE.text + " " + $WHILE_TYPE.text ); }
    | FOR_TYPE LPARENTHESIS expression_statement expression_statement expression? RPARENTHESIS statement
    { if(TRACEON) System.out.println( "iteration: " + $FOR_TYPE.text ); }
    ;

printf_statement
    : PRINTF_TYPE LPARENTHESIS  STR_LITERAL  ( COMMA ID )* RPARENTHESIS statement
    { if(TRACEON) System.out.println( "printf" ); }
    ;

/* description of the tokens */
    
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

EXTERN_TYPE : 'extern';
STATIC_TYPE : 'static';

CONST_TYPE : 'const';
VOLATILE_TYPE : 'volatile';

GOTO_TYPE : 'goto';
BREAK_TYPE : 'break';
CONTINUE_TYPE : 'continue';
RETURN_TYPE : 'return';

FOR_TYPE : 'for';
DO_TYPE : 'do';
WHILE_TYPE : 'while';
IF_TYPE : 'if';
ELSE_TYPE : 'else';
PRINTF_TYPE : 'printf';

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

/*----------------------*/
/*       Literal        */
/*----------------------*/
CHAR_LITERAL : '\''( ESCAPESEQ | ~( '\'' | '\\' ) )'\'';
STR_LITERAL : '"'( ESCAPESEQ | ~( '\\' | '"' ) )*'"';

fragment HEXDIGIT : ( '0'..'9' | 'a'..'f' | 'A'..'F' );
fragment ESCAPESEQ : '\\'( 'b' | 't' | 'n' | 'f' | 'r' | '\"' | '\'' | '\\' );
 
/* Comments */
COMMENT1 : '//'(.)*'\n'{ $channel=HIDDEN; };
COMMENT2 : '/*' (options{greedy=false;}: .)* '*/'{ $channel=HIDDEN; };

fragment LETTER : 'a'..'z' | 'A'..'Z' | '_';
fragment DIGIT : '0'..'9';

WS  : ( ' ' | '\r' | '\t' | '\n' ) { $channel=HIDDEN; };
