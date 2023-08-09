# OWME

OWME (OWME is a Window Manager Emulator) is a configurable window manager (emulator) written in OCaml. 

## Usage

See [bin/main.ml](bin/main.ml) for a usage example.

## Caveats

OWME is built on top of OCaml's [`Graphics`](https://github.com/ocaml/graphics) libary. This provides the pro of being as portable as `Graphics` is. However, it also provides the con of being as rigid as `Graphics` is. 

For example, font rendering is limited to the X11 fonts provided on a user's system. OWME will (by default) choose the first font available for the default OWME font size - this may or may not be an English font depending on a user's machine configuration. The `x11_font_string` field in the `window_config` type can be set to override this behavior (in the example above, it is empty, triggering the default). Even then, the default text spacing is <b>estimated</b>, so manual adjustment with the `text_spacing` struct may be required.

Additionally, rendering the actual window contents is left up to the user, so module-level acceleration is not possible. 

## Goals

I wrote this because I wanted a highly-reusable menuing system for my graphical OCaml projects, so it's not intended to be used for production software (you probably aren't writing production GUI software in OCaml anyways). Eventually I may add mouse events, such as context menus, but at the moment I just want:

- [x] Menu bar
- [x] Dropdowns
- [ ] Text boxes
- [x] Render window passed to user
