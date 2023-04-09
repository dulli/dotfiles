#!/usr/bin/env bash

version=$(go version|cut -d' ' -f 3)
release=$(curl --silent https://go.dev/doc/devel/release | grep -Eo 'go[0-9]+(\.[0-9]+)+' | sort -V | uniq | tail -1)

if [[ $version == "$release" ]]; then
    echo "latest go release already installed: $release"
    exit 0
fi

release="${release}.linux-amd64.tar.gz"
echo "installing $release"

tmp=$(mktemp -d)
cd $tmp || exit 1

curl -OL https://go.dev/dl/$release
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf $release
rm -rf $tmp

go version
