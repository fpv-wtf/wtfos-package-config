#!/bin/bash

set -e
if [ ! -z $DEBUG ]; then
    set -x
fi

#use ./ as config store 
export WTFOS_PACKAGE_CONFIG_BASE=./
#shim dinitctl
export DINITCTL_BINARY="echo"

mkdir -p tmp
cp testconfig.json tmp/config.json
cp testschema.json tmp/schema.json

rm -rf /tmp/package-config/tmp/ || true

echo "#checking default text value"

if [[ $(./package-config get tmp key_text ) != "i am some text" ]]; then
    echo "unexpected key text"
    exit 1 
fi

teststring="me string"

echo "#checking text value update"

./package-config set tmp key_text "$teststring"

if [[ $(./package-config get tmp key_text ) != "$teststring" ]]; then
    echo "unexpected key text"
    exit 1 
fi

## doesn't work in init_schema and fuck spaces in keys
#./package-config set tmp "hello i am spaces" "$teststring"

#if [[ $(./package-config get tmp "hello i am spaces" ) != "$teststring" ]]; then
#    echo "unexpected text"
#    exit 1 
#fi


echo "#checking min text length"

if ./package-config set tmp key_text "a"; then 
    echo "should not have been able to set 1 character text"
    exit 1
fi

echo "#checking max texth length"

if ./package-config set tmp key_text "aasdasdasdadasdasdasdsadas"; then 
    echo "should not have been able to set longer than 10 character text"
    exit 1
fi

echo "#checking text pattern"

if ./package-config set tmp key_text "string123"; then 
    echo "should not have been able to set numberic text not matching pattern"
    exit 1
fi

echo "#checking checbkox invalid value"

if ./package-config set tmp key_checkbox "notabool"; then 
    echo "should not have been able to set nonbool value"
    exit 1
fi

echo "#checking checkbox set to true"

if ./package-config set tmp key_checkbox true; then 
    if [[ $(./package-config get tmp key_checkbox ) != "true" ]]; then
        echo "unexpected checkbox value"
        exit 1
    fi
else 
    echo "should not have been able to set nonbool value"
    exit 1
fi

echo "#checking checkbox set to false"

if ./package-config set tmp key_checkbox false; then 
        if [[ $(./package-config get tmp key_checkbox ) != "false" ]]; then
        echo "unexpected checkbox value"
        exit 1
    fi
else 
    echo "should not have been able to set non bool value"
    exit 1
fi

echo "checking non int value for range"

if ./package-config set tmp key_range "1.04"; then 
    echo "should not have been able to set non int value"
    exit 1
fi

echo "checking min value for int"

if ./package-config set tmp key_range 2; then 
    echo "should not have been able to set values less than 3"
    exit 1
fi

echo "checking max value for int"

if ./package-config set tmp key_range 11; then 
    echo "should not have been able to set values more than 10"
    exit 1
fi

echo "checking set int value"

if ./package-config set tmp key_range 3; then 
        if [[ $(./package-config get tmp key_range ) != "3" ]]; then
        echo "unexpected range value"
        exit 1
    fi
else 
    echo "was not able to set int value"
    exit 1
fi

echo "checking set incorrect select value"

if ./package-config set tmp key_select "iamnotanoption"; then 
    echo "should not have been able to set non existing option"
    exit 1
fi

echo "checking set correct option value"

if ./package-config set tmp key_select key_1; then 
        if [[ $(./package-config get tmp key_select ) != "key_1" ]]; then
        echo "unexpected select value"
        exit 1
    fi
else 
    echo "was not able to set select value"
    exit 1
fi

if ./package-config set tmp key_select key_2; then 
        if [[ $(./package-config get tmp key_select ) != "key_2" ]]; then
        echo "unexpected select value"
        exit 1
    fi
else 
    echo "was not able to set select value"
    exit 1
fi

echo "checking apply command updates config.json"

cp /tmp/package-config/tmp/config.json.new /tmp/package-config/tmp/config.json.new.keep

echo "checking key validation"

if ./package-config set tmp ". #" "iamnotanoption"; then 
    echo "should not be able to set invalid key characters"
    exit 1
fi

#TODO the !!s break something, and i don't know what

#if ./package-config set tmp "f!!" "iamnotanoption"; then 
#    echo "should not be able to set invalid key characters"
#    exit 1
#fi

echo "checking bash variable loading"
eval $(./package-config get tmp)
if [[ "$key_text" != "me string" ]] || [[ "$key_checkbox" != "false" ]] || [[ "$key_range" != "3" ]]  || [[ "$key_select" != "key_2" ]]; then
    echo "could not validate bash variable loading"
    exit 1
fi

./package-config apply tmp

if [ "$(./package-config apply tmp | grep -E "restart service_[12]" | wc -l)" = "2" ]; then
    echo "dinit units didn't get restart called"
    exit 1
fi

if [ "$(cat tmp/config.json | md5sum -)" != "$(cat /tmp/package-config/tmp/config.json.new.keep | md5sum -)" ]; then 
    echo "new config did not apply correctly"
    exit 1
fi

echo all passed