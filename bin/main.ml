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
  ]

let _ =
  render_window
    {
      window_title = "OWM Hello World";
      window_width = 1280;
      window_height = 720;
      resizable = false;
      x11_font_string = "";
      menu_bar = { bg_color = _DEFAULT; text_color = _DEFAULT; dropdowns };
    }
