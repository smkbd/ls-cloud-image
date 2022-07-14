#/usr/bin/env bash
letsencrypt_path='/etc/letsencrypt/live/'
EPACE='        '
ECC_CURV='secp384r1'

check_input(){
    if [ -z "${1}" ] || [ -z "${2}" ] || [ -z "${3}" ]
    then
        help_message
        exit 1
    fi
}


echow(){
    FLAG=${1}
    shift
    echo -e "\033[1m${EPACE}${FLAG}\033[0m${@}"
}


gen_ecc_cert(){
    w_domain=${1}
    w_email=${2}
    w_webroot=${3}
    w_path=$letsencrypt_path${w_domain}/
    if [ -d $w_path ]
    then
        echo "folder exits: $w_path"
        rm -f ${w_path}ecc*
        rm -f ${w_path}*pem
    else
        echo "folder not exits, create path: $w_path"
        mkdir $w_path
    fi

    openssl ecparam -genkey -name ${ECC_CURV} | sudo openssl ec -out ecc.key >/dev/null 2>&1
    openssl req -new -sha256 -key ecc.key -nodes -out ecc.csr -outform pem >/dev/null 2>&1 <<csrconf
US
NJ
Virtual
LiteSpeedCommunity
Testing
$w_domain
.
.
.
csrconf
    mkdir -p ${w_webroot}.well-known
    certbot certonly --non-interactive --agree-tos --email $w_email --webroot -w $w_webroot -d $w_domain --csr ecc.csr
    mv ecc* $w_path
    mv *pem $w_path


}


help_message(){
    echo -e "\033[1mNAME\033[0m"
    echow "generate_ecc.sh - Generate ECC(elliptical curve cryptography) ECDSA"
    echo -e "\033[1mOPTIONS\033[0m"
    echow '-d'
    echo "${EPACE}${EPACE}Domain"
    echow '-e'
    echo "${EPACE}${EPACE}Email"
    echow '-w'
    echo "${EPACE}${EPACE}Website root folder"
    echow '-h, --help'
    echo "${EPACE}${EPACE}Display help."
    echo -e "\033[1mEXAMPLE\033[0m"
    echow "generate_ecc.sh -d 'example.com' -e 'john@email.com' -w '/var/www/public_html/'"
    echo ""
    echow "Vhost SSL settings:"
    echo "${EPACE}${EPACE}SSLCertificateFile /etc/letsencrypt/live/{DOMAIN}/0001_chain.pem"
    echo "${EPACE}${EPACE}SSLCertificateKeyFile /etc/letsencrypt/live/{DOMAIN}/ecc.key"
}

while getopts :d:e:w: flag
do
    case "${flag}" in
        d) domain=${OPTARG};;
        e) email=${OPTARG};;
        w) webroot=${OPTARG};;
    esac
done

check_input $domain $email $webroot

if [ ! -z "${1}" ]
then
    case ${1} in
        -[hH] | -help | --help)
            help_message
            ;;
        -[d] )
            gen_ecc_cert $domain $email $webroot
            ;;
        *)
            help_message
           ;;
    esac
fi
