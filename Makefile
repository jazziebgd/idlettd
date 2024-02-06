buildscript: createdir generatedocs copysource

createdir: 
	mkdir build

copysource:
	cp -rf ./src/*.* ./build/
	cp -rf ./src/lang ./build/
	cp ./license.txt ./build/license.txt

generatedocs:
	doxygen

clean:
	rm -rf ./build
	