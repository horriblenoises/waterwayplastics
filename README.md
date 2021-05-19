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

Edit waterway.yaml to comment out the things you don't need and uncomment out the things you do (lone pool vs spillover system). Edit the other switches to customize for your pool's relays.

Add waterwayautomations.yaml contents to your automations.yaml file. 

__This code will need to be modified and addapted to your pool's setup__. For the most part, you can't break anything but I take no responsibility for your pool equipment. For example, my pool is a solar panel heated Spa/Pool overflow configuration. This changes the way j1, j2, & j3 valve controls work.
