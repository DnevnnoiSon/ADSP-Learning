/*
 **
 ** Source file generated on апреля 18, 2025 at 18:44:08.	
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
 ** SPORT1 (BCLK, BFS, BD0, BD1)
 **
 ** GPIO (unavailable)
 ** ------------------
 ** PE00, PE01, PE03, PE04
 */

#include <sys/platform.h>
#include <stdint.h>

#define SPORT1_BCLK_PORTE_MUX  ((uint16_t) ((uint16_t) 2<<8))
#define SPORT1_BFS_PORTE_MUX  ((uint16_t) ((uint16_t) 2<<6))
#define SPORT1_BD0_PORTE_MUX  ((uint16_t) ((uint16_t) 2<<2))
#define SPORT1_BD1_PORTE_MUX  ((uint16_t) ((uint16_t) 2<<0))

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
    *pREG_PORTE_MUX = SPORT1_BCLK_PORTE_MUX | SPORT1_BFS_PORTE_MUX
     | SPORT1_BD0_PORTE_MUX | SPORT1_BD1_PORTE_MUX;

    /* PORTx_FER registers */
    *pREG_PORTE_FER = SPORT1_BCLK_PORTE_FER | SPORT1_BFS_PORTE_FER
     | SPORT1_BD0_PORTE_FER | SPORT1_BD1_PORTE_FER;
    return 0;
}

