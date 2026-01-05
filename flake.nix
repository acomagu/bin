{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nvc = {
    url = "github:acomagu/nvc";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, nvc }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib;

        # 直下のファイルから、スクリプト候補だけ拾う（除外は最小限）
        scripts = lib.filterAttrs (n: t:
          t == "regular" && !(lib.elem n [ "flake.nix" "flake.lock" "mkfile" "README.md" ])
        ) (builtins.readDir self);

        wrappers = lib.mapAttrsToList (name: _:
          pkgs.writeShellApplication {
            inherit name;
            runtimeInputs = [
              pkgs._9base
              pkgs.python3
              pkgs.git
              pkgs.plan9port
              nvc.packages.${system}.default
            ];
            text = ''exec ${self}/${name} "$@"'';
          }
        ) scripts;
      in
      {
        packages.default = pkgs.symlinkJoin { name = "mybin"; paths = wrappers; };
      });
}

