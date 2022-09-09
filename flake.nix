{
  description = "Build rustlings with crane";
  nixConfig.bash-prompt-prefix = "[rustlings] ";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, crane, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        rustlings = crane.lib.${system}.buildPackage {
          src = ./.;
          #cargoBuildCommand = "cargo build -Z unstable-options --keep-going --release";
        };
      in
      {
        checks = {
          inherit rustlings;
        };

        packages.default = rustlings;

        apps.default = flake-utils.lib.mkApp {
          drv = rustlings;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = builtins.attrValues self.checks;

          # https://discourse.nixos.org/t/rust-src-not-found-and-other-misadventures-of-developing-rust-on-nixos/11570/5
          # RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

          # Extra inputs can be added here
          nativeBuildInputs = [
            pkgs.cargo
            pkgs.rustc
            pkgs.rust-analyzer
          ];
        };
        devShells.rustlings = pkgs.mkShell {
          # Extra inputs can be added here
          inputsFrom = builtins.attrValues self.checks;
          nativeBuildInputs = [
            rustlings
          ];
        };
      });
}