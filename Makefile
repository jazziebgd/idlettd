buildscript: createdir generatedocs copysource

createdir: 
	mkdir build

copysource:
	cp -rf ./src/*.* ./build/
	cp -rf ./src/lang ./build/

generatedocs:
	doxygen

clean: 
	rm -rf ./build
	