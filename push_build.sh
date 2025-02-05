
set -e

function build () {
    cd lib/bundler

    git submodule update --init --recursive
    ./bootstrap

    cd ../../

    rm -rf ./build

    lua lib/bundler/build/stage-1/init.lua src build --log-level error \
        --uid lib_LuaX \
        -i gears -i wibox \
        -i ext -i parser -i table \
        -i bit \
        -i template.showcode
}

function main () {
    build

    # The branch the user is on right now
    CUR_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

    case "$CUR_BRANCH" in 
        "master") BRANCH="build" ;;
        "dev") BRANCH="build-dev" ;;
        *) echo "Unhandled branch $CUR_BRANCH"; exit 1;;
    esac

    MESSAGE="$@"
    if [[ -z "$MESSAGE" ]]; then
        MESSAGE="Automated build push"
    fi

    cd build

    git init
    git checkout -b build-temp
    git remote add origin https://github.com/oezingle/LuaX
    git fetch origin $BRANCH
    git reset origin/$BRANCH
    git add -A
    git commit -m "$MESSAGE"
    git branch -m $BRANCH
    git push origin $BRANCH
}

main $@