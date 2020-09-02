#!/usr/bin/env sh

## Dark-WhatsApp helper script. \n
##
## \033[0;36mUsage:\033[0m
##     sh whatsapp.sh [-rcfh] \n
##
## \033[0;36mOptions:\033[0m
##     -c      Compile custom ~wa.user.styl~ userstyle.
##     -f      Convert ~wa.user.css~ to ~darkmode.css~.
##     -r      Remove files generated by this script.
##     -h      Print help and exit. \n
##
## Source:
##    \033[0;34m https://github.com/vednoc/dark-whatsapp \033[0m \n
##
## Documentation:
##    \033[0;34m https://github.com/vednoc/dark-whatsapp/wiki \033[0m

usage() {
    echo "Invalid arguments. See help with: $0 -h" >&2
}

short_help() {
    help | tail -n +2
}

help() {
    printf "$(sed -n "s/##\ //p" "$0") \n"
}

remove() {
    echo "Removing files..."

    rm temp.styl darkmode.css custom.user.css
}

compile() {
    echo "Compiling..."

    temp="temp.styl"
    input="wa.user.styl"
    output="custom.user.css"

    sed -n '/^\/\//,$p; 1i @import("metadata.styl");' $input > $temp

    if command -v stylus >/dev/null; then
        stylus $temp -o $output
        rm $temp
    elif ! command -v npm >/dev/null; then
        echo "You're missing ~npm~ and ~Node.js~ libraries." >&2
    else
        echo "Missing ~stylus~ executable in your \$PATH." >&2
    fi
}

convert() {
    echo "Converting..."

    if [ -n "${COMPILE+x}" ]; then
        input="custom.user.css"
    else
        input="wa.user.css"
    fi

    output="darkmode.css"

    sed -n '/:root/,$p' $input | sed 's/^\ \ //; $d' > $output

    [ -e $output ] && echo "Done! $output is ready." \
                   || echo "File not found!" >&2
}

[ $# -eq 0 ] && { echo "No arguments given"; short_help; }

while getopts "rcfh" option; do
    case "$option" in
        "r") REMOVE=1  ;;
        "c") COMPILE=1 ;;
        "f") CONVERT=1 ;;
        "h") help      ;;
        *) short_help  ;;
    esac
done

# Functions need to run in this order, therefore they are not called in getopts.
[ -n "${REMOVE+x}"  ] && remove
[ -n "${COMPILE+x}" ] && compile
[ -n "${CONVERT+x}" ] && convert
