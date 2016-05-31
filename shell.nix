{ pkgs ? import <nixpkgs> {} }:

with pkgs;
let funs = pkgs.callPackage ./nix/rust-nightly.nix { };
    cargoNightly = funs.cargo {
      date = "2016-05-21";
      hash = "00b32hm8444dlxwl5v3v1mf4sw262n7yw04smsllr41kz2b8lq43";
    };

    rustNightly = funs.rust {
      date = "2016-05-21";
      hash = "0ylyq746hvqc8ibhi16vk7i12cnk0zlh46gr7s9g59dpx0j0f1nl";
    };

    cudnn = stdenv.mkDerivation rec {
      version = "4.0";

      name = "cudnn-${version}";

      src = requireFile rec {
        name = "cudnn-7.0-linux-x64-v${version}-prod.tgz";
        message = ''
          This nix expression requires that ${name} is
          already part of the store. Register yourself to NVIDIA Accelerated Computing Developer Program
          and download cuDNN library at https://developer.nvidia.com/cudnn, and store it to the nix store with nix-store --add-fixed sha256 <FILE>.
        '';
        sha256 = "0zgr6qdbc29qw6sikhrh6diwwz7150rqc8a49f2qf37j2rvyyr2f";
      };

      phases = "unpackPhase installPhase fixupPhase";

      installPhase = ''
        mkdir -p $out
        cp -a include $out/include
        cp -a lib64 $out/lib64
      '';
    };

in stdenv.mkDerivation {
  name = "leaf-build-env";

  SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
  CUDA_PATH = "${pkgs.cudatoolkit}";

  buildInputs = [
    cudnn
    blas
    cudatoolkit
    linuxPackages.nvidia_x11
    rustNightly
    cargoNightly
    stdenv.cc.cc.lib
  ];

  libPath = lib.makeLibraryPath ([
      stdenv.cc.cc  # For libstdc++.
  ]);
}
