{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sf-mono-liga-src = {
      url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      sf-mono-liga-src,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      sources = import ./sources.nix;
    in
    {
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShellNoCC { };
      });

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          mkAppleFont =
            name: pkg: src:
            pkgs.stdenv.mkDerivation {
              inherit name src;
              version = "0.1.0";
              buildInputs = [
                pkgs.undmg
                pkgs.p7zip
              ];
              unpackPhase = "undmg $src && 7z x '${pkg}' && 7z x 'Payload~'";
              setSourceRoot = "sourceRoot=`pwd`";
              installPhase = ''
                mkdir -p $out/share/fonts/{opentype,truetype}
                find -name \*.otf -exec mv {} $out/share/fonts/opentype/ \;
                find -name \*.ttf -exec mv {} $out/share/fonts/truetype/ \;
              '';
            };

          mkSimpleFont =
            name: src:
            pkgs.stdenvNoCC.mkDerivation {
              pname = name;
              version = "0.1.0";
              inherit src;
              dontConfigure = true;
              installPhase = ''
                mkdir -p $out/share/fonts/opentype
                cp -R $src/*.otf $out/share/fonts/opentype/
              '';
            };
        in
        {
          sf-mono-liga = mkSimpleFont "sf-mono-liga" sf-mono-liga-src;
          ny = mkAppleFont "ny" "NY Fonts.pkg" (pkgs.fetchurl sources.ny);
          sf-pro = mkAppleFont "sf-pro" "SF Pro Fonts.pkg" (pkgs.fetchurl sources.sf-pro);
          sf-mono = mkAppleFont "sf-mono" "SF Mono Fonts.pkg" (pkgs.fetchurl sources.sf-mono);
        }
      );
    };
}
