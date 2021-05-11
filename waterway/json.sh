#! /bin/bash

h2d(){
  echo "ibase=16; $@"|bc
}
h2b(){
  echo "ibase=16; obase=2; $@ + 10000"|bc|sed -e 's/\([0-9]\)/\1 /g'
}
findpoolmode(){
  case $@ in
  000)
    echo -n Off
    ;;
  100)
    echo -n Pool
    ;;
  110)
    echo -n Spillover
    ;;
  111)
    echo -n Spa
    ;;
  *)
    echo -n unknown
    ;;
  esac
}
findmode(){
  case $@ in
  000)
    echo -n 0
    ;;
  100)
    echo -n 1
    ;;
  110)
    echo -n 2
    ;;
  111)
    echo -n 3
    ;;
  *)
    ;;
  esac
}

#Load index.htm with this command so it spits out relevant SetTemp data instead of what webapp asked for last. Dump the reply.
/usr/bin/curl http://192.168.22.5/index.htm?txtValue=%24O2%2C6%2C%21%2CAA%2C55 -s -o /dev/null &

# Load XML and beat it with SED commands so it fits into an array.
XML=$(/usr/bin/curl http://192.168.22.5/status.xml 2>&1 | grep AA,55 ) #| grep \$G0 )
POOLA=($( echo $XML | sed -e 's/!,AA,55.*O2,6,....\(..\),............/\1/' -e 's/[^>]*>\([^!]*\).*/\1/' -e 's/,$//' -e 's/$G0,//' -e 's/,/ /g'))
#echo ${POOLA[@]}
## [0]=?
## [1]=status bitmap
## [2]=pool temp
## [3]=other bitmap
## [4]=mystery bitmap
## [5]=air temp
## [6]=pump speed
## [7]=solar temp
## [8]=heat set temp (If status.xml loaded with $O2 values)
POOLA[2]=$(h2d ${POOLA[2]})
POOLA[5]=$(h2d ${POOLA[5]})
POOLA[6]=$(h2d ${POOLA[6]})
POOLA[7]=$(h2d ${POOLA[7]})
POOLA[8]=$(h2d ${POOLA[8]})
POOLA[9]=$(h2d ${POOLA[9]})

## Dump invalid replies
if ! [[ ${POOLA[2]} -ge 30 && ${POOLA[2]} -le 130 ]]
then
  exit 1
fi

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
##POOLC Statuses:
## [15] heat on
## [12] in transition 

## Extra:
## Pool mode only useful for certain pool setups. (pool & spa on 1 filterpump)
POOLMODE=$(findpoolmode ${POOLB[16]}${POOLB[6]}${POOLB[5]} )
MODE=$(findmode ${POOLB[16]}${POOLB[6]}${POOLB[5]} )
## Invert j3
POOLB[4]=$(tr 01 10 <<< ${POOLB[4]})

echo -n "{\
\"Pool\":\"$POOLMODE\", \
\"Mode\":\"$MODE\", \
\"Pump\":\"${POOLB[16]}\", \
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
\"j4\":\"${POOLB[3]}\"\
}"

