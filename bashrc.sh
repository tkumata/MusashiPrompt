# bash 限定
# HISTCONTROL に ignore 入れない
# PIPESTATUS 位置重点
function musashi () {
    local status=$(echo ${PIPESTATUS[@]})
    local statusArray=(`echo $status`)
    local hist=`history | tail -10 | awk '{$1=""; print $0}' | awk '{sub(/^[ \t]+/, "")}1'`
    echo "${hist}" > /tmp/newhist
    local AM=("武蔵" "浅草" "品川" "村山" "多摩" "青梅" "高尾" "武蔵野" "奥多摩")
    local NO=$(( $RANDOM % ${#AM[@]} ))
    
    if cmp -s /tmp/{newhist,oldhist}
    then
        dummy=""
    else
        cmd=`echo "${hist}" | tail -1`
        echo "「${AM[$NO]}」:"
        echo -n "${cmd} を実行しました。"
        
        if [ "${#statusArray[@]}" -gt 1 ]; then
            echo ""
            i=1
            for s in ${status}; do
                if [ "${#statusArray[@]}" -eq "$i" ]; then
                    local echoopt="-n"
                else
                    local echoopt=""
                fi
                
                if [ ${s} -eq 141 ]; then
                    echo ${echoopt} "$i 番目、${s} です。$(( $i+1 )) 番目で head を使用していたら無視して構いません。"
                elif [ ${s} -gt 0 ]; then
                    echo ${echoopt} "$i 番目、${s} です。コマンドを確認してください。"
                else
                    echo ${echoopt} "$i 番目、${s} です。正常です。"
                fi
                i=$(( $i+1 ))
            done
        else
            if [ ${status} -eq 1 ]; then
                echo -n "Status Code は ${status} です。コマンドを確認してください。"
            else
                echo -n "Status Code は ${status} です。"
            fi
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