{ exitOnLowCoverage ? true }:
let
  project = import ./project.nix;
  src = project.prjSrc;
  repoDir = builtins.toString ./..;
  deps = import ./test-deps.nix {inherit repoDir;};
  nixPkgs = project.nixPkgs;
  projectWithCov = project.project {
    src = repoDir;
    extraModules = [{
      packages.btc-lsp.components.library.doCoverage = true;
    }];
  };
  exeVer = projectWithCov.btc-lsp.components.exes.btc-lsp-exe.version;
  coverageReport = projectWithCov.btc-lsp.coverageReport;
  exitOnLowCoverageSh = if exitOnLowCoverage then "exit 1" else "";
in
  nixPkgs.runCommand "coverage-test" {} ''
      set -euo pipefail

      mkdir $out
      cp -R ${coverageReport}/* $out

      EXPECTED_COV=${project.expectedTestCoveragePercent}
      PROVIDED_COV=$(${nixPkgs.haskell.compiler.ghc902}/bin/hpc report \
        --hpcdir=${coverageReport}/share/hpc/vanilla/mix/coins-${exeVer} \
        ${coverageReport}/share/hpc/vanilla/tix/coins-${exeVer}/coins-${exeVer}.tix \
        | grep "expressions used" | grep -oP '\d+(?=%)')

      echo "coverage-test ==> $PROVIDED_COV% is the provided test coverage."
      echo "coverage-test ==> $EXPECTED_COV% is the minimal test coverage."
      if [[ $PROVIDED_COV -lt $EXPECTED_COV ]]
      then
        echo "coverage-test ==> Test coverage is too low! Failing!"
        ${exitOnLowCoverageSh}
      else
        echo "coverage-test ==> Test coverage is sufficient! Success!"
      fi
    ''
