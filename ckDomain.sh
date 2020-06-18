cek(){
          # High Intensty
  IBlack='\033[0;90m'      
  IRed='\033[0;91m'       
  IGreen='\033[0;92m'
  IYellow='\033[0;93m'
  IBlue='\033[0;94m'
  IPurple='\033[0;95m'
  ICyan='\033[0;96m'

  # Bold High Intensty
  BIBlack='\033[1;90m'
  BIRed='\033[1;91m'
  BIGreen='\033[1;92m'
  BIYellow='\033[1;93m'
  BIBlue='\033[1;94m'
  BIPurple='\033[1;95m'
  BICyan='\033[1;96m'
  BIWhite='\033[1;97m' 

totalLines=`grep -c "." $inputFile`
echo "There are $totalLines list of Domain."
IFS=$'\r\n' GLOBIGNORE='*' command eval  'domainlist=($(cat $inputFile))'
con=1

for (( i = 0; i < "${#domainlist[@]}"; i++ )); do
  username="${domainlist[$i]}"
  indexer=$((con++))
  tot=$((totalLines--))

#   MIDDLE CLASS DOMAIN => [Domain : www.netsuiteipo.com|DA: 18|PA: 19|BL: 26|SS: null]
domain_mentah="$(cut -d'[' -f2 <<<"$username")"
domain_mentah_h="$(cut -d']' -f1 <<<"$domain_mentah")"
domain_da="$(cut -d'|' -f2 <<<"$domain_mentah_h"|cut -d':' -f2)"
domain_pa="$(cut -d'|' -f3 <<<"$domain_mentah"|cut -d':' -f2)"
domain_bl="$(cut -d'|' -f4 <<<"$domain_mentah"|cut -d':' -f2)"
domain_ss_mentah="$(cut -d'|' -f5 <<<"$domain_mentah")"
domain_ss="$(cut -d']' -f1 <<<"$domain_ss_mentah"|cut -d':' -f2)"
#=============================================================
domain_asli_mentah="$(cut -d'|' -f1 <<<"$domain_mentah_h")"
domain_asli="$(cut -d':' -f2 <<<"$domain_asli_mentah"|sed "s/ //g")"
domain_www="$(cut -d'.' -f1 <<<"$domain_asli")"
domain_sld="$(cut -d'.' -f2 <<<"$domain_asli")"
domain_tld="$(cut -d'.' -f3 <<<"$domain_asli")"

# echo "$domain_www -> $domain_sld -> $domain_tld"
# echo "domain_mentah_setengah : $domain_mentah_setengah|DA : $domain_da|PA : $domain_pa|BL : $domain_bl|SS : $domain_ss "

    url=`curl 'https://domains.google.com/v1/Main/FeSearchService/Availability?authuser=0' -H 'authority: domains.google.com' -H 'accept: application/json, text/plain, */*' -H 'user-agent: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Mobile Safari/537.36' -H 'content-type: application/json' -H 'origin: https://domains.google.com' -H 'sec-fetch-site: same-origin' -H 'sec-fetch-mode: cors' -H 'sec-fetch-dest: empty' -H 'referer: https://domains.google.com/m/registrar/search?searchTerm=akucode.com&hl=en&_ga=2.216928598.1538382046.1592474053-754713962.1592474053' -H 'accept-language: en-US,en;q=0.9,id;q=0.8' -H 'cookie: ANID=AHWqTUkLviXwJPtahjXpXHPnOavGhiQN5I8eo6Fvs5fXA0GgV78Sav78C7SEpF0v; NID=204=ihcjPfa-iKUZdLHYTL8gG5x9_NJERxEEDB_gDmgJYd2a9cp7YahokmKnHVQFYEnGCgmBUpYZLhWyKD_AHxdeiTLVcvToq_rYLNZxcmPparagh91xe3TI7Drm799Z2CBrFsjv_T3yaeuhMGcdbIieDfYwh7HOHsQQr0IJ5fzPmOE; 1P_JAR=2020-6-18-9; _gcl_au=1.1.726219492.1592474071; _ga=GA1.3.754713962.1592474053; _gid=GA1.3.1538382046.1592474053; _gat_UA-18038-34=1' --data-binary '{"clientUserSpec":{"countryCode":"ID","currencyCode":"IDR","sessionId":"-1787183499"},"domainName":[{"sld":"'$domain_sld'","tld":"'$domain_tld'"}]}' --compressed -s|sed "s/)]}'//g"|jq -r '.'`

    info_available="$(echo "$url"|jq -r .availabilityResponse.results.result[]?.supportedResultInfo.availabilityInfo.availability)"
    info_pricing="$(echo "$url"|jq -r .availabilityResponse.results.result[]?.supportedResultInfo.purchaseInfo.pricing.normalPricing.renewPrice.units)"
    info_not_available_domain="$(echo "$url"|jq -r .availabilityResponse.results.result[]?.unsupportedResultInfo.unsupportedReasons.unsupportedTld.tldUnicode)"

if [[ $info_available == 'AVAILABILITY_UNAVAILABLE' ]];then
    printf "${BIWhite}[${BIBlue}$i${BIWhite}] ${BIYellow}-> ${BIWhite}[${BIBlue}$domain_asli${BIWhite} ${BIYellow}=> ${BIRed}UNAVAILABLE${BIWhite}]\n"
    echo "UNAVAILABLE DOMAIN => [$domain_asli]" >> $targetFolder/unavailable_domain.txt
    else
    if [[ $info_available == 'AVAILABILITY_AVAILABLE' || $info_available == 'AVAILABILITY_UNKNOWN' ]];then
        printf "${BIWhite}[${BIBlue}$i${BIWhite}] ${BIYellow}-> ${BIWhite}[${BIBlue}$domain_asli${BIWhite} ${BIYellow}=> ${BIGreen}AVAILABLE ${BIWhite}| ${BIBlue}Price ${BIWhite}: ${BIYellow}$info_pricing ${BIWhite}] - [${BIPurple}Domain Authority ${BIWhite}: ${BIYellow}$domain_da ${BIWhite}| ${BIPurple}Page Authority ${BIWhite}: ${BIYellow}$domain_pa ${BIWhite}| ${BIPurple}Total Backlink ${BIWhite}: ${BIYellow}$domain_bl ${BIWhite}| ${BIPurple}Spam Score ${BIWhite}: ${BIYellow}$domain_ss${BIWhite}]\n"
        echo "AVAILABLE DOMAIN => [$domain_asli] | Price : $info_pricing IDR | DA: $domain_da|PA: $domain_pa|BL: $domain_bl|SS: $domain_ss" >> $targetFolder/available_domain.txt
        else
        if [[ $info_not_available_domain == $domain_tld ]];then
                printf "${BIWhite}[${BIBlue}$i${BIWhite}] ${BIYellow}-> ${BIWhite}[${BIBlue}$domain_asli${BIWhite} ${BIYellow}=> ${BIRed}DOMAIN NOT SUPPORTED ON GOOGLE${BIWhite} | ${BIPurple}Price${BIWhite} : ${BIYellow}$info_pricing ${BIBlue}IDR${BIWhite}]\n"
                echo "DOMAIN NOT SUPPORTED ON GOOGLE => [$domain_asli]" >> $targetFolder/not_support_google_domain.txt
                else
                    printf "${BIWhite}[${BIBlue}$i${BIWhite}] ${BIYellow}-> ${BIWhite}[${BIBlue}$domain_asli${BIWhite} ${BIYellow}=> ${BICyan}UNKNOWN${BIWhite}]\n"
                    echo "[$domain_asli] => $url" >> $targetFolder/Unknown.txt
        fi
    fi
fi
    done
}
            while [[ $inputFile == '' ]]; do
            read -p "Input Domain File: " inputFile
                [[ $inputFile == '' ]]
            done
            while [[ $targetFolder == '' ]]; do
            read -p "Create Folder Report: " targetFolder
                [[ $targetFolder == '' ]]
                  if [[ ! -d "$targetFolder" ]]; then
                        echo "[+] Creating $targetFolder/ folder"
                        mkdir $targetFolder
                    else
                        read -p "$targetFolder/ folder are exists, append to them ? [y/n]: " isAppend
                        if [[ $isAppend == 'n' ]]; then
                        exit
                        fi
                    fi
            done
cek