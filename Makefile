.PHONY: clean tests device-tests

all: package-config

tests: 
	./tests.sh
device-tests: 
	./device-runner.sh

install: all
	install -d ipk/data/opt/bin/
	install -d ipk/data/opt/etc/package-config/
	install package-config ipk/data/opt/bin/

ipk: clean tests all
	$(MAKE) -C ipk clean
	$(MAKE) install
	$(MAKE) -C ipk
	mv ipk/*.ipk ./

clean:
	$(MAKE) -C ipk clean
	rm -rf ipk/data/opt/bin/
	rm -f *.ipk