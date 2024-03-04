{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    # A Python interpreter including the 'venv' module is required to bootstrap
    # the environment.
    (python311Packages.python.withPackages (
      p: with p; [
        numpy
        scipy
        matplotlib
      ]
    ))
    ffmpeg
  ];
}