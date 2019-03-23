#!/usr/bin/env bash

pushd /Users/samuel/repos/cdd-rfc
make clean html

pushd rfcs
pwd
rsync -avz *.html OpenEdX4:/var/www/static/cdd-rfc-web --exclude '.git' --rsync-path='sudo rsync'

popd
popd
