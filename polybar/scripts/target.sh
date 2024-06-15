target() {
	rofi -dmenu\
        -no-config\
		-i\
		-no-fixed-num-lines\
		-p ''\
		-theme ~/.config/polybar/scripts/rofi/target.rasi
}

ans=$(target &)
echo $ans > /usr/share/target.txt
 
