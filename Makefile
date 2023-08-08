.PHONY: default build install uninstall test clean fmt
.IGNORE: fmt

default: build

fmt:
	opam exec -- dune build @fmt
	opam exec -- dune promote

build: fmt
	opam exec -- dune build

install:
	opam exec -- dune install

uninstall:
	opam exec -- dune uninstall

clean:
	opam exec -- dune clean
	git clean -dfXq

test: fmt
	opam exec -- dune runtest

testf: fmt
	opam exec -- dune runtest -f

run: build
	opam exec -- dune exec -- owm

raw_run: build
	clear
	_build/default/bin/main.exe 

debug: build
	opam exec -- ocamldebug _build/default/owm/main.bc

push: cleandocs build
	@read -p "Commit message: " input; \
	if [ -z "$input" ]; then \
		echo "Error: Please provide a valid commit message."; \
		exit 1; \
	fi; \
	git add . && git commit -m "$$input" && git push origin main
