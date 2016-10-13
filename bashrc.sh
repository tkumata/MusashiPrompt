#
# The MIT License (MIT)
# Copyright (c) 2016 tkumata
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# bash 限定
user_tmp_dir=$(mktemp -d)

# HISTCONTROL に ignore* 入れない
function code_condition () {
  local code=$1
  
  if [ "${code}" -eq 141 ]; then
    echo -n "パイプ前後が tr,head,tail など処理待ちしないものなら無視して構いません。"
  elif [ "${code}" -eq 130 ]; then
    echo -n "Ctrl+C で終了しました。"
  elif [ "${code}" -gt 128 ] && [ "${code}" -lt 256 ]; then
    local n=$((${code}-128))
    echo -n "Fatal error signal ${n} です。"
  elif [ "${code}" -eq 128 ]; then
    echo -n "実行コマンド内部の EXIT 引数が無効な数字です。"
  elif [ "${code}" -eq 127 ]; then
    echo -n "スペルミスと判断します。"
  elif [ "${code}" -eq 126 ]; then
    echo -n "コマンドの権限を確認してください。"
  elif [ "${code}" -gt 0 ] && [ "${code}" -lt 256 ]; then
    echo -n "コマンドの引数を確認してください。"
  elif [ "${code}" -eq 0 ]; then
    echo -n "正常と判断します。"
  else
    echo -n "不明な終了コードです。"
  fi
}

function check_perm () {
  # stat command is different BSD and Linux. Oh... GNU...
  perm="$(ls -l $1 | awk '{print $1}')"
  if [ "${perm}" != "-rw-------" ]; then
    chmod 0600 "$1"
  fi
}

function detect_distro () {
  case "${OSKERN}" in
    Darwin)
      echo "OS X"
      ;;
    FreeBSD)
      echo "FreeBSD"
      ;;
    NetBSD)
      echo "NetBSD"
      ;;
    SunOS)
      echo "Solaris"
      ;;
    GNU)
      echo "Debian"
      ;;
    HP-UX)
      echo "HP-UX"
      ;;
    Linux)
      if [ -f /etc/os-release ]; then
          . /etc/os-release
          echo "${NAME}"
      elif [ -f /etc/lsb-release ]; then
          . /etc/lsb-release
          echo "${DISTRIB_ID}"
      fi
      ;;
    *)
      echo "Other"
      ;;
  esac
}

# PIPESTATUS 位置重点
function musashi () {
    local status=$(echo ${PIPESTATUS[@]})
    local status_array=($(echo $status))
    local hist=$(history | tail -10 | awk '{$1=""; print $0}' | awk '{sub(/^[ \t]+/, "")}1')
    
    local automaton_names=("武蔵" "浅草" "品川" "村山" "多摩" "青梅" "高尾" "武蔵野" "奥多摩" "鹿角")
    local NO=$(($RANDOM%${#automaton_names[@]}))
    
    local talk_cmd="${HOME}/bin/atalk.sh"
    
    if [ "${automaton_names[$NO]}" = "鹿角" ]; then
        local automaton_name="${automaton_names[$NO]}"
    else
        local automaton_name="〝${automaton_names[$NO]}〟" # *** IMPORTANT ***
        if [ "${automaton_names[$NO]}" = "奥多摩" ]; then
            local oN=$(($RANDOM%2))
            
            if [ "${oN}" -eq 0 ]; then
                local automaton_name="たまちゃん"
            fi
        fi
    fi
    
    # diff openssl
    OSKERN="$(uname -s)"
    if [ ${OSKERN} = "Linux" ]; then
        local prefix1="$(echo -n ${USER}$(tty) | openssl dgst -sha1 | awk '{print $2}')"
        local new="musashi-${prefix1}-n"
        local old="musashi-${prefix1}-o"
        echo "${hist}" | openssl dgst -sha1 | awk '{print $2}' >"${user_tmp_dir}/${new}"
    else
        local prefix1="$(echo -n ${USER}$(tty) | openssl dgst -sha1)"
        local new="musashi-${prefix1}-n"
        local old="musashi-${prefix1}-o"
        echo "${hist}" | openssl dgst -sha1 >"${user_tmp_dir}/${new}"
    fi
    
    # check permission
    $(check_perm ${user_tmp_dir}/${new})
    
    # playfulness
    DISTRO="$(detect_distro)"
    automaton_name="${automaton_name}(${DISTRO})"
    
    # Check command history
    if cmp -s ${user_tmp_dir}/{${new},${old}} || test ! -e ${user_tmp_dir}/${old}; then
        :
    else
        # Head of transcript
        pcmd=$(echo "${hist}" | tail -1) # important " position
        echo -n "${automaton_name}: 終了コードは"
        transcript="終了コードは"
        
        # Middle of transcript, case by exit status code
        if [ ${#status_array[@]} -gt 1 ]; then
            echo "それぞれ"
            i=1
            
            for s in ${status}; do
                if [ ${#status_array[@]} -eq $i ]; then
                    local echoopt="-ne"
                else
                    local echoopt="-e"
                fi
                
                code_result=$(code_condition ${s})
                echo ${echoopt} "${i} 番目、${s} です。${code_result}"
                
                i=$((${i}+1))
            done
        else
            code_result=$(code_condition ${status})
            echo -n " ${status} です。${code_result}"
            transcript="${transcript} ${status} です。${code_result}"
        fi
        
        # End of transcript
        if [[ $(echo "${automaton_name}" | grep "鹿角") ]]; then
            echo "" # End of option "-n"
        else
            echo "――以上"
            transcript="${transcript} 以上"
        fi

        # for say or aquestalk.
#        if [ -f /usr/bin/say ]; then
#            say -v Kyoko -r 200 "${transcript}"
#        elif [ -f ${talk_cmd} ]; then
#            ${talk_cmd} -s 140 "${transcript}"
#        fi
    
    fi
    
    cp "${user_tmp_dir}"/{"${new}","${old}"}
}
PROMPT_COMMAND='musashi;'${PROMPT_COMMAND//musashi;/}
