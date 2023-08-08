open Graphics

let menu_bar_height = 20
let fontsize = 20
let _DEFAULT = -1

type dropdown_element =
  | Button of { button_name : string; onclick : unit -> unit }

type menu_bar_item = {
  dropdown_title : string;
  elements : dropdown_element list;
}

type menu_bar_config = {
  bg_color : int;
  text_color : int;
  dropdowns : menu_bar_item list;
}

let default_font_string =
  Printf.sprintf "-*-*-*-*-*-*-%d-*-*-*-*-*-*-*" fontsize

let default_mb_bg_color = 0xE5E4E2
let default_mb_text_color = 0x000000

type window_config = {
  window_title : string;
  window_width : int;
  window_height : int;
  resizable : bool;
  x11_font_string : string;
  menu_bar : menu_bar_config;
}

let last_wh = ref (0, 0)

let render_window config =
  let height_with_menubar = config.window_height + menu_bar_height in
  open_graph (Printf.sprintf " %dx%d" config.window_width height_with_menubar);
  set_window_title config.window_title;
  last_wh := (config.window_width, config.window_height);

  let canonical_sizey () = size_y () - menu_bar_height in

  let redraw_window () =
    remember_mode true;
    (* Draw menu bar *)
    set_color
      (if config.menu_bar.bg_color < 0 then default_mb_bg_color
       else config.menu_bar.bg_color);
    fill_rect 0 (canonical_sizey ()) (size_x ()) menu_bar_height;
    (* Draw menu bar items *)
    set_font
      (if config.x11_font_string = "" then default_font_string
       else config.x11_font_string);
    let _ =
      set_color
        (if config.menu_bar.text_color < 0 then default_mb_text_color
         else config.menu_bar.text_color);
      List.fold_left
        (fun idx dropdown ->
          moveto idx (canonical_sizey ());
          draw_string dropdown.dropdown_title;
          idx + 1)
        0 config.menu_bar.dropdowns
    in
    (* for i = 0 to List.length config.menu_bar.dropdowns do
         draw_string
       done; *)
    (* Window default bg *)
    let check_size = 17 in
    let default x y =
      let floor n = n / 10 in
      (* if (int)abs(floor(x)) % 2 == (int)abs(floor(z)) % 2 *)
      let _ =
        if abs (floor x) mod 2 = abs (floor y) mod 2 then set_color 0xFF00DC
        else set_color 0x000000
      in
      fill_rect x y check_size (min check_size (canonical_sizey () - y))
    in
    for y = 0 to (canonical_sizey () - 1) / check_size do
      for x = 0 to (size_x () - 1) / check_size do
        default (check_size * x) (check_size * y)
      done
    done;
    remember_mode false
  in

  let _ =
    set_color (rgb 0 0 0);
    remember_mode false;
    try
      while true do
        (* Check for window resize *)
        let new_wh = (size_x (), size_y ()) in
        if !last_wh <> new_wh then (
          if config.resizable then (
            last_wh := new_wh;
            Printf.printf "%d %d %d %d" (fst !last_wh) (snd !last_wh)
              (fst new_wh) (snd new_wh))
          else resize_window config.window_width config.window_height;
          redraw_window ());
        let st = wait_next_event [ Poll ] in
        synchronize ();
        if st.keypressed then raise Exit;
        if st.button then (
          remember_mode true;
          (* draw_image caml st.mouse_x st.mouse_y; *)
          remember_mode false);
        let x = st.mouse_x + 16 and y = st.mouse_y + 16 in
        moveto 0 y;
        lineto (x - 25) y;
        moveto 10000 y;
        lineto (x + 25) y;
        moveto x 0;
        lineto x (y - 25);
        moveto x 10000;
        lineto x (y + 25)
        (* draw_image caml st.mouse_x st.mouse_y *)
      done
    with Exit -> ()
  in
  ()
