/*
 **
 ** Source file generated on апреля 23, 2025 at 13:30:04.	
 **
 ** Copyright (C) 2011-2025 Analog Devices Inc., All Rights Reserved.
 **
 ** This file is generated automatically based upon the options selected in 
 ** the Pin Multiplexing configuration editor. Changes to the Pin Multiplexing
 ** configuration should be made by changing the appropriate options rather
 ** than editing this file.
 **
 ** Selected Peripherals
 ** --------------------
 ** SPORT0 (ACLK, AFS, AD0, AD1, BCLK, BFS, BD0, BD1)
 ** SPORT1 (BCLK, BFS, BD0, BD1)
 **
 ** GPIO (unavailable)
 ** ------------------
 ** PB04, PB05, PB07, PB08, PB09, PB10, PB11, PB12, PE00, PE01, PE03, PE04
 */

#include <sys/platform.h>
#include <stdint.h>

#define SPORT0_ACLK_PORTB_MUX  ((uint16_t) ((uint16_t) 2<<10))
#define SPORT0_AFS_PORTB_MUX  ((uint16_t) ((uint16_t) 2<<8))
#define SPORT0_AD0_PORTB_MUX  ((uint32_t) ((uint32_t) 2<<18))
#define SPORT0_AD1_PORTB_MUX  ((uint32_t) ((uint32_t) 2<<24))
#define SPORT0_BCLK_PORTB_MUX  ((uint32_t) ((uint32_t) 2<<16))
#define SPORT0_BFS_PORTB_MUX  ((uint16_t) ((uint16_t) 2<<14))
#define SPORT0_BD0_PORTB_MUX  ((uint32_t) ((uint32_t) 2<<22))
#define SPORT0_BD1_PORTB_MUX  ((uint32_t) ((uint32_t) 2<<20))
#define SPORT1_BCLK_PORTE_MUX  ((uint16_t) ((uint16_t) 2<<8))
#define SPORT1_BFS_PORTE_MUX  ((uint16_t) ((uint16_t) 2<<6))
#define SPORT1_BD0_PORTE_MUX  ((uint16_t) ((uint16_t) 2<<2))
#define SPORT1_BD1_PORTE_MUX  ((uint16_t) ((uint16_t) 2<<0))

#define SPORT0_ACLK_PORTB_FER  ((uint16_t) ((uint16_t) 1<<5))
#define SPORT0_AFS_PORTB_FER  ((uint16_t) ((uint16_t) 1<<4))
#define SPORT0_AD0_PORTB_FER  ((uint32_t) ((uint32_t) 1<<9))
#define SPORT0_AD1_PORTB_FER  ((uint32_t) ((uint32_t) 1<<12))
#define SPORT0_BCLK_PORTB_FER  ((uint32_t) ((uint32_t) 1<<8))
#define SPORT0_BFS_PORTB_FER  ((uint16_t) ((uint16_t) 1<<7))
#define SPORT0_BD0_PORTB_FER  ((uint32_t) ((uint32_t) 1<<11))
#define SPORT0_BD1_PORTB_FER  ((uint32_t) ((uint32_t) 1<<10))
#define SPORT1_BCLK_PORTE_FER  ((uint16_t) ((uint16_t) 1<<4))
#define SPORT1_BFS_PORTE_FER  ((uint16_t) ((uint16_t) 1<<3))
#define SPORT1_BD0_PORTE_FER  ((uint16_t) ((uint16_t) 1<<1))
#define SPORT1_BD1_PORTE_FER  ((uint16_t) ((uint16_t) 1<<0))

int32_t adi_initpinmux(void);

/*
 * Initialize the Port Control MUX and FER Registers
 */
int32_t adi_initpinmux(void) {
    /* PORTx_MUX registers */
    *pREG_PORTB_MUX = SPORT0_ACLK_PORTB_MUX | SPORT0_AFS_PORTB_MUX
     | SPORT0_AD0_PORTB_MUX | SPORT0_AD1_PORTB_MUX | SPORT0_BCLK_PORTB_MUX
     | SPORT0_BFS_PORTB_MUX | SPORT0_BD0_PORTB_MUX | SPORT0_BD1_PORTB_MUX;
    *pREG_PORTE_MUX = SPORT1_BCLK_PORTE_MUX | SPORT1_BFS_PORTE_MUX
     | SPORT1_BD0_PORTE_MUX | SPORT1_BD1_PORTE_MUX;

    /* PORTx_FER registers */
    *pREG_PORTB_FER = SPORT0_ACLK_PORTB_FER | SPORT0_AFS_PORTB_FER
     | SPORT0_AD0_PORTB_FER | SPORT0_AD1_PORTB_FER | SPORT0_BCLK_PORTB_FER
     | SPORT0_BFS_PORTB_FER | SPORT0_BD0_PORTB_FER | SPORT0_BD1_PORTB_FER;
    *pREG_PORTE_FER = SPORT1_BCLK_PORTE_FER | SPORT1_BFS_PORTE_FER
     | SPORT1_BD0_PORTE_FER | SPORT1_BD1_PORTE_FER;
    return 0;
}

