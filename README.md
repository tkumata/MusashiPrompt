# コマンドを実行するたびに艦長s と鹿角さんが返事してくれている風な bash コード

## Overview
!["スクショ"](./ScreenShot.png)

## How to use
   1. Save this code to a file.
   2. Edit your .bashrc or .bash_profile.
```
Ex. .bashrc)
. $HOME/that_saved_file
```
   3. Quit editor.
   4. Exec "source .bashrc" or "source .bash_profile".

## Requirement
- UNIX / Unix like
- bash 3.2+

## 変更
- Raspberry Pi 3 に対応しました。
- Mac say と AquesTalkPi に対応。(コメントアウトを外せば使えます)

## 希望
- もっと辛辣な感じにしたい。
- 鹿角さんロジックを組み込みたい。
- AI ライブラリでどうにかできないの？

## License
Copyright (c) 2016 tkumata

This software is release under the MIT License, please see [MIT](http://opensource.org/licenses/mit-license.php)

## Author
[tkumata](https://github.com/tkumata)

## Thanks
[実行したコマンドの終了コードを表示する](http://qiita.com/takayuki206/items/f4d0dbb45e5ee2ee698e)
