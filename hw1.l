%{
#include <stdio.h>
#include <string.h>
#include "ast.h"

// Include generated parser header
#include "hw1.tab.h"

// Union definition from parser
extern YYSTYPE yylval;

int lineno = 1;
%}

%%
"if"        { yylval.string_val = strdup(yytext); return IF; }
"elif"      { yylval.string_val = strdup(yytext); return ELIF; }
"else"      { yylval.string_val = strdup(yytext); return ELSE; }
"while"     { yylval.string_val = strdup(yytext); return WHILE; }
"return"    { yylval.string_val = strdup(yytext); return RETURN; }
"and"       { yylval.string_val = strdup(yytext); return AND; }
"or"        { yylval.string_val = strdup(yytext); return OR; }
"not"       { yylval.string_val = strdup(yytext); return NOT; }
"pass"      { yylval.string_val = strdup(yytext); return PASS; }
"def"       { yylval.string_val = strdup(yytext); return DEF; }
"bool"      { yylval.string_val = strdup(yytext); return BOOL; }
"int"       { yylval.string_val = strdup(yytext); return INT; }
"string"    { yylval.string_val = strdup(yytext); return STRING; }

"=="        { yylval.string_val = strdup(yytext); return EQ; }
">"         { yylval.string_val = strdup(yytext); return '>'; }
">="        { yylval.string_val = strdup(yytext); return BIG_EQ; }
"<"         { yylval.string_val = strdup(yytext); return '<'; }
"<="        { yylval.string_val = strdup(yytext); return SMALL_EQ; }
"!="        { yylval.string_val = strdup(yytext); return NO_EQ; }
"="         { yylval.string_val = strdup(yytext); return '='; }
"+"         { yylval.string_val = strdup(yytext); return '+'; }
"-"         { yylval.string_val = strdup(yytext); return '-'; }
"*"         { yylval.string_val = strdup(yytext); return '*'; }
"/"         { yylval.string_val = strdup(yytext); return '/'; }
"**"        { yylval.string_val = strdup(yytext); return POWER; }

[0-9]+      { yylval.string_val = strdup(yytext); return INTEGER_LITERAL; }
[0-9]+\.[0-9]+ { yylval.string_val = strdup(yytext); return FLOAT_LITERAL; }
"True"      { yylval.string_val = strdup(yytext); return TRUE_LIT; }
"False"     { yylval.string_val = strdup(yytext); return FALSE_LIT; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.string_val = strdup(yytext); return ID; }
\"[^"]*\"   { yylval.string_val = strdup(yytext); return STRING_LITERAL; }
'[^']*'     { yylval.string_val = strdup(yytext); return STRING_LITERAL; }
[ \t]+      ; /* Ignore whitespace */
\n          { lineno++; } /* Count line numbers */
#.*$        ; /* Ignore comments */

";"         { return ';'; }
","         { return ','; }
"{"         { return '{'; }
"}"         { return '}'; }
"("         { return '('; }
")"         { return ')'; }
"["         { return '['; }
"]"         { return ']'; }
"->"        { yylval.string_val = strdup(yytext); return TYPE; }
":"         { return ':'; }

.           { fprintf(stderr, "Lexical error on line %d: Unrecognized character '%s'\n", lineno, yytext); return yytext[0]; }
%%

int yywrap() {
    return 1; /* Indicate end of input */
}