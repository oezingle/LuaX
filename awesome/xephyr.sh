SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

Xephyr :5 & sleep 1 ; DISPLAY=:5 awesome -c "$SCRIPT_DIR/rc.lua"