#!/bin/bash

db="/mnt/miniNAS/temp.rrd"

get_temp() {
	/opt/vc/bin/vcgencmd measure_temp|cut -f 2 -d '='|cut -f 1 -d "'"
}

create_db() {
	# create the db
	rrdtool create "$db" --step 1m \
	DS:temp:GAUGE:2m:0:120 \
	RRA:AVERAGE:0.5:2m:1d \
	RRA:AVERAGE:0.5:15m:2w \
	RRA:AVERAGE:0.5:6h:1M
}

update_db() {
	rrdtool update "$db" N:`get_temp`
}

plot() {
	width=700
	height=400
	rrdtool graph 01-hour.png -w $width -h $height -t 'Last hour temperature (°C)' \
	--start N-1h --end N DEF:mytemp="$db":temp:AVERAGE LINE2:mytemp#0000FF >/dev/null
	rrdtool graph 06-hours.png -w $width -h $height -t 'Last 6 hours temperature (°C)' \
	--start N-6h --end N DEF:mytemp="$db":temp:AVERAGE LINE2:mytemp#0000FF >/dev/null
	rrdtool graph 12-hours.png -w $width -h $height -t 'Last 12 hours temperature (°C)' \
	--start N-12h --end N DEF:mytemp="$db":temp:AVERAGE LINE2:mytemp#0000FF >/dev/null
	rrdtool graph 24-hours.png -w $width -h $height -t 'Last day temperature (°C)' \
	--start N-1d --end N DEF:mytemp="$db":temp:AVERAGE LINE2:mytemp#0000FF >/dev/null
	rrdtool graph week.png -w $width -h $height -t 'Last week temperature (°C)' \
	--start N-1w --end N DEF:mytemp="$db":temp:AVERAGE LINE2:mytemp#0000FF >/dev/null
}

if [[ ! -f "$db" ]] ;then
	create_db
fi

if [[ "$1" == "plot" ]] ;then
	plot
else
	update_db
fi
