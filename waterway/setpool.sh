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
  settemp)
    # Agument 2 is desired set temp.
    /usr/bin/curl http://192.168.22.5/index.htm?txtValue=%24O8%2C6%2C2C%2C$(echo "obase=16; $2"|bc)%2C%21%2CAA%2C55
    ;;
  heat)
    /usr/bin/curl http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C15%2C%21%2CAA%2C55 -s -o /dev/null
    ;;
  aux1)
    /usr/bin/curl http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C02%2C%21%2CAA%2C55 -s -o /dev/null
    ;;
  aux2)
    /usr/bin/curl http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C03%2C%21%2CAA%2C55 -s -o /dev/null
    ;;
  aux3)
    /usr/bin/curl http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C04%2C%21%2CAA%2C55 -s -o /dev/null
    ;;
  aux4)
    /usr/bin/curl http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C05%2C%21%2CAA%2C55 -s -o /dev/null
    ;;
  aux5)
    /usr/bin/curl http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C06%2C%21%2CAA%2C55 -s -o /dev/null
    ;;
  aux6)
    /usr/bin/curl http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C07%2C%21%2CAA%2C55 -s -o /dev/null
    ;;
  aux7)
    /usr/bin/curl http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C08%2C%21%2CAA%2C55 -s -o /dev/null
    ;;
  aux8)
    /usr/bin/curl http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C09%2C%21%2CAA%2C55 -s -o /dev/null
    ;;
  aux9)
    /usr/bin/curl http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C0A%2C%21%2CAA%2C55 -s -o /dev/null
    ;;
  j1)
    /usr/bin/curl http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C0B%2C%21%2CAA%2C55 -s -o /dev/null
    ;;
  j2)
    /usr/bin/curl http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C0C%2C%21%2CAA%2C55 -s -o /dev/null
    ;;
  j3)
    /usr/bin/curl http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C0D%2C%21%2CAA%2C55 -s -o /dev/null
    ;;
  j4)
    /usr/bin/curl http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C0E%2C%21%2CAA%2C55 -s -o /dev/null
    ;;
esac
