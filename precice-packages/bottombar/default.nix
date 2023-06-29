{ lib
, fetchFromGitHub
, python3
}:

python3.pkgs.buildPythonPackage rec {
  pname = "bottombar";
  version = "1.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "evalf";
    repo = "bottombar";
    rev = "refs/tags/v${version}";
    hash = "sha256-/3m34HcYmmEf92H3938dYV1Q6k44KaCb9TDx9nDNPnM=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    flit-core
  ];

  # The package only has some "interactive" tests where a user must check for
  # the correct output and hit enter after every check
  pythonImportsCheck = [
    "bottombar"
  ];

  meta = with lib; {
    description = "Context manager that prints a status line at the bottom of a terminal window";
    homepage = "https://github.com/evalf/bottombar";
    license = licenses.mit;
    maintainers = with maintainers; [ conni2461 ];
  };
}
