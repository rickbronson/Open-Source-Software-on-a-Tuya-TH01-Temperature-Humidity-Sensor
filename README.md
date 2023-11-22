  Open Source Software on a Tuya TH01 Temperature Humidity Sensor
==========================================


NOTE: This project requires:

- a fair amount of fine point soldering
- A USB-Serial converter (I used a CH340)
- an oscilloscope is helpful


As sold on Aliexpress and many other sites, the Tuya TH01 is a temperature and humidity sensor that, once configured, sends sensor data to Tuya's cloud and then back to the Smart Life on your phone.  Putting open source software on the TH01 frees it from the cloud and allows you to have more control over the data.  Many thanks to the folks at elektroda.com for the development of the open source software used here.  See https://www.elektroda.com/rtvforum/topic3968377.html for more info.

Here are the parts used on the TH01 module:

- Wi-Fi SOC Board (WiFi/Bluetooth RF module CB3S) (uses a Beken BK7231N chip)
- NP2302fvr FET
- AHT20 temperature/humidity sensor
- TuyaMCU "mystery chip" in a 16 pin NSOP package. (might be a HOLTEK but I couldn't find a pin match)
- Red Led that lights up when sending data to cloud or flashes when in Bluetooth pairing mode.
- Button that wakes up the TuyaMCU and sends data to cloud.  Also used for Bluetooth pairing. The button might be tied to a Reset/Port pin.

The TuyaMCU has control over the power to the CB3S (through the FET) and the AHT20.  In sleep mode, the TuyaMCU only draws about 6 microamps so it provides for a pretty good battery life.  It only wakes up from sleep mode every 55 mintues to send data to the cloud, this seems to take about 11 seconds or so and draws about 63ma.  According to https://oregonembedded.com/batterycalc.htm, with 2850 mAh for each alkaline battery you get about 2.5 years life.
	
Here is a photo of the board:

![alt text](https://github.com/rickbronson/Open-Source-Software-on-a-Tuya-TH01-Temperature-Humidity-Sensor/blob/master/docs/hardware/tuya-temp-humidity-photo.png "photo")

Here is a rough schematic of the board:

![alt text](https://github.com/rickbronson/Open-Source-Software-on-a-Tuya-TH01-Temperature-Humidity-Sensor/blob/master/docs/hardware/tuya-temp-humidity8.png "schematic")

Here is hookup photo showing what you need to connect:

![alt text](https://github.com/rickbronson/Open-Source-Software-on-a-Tuya-TH01-Temperature-Humidity-Sensor/blob/master/docs/hardware/tuya-temp-humidity-hookup2.png "hookup")

Steps for install on Debian 12.2:

```
sudo usermod -a -G dialout $USER
sudo apt install gcc-arm-none-eabi mosquitto mosquitto-clients git make python3-hid python3-serial python3-tqdm
sudo mosquitto_passwd -c /etc/mosquitto/passwd <user> #make user and passwd for mosquitto for testing

sudo bash -c "cat << EOF >> /etc/mosquitto/conf.d/default.conf
allow_anonymous false
password_file /etc/mosquitto/passwd
listener 1883 0.0.0.0
EOF"
sudo systemctl enable mosquitto
sudo systemctl restart mosquitto
```

  Download flashing tool:
	
```
git clone https://github.com/OpenBekenIOT/hid_download_py
```

Go to https://github.com/openshwprojects/OpenBK7231T_App/releases and download the latests release for "BK7231N 	UART Flash".  NOTE: Don't get the one for BK7231T

This step is optional and only if you want to build the source code:

```
git clone --recursive https://github.com/tuya/tuya-iotos-embeded-sdk-wifi-ble-bk7231n.git
git clone --recursive https://github.com/openshwprojects/OpenBK7231N
cd OpenBK7231N/apps
git clone https://github.com/openshwprojects/OpenBK7231T_App
mv OpenBK7231T_App OpenBK7231N_App
cd ../..
sed -i -e "s/^python /python3 /g" OpenBK7231N/platforms/bk7231n/bk7231n_os/build.sh
```

 - Hook up for board using the "hookup" photo above
 - Before you do the following step you need to have your hand on the switch in the hookup photo above and reset the CB3S and then within about 1/2 second perform the following step:

```
python3 hid_download_py/uartprogram OpenBK7231N_QIO_1.17.301.bin -u -d /dev/ttyUSB0 -w -s 0x0 -b 460800
```

Sometimes it takes a few times before you get it to program.
	
  Once programmed, it will start an Access Point called "OpenBK7231N_????????". Connect to it and then, with a browser, go to 192.168.4.1 and setup WiFi so it connects to your router.  Log into your router to figure out what IP address it got (in the examples below, it's connected to my router at 192.168.2.3).	

Go to http://192.168.2.3/startup_command and set the Startup as:

```
backlog startDriver tuyaMCU; startDriver tmSensor; linkTuyaMCUOutputToChannel 1 val 1; setChannelType 1 temperature_div10; linkTuyaMCUOutputToChannel 2 val 2; setChannelType 2 Humidity;linkTuyaMCUOutputToChannel 3 val 3; setChannelType 3 ReadOnly;
```

Go to http://192.168.2.3/cfg_generic and setup:

Flags: 33, 10, 37 turned ON, and "Uptime seconds required to mark boot as ok:" from 5 to 3.

Setting up pin configuration:

Use the GPIO Mapper feature to find the pin config, got to:

```
http://192.168.2.3/app?
```

and select the "GPIO Finder" tab.  In this tab you can see when a input pin changes or change the output pin to high or low.

Testing MQTT:

I setup up the MQTT config page (on http://192.168.2.3/cfg_mqtt) like this:

![alt text](https://github.com/rickbronson/Open-Source-Software-on-a-Tuya-TH01-Temperature-Humidity-Sensor/blob/master/docs/hardware/OpenBK-config-mqtt-page.png "photo")

We are going to use a host (192.168.2.4) computer below to act as the MQTT reader.

For MQTT debug on your Host do:
```
sudo tail -f /var/log/mosquitto/mosquitto.log
```

to get temp (obTH01 is the "Client Topic"):
```
mosquitto_sub -h localhost -t "obTH01/1/get" -u <user> -P <passwd>
```

Then press the button on the board (not the switch tied to CBS3) for a very short time, the LED should flash, and you should see a value come over on the above command.

This command will add a timestamp to the one above:

```
mosquitto_sub -v -h localhost -t "obTH01/1/get" -u <user> -P <passwd> | xargs -d$'\n' -L1 bash -c 'date "+%Y-%m-%d %T.%3N $0"'
```

To see a log on the TH01 device go to

```
http://192.168.2.3/app?
```

and select the "Log" tab

When you're all done testing, disconnect the wires and put in battries.  Note that at this point you won't be able to configure it since it's only actually on for 11 seconds out of 55 minutes.  For this reason I attached a very short wire to Pin 9 of the CB3S so that I can jumper it to ground and keep the CB3S powered so that you can configure it.