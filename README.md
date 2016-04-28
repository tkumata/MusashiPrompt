# コマンドを実行するたびに艦長s と鹿角さんが返事してくれている風な bash コード


## 概要
!["Screen Shot"](./ScreenShot.png)


## 使い方
1. Save this code to a file.
2. Edit your .bashrc or .bash_profile. (see below.)
3. Quit editor.
4. Exec "source .bashrc" or "source .bash_profile".


例: .bashrc
```
. $HOME/bin/MusashiPrompt/bashrc.sh
```


## 要件
- UNIX / Unix like
- bash 3.2+


## 変更
- Linux に対応しました。
- Mac say と AquesTalkPi に対応。(コメントアウトを外せば使えます)


## 希望
- もっと辛辣な感じにしたい。
- 鹿角さんロジックを組み込みたい。
- AI ライブラリでどうにかできないの？


## ライセンス
Copyright (c) 2016 tkumata

This software is release under the MIT License, please see [MIT](http://opensource.org/licenses/mit-license.php)


## 著者
[tkumata](https://github.com/tkumata)


## 謝辞
[実行したコマンドの終了コードを表示する](http://qiita.com/takayuki206/items/f4d0dbb45e5ee2ee698e)
