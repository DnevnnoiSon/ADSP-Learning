#include "defBF607.h"
#include "gpio.h"

.GLOBAL _GPIO_Control
.GLOBAL _GPIO_Inverse;
.GLOBAL _GPIO_Meandr;
.GLOBAL _GPIO_Triger_Overflow;

.EXTERN _main.Loop;

#define PIN_RESET		 (~BITM_PORT_DATA_PX14)  
#define PIN_SET   		 (BITM_PORT_DATA_PX14)

.SECTION data1;
.ALIGN 4;
.GLOBAL prev_state;
.BYTE4 prev_state = 0;	

.SECTION program;
.ALIGN 4;
.GLOBAL _GPIO_Control;
_GPIO_Control:
//==== Настройка на GPIO/Pherefirial ================
	P0.L = LO(REG_PORTE_FER);       /* BNC1 - GPIO */
	P0.H = HI(REG_PORTE_FER);
	R0 = [P0];	
	R1 = ~BITM_PORT_FER_PX14;
	R0 = R0 & R1;	
	[P0] = R0;
	
	P0.L = LO(REG_PORTC_FER);       /* BNC2 - GPIO */
	P0.H = HI(REG_PORTC_FER);
	R0 = [P0];
	R1 = ~BITM_PORT_FER_PX2;
	R0 = R1 & R0; 
	[P0] = R0;
	    
	P0.L = LO(REG_PORTD_FER);       /* PORTD PIN7 - GPIO */
	P0.H = HI(REG_PORTD_FER);
	R0 = [P0];
	R1 = ~BITM_PORT_FER_PX7;
	R0 = R1 & R0; 
	[P0] = R0;
//==== Настройка на вход/выход ======================
	P0.L = LO(REG_PORTE_DIR);     /* BNC1 - OUTPUT */
	P0.H = HI(REG_PORTE_DIR);
	R0 = [P0];	
	R1 = BITM_PORT_POL_PX14;
	R0 = R0 | R1;
	[P0] = R0;
	
	P0.L = LO(REG_PORTC_DIR);     /* BNC2 - INPUT */
	P0.H = HI(REG_PORTC_DIR);
	R0 = [P0];	
	R1 = ~BITM_PORT_POL_PX2;
	R0 = R0 & R1;
	[P0] = R0;	
	
	P0.L = LO(REG_PORTD_DIR);      /* PORTD PIN7 - OUTPUT*/
	P0.H = HI(REG_PORTD_DIR);
	R0 = [P0];	
	R1 = ~BITM_PORT_POL_PX7;
	R0 = R0 & R1;
	[P0] = R0;	
//========================================================================
//==== Настройка физического сигнала ================
	P0.L = LO(REG_PORTE_DATA);      /* BNC1 - HIGH */
	P0.H = HI(REG_PORTE_DATA);
	R0 = [P0];	
	R1 = BITM_PORT_DATA_TGL_PX14;
	R0 = R0 | R1;
	[P0] = R0;
		
	P0.L = LO(REG_PORTC_DATA);       /* BNC2 - LOW */
	P0.H = HI(REG_PORTC_DATA);
	R0 = [P0];	
	R1 = ~BITM_PORT_DATA_TGL_PX2;
	R0 = R0 & R1;
	[P0] = R0;
		
	P0.L = LO(REG_PORTD_DATA);       /* PORTD PIN7 - LOW */
	P0.H = HI(REG_PORTD_DATA);
	R0 = [P0];	
	R1 = ~BITM_PORT_DATA_TGL_PX7;
	R0 = R0 & R1;
	[P0] = R0;	
								     
	RTS;
_GPIO_Control.end:

//МЕАНДР ПЕРИОДИЧНОСТЬЮ В ТАКТАХ ЦИКЛА:
.GLOBAL _GPIO_Meandr;
.SECTION program
.ALIGN 4;
_GPIO_Meandr:
	P0.L = LO(REG_PORTE_DATA);
	P0.H = HI(REG_PORTE_DATA);
	
	R0 = 10000;	
	P2 = R0; 	//ЗАДЕРЖКА
	LSETUP(_GPIO_Meandr.LoopBegin, _GPIO_Meandr.LoopEnd) LC0 = P2;
_GPIO_Meandr.LoopBegin:
	
_GPIO_Meandr.LoopEnd:
	nop; 
_GPIO_Meandr.Reverse: 
	R0 = [P0];		//Выгрузка
	BITTGL(R0, 14); //Инверсия

	[P0] = R0;

	RTS; 
_GPIO_Meandr.end:

//========= ОПРОС ФЛАГА ТРИГГЕРА СИГНАЛА ======================
//РЕАЛИЗАЦИЯ БЕЗ ПРИВЯЗКИ К ВЕКТОРУ ПРЕРЫВАНИЙ
.GLOBAL _GPIO_Triger_Overflow;
.SECTION program
.ALIGN 4;
_GPIO_Triger_Overflow:
	[--sp] = RETS;
	
	P0.L = LO(REG_PORTC_DATA);
	P0.H = HI(REG_PORTC_DATA);  
	R0 = [P0];   
	
//R0 - Текущее значение
//R1 - Предыдущее значение
	R2 = BITM_PORT_POL_PX2;
	R0 = R0 & R2;
//выгрузка предыдущего значения: 
	P0.H = HI(prev_state);
	P0.L = LO(prev_state);
	R1 = [P0];
	R1 = R1 & R2; 

	CC = R0 == R1;
	IF CC JUMP _GPIO_Triger_Overflow.exit;
/* Входной триггер зафиксировал смену сигнала */
//обновление cостояния:
 	P1.H = HI(prev_state);
    P1.L = LO(prev_state);
    [P1] = R0;            
 
/* => Переключение Выходного сигнала */
	CALL _GPIO_Inverse;

_GPIO_Triger_Overflow.exit:
	R7 = CC;
	RETS = [sp++];
	RTS;
_GPIO_Triger_Overflow.end:

//==========================================================================
.GLOBAL _GPIO_Inverse;	//Для таймеров 
.SECTION program
.ALIGN 4;
_GPIO_Inverse:
	P0.L = LO(REG_PORTE_DATA);
	P0.H = HI(REG_PORTE_DATA);
	
	R0 = [P0];	//Выгрузка
	BITTGL(R0, 14); 	//Инверсия
	[P0] = R0;

	RTS; 
_GPIO_Inverse.end:

















