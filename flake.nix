{
  description = "Nix JavaScript transpiler and interpreter.";

  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";
  inputs.nixjs-rt.url = "github:urbas/nixjs-rt";

  outputs = { self, nixpkgs, nixjs-rt }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forSupportedSystems = f: with nixpkgs.lib; foldl' (resultAttrset: system: recursiveUpdate resultAttrset (f { inherit system; pkgs = import nixpkgs { inherit system; }; })) { } supportedSystems;

    in
    forSupportedSystems ({ pkgs, system, ... }:
      let
        buildInputs = with pkgs; [
          nixjs-rt.packages.${system}.default
          nixpkgs-fmt
          rustup
        ];

      in
      {
        packages.${system} = { inherit nixjs-rt pkgs; };
        devShells.${system}.default = pkgs.stdenv.mkDerivation {
          name = "nixjs";
          inherit buildInputs;
          shellHook = ''
            export NIXJS_RT_MODULE=${nixjs-rt.packages.${system}.default}/lib/node_modules/nixjs-rt/dist/lib.js
            export RUSTFLAGS=-Dwarnings
          '';
        };
      });
}
