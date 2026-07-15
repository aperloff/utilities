# These function depend upon ImageMagick

#
# Get size of image (static or animated)
#
image_size() {
    identify ${1} | head -n 1 | awk '{print $3}'
}

#
# Get the length of an animated GIF
#
gif_duration() {
    identify -format "%T " ${1} | \
    awk '{for(i=1;i<=NF;i++) s+=$i} END{print "Total 1/100s:", s, " -> seconds:", s/100}'
}

#
# Form a triptych from three separate images
#
create_triptych() {
    # Check if we have exactly 3 arguments
    if [ "$#" -ne 3 ]; then
        echo "Usage: create_triptych <image1> <image2> <image3> [output.gif]"
        return 1
    fi

    # Set input files and default output
    local img1="$1"
    local img2="$2"
    local img3="$3"
    local output="${4:-triptych.gif}"

    # Get dimensions of each image
    local size1=$(image_size "$img1")
    local size2=$(image_size "$img2")
    local size3=$(image_size "$img3")

    # Extract width and height for each image
    local width1=$(echo "$size1" | cut -d'x' -f1)
    local height1=$(echo "$size1" | cut -d'x' -f2)
    local width2=$(echo "$size2" | cut -d'x' -f1)
    local height2=$(echo "$size2" | cut -d'x' -f2)
    local width3=$(echo "$size3" | cut -d'x' -f1)
    local height3=$(echo "$size3" | cut -d'x' -f2)

    # Calculate total width
    local total_width=$((width1 + width2 + width3))

    # Find the maximum height
    local max_height=$height1
    if [ "$height2" -gt "$max_height" ]; then max_height=$height2; fi
    if [ "$height3" -gt "$max_height" ]; then max_height=$height3; fi

    # Calculate vertical offsets to center each image
    local offset_y1=$(( (max_height - height1) / 2 ))
    local offset_y2=$(( (max_height - height2) / 2 ))
    local offset_y3=$(( (max_height - height3) / 2 ))

    # Calculate horizontal positions
    local pos_x1=0
    local pos_x2=$width1
    local pos_x3=$((width1 + width2))

    # Create the triptych
    magick convert -size ${total_width}x${max_height} xc:none \
    null: "$img1" -geometry +${pos_x1}+${offset_y1} -layers composite \
    null: "$img2" -geometry +${pos_x2}+${offset_y2} -layers composite \
    null: "$img3" -geometry +${pos_x3}+${offset_y3} -layers composite \
    -layers optimize "$output"

    echo "Triptych created as $output (${total_width}x${max_height})"
}
