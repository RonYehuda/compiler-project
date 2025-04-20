%{  
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
#include "ast.h"
int lineno = 1;
struct node;  
struct node *makenode(char* token, struct node* left, struct node* right); 
%}

%%
//keywords
"if"         {return IF;}
"elif"       {return ELIF;}
"else"       {return ELSE;}
"while"      {return WHILE;}
"return"     {return RETURN;}
"and"        {return AND;}
"or"         {return OR;}
"not"        {return NOT;}
"pass"       {return PASS;}
"def"        {return DEF;}
"bool"       {return BOOL;}
"int"        {return INT;}
"string"     {return STRING;}

//operators
"=="         {return EQ;}
">"          {return '>';}
">="         {return BIG_EQ;}
"<"          {return '<';}
"<="         {return SMALL_EQ;}
"!="         {return NO_EQ;}
"="          {return '=';}
"+"          {return '+';}
"-"          {return '-';}
"*"          {return '*';}
"/"          {return '/';}
"**"         {return POWER;}

//Literals
// Integer literals - decimal
[+-]?[1-9][0-9]* {yylval = makenode(strdup(yytext),NULL,NULL); return INTEGER_LITERAL;}
0               {yylval = makenode("0",NULL,NULL); return INTEGER_LITERAL;}  // Zero as a special case
0[xX][0-9a-fA-F]+ {yylval = makenode(strdup(yytext), NULL,NULL); return INTEGER_LITERAL;}

// Float literals
[+-]?[0-9]*\.[0-9]+ {yylval = makenode(strdup(yytext),NULL,NULL); return FLOAT_LITERAL;}

// Scientific notation for floats
[+-]?[0-9]+(\.[0-9]*)?[eE][+-]?[0-9]+ {yylval = makenode(strdup(yytext),NULL,NULL); return FLOAT_LITERAL;}
[+-]?[0-9]*\.[0-9]+[eE][+-]?[0-9]+ {yylval = makenode(strdup(yytext),NULL,NULL); return FLOAT_LITERAL;}

(_|__|[A-Za-z])([A-Za-z0-9_]*) {yylval = makenode(strdup(yytext),NULL,NULL); return ID;} //to check if 3 underscore is posiballe 
\"[^"]*\"      {yylval = makenode(strdup(yytext),NULL,NULL); return STRING_LITERAL;}
'[^']*'        {yylval = makenode(strdup(yytext),NULL,NULL); return STRING_LITERAL;}
"True"         {return TRUE_LIT;}
"False"        {return FALSE_LIT;}
[ \t]+         ; // ignore white spaces or tab
\n             {lineno++;} //linecounter
#.*$           ; // ignore comments 


//specials signs
";"            {return ';';}
","            {return ',';}
"{"            {return '{';}
"}"            {return '}';}
"("            {return '(';}
")"            {return ')';}
"["            {return '[';}
"]"            {return ']';}
"->"           {return TYPE;}
":"            {return ':';}

.              {fprintf(stderr, "Lexical error on line %d: Unrecognized character '%s'\n", lineno, yytext);
                return yytext[0];} // Still return the character to the parser
%%