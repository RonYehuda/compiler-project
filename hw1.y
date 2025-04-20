%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    
    // Node structure for AST
    typedef struct node {
        char *token;
        struct node *left;
        struct node *right;
    } node;
    
    // Function declarations
    node *makenode(char* token, node* left, node* right);
    void printtree(node *tree, int indent);
    int yylex(void);
    int yyerror(char *s);
    
    #define YYSTYPE struct node*
    extern int lineno;
    extern char* yytext;

    node* ast_root = NULL; 
%}

// Token definitions - match these with your LEX file
%token IF ELIF ELSE WHILE RETURN AND OR NOT PASS DEF BOOL INT STRING
%token INTEGER_LITERAL FLOAT_LITERAL ID STRING_LITERAL TRUE_LIT FALSE_LIT
%token TYPE EQ BIG_EQ SMALL_EQ NO_EQ POWER

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
program     : funcs { $$ = makenode("CODE", $1, NULL); }
            ;

funcs : func { $$ = $1; }
      | funcs func { $$ = makenode("FUNCS", $1, $2); }
      ;

func : DEF ID '(' params ')' ':' '{' body '}' 
     { $$ = makenode("FUNC", $2, makenode("ARGS", $4, makenode("RETURN VOID", NULL, makenode("BODY", $8, NULL)))); }
     | DEF ID '(' params ')' TYPE ':' '{' body '}' 
     { $$ = makenode("FUNC", $2, makenode("ARGS", $4, makenode("RET", $6, makenode("BODY", $9, NULL)))); }
     | DEF ID '(' params ')' ':' st ';' 
     { $$ = makenode("FUNC", $2, makenode("ARGS", $4, makenode("RETURN VOID", NULL, makenode("BODY", $7, NULL)))); }
     | DEF ID '(' params ')' TYPE ':' st ';' 
     { $$ = makenode("FUNC", $2, makenode("ARGS", $4, makenode("RET", $6, makenode("BODY", $8, NULL)))); }
     ;

params : /* empty */ { $$ = makenode("NONE", NULL, NULL); }
       | param_decl { $$ = $1; }
       | params ';' param_decl { $$ = makenode("PARAMS", $1, $3); }
       ;

param_decl : type id_list { $$ = makenode($1->token, $2, NULL); }
           | type id_list_with_defaults { $$ = makenode($1->token, $2, NULL); }
           ;

id_list : ID { $$ = makenode($1->token, NULL, NULL); }
        | id_list ',' ID { $$ = makenode("LIST", $1, makenode($3->token, NULL, NULL)); }
        ;

id_list_with_defaults : ID ':' literal { $$ = makenode("DEFAULT", makenode($1->token, NULL, NULL), $3); }
                      | id_list_with_defaults ',' ID ':' literal { $$ = makenode("LIST", $1, makenode("DEFAULT", makenode($3->token, NULL, NULL), $5)); }
                      ;

type : INT { $$ = makenode("INT", NULL, NULL); }
     | BOOL { $$ = makenode("BOOL", NULL, NULL); }
     | STRING { $$ = makenode("STRING", NULL, NULL); }
     ;

body : /* empty */ { $$ = makenode("EMPTY", NULL, NULL); }
     | declaration_list sts { $$ = makenode("BLOCK", $1, $2); }
     ;

declaration_list : /* empty */ { $$ = NULL; }
                 | declaration_list declaration { 
                     if ($1 == NULL) 
                         $$ = $2; 
                     else 
                         $$ = makenode("DECL_LIST", $1, $2); 
                 }
                 ;

declaration : type id_list ';' { $$ = makenode("DECL", $1, $2); }
            | type id_list '=' exp ';' { $$ = makenode("DECL_INIT", $1, makenode("ASSIGN", $2, $4)); }
            ;

sts : st { $$ = $1; }
    | sts st { $$ = makenode("STMTS", $1, $2); }
    ;

st : assignment_statement { $$ = $1; }
   | if_statement { $$ = $1; }
   | while_statement { $$ = $1; }
   | return_statement { $$ = $1; }
   | function_call ';' { $$ = $1; }
   | PASS ';' { $$ = makenode("PASS", NULL, NULL); }
   | '{' sts '}' { $$ = makenode("BLOCK", $2, NULL); }
   ;

assignment_statement : ID '=' exp ';' { $$ = makenode("ASS", makenode($1->token, NULL, NULL), $3); }
                     | string_index '=' exp ';' { $$ = makenode("ASS", $1, $3); }
                     | multi_id_list '=' multi_exp_list ';' { $$ = makenode("MULTI_ASS", $1, $3); }
                     ;

multi_id_list : ID { $$ = makenode($1->token, NULL, NULL); }
              | multi_id_list ',' ID { $$ = makenode("ID_LIST", $1, makenode($3->token, NULL, NULL)); }
              ;

multi_exp_list : exp { $$ = $1; }
               | multi_exp_list ',' exp { $$ = makenode("EXP_LIST", $1, $3); }
               ;

if_statement : IF exp ':' st 
             { $$ = makenode("IF", $2, $4); }
             | IF exp ':' st ELSE ':' st 
             { $$ = makenode("IF-ELSE", $2, makenode("THEN", $4, makenode("ELSE", $7, NULL))); }
             | IF exp ':' st elif_list 
             { $$ = makenode("IF-ELIF", $2, makenode("THEN", $4, $5)); }
             | IF exp ':' st elif_list ELSE ':' st 
             { $$ = makenode("IF-ELIF-ELSE", $2, makenode("THEN", $4, makenode("ELIF-ELSE", $5, makenode("ELSE", $8, NULL)))); }
             ;

elif_list : ELIF exp ':' st 
          { $$ = makenode("ELIF", $2, $4); }
          | elif_list ELIF exp ':' st 
          { $$ = makenode("ELIF-LIST", $1, makenode("ELIF", $3, $5)); }
          ;

while_statement : WHILE exp ':' st 
                { $$ = makenode("WHILE", $2, $4); }
                ;

return_statement : RETURN ';' 
                 { $$ = makenode("RET", NULL, NULL); }
                 | RETURN exp ';' 
                 { $$ = makenode("RET", $2, NULL); }
                 ;

function_call : ID '(' ')' 
              { $$ = makenode("CALL", makenode($1->token, NULL, NULL), NULL); }
              | ID '(' exp_list ')' 
              { $$ = makenode("CALL", makenode($1->token, NULL, NULL), $3); }
              ;

exp_list : exp { $$ = $1; }
         | exp_list ',' exp { $$ = makenode("ARGS", $1, $3); }
         ;

string_index : ID '[' exp ']' 
             { $$ = makenode("INDEX", makenode($1->token, NULL, NULL), $3); }
             | ID '[' exp ':' exp ']' 
             { $$ = makenode("SLICE", makenode($1->token, NULL, NULL), makenode("RANGE", $3, $5)); }
             | ID '[' exp ':' exp ':' exp ']' 
             { $$ = makenode("SLICE", makenode($1->token, NULL, NULL), makenode("RANGE_STEP", $3, makenode("TO", $5, $7))); }
             | ID '[' ':' exp ']' 
             { $$ = makenode("SLICE", makenode($1->token, NULL, NULL), makenode("START_TO", makenode("0", NULL, NULL), $4)); }
             | ID '[' exp ':' ']' 
             { $$ = makenode("SLICE", makenode($1->token, NULL, NULL), makenode("FROM_END", $3, NULL)); }
             | ID '[' ':' ']' 
             { $$ = makenode("SLICE", makenode($1->token, NULL, NULL), makenode("FULL", NULL, NULL)); }
             ;

exp : INTEGER_LITERAL { $$ = makenode($1->token, NULL, NULL); }
    | FLOAT_LITERAL { $$ = makenode($1->token, NULL, NULL); }
    | STRING_LITERAL { $$ = makenode($1->token, NULL, NULL); }
    | TRUE_LIT { $$ = makenode("True", NULL, NULL); }
    | FALSE_LIT { $$ = makenode("False", NULL, NULL); }
    | ID { $$ = makenode($1->token, NULL, NULL); }
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

literal : INTEGER_LITERAL { $$ = makenode($1->token, NULL, NULL); }
        | FLOAT_LITERAL { $$ = makenode($1->token, NULL, NULL); }
        | STRING_LITERAL { $$ = makenode($1->token, NULL, NULL); }
        | TRUE_LIT { $$ = makenode("True", NULL, NULL); }
        | FALSE_LIT { $$ = makenode("False", NULL, NULL); }
        ;
%%

#include "lex.yy.c"

// Tree printing func
void printtree(node *tree, int indent) {
    if (tree == NULL) return;
    
    // Print indentation
    for (int i = 0; i < indent; i++) {
        printf(" ");
    }
    
    // Print the current node
    printf("(%s\n", tree->token);
    
    // Print children with increased indentation
    if (tree->left) printtree(tree->left, indent + 2);
    if (tree->right) printtree(tree->right, indent + 2);
    
    // Close the parenthesis
    for (int i = 0; i < indent; i++) {
        printf(" ");
    }
    printf(")\n");
}

// Error reporting func
int yyerror(char *s) {
    fprintf(stderr, "Error at line %d: %s\n", lineno, s);
    return 0;
}
// Node creation func
node *makenode(char* token, node* left, node* right) {
    node *new_node = (node *)malloc(sizeof(node));
    if (new_node == NULL) {
        fprintf(stderr, "Error: Out of memory\n");
        exit(1);
    }
    new_node->token = strdup(token);
    new_node->left = left;
    new_node->right = right;
    return new_node;
}

// Main func
int main() {
    if (yyparse() == 0) {
        // Print the AST starting from the root node, which should be in $$
        printtree($$, 0);
    }
    return 0;
}