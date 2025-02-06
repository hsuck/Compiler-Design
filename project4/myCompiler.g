grammar myCompiler;

options {
   language = Java;
}

@header {
    // import packages here.
    import java.util.HashMap;
    import java.util.ArrayList;
}

@members {
    boolean TRACEON = false;

    // Type information.
    public enum Type{
       ERR, BOOL, INT, FLOAT, CHAR, CONST_INT, CONST_FLOAT;
    }

    public enum RelationalOP_type{
      GT, GE, LT, LE, EQ, NE;
   }

    // This structure is used to record the information of a variable or a constant.
    class tVar {
	   int   varIndex; // temporary variable's index. Ex: t1, t2, ..., etc.
	   int   iValue;   // value of constant integer. Ex: 123.
	   float fValue;   // value of constant floating point. Ex: 2.314.
	};

    class Info {
       Type theType;  // type information.
       tVar theVar;
	   
	   Info() {
          theType = Type.ERR;
		  theVar = new tVar();
	   }
    };

	
    // ============================================
    // Create a symbol table.
	// ArrayList is easy to extend to add more info. into symbol table.
	//
	// The structure of symbol table:
	// <variable ID, [Type, [varIndex or iValue, or fValue]]>
	//    - type: the variable type   (please check "enum Type")
	//    - varIndex: the variable's index, ex: t1, t2, ...
	//    - iValue: value of integer constant.
	//    - fValue: value of floating-point constant.
    // ============================================

    HashMap<String, Info> symtab = new HashMap<String, Info>();

    // labelCount is used to represent temporary label.
    // The first index is 0.
    int labelCount = 0;
	
    // varCount is used to represent temporary variables.
    // The first index is 0.
    int varCount = 0;

    // Record all assembly instructions.
    List<String> TextCode = new ArrayList<String>();

    int printfCount = 2;

    int condCount = 0;

    /*
     * Output prologue.
     */
    void prologue(){
       TextCode.add("; === prologue ====");
       TextCode.add("declare dso_local i32 @printf(i8*, ...)");
	   TextCode.add("define dso_local i32 @main()");
	   TextCode.add("{");
    }
    
	
    /*
     * Output epilogue.
     */
    void epilogue(){
       /* handle epilogue */
       TextCode.add("\n; === epilogue ===");
	   TextCode.add("\tret i32 0");
       TextCode.add("}");
    }
    
    
    /* Generate a new label */
    String newLabel(){
       labelCount ++;
       return (new String("L")) + Integer.toString(labelCount);
    } 
    
    
    public List<String> getTextCode(){
       return TextCode;
    }
}

program
    : type MAIN '(' ')'
        {
           /* Output function prologue */
           prologue();
        }

        '{' 
           declarations
           statements
        '}'
        {
            if (TRACEON)
                System.out.println("VOID MAIN () {declarations statements}");

            /* output function epilogue */	  
            epilogue();
        }
        ;


declarations
    : type Identifier ';' declarations
        {
           if (TRACEON)
              System.out.println("declarations: type Identifier : declarations");

           if (symtab.containsKey($Identifier.text)) {
              // variable re-declared.
              System.out.println("Type Error: " + 
                                  $Identifier.getLine() + 
                                 ": Redeclared identifier.");
              System.exit(0);
           }
                 
           /* Add ID and its info into the symbol table. */
	       Info the_entry = new Info();
		   the_entry.theType = $type.attr_type;
		   the_entry.theVar.varIndex = varCount;
		   varCount ++;
		   symtab.put($Identifier.text, the_entry);

           // issue the instruction.
		   // Ex: \%a = alloca i32, align 4
           if ($type.attr_type == Type.INT) { 
              TextCode.add("\t\%t" + the_entry.theVar.varIndex + " = alloca i32, align 4");
           }
           else if( $type.attr_type == Type.FLOAT ){ 
              TextCode.add( "\t\%t" + the_entry.theVar.varIndex + " = alloca float" );
           }
           else if( $type.attr_type == Type.CHAR ){ 
              TextCode.add( "\t\%t" + the_entry.theVar.varIndex + " = alloca i8" );
           }
        }
    | 
        {
           if (TRACEON)
              System.out.println("declarations: ");
        }
    ;


type returns [ Type attr_type ]
    : INT { if (TRACEON) System.out.println("type: INT"); $attr_type=Type.INT; }
    | CHAR { if (TRACEON) System.out.println("type: CHAR"); $attr_type=Type.CHAR; }
    | FLOAT {if (TRACEON) System.out.println("type: FLOAT"); $attr_type=Type.FLOAT; }
	;


statements:statement statements
    |
    ;


statement
    : assign_stmt ';'
    | if_stmt
    | func_no_return_stmt ';'
    | for_stmt
    | printf_stmt
    ;

printf_stmt
    : 'printf' '('  STRING_LITERAL ( ',' a = argument )? ')' ';'
        {
            String newStr = $STRING_LITERAL.text;
            int len = newStr.length();
            int matched = 0;
            int pos = newStr.indexOf( "\\n", 0 );

            while( pos != -1 ){
                matched++;
                pos = newStr.indexOf( "\\n", pos + 1 );
            }

            // plus 1 for end of string, subtract 2 for double qoute
            len = len - matched - 2 + 1;

            newStr = newStr.replace( "\\n", "\\0A" );
            newStr = newStr.substring( 0, newStr.length() - 1 ) + "\\00" + "\"";
            
            // get argument list
            String arg_list = "";
            if( $a.text != null ){
                for( int i = 0; i < $a.rec.size(); i++ ){
                    Type theType = $a.rec.get( i ).theType;
                    switch( theType ){
                        case INT:
                            arg_list = arg_list.concat( ", i32 \%t" + $a.rec.get( i ).theVar.varIndex );
                            break;

                        case FLOAT:
                            arg_list = arg_list.concat( ", double \%t" + $a.rec.get( i ).theVar.varIndex );
                            break;
                    }
                }
            }

            TextCode.add( printfCount, "@.str." + ( printfCount - 2 ) + " = private unnamed_addr constant [" +
                        len + " x i8] c" + newStr + ", align 1" );
            TextCode.add( "\t\%t" + varCount + " = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([" +
                        len + " x i8], [" + (len) + " x i8]* @.str." + ( printfCount - 2 ) + ", i64 0, i64 0)" + 
                        arg_list + ")" );
            printfCount++;
            varCount++;
            
            if (TRACEON) { 
                System.out.println("PRINT '(\"' STRING_LITERAL '\")'"); 
            }
        }
    ;

for_stmt
@init{ String assign = newLabel(); }
    : FOR '(' assign_stmt ';'
                    {
                        String loop = newLabel();
                        // System.out.println( loop );
                        TextCode.add( "\tbr label \%" + loop );
                        TextCode.add( "\n" + loop + ":" );
                    }
                  a = cond_expression ';'
                    {
                        TextCode.add( "\tbr i1 \%cond" + condCount + ", label \%" + $a.ltrue + ", label \%" + $a.lfalse );
                        TextCode.add( "\n" + assign + ":" );
                        condCount++;
                    }
                  assign_stmt
                    {
                        TextCode.add( "\tbr label \%" + loop );
                        TextCode.add( "\n" + $a.ltrue + ":" );
                    }
                ')'
                  block_stmt
                    {
                        if( TRACEON ) System.out.println("After block_stmt");

                        TextCode.add( "\tbr label \%" + assign );
                        TextCode.add( "\n" + $a.lfalse + ":" );
                    }
    ;
		 
		 
if_stmt
    : if_then_stmt if_else_stmt
        {
            TextCode.add( "\tbr label \%" + $if_then_stmt.lend );
            TextCode.add( "\n" + $if_then_stmt.lend + ":" );
        }
    ;

	   
if_then_stmt returns [ String lend ]
            : IF '(' cond_expression
                        {
                            TextCode.add( "\tbr i1 \%cond" + condCount + ", label \%" + $cond_expression.ltrue + ", label \%" + $cond_expression.lfalse );
                            TextCode.add( "\n" + $cond_expression.ltrue + ":" );
                            condCount++;
                        }
                   ')' block_stmt
                        {
                            if( TRACEON ) System.out.println("IF '(' cond_expression ')' block_stmt"); 

                            lend = newLabel();

                            TextCode.add( "\tbr label \%" + lend );
                            TextCode.add( "\n" + $cond_expression.lfalse + ":" );
                        }

            ;


if_else_stmt
    : ELSE block_stmt
        { 
            if( TRACEON ) System.out.println("ELSE block_stmt"); 
        }
    |
    ;

				  
block_stmt
    : '{' statements '}'
        {
            if( TRACEON ) System.out.println("'{' statements '}'");
        }
	;


assign_stmt
    : Identifier '=' arith_expression
        {
            Info theRHS = $arith_expression.theInfo;
            Info theLHS;

            if( symtab.containsKey( $Identifier.text ) ){
                theLHS = symtab.get( $Identifier.text );
                if( ( theLHS.theType == Type.INT ) && ( theRHS.theType == Type.INT ) ){		   
                    // issue store instruction.

                    // Ex: store i32 \%tx, i32* \%ty
                    TextCode.add( "\tstore i32 \%t" + theRHS.theVar.varIndex + ", i32* \%t" + theLHS.theVar.varIndex + ", align 4" );
                } 
                else if( ( theLHS.theType == Type.INT ) && ( theRHS.theType == Type.CONST_INT ) ){
                    // issue store instruction.

                    // Ex: store i32 value, i32* \%ty
                    TextCode.add( "\tstore i32 " + theRHS.theVar.iValue + ", i32* \%t" + theLHS.theVar.varIndex + ", align 4" );				
                }
                else if( ( theLHS.theType == Type.FLOAT ) && ( theRHS.theType == Type.FLOAT ) ){		   
                    // issue store instruction.

                    // Ex: store float \%tx, float* \%ty
                    TextCode.add( "\tstore float \%t" + theRHS.theVar.varIndex + ", float* \%t" + theLHS.theVar.varIndex + ", align 4" );
                } 
                else if( ( theLHS.theType == Type.FLOAT ) && ( theRHS.theType == Type.CONST_FLOAT ) ){
                    double val2 = theRHS.theVar.fValue;
                    // System.out.println( val2 );
                    long ans2 = Double.doubleToLongBits( val2 );
                    // System.out.println( Long.toHexString( ans2 ) );
                    // issue store instruction.

                    // Ex: store float value, float* \%ty
                    TextCode.add( "\tstore float 0x" + Long.toHexString( ans2 ) + ", float* \%t" + theLHS.theVar.varIndex + ", align 4" );				
                }
                else if( ( theLHS.theType != theRHS.theType )  &&  ( theLHS.theType != Type.ERR ) && ( theRHS.theType != Type.ERR ) ){
                    System.out.println( "Error: " +
                                                            $Identifier.getLine() +
                                                            ": Type mismatch for the = operation in an expression." );
                    System.exit(0);
                }
            }
            else{
                System.out.println( "Error: " + 
                                                            $Identifier.getLine() + 
                                                            ": Undeclared identifier : " +
                                                            $Identifier.text );
                System.exit(0);
            }
        }
        ;

		   
func_no_return_stmt
    : Identifier '(' argument ')'
    ;


argument returns [ List<Info> rec ]
@init{ $rec = new ArrayList<Info>(); }
    : a = arg 
        {
            $rec.add( $a.theInfo );
            if( $a.theInfo.theType == Type.FLOAT ){
                TextCode.add( "\t\%t" + varCount + " = fpext float \%t" + $a.theInfo.theVar.varIndex + " to double" );
                $a.theInfo.theVar.varIndex = varCount;
                varCount++;
            }
        } 
    ( ',' b = arg 
        {
            $rec.add( $b.theInfo );
            if( $b.theInfo.theType == Type.FLOAT ){
                TextCode.add( "\t\%t" + varCount + " = fpext float \%t" + $b.theInfo.theVar.varIndex + " to double" );
                $b.theInfo.theVar.varIndex = varCount;
                varCount++;
            }
        } 
   )* 
   ;

arg returns [ Info theInfo ]
    : a = arith_expression
        {
            $theInfo = $a.theInfo;
        }
    | STRING_LITERAL
    ;
		   
cond_expression returns [ String ltrue, String lfalse ]
    : a = arith_expression (relationop b = arith_expression)*
        { 
            if( TRACEON ) System.out.println("a=arith_expression (relationop b=arith_expression)*");
            // System.out.println( $a.theInfo.theType + " " +$b.theInfo.theType );

            // Greater than >
            if( $relationop.r_type == RelationalOP_type.GT ){
                if( ( $a.theInfo.theType == Type.INT ) && ( $b.theInfo.theType == Type.INT ) ){ 
                    TextCode.add( "\t\%cond" + condCount + " = icmp sgt i32 \%t" + $a.theInfo.theVar.varIndex +
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType == Type.INT ) && ( $b.theInfo.theType == Type.CONST_INT ) ){
                TextCode.add( "\t\%cond" + condCount + " = icmp sgt i32 \%t" + $a.theInfo.theVar.varIndex +
                                            ", " + $b.theInfo.theVar.iValue );
                }
                else if( ( $a.theInfo.theType == Type.CONST_INT ) && ( $b.theInfo.theType == Type.CONST_INT ) ){
                    TextCode.add( "\t\%cond" + condCount + " = icmp sgt i32 " + $b.theInfo.theVar.iValue +
                                                ", " + $b.theInfo.theVar.iValue );
                }
                else if( ( $a.theInfo.theType == Type.CONST_INT ) && ( $b.theInfo.theType == Type.INT ) ){
                    TextCode.add( "\t\%cond" + condCount + " = icmp sgt i32 " + $a.theInfo.theVar.iValue +
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType == Type.FLOAT ) && ( $b.theInfo.theType == Type.FLOAT ) ){
                    TextCode.add( "\t\%cond" + condCount + " = fcmp ogt float \%t" + $a.theInfo.theVar.varIndex + 
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType == Type.FLOAT ) && ( $b.theInfo.theType == Type.CONST_FLOAT ) ){
                    double val2 = $b.theInfo.theVar.fValue;
                    long ans2 = Double.doubleToLongBits( val2 );
                    TextCode.add( "\t\%cond" + condCount + " = fcmp ogt float \%t" + $a.theInfo.theVar.varIndex + 
                                                ", 0x" + Long.toHexString( ans2 ) );
                }
                else if( ( $a.theInfo.theType == Type.CONST_FLOAT ) && ( $b.theInfo.theType == Type.CONST_FLOAT ) ){
                    double val1 = $a.theInfo.theVar.fValue;
                    long ans1 = Double.doubleToLongBits( val1 );
                    double val2 = $b.theInfo.theVar.fValue;
                    long ans2 = Double.doubleToLongBits( val2 );
                    TextCode.add( "\t\%cond" + condCount + " = fcmp ogt float 0x" + Long.toHexString( ans1 ) + 
                                                ", 0x" + Long.toHexString( ans2 ) );
                }
                else if( ( $a.theInfo.theType == Type.CONST_FLOAT ) && ( $b.theInfo.theType == Type.FLOAT ) ){
                    double val1 = $a.theInfo.theVar.fValue;
                    long ans1 = Double.doubleToLongBits( val1 );
                    TextCode.add( "\t\%cond" + condCount + " = fcmp ogt float 0x" + Long.toHexString( ans1 ) + 
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType != $b.theInfo.theType )  &&  ( $a.theInfo.theType != Type.ERR ) && ( $b.theInfo.theType != Type.ERR ) ){
                    System.out.println( "Error: " +
                                                            $a.start.getLine() +
                                                            ": Type mismatch for the > operation in an expression." );
                    $a.theInfo.theType = Type.ERR;                                                          
                    System.exit(0);
                }
            }
            // Greater than or equal >=
            else if( $relationop.r_type == RelationalOP_type.GE ){
                if( ( $a.theInfo.theType == Type.INT ) && ( $b.theInfo.theType == Type.INT ) ){ 
                    TextCode.add( "\t\%cond" + condCount + " = icmp sge i32 \%t" + $a.theInfo.theVar.varIndex +
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType == Type.INT ) && ( $b.theInfo.theType == Type.CONST_INT ) ){
                TextCode.add( "\t\%cond" + condCount + " = icmp sge i32 \%t" + $a.theInfo.theVar.varIndex +
                                            ", " + $b.theInfo.theVar.iValue );
                }
                else if( ( $a.theInfo.theType == Type.CONST_INT ) && ( $b.theInfo.theType == Type.CONST_INT ) ){
                    TextCode.add( "\t\%cond" + condCount + " = icmp sge i32 " + $b.theInfo.theVar.iValue +
                                                ", " + $b.theInfo.theVar.iValue );
                }
                else if( ( $a.theInfo.theType == Type.CONST_INT ) && ( $b.theInfo.theType == Type.INT ) ){
                    TextCode.add( "\t\%cond" + condCount + " = icmp sge i32 " + $a.theInfo.theVar.iValue +
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType == Type.FLOAT ) && ( $b.theInfo.theType == Type.FLOAT ) ){
                    TextCode.add( "\t\%cond" + condCount + " = fcmp oge float \%t" + $a.theInfo.theVar.varIndex + 
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType == Type.FLOAT ) && ( $b.theInfo.theType == Type.CONST_FLOAT ) ){
                    double val2 = $b.theInfo.theVar.fValue;
                    long ans2 = Double.doubleToLongBits( val2 );
                    TextCode.add( "\t\%cond" + condCount + " = fcmp oge float \%t" + $a.theInfo.theVar.varIndex + 
                                                ", 0x" + Long.toHexString( ans2 ) );
                }
                else if( ( $a.theInfo.theType == Type.CONST_FLOAT ) && ( $b.theInfo.theType == Type.CONST_FLOAT ) ){
                    double val1 = $a.theInfo.theVar.fValue;
                    long ans1 = Double.doubleToLongBits( val1 );
                    double val2 = $b.theInfo.theVar.fValue;
                    long ans2 = Double.doubleToLongBits( val2 );
                    TextCode.add( "\t\%cond" + condCount + " = fcmp oge float 0x" + Long.toHexString( ans1 ) + 
                                                ", 0x" + Long.toHexString( ans2 ) );
                }
                else if( ( $a.theInfo.theType == Type.CONST_FLOAT ) && ( $b.theInfo.theType == Type.FLOAT ) ){
                    double val1 = $a.theInfo.theVar.fValue;
                    long ans1 = Double.doubleToLongBits( val1 );
                    TextCode.add( "\t\%cond" + condCount + " = fcmp oge float 0x" + Long.toHexString( ans1 ) + 
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType != $b.theInfo.theType )  &&  ( $a.theInfo.theType != Type.ERR ) && ( $b.theInfo.theType != Type.ERR ) ){
                    System.out.println( "Error: " +
                                                            $a.start.getLine() +
                                                            ": Type mismatch for the >= operation in an expression." );
                    $a.theInfo.theType = Type.ERR;                                                          
                    System.exit(0);
                }
            }
            // Less than <
            else if( $relationop.r_type == RelationalOP_type.LT ){
                if( ( $a.theInfo.theType == Type.INT ) && ( $b.theInfo.theType == Type.INT ) ){ 
                    TextCode.add( "\t\%cond" + condCount + " = icmp slt i32 \%t" + $a.theInfo.theVar.varIndex +
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType == Type.INT ) && ( $b.theInfo.theType == Type.CONST_INT ) ){
                TextCode.add( "\t\%cond" + condCount + " = icmp slt i32 \%t" + $a.theInfo.theVar.varIndex +
                                            ", " + $b.theInfo.theVar.iValue );
                }
                else if( ( $a.theInfo.theType == Type.CONST_INT ) && ( $b.theInfo.theType == Type.CONST_INT ) ){
                    TextCode.add( "\t\%cond" + condCount + " = icmp slt i32 " + $b.theInfo.theVar.iValue +
                                                ", " + $b.theInfo.theVar.iValue );
                }
                else if( ( $a.theInfo.theType == Type.CONST_INT ) && ( $b.theInfo.theType == Type.INT ) ){
                    TextCode.add( "\t\%cond" + condCount + " = icmp slt i32 " + $a.theInfo.theVar.iValue +
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType == Type.FLOAT ) && ( $b.theInfo.theType == Type.FLOAT ) ){
                    TextCode.add( "\t\%cond" + condCount + " = fcmp olt float \%t" + $a.theInfo.theVar.varIndex + 
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType == Type.FLOAT ) && ( $b.theInfo.theType == Type.CONST_FLOAT ) ){
                    double val2 = $b.theInfo.theVar.fValue;
                    long ans2 = Double.doubleToLongBits( val2 );
                    TextCode.add( "\t\%cond" + condCount + " = fcmp olt float \%t" + $a.theInfo.theVar.varIndex + 
                                                ", 0x" + Long.toHexString( ans2 ) );
                }
                else if( ( $a.theInfo.theType == Type.CONST_FLOAT ) && ( $b.theInfo.theType == Type.CONST_FLOAT ) ){
                    double val1 = $a.theInfo.theVar.fValue;
                    long ans1 = Double.doubleToLongBits( val1 );
                    double val2 = $b.theInfo.theVar.fValue;
                    long ans2 = Double.doubleToLongBits( val2 );
                    TextCode.add( "\t\%cond" + condCount + " = fcmp olt float 0x" + Long.toHexString( ans1 ) + 
                                                ", 0x" + Long.toHexString( ans2 ) );
                }
                else if( ( $a.theInfo.theType == Type.CONST_FLOAT ) && ( $b.theInfo.theType == Type.FLOAT ) ){
                    double val1 = $a.theInfo.theVar.fValue;
                    long ans1 = Double.doubleToLongBits( val1 );
                    TextCode.add( "\t\%cond" + condCount + " = fcmp olt float 0x" + Long.toHexString( ans1 ) + 
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType != $b.theInfo.theType )  &&  ( $a.theInfo.theType != Type.ERR ) && ( $b.theInfo.theType != Type.ERR ) ){
                    System.out.println( "Error: " +
                                                            $a.start.getLine() +
                                                            ": Type mismatch for the < operation in an expression." );
                    $a.theInfo.theType = Type.ERR;                                                          
                    System.exit(0);
                }
            }
            // Less than or equal <=
            else if( $relationop.r_type == RelationalOP_type.LE ){
                if( ( $a.theInfo.theType == Type.INT ) && ( $b.theInfo.theType == Type.INT ) ){ 
                    TextCode.add( "\t\%cond" + condCount + " = icmp slt i32 \%t" + $a.theInfo.theVar.varIndex +
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType == Type.INT ) && ( $b.theInfo.theType == Type.CONST_INT ) ){
                TextCode.add( "\t\%cond" + condCount + " = icmp slt i32 \%t" + $a.theInfo.theVar.varIndex +
                                            ", " + $b.theInfo.theVar.iValue );
                }
                else if( ( $a.theInfo.theType == Type.CONST_INT ) && ( $b.theInfo.theType == Type.CONST_INT ) ){
                    TextCode.add( "\t\%cond" + condCount + " = icmp slt i32 " + $b.theInfo.theVar.iValue +
                                                ", " + $b.theInfo.theVar.iValue );
                }
                else if( ( $a.theInfo.theType == Type.CONST_INT ) && ( $b.theInfo.theType == Type.INT ) ){
                    TextCode.add( "\t\%cond" + condCount + " = icmp slt i32 " + $a.theInfo.theVar.iValue +
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType == Type.FLOAT ) && ( $b.theInfo.theType == Type.FLOAT ) ){
                    TextCode.add( "\t\%cond" + condCount + " = fcmp olt float \%t" + $a.theInfo.theVar.varIndex + 
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType == Type.FLOAT ) && ( $b.theInfo.theType == Type.CONST_FLOAT ) ){
                    double val2 = $b.theInfo.theVar.fValue;
                    long ans2 = Double.doubleToLongBits( val2 );
                    TextCode.add( "\t\%cond" + condCount + " = fcmp olt float \%t" + $a.theInfo.theVar.varIndex + 
                                                ", 0x" + Long.toHexString( ans2 ) );
                }
                else if( ( $a.theInfo.theType == Type.CONST_FLOAT ) && ( $b.theInfo.theType == Type.CONST_FLOAT ) ){
                    double val1 = $a.theInfo.theVar.fValue;
                    long ans1 = Double.doubleToLongBits( val1 );
                    double val2 = $b.theInfo.theVar.fValue;
                    long ans2 = Double.doubleToLongBits( val2 );
                    TextCode.add( "\t\%cond" + condCount + " = fcmp olt float 0x" + Long.toHexString( ans1 ) + 
                                                ", 0x" + Long.toHexString( ans2 ) );
                }
                else if( ( $a.theInfo.theType == Type.CONST_FLOAT ) && ( $b.theInfo.theType == Type.FLOAT ) ){
                    double val1 = $a.theInfo.theVar.fValue;
                    long ans1 = Double.doubleToLongBits( val1 );
                    TextCode.add( "\t\%cond" + condCount + " = fcmp olt float 0x" + Long.toHexString( ans1 ) + 
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType != $b.theInfo.theType )  &&  ( $a.theInfo.theType != Type.ERR ) && ( $b.theInfo.theType != Type.ERR ) ){
                    System.out.println( "Error: " +
                                                            $a.start.getLine() +
                                                            ": Type mismatch for the <= operation in an expression." );
                    $a.theInfo.theType = Type.ERR;                                                          
                    System.exit(0);
                }
            }
            // Equal ==
            else if( $relationop.r_type == RelationalOP_type.EQ ){
                if( ( $a.theInfo.theType == Type.INT ) && ( $b.theInfo.theType == Type.INT ) ){ 
                    TextCode.add( "\t\%cond" + condCount + " = icmp eq i32 \%t" + $a.theInfo.theVar.varIndex +
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType == Type.INT ) && ( $b.theInfo.theType == Type.CONST_INT ) ){
                TextCode.add( "\t\%cond" + condCount + " = icmp eq i32 \%t" + $a.theInfo.theVar.varIndex +
                                            ", " + $b.theInfo.theVar.iValue );
                }
                else if( ( $a.theInfo.theType == Type.CONST_INT ) && ( $b.theInfo.theType == Type.CONST_INT ) ){
                    TextCode.add( "\t\%cond" + condCount + " = icmp eq i32 " + $b.theInfo.theVar.iValue +
                                                ", " + $b.theInfo.theVar.iValue );
                }
                else if( ( $a.theInfo.theType == Type.CONST_INT ) && ( $b.theInfo.theType == Type.INT ) ){
                    TextCode.add( "\t\%cond" + condCount + " = icmp eq i32 " + $a.theInfo.theVar.iValue +
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType == Type.FLOAT ) && ( $b.theInfo.theType == Type.FLOAT ) ){
                    TextCode.add( "\t\%cond" + condCount + " = fcmp oeq float \%t" + $a.theInfo.theVar.varIndex + 
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType == Type.FLOAT ) && ( $b.theInfo.theType == Type.CONST_FLOAT ) ){
                    double val2 = $b.theInfo.theVar.fValue;
                    long ans2 = Double.doubleToLongBits( val2 );
                    TextCode.add( "\t\%cond" + condCount + " = fcmp oeq float \%t" + $a.theInfo.theVar.varIndex + 
                                                ", 0x" + Long.toHexString( ans2 ) );
                }
                else if( ( $a.theInfo.theType == Type.CONST_FLOAT ) && ( $b.theInfo.theType == Type.CONST_FLOAT ) ){
                    double val1 = $a.theInfo.theVar.fValue;
                    long ans1 = Double.doubleToLongBits( val1 );
                    double val2 = $b.theInfo.theVar.fValue;
                    long ans2 = Double.doubleToLongBits( val2 );
                    TextCode.add( "\t\%cond" + condCount + " = fcmp oeq float 0x" + Long.toHexString( ans1 ) + 
                                                ", 0x" + Long.toHexString( ans2 ) );
                }
                else if( ( $a.theInfo.theType == Type.CONST_FLOAT ) && ( $b.theInfo.theType == Type.FLOAT ) ){
                    double val1 = $a.theInfo.theVar.fValue;
                    long ans1 = Double.doubleToLongBits( val1 );
                    TextCode.add( "\t\%cond" + condCount + " = fcmp oeq float 0x" + Long.toHexString( ans1 ) + 
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType != $b.theInfo.theType )  &&  ( $a.theInfo.theType != Type.ERR ) && ( $b.theInfo.theType != Type.ERR ) ){
                    System.out.println( "Error: " +
                                                            $a.start.getLine() +
                                                            ": Type mismatch for the == operation in an expression." );
                    $a.theInfo.theType = Type.ERR;                                                          
                    System.exit(0);
                }
            }
            // Nor equal !=
            else if( $relationop.r_type == RelationalOP_type.NE ){
                if( ( $a.theInfo.theType == Type.INT ) && ( $b.theInfo.theType == Type.INT ) ){ 
                    TextCode.add( "\t\%cond" + condCount + " = icmp ne i32 \%t" + $a.theInfo.theVar.varIndex +
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType == Type.INT ) && ( $b.theInfo.theType == Type.CONST_INT ) ){
                TextCode.add( "\t\%cond" + condCount + " = icmp ne i32 \%t" + $a.theInfo.theVar.varIndex +
                                            ", " + $b.theInfo.theVar.iValue );
                }
                else if( ( $a.theInfo.theType == Type.CONST_INT ) && ( $b.theInfo.theType == Type.CONST_INT ) ){
                    TextCode.add( "\t\%cond" + condCount + " = icmp ne i32 " + $b.theInfo.theVar.iValue +
                                                ", " + $b.theInfo.theVar.iValue );
                }
                else if( ( $a.theInfo.theType == Type.CONST_INT ) && ( $b.theInfo.theType == Type.INT ) ){
                    TextCode.add( "\t\%cond" + condCount + " = icmp ne i32 " + $a.theInfo.theVar.iValue +
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType == Type.FLOAT ) && ( $b.theInfo.theType == Type.FLOAT ) ){
                    TextCode.add( "\t\%cond" + condCount + " = fcmp one float \%t" + $a.theInfo.theVar.varIndex + 
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType == Type.FLOAT ) && ( $b.theInfo.theType == Type.CONST_FLOAT ) ){
                    double val2 = $b.theInfo.theVar.fValue;
                    long ans2 = Double.doubleToLongBits( val2 );
                    TextCode.add( "\t\%cond" + condCount + " = fcmp one float \%t" + $a.theInfo.theVar.varIndex + 
                                                ", 0x" + Long.toHexString( ans2 ) );
                }
                else if( ( $a.theInfo.theType == Type.CONST_FLOAT ) && ( $b.theInfo.theType == Type.CONST_FLOAT ) ){
                    double val1 = $a.theInfo.theVar.fValue;
                    long ans1 = Double.doubleToLongBits( val1 );
                    double val2 = $b.theInfo.theVar.fValue;
                    long ans2 = Double.doubleToLongBits( val2 );
                    TextCode.add( "\t\%cond" + condCount + " = fcmp one float 0x" + Long.toHexString( ans1 ) + 
                                                ", 0x" + Long.toHexString( ans2 ) );
                }
                else if( ( $a.theInfo.theType == Type.CONST_FLOAT ) && ( $b.theInfo.theType == Type.FLOAT ) ){
                    double val1 = $a.theInfo.theVar.fValue;
                    long ans1 = Double.doubleToLongBits( val1 );
                    TextCode.add( "\t\%cond" + condCount + " = fcmp one float 0x" + Long.toHexString( ans1 )  + 
                                                ", \%t" + $b.theInfo.theVar.varIndex );
                }
                else if( ( $a.theInfo.theType != $b.theInfo.theType )  &&  ( $a.theInfo.theType != Type.ERR ) && ( $b.theInfo.theType != Type.ERR ) ){
                    System.out.println( "Error: " +
                                                            $a.start.getLine() +
                                                            ": Type mismatch for the != operation in an expression." );
                    $a.theInfo.theType = Type.ERR;                                                          
                    System.exit(0);
                }
            }
            // condCount++;
            $ltrue = newLabel();
            $lfalse = newLabel();
        }
    ;

relationop returns [ RelationalOP_type r_type ]
    : GT 
        { 
            if( TRACEON ) System.out.println("Relation operator: >");
            $r_type = RelationalOP_type.GT; 
        }
    | GE 
        { 
            if( TRACEON ) System.out.println("Relation operator: >=");
            $r_type = RelationalOP_type.GE; 
        }
    | LT 
        { 
            if( TRACEON ) System.out.println("Relation operator: <");
            $r_type = RelationalOP_type.LT; 
        }
    | LE 
        { 
            if( TRACEON ) System.out.println("Relation operator: <=");
            $r_type = RelationalOP_type.LE; 
        }
    | EQ 
        { 
            if( TRACEON ) System.out.println("Relation operator: ==");
            $r_type = RelationalOP_type.EQ; 
        }
    | NE 
        { 
            if( TRACEON ) System.out.println("Relation operator: !=");
            $r_type = RelationalOP_type.NE; 
        }
    ;
			   
arith_expression returns [ Info theInfo ]
@init{ $theInfo = new Info(); }
    : a = multExpr { $theInfo = $a.theInfo; }
    ( '+' b = multExpr
        {				  
            // code generation.		
            // Int			   
            // System.out.println( $a.theInfo.theType + " " +$b.theInfo.theType );
            if( ( $a.theInfo.theType == Type.INT ) && ( $b.theInfo.theType == Type.INT ) ){
                TextCode.add( "\t\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.INT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            } 
            else if( ( $a.theInfo.theType == Type.INT ) && ( $b.theInfo.theType == Type.CONST_INT ) ){
                TextCode.add( "\t\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.INT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            else if( ( $a.theInfo.theType == Type.CONST_INT ) && ( $b.theInfo.theType == Type.CONST_INT ) ){
                // System.out.println( $a.theInfo.theType + " " +$b.theInfo.theType );
                TextCode.add( "\t\%t" + varCount + " = add nsw i32 " + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.INT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            else if( ( $a.theInfo.theType == Type.CONST_INT ) && ( $b.theInfo.theType == Type.INT ) ){
                TextCode.add( "\t\%t" + varCount + " = add nsw i32 " + $theInfo.theVar.iValue + ", \%t" + $b.theInfo.theVar.varIndex );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.INT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            // Floating point
            else if( ( $a.theInfo.theType == Type.FLOAT ) && ( $b.theInfo.theType == Type.FLOAT ) ){
                TextCode.add( "\t\%t" + varCount + " = fadd float \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.FLOAT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            } 
            else if( ( $a.theInfo.theType == Type.FLOAT ) && ( $b.theInfo.theType == Type.CONST_FLOAT ) ){
                double val2 = $b.theInfo.theVar.fValue;
                long ans2 = Double.doubleToLongBits( val2 );
                TextCode.add( "\t\%t" + varCount + " = fadd float \%t" + $theInfo.theVar.varIndex + ", 0x" + Long.toHexString( ans2 ) );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.FLOAT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            else if( ( $a.theInfo.theType == Type.CONST_FLOAT ) && ( $b.theInfo.theType == Type.CONST_FLOAT ) ){
                double val1 = $a.theInfo.theVar.fValue;
                long ans1 = Double.doubleToLongBits( val1 );
                double val2 = $b.theInfo.theVar.fValue;
                long ans2 = Double.doubleToLongBits( val2 );
                TextCode.add( "\t\%t" + varCount + " = fadd float 0x" + Long.toHexString( ans1 ) + ", 0x" + Long.toHexString( ans2 ) );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.FLOAT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            else if( ( $a.theInfo.theType == Type.CONST_FLOAT ) && ( $b.theInfo.theType == Type.FLOAT ) ){
                double val1 = $a.theInfo.theVar.fValue;
                long ans1 = Double.doubleToLongBits( val1 );
                TextCode.add( "\t\%t" + varCount + " = fadd float 0x" + Long.toHexString( ans1 ) + ", \%t" + $b.theInfo.theVar.varIndex );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.FLOAT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            else if( ( $a.theInfo.theType != $b.theInfo.theType )  &&  ( $a.theInfo.theType != Type.ERR ) && ( $b.theInfo.theType != Type.ERR ) ){
                // System.out.println( $a.theInfo.theType + " " +$b.theInfo.theType );
                System.out.println( "Error: " +
                                                          $a.start.getLine() +
                                                          ": Type mismatch for the + operation in an expression." );
                $a.theInfo.theType = Type.ERR;
                System.exit(0);
            }
        }
    | '-' c = multExpr
        {
            // code generation.			
            // Int		   
            if( ( $a.theInfo.theType == Type.INT ) && ( $c.theInfo.theType == Type.INT ) ){
                TextCode.add( "\t\%t" + varCount + " = sub i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.INT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            } 
            else if( ( $a.theInfo.theType == Type.INT ) && ( $c.theInfo.theType == Type.CONST_INT ) ){
                TextCode.add( "\t\%t" + varCount + " = sub i32 \%t" + $theInfo.theVar.varIndex + ", " + $c.theInfo.theVar.iValue );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.INT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            else if( ( $a.theInfo.theType == Type.CONST_INT ) && ( $c.theInfo.theType == Type.CONST_INT ) ){
                TextCode.add( "\t\%t" + varCount + " = sub i32 " + $theInfo.theVar.iValue + ", " + $c.theInfo.theVar.iValue );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.INT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            else if( ( $a.theInfo.theType == Type.CONST_INT ) && ( $c.theInfo.theType == Type.INT ) ){
                TextCode.add( "\t\%t" + varCount + " = sub i32 " + $theInfo.theVar.iValue + ", \%t" + $c.theInfo.theVar.varIndex );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.INT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            // Floating point
            else if( ( $a.theInfo.theType == Type.FLOAT ) && ( $c.theInfo.theType == Type.FLOAT ) ){
                TextCode.add( "\t\%t" + varCount + " = fsub float \%t" + $theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.FLOAT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            } 
            else if( ( $a.theInfo.theType == Type.FLOAT ) && ( $c.theInfo.theType == Type.CONST_FLOAT ) ){
                double val2 = $c.theInfo.theVar.fValue;
                long ans2 = Double.doubleToLongBits( val2 );
                TextCode.add( "\t\%t" + varCount + " = fsub float \%t" + $theInfo.theVar.varIndex + ", 0x" + Long.toHexString( ans2 ) );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.FLOAT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            else if( ( $a.theInfo.theType == Type.CONST_FLOAT ) && ( $c.theInfo.theType == Type.CONST_FLOAT ) ){
                double val1 = $a.theInfo.theVar.fValue;
                long ans1 = Double.doubleToLongBits( val1 );
                double val2 = $c.theInfo.theVar.fValue;
                long ans2 = Double.doubleToLongBits( val2 );
                TextCode.add( "\t\%t" + varCount + " = fsub float 0x" + Long.toHexString( ans1 ) + ", 0x" + Long.toHexString( ans2 ) );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.FLOAT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            else if( ( $a.theInfo.theType == Type.CONST_FLOAT ) && ( $c.theInfo.theType == Type.FLOAT ) ){
                double val1 = $a.theInfo.theVar.fValue;
                long ans1 = Double.doubleToLongBits( val1 );
                TextCode.add( "\t\%t" + varCount + " = fsub float 0x" + Long.toHexString( ans1 ) + ", \%t" + $c.theInfo.theVar.varIndex );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.FLOAT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            else if( ( $a.theInfo.theType != $c.theInfo.theType )  &&  ( $a.theInfo.theType != Type.ERR ) && ( $c.theInfo.theType != Type.ERR ) ){
                System.out.println( "Error: " +
                                                          $a.start.getLine() +
                                                          ": Type mismatch for the - operation in an expression." );
                $a.theInfo.theType = Type.ERR;                                                          
                System.exit(0);
            }
        }
    )*
    ;

multExpr returns [ Info theInfo ]
@init{ $theInfo = new Info(); }
    : a = signExpr { $theInfo=$a.theInfo; }
    ( '*' b = signExpr
        { 
            // code generation.		
            // Int			   
            if( ( $a.theInfo.theType == Type.INT ) && ( $b.theInfo.theType == Type.INT ) ){
                TextCode.add( "\t\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.INT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            } 
            else if( ( $a.theInfo.theType == Type.INT ) && ( $b.theInfo.theType == Type.CONST_INT ) ){
                TextCode.add( "\t\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.INT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            else if( ( $a.theInfo.theType == Type.CONST_INT ) && ( $b.theInfo.theType == Type.CONST_INT ) ){
                TextCode.add( "\t\%t" + varCount + " = mul nsw i32 " + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.INT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            else if( ( $a.theInfo.theType == Type.CONST_INT ) && ( $b.theInfo.theType == Type.INT ) ){
                TextCode.add( "\t\%t" + varCount + " = mul nsw i32 " + $theInfo.theVar.iValue + ", \%t" + $b.theInfo.theVar.varIndex );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.INT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            // Floating point
            else if( ( $a.theInfo.theType == Type.FLOAT ) && ( $b.theInfo.theType == Type.FLOAT ) ){
                TextCode.add( "\t\%t" + varCount + " = fmul float \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.FLOAT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            } 
            else if( ( $a.theInfo.theType == Type.FLOAT ) && ( $b.theInfo.theType == Type.CONST_FLOAT ) ){
                double val2 = $b.theInfo.theVar.fValue;
                long ans2 = Double.doubleToLongBits( val2 );
                TextCode.add( "\t\%t" + varCount + " = fmul float \%t" + $theInfo.theVar.varIndex + ", 0x" + Long.toHexString( ans2 ) );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.FLOAT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            else if( ( $a.theInfo.theType == Type.CONST_FLOAT ) && ( $b.theInfo.theType == Type.CONST_FLOAT ) ){
                double val1 = $a.theInfo.theVar.fValue;
                long ans1 = Double.doubleToLongBits( val1 );
                double val2 = $b.theInfo.theVar.fValue;
                long ans2 = Double.doubleToLongBits( val2 );
                TextCode.add( "\t\%t" + varCount + " = fmul float 0x" + Long.toHexString( ans1 ) + ", 0x" + Long.toHexString( ans2 ) );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.FLOAT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            else if( ( $a.theInfo.theType == Type.CONST_FLOAT ) && ( $b.theInfo.theType == Type.FLOAT ) ){
                double val1 = $a.theInfo.theVar.fValue;
                long ans1 = Double.doubleToLongBits( val1 );
                TextCode.add( "\t\%t" + varCount + " = fmul float 0x" + Long.toHexString( ans1 ) + ", \%t" + $b.theInfo.theVar.varIndex );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.FLOAT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            else if( ( $a.theInfo.theType != $b.theInfo.theType )  &&  ( $a.theInfo.theType != Type.ERR ) && ( $b.theInfo.theType != Type.ERR ) ){
                System.out.println( "Error: " +
                                                          $a.start.getLine() +
                                                          ": Type mismatch for the * operation in an expression." );
                $a.theInfo.theType = Type.ERR;
                System.exit(0);
            }
        }
    | '/' c = signExpr
        {				  
            // code generation.			
            // Int		   
            if( ( $a.theInfo.theType == Type.INT ) && ( $c.theInfo.theType == Type.INT ) ){
                TextCode.add( "\t\%t" + varCount + " = sdiv i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.INT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            } 
            else if( ( $a.theInfo.theType == Type.INT ) && ( $c.theInfo.theType == Type.CONST_INT ) ){
                TextCode.add( "\t\%t" + varCount + " = sdiv i32 \%t" + $theInfo.theVar.varIndex + ", " + $c.theInfo.theVar.iValue );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.INT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            else if( ( $a.theInfo.theType == Type.CONST_INT ) && ( $c.theInfo.theType == Type.CONST_INT ) ){
                TextCode.add( "\t\%t" + varCount + " = sdiv i32 " + $theInfo.theVar.iValue + ", " + $c.theInfo.theVar.iValue );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.INT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            else if( ( $a.theInfo.theType == Type.CONST_INT ) && ( $c.theInfo.theType == Type.INT ) ){
                TextCode.add( "\t\%t" + varCount + " = sdiv i32 " + $theInfo.theVar.iValue + ", \%t" + $c.theInfo.theVar.varIndex );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.INT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            // Floating point
            else if( ( $a.theInfo.theType == Type.FLOAT ) && ( $c.theInfo.theType == Type.FLOAT ) ){
                TextCode.add( "\t\%t" + varCount + " = fdiv float \%t" + $theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.FLOAT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            } 
            else if( ( $a.theInfo.theType == Type.FLOAT ) && ( $c.theInfo.theType == Type.CONST_FLOAT ) ){
                double val2 = $c.theInfo.theVar.fValue;
                long ans2 = Double.doubleToLongBits( val2 );
                TextCode.add( "\t\%t" + varCount + " = fdiv float \%t" + $theInfo.theVar.varIndex + ", 0x" + Long.toHexString( ans2 ) );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.FLOAT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            else if( ( $a.theInfo.theType == Type.CONST_FLOAT ) && ( $c.theInfo.theType == Type.CONST_FLOAT ) ){
                double val1 = $a.theInfo.theVar.fValue;
                long ans1 = Double.doubleToLongBits( val1 );
                double val2 = $c.theInfo.theVar.fValue;
                long ans2 = Double.doubleToLongBits( val2 );
                TextCode.add( "\t\%t" + varCount + " = fdiv float 0x" + Long.toHexString( ans1 ) + ", 0x" + Long.toHexString( ans2 ) );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.FLOAT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            else if( ( $a.theInfo.theType == Type.CONST_FLOAT ) && ( $c.theInfo.theType == Type.FLOAT ) ){
                double val1 = $a.theInfo.theVar.fValue;
                long ans1 = Double.doubleToLongBits( val1 );
                TextCode.add( "\t\%t" + varCount + " = fdiv float 0x" + Long.toHexString( ans1 ) + ", \%t" + $c.theInfo.theVar.varIndex );
            
                // Update arith_expression's theInfo.
                $theInfo.theType = Type.FLOAT;
                $theInfo.theVar.varIndex = varCount;
                varCount++;
            }
            else if( ( $a.theInfo.theType != $c.theInfo.theType )  &&  ( $a.theInfo.theType != Type.ERR ) && ( $c.theInfo.theType != Type.ERR ) ){
                System.out.println( "Error: " +
                                                          $a.start.getLine() +
                                                          ": Type mismatch for the / operation in an expression." );
                $a.theInfo.theType = Type.ERR;
                System.exit(0);
            }
        }
    )*
    ;

signExpr returns [ Info theInfo ]
@init{ $theInfo = new Info(); }
    : a = primaryExpr { $theInfo = $a.theInfo; }
    | '-' b = primaryExpr
        { 
            $theInfo=$b.theInfo;
            if( $theInfo.theType == Type.INT || $theInfo.theType == Type.CONST_INT ){
                $theInfo.theVar.iValue *= -1;
                if( TRACEON )   System.out.println( "signExpr value: " + $theInfo.theVar.iValue );
            }
            else if( $theInfo.theType == Type.FLOAT || $theInfo.theType == Type.CONST_FLOAT ){
                $theInfo.theVar.fValue *= -1;       
                if( TRACEON )   System.out.println( "signExpr value: " + $theInfo.theVar.fValue );
            }     
        }
	;
		  
primaryExpr returns [ Info theInfo ]
@init{ $theInfo = new Info(); }
    : Integer_constant
        {
            $theInfo.theType = Type.CONST_INT;
            $theInfo.theVar.iValue = Integer.parseInt( $Integer_constant.text );
            // System.out.println( "Integer_constant: " + $theInfo.theVar.iValue );
        }
    | Floating_point_constant
        {
            $theInfo.theType = Type.CONST_FLOAT;
            $theInfo.theVar.fValue = Float.parseFloat( $Floating_point_constant.text );
        }    
    | Identifier
        {
            if( symtab.containsKey( $Identifier.text ) ){
                // get type information from symtab.
                Type theType = symtab.get( $Identifier.text ).theType;
                $theInfo.theType = theType;

                // get variable index from symtab.
                int vIndex = symtab.get($Identifier.text).theVar.varIndex;
            
                switch( theType ){
                    case INT: 
                        // get a new temporary variable and
                        // load the variable into the temporary variable.
                        
                        // Ex: \%tx = load i32, i32* \%ty.
                        TextCode.add( "\t\%t" + varCount + " = load i32, i32* \%t" + vIndex );
                        
                        // Now, Identifier's value is at the temporary variable \%t[varCount].
                        // Therefore, update it.
                        $theInfo.theVar.varIndex = varCount;
                        varCount++;
                        break;
                    case FLOAT:
                        // get a new temporary variable and
                        // load the variable into the temporary variable.
                        
                        // Ex: \%tx = load float, float* \%ty.
                        TextCode.add( "\t\%t" + varCount + " = load float, float* \%t" + vIndex );
                        
                        // Now, Identifier's value is at the temporary variable \%t[varCount].
                        // Therefore, update it.
                        $theInfo.theVar.varIndex = varCount;
                        varCount++;
                        break;
                    case CHAR:
                        // get a new temporary variable and
                        // load the variable into the temporary variable.
                        
                        // Ex: \%tx = load i8, i8* \%ty.
                        TextCode.add( "\t\%t" + varCount + " = load i8, i8* \%t" + vIndex );
                        
                        // Now, Identifier's value is at the temporary variable \%t[varCount].
                        // Therefore, update it.
                        $theInfo.theVar.varIndex = varCount;
                        varCount++;
                        break;
                }
            }
            else{
                System.out.println( "Error: " + 
                                                            $Identifier.getLine() + 
                                                            ": Undeclared identifier : " +
                                                            $Identifier.text );

                $theInfo.theType = Type.ERR;
                System.exit(0);
            }
        }
    | '&' Identifier
    | '(' arith_expression ')'{ $theInfo = $arith_expression.theInfo;
        // System.out.println( $theInfo.theVar.varIndex );
     }
    ;

		   
/* description of the tokens */
FLOAT:'float';
INT:'int';
CHAR: 'char';

MAIN: 'main';
VOID: 'void';
IF: 'if';
ELSE: 'else';
FOR: 'for';

GT: '>';
GE: '>=';
LT: '<';
LE: '<=';
EQ: '==';
NE: '!=';

Identifier:('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;

Integer_constant : ( '0' | ( '1'..'9' )( DIGIT )* );
Floating_point_constant : ( FLOAT_NUM1 | FLOAT_NUM2 | FLOAT_NUM3 )( FLOATTYPESUFFIX? );
fragment FLOAT_NUM1 : ( DIGIT )+'.'( DIGIT )*;
fragment FLOAT_NUM2 : '.'( DIGIT )+;
fragment FLOAT_NUM3 : ( DIGIT )+;
fragment FLOATTYPESUFFIX : ( 'f' | 'F' | 'd' | 'D' );
fragment DIGIT : '0'..'9';

STRING_LITERAL
    :  '"' ( EscapeSequence | ~('\\'|'"') )* '"'
    ;

WS:( ' ' | '\t' | '\r' | '\n' ) {$channel=HIDDEN;};

/* Comments */
COMMENT1 : '//'(.)*'\n'{ $channel=HIDDEN; };
COMMENT2 : '/*' (options{greedy=false;}: .)* '*/'{ $channel=HIDDEN; };


fragment
EscapeSequence
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
    ;
