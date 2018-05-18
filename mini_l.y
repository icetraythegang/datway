%{
 #include <stdio.h>
 #include <stdlib.h>
 void yyerror(const char *msg);
 extern int currLine;
 extern int currPos;
 FILE * yyin;
 extern int yyleng;
%}

%union{
 int ival;
 char* dval;
}

%error-verbose
%start	prog_start

%token FUNCTION 
%token BEGIN_PARAMS 
%token END_PARAMS 
%token BEGIN_LOCALS 
%token END_LOCALS 
%token BEGIN_BODY 
%token END_BODY 
%token INTEGER 
%token ARRAY 
%token OF 
%token IF 
%token THEN 
%token ENDIF 
%token ELSE 
%token WHILE 
%token DO 
%token BEGINLOOP 
%token ENDLOOP
%token CONTINUE 
%token READ 
%token WRITE 
%token TRUE 
%token FALSE 
%token SEMICOLON 
%token COLON 
%token COMMA 
%token L_PAREN 
%token R_PAREN 
%token L_SQUARE 
%token R_SQUARE 
%token ASSIGN 
%token RETURN


%token <ival> NUMBERS
%token <dval> IDENT


%left MULT DIV MOD ADD SUB 
%left LT LTE GT GTE EQ NEQ
%left AND OR
%right ASSIGN
%right NOT

%%

prog_start:	functions { printf("prog_start->functions\n"); }
		;	
	
functions:	%empty
		{printf("functions -> epsilon\n");}
		|function functions {printf("functions -> function functions\n");}
		| error {yyerrok; yyclearin;}
		;

function:	FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY
		{printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS Declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");}
		;


declarations:	%empty 
		{printf("declarations->epsilon\n");}
		| declaration SEMICOLON declarations {printf("declarations -> declaration SEMICOLON declarations\n");}
		;

declaration:	Identifier COLON INTEGER {printf("declaration -> Identifier COLON INTEGER\n");}
		| Identifier COLON ARRAY L_SQUARE NUMBERS R_SQUARE OF INTEGER
		 {printf("declaration -> Identifier COLON ARRAY L_SQUARE NUMBER %d R_SQUARE OF INTEGER\n", $5);}
		;

Identifier:	 IDENT {printf("Identifier -> IDENT  %s \n", $1);}
		| IDENT COMMA Identifier {printf("Identifier -> IDENT %s COMMA Identifier\n", $1); }
		;

statements:	statement SEMICOLON statements {printf("statements -> statement SEMICOLON statements\n");}
		| statement SEMICOLON {printf("statements -> statement SEMICOLON\n");}
		;

statement:      var ASSIGN expression {printf("statement -> Var ASSIGN Expression\n");}
		|
		elseloop {printf("statement-> elseloop\n");}
                | WHILE boolex BEGINLOOP statements ENDLOOP
		 {printf("statement -> WHILE BoolExp BEGINLOOP Statements ENDLOOP\n");}
                 | DO BEGINLOOP statements ENDLOOP WHILE boolex
		 {printf("statement -> DO BEGINLOOP Statements ENDLOOP WHILE BoolExp\n");}
                 | READ Vars
		 {printf("statement -> READ Vars\n");}
                 | WRITE Vars
		 {printf("statement -> WRITE Vars\n");}
                 | CONTINUE
		 {printf("statement -> CONTINUE\n");}
                 | RETURN expression
		 {printf("statement -> RETURN expression\n");}
;

elseloop: 	IF boolex THEN statements ENDIF  {printf("statement -> IF boolex THEN Statements ENDIF\n");}
	 	 | IF boolex THEN statements ELSE statements ENDIF
		 {printf("statement -> IF boolex THEN statements ELSE statements ENDIF\n");}		 
               	 
boolex:	        relation {printf("boolex -> relation\n");}
		| boolex OR relation {printf("boolex -> boolex OR relation\n");}
		;

relation:	relation1 {printf( "relation -> relation1\n");} 
		| relation AND relation1 {printf("relation -> relation AND relation1\n");}
		;

relation1:	r_exp{ printf( "relation1 -> r_exp\n");}
		| NOT r_exp { printf("relation1 -> NOT r_exp\n");}
		;

r_exp:		expression comp expression {printf("rexpr -> expression comp expression\n");}
		| TRUE {printf("rexpr -> TRUE\n");}
		| FALSE {printf( "rexpr -> FALSE\n");}
		| L_PAREN boolex R_PAREN {printf("rexpr -> L_PAREN boolex R_PAREN\n");}
		;

comp:		EQ {printf("comp -> EQ\n");}
		| NEQ {printf("comp -> NEQ\n");}
		| LT {printf("comp -> LT\n");}
		| GT {printf("comp -> GT\n");}
		| LTE {printf("comp -> LTE\n");}
		| GTE {printf( "comp -> GTE\n");}
		;


expression:	mult_exp plminus {printf("expression -> mult_exp plminus\n");}
		;

plminus:	%empty
		 {printf("plminus -> epsilon\n");}
		| ADD mult_exp plminus {printf("plminus -> ADD mul_expr plminus\n");}
		| SUB mult_exp plminus {printf("plminus -> SUB mul_expr plminus\n");}
		;

mult_exp:	term longterm {printf("mult_exp -> term longterm\n");}
		;

longterm:	%empty
		 {printf("longterm -> epsilon\n");}
		| MULT term longterm {printf( "longterm -> MULT term longterm\n");} 
		| DIV term longterm {printf( "longterm -> DIV term longterm\n");}
		| MOD term longterm {printf("longterm -> MOD term longterm\n");}
		;

term:           upperterm {printf( "term -> upperterm\n");}
                | SUB upperterm {printf("term -> SUB upperterm\n");}
                | IDENT lowerterm {printf("term -> IDENT lowerterm\n");}
                ;

upperterm:        var {printf( "upperterm -> var\n");}
                | NUMBERS {printf("upperterm -> NUMBERS \n");}
                | L_PAREN expression R_PAREN {printf("upperterm -> L_PAREN expression R_PAREN\n");}
                ;

lowerterm:      L_PAREN term_exp R_PAREN {printf("lowerterm -> L_PAREN term_exp R_PAREN\n");}
                | L_PAREN R_PAREN {printf("lowerterm -> L_PAREN R_PAREN\n");}
                ;

term_exp:        expression {printf("term_exp -> expression\n");}
                | expression COMMA term_exp {printf("term_exp -> expression COMMA term_exp\n");}
                ;

var:            IDENT {printf("var -> IDENT %s \n", $1);}
                | IDENT L_SQUARE expression R_SQUARE {printf("var -> IDENT %s L_SQUARE expression R_SQUARE\n", $1);} 
                ;


Vars:            var {printf("Vars -> var\n");}
                 | var COMMA Vars
		 {printf("Vars -> var COMMA Vars\n");}
;


%%

int main(int argc, char **argv) {
   if (argc > 1) {
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         printf("syntax: %s filename\n", argv[0]);
      }//end if
   }//end if
   yyparse(); // Calls yylex() for tokens.
   return 0;
}




void yyerror(const char *msg) {
   printf("** Line %d, position %d: %s\n", currLine, currPos, msg);
}

