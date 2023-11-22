OUT_DIR= $(shell	if [ -d "$(HOME)/in" ] ; then \
		echo -n $(HOME)/in; else echo -n /tmp;	fi)
PROJ=OpenBK7231N
VERS=6


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
	cd OpenBK7231N; ./build_app.sh apps/OpenBK7231N_App OpenBK7231N_App 1.17.308-$(VERS)
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

diff:
#	rm -f $(OUT_DIR)/$(PROJ)-$@-$(VERS).patch; cd OpenBK7231N/apps/OpenBK7231N_App; for file in `find -L . -name "*.~1~"` ; do root_name=`echo $$file | sed -e "s|\(.*\).~1~|\1|"`;  echo "* diffing $$root_name{.~1~,}"; diff -uNr $$root_name.~1~ $$root_name >> $(OUT_DIR)/$(PROJ)-$@-$(VERS).patch; ls > /dev/null; done
	cd OpenBK7231N/apps/OpenBK7231N_App; git diff > $(OUT_DIR)/$(PROJ)-$@-$(VERS).patch
	diff -uNr autoexec.bat.~1~ autoexec.bat >> $(OUT_DIR)/$(PROJ)-$@-$(VERS).patch; ls > /dev/null
	zip $(OUT_DIR)/$(PROJ)-$@-$(VERS).patch.zip $(OUT_DIR)/$(PROJ)-$@-$(VERS).patch
	@echo -e "cd $(PROJ).orig; cat $(OUT_DIR)/$(PROJ)-$(VERS).patch | patch -b --version-control=numbered -p1 --dry-run"

patch:
	cd OpenBK7231N/apps/OpenBK7231N_App$ cat ~/boards/tuya-temp-humidity/patch1 | patch --dry-run -p1
