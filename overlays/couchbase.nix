# overlays/couchbase.nix
self: super: {
  couchbase-server-admin-tools = super.stdenv.mkDerivation rec {
    pname = "couchbase-server-admin-tools";
    version = "7.6.4";

    src = super.fetchurl {
      url = "https://packages.couchbase.com/releases/${version}/couchbase-server-admin-tools-${version}-linux_x86_64.tar.gz";
      sha256 = "sha256-cHJY/f/Sihw4EJrENbXuH90EBUkN5+EXT/0CDBnP0+I=";
    };

    nativeBuildInputs = [
      super.patchelf
      super.makeWrapper
    ];

    phases = [ "unpackPhase" "installPhase" ];

    installPhase = ''
      mkdir -p "$out"
      cp -r * "$out"

      for exe in $(find "$out" -type f); do
        if file "$exe" | grep -q ELF; then
          if readelf -l "$exe" | grep -q 'Requesting program interpreter:'; then
            patchelf \
              --set-interpreter "$(cat ${super.stdenv.cc}/nix-support/dynamic-linker)" \
              --set-rpath "$out/lib" \
              "$exe"
          else
            echo "Skipping ELF without interpreter: $exe"
          fi
        fi
      done
    '';
  };
}
