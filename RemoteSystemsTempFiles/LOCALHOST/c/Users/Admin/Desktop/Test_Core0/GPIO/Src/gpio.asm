#include "defBF607.h"
#include "gpio.h"

.GLOBAL _GPIO_Control
.GLOBAL _GPIO_Inverse;
.GLOBAL _GPIO_Meandr;
.GLOBAL _TIM_CNT_Check;

.EXTERN _main.Loop;

#define PIN_RESET		 (~BITM_PORT_DATA_PX14)  
#define PIN_SET   		 (BITM_PORT_DATA_PX14)

.GLOBAL _GPIO_Control;
.SECTION program_for_artem;
.ALIGN 4;
_GPIO_Control:
_GPIO_Control.Init:	
	
	//Настройка на GPIO
	P0.L = LO(REG_PORTE_FER);
	P0.H = HI(REG_PORTE_FER);
	R0 = [P0];	
	R1 = BITM_PORT_FER_PX14;
	R0 = R0 & R1;	
	[P0] = R0;
	
	//Настройка на выход
	P0.L = LO(REG_PORTE_DIR);
	P0.H = HI(REG_PORTE_DIR);
	R0 = [P0];	
	R1 = BITM_PORT_POL_PX14;
	R0 = R0 | R1;
	[P0] = R0;
	
	//Настройка физического сигнала
	P0.L = LO(REG_PORTE_DATA);
	P0.H = HI(REG_PORTE_DATA);
	R0 = [P0];	
	R1 = BITM_PORT_DATA_TGL_PX14;
	R0 = R0 | R1;
	[P0] = R0;
	
	R0 = P0;
	
	RTS;
_GPIO_Control.end:

//==========================================================================
.GLOBAL _GPIO_Meandr;
.SECTION program
.ALIGN 4;
_GPIO_Meandr:
	P0 = R0;	//Соглашение
	
	R0 = 10000;	
	P2 = R0; 	//ЗАДЕРЖКА
	LSETUP(_GPIO_Meandr.LoopBegin, _GPIO_Meandr.LoopEnd) LC0 = P2;
_GPIO_Meandr.LoopBegin:
	
_GPIO_Meandr.LoopEnd:
	nop; 
_GPIO_Meandr.Reverse: 
	R0 = [P0];	//Выгрузка
	BITTGL(R0, 14); 	//Инверсия

	[P0] = R0;

	RTS; 
_GPIO_Meandr.end:

//==========================================================================
.GLOBAL _GPIO_Inverse;	//Для таймеров 
.SECTION program
.ALIGN 4;
_GPIO_Inverse:
	P0 = R0;	//Соглашение
	R0 = [P0];	//Выгрузка
	BITTGL(R0, 14); 	//Инверсия
	[P0] = R0;

	RTS; 
_GPIO_Inverse.end:

//==========================================================================
.GLOBAL _TIM_CNT_Check;
.SECTION program
.ALIGN 4;
_TIM_CNT_Check:
//Опрашивать флаг:
	//Переполнился? - вызвать переключение(meandr)
	P0.H = HI(REG_TIMER0_STAT_ILAT);
	P0.L = LO(REG_TIMER0_STAT_ILAT);
	
	R0 = [P0];
	
	CC = BITTST(R0, BITP_TIMER_STAT_ILAT_TMR00);
	IF !CC JUMP _TIM_CNT_Check.exit;
	
	CALL _GPIO_Inverse;
	
_TIM_CNT_Check.exit:
	RTS;
_TIM_CNT_Check.end:


















