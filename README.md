
# VM Translator

This project translates virtual machine (VM) instructions to Hack assembly code. It is implemented in OCaml and utilizes a number of key concepts like syntax tree generation, parsing, and symbol table management.

## Prerequisites

- **OCaml:** Ensure that OCaml is installed on your system. You can download it from the [official OCaml website](https://ocaml.org/).  
- **Dune:** This project uses Dune as the build system. Install Dune by following the instructions on the [Dune GitHub page](https://github.com/ocaml/dune).  

## Features

- **Syntax Tree Generation:** Implements a structured representation of the parsed VM code.
- **Parser:** The parser.ml file parses VM instructions and converts them into an abstract syntax tree. 
- **Translation:** The machine.ml file handles the translation of VM instructions into Hack assembly code. 
- **Symbol Table:** A symbol table is implemented to manage variables and labels during translation.

## Project Structure

- **`ast.ml`**: Contains definitions for the abstract syntax tree (AST) generation.
- **`parser.ml`**: Contains functions for parsing VM instructions into the AST. 
- **`machine.ml`**: Responsible for translating the instructions into Hack assembly language.
- **`symbol_table.ml`**: Implements the symbol table to store variables and labels.
- **`.bin\main.ml`**: The entry point of the VM translator

## Installation

1. **Clone the Repository:**  
   ```bash
   git clone https://github.com/KarthikKrishnaMCS/vm_translator.git
2. **Navigate to the Project Directory:**  
   ```bash
   cd vm_translator
3. **Build the Project Using Dune**  
   ```bash
   dune build

## Usage

After building the project, run the VM translator to translate VM files into Hack assembly files:

  ```bash
   dune ./bin/main.exe > file.vm
  ```
Replace file.vm with your VM file.


## Example

Given a VM file Add.vm with the following content:

  ```vm
   // This program computes sum of two numbers 10 and 20
   push constant 10
   push constant 20
   add
   ```

Running the VM translator will produce a Hack assembly file Add.asm with the corresponding machine code:

   ```asm
   @10
   D=A
   @SP
   A=M
   M=D
   @20
   D=A
   @SP
   A=M
   M=D
   @SP
   M=M+1
   A=A-1
   D=M
   A=A-1
   M=D+M
   ```

## Acknowledgements

This VM translator is inspired by the projects and teachings from the "Elements of Computing Systems" course, also known as Nand2Tetris. Special thanks to Noam Nisan and Shimon Schocken for their foundational work in computer science education.


