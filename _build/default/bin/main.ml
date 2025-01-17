(* main.ml *)

let rec read_lines acc =
  try
    let line = read_line () in
    read_lines (line :: acc)  (* Accumulate input lines *)
  with End_of_file ->
    List.rev acc  (* Return the accumulated lines in reverse order *)

let process_lines lines =
  List.map (fun line ->
    match Jackvm.Parser.parse_instruction line with
    | Some instr -> Jackvm.Translator.translate_instruction instr
    | None -> ""
  ) lines

let () =
  print_endline "Enter VM instructions (press Ctrl+D to finish):";
  let input_lines = read_lines [] in
  let asm_code_lines = process_lines input_lines in
  List.iter print_endline asm_code_lines
