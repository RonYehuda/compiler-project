# Simple Programming Language Compiler

This project implements a scanner and parser for a simple procedural programming language, generating an Abstract Syntax Tree (AST) representation of the source code.

## Features

The compiler supports the following language features:

- Function definitions with optional return types
- Variable declarations with types (int, bool, string)
- Parameter lists with multiple types
- If-elif-else control structures
- While loops
- String operations (indexing and slicing)
- Multi-assignment statements
- Expressions with operator precedence
- Comments

## Project Structure

- `hw1.l` - Lexical analyzer (scanner) written in Flex
- `hw1.y` - Syntax analyzer (parser) written in Bison
- `ast.h` - AST node structure definition
- `ast.c` - AST node creation and manipulation functions

## Building the Compiler

To build the compiler, you need Flex, Bison, and GCC installed on your system.

```bash
# Generate the parser from the grammar
bison -d hw1.y

# Generate the lexer from the lexical rules
flex hw1.l

# Compile everything together
gcc -Wall -g -o parser hw1.tab.c lex.yy.c ast.c -lfl
```

## Running the Compiler

To run the compiler on a source file:

```bash
./parser < your_program.txt
```

This will parse the input file and, if parsing is successful, display the AST structure.

## Language Syntax Examples

### Function Definition

```
def foo(int x, y, z; bool f): {
    # Function body
}

def goo()->string: {
    return "hello";
}
```

### If-Elif-Else Statement

```
if x > 5: {
    y = 1;
} elif x == 5: {
    y = 2;
} else: {
    y = 3;
}
```

### While Loop

```
while x < 10: {
    x = x + 1;
}
```

### String Operations

```
s = "hello";
s = s[0];        # Indexing
s = s[1:4];      # Slicing
s = s[1:5:2];    # Slicing with step
s = s[:5];       # From beginning to position
s = s[5:];       # From position to end
s = s[:];        # Full string copy
```

### Multi-Assignment

```
x, y = 10, 20;
```

## AST Structure

The generated AST follows a tree structure with nodes for each language construct. Each node contains:
- A token (string representing the node type or value)
- Left child (first operand or child node)
- Right child (second operand or sibling node)

For example, a function definition creates a FUNC node with the function name and body as children.

## Limitations and Future Work

- Error reporting is basic and could be improved
- No semantic analysis yet (type checking, variable scoping, etc.)
- No code optimization
- No code generation

## Authors Ron Yehuda

Created as part of a compiler construction course project.
