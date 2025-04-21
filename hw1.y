%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "ast.h"

    // Function declarations
    void yyerror(char *s);
    int yylex(void);
    
    extern int lineno;
    extern char* yytext;
    extern node* ast_root;
%}

%union {
    node* ast_node;
    char* string_val;
    int int_val;
}

// Token definitions
%token <string_val> IF ELIF ELSE WHILE RETURN AND OR NOT PASS DEF BOOL INT STRING
%token <string_val> INTEGER_LITERAL FLOAT_LITERAL ID STRING_LITERAL TRUE_LIT FALSE_LIT
%token <string_val> TYPE EQ BIG_EQ SMALL_EQ NO_EQ POWER

// Non-terminal types
%type <ast_node> program funcs func params param_decl id_list 
%type <ast_node> type body sts st statement block
%type <ast_node> if_statement elif_list while_statement 
%type <ast_node> assignment_statement multi_id_list multi_exp_list
%type <ast_node> return_statement function_call string_index
%type <ast_node> exp exp_list

// Precedence rules
%right '='  
%left AND OR
%left EQ NO_EQ
%left '>' '<' BIG_EQ SMALL_EQ
%left '+' '-'
%left '*' '/'
%right POWER
%right NOT
%left '[' ']'
%left '(' ')'

%%
// Grammar rules
program     : funcs { $$ = makenode("CODE", $1, NULL); ast_root = $$; }
            ;

funcs       : func { $$ = $1; }
            | funcs func { $$ = makenode("FUNCS", $1, $2); }
            ;

func        : DEF ID '(' params ')' ':' block 
            { $$ = makenode("FUNC", makenode($2, NULL, NULL), 
                    makenode("ARGS", $4, makenode("RETURN VOID", NULL, makenode("BODY", $7, NULL)))); }
            | DEF ID '(' params ')' TYPE type ':' block 
            { $$ = makenode("FUNC", makenode($2, NULL, NULL), 
                    makenode("ARGS", $4, makenode("RET", $7, makenode("BODY", $9, NULL)))); }
            ;

params      : /* empty */ { $$ = makenode("NONE", NULL, NULL); }
            | param_decl { $$ = $1; }
            | params ';' param_decl { $$ = makenode("PARAMS", $1, $3); }
            ;

param_decl  : type id_list { $$ = makenode($1->token, $2, NULL); }
            ;

id_list     : ID { $$ = makenode($1, NULL, NULL); }
            | id_list ',' ID { $$ = makenode("LIST", $1, makenode($3, NULL, NULL)); }
            ;

type        : INT { $$ = makenode("INT", NULL, NULL); }
            | BOOL { $$ = makenode("BOOL", NULL, NULL); }
            | STRING { $$ = makenode("STRING", NULL, NULL); }
            ;

block       : '{' body '}' { $$ = $2; }
            ;

body        : /* empty */ { $$ = makenode("EMPTY", NULL, NULL); }
            | sts { $$ = makenode("BLOCK", NULL, $1); }
            ;

sts         : st { $$ = $1; }
            | sts st { $$ = makenode("STMTS", $1, $2); }
            ;

st          : statement ';' { $$ = $1; }
            | if_statement { $$ = $1; }
            | while_statement { $$ = $1; }
            | block { $$ = $1; }
            ;

statement   : assignment_statement { $$ = $1; }
            | return_statement { $$ = $1; }
            | function_call { $$ = $1; }
            | PASS { $$ = makenode("PASS", NULL, NULL); }
            ;

assignment_statement : ID '=' exp { $$ = makenode("ASS", makenode($1, NULL, NULL), $3); }
                     | string_index '=' exp { $$ = makenode("ASS", $1, $3); }
                     | multi_id_list '=' multi_exp_list { $$ = makenode("MULTI_ASS", $1, $3); }
                     ;

multi_id_list : ID { $$ = makenode($1, NULL, NULL); }
              | multi_id_list ',' ID { $$ = makenode("ID_LIST", $1, makenode($3, NULL, NULL)); }
              ;

multi_exp_list : exp { $$ = $1; }
               | multi_exp_list ',' exp { $$ = makenode("EXP_LIST", $1, $3); }
               ;

if_statement : IF exp ':' block { $$ = makenode("IF", $2, $4); }
             | IF exp ':' block ELSE ':' block 
               { $$ = makenode("IF-ELSE", $2, makenode("THEN", $4, makenode("ELSE", $7, NULL))); }
             | IF exp ':' block elif_list
               { $$ = makenode("IF-ELIF", $2, makenode("THEN", $4, $5)); }
             | IF exp ':' block elif_list ELSE ':' block
               { $$ = makenode("IF-ELIF-ELSE", $2, makenode("THEN", $4, makenode("ELIF-ELSE", $5, makenode("ELSE", $8, NULL)))); }
             ;

elif_list   : ELIF exp ':' block 
              { $$ = makenode("ELIF", $2, $4); }
            | elif_list ELIF exp ':' block 
              { $$ = makenode("ELIF-LIST", $1, makenode("ELIF", $3, $5)); }
            ;

while_statement : WHILE exp ':' block
                  { $$ = makenode("WHILE", $2, $4); }
                ;

return_statement : RETURN { $$ = makenode("RET", NULL, NULL); }
                 | RETURN exp { $$ = makenode("RET", $2, NULL); }
                 ;

function_call : ID '(' ')' { $$ = makenode("CALL", makenode($1, NULL, NULL), NULL); }
              | ID '(' exp_list ')' { $$ = makenode("CALL", makenode($1, NULL, NULL), $3); }
              ;

exp_list    : exp { $$ = $1; }
            | exp_list ',' exp { $$ = makenode("ARGS", $1, $3); }
            ;

string_index : ID '[' exp ']' 
               { $$ = makenode("INDEX", makenode($1, NULL, NULL), $3); }
             | ID '[' exp ':' exp ']' 
               { $$ = makenode("SLICE", makenode($1, NULL, NULL), makenode("RANGE", $3, $5)); }
             | ID '[' exp ':' exp ':' exp ']' 
               { $$ = makenode("SLICE", makenode($1, NULL, NULL), makenode("RANGE_STEP", $3, makenode("TO", $5, $7))); }
             | ID '[' ':' exp ']' 
               { $$ = makenode("SLICE", makenode($1, NULL, NULL), makenode("START_TO", makenode("0", NULL, NULL), $4)); }
             | ID '[' exp ':' ']' 
               { $$ = makenode("SLICE", makenode($1, NULL, NULL), makenode("FROM_END", $3, NULL)); }
             | ID '[' ':' ']' 
               { $$ = makenode("SLICE", makenode($1, NULL, NULL), makenode("FULL", NULL, NULL)); }
             ;

exp         : INTEGER_LITERAL { $$ = makenode($1, NULL, NULL); }
            | FLOAT_LITERAL { $$ = makenode($1, NULL, NULL); }
            | STRING_LITERAL { $$ = makenode($1, NULL, NULL); }
            | TRUE_LIT { $$ = makenode("True", NULL, NULL); }
            | FALSE_LIT { $$ = makenode("False", NULL, NULL); }
            | ID { $$ = makenode($1, NULL, NULL); }
            | string_index { $$ = $1; }
            | function_call { $$ = $1; }
            | '(' exp ')' { $$ = $2; }
            | exp '+' exp { $$ = makenode("+", $1, $3); }
            | exp '-' exp { $$ = makenode("-", $1, $3); }
            | exp '*' exp { $$ = makenode("*", $1, $3); }
            | exp '/' exp { $$ = makenode("/", $1, $3); }
            | exp POWER exp { $$ = makenode("**", $1, $3); }
            | exp EQ exp { $$ = makenode("==", $1, $3); }
            | exp NO_EQ exp { $$ = makenode("!=", $1, $3); }
            | exp '>' exp { $$ = makenode(">", $1, $3); }
            | exp '<' exp { $$ = makenode("<", $1, $3); }
            | exp BIG_EQ exp { $$ = makenode(">=", $1, $3); }
            | exp SMALL_EQ exp { $$ = makenode("<=", $1, $3); }
            | exp AND exp { $$ = makenode("and", $1, $3); }
            | exp OR exp { $$ = makenode("or", $1, $3); }
            | NOT exp { $$ = makenode("not", $2, NULL); }
            | '-' exp { $$ = makenode("neg", $2, NULL); }
            ;

%%

// Error reporting func
void yyerror(char *s) {
    fprintf(stderr, "Error at line %d: %s near token '%s'\n", lineno, s, yytext);
}

// Main func
int main() {
    if (yyparse() == 0) {
        printtree(ast_root, 0); // Print the AST starting from the root node
        free_node(ast_root);  // free the AST
        ast_root = NULL;  // reset the root to NULL after freeing
    }
    return 0;
}