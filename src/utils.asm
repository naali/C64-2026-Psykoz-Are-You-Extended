.macro spendTime(cycles) {
    .if (cycles <  2) {
        .error "Stupid cycle count: " + cycles
    }

    .if (mod(cycles, 2) == 1) {
        bit $ea
        .eval cycles -= 3 
    }

    .for (var i = 0; i < cycles / 2; i++) {
        nop
    }
}

.struct VICBank { vicBank, bitmapBank, screenBank, vicRamStart, vicRamEnd, bitmapRamBegin, screenRamBegin, spritePtrBegin, spriteRamBegin, DD00_config, DD02_config, D018_config }
.function getVICStruct(vicBank, bitmapBank, screenBank) {
    .if (vicBank < 0 || vicBank > 3) { .error "Stupid VIC bank: " + vicBank }
    .if (bitmapBank < 0 || bitmapBank > 1) { .error "Stupid Bitmap RAM bank:" + bitmapBank}
    .if (screenBank < 0 || screenBank > 15) { .error "Stupid Screen RAM bank: " + screenBank }
    .var vb = VICBank()
    .eval vb.vicBank = vicBank
    .eval vb.bitmapBank = bitmapBank
    .eval vb.screenBank = screenBank
    .eval vb.vicRamStart = vicBank * $4000
    .eval vb.vicRamEnd = ((vicBank + 1) * $4000) - 1
    .eval vb.bitmapRamBegin = vb.vicRamStart + (bitmapBank * $2000)
    .eval vb.screenRamBegin = vb.vicRamStart + (screenBank * $400)
    .eval vb.spritePtrBegin = vb.vicRamStart + (screenBank * $400) + $03f8
    .eval vb.spriteRamBegin = screenBank * $400
    .eval vb.DD00_config = 3 - vicBank
    .eval vb.DD02_config = %00111100 | vicBank
    .eval vb.D018_config = (vb.screenBank << 4) | (vb.bitmapBank << 3)
    .return vb
}

.function printVICStruct(vicStruct) {
    .print "vicBank:" + vicStruct.vicBank
    .print "bitmapBank: " + vicStruct.bitmapBank
    .print "screenBank: " + vicStruct.screenBank
    .print "vicRamStart: $" + toHexString(vicStruct.vicRamStart)
    .print "vicRamEnd: $" + toHexString(vicStruct.vicRamEnd)
    .print "bitmapRamBegin: $" + toHexString(vicStruct.bitmapRamBegin)
    .print "screenRamBegin: $" + toHexString(vicStruct.screenRamBegin)
    .print "spritePtrBegin: $" + toHexString(vicStruct.spritePtrBegin)
    .print "spriteRamBegin: $" + toHexString(vicStruct.spriteRamBegin)
    .print "$DD00_config: $" + toHexString(vicStruct.DD00_config)
//    .print "$DD02_config (for spindle etc.): $" + toHexString(vicStruct.DD02_config)
    .print "$D018_config: $" + toHexString(vicStruct.D018_config) + @"\n"
}

.function createPalette(rgbValues) {
    .var palette = Hashtable()
    .for (var i = 0; i < rgbValues.size(); i++) {
        .eval palette.put(rgbValues.get(i), i)
    }

    .return palette
}

.function createRasterTable(filename, palette, isLeft) {
    .var image = LoadPicture(filename)
    .var column = isLeft ? 0 : (image.width - 1)

    .var rasterList = List()

    .for (var y = 3; y < image.height; y++) {
        .var pixelColor = image.getPixel(column, y)
        .if (palette.containsKey(pixelColor)) {
            .var paletteIndex = palette.get(pixelColor)
            .eval rasterList.add(paletteIndex)
        } else {
            .print "Couldn't find " + toHexString(pixelColor) + " from palette to create raster table (y = " + y + "), replacing it with black."
            .eval rasterList.add(0)
        }
    }

    .print "Created rasterlist from " + filename + " with " + rasterList.size() + " values"
    .return rasterList
}

.macro EndIRQ(nextIRQaddr, nextIRQline) {
    .const irqpointer = $fffe
    .var lineLow = nextIRQline & 255
    .var lineHigh = (nextIRQline >> 8) & 1

        asl $d019

        lda #<nextIRQaddr
        sta irqpointer
        lda #>nextIRQaddr
        sta irqpointer+1

        lda #lineLow
        sta $d012

        lda $d011
        
    .if (((nextIRQline >> 8) & 1) != 0) {
        ora #%10000000
    } else {
        and #%01111111
    }
        sta $d011

}

.macro waitUntilLine(line) {
    lda #line

!:
    cmp $d012
    bne !-
}

.macro SetupIRQ(IRQaddr, IRQline) {
    .const irqpointer = $fffe
    .var lineLow = IRQline & 255
    .var lineHigh = IRQline > 255 ? 1 : 0

        sei

        lda #<IRQaddr
        sta irqpointer
        lda #>IRQaddr
        sta irqpointer + 1

        lda #$7f        // disable cia irq's 
        sta $dc0d 
        sta $dd0d 
    
        lda #$35        // bank out kernal and basic 
        sta $01         // $e000-$ffff 

        lda #$81
        sta $d01a
        sta $d019

        lda #lineLow
        sta $d012

        lda $d011
    .if (lineHigh != 0) {
        ora #%10000000
    } else {
        and #%01111111
    }
        sta $d011

        lda #$01        // enable raster irqs 
        sta $d01a

        cli
}

.macro stableIRQ() {
			dec 0	// go from 2f to 2e

			// Set up Wedge IRQ vector
			lda #<wedgeIRQ
			sta $fffe
			lda #>wedgeIRQ
			sta $ffff

			// Set the Raster IRQ to trigger on the next Raster line
			inc $d012

            lda $d011
            and #%01111111
            sta $d011

			// Acknowlege current Raster IRQ
			lda #$01
			sta $d019

			// Store current Stack Pointer (will be messed up when the next IRQ occurs)
			tsx

			// Allow IRQ to happen (Remeber the Interupt flag is set by the Interrupt Handler).
			cli

			// Execute NOPs untill the raster line changes and the Raster IRQ triggers
			nop
			nop
			nop
			nop
			nop
			nop
			nop
			nop	// Add one extra nop for 65 cycle NTSC machines

wedgeIRQ:	txs
			ldx #$08
			dex
			bne *-1
			bit $00

			// Check if $d012 is incremented and rectify with an aditional cycle if neccessary
			lda $d012
			cmp $d012	// <- critical instruction (ZERO-Flag will indicate if Jitter = 0 or 1)
			beq *+2		// Add one cycle if $d012 wasn't incremented (Jitter / ZERO-Flag = 0)
}
