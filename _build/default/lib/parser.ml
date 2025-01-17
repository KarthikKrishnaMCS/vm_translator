(* parser.ml *)
open Ast

(* Function to parse segment from string *)
let parse_segment = function
  | "argument" -> Argument
  | "local" -> Local
  | "static" -> Static
  | "constant" -> Constant
  | "this" -> This
  | "that" -> That
  | "pointer" -> Pointer
  | "temp" -> Temp
  | seg -> failwith ("Unknown segment: " ^ seg)

(* Function to parse arithmetic operations *)
let parse_arithmetic = function
  | "add" -> Arithmetic Add
  | "sub" -> Arithmetic Sub
  | "neg" -> Arithmetic Neg
  | "eq" -> Arithmetic Eq
  | "gt" -> Arithmetic Gt
  | "lt" -> Arithmetic Lt
  | "and" -> Arithmetic And
  | "or" -> Arithmetic Or
  | "not" -> Arithmetic Not
  | op -> failwith ("Unknown arithmetic operation: " ^ op)

(* Function to parse memory commands *)
let parse_memory words =
  match words with
  | ["push"; segment; value] ->
    Memory (Push (parse_segment segment, int_of_string value))
  | ["pop"; segment; value] ->
    Memory (Pop (parse_segment segment, int_of_string value))
  | _ -> failwith "Invalid memory command"

(* Function to parse program commands *)
let parse_program = function
  | ["label"; name] -> Program (Label name)
  | ["goto"; name] -> Program (Goto name)
  | ["if-goto"; name] -> Program (IfGoto name)
  | _ -> failwith "Invalid program command"

(* Function to parse function commands *)
let parse_function = function
  | ["function"; name; n] -> Function (Func (name, int_of_string n))
  | ["call"; name; n] -> Function (Call (name, int_of_string n))
  | ["return"] -> Function Return
  | _ -> failwith "Invalid function command"
(*
(* Main parser function *)
let parse_instruction line =
  let words = String.split_on_char ' ' (String.trim line) in
  match words with
  | [] | [""] -> None
  | [op] -> Some (parse_arithmetic op)
  | "push" :: _ | "pop" :: _ -> Some (parse_memory words)
  | "label" :: _ | "goto" :: _ | "if-goto" :: _ -> Some (parse_program words)
  | "function" :: _ | "call" :: _ | "return" :: _ -> Some (parse_function words)
  | _ -> None
*)
let parse_instruction line =
  let words = String.split_on_char ' ' (String.trim line) in
  match words with
  | [] | [""] -> None
  | [op] when List.mem op ["add"; "sub"; "neg"; "eq"; "gt"; "lt"; "and"; "or"; "not"] -> 
      Some (parse_arithmetic op)  (* Only parse arithmetic operations here *)
  | "push" :: _ | "pop" :: _ -> Some (parse_memory words)
  | "label" :: _ | "goto" :: _ | "if-goto" :: _ -> Some (parse_program words)
  | "function" :: _ | "call" :: _ -> Some (parse_function words)  (* Match function or call commands here *)
  | ["return"] -> Some (Function Return)  (* Directly parse return as a function-related instruction *)
  | _ -> None

