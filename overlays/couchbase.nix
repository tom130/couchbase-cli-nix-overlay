# overlays/couchbase.nix
self: super: {
  couchbase-server-admin-tools = super.stdenv.mkDerivation rec {
    pname = "couchbase-server-admin-tools";
    version = "7.6.4";

    sys = super.stdenv.hostPlatform.system;

    url =
      if sys == "x86_64-linux" then "https://packages.couchbase.com/releases/7.6.4/couchbase-server-admin-tools-7.6.4-linux_x86_64.tar.gz"
      else if sys == "aarch64-linux" then "https://packages.couchbase.com/releases/7.6.4/couchbase-server-admin-tools-7.6.4-linux_aarch64.tar.gz"
      else if sys == "x86_64-darwin" then "https://packages.couchbase.com/releases/7.6.4/couchbase-server-admin-tools-7.6.4-macos_x86_64.zip"
      else if sys == "aarch64-darwin" then "https://packages.couchbase.com/releases/7.6.4/couchbase-server-admin-tools-7.6.4-macos_arm64.zip"
      else if sys == "x86_64-windows" then "https://packages.couchbase.com/releases/7.6.4/couchbase-server-admin-tools-7.6.4-windows_amd64.zip"
      else error ("Unsupported system: " + sys);

    src = super.fetchurl {
      url = url;
      sha256 =
        if sys == "x86_64-linux" then "0a3z8g5dnsdrfcfdrx0qfj2srr7n57kpljkn9f91408mmv30c282"
        else if sys == "aarch64-linux" then "00w9rpmrajsc8q001xm2z8qaa7q2kc782b3m669rcq1534rns0zq"
        else if sys == "x86_64-darwin" then "1jm5gars14w4983iag3pbp4p047vwbr9km7z12fwcl6h81ysi2v1"
        else if sys == "aarch64-darwin" then "0vkm5w4x1a1b0qlaqki6zbazs3lpqf3lxh8i3lga0k7qy9i9jhm5"
        else if sys == "x86_64-windows" then "0wwj38d3lqrj564kvfdxpr855kqv6c0fdccdfizy62a1dss3v3qs"
        else "";
    };
    # On Linux, use patchelf; on Darwin (or Windows) we need unzip.
    nativeBuildInputs = if sys == "x86_64-linux" || sys == "aarch64-linux" then [
      super.patchelf
      super.makeWrapper
    ] else [
      super.makeWrapper
      super.unzip
    ];

    phases = [ "unpackPhase" "installPhase" ];

    installPhase = ''
      mkdir -p "$out"
      # If the URL ends with "zip", assume it's a ZIP archive and unzip it.
      if [ "${url##*.}" = "zip" ]; then
        unzip $src -d $out
      else
        cp -r * "$out"
        # For tarballs on Linux, patch ELF binaries if needed.
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
      fi
    '';

    meta = with super.lib; {
      platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" "x86_64-windows" ];
      description = "Couchbase Server Admin Tools version 7.6.4";
      license = super.licenses.mit;
    };
  };
}
