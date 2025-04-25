#include "sport.h"
#include "asm_def.h"
#include "defBF607.h"
#include "lmx2571.h"

.EXTERN _SPORT0B_Transmit_Data;

#define BITM_LMX_REG0_RESET	0x1000
#define CONFIG_COUNT        3

.SECTION data1
.ALIGN 4;
/*    СФОРМИРОВАННЫЕ ЗАПРОСЫ REG-->SPORT-->LMX2571    */
/*====================================================*/
/*       REG: [R/W-1бит][Addr-7бит][Data-16бит]       */
.GLOBAL config_array;	
.BYTE4 config_array[CONFIG_COUNT] = {
//===== ЗАПРОСЫ ======//
	0xFFF000,
	0xFFF000,
	0xFFF000
}; 

/*====== Инициализация LMX2571 ======*/
.SECTION program
.ALIGN 4;
.GLOBAL _LMX2571_Init;
_LMX2571_Init:
	[--SP] = RETS;

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
_GPIO_Meandr.LoopEnd:
	NOP;
_LMX2571_Init.exit:
	RETS = [SP++];
	RTS;
_LMX2571_Init.end:








