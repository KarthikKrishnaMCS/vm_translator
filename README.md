
# VM Translator

This project translates virtual machine (VM) instructions to Hack assembly code. It is implemented in OCaml and utilizes a number of key concepts like syntax tree generation, parsing, and symbol table management.

## Features

- **Syntax Tree Generation:** Implements a structured representation of the parsed VM code.
- **Parser:** The parser.ml file parses VM instructions and converts them into an abstract syntax tree. 
- **Translation:** The machine.ml file handles the translation of VM instructions into Hack assembly code. 
- **Symbol Table:** A symbol table is implemented to manage variables and labels during translation.

## Prerequisites

- **OCaml:** Ensure that OCaml is installed on your system. You can download it from the [official OCaml website](https://ocaml.org/).  
- **Dune:** This project uses Dune as the build system. Install Dune by following the instructions on the [Dune GitHub page](https://github.com/ocaml/dune).  

## Installation

1. **Clone the Repository:**  
   ```bash
   git clone https://github.com/KarthikKrishnaMCS/hack_assembler.git
2. **Navigate to the Project Directory:**  
   ```bash
   cd hack_assembler
3. **Build the Project Using Dune**  
   ```bash
   dune build

## Usage

After building the project, run the assembler to translate Hack assembly files into binary code:

  ```bash
   dune ./bin/main.exe > file.asm
  ```
Replace file.asm with your Hack assembly file.


## Project Structure

- **`ast.ml`**: Contains definitions for the abstract syntax tree (AST) generation.
- **`parser.ml`**: Contains functions for parsing VM instructions into the AST. 
- **`machine.ml`**: Responsible for translating the instructions into Hack assembly language.
- **`symbol_table.ml`**: Implements the symbol table to store variables and labels.


## Example

Given a Hack assembly file Max.asm with the following content:

  ```asm
   // This program computes R2 = max(R0, R1)
   @R0
   D=M
   @R1
   D=D-M
   @OUTPUT_FIRST
   D;JGT
   @R1
   D=M
   @OUTPUT_D
  0;JMP
   (OUTPUT_FIRST)
   @R0
   D=M
   (OUTPUT_D)
   @R2
   M=D
   @END
   0;JMP
   (END)
   ```

Running the assembler will produce a binary file Max.hack with the corresponding machine code:

   ```asm
   0000000000000000
   1111110000001000
   0000000000000001
   1111010011010000
   0000000000001010
   1110001100000001
   0000000000000001
   1111110000001000
   0000000000001100
   1110101010000111
   0000000000000000
   1111110000001000
   0000000000000010
   1110001100001000
   0000000000001110
   1110101010000111
   0000000000001110
   ```

## Acknowledgements

This assembler is inspired by the projects and teachings from the "Elements of Computing Systems" course, also known as Nand2Tetris. Special thanks to Noam Nisan and Shimon Schocken for their foundational work in computer science education.


