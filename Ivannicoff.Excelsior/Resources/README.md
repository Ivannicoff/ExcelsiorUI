# Resources (Source Files for Themes)

Subfolders in this directory hold the XAML source files that **XAMLCombiner.ps1** merges into the final ResourceDictionary files in `Themes`.

These files are only for development and are excluded from the compilation process.

Important:

- All `.xaml` files here are `ResourceDictionary` definitions.
- These files are not compiled directly into the assembly.
- They serve as input for **XAMLCombiner.ps1**.
- Without the two core files in `Resources/Shared`—`Generic.xaml` and `Brushes.xaml`—the script will fail and nothing will be generated.
- To modify styles and resources, edit:
  - `Resources/Shared` (contains `Generic.xaml` and `Brushes.xaml`)
  - `Resources/Styles`
  - `Resources/Colors`

After editing, run a build to regenerate the theme files in `Themes`.