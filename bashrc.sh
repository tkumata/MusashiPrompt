# bash 限定
# HISTCONTROL に ignore* 入れない
# PIPESTATUS 位置重点
function codeCondition () {
    local code=$1
    
    if [ ${code} -eq 141 ]; then
        echo -n "パイプの後に head を使用していたら無視して構いません。"
    elif [ ${code} -eq 127 ]; then
        echo -n "コマンドのスペルを確認してください。"
    elif [ ${code} -gt 0 -a ${code} -lt 256 ]; then
        echo -n "引数もしくはコマンドを確認してください。"
    elif [ ${code} -eq 0 ]; then
        echo -n "正常値です。"
    else
        echo -n "不明な終了ステータスコードです。"
    fi
}

function musashi () {
    local status=$(echo ${PIPESTATUS[@]})
    local statusArray=($(echo $status))
    local hist=$(history | tail -10 | awk '{$1=""; print $0}' | awk '{sub(/^[ \t]+/, "")}1')
    echo "${hist}" > /tmp/newhist
    local AM=("武蔵" "浅草" "品川" "村山" "多摩" "青梅" "高尾" "武蔵野" "奥多摩")
    local NO=$(( $RANDOM % ${#AM[@]} ))
    
    if cmp -s /tmp/{newhist,oldhist} || test ! -e /tmp/oldhist
    then
        dummy=""
    else
        cmd=$(echo "${hist}" | tail -1)
        echo -n "〝${AM[$NO]}〟: ${cmd} を実行しました。終了ステータスコードは"
        
        if [ "${#statusArray[@]}" -gt 1 ]; then
            echo "それぞれ"
            i=1
            
            for s in ${status}; do
                if [ "${#statusArray[@]}" -eq "$i" ]; then
                    local echoopt="-ne"
                else
                    local echoopt="-e"
                fi
                
                coderesult=$(codeCondition ${s})
                echo ${echoopt} "$i 番目、${s} です。${coderesult}"
                
                i=$(( $i+1 ))
            done
        else
            coderesult=$(codeCondition ${status})
            echo -n " ${status} です。${coderesult}"
        fi
        
        echo "――以上"
    fi
    
    cp /tmp/{newhist,oldhist}
}
PROMPT_COMMAND='musashi;'${PROMPT_COMMAND//musashi;/}

# fc でやると履歴がずれるからボツ。
#function musashi () {
#    local foo=$_
#    fc -l -10 > /tmp/newhist
#    if cmp -s /tmp/{newhist,oldhist} || test -z "$foo"
#    then
#        a=""
#    else
#        cmd=`fc -l -1 | awk '{$1=""; print $0}' | awk '{sub(/^[ \t]+/, "")}1'`
#        echo "${cmd} を実行しました。 ――以上"
#    fi
#    cp /tmp/{newhist,oldhist}
#}
#PROMPT_COMMAND="musashi; ${PROMPT_COMMAND}"