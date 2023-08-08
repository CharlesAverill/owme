(lang dune 3.9)

(name owm)

(generate_opam_files true)

(source
 (github CharlesAverill/owm))

(authors "Charles Averill")

(maintainers "Charles Averill")

(license LICENSE)

(documentation https://github.com/CharlesAverill/owm)

(package
 (name owm)
 (synopsis "An OCaml Window Manager")
 (description "A Window Manager written in the OCaml Graphics library")
 (depends ocaml dune graphics))

