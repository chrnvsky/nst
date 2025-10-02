#!/usr/bin/bash

#АРГУМЕНТЫ ЗАПУСКА "nexus.tomskasu.ru" "nuget-hosted" "nexus-kk.tomskasu.ru"

LINKS_ARR=()

#Загрузка пакетов в новый нексус
function download_upload_to_nexus_package() {
  NEW_FILE_NAME=$(awk -F '/' '{print $6 "." $7 ".nupkg"}' <<< "${LINKS_ARR[$j]}")
  wget "${LINKS_ARR[$j]}" -O $NEW_FILE_NAME
  curl -u login:password -X POST https://"${NEW_NEXUS}"/service/rest/v1/components?repository="${NEXUS_REPO}" -F nuget.asset=@"${NEW_FILE_NAME}"
  rm "$NEW_FILE_NAME"
}

#Получение списка всех пакетов из репозитория нексуса
function parse_page() { 

  ARG_TOKEN=""
  if [[ $TOKEN != "" ]]; then
    ARG_TOKEN="continuationToken=${TOKEN}&"
  fi

  list_json=$(curl -X GET https://${URL_NEXUS}/service/rest/v1/components?"${ARG_TOKEN}"repository=${NEXUS_REPO})
  LIST_URLS=($(grep downloadUrl <<< ${list_json} | awk '{gsub(/"/, "", $3);gsub(/,/, "", $3); print $3}'))
  LINKS_ARR+=(${LIST_URLS[@]})
  CONT_TOKEN=$(grep continuationToken <<< ${list_json} | awk '{gsub(/"/, "", $3); print $3}')
}

function list_download_url() {

  URL_NEXUS=$1
  NEXUS_REPO=$2

  TOKEN=""
  while true; do
    parse_page
    TOKEN=$CONT_TOKEN
    if [[ $TOKEN == null ]]; then
        break
    fi
  done
}

function download_packages() {

  NEW_NEXUS=$1
  NEXUS_REPO=$2

  step=5
  idx=0
  lenght_array=${#LINKS_ARR[@]}
  elements_array=$((--lenght_array))
  iterations=$((elements_array/step))

  for (( i = 0; i < ((iterations+1)); i++ )); do # Общий цикл всех итераций 250 пакетов = 50 итераций при шаге 5
  pids=()
      for (( j = idx; j < ((idx+step)); j++ )); do # Запуск пачки из `step` задач параллельно
        download_upload_to_nexus_package &
        pids+=" $!"
      if [[ $j == $elements_array ]]; then
        break
      fi
      done

      for pid in ${pids[*]}; do
        wait $pid
        if [ $? -ne 0 ]; then
          exit 1
        fi
      done
  ((idx=idx+step))
  done
}

function main() {
     list_download_url "$1" "$2"
     download_packages "$3" "$2"
}

main "$1" "$2" "$3"
#"nexus.tomskasu.ru" "nuget-hosted" "nexus-kk.tomskasu.ru"