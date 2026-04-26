{
  description = "Tolaria development environment and package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        libraries = with pkgs; [
          webkitgtk_4_1
          gtk3
          cairo
          gdk-pixbuf
          glib
          dbus
          openssl_3
          librsvg
        ];

        packages = with pkgs; [
          pkg-config
          rustc
          cargo
          rustfmt
          rust-analyzer
          clippy
          nodejs_22
          pnpm
        ];
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "tolaria";
          version = "0.1.0";
          src = ./.;

          buildAndTestSubdir = "src-tauri";

          cargoLock = {
            lockFile = ./src-tauri/Cargo.lock;
            allowBuiltinFetchGit = true;
          };

          doCheck = false;

          postPatch = ''
            ln -s src-tauri/Cargo.lock Cargo.lock
          '';

          nativeBuildInputs = with pkgs; [
            pkg-config
            nodejs_22
            pnpm
            cargo-tauri
            wrapGAppsHook3
          ];

          buildInputs = libraries;
          
          preBuild = ''
            pnpm install --no-frozen-lockfile || true
            pnpm build || true
          '';

          postInstall = ''
            # Tauri produces binaries in target/release, rustPlatform handles this.
            # We also might want to install desktop files and icons.
          '';
        };

        devShell = pkgs.mkShell {
          buildInputs = packages ++ libraries ++ [ pkgs.cargo-tauri ];

          shellHook = ''
            export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath libraries}:$LD_LIBRARY_PATH
            export XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS
          '';
        };
      }
    );
}