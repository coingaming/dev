{ lib, buildGoModule, fetchFromGitHub, installShellFiles, git }:

buildGoModule rec {
  pname = "kompose";
  version = "1.26.1";

  src = fetchFromGitHub {
    owner = "kubernetes";
    repo = "kompose";
    rev = "v${version}";
    sha256 = "1rfdcrnr4msb03dyi8mzj5ys83q0fmrvvp0virkgmh2rdqcfmz1m";
  };

  vendorSha256 = "0xwlp61l1wdlla8n8wkm9z31h7bsxz8d652wz8dfsv6yz7c587ir";

  nativeBuildInputs = [ installShellFiles git ];
  postInstall = ''
    for shell in bash zsh; do
      $out/bin/kompose completion $shell > kompose.$shell
      installShellCompletion kompose.$shell
    done
  '';

  meta = with lib; {
    description = "A tool to help users who are familiar with docker-compose move to Kubernetes";
    homepage = "https://kompose.io";
    license = licenses.asl20;
    maintainers = with maintainers; [ thpham vdemeester ];
    platforms = platforms.unix;
  };
}
