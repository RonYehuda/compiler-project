// ast.h
#ifndef AST_H
#define AST_H

typedef struct node {
    char *token;
    struct node *left;
    struct node *right;
} node;

node *makenode(char* token, node* left, node* right);
void printtree(node *tree, int indent);

extern node* ast_root;
#endif