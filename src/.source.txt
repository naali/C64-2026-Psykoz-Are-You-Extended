.filenamespace MyGuardian
// https://codebase64.org/doku.php?id=base:c64_grafix_files_specs_list_v0.03
.const KOALA_TEMPLATE = "C64FILE, Bitmap = $0000, ScreenRam = $1f40, ColorRam = $2328, BackgroundColor = $2710"
.var pictureOdd = LoadBinary("../obj/are-you-extended.kla", KOALA_TEMPLATE)

#import "utils.asm"

.const debug = false

.var peptoRGB = List().add(
    $000000, // 0
    $FFFFFF, // 1
    $68372B, // 2
    $70A4B2, // 3
    $6F3D86, // 4
    $588D43, // 5
    $352879, // 6
    $B8C76F, // 7
    $6F4F25, // 8
    $433900, // 9
    $9A6759, // 10
    $444444, // 11
    $6C6C6C, // 12
    $9AD284, // 13
    $6C5EB5, // 14
    $959595 // 15
)
.var palette = createPalette(peptoRGB)

.const rasterColorsLeft = createRasterTable("../images/are-you-extended_rasters-left.png", palette, true)
.const rasterColorsRight = createRasterTable("../images/are-you-extended_rasters-right.png", palette, false)

.print "Allocating VIC for Sprite line 1 / odd"
.var vic_spriteLine1 = getVICStruct(1, 1, 0)
.eval printVICStruct(vic_spriteLine1)

.print "Allocating VIC for Sprite line 1 / even"
.var vic_spriteLine1Even = getVICStruct(2, 1, 0)
.eval printVICStruct(vic_spriteLine1Even)

.var spriteLine1Colors = List()

.print "Allocating VIC for Sprite line 2 / odd"
.var vic_spriteLine2 = getVICStruct(1, 1, 2)
.eval printVICStruct(vic_spriteLine2)

.print "Allocating VIC for Sprite line 2 / even"
.var vic_spriteLine2Even = getVICStruct(2, 1, 2)
.eval printVICStruct(vic_spriteLine2Even)

.var spriteLine2Colors = List()

.print "Allocating VIC for Sprite line 3 / odd"
.var vic_spriteLine3 = getVICStruct(1, 1, 4)
.eval printVICStruct(vic_spriteLine3)

.print "Allocating VIC for Sprite line 3 / even"
.var vic_spriteLine3Even = getVICStruct(2, 1, 4)
.eval printVICStruct(vic_spriteLine3Even)

.var spriteLine3Colors = List()

.print "Allocating VIC for Sprite line 4 / odd"
.var vic_spriteLine4 = getVICStruct(1, 1, 6)
.eval printVICStruct(vic_spriteLine4)

.print "Allocating VIC for Sprite line 4 / even"
.var vic_spriteLine4Even = getVICStruct(2, 1, 6)
.eval printVICStruct(vic_spriteLine4Even)
.var spriteLine4Colors = List()

.const rasterPrecalcBegin = $1000
.const colorRamTempBegin = $2A00
.const codeBegin = $3000

.const colorRamBegin = $d800

.const spriteMultiColor1_top = 15        // $B8C76F
.const spriteMultiColor2_top = 13       // $9A6759

.const spriteMultiColor1_bottom = 15     // $B8C76F
.const spriteMultiColor2_bottom = 13    // $9A6759

.const imageBackgroundColor = 0
.const imageBorderColor = 3

.const imageTopBorderColor = 15
.const imageBottomBorderColor = 15       // $68372B

.const irqStartLine = 0

.const spriteLine1SetupLine = 1
.const spriteLine1PosY = 8

.const spriteLine2SetupLine = 27
.const spriteLine2PosY = spriteLine1PosY + 21

.const backgroundColorSetupLine = 50

.const spriteLine3SetupLine = 248
.const spriteLine3PosY = 250

.const spriteLine4SetupLine = spriteLine3SetupLine + 21
.const spriteLine4PosY = spriteLine3PosY + 21

.const backgroundColorRestoreLine = spriteLine4PosY + 3

.const HScroll = %00000011

.macro insertSpritePointers(vicStruct, firstSpriteIndex, count) {
    .for (var i = 0; i < count; i++) {
        .byte (vicStruct.spriteRamBegin / 64) + i + firstSpriteIndex
    }
}

.const SprBGC_top = $15 // Sprite background color
.const ComSC1_top = peptoRGB.get(15) // $B8C76F // Common sprite color 1
.const ComSC2_top = peptoRGB.get(13) // $9A6759 // Common sprite color 2

.const SprBGC_bottom = peptoRGB.get(0) // Sprite transparent color
.const ComSC1_bottom = peptoRGB.get(7) // $B8C76F // Common sprite color 1
.const ComSC2_bottom = peptoRGB.get(10) // $9A6759 // Common sprite color 2

* = vic_spriteLine1.bitmapRamBegin "Bitmap Ram Odd"
    .fill pictureOdd.getBitmapSize(), pictureOdd.getBitmap(i)

* = colorRamTempBegin "Color Ram temp"
    .fill pictureOdd.getColorRamSize(), pictureOdd.getColorRam(i)

* = vic_spriteLine1.screenRamBegin "Screen Ram 1 Odd"
    .fill pictureOdd.getScreenRamSize(), pictureOdd.getScreenRam(i)

* = vic_spriteLine1.spritePtrBegin "Sprite Pointers 1 Odd"
    insertSpritePointers(vic_spriteLine1, 16, 8)

* = vic_spriteLine1.screenRamBegin + $400 "Sprites 1 Odd"
loadMultiColorSprite("../images/sprites/are-you-extended_sprite01.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine1Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite02.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine1Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite03.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine1Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite04.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine1Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite05.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine1Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite06.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine1Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite07.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine1Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite08.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine1Colors)

* = vic_spriteLine2.screenRamBegin "Screen Ram 2 Odd"
    .fill pictureOdd.getScreenRamSize(), pictureOdd.getScreenRam(i)

* = vic_spriteLine2.spritePtrBegin "Sprite Pointers 2 Odd"
    insertSpritePointers(vic_spriteLine2, 16, 8)

* = vic_spriteLine2.screenRamBegin + $400 "Sprites 2 Odd"
loadMultiColorSprite("../images/sprites/are-you-extended_sprite09.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine2Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite10.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine2Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite11.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine2Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite12.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine2Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite13.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine2Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite14.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine2Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite15.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine2Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite16.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine2Colors)

* = vic_spriteLine3.screenRamBegin "Screen Ram 3 Odd"
    .fill pictureOdd.getScreenRamSize(), pictureOdd.getScreenRam(i)

* = vic_spriteLine3.spritePtrBegin "Sprite Pointers 3 Odd"
    insertSpritePointers(vic_spriteLine3, 16, 8)

* = vic_spriteLine3.screenRamBegin + $400 "Sprites 3 Odd"
loadMultiColorSprite("../images/sprites/are-you-extended_sprite17.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine3Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite18.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine3Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite19.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine3Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite20.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine3Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite21.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine3Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite22.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine3Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite23.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine3Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite24.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine3Colors)

* = vic_spriteLine4.screenRamBegin "Screen Ram 4 Odd"
    .fill pictureOdd.getScreenRamSize(), pictureOdd.getScreenRam(i)

* = vic_spriteLine4.spritePtrBegin "Sprite Pointers 4 Odd"
    insertSpritePointers(vic_spriteLine4, 16, 8)

* = vic_spriteLine4.screenRamBegin + $400 "Sprites 4 Odd"
loadMultiColorSprite("../images/sprites/are-you-extended_sprite25.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine4Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite26.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine4Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite27.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine4Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite28.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine4Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite29.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine4Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite30.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine4Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite31.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine4Colors)
loadMultiColorSprite("../images/sprites/are-you-extended_sprite32.png", SprBGC_top, ComSC1_top, ComSC2_top, $000000, spriteLine4Colors)

:BasicUpstart2(startup)

* = codeBegin "Code"
startup: {
        sei
        waitUntilLine($80)

        ora #vic_spriteLine1.DD00_config
        sta $dd00

        lda #%00011000 // 40 columns, multicolor mode
        sta $d016

        lda #(%00111000 | HScroll) // Bitmapmode, screen on, 25 rows
        sta $d011

        lda #imageBackgroundColor
        sta $d020
        sta $d021

        lda #0
        sta vic_spriteLine1.vicRamEnd

        cli

        jsr copyColorMemory

        lda #%11111111   // Set sprites multicolor
        sta $d01c

        lda #%00000000
        sta $d01d        // No x stretch
        sta $d017        // No y stretch

        sei
		:SetupIRQ(irqStart, irqStartLine)
        cli

looppi:
        jmp looppi

}

copyColorMemory: {
    !loop:
        .for (var i = 0; i < 4; i++) {
            lda colorRamTempBegin + i * $100, x
            sta colorRamBegin + i * $100, x
        }

        inx
        bne !loop-
    rts
}

.align $100
irqStart: {
    sta ra 
    stx rx 
    sty ry

    DebugRaster(BLUE)

    lda #vic_spriteLine1.D018_config
    sta $d018

    lda #(%00111000 | HScroll)
    sta $d011

    lda #%11111111 // set sprites 0-7 on
    sta $d015

    DebugRaster(BLACK)

    lda #imageTopBorderColor
    sta $d020
    sta $d021

    EndIRQ(irqSpriteLine1SetupLine, spriteLine1SetupLine)

    lda ra:#$00
    ldx rx:#$00
    ldy ry:#$00

    rti
}

.align $100
irqSpriteLine1SetupLine: {
    sta ra 
    stx rx 
    sty ry

    DebugRaster(YELLOW)


    lda #(%00111000 | HScroll)
    sta $d011

    lda #vic_spriteLine1.D018_config
    sta $d018

    // Sprite Y positions
    lda #(spriteLine1PosY)
.for (var i = 0; i < 8; i++) {
    sta $d001 + i * 2
}

.var spriteXoffs = 86
.var spriteXpositions = List().add(0 * 24, 1 * 24, 2 * 24, 3 * 24, 4 * 24, 5 * 24, 6 * 24, 7 * 24)
.for (var i = 0; i < 8; i++) {
    lda #((spriteXpositions.get(i) + spriteXoffs) & 255)
    sta $d000 + i * 2
}

    lda #%00000000           // sprites 5 - 7 x pos is > 255...
    sta $d010

.for (var i = 0; i < 8; i++) {
    lda #spriteLine1Colors.get(i)
    sta $d027 + i
}

    lda #spriteMultiColor1_top
    sta $d025

    lda #spriteMultiColor2_top
    sta $d026

    DebugRaster(BLACK)

    EndIRQ(irqSpriteLine2SetupLine, spriteLine2SetupLine)

    lda ra:#$00
    ldx rx:#$00
    ldy ry:#$00

    lda #$01
    sta $d019

    rti
}

.align $100
irqSpriteLine2SetupLine: {
    sta ra
    stx rx
    sty ry

    // Sprite Y positions
    lda #spriteLine2PosY
.for (var i = 0; i < 8; i++) {
    sta $d001 + i * 2
}

.for (var i = 0; i < 8; i++) {
    lda #spriteLine2Colors.get(i)
    sta $d027 + i
}

    lda #vic_spriteLine2.D018_config
    sta $d018

    EndIRQ(irqBackgroundColorSetupLine, backgroundColorSetupLine)

    lda ra:#$00
    ldx rx:#$00
    ldy ry:#$00

    rti
}


.align $100
irqBackgroundColorSetupLine: {
    sta ra
    stx rx
    sty ry

    spendTime(18)

    lda #%00000000 // set sprites 0-7 off
    sta $d015

    lda #imageBackgroundColor
    sta $d021

    stableIRQ()

    jsr rasterPrecalc

.for (var i = 0; i < 8; i++) {
    lda #spriteLine3Colors.get(i)
    sta $d027 + i
}
    lda #spriteMultiColor1_bottom
    sta $d025

    lda #spriteMultiColor2_bottom
    sta $d026

    EndIRQ(irqSpriteLine3SetupLine, spriteLine3SetupLine)

    lda #$01
    sta $d019

    lda ra:#$00
    ldx rx:#$00
    ldy ry:#$00

//    lsr $d019 		// clear the interrupt
    inc 0	// back to 2f

    rti
}

.align $100
irqSpriteLine3SetupLine: {
    sta ra 
    stx rx 
    sty ry

    // Sprite Y positions
    lda #(spriteLine3PosY)
.for (var i = 0; i < 8; i++) {
    sta $d001 + i * 2
}

    lda #(%00110000 | HScroll)
    sta $d011

    spendTime(5)

    lda #vic_spriteLine3.D018_config
    sta $d018

    lda #%11111111 // set sprites 0-7 on
    sta $d015

    lda #%00000000          // sprite x pos high bits
    sta $d010

.var spriteXoffs = 22
.var spriteXpositions = List().add(
    0 * 24, 
    1 * 24, 
    2 * 24, 
    3 * 24, 
    4 * 24 + 32, 
    5 * 24 + 32, 
    6 * 24 + 32, 
    7 * 24 + 32
)

.for (var i = 0; i < 8; i++) {
    lda #((spriteXpositions.get(i) + spriteXoffs) & 255)
    sta $d000 + i * 2
}

    EndIRQ(irqSpriteLine4SetupLine, spriteLine4SetupLine)

    lda #imageBottomBorderColor
    sta $d021

    lda #$01
    sta $d019

    lda ra:#$00
    ldx rx:#$00
    ldy ry:#$00

//    lsr $d019

    rti
}

.align $100
irqSpriteLine4SetupLine: {
    sta ra 
    stx rx 
    sty ry

    // Sprite Y positions
    lda #spriteLine4PosY
.for (var i = 0; i < 8; i++) {
    sta $d001 + i * 2
}

    spendTime(36)

    lda #vic_spriteLine4.D018_config
    sta $d018

    spendTime((3 + 2) * 8) // Spending some time since we're not setting colors again to the same values...
    
/*
.for (var i = 0; i < 8; i++) {
    lda #spriteLine4Colors.get(i)
    sta $d027 + i
}
*/
    lda #%00000000 // sprites off
    sta $d015

//    EndIRQ(irqStart, irqStartLine)
    EndIRQ(irqBackgroundColorRestoreLine, 307)

    lda #$01
    sta $d019

    lda ra:#$00
    ldx rx:#$00
    ldy ry:#$00

//    lsr $d019

    rti
}

.align $100
irqBackgroundColorRestoreLine: {
    sta ra 
    stx rx 
    sty ry

    stableIRQ()

    spendTime(44)

    lda #imageTopBorderColor
    sta $d020
    sta $d021

    EndIRQ(irqStart, irqStartLine)

//    lda #$01
//    sta $d019

    lda #$01
    sta $d019

    lda ra:#$00
    ldx rx:#$00
    ldy ry:#$00

//    lsr $d019
    inc 0	        // back to 2f
    
    rti
}


.macro DebugRaster(color) {
	.if (debug) {
		pha
		lda #0 + color
		sta $d020
		pla
	}
}

.macro loadSingleColorSprite(filename, transparent, color1, colorList) {
    .var usedColors = Hashtable()
    .var hasErrors = false
    .var sprite = LoadPicture(filename, List().add(transparent, color1))

    .for (var y = 0; y < 21; y++) {
        .for (var x = 0; x < 3; x++) {
            .var value = 0

            .for (var xinner = 0; xinner < 8; xinner++) {
                .var color = sprite.getPixel(x * 8 + xinner, y)

                .var colorUseCount = usedColors.get(color)
                .if (colorUseCount == null) {
                    .eval colorUseCount = 0
                }
                .eval usedColors.put(color, colorUseCount + 1)

                .if (color == transparent) {
                    // Transparent color
                    .eval value = (value << 1) | %0

                } else .if (color == color1) {
                    // Sprite color
                    .eval value = (value << 1) | %1

                } else {
                    .print "Unknown color in single color sprite " + filename + " x: " + (x * 8 + xinner * 2) + ", y:" + y + " $" + toHexString(color, 6)
                    .eval value = (value << 1) | %1
                    .eval hasErrors = true
                }
            }

            .byte value

        }
    }

    .byte 0 // Padding

    .if (hasErrors == true) {
        .var colorKeys = usedColors.keys()
        .var colorStr = "Used colors: "
        .for (var i = 0; i < colorKeys.size(); i++) {
            .var color = colorKeys.get(i).asNumber()
            .var useCount = usedColors.get(color)
            .eval colorStr += "$" + toHexString(color, 6) + ": " + useCount
            .if (i < colorKeys.size() - 1) {
                .eval colorStr += ", "
            }
        }

        .print colorStr
    }    

    .eval colorList.add(palette.get(color1))
}

.macro loadMultiColorSprite(filename, color, color2, color3, color4, colorList) {
    loadMultiColorSpriteWithForcedC4(filename, color, color2, color3, color4, color4, colorList)
}

.macro loadMultiColorSpriteWithForcedC4(filename, color1, color2, color3, color4, forcedToC4, colorList) {
    .var forceC4 = (forcedToC4 != color1)

    .var usedColors = Hashtable()
    .var hasErrors = false
    .var sprite = LoadPicture(filename, List().add(color1, color2, color3, color4))
    .for (var y = 0; y < 21; y++) {
        .for (var x = 0; x < 3; x++) {
            .var value = 0

            .for (var xinner = 0; xinner < 4; xinner++) {
                .var color = sprite.getPixel(x * 8 + xinner * 2, y)
                .var nextColor = sprite.getPixel(x * 8 + xinner * 2 + 1, y)

                .if (forceC4) {
                    .if (color == forcedToC4) { .eval color = color4 }
                    .if (nextColor == forcedToC4) { .eval nextColor = color4 }
                }

                .var colorUseCount = usedColors.get(color)
                .if (colorUseCount == null) {
                    .eval colorUseCount = 0
                }
                .eval usedColors.put(color, colorUseCount + 1)

                .eval colorUseCount = usedColors.get(nextColor)
                .if (colorUseCount == null) {
                    .eval colorUseCount = 0
                }
                .eval usedColors.put(nextColor, colorUseCount + 1)

                .if (color != nextColor) {
                    .print "Non-matching consecutive colors in multicolor sprite " + filename + " x: " + (x * 8 + xinner * 2) + ", y:" + y + " $" + toHexString(color, 6) + " and $" + toHexString(nextColor, 6)
                }

//                .eval value = (value << 2) | %10

                .if (color == color1) {
                    // Transparent color
                    .eval value = (value << 2) | %00 // läpi

                } else .if (color == color2) {
                    // Color from $d025 (SpriteMultiColor1)
                    .eval value = (value << 2) | %01 // keltane

                } else .if (color == color3) {
                    // Color from $d025 (SpriteMultiColor1)
                    .eval value = (value << 2) | %11 // marjapuuro

                } else .if (color == color4) {
                    // Per sprite color                    
                    .eval value = (value << 2) | %10 // custom

                } else {
                    .print "Unknown color in multicolor sprite " + filename + " x: " + (x * 8 + xinner * 2) + ", y:" + y + " $" + toHexString(color, 6)
                    .print "color1: $" + toHexString(color1, 6)
                    .print "color2: $" + toHexString(color2, 6)
                    .print "color3: $" + toHexString(color3, 6)
                    .print "color4: $" + toHexString(color4, 6)
                    .eval value = (value << 2) | %11
                    .eval hasErrors = true
                }
            }

            .byte value
//            .byte %10101010

        }        
    }
    .byte 0 // padding

    .if (hasErrors == true) {
        .var colorKeys = usedColors.keys()
        .var colorStr = "Used colors: "
        .for (var i = 0; i < colorKeys.size(); i++) {
            .var color = colorKeys.get(i).asNumber()
            .var useCount = usedColors.get(color)
            .eval colorStr += "$" + toHexString(color, 6) + ": " + useCount
            .if (i < colorKeys.size() - 1) {
                .eval colorStr += ", "
            }
        }

        .print colorStr
    }

    .eval colorList.add(palette.get(color4))
}

* = rasterPrecalcBegin "Raster precalc"
rasterPrecalc: {
    spendTime(23 - 4)
    ldx #0

    .for (var i = 0; i < 190; i++) {
        .var isBadLine = (mod(i + 3, 8) == 0)

        lda #rasterColorsLeft.get(i)
        sta $d020

        lda #rasterColorsRight.get(i)

        .if (isBadLine) {
            spendTime(5)
            sta $d020
            spendTime(2 + 1)
        } else {
            spendTime(47 + 1)
            sta $d020
            spendTime(3)
        }
    }

    lda #imageBottomBorderColor
    sta $d020

    rts
}
