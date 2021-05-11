# waterway
An iffy implementation of Home Assistant integration

Thank you to S10XtremeNLow's for sharing your NodeRed solution.


###Installation: 
Add these lines to your configuration.yaml

```
homeassistant:
  packages:
    waterway: !include waterway/waterway.yaml
```

Then throw the waterway folder into your config/.
Change all instances of my ip (192.168.22.5) to your pool controller's ip.
