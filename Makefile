ifeq '$(findstring ;,$(PATH))' ';'
    detected_OS := Windows
else
    detected_OS := $(shell uname 2>/dev/null || echo Unknown)
    detected_OS := $(patsubst CYGWIN%,Cygwin,$(detected_OS))
    detected_OS := $(patsubst MSYS%,MSYS,$(detected_OS))
    detected_OS := $(patsubst MINGW%,MSYS,$(detected_OS))
endif

ifeq ($(detected_OS),Darwin)
	JAVA=`which java`
	KICKASM_JAR=~/bin/KickAssembler/KickAss.jar
	KICKASS_CMD=$(JAVA) -jar $(KICKASM_JAR) -vicesymbols -symbolfile -debugdump $<
	REMOVE=rm -f
	EMULATOR=`which x64sc`
	IMAGE2C64=`which image2c64`
	ZIP=`which zip`
else ifeq ($(detected_OS),Linux)
	JAVA=`which java`
	KICKASM_JAR=/c64/bin/kickassembler/KickAss.jar
	KICKASS_CMD=$(JAVA) -jar $(KICKASM_JAR) -vicesymbols -symbolfile -debugdump $<
	REMOVE=rm -f
	EMULATOR=`which x64sc`
	IMAGE2C64=`which image2c64`
	ZIP=`which zip`
else
	JAVA=`which java`
	KICKASM_JAR=~/bin/KickAssembler/KickAss.jar
	KICKASS_CMD=$(JAVA) -jar $(KICKASM_JAR) -vicesymbols -symbolfile -debugdump $<
	REMOVE=del /q
	EMULATOR=`which x64sc`
	IMAGE2C64=`which image2c64`
	ZIP=`which zip`
endif

BINARIES=sym vs dbg prg d64
IMAGENAME=are-you-extended

all: clean obj $(IMAGENAME) picture/$(IMAGENAME).zip

obj/are-you-extended.kla: obj images/$(IMAGENAME).png
	export
	$(IMAGE2C64) --background 0 -e fix -v -f koala images/$(IMAGENAME).png -o obj/$(IMAGENAME).kla


obj:
	mkdir -p obj

picture:
	mkdir -p picture

run: all
	$(EMULATOR) -autostart-warp -moncommands obj/$(IMAGENAME).vs obj/$(IMAGENAME).prg

obj/$(IMAGENAME).prg: src/$(IMAGENAME).asm src/utils.asm obj/$(IMAGENAME).kla
	$(KICKASS_CMD) -o obj/$(IMAGENAME).prg

$(IMAGENAME): obj/$(IMAGENAME).prg

picture/$(IMAGENAME).zip: obj/$(IMAGENAME).prg picture
	zip $@ $<

clean:
	rm -rf obj
	rm -rf picture
	for ext in $(BINARIES); do \
		$(REMOVE) *.$$ext; \
	done
