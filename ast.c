// ast.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

node* ast_root = NULL;  //define the global variable ast_root

/*function to create a new node
 and return a pointer to it */
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

// Function to free the memory allocated for the tree
void free_node(node *n) {
    if (n == NULL) return;
    free_node(n->left);
    free_node(n->right);
    free(n->token);  // free the string
    free(n);        // free the node 
}