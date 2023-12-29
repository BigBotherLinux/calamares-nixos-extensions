{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs }: {
  packages.x86_64-linux.calamares-nixos-extensions =
      with import nixpkgs { system = "x86_64-linux"; };
      ## Custom calamares build

      stdenv.mkDerivation {
        name = "calamares-nixos-extensions";
        pname = "calamares-nixos-extensions";
        version = "0.3.14";

        src = self;

        installPhase = ''
          runHook preInstall
          mkdir -p $out/{lib,share}/calamares
          ls -la .
          cp -r ./modules $out/lib/calamares/
          cp -r ./config/* $out/share/calamares/
          runHook postInstall
        '';

        meta = with lib; {
          description = "Calamares modules for BigBother";
          homepage = "https://github.com/hauskens/calamares-nixos-extensions";
          license = with licenses; [ gpl3Plus bsd2 cc-by-40 cc-by-sa-40 cc0 ];
          #maintainers = with maintainers; [ vlinkz ];
          platforms = platforms.linux;
        };
      };
      devShells.x86_64-linux.default =
        let
          pkgs = import nixpkgs { system = "x86_64-linux"; };
        in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            (self.packages.x86_64-linux.calamares-nixos-extensions)
            pkgs.calamares
            pkgs.calamares-nixos
          ];
        };
  };
}
