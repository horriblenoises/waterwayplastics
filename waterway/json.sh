## Waterways Oasis

##changes:
# moved template entities from legacy format to new.
# changed set_heat_temp to number entity for cleaner interface and removed old automations.
#  replace input_number.pool_settemp with number.pool_heat_temp
# added service mode
# added rest call to set current time to sync with home assistant
# input_text.poolctrlip as hacky variable for the pool controller IP.



## ENTER YOUR POOL CONTROLLER'S IP ADDRESS
input_text:
  poolctrlip:
    initial: "192.168.22.5"


sensor:
  - platform: command_line
    name: pool
    json_attributes:
      - Mode
      - ModeNumber
      - ServiceMode
      - InTransition
      - SchedOverride
      - PumpSpeed
      - PoolTemp
      - AirTemp
      - SolarTemp
      - SetTemp
      - Heat
      - aux1
      - aux2
      - aux3
      - aux4
      - aux5
      - aux6
      - aux7
      - aux8
      - aux9
      - j1
      - j2
      - j3
      - j4
    command: "/config/waterway/json.sh"
    value_template: "{{ value_json.Status }}"
    scan_interval: "2"

template:
  sensor:
    - name: "Pool Mode"
      state: "{{ state_attr('sensor.pool', 'Mode') }}"
      icon: "mdi:air-filter"
    - name: "Pool Temp"
      state: "{{ state_attr('sensor.pool', 'PoolTemp')|int if (state_attr('sensor.pool', 'PoolTemp')|int > 0) }}"
      icon: mdi:pool-thermometer
      device_class: "temperature"
      unit_of_measurement: "°F"
    - name: "Air Temp"
      state: "{{ state_attr('sensor.pool', 'AirTemp')|int if (state_attr('sensor.pool', 'AirTemp')|int > 0) }}"
      device_class: "temperature"
      unit_of_measurement: "°F"
    - name: "Solar Temp"
      state: "{{ state_attr('sensor.pool', 'SolarTemp')|int if (state_attr('sensor.pool', 'SolarTemp')|int > 0) }}"
      device_class: "temperature"
      icon: mdi:sun-thermometer
      unit_of_measurement: "°F"
    - name: "Pump Speed"
      state: "{{ state_attr('sensor.pool', 'PumpSpeed')|int }}"
      unit_of_measurement: "%"
      icon: "mdi:pump"
  number:
    - name: "Pool Heat Temp"
      state: "{{ state_attr('sensor.pool', 'SetTemp')|int }}"
      min: 74
      max: 99
      step: 1
      optimistic: true
      set_value:
        service: rest_command.set_pool_heat_temp
  binary_sensor:
    - name: "Pool Service Mode"
      state: "{{ is_state_attr('sensor.pool', 'ServiceMode', '1') }}"
      icon: mdi:progress-wrench
# Transitioning is the timeout period of ~30sec the controller waits for valves to rotate before it turns the pump on.
# May not be a thing for pools without spillover/spa modes.
    - name: "Pool Transitioning"
      state: "{{ is_state_attr('sensor.pool', 'InTransition', '1') }}"
      icon: mdi:progress-clock
# Schedule Override is 'on' whenever the mode is changed manually.
# If you change the mode back to what was scheduled, the controller may turn this off and resume scheduled behavior. .. maybe?
    - name: "Pool Schedule Override"
      state: "{{ is_state_attr('sensor.pool', 'SchedOverride', '1') }}"
      icon: mdi:clock-remove-outline

# Comment out these last two for lone pool system.
    - name: "Pool Intake Valve"
      state: "{{ is_state_attr('sensor.pool', 'j2', '1') }}"
      icon: mdi:relation-many-to-zero-or-one
    - name: "Pool Return Valve"
      state: "{{ is_state_attr('sensor.pool', 'j1', '1') }}"
      icon: mdi:relation-one-to-zero-or-many


switch:
  - platform: template
    switches:
## Uncomment for lone pool system
#      pool:
#        friendly_name: "Pool"
#        value_template: "{{ is_state('sensor.pool', 'on') }}"
#        turn_on:
#          - service: shell_command.pool_toggle
#        turn_off:
#          - service: shell_command.pool_toggle
#        icon_template: "mdi:waves"
## Comment out next three (pool_mode,spillover_mode,spa_mode) for lone pool system
      pool_mode:
        friendly_name: "Pool"
        value_template: "{{ is_state_attr('sensor.pool', 'Mode', 'Pool') }}"
        turn_on:
          - service: shell_command.pool_mode
        turn_off:
          - service: shell_command.off_mode
        icon_template: "mdi:waves"
      spillover_mode:
        friendly_name: "Spillover"
        value_template: "{{ is_state_attr('sensor.pool', 'Mode', 'Spillover') }}"
        turn_on:
          - service: shell_command.spillover_mode
        turn_off:
          - service: shell_command.off_mode
        icon_template: "mdi:waterfall"
      spa_mode:
        friendly_name: "Spa"
        value_template: "{{ is_state_attr('sensor.pool', 'Mode', 'Spa') }}"
        turn_on:
          - service: shell_command.spa_mode
        turn_off:
          - service: shell_command.off_mode
        icon_template: "mdi:hot-tub"
      pool_heat:
        friendly_name: "Heat"
        value_template: "{{ is_state_attr('sensor.pool', 'Heat', '1') }}"
        turn_on:
          - service: rest_command.pool_heat
        turn_off:
          - service: rest_command.pool_heat
        icon_template: "mdi:hot-tub"
      spa_light:
        friendly_name: "Spa Light"
        value_template: "{{ is_state_attr('sensor.pool', 'aux1', '1') }}"
        turn_on:
          - service: rest_command.pool_aux1
        turn_off:
          - service: rest_command.pool_aux1
        icon_template: mdi:lightbulb
      pool_solar:
        friendly_name: "Pool Solar"
        value_template: "{{ is_state_attr('sensor.pool', 'j3', '1') }}"
        turn_on:
          - service: rest_command.pool_j3
        turn_off:
          - service: rest_command.pool_j3
        icon_template: "mdi:weather-sunny"

shell_command:
# Uncomment for lone pool system (and the applicable switch below)
#  pool_toggle: "/config/waterway/setpool.sh poolmode 1"
# Comment out these four for lone pool system (and the applicable switches below)
##
# ! These are bad names. Prepend with "pool_". Even if that makes "pool_pool_mode"
##
  off_mode: "/config/waterway/setpool.sh poolmode {{ ((state_attr('sensor.pool','ModeNumber')|int*-1)+0)%4 }}"
  pool_mode: "/config/waterway/setpool.sh poolmode {{ ((state_attr('sensor.pool','ModeNumber')|int*-1)+1)%4 }}"
  spillover_mode: "/config/waterway/setpool.sh poolmode {{ ((state_attr('sensor.pool','ModeNumber')|int*-1)+2)%4 }}"
  spa_mode: "/config/waterway/setpool.sh poolmode {{ ((state_attr('sensor.pool','ModeNumber')|int*-1)+3)%4 }}"
#  set_pool_heat_temp: "/config/waterway/setpool.sh settemp {{ value }}"
  
rest_command:
  pool_mode:
    url: "http://{{states('input_text.poolctrlip')}}/index.htm?txtValue=%24A0%2C6%2C17%2C%21%2CAA%2C55"
  set_pool_heat_temp:
    url: "http://{{states('input_text.poolctrlip')}}/index.htm?txtValue=%24O8%2C6%2C2C%2C{{ '%0X' | format(states('number.pool_heat_temp')|int) }}%2C%21%2CAA%2C55"
  pool_heat:
    url: "http://{{states('input_text.poolctrlip')}}/index.htm?txtValue=%24A0%2C6%2C15%2C%21%2CAA%2C55"
  pool_aux1:
    url: "http://{{states('input_text.poolctrlip')}}/index.htm?txtValue=%24A0%2C6%2C02%2C%21%2CAA%2C55"
  pool_aux2:
    url: "http://{{states('input_text.poolctrlip')}}/index.htm?txtValue=%24A0%2C6%2C03%2C%21%2CAA%2C55"
  pool_aux3:
    url: "http://{{states('input_text.poolctrlip')}}/index.htm?txtValue=%24A0%2C6%2C04%2C%21%2CAA%2C55"
  pool_aux4:
    url: "http://{{states('input_text.poolctrlip')}}/index.htm?txtValue=%24A0%2C6%2C05%2C%21%2CAA%2C55"
  pool_aux5:
    url: "http://{{states('input_text.poolctrlip')}}/index.htm?txtValue=%24A0%2C6%2C06%2C%21%2CAA%2C55"
  pool_aux6:
    url: "http://{{states('input_text.poolctrlip')}}/index.htm?txtValue=%24A0%2C6%2C07%2C%21%2CAA%2C55"
  pool_aux7:
    url: "http://{{states('input_text.poolctrlip')}}/index.htm?txtValue=%24A0%2C6%2C08%2C%21%2CAA%2C55"
  pool_aux8:
    url: "http://{{states('input_text.poolctrlip')}}/index.htm?txtValue=%24A0%2C6%2C09%2C%21%2CAA%2C55"
  pool_aux9:
    url: "http://{{states('input_text.poolctrlip')}}/index.htm?txtValue=%24A0%2C6%2C0A%2C%21%2CAA%2C55"
  pool_j1:
    url: "http://{{states('input_text.poolctrlip')}}/index.htm?txtValue=%24A0%2C6%2C0B%2C%21%2CAA%2C55"
  pool_j2:
    url: "http://{{states('input_text.poolctrlip')}}/index.htm?txtValue=%24A0%2C6%2C0C%2C%21%2CAA%2C55"
  pool_j3:
    url: "http://{{states('input_text.poolctrlip')}}/index.htm?txtValue=%24A0%2C6%2C0D%2C%21%2CAA%2C55"
  pool_j4:
    url: "http://{{states('input_text.poolctrlip')}}/index.htm?txtValue=%24A0%2C6%2C0E%2C%21%2CAA%2C55"
# Changing the time causes the system to hang for a bit. I think something needs to reload on the board afterward.
  pool_set_time:
    url: "http://{{states('input_text.poolctrlip')}}/index.htm?txtValue={{now().strftime('%%24S6%%2C6%%2CD%%2C%y%%2C%m%%2C%d%%2CW%%2C%w%%2CT%%2C%H%%2C%M%%2C%S%%2C%%21%%2CAA%%2C55')}}"
