#! /bin/bash

fail(){
  cat /config/waterway/.cache
  exit 0
}

h2d(){
  echo "ibase=16; $@"|bc
}
b2d(){
  echo "ibase=2; $@"|bc
}
h2b(){
  # Prepends a 1 to the output to keep leading 0's intact.
  echo "ibase=16; obase=2; $@ + 10000"|bc|sed -e 's/\([0-9]\)/\1 /g'
}
findpoolmode(){
  case $@ in
  0)
    echo -n Off
    ;;
  1)
    echo -n Pool
    ;;
  2)
    echo -n Spillover
    ;;
  3)
    echo -n Spa
    ;;
  *)
    echo -n unknown
    ;;
  esac
}
onoff(){
 [ $@ -eq 1 ] && echo -n "on" || echo -n "off"
}
getoldheat(){
  POOLA[8]=$(cut -d'"' -f32 < .cache)
  /usr/bin/curl http://192.168.22.5/index.htm?txtValue=%24O2%2C6%2C%21%2CAA%2C55 -s -m 3 -o /dev/null &
}


#Load index.htm with this command so it spits out relevant SetTemp data instead of what webapp asked for last. Dump the reply.
#/usr/bin/curl http://192.168.22.5/index.htm?txtValue=%24O2%2C6%2C%21%2CAA%2C55 -s -m 3 -o /dev/null &

# Load XML and beat it with SED commands until it fits into an array.
XML=$(/usr/bin/curl -m 3 http://192.168.22.5/status.xml 2>&1 | grep AA,55 ) #| grep \$G0 )
#XML=$(cat ./.working/error1.xml | grep -a AA,55 ) #| grep \$G0 )
#echo XML: $XML
POOLA=($( echo $XML | sed -e 's/!,AA,55.*O2,6,....\(..\),............/\1/' -e 's/[^>]*>\([^!]*\).*/\1/' -e 's/,$//' -e 's/$G0,//' -e 's/,/ /g'))
#echo Array: ${POOLA[@]}
#echo Array: ${#POOLA[@]}

## Garbage input returns last good values and exits
[[ ${POOLA[1]},${POOLA[2]},${POOLA[3]},${POOLA[4]},${POOLA[5]},${POOLA[6]},${POOLA[7]} =~ ^[[:xdigit:]]{4}(,[[:xdigit:]]{2}){6}$ ]] || fail;

## [0]=?
## [1]=status bitmap
## [2]=pool temp
## [3]=other bitmap
## [4]=service bitmap
## [5]=air temp
## [6]=pump speed
## [7]=solar temp
## [8]=heat set temp (If status.xml loaded with $O2 values)
  POOLA[2]=$((16#${POOLA[2]}))
  POOLA[5]=$([ ${POOLA[5]} != "00" ] && [ ${POOLA[5]} != "ff" ] && echo -n $((16#${POOLA[5]})) || echo -n "unknown" )
  POOLA[6]=$((16#${POOLA[6]}))
  POOLA[7]=$([ ${POOLA[7]} != "00" ] && [ ${POOLA[7]} != "ff" ] && echo -n $((16#${POOLA[7]})) || echo -n "unknown" )
## Check heat SetTemp. Use cached value if bad and load index.html with O2 to get "other info" back.
  [[ ${POOLA[8]} =~ ^[[:xdigit:]]{2}$ ]] && POOLA[8]=$((16#${POOLA[8]})) || getoldheat;

## Dump invalid replies and error out
  [ ${POOLA[2]} -ge 30 ] && [ ${POOLA[2]} -le 130 ] || exit 1

## Convert status bitmap into usable binary array.
  POOLB=($(h2b ${POOLA[1]}))
##POOLB Statuses:
##  [0] placeholder
##  [3] j4
##  [4] j3-solar
##  [5] j2-return
##  [6] j1-intake
##  [7] aux9
##  [8] aux8
##  [9] aux7
## [10] aux6
## [11] aux5
## [12] aux4
## [13] aux3
## [14] aux2
## [15] aux1
## [16] filterpump

## Convert second bitmap into usable binary array.
  POOLC=($(h2b ${POOLA[3]}))
##POOLC Statuses (All values +8 becasue I'm using the same converter for the 4 digit hex array as this 2 digit hex array):
## [15] heat on
## [13&14] pool mode
## [12] in transition
##  [9] off schedule

## Extra:
## Simple pool status for lone pool systems. Ignore "mode" in home assistant.
## Pool mode only useful for certain pool setups. (pool & spa on 1 filterpump)
  MODENUMBER=$(b2d ${POOLC[13]}${POOLC[14]})
  POOLMODE=$(findpoolmode $MODENUMBER)
## Invert j3 (!! Other users will not want this)
  POOLB[4]=$(tr 01 10 <<< ${POOLB[4]})

## Service Mode:
  SERVICE=$([ ${POOLA[4]} != "00" ] && echo -n "1" || echo -n "0" )

## make Status what was pump
## make Mode what was pool:  pool/spill/spa/off
## make ModeNumber what is currently mode

echo -n "{\
\"Status\":\"$(onoff ${POOLB[16]})\", \
\"Mode\":\"$POOLMODE\", \
\"ModeNumber\":\"$MODENUMBER\", \
\"ServiceMode\":\"$SERVICE\", \
\"InTransition\":\"${POOLC[12]}\", \
\"SchedOverride\":\"${POOLC[9]}\", \
\"PumpSpeed\":\"${POOLA[6]}\", \
\"PoolTemp\":\"${POOLA[2]}\", \
\"AirTemp\":\"${POOLA[5]}\", \
\"SolarTemp\":\"${POOLA[7]}\", \
\"SetTemp\":\"${POOLA[8]}\", \
\"Heat\":\"${POOLC[15]}\", \
\"aux1\":\"${POOLB[15]}\", \
\"aux2\":\"${POOLB[14]}\", \
\"aux3\":\"${POOLB[13]}\", \
\"aux4\":\"${POOLB[12]}\", \
\"aux5\":\"${POOLB[11]}\", \
\"aux6\":\"${POOLB[10]}\", \
\"aux7\":\"${POOLB[9]}\", \
\"aux8\":\"${POOLB[8]}\", \
\"aux9\":\"${POOLB[7]}\", \
\"j1\":\"${POOLB[6]}\", \
\"j2\":\"${POOLB[5]}\", \
\"j3\":\"${POOLB[4]}\", \
\"j4\":\"${POOLB[3]}\" \
}" | tee /config/waterway/.cache
