#!/usr/bin/env bash

set -e
set -u

target=$TARGET

all=(settarget copytoclipboard deletetarget goback)

show=("${all[@]}")

declare -A texts
texts[goback]="Go back"
texts[settarget]="Set target"
texts[copytoclipboard]="Copy to clipboard"
texts[deletetarget]="Delete target"

declare -A icons
icons[goback]=" "
icons[settarget]=" "
icons[copytoclipboard]=" "
icons[deletetarget]=" "

dryrun=false
showsymbols=true
showtext=ture

function write_message {
  icon="<span rise='-4000' font_size=\"large\">$1</span>"
  text="<span font_size=\"medium\">$2</span>"
  echo -ne "\u200e$icon\t\u2068$text\u2069"
}

if [ "$showsymbols" = "false" -a "$showtext" = "false" ]
then
    echo "Invalid options: cannot have --no-symbols and --no-text enabled at the same time." >&2
    exit 1
fi

declare -A messages
declare -A confirmationMessages
for entry in "${all[@]}"
do
    messages[$entry]=$(write_message "${icons[$entry]}" "${texts[$entry]^}")
done
for entry in "${all[@]}"
do
    confirmationMessages[$entry]=$(write_message "${icons[$entry]}" "Yes, ${texts[$entry]}")
done

if [ $# -gt 0 ]
then
    selection="${@}"
    selection=$(echo "${@}" | sed 's/.*">//' | sed 's/.\{8\}$//' | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')  
    case $selection in
      settarget)
        pkill rofi
        sed -i "s/\b$target\b//g" ~/.config/bin/target
        sed -i '/^$/d' ~/.config/bin/target
        echo -e "$target\n$(cat ~/.config/bin/target)" > ~/.config/bin/target
        cat ~/.config/bin/target | head -1 | tr -d '\n' | xclip -selection clipboard
        exit 0
        ;;

      copytoclipboard)
        pkill rofi
        echo -n $target | xclip -selection clipboard
        exit 0
        ;;

      deletetarget)
        pkill rofi
        sed -i "s/\b$target\b//g" ~/.config/bin/target
        sed -i '/^$/d' ~/.config/bin/target
        source ~/.config/bin/target_set.sh
        ;;

      goback)
        pkill rofi
        source ~/.config/bin/target_set.sh 
        ;;
  esac
  else
    if [ -n "${selectionID+x}" ]
    then
        selection="${messages[$selectionID]}"
    fi
fi

echo -e "\0no-custom\x1ftrue"
echo -e "\0markup-rows\x1ftrue"
echo -e "\0prompt\x1f$target"

if [ -z ${selection+x} ]
then
    for entry in "${show[@]}"
    do
        echo -e "${messages[$entry]}\0icon\x1f${icons[$entry]}"
    done
fi
