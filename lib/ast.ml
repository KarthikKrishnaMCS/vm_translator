(* ast.ml *)
type arithmetic =
  | Add
  | Sub
  | Neg
  | Eq
  | Gt
  | Lt
  | And
  | Or
  | Not

type segment =
  | Argument
  | Local
  | Static
  | Constant
  | This
  | That
  | Pointer
  | Temp

type memory =
  | Push of segment * int
  | Pop of segment * int

type prog =
  | Label of string
  | Goto of string
  | IfGoto of string

type func =
  | Func of string * int  
  | Call of string * int    
  | Return

type instruction =
  | Arithmetic of arithmetic
  | Memory of memory
  | Program of prog
  | Function of func

