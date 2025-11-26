{
  description = "Godot test";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        name = "vision";
        fancyName = "Vision";
        desc = "A music visualizer written in godot";

        package = pkgs.stdenv.mkDerivation rec {
          pname = name;
          version = "0.0.1";

          src = ./src;

          nativeBuildInputs = with pkgs; [
            autoPatchelfHook
            # copyDesktopItems
            godot
            makeWrapper
            writableTmpDirAsHomeHook
          ];

          buildInputs = with pkgs; [
            libx11
            libxcursor
            libxext
            libxi
            libxinerama
            libxrandr
            libxrender
            libglvnd
            mesa

            alsa-lib
            pulseaudio
          ];

          buildPhase = ''
            runHook preBuild

            mkdir -p $HOME/.local/share/godot
            ln -s ${pkgs.godot-export-templates-bin}/share/godot/export_templates $HOME/.local/share/godot

            # ls -a $HOME/.local/share/godot

            mkdir -p $out/bin
            godot --headless --export-release "Linux" $out/bin/${name}-unpatched

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out/bin

            makeWrapper $out/bin/${name}-unpatched $out/bin/${name} \
              --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath buildInputs}

            runHook postInstall
          '';

          desktopItem = pkgs.makeDesktopItem {
              inherit name;
              exec = name;
              # icon = "a-keys-path";
              desktopName = name;
              # comment = "GodotTest";
              genericName = fancyName;
              categories = [ "Game" ];
            };

          meta = {
            homepage = "https://example.com";
            description = desc;
            mainProgram = name;
            platforms = [
              system
            ];
          };
        };

      in
      {
        packages = {
          default = package;
        };

        apps.default = {
          type = "app";
          program = "${package}/bin/${name}";
        };
      }
    );
}
