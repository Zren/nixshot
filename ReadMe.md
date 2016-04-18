# NixShot

A tool to capture a screenshot, optionally crop it, then upload it, and finally copy it's url to the clipboard. Based on ShareX's workflow. Keybindings are bound with [xbindkeys](). Uses [scrot](https://en.wikipedia.org/wiki/Scrot) to actually capture the screen. If the `captureregion` script/key is used, it then sends it to a fullscreen window made with qt/qml with a magnifier. Finally it uploads the screenshot to imgur with a python script, displaying a notification with a thumbnail preview and copies the uploaded images url to the clipboard.

## Screenshots
 
![](https://i.imgur.com/7FjM9fN.png)

## Install

:caution: **Incomplete**

```
sudo apt-get install xbindkeys scrot python3
pip3 install imgurpython
git clone https://github.com/Zren/nixshot
mkdir ~/bin
mkdir ~/Pictures/Screenshots
cp ./nixshot/bin/* ~/bin
cat ./nixshot/.xbindkeysrc >> ~/.xbindkeysrc
xbindkeys
```

To login to imgur, you'll need to run a script we just installed. If `~/bin` didn't already exist you might need to restart bash first to reload `$PATH`, or use the full path to call it.

```
uploadscreenshot
```

The above will give you a url to visit to obtain a pin. You then enter the pin code with:

```
uploadscreenshot -p CODEHERE
```

It will create a new file `~/.nixshotrc` with your credentials. Another file called `.nixshot.log` will also be created later with the imgur responses.


## Keybindings

You can change these by modifying `~/.xbindkeysrc` then running `xbindkeys` to apply them.

* `PrintScreen` Capture screen
* `Ctrl + PrintScreen` Capture region
