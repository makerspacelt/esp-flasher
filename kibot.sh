#!/bin/bash

# run this script to generate stuff defined in ./project/.kibot.yaml file
# ./kibot.sh

uid=$(id -u)
gid=$(id -g)


mkdir -p gen/prod

time docker run --rm -it \
    --volume "$(pwd):/tmp/workdir" \
    --workdir "/tmp/workdir" \
    setsoft/kicad_auto:ki6.0.7_Debian \
    /bin/bash -c "groupadd -g$gid u; useradd -u$uid -g$gid -d/tmp u; su u -c 'cd project && kibot -c .kibot.yaml'"



# make gerber generation reproducible
sed -i \
	-e '/^.*TF.CreationDate.*$/d' \
	-e '/^.*G04 Created by KiCad.* date .*$/d' \
	-e '/^.*DRILL file .* date .*$/d' \
	./gen/prod/*.{gbr,drl}

#rm -f ./gen/prod.zip
touch -cd 1970-01-01T00:00:00Z ./gen/prod/*
zip -qjorX9 -n zip gen/prod.zip ./gen/prod

# remove garbage changes from schematics.pdf
sed -i '/[/]CreationDate.*$/d' ./gen/schematics.pdf
sed -i '/[/]CreationDate.*$/d' ./gen/pcb.pdf

