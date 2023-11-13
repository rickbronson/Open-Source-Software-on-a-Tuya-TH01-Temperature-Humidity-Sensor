all: read

get:
	git clone --recursive https://github.com/openshwprojects/OpenBK7231T; cd OpenBK7231N/apps; git clone https://github.com/openshwprojects/OpenBK7231T_App

read:
	python3 hid_download_py/uartprogram firmware.bin -r # -l 1220608

flash_factory:
	python3 hid_download_py/uartprogram firmware.bin -u -w -s 0x11000 -b 460800

flash_downloaded:
	python3 hid_download_py/uartprogram OpenBK7231N_QIO_1.17.301.bin -u -d /dev/ttyUSB0 -w -s 0x0 -b 460800

flash:
	python3 hid_download_py/uartprogram OpenBK7231T/apps/OpgenBK7231T_App/output/1.0.0/OpenBK7231T_App_1.0.0.bin -u -d /dev/ttyUSB0 -w -s 0x0 -b 460800
#	python3 hid_download_py/uartprogram OpenBK7231T/apps/OpenBK7231T_App/output/1.0.0/OpenBK7231T_App_1.0.0.bin --unprotect -d /dev/ttyUSB0 -w --startaddr 0x0

build:
	cd OpenBK7231N; ./build_app.sh apps/OpenBK7231N_App OpenBK7231N_App 1.0.0
#	cd OpenBK7231N; sh build_app.sh apps/tuya_demo_template tuya_demo_template 1.0.0

clean:
	cd OpenBK7231N; ./build_app.sh apps/OpenBK7231N_App OpenBK7231N_App 1.0.0 clean

github-init:
	gh repo create 'Open Source Software on a Tuya TH01 Temperature Humidity Sensor' --public
	rm -rf .git
	git init
	git add Makefile docs/hardware/NP2302fvr_E.PDF docs/hardware/CB3S-datasheet.pdf docs/hardware/AHT20-datasheet-2020-4-16.pdf docs/hardware/Tuya-WiFi-Module.pdf docs/hardware/ITM-7231N-BK-Datasheet_V0.3_20211105.pdf docs/hardware/tuya-temp-humidity-photo.png docs/hardware/tuya-temp-humidity-hookup2.png docs/hardware/tuya-temp-humidity8.png docs/hardware/tuya-temp-humidity-wiring1.png docs/hardware/OpenBK-config-mqtt-page.png ./README.md 
	git commit -m "first commit"
	git remote add origin https://github.com/rickbronson/Open-Source-Software-on-a-Tuya-TH01-Temperature-Humidity-Sensor.git
# /snap/bin/gh auth login --with-token < ~/.ssh/id_ed25519.pub 
# go here https://github.com/settings/tokens and get a new tokin and use this as the password on the next step, NOTE: you need to enable several permissions on this page!
#	git push -u origin master

github-update:
	git commit -a -m 'update README'
	git push -u origin master

