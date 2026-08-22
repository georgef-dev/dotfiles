# Terraform toolchain plus two odds and ends. Opt-in: a host that does no
# infrastructure work should not import this.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    terraform # unfree (BUSL) — flake sets allowUnfree
    terraform-docs
    terraform-ls
    tflint
    tfsec
    cloudflared
    istioctl
  ];
}
