{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [
          # Made available on the CLI
          pkgs.ocaml
          pkgs.dune_3
          pkgs.opam
	  pkgs.ocamlPackages.utop
	  pkgs.ocamlPackages.lsp
	  pkgs.ocamlPackages.merlin
	  pkgs.fish
	  pkgs.emacs29
        ];
      
      };

      # You could also define extra shells or packages here
    };

  	  


}
