# ItemExchange plugin for Trackmania

https://openplanet.nl/files/164

Access items and sets from ItemExchange in game, and import them into the editor without having to restart the game!

[YouTube demo](https://www.youtube.com/watch?v=cBxrbqqXsrQ)

Access items and sets from ItemExchange in game, and import them into the editor without having to restart the game!

## Enable Auto-import
1. Download the dll from https://github.com/RuurdBijlsma/tm-item-exchange/blob/main/lib/libclick.dll
2. Place the .dll file in C:/Users/Name/OpenplanetNext/lib/libclick.dll

Now when the plugin loads it should use the dll to enable automatic importing (no clicks needed)

Check if the dll is loaded in the home tab of the plugin in game, there should be a ✅.

If you don't trust my dll you can compile it yourself: https://github.com/RuurdBijlsma/send-input-lib

## Features
* Search items and sets by name, author, or tag
* Sort items by name, author, date, likes, score, or file size
* View item and set details
* Import items and sets straight into the editor

## Source code & issues
Report issues and find the source code of this plugin [on GitHub](https://github.com/RuurdBijlsma/tm-item-exchange).

## Limitations
* The "block" item type is not supported for import
* Importing is not fully automated, the user is required to click twice
