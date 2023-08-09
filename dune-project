(lang dune 3.9)

(name owme)

(generate_opam_files true)

(source
 (github CharlesAverill/owme))

(authors "Charles Averill")

(maintainers "Charles Averill")

(license LICENSE)

(documentation https://github.com/CharlesAverill/owme)

(package
 (name owme)
 (synopsis "An OCaml Window Manager")
 (description "A Window Manager written in the OCaml Graphics library")
 (depends ocaml dune graphics 
  (core_unix (>= :"0.15.2")) ))

