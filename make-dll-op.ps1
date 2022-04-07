$Name = Split-Path -Path $pwd -Leaf

7z a -tzip "../$Name.op" info.toml src Oswald-Regular.ttf lib

Write-Host("Done!")
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")