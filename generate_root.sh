CMD="docker run --rm -v `pwd`/workdir:/workdir docker-openssl"

rm -rf workdir
mkdir -p workdir

#################################################################

CN=root_ca
SUBJ="`cat subj_prefix.txt`${CN}"

#################################################################

if [ -d ca_root ] && [ -f ca_root/rootca.key ] && [ -d ca_root/index ];
then
    echo "ca_root already exist, nothing to do"
    exit 0
fi
rm -rf ca_root
mkdir -p ca_root
mkdir -p ca_root/index

echo -n > ca_root/index/rootca_certindex
echo 1000 > ca_root/index/rootca_certserial
echo 1000 > ca_root/index/rootca_crlnumber

echo "*** Generating root ca key ***"
$CMD genrsa -out rootca.key 8192

echo "*** Creating self-signed root CA certificate ***"
$CMD req -sha256 -new -x509 -days 3650 -key rootca.key -out rootca.crt -subj "$SUBJ"

cp workdir/rootca.{key,crt} ca_root/
rm -rf workdir

