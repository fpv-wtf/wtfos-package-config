#!/bin/bash

set -e
#set -x

export WTFOS_PACKAGE_CONFIG_BASE=./

mkdir -p tmp
cp config.json tmp
cp schema.json tmp

rm tmp/config.json.new || true
rm tmp/config.json.keep || true

echo "#checking default text value"

if [[ $(./config get tmp key_text ) != "i am some text" ]]; then
    echo "unexpected key text"
    exit 1 
fi

teststring="me string"

echo "#checking text value update"

./config set tmp key_text "$teststring"

if [[ $(./config get tmp key_text ) != "$teststring" ]]; then
    echo "unexpected key text"
    exit 1 
fi

## doesn't work in init_schema and fuck spaces in keys
#./config set tmp "hello i am spaces" "$teststring"

#if [[ $(./config get tmp "hello i am spaces" ) != "$teststring" ]]; then
#    echo "unexpected text"
#    exit 1 
#fi


echo "#checking min text length"

if ./config set tmp key_text "a"; then 
    echo "should not have been able to set 1 character text"
    exit 1
fi

echo "#checking max texth length"

if ./config set tmp key_text "aasdasdasdadasdasdasdsadas"; then 
    echo "should not have been able to set longer than 10 character text"
    exit 1
fi

echo "#checking text pattern"

if ./config set tmp key_text "string123"; then 
    echo "should not have been able to set numberic text not matching pattern"
    exit 1
fi

echo "#checking checbkox invalid value"

if ./config set tmp key_checkbox "notabool"; then 
    echo "should not have been able to set nonbool value"
    exit 1
fi

echo "#checking checkbox set to true"

if ./config set tmp key_checkbox true; then 
    if [[ $(./config get tmp key_checkbox ) != "true" ]]; then
        echo "unexpected checkbox value"
        exit 1
    fi
else 
    echo "should not have been able to set nonbool value"
    exit 1
fi

echo "#checking checkbox set to false"

if ./config set tmp key_checkbox false; then 
        if [[ $(./config get tmp key_checkbox ) != "false" ]]; then
        echo "unexpected checkbox value"
        exit 1
    fi
else 
    echo "should not have been able to set non bool value"
    exit 1
fi

echo "checking non int value for range"

if ./config set tmp key_range "1.04"; then 
    echo "should not have been able to set non int value"
    exit 1
fi

echo "checking min value for int"

if ./config set tmp key_range 2; then 
    echo "should not have been able to set values less than 3"
    exit 1
fi

echo "checking max value for int"

if ./config set tmp key_range 11; then 
    echo "should not have been able to set values more than 10"
    exit 1
fi

echo "checking set int value"

if ./config set tmp key_range 3; then 
        if [[ $(./config get tmp key_range ) != "3" ]]; then
        echo "unexpected range value"
        exit 1
    fi
else 
    echo "was not able to set int value"
    exit 1
fi

echo "checking set incorrect select value"

if ./config set tmp key_select "iamnotanoption"; then 
    echo "should not have been able to set non existing option"
    exit 1
fi

echo "checking set correct option value"

if ./config set tmp key_select key_1; then 
        if [[ $(./config get tmp key_select ) != "key_1" ]]; then
        echo "unexpected select value"
        exit 1
    fi
else 
    echo "was not able to set select value"
    exit 1
fi

if ./config set tmp key_select key_2; then 
        if [[ $(./config get tmp key_select ) != "key_2" ]]; then
        echo "unexpected select value"
        exit 1
    fi
else 
    echo "was not able to set select value"
    exit 1
fi

echo "checking apply command updates config.json"

cp tmp/config.json.new tmp/config.json.keep

./config apply tmp
if [ "$(cat tmp/config.json | shasum -)" != "$(cat tmp/config.json.keep | shasum -)" ]; then 
    echo "new config did not apply correctly"
    exit 1
fi

echo all passed