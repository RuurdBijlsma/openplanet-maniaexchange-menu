$compress = @{
    Path = "./Oswald-Regular.ttf", "./info.toml", "./src"
    CompressionLevel = "Fastest"
    DestinationPath = "../ItemExchange.zip"
}
Compress-Archive @compress -Force

Move-Item -Path "../ItemExchange.zip" -Destination "../ItemExchange.op" -Force

Write-Host("Done!")
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")