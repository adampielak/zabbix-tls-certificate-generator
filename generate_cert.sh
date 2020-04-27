wd=`pwd`

CMD="docker run --rm -v `pwd`/workdir:/workdir docker-openssl"

rm -rf workdir
mkdir -p workdir

#################################################################
USAGE="USAGE: $0 [--inter] [--server] --name <host_name>"

name=""
use_inter=false
server_cert=false

# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash/14203146#14203146
POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        --name)
        name="$2"
        shift # past argument
        shift # past value
        ;;
        --inter)
        use_inter=true
        shift # past argument
        ;;
        --server)
        server_cert=true
        shift # past argument
        ;;
        *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters
other_params=$@

if [[ -z ${name} ]]; then
    echo "$USAGE"
    exit
fi

#################################################################

CN="${name}"
SUBJ="`cat subj_prefix.txt`${CN}"

#################################################################

mkdir -p certs
out=certs/$name

if [ -d $out ] && [ -f $out/$name.key ];
then
    echo "$out already exist, nothing to do"
    exit 0
fi

rm -rf $out
mkdir -p $out

#################################################################

if [ "$use_inter" = true ]
then
    cp config/interca.cnf workdir/
    cp ca_inter/interca.{key,crt} workdir/
    cp ca_inter/index/* workdir/
else
    cp config/rootca.cnf workdir/
    cp ca_root/rootca.{key,crt} workdir/
    cp ca_root/index/* workdir/
fi

#################################################################

echo "*** Generating key ***"
$CMD genrsa -out $name.key 4096

echo "*** Creating $name csr ***"
$CMD req -new -sha256 -key $name.key -out $name.csr -subj "$SUBJ"

if [ "$use_inter" = true ]
then
    echo "*** Signing $name csr with intermediate ca key ***"
    $CMD ca -batch -notext -in $name.csr -out $name.crt -config interca.cnf
else
    echo "*** Signing $name csr with root ca key ***"
    $CMD ca -batch -notext -in $name.csr -out $name.crt -config rootca.cnf
fi

cp workdir/$name.{key,crt} $out/
rm -rf workdir

enc_dir=$out/enc
mkdir -p $enc_dir

if [ "$use_inter" = true ]
then
    cat ca_root/rootca.crt ca_inter/interca.crt > $enc_dir/zabbix_ca_file
else
    cat ca_root/rootca.crt > $enc_dir/zabbix_ca_file
fi


crt_file=zabbix_agentd.crt
key_file=zabbix_agentd.key
if [ "$server_cert" = true ]
then
    crt_file=zabbix_server.crt
    key_file=zabbix_server.key
fi

if [ "$use_inter" = true ]
then
    cat $out/$name.crt ca_inter/interca.crt ca_root/rootca.crt > $enc_dir/$crt_file
else
    cat $out/$name.crt ca_root/rootca.crt > $enc_dir/$crt_file
fi

cp $out/$name.key $enc_dir/$key_file

cd $out

tar -cvf enc_${name}.tar enc

cd $wd

mkdir -p enc
cp $out/enc_${name}.tar enc
