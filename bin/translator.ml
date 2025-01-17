open Ast

let segment_to_asm = function
  | Argument -> "ARG"
  | Local -> "LCL"
  | Static -> "STATIC"
  | Constant -> ""  (* Constant is handled directly in assembly *)
  | This -> "THIS"
  | That -> "THAT"
  | Pointer -> "R3"  (* Pointer 0 -> THIS, Pointer 1 -> THAT *)
  | Temp -> "R5"

(* Helper function to generate a unique label *)
let label_counter = ref 0
let generate_label prefix =
  let label = Printf.sprintf "%s%d" prefix !label_counter in
  label_counter := !label_counter + 1;
  label

let translate_arithmetic = function
  | Add -> "@SP\nAM=M-1\nD=M\nA=A-1\nM=D+M"
  | Sub -> "@SP\nAM=M-1\nD=M\nA=A-1\nM=M-D"
  | Neg -> "@SP\nA=M-1\nM=-M"
  | Eq ->
    let base_label = generate_label "EQ" in
    let if_label = "if_" ^ base_label in
    let else_label = "else_" ^ base_label in
    Printf.sprintf
      "@SP\nAM=M-1\nD=M\nA=A-1\nD=M-D\n@%s\nD;JEQ\nD=0\n@%s\n0;JMP\n(%s)\nD=-1\n(%s)\n@SP\nA=M-1\nM=D"
      if_label else_label if_label else_label
  | Gt ->
    let base_label = generate_label "GT" in
    let if_label = "if_" ^ base_label in
    let else_label = "else_" ^ base_label in
    Printf.sprintf
      "@SP\nAM=M-1\nD=M\nA=A-1\nD=M-D\n@%s\nD;JGT\nD=0\n@%s\n0;JMP\n(%s)\nD=-1\n(%s)\n@SP\nA=M-1\nM=D"
      if_label else_label if_label else_label
  | Lt ->
    let base_label = generate_label "LT" in
    let if_label = "if_" ^ base_label in
    let else_label = "else_" ^ base_label in
    Printf.sprintf
      "@SP\nAM=M-1\nD=M\nA=A-1\nD=M-D\n@%s\nD;JLT\nD=0\n@%s\n0;JMP\n(%s)\nD=-1\n(%s)\n@SP\nA=M-1\nM=D"
      if_label else_label if_label else_label
  | And -> "@SP\nAM=M-1\nD=M\nA=A-1\nM=D&M"
  | Or -> "@SP\nAM=M-1\nD=M\nA=A-1\nM=D|M"
  | Not -> "@SP\nA=M-1\nM=!M"

let translate_memory = function
  | Push (Constant, value) -> 
      (* Push constant directly to stack *)
      Printf.sprintf "@%d\nD=A\n@SP\nA=M\nM=D\n@SP\nM=M+1" value

  | Push (segment, index) -> 
      let seg = segment_to_asm segment in
      if seg = "THIS" || seg = "THAT" || seg = "LCL" || seg = "ARG" then
        (* Store segment value in @13 before accessing the segment *)
        Printf.sprintf "@%s\nD=M\n@13\nM=D\n@%d\nD=A\n@13\nM=D+M\nA=M\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1" seg index
      else if seg = "STATIC" then
        Printf.sprintf "@%s.%d\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1" "filename" index
      else if seg = "R3" then
        if index = 0 then
          (* Handle Pointer 0 -> THIS *)
          Printf.sprintf "@THIS\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1"
        else if index = 1 then
          (* Handle Pointer 1 -> THAT *)
          Printf.sprintf "@THAT\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1"
        else
          (* In case of an unexpected index *)
          failwith "Invalid index for Pointer segment"
      else if seg = "R5" then
        (* Temp segment mapped to R5 *)
        Printf.sprintf "@5\nD=A\n@13\nM=D\n@%d\nD=A\n@13\nM=D+M\nA=M\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1" index
      else
        failwith "Unknown segment"

  | Pop (segment, index) -> 
      let seg = segment_to_asm segment in
      if seg = "THIS" || seg = "THAT" || seg = "LCL" || seg = "ARG" then
        (* Store segment value in @13 before storing the value at the segment's address *)
        Printf.sprintf "@%s\nD=M\n@13\nM=D\n@%d\nD=A\n@13\nM=D+M\n@SP\nM=M-1\nA=M\nD=M\n@13\nA=M\nM=D" seg index
      else if seg = "STATIC" then
        Printf.sprintf "@%s.%d\nD=A\n@SP\nAM=M-1\nD=M\n@%s.%d\nM=D" "filename" index "filename" index
      else if seg = "R3" then
        if index = 0 then
          (* Handle Pointer 0 -> THIS *)
          Printf.sprintf "@SP\nM=M-1\nA=M\nD=M\n@THIS\nM=D"
        else if index = 1 then
          (* Handle Pointer 1 -> THAT *)
          Printf.sprintf "@SP\nM=M-1\nA=M\nD=M\n@THAT\nM=D"
        else
          (* In case of an unexpected index *)
          failwith "Invalid index for Pointer segment"
      else if seg = "R5" then
        (* Temp segment mapped to R5 *)
        Printf.sprintf "@5\nD=A\n@13\nM=D\n@%d\nD=A\n@13\nM=D+M\n@SP\nM=M-1\nA=M\nD=M\n@13\nA=M\nM=D" index
      else if seg = "R13" then
        (* Special handling for index 13 *)
        Printf.sprintf "@%d\nD=A\n@13\nD=D+M\n@SP\nAM=M-1\nD=M\n@13\nA=M\nM=D" index
      else
        failwith "Unknown segment"
        
let translate_function = function
  | Func (func_name, num_locals) ->
      let base_label = Printf.sprintf "(%s)" func_name in
      let initialize_locals = String.concat "\n" (List.init num_locals (fun _ ->
        "@SP\nA=M\nM=0\n@SP\nM=M+1")) in
      Printf.sprintf "%s\n%s" base_label initialize_locals

  | Call (func_name, num_args) ->
      let return_label = Printf.sprintf "RETURN_%s_%d" func_name num_args in
      Printf.sprintf
        "@%s\nD=A\n@SP\nA=M\nM=D\n@SP\nM=M+1\n" return_label ^       (* Push return address *)
        "@LCL\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n" ^                    (* Push LCL *)
        "@ARG\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n" ^                    (* Push ARG *)
        "@THIS\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n" ^                   (* Push THIS *)
        "@THAT\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n" ^                   (* Push THAT *)
        "@SP\nD=M\n@0\nD=D-A\n@5\nD=D-A\n@ARG\nM=D\n" ^               (* ARG = SP - 5 - num_args *)
        "@SP\nD=M\n@LCL\nM=D\n" ^                                      (* LCL = SP *)
        Printf.sprintf "@%s\n0;JMP\n" func_name ^                     (* Jump to function *)
        Printf.sprintf "(%s)" return_label                             (* Define return label *)



  | Return ->
      "@LCL\nD=M\n@13\nM=D\n" ^ (* FRAME = LCL *)
      "@5\nA=D-A\nD=M\n@14\nM=D\n" ^ (* RET = *(FRAME-5) *)
      "@SP\nAM=M-1\nD=M\n@ARG\nA=M\nM=D\n" ^ (* *ARG = pop() *)
      "@ARG\nD=M+1\n@SP\nM=D\n" ^ (* SP = ARG+1 *)
      "@13\nAM=M-1\nD=M\n@THAT\nM=D\n" ^
      "@13\nAM=M-1\nD=M\n@THIS\nM=D\n" ^
      "@13\nAM=M-1\nD=M\n@ARG\nM=D\n" ^
      "@13\nAM=M-1\nD=M\n@LCL\nM=D\n" ^
      "@14\nA=M\n0;JMP" (* goto RET *)

let translate_prog = function
  | Label label_name ->
      Printf.sprintf "(%s)" label_name  (* Generate label (LOOP) *)

  | Goto label_name ->
      Printf.sprintf "@%s\n0;JMP" label_name  (* Generate goto command for (LOOP) *)

  | IfGoto label_name ->
      Printf.sprintf "@SP\nAM=M-1\nD=M\n@%s\nD;JNE" label_name  (* Generate if-goto command *)


(* Use translate_function in translate_instruction *)
let translate_instruction = function
  | Arithmetic op -> translate_arithmetic op
  | Memory mem -> translate_memory mem
  | Function func -> translate_function func
  | Program prog -> translate_prog prog  (* Delegate to translate_prog *)



(* Final instruction to jump to END *)
let translate_end = "@END\n0;JMP"

(* Add the END jump at the very end of the program *)
let translate_program instructions =
  let translated_instructions = List.map translate_instruction instructions in
  String.concat "\n" (translated_instructions @ [translate_end])
