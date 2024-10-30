
set -e

cd lib/bundler

git submodule update --init --recursive
./bootstrap

cd ../../

rm -rf ./build

lua lib/bundler/build/stage-1/init.lua src build --log-level error \
        -i gears -i wibox \
        -i ext -i parser -i table \
        -i bit \
        -i template.showcode