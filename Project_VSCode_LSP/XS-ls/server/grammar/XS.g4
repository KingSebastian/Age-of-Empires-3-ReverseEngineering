grammar XS;

// -------------------- PROGRAM --------------------

program
    : statement* EOF
    ;

// -------------------- STATEMENTS --------------------

statement
    : includeStatement ';'
    | functionDeclaration
    | declaration ';'
    | assignment ';'
    | functionCall
    | ifStatement
    | whileStatement
    | forStatement
    | codeBlock
    | expression ';' 
    ;

// -------------------- INCLUDE --------------------

includeStatement
    : INCLUDE STRING 
    ;

// -------------------- DECLARATION --------------------

declaration
    : CONST? TYPE IDENTIFIER ('=' expression)? 
    ;

// -------------------- ASSIGNMENT --------------------

assignment
    : IDENTIFIER assignmentOperator expression 
    ;


assignmentOperator
    : '=' | '+=' | '-=' | '*=' | '/=' | '%='
    ;

// -------------------- CONTROL FLOW --------------------

ifStatement
    : 'if' '(' expression ')' statement ('else' statement)?
    ;

whileStatement
    : 'while' '(' expression ')' statement
    ;

forStatement
    : 'for' '(' forInit? ';' forCondition? (';' expression?)? ')' statement
    ;

forInit
    : declaration
    | assignment
    ;

forCondition
    : expression                                                        # ForExtendedExpr
    | ('==' | '!=' | '<' | '<=' | '>' | '>=') expression                # ForImplicitComparator
    | IDENTIFIER ('==' | '!=' | '<' | '<=' | '>' | '>=') expression     # ForExplicitComparator
    ;

// -------------------- CODE BLOCK --------------------

codeBlock
    : '{' statement* '}'
    ;

// -------------------- FUNCTIONS --------------------

functionDeclaration
    : (TYPE | VOID) IDENTIFIER '(' parameterList? ')' codeBlock
    ;

parameterList
    : VOID                     # EmptyParams
    | parameter (',' parameter)* # NormalParams
    ;

parameter
    : TYPE IDENTIFIER
    ;

functionCall
    : IDENTIFIER '(' argumentList? ')' ';'? 
    ;

argumentList
    : expression (',' expression)*
    ;



// =====================================================
//                 EXPRESSIONS (CLEAN)
// =====================================================

expression
    : ternaryExpression
    ;

// -------------------- TERNARY --------------------

ternaryExpression
    : logicalOrExpression ('?' expression ':' expression)?
    ;

// -------------------- LOGICAL OR --------------------

logicalOrExpression
    : logicalAndExpression ('||' logicalAndExpression)*
    ;

// -------------------- LOGICAL AND --------------------

logicalAndExpression
    : bitwiseOrExpression ('&&' bitwiseOrExpression)*
    ;

// -------------------- BITWISE OR --------------------

bitwiseOrExpression
    : equalityExpression ('|' equalityExpression)*
    ;

// -------------------- EQUALITY --------------------

equalityExpression
    : relationalExpression (('==' | '!=') relationalExpression)*
    ;

// -------------------- RELATIONAL --------------------

relationalExpression
    : additiveExpression (('<' | '<=' | '>' | '>=') additiveExpression)*
    ;

// -------------------- ADDITIVE --------------------

additiveExpression
    : multiplicativeExpression (('+' | '-') multiplicativeExpression)*
    ;

// -------------------- MULTIPLICATIVE --------------------

multiplicativeExpression
    : unaryExpression (('*' | '/' | '%') unaryExpression)*
    ;

// -------------------- UNARY --------------------

unaryExpression
    : ('++' | '--' | '+' | '-') unaryExpression
    | postfixExpression
    ;

// -------------------- POSTFIX --------------------

postfixExpression
    : primary ('++' | '--')*
    ;

// -------------------- PRIMARY --------------------

primary
    : literal
    | IDENTIFIER
    | functionCall
    | '(' expression ')'
    ;

// -------------------- LITERALS --------------------

literal
    : NUMBER
    | STRING
    | BOOLEAN
    ;

// -------------------- KEYWORDS --------------------

INCLUDE : 'include';
CONST   : 'const';

VOID : 'void';

TYPE
    : 'int'
    | 'float'
    | 'bool'
    | 'string'
    | 'vector'
    ;

BOOLEAN : 'true' | 'false';

// -------------------- LEXER RULES --------------------

COMMENT
    : ('//' ~[\r\n]*
    | '/*' .*? '*/')
    -> skip
    ;

STRING
    : '"' (~["\r\n])* '"'
    ;

NUMBER
    : [0-9]+ ('.' [0-9]+)?
    ;

IDENTIFIER
    : [a-zA-Z_][a-zA-Z0-9_]*
    ;

WS
    : [ \t\r\n]+ -> skip
    ;