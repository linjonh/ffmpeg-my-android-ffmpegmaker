#!bin/bash

ALONE="false"
echo define ALONE=$ALONE
echo all args : $@
for arg in "$@"; do
    key=${arg%=*}
    echo paten= "$key"
    if [[ $key == ALONE  ]]; then
        export value=${arg#*=}
        echo ALOne=$value
    else
        echo not hit patern
    fi
done
function testArgsFun(){
    echo all args : $@
    echo [[ $ALONE == "true" ]] ;
    echo define ALONE=$ALONE
    
    if [ $ALONE == "true" ] ; then
        echo build alone
    else
        echo "build all"
    fi
}

testArgsFun $@

str="HelloWorldHelloWorldALONEtrue"

echo ${str%%l*d*}