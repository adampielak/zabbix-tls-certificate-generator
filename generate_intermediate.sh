CMD="docker run --rm -v `pwd`/workdir:/workdir docker-openssl"

rm -rf workdir
mkdir -p workdir

#################################################################

CN=inter_ca
SUBJ="`cat subj_prefix.txt`${CN}"

#################################################################

if [ -d ca_inter ] && [ -f ca_inter/interca.key ] && [ -d ca_inter/index ];
then
    echo "ca_inter already exist, nothing to do"
    exit 0
fi
rm -rf ca_inter
mkdir -p ca_inter
mkdir -p ca_inter/index

echo -n > ca_inter/index/interca_certindex
echo 1000 > ca_inter/index/interca_certserial
echo 1000 > ca_inter/index/interca_crlnumber


cp config/rootca.cnf workdir/
cp ca_root/rootca.{key,crt} workdir/
cp ca_root/index/* workdir/

#################################################################

echo "*** Generating intermediate ca key ***"
$CMD genrsa -out interca.key 8192

echo "*** Creating intermediate CA CSR ***"
$CMD req -sha256 -new -key interca.key -out interca.csr -subj "$SUBJ"

echo "*** Signing intermediate csr with root ca key ***"
$CMD ca -batch -notext -in interca.csr -out interca.crt -config rootca.cnf

cp workdir/interca.{key,crt} ca_inter/
rm -rf workdir

