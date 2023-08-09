open Graphics

let menu_bar_height = 20
let fontsize = 20

type text_spacing_config = { between_dropdowns_px : int }
type bgmode = Solid of int | Checker of int * int

type dropdown_element =
  | Button of { button_name : string; onclick : unit -> unit }

let text_of_dropdown_item = function Button b -> b.button_name
let onclick_of_dropdown_item = function Button b -> b.onclick

type menu_bar_item = {
  dropdown_title : string;
  elements : dropdown_element list;
}

type menu_bar_config = {
  bg_color : int option;
  selected_bg_color : int option;
  text_color : int option;
  dropdowns : menu_bar_item list;
}

let default_font_string =
  Printf.sprintf "-*-*-*-*-*-*-%d-*-*-*-*-*-*-*" fontsize

let default_mb_bg_color = 0xE5E4E2
let default_mb_bg_selected_color = 0xB5B4B2
let default_mb_text_color = 0x000000

type window_config = {
  window_title : string;
  window_width : int;
  window_height : int;
  resizable : bool;
  x11_font_string : string option;
  text_spacing : text_spacing_config option;
  framerate_cap : int;
  background : bgmode;
  render_loop : int -> int -> unit;
  on_click : unit -> unit;
  menu_bar : menu_bar_config;
}

let last_wh = ref (0, 0)
let mouse_is_down = ref false

let currently_open_dropdown : (menu_bar_item * int * int * int * int) option ref
    =
  ref None

let owme_render_window config =
  (* Set up window *)
  let height_with_menubar = config.window_height + menu_bar_height in
  open_graph (Printf.sprintf " %dx%d" config.window_width height_with_menubar);
  set_window_title config.window_title;
  last_wh := (config.window_width, config.window_height);

  let mb_bg_color =
    match config.menu_bar.bg_color with
    | Some x -> x
    | None -> default_mb_bg_color
  and mb_selected_bg_color =
    match config.menu_bar.selected_bg_color with
    | Some x -> x
    | None -> default_mb_bg_selected_color
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

  let dropdown_x_pos idx =
    let consumedpx =
      fst
        (List.fold_left
           (fun (cpx, i) item ->
             if i >= idx then (cpx, i)
             else
               ( (cpx
                 + string_px_width item.dropdown_title
                 + (2 * char_px_width)
                 + if i <> 0 then text_between_dropdowns_px else 0),
                 i + 1 ))
           (0, 0) config.menu_bar.dropdowns)
    in
    consumedpx
  in

  let xy_within_rect x y rx ry rw rh =
    (x >= rx && x <= rx + rw) && y >= ry && y <= ry + rh
  in

  let is_click_within_mb x y =
    xy_within_rect x y 0 (canonical_sizey ()) (size_x ()) menu_bar_height
  in

  let mb_click_to_mbitem x _y =
    List.fold_left
      (fun (result, idx) item ->
        let max_x = dropdown_x_pos idx + string_px_width item.dropdown_title in
        if result = None then
          if x > dropdown_x_pos idx && x < max_x then (Some item, idx)
          else (None, idx + 1)
        else (result, idx))
      (None, 0) config.menu_bar.dropdowns
  in

  let highlight_mbitem idx =
    let item = List.nth config.menu_bar.dropdowns idx in
    let posx, posy = (dropdown_x_pos idx, canonical_sizey () + 1) in
    set_color mb_selected_bg_color;
    fill_rect posx posy (string_px_width item.dropdown_title) menu_bar_height;
    set_color 0x000000;
    moveto posx posy;
    draw_string item.dropdown_title
  in

  let open_dropdown idx =
    highlight_mbitem idx;
    let item = List.nth config.menu_bar.dropdowns idx in
    let num_subitems = List.length item.elements in
    let max_subitem_length =
      List.fold_left
        (fun n item ->
          let n' = String.length (text_of_dropdown_item item) in
          if n' > n then n' else n)
        0 item.elements
    in
    (* Draw the background rectangle *)
    set_color mb_bg_color;
    let cornerx, cornery =
      ( dropdown_x_pos idx,
        canonical_sizey () + 1 - (menu_bar_height * num_subitems) )
    in
    let drdw, drdh =
      (max_subitem_length * char_px_width, (menu_bar_height * num_subitems) - 1)
    in
    fill_rect cornerx cornery drdw drdh;
    (* Draw each option *)
    set_color 0x000000;
    let _ =
      List.fold_left
        (fun idx drdelem ->
          moveto cornerx (cornery + (idx * menu_bar_height));
          draw_string (text_of_dropdown_item drdelem);
          idx + 1)
        0 (List.rev item.elements)
    in
    currently_open_dropdown := Some (item, cornerx, cornery, drdw, drdh)
  in

  let click_mbitem x y =
    let elements, cornerx, cornery, drdw, _drdh =
      match !currently_open_dropdown with
      | Some (item, a, b, c, d) -> (item.elements, a, b, c, d)
      | _ -> ([], 0, 0, 0, 0)
    in
    let click_func =
      List.fold_left
        (fun (found, idx, res) listitem ->
          if found then (found, idx, res)
          else if
            xy_within_rect x y cornerx
              (cornery + (idx * menu_bar_height))
              drdw menu_bar_height
          then (true, idx, onclick_of_dropdown_item listitem)
          else (false, idx + 1, res))
        (false, 0, fun () -> ())
        (List.rev elements)
    in
    match click_func with _, _, f -> f ()
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
        (fun idx dropdown ->
          let newx = dropdown_x_pos idx in
          moveto newx (canonical_sizey ());
          draw_string dropdown.dropdown_title;
          idx + 1)
        0 config.menu_bar.dropdowns
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

  let frame_duration = 1. /. float_of_int config.framerate_cap in

  let _ =
    set_color (rgb 0 0 0);
    remember_mode false;
    let last_time = ref (Core_unix.gettimeofday ()) in
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

        (* Calculate the time elapsed since the last frame *)
        let current_time = Unix.gettimeofday () in
        let elapsed_time = current_time -. !last_time in
        last_time := current_time;

        (* Calculate the time to sleep to achieve the desired frame rate *)
        let sleep_time = frame_duration -. elapsed_time in
        if sleep_time > 0. then Core_thread.delay sleep_time;

        if st.keypressed then raise Exit;
        if st.button then (
          if not !mouse_is_down then (
            redraw_window ();
            mouse_is_down := true;
            (* Click on menu bar item *)
            if is_click_within_mb st.mouse_x st.mouse_y then
              let menu_item_clicked, idx =
                mb_click_to_mbitem st.mouse_x st.mouse_y
              in
              match menu_item_clicked with
              | None -> ()
              | Some _ -> open_dropdown idx
            else
              let do_click_mbitem =
                match !currently_open_dropdown with
                | Some (_, drdx, drdy, drdw, drdh) ->
                    if xy_within_rect st.mouse_x st.mouse_y drdx drdy drdw drdh
                    then true
                    else false
                | _ -> false
              in
              if do_click_mbitem then click_mbitem st.mouse_x st.mouse_y
              else (* Click in render window *) config.on_click ()))
        else mouse_is_down := false;
        config.render_loop (size_x ()) (canonical_sizey ())
      done
    with Exit -> ()
  in
  ()
