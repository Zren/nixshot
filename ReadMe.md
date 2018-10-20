# NixShot

A tool to capture a screenshot, optionally crop it, then upload it, and finally copy it's url to the clipboard. Based on [ShareX's workflow](https://www.youtube.com/watch?v=7dwKBXgkzd0#t=1m33). Keybindings are bound with [xbindkeys](). Uses [scrot](https://en.wikipedia.org/wiki/Scrot) to actually capture the screen. If the `captureregion` script/key is used, it then sends it to a fullscreen window made with qt/qml with a magnifier. Finally it uploads the screenshot to imgur with a python script, displaying a notification with a thumbnail preview and copies the uploaded images url to the clipboard.

## Screenshots
 
![](https://i.imgur.com/aIoHNL9.png)

## Install

Note this needs `v1.1.9` of `imgurpython` from https://github.com/BryanH/imgurpython, the deprecated `v1.1.7` shipped with `pip3 install imgurpython` is out of date.

```
sudo apt-get install xbindkeys scrot python3 python3-pip qt5-qmake qtdeclarative5-dev
git clone https://github.com/Zren/nixshot
cd nixshot
sh ./install
cat ./.xbindkeysrc >> ~/.xbindkeysrc
killall xbindkeys
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

## `cropscreenshot`

Click + drag to crop. Press `Esc` to quit without uploading the screenshot.
