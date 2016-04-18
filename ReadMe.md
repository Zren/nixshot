# NixShot

A tool to capture a screenshot, optionally crop it, then upload it, and finally copy it's url to the clipboard. Based on ShareX's workflow. Keybindings are bound with [xbindkeys](). Uses [scrot](https://en.wikipedia.org/wiki/Scrot) to actually capture the screen. If the `captureregion` script/key is used, it then sends it to a fullscreen window made with qt/qml with a magnifier. Finally it uploads the screenshot to imgur with a python script, displaying a notification with a thumbnail preview and copies the uploaded images url to the clipboard.

## Screenshots
 
![](https://i.imgur.com/7FjM9fN.png)

## Install

```
sudo apt-get install xbindkeys scrot python3
git clone https://github.com/Zren/nixshot
mkdir ~/bin
cp ./nixshot/bin/* ~/bin
```

If `~/bin` didn't already exist you might need to restart bash first to reload the path.

```
uploadscreenshot
```

Will give you a url to visit with a pin. You then enter the pin code with:

```
uploadscreenshot -p CODEHERE
```
