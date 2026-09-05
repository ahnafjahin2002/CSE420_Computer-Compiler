# CSE420 — Compiler Design Lab

## Complete Compiler Construction Project

A complete implementation of the major phases of a compiler for a selected subset of the C programming language, developed as part of **CSE420: Compiler Design** at the **Department of Computer Science and Engineering, BRAC University**.

This repository contains the implementations developed throughout the Compiler Design laboratory exercises, progressively building a compiler pipeline from **lexical analysis and syntax analysis** to **symbol table generation, semantic analysis, Abstract Syntax Tree (AST) construction, and three-address intermediate code generation**.

The project demonstrates how a compiler processes a source program step by step, starting from raw characters and eventually producing a structured intermediate representation of the program.

---

# 📚 Table of Contents

* [Project Overview](#-project-overview)
* [Compiler Pipeline](#-compiler-pipeline)
* [Labs Included](#-labs-included)

  * [Lab 1 — Lexical & Syntax Analysis](#lab-1--lexical-analysis--syntax-analysis)
  * [Lab 2 — Symbol Table Generation](#lab-2--symbol-table-generation)
  * [Lab 3 — Semantic Analysis](#lab-3--semantic-analysis)
  * [Lab 4 — Intermediate Code Generation](#lab-4--intermediate-code-generation)
* [Technologies Used](#-technologies-used)
* [Project Structure](#-project-structure)
* [Supported C Subset](#-supported-c-subset)
* [Lexical Analysis](#-lexical-analysis)
* [Syntax Analysis](#-syntax-analysis)
* [Symbol Table](#-symbol-table)
* [Scope Management](#-scope-management)
* [Semantic Analysis](#-semantic-analysis)
* [Type Checking](#-type-checking)
* [Type Conversion](#-type-conversion)
* [Uniqueness Checking](#-uniqueness-checking)
* [Array Checking](#-array-checking)
* [Function Parameter Checking](#-function-parameter-checking)
* [Abstract Syntax Tree](#-abstract-syntax-tree)
* [Three-Address Code](#-three-address-code)
* [Compiler Workflow](#-compiler-workflow)
* [Input and Output](#-input-and-output)
* [Building and Running](#-building-and-running)
* [Typical Workflow](#-typical-workflow)
* [Example Program](#-example-program)
* [Example Intermediate Representation](#-example-intermediate-representation)
* [Error Handling](#-error-handling)
* [Important Implementation Concepts](#-important-implementation-concepts)
* [Learning Outcomes](#-learning-outcomes)
* [Lab Progression](#-lab-progression)
* [Submission Structure](#-submission-structure)
* [Notes](#-notes)
* [Acknowledgement](#-acknowledgement)

---

# 🔎 Project Overview

A compiler is a program that translates source code written in a high-level programming language into a lower-level representation that can eventually be executed by a computer.

This project implements several fundamental compiler phases for a subset of the C programming language.

The project is developed progressively across four laboratory experiments:

```text
                 C Source Program
                        │
                        ▼
              ┌───────────────────┐
              │ Lexical Analysis  │
              │      Lexer        │
              └─────────┬─────────┘
                        │
                        ▼
                     Tokens
                        │
                        ▼
              ┌───────────────────┐
              │ Syntax Analysis   │
              │      Parser       │
              └─────────┬─────────┘
                        │
                        ▼
                Parse / Grammar
                        │
                        ▼
              ┌───────────────────┐
              │   Symbol Table    │
              │ Scope Management  │
              └─────────┬─────────┘
                        │
                        ▼
              ┌───────────────────┐
              │ Semantic Analysis │
              │ Type & Scope Check│
              └─────────┬─────────┘
                        │
                        ▼
                 Valid Program
                        │
                        ▼
              ┌───────────────────┐
              │   AST Creation    │
              │ Abstract Syntax   │
              │       Tree        │
              └─────────┬─────────┘
                        │
                        ▼
              ┌───────────────────┐
              │ Intermediate Code │
              │    Generation     │
              └─────────┬─────────┘
                        │
                        ▼
              Three-Address Code
```

Each laboratory extends the previous one, resulting in a progressively more capable compiler front-end and intermediate-code generation system.

---

# 🧪 Labs Included

## Lab 1 — Lexical Analysis & Syntax Analysis

The first laboratory focuses on constructing:

* A lexical analyzer
* A syntax analyzer
* Token recognition
* Regular-expression based lexical rules
* C subset grammar
* Grammar-rule matching
* Line counting
* Lex/Yacc integration

The lexical analyzer converts source code characters into meaningful tokens, while the syntax analyzer determines whether those tokens follow the grammar of the selected C subset.

The laboratory specification describes lexical analysis as the process of scanning a source program as a sequence of characters and converting it into sequences of tokens. It uses **Lex/Flex** and **Yacc/Bison** for constructing the scanner and parser.

---

## Lab 2 — Symbol Table Generation

The second laboratory extends the syntax analyzer by introducing a **symbol table**.

The symbol table stores information about entities encountered in the source program, including identifiers, variables, arrays, and functions.

The implementation uses a collection of scope tables, where each scope table behaves as a hash table. Scope tables are maintained as a stack/list so that nested scopes can be handled correctly.

The major concepts introduced in this laboratory are:

* Hash tables
* Symbol information
* Scope tables
* Nested scopes
* Scope entering and exiting
* Symbol insertion
* Symbol deletion
* Symbol lookup
* Function information
* Array information

---

## Lab 3 — Semantic Analysis

The third laboratory introduces **semantic analysis**.

Syntax analysis determines whether a program follows the grammar, but syntactically correct code can still contain semantic errors.

For example:

```c
int x;
x = 3.14;
```

The structure may be syntactically valid, but assigning a floating-point value to an integer variable requires semantic checking.

The semantic-analysis laboratory introduces checks including assignment compatibility, array indexing, modulus operands, division/modulus by zero, function-call arguments, undeclared variables, duplicate declarations, and invalid function usage.

---

## Lab 4 — Intermediate Code Generation

The fourth laboratory moves the project toward actual compiler intermediate representation.

The laboratory introduces:

* Abstract Syntax Tree construction
* AST node hierarchy
* AST traversal
* Three-address code
* Temporary variables
* Labels
* Control-flow instructions
* Function calls
* Return statements

The specification describes intermediate code as a representation between high-level source code and low-level target code and uses **three-address code** as the intermediate representation.

The AST is constructed during parsing and subsequently traversed to generate intermediate code.

---

# 🛠 Technologies Used

The project is primarily based on the following technologies and concepts:

* **C / C++**
* **Lex / Flex**
* **Yacc / Bison**
* Regular Expressions
* Context-Free Grammars
* Hash Tables
* Symbol Tables
* Scope Management
* Semantic Analysis
* Abstract Syntax Trees
* Three-Address Code
* Compiler Construction

---

# 🏗 Compiler Pipeline

The complete project can be viewed as the following pipeline:

```text
Source Code
    │
    ▼
┌───────────────┐
│ Lexical       │
│ Analyzer      │
└───────┬───────┘
        │
        ▼
      Tokens
        │
        ▼
┌───────────────┐
│ Syntax        │
│ Analyzer      │
└───────┬───────┘
        │
        ▼
   Parse Structure
        │
        ▼
┌───────────────┐
│ Symbol Table  │
│ Generation    │
└───────┬───────┘
        │
        ▼
 Symbol Information
        │
        ▼
┌───────────────┐
│ Semantic      │
│ Analysis      │
└───────┬───────┘
        │
        ▼
Semantically Valid
Program
        │
        ▼
┌───────────────┐
│ AST           │
│ Construction  │
└───────┬───────┘
        │
        ▼
Abstract Syntax Tree
        │
        ▼
┌───────────────┐
│ Intermediate  │
│ Code Generator│
└───────┬───────┘
        │
        ▼
Three-Address Code
```

Each stage receives information from the previous stage and produces information required by the next stage.

---

# 🧩 Lab 1 — Lexical Analysis & Syntax Analysis

## 1. Lexical Analyzer

The lexical analyzer, commonly known as a **lexer**, **scanner**, or **lexical analyzer**, scans the source program character by character and groups characters into tokens.

For example:

```c
int x = 5;
```

can be represented conceptually as:

```text
<INT> <ID> <ASSIGNOP> <CONST_INT> <SEMICOLON>
```

The identifier token also carries its associated symbol where necessary.

---

## 2. Keywords

The lexer recognizes keywords from the specified C subset.

The required keyword mappings include:

| Keyword    | Token      |
| ---------- | ---------- |
| `if`       | `IF`       |
| `else`     | `ELSE`     |
| `void`     | `VOID`     |
| `for`      | `FOR`      |
| `while`    | `WHILE`    |
| `switch`   | `SWITCH`   |
| `do`       | `DO`       |
| `break`    | `BREAK`    |
| `default`  | `DEFAULT`  |
| `int`      | `INT`      |
| `char`     | `CHAR`     |
| `goto`     | `GOTO`     |
| `float`    | `FLOAT`    |
| `double`   | `DOUBLE`   |
| `return`   | `RETURN`   |
| `continue` | `CONTINUE` |
| `case`     | `CASE`     |
| `printf`   | `PRINTLN`  |

These mappings are specified in the Lab 1 keyword table.

---

## 3. Constants

The lexer recognizes integer and floating-point constants.

### Integer Constants

One or more consecutive digits form an integer literal.

Example:

```c
10
100
5000
```

These are classified as:

```text
CONST_INT
```

The `+` or `-` sign is not considered part of the integer literal.

### Floating-Point Constants

The specified language supports floating-point representations such as:

```text
3.14159
3.14159E-10
.314159
314159E10
```

These are classified as:

```text
CONST_FLOAT
```

---

# ➕ Operators and Punctuators

The lexical analyzer recognizes operators and punctuation symbols required by the language.

| Symbol                           | Token       |   |           |
| -------------------------------- | ----------- | - | --------- |
| `+`, `-`                         | `ADDOP`     |   |           |
| `*`, `/`, `%`                    | `MULOP`     |   |           |
| `++`                             | `INCOP`     |   |           |
| `--`                             | `DECOP`     |   |           |
| `<`, `>`, `==`, `<=`, `>=`, `!=` | `RELOP`     |   |           |
| `=`                              | `ASSIGNOP`  |   |           |
| `&&`, `                          |             | ` | `LOGICOP` |
| `!`                              | `NOT`       |   |           |
| `(`                              | `LPAREN`    |   |           |
| `)`                              | `RPAREN`    |   |           |
| `{`                              | `LCURL`     |   |           |
| `}`                              | `RCURL`     |   |           |
| `[`                              | `LTHIRD`    |   |           |
| `]`                              | `RTHIRD`    |   |           |
| `,`                              | `COMMA`     |   |           |
| `:`                              | `COLON`     |   |           |
| `;`                              | `SEMICOLON` |   |           |

The complete operator and punctuator mapping follows the Lab 1 specification.

---

# 🔤 Identifiers

Identifiers represent names assigned to entities such as:

* Variables
* Functions
* Arrays
* Other supported entities

An identifier may contain:

```text
a-z
A-Z
0-9
_
```

However, the first character must be:

```text
a-z
A-Z
_
```

When an identifier is recognized, the lexer returns the `ID` token together with its symbol information.

Examples:

```c
x
counter
student_name
_sum
value123
```

---

# 📝 Whitespace and Line Counting

Whitespace and newline characters are captured by the lexical analyzer.

No specific action is required for whitespace itself, but newline information is important because the compiler output keeps track of source-code line numbers.

The lexer maintains a line count so that the generated log can identify where tokens and grammar rules occur.

---

# 🌳 Syntax Analysis

After lexical analysis, tokens are passed to the parser.

The parser uses a context-free grammar to determine whether the sequence of tokens forms a valid program according to the selected subset of C.

The parser is implemented using Yacc/Bison.

An important part of the implementation is passing symbol information from the lexer to the parser through a `SymbolInfo` pointer.

For example:

```text
Lexer detects identifier
        │
        ▼
Returns ID token
        │
        ▼
Passes symbol/type information
        │
        ▼
Parser receives semantic value
```

The Lab 1 specification explicitly requires the use of a `SymbolInfo` pointer for passing identifier information between the lexical analyzer and parser.

---

# ⚠️ Grammar Ambiguity

The parser must also handle ambiguity in the supplied grammar.

A classic example is the **dangling else** problem:

```c
if (condition)
    if (condition2)
        statement;
    else
        statement;
```

The parser must resolve such ambiguity correctly.

The Lab 1 specification requires the Yacc file to compile with:

```text
0 conflicts
```

---

# 📄 Lab 1 Output

The output log contains:

* Recognized tokens
* Token information
* Line numbers
* Matching grammar rules
* Relevant source-code segments
* Final line count

The specification requires the output to follow the prescribed format and encourages matching the supplied sample I/O format as closely as possible.

---

# 🗂 Lab 2 — Symbol Table Generation

## What is a Symbol Table?

A symbol table is a data structure used by a compiler to store information about entities appearing in a program.

For example:

```c
int x;
float y;
int add(int a, int b);
```

The compiler needs to know information such as:

```text
x → int
y → float
add → function
```

The symbol table introduced in Lab 2 stores information related to symbols and their scopes.

---

# 🧮 Hash-Based Scope Table

Each individual scope is represented using a **scope table**.

A scope table is essentially a hash table containing symbols belonging to that particular scope.

Conceptually:

```text
Scope Table
────────────────────────────
Bucket 0 → symbols
Bucket 1 → symbols
Bucket 2 → symbols
Bucket 3 → symbols
...
Bucket N → symbols
```

A hash function receives the symbol name and determines the bucket in which the symbol should be stored.

The hash value must remain within the range of the available buckets.

---

# 🔗 Symbol Table and Scope Table

The complete symbol table consists of multiple scope tables.

For example:

```text
Global Scope
     │
     ▼
Function Scope
     │
     ▼
If Block Scope
```

Each newly created scope table maintains a reference to its parent scope.

Conceptually:

```text
Scope 3
   │
   └── parent → Scope 2
                    │
                    └── parent → Scope 1
                                      │
                                      └── parent → NULL
```

This allows the compiler to search for symbols through nested scopes.

The specification describes the collection as a list or stack of scope tables. When entering a block, a new scope table is created and placed on top; when leaving the block, the current scope is removed.

---

# 🔍 Scope Lookup

When a symbol is referenced, lookup begins in the current scope.

If the symbol is not found:

```text
Current Scope
     │
     │ not found
     ▼
Parent Scope
     │
     │ not found
     ▼
Parent Scope
     │
     ▼
Global Scope
```

This mechanism allows nested scopes to correctly access symbols declared in outer scopes.

It also supports **shadowing**.

For example:

```c
int x;

void func() {
    int x;

    if (condition) {
        int x;
    }
}
```

The `x` declared in the innermost scope can hide an `x` declared in an outer scope.

---

# 🔧 Scope Table Operations

The scope table provides several fundamental operations.

## Insert

Adds a symbol to the current scope if it does not already exist in that scope.

```text
Insert(symbol)
```

The operation returns whether insertion was successful.

---

## Lookup

Searches the current scope table for a particular symbol.

```text
Lookup(symbol)
```

If found, a `SymbolInfo` pointer is returned.

---

## Delete

Removes a symbol from the current scope.

```text
Delete(symbol)
```

The operation returns success or failure.

---

## Print

Prints the current scope table to the log.

These operations are required by the Lab 2 specification.

---

# 🔄 Symbol Table Operations

The overall symbol table provides:

```text
Enter Scope
Exit Scope
Insert
Remove
Lookup
Print Current Scope
Print All Scopes
```

### Enter Scope

Creates a new scope table and makes it the current scope.

### Exit Scope

Removes the current scope table.

### Insert

Inserts a symbol into the current scope.

### Remove

Removes a symbol from the current scope.

### Lookup

Searches the current scope and then progressively searches parent scopes.

### Print Current Scope

Prints the currently active scope.

### Print All Scopes

Prints all currently active scope tables.

These operations are explicitly required by the Lab 2 specification.

---

# 🧱 Types of Symbols

The symbol table supports three major categories of identifiers.

## 1. Normal Variables

A normal variable stores information such as:

```text
Name
Datatype
```

Example:

```c
int x;
float y;
```

---

## 2. Array Variables

Array symbols store:

```text
Name
Datatype
Array Size
```

Example:

```c
int numbers[10];
```

---

## 3. Function Names

Function symbols store information including:

```text
Function Name
Return Type
Number of Parameters
Parameter Types
```

This information becomes especially important during semantic analysis and function-call checking.

These three symbol categories are specified in Lab 2.

---

# 🧠 Lab 3 — Semantic Analysis

Syntax correctness alone does not guarantee that a program is valid.

Consider:

```c
int x;
x = "hello";
```

The grammar may recognize the statement structure, but the assignment is semantically invalid.

Semantic analysis examines the meaning and consistency of the program.

The project performs several categories of semantic checking.

---

# ✅ Type Checking

The semantic analyzer performs different forms of type checking.

The required checks include:

1. Assignment compatibility
2. Array index type
3. Modulus operand types
4. Division/modulus by zero
5. Function-call argument compatibility
6. Invalid use of void functions

These checks are specified in the semantic-analysis laboratory.

---

# 🧮 Assignment Type Checking

The compiler checks whether the right-hand side of an assignment is compatible with the left-hand side.

For example:

```c
int x;
x = 10;
```

is compatible.

However:

```c
int x;
x = 3.14;
```

requires conversion/checking because the expression has floating-point type.

The right-hand side may be a complex expression containing:

* Constants
* Variables
* Function calls
* Arithmetic expressions
* Logical expressions
* Relational expressions

The semantic analyzer therefore needs to propagate type information through expressions.

---

# 📐 Array Index Checking

Array indices must have the appropriate type.

For example:

```c
int arr[10];
int x;

arr[x] = 5;
```

is valid if `x` is an integer.

An invalid example would be:

```c
float x;
arr[x] = 5;
```

The semantic analyzer detects this type mismatch.

The specification specifically requires checking that an array index is an integer.

---

# % Modulus Operator Checking

The modulus operator has additional semantic restrictions.

Both operands must be integers.

For example:

```c
int x;
int y;

x % y;
```

is valid.

But:

```c
float x;
int y;

x % y;
```

should produce a semantic error.

---

# ⚠️ Division and Modulus by Zero

The semantic analyzer also checks that the second operand of division and modulus is not zero.

Examples:

```c
x / 0;
x % 0;
```

should generate an error according to the laboratory requirements.

---

# ☎️ Function Call Checking

Function calls must be compatible with their corresponding function definitions.

For example:

```c
int add(int a, int b);
```

A call such as:

```c
add(10, 20);
```

has two arguments and therefore matches the parameter count.

The semantic analyzer checks:

```text
Function exists?
        │
        ▼
Is it actually a function?
        │
        ▼
Correct number of arguments?
        │
        ▼
Correct argument types?
```

The function information stored in the symbol table during Lab 2 is used to perform these checks.

---

# 🚫 Void Function in Expression

A function returning `void` cannot be used as a value-producing component of an expression.

For example, a construct conceptually equivalent to:

```c
x = voidFunction();
```

should be rejected when the language rules require an expression value.

The semantic-analysis specification explicitly requires detection of this situation.

---

# 🔄 Type Conversion

The semantic analyzer also handles type-conversion-related situations.

For example:

```c
int x;
float y;

x = y;
```

The compiler should generate an appropriate error or warning for assigning a floating-point value to an integer variable.

The specification also requires the results of:

```text
RELOP
LOGICOP
```

operations to be treated as integers.

---

# 🔎 Uniqueness and Declaration Checking

The compiler verifies whether variables used in expressions have been declared.

For example:

```c
int x;
x = 10;
```

is valid.

But:

```c
x = 10;
```

should result in an undeclared-variable error if `x` has not been declared in any accessible scope.

The compiler also checks whether the same identifier has been declared multiple times within the same scope.

---

# 📦 Array Usage Checking

The semantic analyzer distinguishes between array identifiers and normal variables.

For example:

```c
int arr[10];
int x;

arr[0] = 10;
```

uses an array correctly.

However, using an array without an index or using a scalar as an array should be detected.

The laboratory explicitly requires checking whether an index is used with an array and vice versa.

---

# 👨‍💻 Function Parameter Checking

The compiler verifies both:

```text
Number of arguments
```

and:

```text
Types of arguments
```

when a function is called.

For example:

```c
int multiply(int a, int b);
```

The call:

```c
multiply(5, 10);
```

has the correct number of arguments.

The compiler must also reject a function call made using an identifier that does not represent a function.

These checks rely on function metadata stored in the symbol table.

---

# 🛑 Error Recovery

One of the important requirements of semantic analysis is that the compiler should **not stop after detecting the first error**.

Instead, it should continue processing the source program and collect additional errors.

Conceptually:

```text
Source Program
      │
      ▼
Error 1 ───────┐
               │
Error 2 ───────┤
               │
Error 3 ───────┤
               ▼
        Continue Parsing
               │
               ▼
       Report All Errors
```

The specification explicitly requires compilation to continue until the end of the given C program so that all detectable errors can be captured.

---

# 🌳 Lab 4 — Abstract Syntax Tree

The fourth laboratory introduces an **Abstract Syntax Tree (AST)**.

An AST provides a structured representation of a program.

For example:

```c
x = a + b;
```

can conceptually be represented as:

```text
        Assignment
        /        \
       x          +
                /   \
               a     b
```

The AST removes unnecessary syntactic details while preserving the essential structure of the program.

---

# 🧱 AST Node Hierarchy

The required AST design includes a base:

```text
ASTNode
```

from which specialized node types inherit.

---

## Expression Nodes

The specification identifies the following expression node types:

```text
ExprNode
│
├── VarNode
├── ConstNode
├── BinaryOpNode
├── UnaryOpNode
├── AssignNode
└── FuncCallNode
```

These represent:

* Variable references
* Constants
* Binary expressions
* Unary expressions
* Assignment expressions
* Function calls

---

# 📋 Statement Nodes

Statement nodes include:

```text
StmtNode
│
├── ExprStmtNode
├── BlockNode
├── IfNode
├── WhileNode
├── ForNode
├── ReturnNode
└── DeclNode
```

These represent:

* Expression statements
* Compound blocks
* If-else statements
* While loops
* For loops
* Return statements
* Variable declarations

---

# 🌲 Program Node

At the root of the AST is:

```text
ProgramNode
```

The `ProgramNode` represents the complete source program.

A simplified AST hierarchy therefore looks like:

```text
ProgramNode
│
├── Declaration
├── Function
│   ├── Parameters
│   └── BlockNode
│       ├── Declaration
│       ├── IfNode
│       ├── WhileNode
│       ├── ForNode
│       └── ReturnNode
│
└── ...
```

The AST classes and their `generate_code` functionality form a major part of Lab 4.

---

# 🔨 AST Construction During Parsing

The AST is constructed while the parser recognizes grammar rules.

Instead of only printing grammar rules, parser actions create AST nodes and connect them together.

Conceptually:

```text
Grammar Rule
     │
     ▼
Parser Action
     │
     ▼
Create AST Node
     │
     ▼
Attach Child Nodes
     │
     ▼
Return AST Node
```

For example, an assignment expression:

```c
x = a + b;
```

can create:

```text
AssignNode
   │
   ├── VarNode(x)
   │
   └── BinaryOpNode(+)
          ├── VarNode(a)
          └── VarNode(b)
```

The Lab 4 specification explicitly requires modifying parser actions so that each grammar rule creates and connects the appropriate AST nodes.

---

# ⚙️ Three-Address Code Generation

Once the AST has been constructed, it can be traversed to generate intermediate code.

The project uses **three-address code (TAC)**.

Three-address code generally represents an operation using a limited number of operands.

For example:

```c
x = a + b * c;
```

may be represented conceptually as:

```text
t0 = b * c
t1 = a + t0
x = t1
```

This representation makes complex expressions easier for later compiler phases to process.

---

# 🔢 Temporary Variables

Temporary variables are used for intermediate results.

The specified naming convention is:

```text
t0
t1
t2
t3
...
```

For example:

```text
t0 = a + b
t1 = t0 * c
```

The specification explicitly defines temporary variables using the `t0`, `t1`, `t2`, ... convention.

---

# 🏷 Labels

Labels represent locations used for control flow.

The specified format is:

```text
L0
L1
L2
L3
...
```

For example:

```text
if t1 goto L0
goto L1

L0:
    ...
L1:
    ...
```

Labels become particularly important when generating code for:

* `if`
* `if-else`
* `while`
* `for`

---

# ➕ Arithmetic Operations

The intermediate-code generator handles arithmetic operators such as:

```text
+
-
*
/
```

For example:

```c
x = a + b * c;
```

could become:

```text
t0 = b * c
t1 = a + t0
x = t1
```

This demonstrates how operator precedence can naturally be represented by the AST and then translated into a sequence of simple instructions.

---

# 🔀 Logical Operations

Logical operations include:

```text
&&
||
!
```

The intermediate representation provides instructions corresponding to these operations.

The AST structure determines the order in which the logical expressions are evaluated.

---

# ⚖️ Relational Operations

Relational operators include:

```text
<
>
==
!=
<=
>=
```

For example:

```c
a < b
```

can be represented as a relational operation in the AST and subsequently translated into intermediate code.

---

# 📝 Assignment Operations

Assignment:

```c
x = expression;
```

is represented using an `AssignNode`.

A simple assignment may generate:

```text
x = t0
```

where `t0` contains the result of the expression.

---

# 📦 Array Access

Array access such as:

```c
a[i]
```

must also be represented in the intermediate code.

The Lab 4 specification specifically requires code generation support for array access.

---

# 🔀 Control Flow

The intermediate-code generator supports:

```text
if-else
while
for
```

Control flow is represented using labels and jumps.

A conceptual `if-else` structure:

```c
if (condition)
    statement1;
else
    statement2;
```

can be represented as:

```text
if condition goto L0
goto L1

L0:
    code(statement1)
    goto L2

L1:
    code(statement2)

L2:
```

The exact emitted representation depends on the implementation.

---

# 🔁 While Loop

A `while` loop can conceptually be translated as:

```text
L0:
    evaluate condition
    if condition goto L1
    goto L2

L1:
    loop body
    goto L0

L2:
```

The key idea is that a label marks the beginning of the loop and control returns to that label after executing the body.

---

# 🔄 For Loop

A `for` loop can be represented using multiple stages:

```text
initialization
      │
      ▼
condition
      │
      ▼
body
      │
      ▼
update
      │
      └──────────► condition
```

A conceptual TAC structure is:

```text
initialization

L0:
    condition
    if condition goto L1
    goto L2

L1:
    body
    update
    goto L0

L2:
```

---

# 📞 Function Calls and Returns

The intermediate-code generator also supports:

```text
function calls
return statements
```

For example:

```c
x = add(a, b);
```

can conceptually be represented using a function-call instruction and a temporary/result assignment.

A return statement can be represented using:

```text
return value
```

The specification explicitly lists function calls and returns among the required code-generation features.

---

# 🔄 Complete Compiler Workflow

The entire project can be understood as a sequence of transformations.

## Step 1 — Source Code

Input:

```c
int x;
x = 10 + 20;
```

---

## Step 2 — Lexical Analysis

The lexer recognizes:

```text
INT
ID
SEMICOLON
ID
ASSIGNOP
CONST_INT
ADDOP
CONST_INT
SEMICOLON
```

---

## Step 3 — Syntax Analysis

The parser verifies that the token sequence follows the grammar.

---

## Step 4 — Symbol Table

The compiler stores:

```text
x → int
```

inside the appropriate scope.

---

## Step 5 — Semantic Analysis

The compiler checks:

```text
Is x declared?
Is x assignable?
Is the expression type compatible?
```

---

## Step 6 — AST Construction

The expression becomes a tree:

```text
       Assign
       /    \
      x      +
            / \
          10  20
```

---

## Step 7 — Intermediate Code

The AST can generate:

```text
t0 = 10 + 20
x = t0
```

This demonstrates the overall purpose of the four laboratory stages.

---

# 📂 Input and Output

The laboratories use C source files as input.

The Lab 1 specification describes the input as a C source program whose filename is supplied through the command line.

Lab 2 similarly uses a `.c` source file as input.

Lab 3 uses a `.c` source file and produces both log and error information.

Lab 4 continues with a C source file and produces log, error, and intermediate-code output.

---

# 📄 Output Files

Depending on the laboratory stage, output includes different information.

## Lab 1

The log contains:

```text
Tokens
Line numbers
Grammar rules
Source-code segments
Line count
```

---

## Lab 2

The log additionally contains:

```text
Scope creation
Scope removal
Symbol-table contents
Symbol information
Line count
```

The Lab 2 specification requires the ID of newly created scopes to be printed, the removed scope to be reported, and the symbol table state to be printed when leaving a scope.

---

## Lab 3

The outputs include:

```text
<student_id>_log.txt
<student_id>_error.txt
```

The log includes:

```text
Grammar rules
Source-code segments
Line count
Error count
```

The error file contains:

```text
Semantic errors
Warnings
Error count
```

The specification specifically requires the error count to appear at the end of both appropriate output files.

---

## Lab 4

The outputs include:

```text
log.txt
error.txt
code.txt
```

### `log.txt`

Contains:

* Grammar-rule information
* Source-code segments
* AST information
* Line count
* Error count

### `error.txt`

Contains:

* Parsing errors
* Semantic errors
* Error count

### `code.txt`

Contains:

* Generated three-address code
* Temporaries
* Labels
* Control-flow instructions
* Appropriate comments

These output requirements are specified in Lab 4.

---

# 🏃 Building and Running

The repository contains the source files and scripts required by the respective laboratory implementations.

A typical Lex/Yacc based workflow consists of:

```bash
flex lexer.l
bison -d parser.y
g++ lex.yy.c parser.tab.c -o compiler
```

Depending on the exact filenames and build script included in the repository, the corresponding `script.sh` can be used to automate the build process.

A typical execution pattern is:

```bash
./compiler input.c
```

The exact command should follow the filenames and compilation commands provided by the implementation in this repository.

---

# 📜 Script-Based Compilation

The laboratory specifications require a script named:

```text
script.sh
```

for the submission structure.

The script is intended to simplify the generation and compilation process.

A typical pipeline is:

```text
script.sh
    │
    ├── Flex
    │
    ├── Bison
    │
    ├── C/C++ Compiler
    │
    └── Executable
```

This makes the compiler easier to build and test repeatedly.

---

# 🧪 Typical Workflow

A typical development workflow is:

```bash
# Build the compiler
./script.sh

# Run against an input program
./compiler input.c
```

The exact executable name may vary according to the implementation.

After execution, inspect the generated output files:

```text
log.txt
error.txt
code.txt
```

where applicable.

---

# 💻 Example Program

A suitable input program may contain several language features supported by the project:

```c
int add(int a, int b)
{
    int result;

    result = a + b;

    return result;
}

int main()
{
    int x;
    int y;
    int result;

    x = 10;
    y = 20;

    result = add(x, y);

    if (result > 20)
    {
        result = result + 1;
    }

    return 0;
}
```

This type of program allows the different compiler phases to process:

* Function declarations
* Function parameters
* Local variables
* Assignments
* Arithmetic expressions
* Function calls
* Relational expressions
* Conditional statements
* Return statements
* Nested scopes

---

# 🌲 Conceptual AST for the Example

A simplified AST could look like:

```text
Program
│
├── Function: add
│   │
│   ├── Parameters
│   │   ├── a
│   │   └── b
│   │
│   └── Block
│       │
│       ├── Declaration: result
│       │
│       ├── Assignment
│       │   ├── result
│       │   └── BinaryOp(+)
│       │       ├── a
│       │       └── b
│       │
│       └── Return
│           └── result
│
└── Function: main
    │
    └── Block
        │
        ├── Declaration: x
        ├── Declaration: y
        ├── Declaration: result
        │
        ├── Assignment: x = 10
        ├── Assignment: y = 20
        │
        ├── Assignment
        │   ├── result
        │   └── FunctionCall: add
        │
        ├── If
        │   │
        │   ├── Condition: result > 20
        │   │
        │   └── Block
        │       └── Assignment
        │
        └── Return: 0
```

---

# ⚙️ Example Three-Address Code

A corresponding intermediate representation could conceptually contain instructions such as:

```text
t0 = a + b
result = t0
return result

x = 10
y = 20

t1 = call add, x, y
result = t1

t2 = result > 20
if t2 goto L0
goto L1

L0:
    t3 = result + 1
    result = t3

L1:
    return 0
```

The actual generated output depends on the implementation and AST/code-generation logic in the repository.

The Lab 4 specification defines temporaries such as `t0`, `t1`, `t2`, labels such as `L0`, `L1`, and control-flow instructions such as `if`, `goto`, `call`, and `return`.

---

# 🚨 Error Handling

Error handling is an important part of the project.

The compiler is designed to identify problems at different stages.

## Lexical Errors

These occur when the input contains characters or patterns that do not match the supported lexical rules.

---

## Syntax Errors

These occur when the token sequence does not conform to the grammar.

Examples include:

```text
Missing semicolon
Missing parenthesis
Invalid statement structure
Incorrect expression structure
```

---

## Semantic Errors

These occur when the program is syntactically valid but violates language rules.

Examples include:

```text
Undeclared variable
Duplicate declaration
Type mismatch
Invalid array indexing
Incorrect function parameters
Division by zero
Invalid modulus operation
Calling a non-function
Using a void function as an expression
```

---

# 📊 Error Reporting Strategy

A major requirement of the semantic-analysis phase is continued processing after errors.

Instead of:

```text
Error found
    ↓
STOP
```

the compiler should follow:

```text
Error found
    ↓
Report error
    ↓
Continue processing
    ↓
Find next error
    ↓
Report error
    ↓
Continue
    ↓
Finish compilation
```

This provides a more useful compiler diagnostic system.

The Lab 3 specification explicitly states that encountering one error should not stop processing and that all errors should be captured until the end of the source program.

---

# 🧠 Important Implementation Concepts

## Regular Expressions

Regular expressions are used in lexical analysis to recognize patterns such as:

```text
Identifiers
Integer constants
Floating-point constants
Operators
Punctuators
```

---

## Context-Free Grammar

The parser uses grammar rules to describe valid program structures.

Examples of grammar concepts include:

```text
Expressions
Statements
Declarations
Functions
Blocks
Loops
Conditional statements
```

---

## Hashing

Hashing is used by the scope table to efficiently locate symbols.

Conceptually:

```text
Symbol Name
    │
    ▼
Hash Function
    │
    ▼
Bucket Number
    │
    ▼
Symbol Entry
```

---

## Scope Stack

Nested blocks require nested scopes.

Conceptually:

```text
┌─────────────────────┐
│ Scope 3             │ ← Current
├─────────────────────┤
│ Scope 2             │
├─────────────────────┤
│ Scope 1             │ ← Global
└─────────────────────┘
```

Entering a block creates a scope.

Leaving a block removes the current scope.

---

## Symbol Information

A symbol needs enough information for later compiler phases.

Depending on the symbol category, this can include:

```text
Name
Type
Array information
Function information
Parameter information
Scope information
```

The symbol-table laboratory specifically requires enough information to represent normal variables, arrays, and functions.

---

# 🌳 AST vs Parse Tree

The project uses an Abstract Syntax Tree to provide a more useful representation for intermediate code generation.

A parse tree contains many grammar-specific details.

An AST focuses on meaningful program constructs.

For example:

```c
x = a + b;
```

can be represented as:

```text
Assignment
├── x
└── +
    ├── a
    └── b
```

This makes it easier to traverse the program and generate intermediate instructions.

---

# 🔁 Why AST is Useful

AST construction separates:

```text
Parsing
```

from:

```text
Code Generation
```

Once the AST exists, the code generator can operate on a structured representation instead of directly manipulating parser grammar rules.

This makes the intermediate-code-generation phase conceptually cleaner.

---

# 🧮 Why Three-Address Code?

Three-address code provides a simple intermediate representation.

Instead of directly translating:

```c
a = b + c * d;
```

into machine-specific instructions, the compiler first generates something similar to:

```text
t0 = c * d
t1 = b + t0
a = t1
```

This intermediate representation can then serve as a bridge toward later compiler phases such as optimization and target-code generation.

The Lab 4 specification highlights this role of intermediate code as a bridge between high-level source code and low-level target code.

---

# 📈 Lab Progression

The project demonstrates a natural progression in compiler construction.

```text
LAB 1
│
├── Lexical Analysis
└── Syntax Analysis
        │
        ▼
LAB 2
│
└── Symbol Table
        │
        ▼
LAB 3
│
└── Semantic Analysis
        │
        ▼
LAB 4
│
├── AST
└── Three-Address Code
```

Each laboratory depends conceptually on the previous one.

---

# 🧪 Lab 1 → Lab 2

Lab 1 establishes:

```text
Lexer
Parser
Grammar
Tokens
```

Lab 2 extends this by adding:

```text
Symbol Information
Scope Tables
Symbol Table
```

The syntax analyzer is modified so that identifiers and functions can be inserted into the symbol table during parsing.

---

# 🧪 Lab 2 → Lab 3

Lab 2 provides the compiler with information about:

```text
Variables
Arrays
Functions
Types
Scopes
Parameters
```

Lab 3 uses that information to perform:

```text
Type Checking
Declaration Checking
Function Checking
Array Checking
Scope-Based Lookup
```

---

# 🧪 Lab 3 → Lab 4

After semantic analysis, the compiler has enough structural and semantic information to build an AST and generate intermediate code.

Lab 4 therefore adds:

```text
AST
│
▼
AST Traversal
│
▼
Three-Address Code
```

The specification requires code generation for arithmetic, logical, relational, assignment, arrays, control structures, function calls, and returns.

---

# 📁 Expected Repository Organization

A logical organization for the project is:

```text
Compiler-Design-Lab/
│
├── Lab-1/
│   ├── lexer.l
│   ├── parser.y
│   ├── symbol_info.h
│   ├── script.sh
│   └── input.txt
│
├── Lab-2/
│   ├── lexer.l
│   ├── parser.y
│   ├── symbol_info.h
│   ├── scope_table.h
│   ├── symbol_table.h
│   ├── script.sh
│   └── input.c
│
├── Lab-3/
│   ├── lexer.l
│   ├── parser.y
│   ├── symbol_info.h
│   ├── scope_table.h
│   ├── symbol_table.h
│   ├── script.sh
│   └── input.c
│
├── Lab-4/
│   ├── lexer.l
│   ├── parser.y
│   ├── symbol_info.h
│   ├── scope_table.h
│   ├── symbol_table.h
│   ├── ast.h
│   ├── three_addr_code.h
│   ├── script.sh
│   └── input.c
│
└── README.md
```

> **Note:** The exact directory and filename organization may differ depending on how the repository has been structured.

---

# 📦 Submission-Oriented Structure

The laboratory specifications consistently require a student-ID-based submission folder containing the required source files.

For the later laboratories, the required components include files such as:

```text
<student_id>.l
<student_id>.y
script.sh
symbol_info.h
scope_table.h
symbol_table.h
input.c
```

Lab 4 additionally requires:

```text
ast.h
three_addr_code.h
```

The specifications also state that generated files and executables should not be included in the submission folder.

---

# 🚫 Files Normally Excluded from Submission

The lab specifications explicitly instruct students not to include generated or executable files such as:

```text
lex.yy.c
y.tab.c
y.tab.h
```

or executable binaries.

Generated output files should also be excluded from the submission folder where the specification requires this.

For Lab 4, the required source files include the AST and three-address-code headers, while generated files and executables are explicitly excluded.

---

# 🎯 Learning Outcomes

By completing this project, the following compiler-design concepts are demonstrated:

### Lexical Analysis

Understanding how raw source code is converted into tokens.

### Syntax Analysis

Understanding how grammar rules define valid program structures.

### Symbol Tables

Understanding how compilers store information about identifiers and functions.

### Hashing

Understanding how hash tables can efficiently organize symbols.

### Scope Management

Understanding how nested blocks and shadowing are handled.

### Semantic Analysis

Understanding how a compiler detects errors that cannot be identified through syntax alone.

### Type Systems

Understanding type compatibility and type conversion.

### AST

Understanding how source programs can be represented as structured trees.

### Intermediate Representation

Understanding how high-level source code can be converted into a machine-independent intermediate representation.

### Three-Address Code

Understanding how expressions and control flow can be represented using simple instructions, temporaries, and labels.

---

# 🔬 Concepts Demonstrated by the Project

The complete project brings together several major areas of compiler design:

```text
Regular Expressions
       +
Lexical Analysis
       +
Context-Free Grammars
       +
Parsing
       +
Symbol Tables
       +
Hashing
       +
Scope Management
       +
Type Checking
       +
Semantic Analysis
       +
AST Construction
       +
Intermediate Representation
       +
Three-Address Code
```

Together, these components form the foundation of a compiler front-end and intermediate-code generation pipeline.

---

# 📝 Notes

This repository follows the concepts and requirements specified in the CSE420 Compiler Design laboratory experiments.

The project is designed around a **subset of the C language**, rather than attempting to implement the complete C standard.

According to the Lab 1 specification, the selected language subset supports multiple functions, variable declarations in suitable locations, global variables, operators with standard precedence and associativity, and excludes certain constructs such as preprocessing directives, `break`, and `switch-case` usage.

The implementation should therefore be evaluated according to the language subset and grammar provided for the laboratory rather than the full C language specification.

---

# 🧭 Recommended Way to Explore This Repository

If you are studying the project, it is recommended to inspect the laboratories in order:

```text
1. Lab 1
   ↓
2. Lab 2
   ↓
3. Lab 3
   ↓
4. Lab 4
```

Start with the lexer and parser to understand how source code becomes tokens and grammar structures.

Then examine the symbol-table implementation to understand how identifiers and scopes are stored.

Next, study the semantic-analysis actions to understand how the compiler validates the meaning of the program.

Finally, examine the AST and three-address-code implementation to understand how the compiler transforms the source program into an intermediate representation.

---

# 🏁 Final Project Summary

This repository represents a progressive implementation of a compiler system for a subset of C.

The project begins with:

```text
Characters
```

and progressively transforms them into:

```text
Tokens
   ↓
Syntax Structure
   ↓
Symbol Information
   ↓
Semantic Information
   ↓
Abstract Syntax Tree
   ↓
Three-Address Intermediate Code
```

The four laboratories therefore demonstrate the evolution of a compiler from a basic scanner/parser into a significantly more complete compiler front-end.

The final stage combines the work of the previous stages to construct an AST and generate intermediate code, providing a clear demonstration of how source programs can be transformed into a structured representation suitable for later compilation stages.

---

# 📚 Laboratory References

This project is based on the following CSE420 Compiler Design laboratory experiments:

1. **Experiment 1 — Constructing a Lexical Analyzer & Syntax Analyzer**
2. **Experiment 2 — Symbol Table Generation**
3. **Experiment 3 — Semantic Analysis**
4. **Experiment 4 — Intermediate Code Generation**

The laboratory specifications were provided by the **Department of Computer Science and Engineering, BRAC University**.

---

# 👨‍💻 Author

**CSE420 — Compiler Design Lab**

This repository contains the laboratory implementations developed as part of the Compiler Design course.

---

# ⭐ If You Find This Repository Useful

If this repository helps you understand compiler construction, feel free to:

* ⭐ Star the repository
* 🍴 Fork the repository
* 🐛 Report issues
* 💡 Suggest improvements
* 📖 Use the implementation for learning and reference

---

## 🚀 Compiler Construction in One Picture

```text
                    ┌────────────────────┐
                    │   C Source Code    │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │ Lexical Analyzer   │
                    │      Flex/Lex      │
                    └─────────┬──────────┘
                              │
                              ▼
                         TOKEN STREAM
                              │
                              ▼
                    ┌────────────────────┐
                    │  Syntax Analyzer  │
                    │     Yacc/Bison     │
                    └─────────┬──────────┘
                              │
                              ▼
                       PARSED PROGRAM
                              │
                              ▼
                    ┌────────────────────┐
                    │   Symbol Table     │
                    │ Scope + Hash Table │
                    └─────────┬──────────┘
                              │
                              ▼
                     SYMBOL INFORMATION
                              │
                              ▼
                    ┌────────────────────┐
                    │ Semantic Analyzer  │
                    │ Type & Scope Check │
                    └─────────┬──────────┘
                              │
                              ▼
                      VALID PROGRAM
                              │
                              ▼
                    ┌────────────────────┐
                    │   AST Construction │
                    └─────────┬──────────┘
                              │
                              ▼
                       ABSTRACT SYNTAX
                             TREE
                              │
                              ▼
                    ┌────────────────────┐
                    │ Intermediate Code  │
                    │    Generation      │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │ Three-Address Code │
                    │ t0, t1, ...        │
                    │ L0, L1, ...        │
                    └────────────────────┘
```

---

## 📌 Bottom Line

The four laboratory experiments collectively cover a substantial portion of the compiler front-end:

```text
                 COMPILER DESIGN
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ▼              ▼              ▼
     FRONT-END      ANALYSIS      IR GENERATION
        │              │              │
        ▼              ▼              ▼
      Lexer         Symbol Table      AST
        │              │              │
        ▼              ▼              ▼
      Parser       Scope Handling      TAC
        │              │              │
        └──────────────┼──────────────┘
                       │
                       ▼
               COMPILER PIPELINE
```

This project provides a practical demonstration of how a compiler analyzes source code, manages identifiers and scopes, detects semantic errors, builds an abstract representation of the program, and finally produces a structured intermediate representation.

**From characters → tokens → grammar → symbols → semantics → AST → three-address code.**

That progression is the core idea behind this Compiler Design laboratory project.
