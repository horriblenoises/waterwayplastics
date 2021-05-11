# waterway
An iffy implementation of Home Assistant integration

Thank you to S10XtremeNLow's for sharing your NodeRed solution.


### Installation: 
Add these lines to your configuration.yaml

```
homeassistant:
  packages:
    waterway: !include waterway/waterway.yaml
```

Throw the waterway folder into your config/. 

Change all instances of my ip (192.168.22.5) to your pool controller's ip.

Add waterwayautomations.yaml contents to your automations.yaml file. 

__This code will need to be modified and addapted to your pool's setup__. For the most part, you can't break anything but I take no responsibility for your pool equipment. For example, my pool is a solar panel heated Spa/Pool overflow configuration. This changes the way j1, j2, & j3 valve controls work.




### Scratch Sheet:
```
Pool Decode

Statuses:
  Status?
  | ?
  | |    Status bitmap
  | |    | Pool Temp
  | |    |  | bitmap
  | |    |  | |   ?
  | |    |  | |   | Air temp?
  | |    |  | |   |  | Pump Speed
  | |    |  | |   |  |  | Solar temp
  | |    |  | |   |  |  |  | ?
$G0,0,0001,44,04,00,43,4F,43,!,AA,55	Pool mode; Spa Light off.
$G0,0,0003,44,84,00,43,4F,43,!,AA,55	Pool mode; Spa Light on.
$G0,0,0003,44,84,00,43,4F,42,!,AA,55	Pool mode; Spa Light on.
$G0,0,0003,44,84,00,44,4F,43,!,AA,55	Pool mode; Spa Light on.
$G0,0,0001,44,04,00,44,4F,43,!,AA,55	Pool mode; spa light off.
           68 l     67 79 67 											Cannot find Pool set temp. 87 or 0x57
$G0,0,0001,45,86,00,45,3C,43,!,AA,55	Turned on poll heat.
           69  x    69 60 67
$G0,0,0001,45,04,00,45,5A,44,!,AA,55	Pump speed 90%
                       90
$G0,0,0400,45,98,00,45,00,44,!,AA,55	Activating Spillover
$G0,0,0401,45,88,00,45,64,44,!,AA,55	Spillover mode prime
                      100
$G0,0,0401,45,88,00,44,50,43,!,AA,55	Spillover mode
                       80
$G0,0,0403,45,88,00,44,50,42,!,AA,55	Spillover mode; Spa Light on.

$G0,0,0C00,45,9C,00,44,00,42,!,AA,55	Spa mode activating
$G0,0,0C01,45,8C,00,44,64,43,!,AA,55	Spa mode priming
$G0,0,0C01,47,8C,00,44,50,43,!,AA,55	Spa mode

$G0,0,0000,44,00,00,44,00,43,!,AA,55	Pool off; light off.
$G0,0,0002,44,80,00,44,00,43,!,AA,55	pool off; light on.			$O9,6,01,0000,!,AA,55

$G0,0,0001,42,04,00,44,4F,44,!,AA,55	pool mode; light off.
           66       68    68

$G0,0,0005,42,84,00,44,4F,44,!,AA,55	pool mode; aux pump on.

$G0,0,0201,42,84,00,45,4F,45,!,AA,55	pool mode; aux9 on.

$G0,0,2001,42,84,00,45,4F,45,!,AA,55	pool mode; j4 on.

$G0,0,0C00,42,1C,00,45,00,45,!,AA,55	spa mode activating from sched;
         1    0C                    	spa mode active

$G0,0,0C01,43,8E,00,46,64,46,!,AA,55	spa mode; spa heat


$G0,0,0001,44,04,00,49,4F,4A,!,AA,55	air 72 solar 75 water 67 poolset 87
           68       73    74



Any feature active?
|?
||?
|||In Transition
||||xx Mode 2bit (0:off; 1:pool; 2:spillover; 3:spa)
||||||Pool/Spa Heat
|||||||?
||||||||
87654321
10000000	80 off mode; light on
10001000	88 spillover mode
10000100	84 pool mode
10000110	86 pool mode; pool heat
00011100	1C spa mode activating
10011100	9C spa mode activating
00001100	0C spa mode
10001110	8E spa mode; spa heat
||||||||
|||||||
||||||Heat on



??
||j4-option
|||j3-solar
||||j2-return
|||||j1-intake
||||||9876
||||||||||Aux5
|||||||||||Aux4
||||||||||||Aux3
|||||||||||||Aux Pump (aux2)
||||||||||||||Light on (aux1)
|||||||||||||||Pool on (Filter pump)
||||||||||||||||
0fedcba987654321
0000000000000001	pool mode
0000010000000001	spillover mode
0000110000000001	spa mode
0000001000000001	poolmode; aux9 on.
0010000000000001	poolmode; j4option on.
||||||||||||||||
|||||||||||||||pump
||||||||||||||light
|||||valve1
||||valve2
|||valve3
|
heat status


http://192.168.22.5/index.htm?txtValue=
http://192.168.22.5/status.xml?txtValue=%24O2

%24A0%2C6%2C02%2C%21%2CAA%2C55	$A0,6,02,!,AA,55
%24A0%2C6%2C02%2C%21%2CAA%2C55


"Query Pool Heat Temp"
http://192.168.22.5/index.htm?txtValue=
$O2,6,!,AA,55
$O2

Set Pool Temp:
http://192.168.22.5/index.htm?txtValue=%24O8%2C6%2C2C%2C  %2C%21%2CAA%2C55
$O8,6,2C,xx,!,AA,55
?? $O8 = $A5,0,01,3540,F5,!,AA,55

"Trigger Valve 1"
http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C0B%2C%21%2CAA%2C55
$A0,6,0B,!,AA,55

"Trigger Valve 2"
http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C0C%2C%21%2CAA%2C55
$A0,6,0C,!,AA,55

"Trigger Valve 3"
http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C0D%2C%21%2CAA%2C55
$A0,6,0D,!,AA,55

"Trigger Heat"
http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C15%2C%21%2CAA%2C55
$A0,6,15,!,AA,55

"Pool Light"
http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C02%2C%21%2CAA%2C55
$A0,6,02,!,AA,55

Pool/Spa Mode Cycle [Pool,Spill,Spa,Off]
http://192.168.22.5/index.htm?txtValue=%24A0%2C6%2C17%2C%21%2CAA%2C55
$A0,6,17,!,AA,55
```
