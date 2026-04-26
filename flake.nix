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
          webkit2gtk
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

          sourceRoot = "source/src-tauri";

          cargoLock = {
            lockFile = ./src-tauri/Cargo.lock;
            # If the Cargo.lock needs its hash updated, run the build and replace this hash or remove if not needed.
            allowBuiltinFetchGit = true;
          };

          nativeBuildInputs = with pkgs; [
            pkg-config
            nodejs_22
            pnpm
            cargo-tauri
            wrapGAppsHook
          ];

          buildInputs = libraries;

          # For a complete Nix build of a Tauri app with a frontend:
          # In a strict Nix sandbox, pnpm install requires fetchPnpmDeps. 
          # We're using a simplified approach where you build the frontend manually first, or use a more advanced builder.
          # Here we assume the frontend is either built or the environment allows network access for this basic flake package.
          
          preBuild = ''
            cd ..
            # You would normally use fetchPnpmDeps in Nix, but for simplicity here 
            # we just do a pnpm install if network is available, or assume pre-built.
            pnpm install --no-frozen-lockfile || true
            pnpm build || true
            cd src-tauri
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