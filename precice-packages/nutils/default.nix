{ lib
, stdenv
, pythonOlder
, python3Packages
, buildPythonPackage
, pytestCheckHook
, fetchFromGitHub
, bottombar
}:

buildPythonPackage rec {
  pname = "nutils";
  version = "7.3";
  format = "pyproject";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "evalf";
    repo = "nutils";
    rev = "refs/tags/v${version}";
    hash = "sha256-3VtQFnR8vihxoIyRkbE1a1Rs8Np3/79PWNKReTBZDg8=";
  };

  propagatedBuildInputs = [
    python3Packages.numpy
    python3Packages.treelog
    python3Packages.stringly
    python3Packages.flit-core
    bottombar
  ];

  nativeCheckInputs = [
    pytestCheckHook
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
