(*
    OWME USAGE EXAMPLE

    This file sets up a window that draws a spiral.

    When the render window is clicked, the spiral changes colors.

    When a key is pressed, its ASCII representation is printed to the console

    The menu bar has four dropdowns: File, Edit, View, and Help.
    Clicking on them opens their dropdowns. Their dropdown items 
    execute arbitrary unit -> unit functions when clicked.
*)

open Owme
open Graphics

let dropdowns =
  [
    {
      dropdown_title = "File";
      elements =
        [
          Button
            {
              button_name = "Subfile1";
              onclick = (fun _ -> print_endline "Subfile1");
            };
          Button
            {
              button_name = "Subfile2";
              onclick = (fun _ -> print_endline "Subfile2");
            };
        ];
    };
    {
      dropdown_title = "Edit";
      elements =
        [
          Button
            {
              button_name = "Subedit1";
              onclick = (fun _ -> print_endline "Subedit1");
            };
          Button
            {
              button_name = "Subedit2";
              onclick = (fun _ -> print_endline "Subedit2");
            };
        ];
    };
    {
      dropdown_title = "View";
      elements =
        [
          Button
            {
              button_name = "Subview1";
              onclick = (fun _ -> print_endline "Subview1");
            };
          Button
            {
              button_name = "Subview2";
              onclick = (fun _ -> print_endline "Subview2");
            };
        ];
    };
    {
      dropdown_title = "Help";
      elements =
        [
          Button
            {
              button_name = "Subhelp1";
              onclick = (fun _ -> print_endline "Subhelp1");
            };
          Button
            {
              button_name = "Subhelp2";
              onclick = (fun _ -> print_endline "Subhelp2");
            };
        ];
    };
  ]

let spiral_color = ref 0xFF0000

let render_loop max_x max_y =
  set_line_width 3;
  set_color !spiral_color;
  let rec draw x y length angle =
    if length < max_y / 3 then (
      let new_x = int_of_float (float x +. (float length *. cos angle)) in
      let new_y = int_of_float (float y +. (float length *. sin angle)) in
      moveto x y;
      lineto new_x new_y;
      draw new_x new_y (length + 2) (angle -. 1.0))
  in
  draw (max_x / 2) (max_y / 2) 0 100.0

let onclick () =
  spiral_color :=
    match !spiral_color with
    | 0xFF0000 -> 0x00FF00
    | 0x00FF00 -> 0x0000FF
    | 0x0000FF -> 0xFF0000
    | _ -> 0xFF0000

let onkey c =
  if int_of_char c = key_ESCAPE then raise Exit
  else (
    print_char c;
    print_endline "")

let _ =
  owme_render_window
    {
      (* Title of generated window *)
      window_title = "OWME Hello World";
      (* Width of render window *)
      window_width = 1280;
      (* Height of render window (does not include menu bar height - real window resolution will be 720 + menu_bar_height)*)
      window_height = 720;
      (* If false, window will snap back to original (w, h) if resized *)
      resizable = false;
      (* Override the default argument to set_font called for menu items *)
      x11_font_string = None;
      (* The function to render the window contents. 
         This can render in real-time, but a framebuffer approach with an image ref might have less flicker *)
      render_loop;
      (* Function called when mouse clicked *)
      on_click = onclick;
      (* Function called when key pressed *)
      on_key = onkey;
      (* Default render window background color *)
      background = Solid 0xFF00DC;
      (* Whether to clear the screen after each rendered frame (will likely cause flicker) *)
      clear_each_frame = true;
      (* Adjust menu bar text spacing *)
      text_spacing = Some {between_dropdowns_px = -1};
      (* If true, clicks outside of the window boundaries will trigger on_click *)
      trigger_outside_clicks = false;
      (* OWM uses Core_unix to cap the framerate to save resources *)
      framerate_cap = 60;
      (* Menu bar configuration *)
      menu_bar =
        {
          (* Use the default background, selected background, and text colors *)
          bg_color = None;
          selected_bg_color = None;
          text_color = None;
          (* Dropdown configuration *)
          dropdowns;
        };
    }
