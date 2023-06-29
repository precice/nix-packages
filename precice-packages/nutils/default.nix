{ lib
, stdenv
, python3
, fetchFromGitHub
, bottombar
}:

python3.pkgs.buildPythonPackage rec {
  pname = "nutils";
  version = "7.3";
  format = "pyproject";

  disabled = python3.pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "evalf";
    repo = "nutils";
    rev = "refs/tags/v${version}";
    hash = "sha256-3VtQFnR8vihxoIyRkbE1a1Rs8Np3/79PWNKReTBZDg8=";
  };

  propagatedBuildInputs = [
    python3.pkgs.numpy
    python3.pkgs.treelog
    python3.pkgs.stringly
    python3.pkgs.flit-core
    bottombar
  ];

  nativeCheckInputs = [
    python3.pkgs.pytestCheckHook
  ];

  pythonImportsCheck = [
    "nutils"
  ];

  disabledTestPaths = [
    # AttributeError: type object 'setup' has no attribute '__code__'
    "tests/test_cli.py"
  ];

  meta = with lib; {
    description = "Numerical Utilities for Finite Element Analysis";
    homepage = "https://www.nutils.org/";
    license = licenses.mit;
    broken = stdenv.hostPlatform.isAarch64;
    maintainers = with maintainers; [ Scriptkiddi ];
  };
}
