# Excelsior UI Framework
# © 2025 Alexios Ivannicoff. All rights reserved.
# Esse quam videri — To be rather than to seem.
#
# This source code is distributed under the terms of the MIT License,
# full text if not included: https://opensource.org/licenses/MIT
#
# XAML ResourceDictionary Combiner
# Combines shared styles, brushes, and color schemes into unified theme dictionaries.
# ExcelsiorUI.xaml includes full style definitions.
# Excelsior{Theme}.xaml merges Colors\Theme.xaml with Shared\Brushes.xaml.
# Styles are not included in theme variants — only shared brushes and theme-specific resources.

# Paths
$projectDir     = Get-Location
$stylesDir      = Join-Path $projectDir "Resources\Styles\"
$colorsDir      = Join-Path $projectDir "Resources\Colors\"
$genericFile    = Join-Path $projectDir "Resources\Shared\Generic.xaml"
$brushesFile    = Join-Path $projectDir "Resources\Shared\Brushes.xaml"
$outputDir      = Join-Path $projectDir "Themes"

# XML writer settings
$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent             = $true
$settings.IndentChars        = "`t"
$settings.NewLineChars       = "`r`n"
$settings.OmitXmlDeclaration = $true
$settings.Encoding           = [System.Text.Encoding]::UTF8

# Generate ExcelsiorUI.xaml (Generic.xaml + all style files, root first then subfolders)
[xml]$stylesDictionary = Get-Content $genericFile -Encoding UTF8

# Get styles: first from root, then from subfolders, both sorted by name
$styleFiles = Get-ChildItem $stylesDir -File -Filter "*.xaml" -Recurse |
    Sort-Object @{ e = { $_.DirectoryName -ne $stylesDir } }, DirectoryName, Name

# Append all style ResourceDictionaries to the base dictionary
foreach ($f in $styleFiles) {
    [xml]$x = Get-Content $f.FullName -Encoding UTF8
    $stylesDictionary.ResourceDictionary.InnerXml += $x.ResourceDictionary.InnerXml
}

# Save the combined styles dictionary to ExcelsiorUI.xaml
$outFile = Join-Path $outputDir "ExcelsiorUI.xaml"
$writer  = [System.Xml.XmlWriter]::Create($outFile, $settings)
$stylesDictionary.Save($writer)
$writer.Close()

# Load Brushes.xaml once for cloning
[xml]$brushesBase = Get-Content $brushesFile -Encoding UTF8

# Generate theme dictionaries (Colors + Brushes)
Get-ChildItem $colorsDir -Filter "*.xaml" | ForEach-Object {
    # Deep clone to preserve original brushes and comments
    $themeDictionary = $brushesBase.Clone()

    $themeName = [IO.Path]::GetFileNameWithoutExtension($_.Name)
    $outFile   = Join-Path $outputDir "Excelsior$themeName.xaml"

    [xml]$colorsDictionary = Get-Content $_.FullName -Encoding UTF8

    # Place theme colors before shared brushes
    $themeDictionary.ResourceDictionary.InnerXml =
        $colorsDictionary.ResourceDictionary.InnerXml +
        $themeDictionary.ResourceDictionary.InnerXml

    $writer = [System.Xml.XmlWriter]::Create($outFile, $settings)
    $themeDictionary.Save($writer)
    $writer.Close()
}