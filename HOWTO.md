# HOWTO

## Bump version of package

1. First open the specific package `default.nix` file
2. Packages always contains a `src =` section which defines where the sources are being pulled from.
E.g. A package can be fetched from `GitHub` by specifying a `owner`, `repo`, the `rev` and the `hash`.
`rev` can be a tag or a commit, and usually uses the version defined in the package.
3. To update to a new version, set the new version in `version =` and after that comment out `hash` in the src section.
We need to comment out the `hash`, so nix recognizes the change and refetches the source.
It will then tell us the new hash of the source directory, after running `nix build .#packagename` and we can use the new hash as replacement of the old.
4. Last but not least we can attempt to rebuild the package with `nix build .#packagename` which will then pull the src again and validate the hash, if everything works it will now build the new version of the package.
Note, that there might be more to the version bump, like a change in dependencies.

### Example dealii

1. Open `precice-packages/dealii/default.nix`
2. Change the version from `9.4.1` -> `9.5.1`
3. Delete the line inside the `src` block starting with `hash`
4. Run `nix build '.#dealii'`
5. Set the new hash value, resulting in `hash = "sha256-ifZjBOyHHezbpbaFtqTQ3xUzwwji7qKGtjq9QutWRhA="`
6. Run `nix build '.#dealii'` again
7. In this case the build works, but it seems like the tests fail, you can inspect the logs with `nix log ...`, `nix build` will tell you the complete command.
8. The log output indicates that `perl` is missing for the tests, so you can add a new test dependency.
There are a lot of different input types that nix has which are present at different parts of the stage, see [reference](https://nixos.org/manual/nixpkgs/stable/#ssec-stdenv-dependencies-reference).
Here, we are looking for `nativeCheckInputs`, which are inputs that are present at the check/test phase.
We already have an input in the `nativeCheckInputs` so we need to extend the current inputs with `perl` resulting in `nativeCheckInputs = [ openssh perl ];`, but we also need to define it as an input into the package.
We can do that at the top of the file with the following diff
```diff
diff --git a/precice-packages/dealii/default.nix b/precice-packages/dealii/default.nix
index 1e8c6e3..a6c0a49 100644
--- a/precice-packages/dealii/default.nix
+++ b/precice-packages/dealii/default.nix
@@ -20,6 +20,7 @@
 , petsc
 , zlib
 , openssh
+, perl
 }:

 stdenv.mkDerivation rec {
```
This basically adds perl as a new input.
9. We can now run `nix build '.#dealli` again and see if the tests now succeed.
As an alternative, you could have also disabled the check/test phase by changing `doCheck = true;` to `doCheck = false;`
