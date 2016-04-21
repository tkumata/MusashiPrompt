# bash 限定
utmpdir=$(mktemp -d)

# HISTCONTROL に ignore* 入れない
function codeCondition () {
    local code=$1
    
    if [ "${code}" -eq 141 ]; then
        echo -n "パイプ前後が tr や head, tail など処理待ちしないものなら無視して構いません。"
    elif [ "${code}" -eq 130 ]; then
        echo -n "Ctrl + c で終了しました。"
    elif [ "${code}" -gt 128 ] && [ "${code}" -lt 256 ]; then
        local n=$((${code}-128))
        echo -n "Fatal error signal ${n} です。"
    elif [ "${code}" -eq 128 ]; then
        echo -n "実行コマンド内部の EXIT 引数が無効な数字です。"
    elif [ "${code}" -eq 127 ]; then
        echo -n "コマンドのスペルか存在を確認してください。"
    elif [ "${code}" -eq 126 ]; then
        echo -n "実行できませんでした。権限を確認してください。"
    elif [ "${code}" -gt 0 ] && [ "${code}" -lt 256 ]; then
        echo -n "コマンドの引数を確認してください。"
    elif [ "${code}" -eq 0 ]; then
        echo -n "正常です。"
    else
        echo -n "不明な終了ステータスコードです。"
    fi
}

function checkPerm () {
    # stat command is different BSD and Linux. Oh... GNU...
    perm=$(ls -l $1 | awk '{print $1}')
    if [ "${perm}" != "-rw-------" ]; then
        chmod 0600 "$1"
    fi
}

# 使わない関数
function detectOS () {
    local OS="$(uname -s)"
    if [ $OS = "Darwin" ]; then
        echo "Mac OS X"
    elif [ $OS = "FreeBSD" ]; then
        echo "FreeBSD"
    elif [ $OS = "Linux" ]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            echo $ID
        elif [ -f /etc/lsb-release ]; then
            . /etc/lsb-release
            echo $DISTRIB_ID
        fi
    else
        echo "Unknown"
    fi
}

# PIPESTATUS 位置重点
function musashi () {
    local status=$(echo ${PIPESTATUS[@]})
    local statusArray=($(echo $status))
    local hist=$(history | tail -10 | awk '{$1=""; print $0}' | awk '{sub(/^[ \t]+/, "")}1')
    
    local AM=("武蔵" "浅草" "品川" "村山" "多摩" "青梅" "高尾" "武蔵野" "奥多摩" "鹿角")
    local NO=$(($RANDOM%${#AM[@]}))

    local talkCmd="$HOME/bin/atalk.sh"

    if [ "${AM[$NO]}" != "鹿角" ]; then
        local AMNAME="〝${AM[$NO]}〟" # *** IMPORTANT!!!!! ***
        if [ "${AM[$NO]}" = "奥多摩" ]; then
            local oN=$(($RANDOM%2))
            if [ "${oN}" -eq 0 ]; then
                local AMNAME="たまちゃん"
            fi
        fi
    else
        local AMNAME="${AM[$NO]}"
    fi
    
    if uname -s | grep -i 'linux' > /dev/null 2>&1; then
        local OS="Linux"
    else
        local OS="Other"
    fi
    
    # BSD is sha1, Linux is sha1sum. So I had used openssl.
    if [ ${OS} = "Linux" ]; then
        local prefix1="$(echo -n ${USER}$(tty) | openssl dgst -sha1 | awk '{print $2}')"
        local new="musashi-${prefix1}-n"
        local old="musashi-${prefix1}-o"
        echo "${hist}" | openssl dgst -sha1 | awk '{print $2}' > "${utmpdir}/${new}"
    else
        local prefix1="$(echo -n ${USER}$(tty) | openssl dgst -sha1)"
        local new="musashi-${prefix1}-n"
        local old="musashi-${prefix1}-o"
        echo "${hist}" | openssl dgst -sha1 > "${utmpdir}/${new}"
    fi
    
    $(checkPerm ${utmpdir}/${new})
    
    # Check command history
    if cmp -s ${utmpdir}/{${new},${old}} || test ! -e ${utmpdir}/${old}; then
        :
    else
        # Head of transcript
        pcmd=$(echo "${hist}" | tail -1) # important "
        # echo ""
        # echo -n "${AMNAME}: ${pcmd} を実行しました。終了ステータスコードは"
        echo -n "${AMNAME}: 終了ステータスコードは"
        TRAN="終了ステータスコードは"
        
        # Middle of transcript, case by exit status code
        if [ ${#statusArray[@]} -gt 1 ]; then
            echo "それぞれ"
            i=1
            
            for s in ${status}
            do
                if [ ${#statusArray[@]} -eq $i ]; then
                    local echoopt="-ne"
                else
                    local echoopt="-e"
                fi
                
                coderesult=$(codeCondition ${s})
                echo ${echoopt} "${i} 番目、${s} です。${coderesult}"
                
                i=$((${i}+1))
            done
        else
            coderesult=$(codeCondition ${status})
            echo -n " ${status} です。${coderesult}"
            TRAN="${TRAN} ${status} です。${coderesult}"
        fi
        
        # End of transcript
        if [ ! "${AMNAME}" = "鹿角" ]; then
            echo "――以上"
            TRAN="$TRAN 以上"
        fi

#        if [ -f /usr/bin/say ]; then
#            say -v Kyoko -r 200 "${TRAN}"
#        elif [ -f ${talkCmd} ]; then
#            ${talkCmd} -s 140 "${TRAN}"
#        fi

    fi
    
    cp "${utmpdir}"/{"${new}","${old}"}
}
PROMPT_COMMAND='musashi;'${PROMPT_COMMAND//musashi;/}
