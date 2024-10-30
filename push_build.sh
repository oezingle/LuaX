
set -e

cd build
git init
git checkout -b build
git add -A
git commit -m "Automated build push"
git push -f https://github.com/oezingle/LuaX build