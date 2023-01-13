#! /bin/bash

## Might want to make a control for pumpspeed but for now, happy with the controller programming.

case $1 in
  poolmode)
    # Agument 2 is the number of times this url needs to fire to get to desired mode.
    for i in `seq 1 $2`;
    do
      /usr/bin/curl http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C17%2C%21%2CAA%2C55 -s -o /dev/null
      sleep 1
    done
    ;;
## I don't use the rest of these but leaving them just incase / quick reference for urls.
  settemp)
    # Agument 2 is desired set temp.
    echo $2 >> pooltemp.txt
    /usr/bin/curl http://192.168.22.5/index.htm?txtValue=%24O8%2C6%2C2C%2C$(echo "obase=16; $2"|bc)%2C%21%2CAA%2C55
    ;;
  heat)
    /usr/bin/curl http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C15%2C%21%2CAA%2C55 -s -o /dev/null
    ;;
esac
