{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ffmpeg
    tesseract
    pandoc
    graphviz
    httrack
  ];
}
