open Owm

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

let render_loop () = ()

let _ =
  owm_render_window
    {
      window_title = "OWM Hello World";
      window_width = 1280;
      window_height = 720;
      resizable = false;
      x11_font_string = None;
      render_loop;
      background = Solid 0xFF00DC;
      text_spacing = None;
      menu_bar = { bg_color = None; text_color = None; dropdowns };
    }
