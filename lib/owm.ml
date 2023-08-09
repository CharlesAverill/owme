open Graphics

let menu_bar_height = 20
let fontsize = 20

type text_spacing_config = { between_dropdowns_px : int }
type bgmode = Solid of int | Checker of int * int

type dropdown_element =
  | Button of { button_name : string; onclick : unit -> unit }

type menu_bar_item = {
  dropdown_title : string;
  elements : dropdown_element list;
}

type menu_bar_config = {
  bg_color : int option;
  text_color : int option;
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
  x11_font_string : string option;
  text_spacing : text_spacing_config option;
  background : bgmode;
  render_loop : unit -> unit;
  menu_bar : menu_bar_config;
}

let last_wh = ref (0, 0)

let owm_render_window config =
  (* Set up window *)
  let height_with_menubar = config.window_height + menu_bar_height in
  open_graph (Printf.sprintf " %dx%d" config.window_width height_with_menubar);
  set_window_title config.window_title;
  last_wh := (config.window_width, config.window_height);

  let mb_bg_color =
    match config.menu_bar.bg_color with
    | Some x -> x
    | None -> default_mb_bg_color
  and mb_text_color =
    match config.menu_bar.text_color with
    | Some x -> x
    | None -> default_mb_text_color
  and font_string =
    match config.x11_font_string with
    | Some x -> x
    | None -> default_font_string
  and text_between_dropdowns_px =
    match config.text_spacing with
    | None -> 0
    | Some x -> x.between_dropdowns_px
  in

  let canonical_sizey () = size_y () - menu_bar_height in

  (* THESE ASSUMES MONOSPACE *)
  let char_px_width = fontsize / 2 in
  let string_px_width s = String.length s * char_px_width in

  let dropdown_x_pos idx consumedpx =
    consumedpx
    + if idx <> 0 then (2 * char_px_width) + text_between_dropdowns_px else 0
  in

  let is_click_within_mb _x y = y > canonical_sizey () in

  let mb_click_to_mbitem x _y =
    match
      List.fold_left
        (fun (result, idx, consumedpx) item ->
          if result = None then
            if x > consumedpx && x < consumedpx + dropdown_x_pos idx consumedpx
            then (Some item, idx, 0)
            else
              ( None,
                idx + 1,
                dropdown_x_pos idx consumedpx
                + string_px_width item.dropdown_title )
          else (result, idx, 0))
        (None, 0, 0) config.menu_bar.dropdowns
    with
    | r, _, _ -> r
  in
  (* Draw menu bar and default background *)
  let redraw_window () =
    remember_mode true;
    (* Draw menu bar *)
    set_color mb_bg_color;
    fill_rect 0 (canonical_sizey ()) (size_x ()) menu_bar_height;
    (* Draw menu bar items *)
    set_font font_string;
    set_color mb_text_color;
    let _ =
      List.fold_left
        (fun (idx, consumedpx) dropdown ->
          let newx = dropdown_x_pos idx consumedpx in
          moveto newx (canonical_sizey ());
          draw_string dropdown.dropdown_title;
          (idx + 1, newx + string_px_width dropdown.dropdown_title))
        (0, 0) config.menu_bar.dropdowns
    in
    (* Window default bg *)
    let check_size = 17 in
    match config.background with
    | Solid bg ->
        set_color bg;
        fill_rect 0 0 (size_x ()) (canonical_sizey ())
    | Checker (a, b) ->
        for y = 0 to (canonical_sizey () - 1) / check_size do
          for x = 0 to (size_x () - 1) / check_size do
            let floor n = n / 10 in
            let x', y' = (x * check_size, y * check_size) in
            let _ =
              if abs (floor x') mod 2 = abs (floor y') mod 2 then set_color a
              else set_color b
            in
            fill_rect x' y' check_size
              (min check_size (canonical_sizey () - y'))
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
        (if st.button then
           if is_click_within_mb st.mouse_x st.mouse_y then
             let menu_item_clicked = mb_click_to_mbitem st.mouse_x st.mouse_y in
             match menu_item_clicked with
             | None -> ()
             | Some item -> print_endline item.dropdown_title);
        config.render_loop ()
      done
    with Exit -> ()
  in
  ()
