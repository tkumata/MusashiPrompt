# bash 限定
# HISTCONTROL に ignore* 入れない
function codeCondition () {
    local code=$1
    
    if [ ${code} -eq 141 ]; then
        echo -n "パイプの後に head を使用していたら無視して構いません。"
    elif [ ${code} -eq 130 ]; then
        echo -n "Ctrl+C で終了しました。"
    elif [ ${code} -gt 128 ]; then
        local n=$(( ${code} - 128 ))
        echo -n "Fatal error signal ${n} です。"
    elif [ ${code} -eq 128 ]; then
        echo -n "実行コマンド内部の EXIT 引数が無効な数字です。"
    elif [ ${code} -eq 127 ]; then
        echo -n "コマンドのスペルか存在を確認してください。"
    elif [ ${code} -eq 126 ]; then
        echo -n "実行できませんでした。権限を確認してください。"
    elif [ ${code} -gt 0 -a ${code} -lt 256 ]; then
        echo -n "コマンドの引数を確認してください。"
    elif [ ${code} -eq 0 ]; then
        echo -n "正常値です。"
    else
        echo -n "不明な終了ステータスコードです。"
    fi
}

# PIPESTATUS 位置重点
function musashi () {
    local status=$(echo ${PIPESTATUS[@]})
    local statusArray=($(echo $status))
    local hist=$(history | tail -10 | awk '{$1=""; print $0}' | awk '{sub(/^[ \t]+/, "")}1')
    
    local AM=("武蔵" "浅草" "品川" "村山" "多摩" "青梅" "高尾" "武蔵野" "奥多摩" "鹿角")
    local NO=$(( $RANDOM % ${#AM[@]} ))
    
    local prefix1=$(echo -n ${USER} | openssl dgst -md5)
    local prefix2=$(tty | openssl dgst -md5)
    local new="musashi-${prefix1}${prefix2}-n"
    local old="musashi-${prefix1}${prefix2}-o"
    echo "${hist}" > /tmp/${new}; chmod 0600 /tmp/${new}
    
    # Check command history
    if cmp -s /tmp/{${new},${old}} || test ! -e /tmp/${old}
    then
        dummy=""
    else
        # Head of transcript
        cmd=$(echo "${hist}" | tail -1)
        echo -n "〝${AM[$NO]}〟: ${cmd} を実行しました。終了ステータスコードは"
        
        # Middle of transcript, case by exit status code
        if [ "${#statusArray[@]}" -gt 1 ]
        then
            echo "それぞれ"
            i=1
            
            for s in ${status}
            do
                if [ "${#statusArray[@]}" -eq "$i" ]
                then
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
        
        # End of transcript
        if [ "${AM[$NO]}" = "鹿角" ]
        then
            echo ""
        else
            echo "――以上"
        fi
    fi
    
    cp /tmp/{${new},${old}}
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