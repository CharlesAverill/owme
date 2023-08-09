# OWM

A configurable OCaml Window Manager. 

## Quickstart

```ocaml
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
  owm_render_window
    {
      window_title = "OWM Hello World";
      window_width = 1280;
      window_height = 720;
      resizable = false;
      x11_font_string = "";
      menu_bar = { bg_color = _DEFAULT; text_color = _DEFAULT; dropdowns };
    }
```

## Caveats

OWM is built on top of OCaml's [`Graphics`](https://github.com/ocaml/graphics) libary. This provides the pro of being as portable as `Graphics` is. However, it also provides the con of being as rigid as `Graphics` is. 

For example, font rendering is limited to the X11 fonts provided on a user's system. OWM will (by default) choose the first font available for the default OWM font size - this may or may not be an English font depending on a user's machine configuration. The `x11_font_string` field in the `window_config` type can be set to override this behavior (in the example above, it is empty, triggering the default). Even then, the default text spacing is <b>estimated</b>, so manual adjustment with the `text_spacing` struct may be required.

Additionally, rendering the actual window contents is left up to the user, so module-level acceleration is not possible. 

## Goals

I wrote this because I wanted a highly-reusable menuing system for my graphical OCaml projects, so it's not intended to be used for production software (you probably aren't writing production GUI software in OCaml anyways). Eventually I may add mouse events, such as context menus, but at the moment I just want:

- [ ] Menu bar
- [ ] Dropdowns
- [ ] Text boxes
- [ ] Render window passed to user
