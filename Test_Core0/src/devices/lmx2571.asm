#include "sport.h"
#include "asm_def.h"
#include "defBF607.h"
#include "lmx2571.h"

.EXTERN _SPORT0B_Transmit_Data;

#define BITM_LMX_REG0_RESET	0x1000
#define CONFIG_COUNT        44

.SECTION data1
.ALIGN 4;
/*    СФОРМИРОВАННЫЕ ЗАПРОСЫ REG-->SPORT-->LMX2571    */
/*====================================================*/
/*       REG: [R/W-1бит][Addr-7бит][Data-16бит]       */
.GLOBAL config_array;	
.BYTE4 config_array[CONFIG_COUNT] = {
//===== ЗАПРОСЫ ======//
	0x3CA000,
	0x3A8C00,
	0x357806,
	0x2F6000,
	0x2E001A,
	0x2A0210,
	0x290810,
	0x28101C,
	0x2711FB,
	0x230C83,
	0x221000,
	0x210000,
	0x200000,
	0x1F0000,
	0x1E0000,
	0x1D0000,
	0x1C0000,
	0x1B0000,
	0x1A0000,
	0x190000,
	0x18000E,
	0x170EC4,
	0x169181,
	0x1430FA,
	0x1303E8,
	0x120000,
	0x110000,
	0x100000,
	0x0F0000,
	0x0E0000,
	0x0D0000,
	0x0C0000,
	0x0B0000,
	0x0A0000,
	0x090000,
	0x08000E,
	0x070EC4,
	0x069181,
	0x050101,
	0x0430FA,
	0x0303E8,
	0x020000,
	0x010000,
	0x0000C3
}; 

/*====== Инициализация LMX2571 ======*/
.SECTION program
.ALIGN 4;
.GLOBAL _LMX2571_Init;
_LMX2571_Init:
	[--SP] = RETS;
//====== LMX GPIO --> КЛЮЧ ===========//
	P0.L = LO(REG_PORTD_FER);
	P0.H = HI(REG_PORTD_FER);
	R0 = [P0];	
	R1 = ~BITM_PORT_FER_PX7;
	R0 = R0 & R1;	
	[P0] = R0;
	
	P0.L = LO(REG_PORTD_DIR);     
	P0.H = HI(REG_PORTD_DIR);
	R0 = [P0];	
	R1 = BITM_PORT_POL_PX7;
	R0 = R0 | R1;
	[P0] = R0;
	
	P0.L = LO(REG_PORTD_DATA);      
	P0.H = HI(REG_PORTD_DATA);
	R0 = [P0];	
	R1 = ~BITM_PORT_DATA_TGL_PX7;
	R0 = R0 & R1;
	[P0] = R0;
//====================================//	
	R0 = BITM_LMX_REG0_RESET(Z);
	CALL _SPORT0B_Transmit_Data; 
/* Конфигурация регистров LMX2571: */ 
	P0.L = LO(config_array); 
	P0.H = HI(config_array);
		
	R0 = CONFIG_COUNT;
	P1 = R0; 	
	LSETUP(_GPIO_Meandr.LoopBegin, _GPIO_Meandr.LoopEnd) LC0 = P1;
_GPIO_Meandr.LoopBegin:
	R0 = [P0];

	[--SP] = P0;
	CALL _SPORT0B_Transmit_Data;
	P0 = [SP++];
	P0 += 4;
/* задержка на 100мксек <==> 48к тактов */
          /* 1 итерация <==> 4 такта */
	R0 = 7000;
	R1 = 0(Z);
	R2 = 1;
_GPIO_Meandr.Delay_Loop:
    R0 = R0 - R2;
    CC = R0 == R1;
    IF !CC JUMP _GPIO_Meandr.Delay_Loop;  
_GPIO_Meandr.LoopEnd:
	NOP;
_LMX2571_Init.exit:
	RETS = [SP++];
	RTS;
_LMX2571_Init.end:








