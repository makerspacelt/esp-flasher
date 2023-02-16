#!/bin/bash

# run this script to generate stuff defined in ./project/.kibot.yaml file
# ./kibot.sh

uid=$(id -u)
gid=$(id -g)

time docker run --rm -it \
    --volume "$(pwd):/tmp/workdir" \
    --workdir "/tmp/workdir" \
    setsoft/kicad_auto:ki6.0.7_Debian \
    /bin/bash -c "groupadd -g$gid u; useradd -u$uid -g$gid -d/tmp u; su u -c 'cd project && kibot -c .kibot.yaml'"


mkdir -p gen

# make gerber generation reproducible
sed -i \
	-e '/^.*TF.CreationDate.*$/d' \
	-e '/^.*G04 Created by KiCad.* date .*$/d' \
	-e '/^.*DRILL file .* date .*$/d' \
	./gen/gerbers/*.{gbr,drl}

rm -f ./gen/gerbers/gerbers.zip
touch -cd 1970-01-01T00:00:00Z ./gen/gerbers/*
zip -qjorX9 -n zip gen/gerbers/gerbers.zip ./gen/gerbers

# remove garbage changes from schematics.pdf
sed -i '/[/]CreationDate.*$/d' ./gen/schematics.pdf
sed -i '/[/]CreationDate.*$/d' ./gen/pcb.pdf

