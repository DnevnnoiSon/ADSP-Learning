#include "asm_def.h"
#include "defBF607.h"
#include "trigger.h"

.EXTERN _GPIO_Inverse;

//============ PORTC-2(BNC2) =======================================
#define TRIGGER_IN_BITP                 BITP_PORT_DATA_SET_PX2
#define TRIGGER_IN_BITM                 (1 << TRIGGER_IN_BITP)

#define TRIGGER_IN_PINT_BITP           	BITP_PORT_DATA_SET_PX2
#define TRIGGER_IN_PINT_BITM           	(1<<TRIGGER_IN_PINT_BITP)


//================ ИНИЦИАЛИЗАЦИЯ ПОРТОВ ДЛЯ ТРИГГЕРОВ ================== 
.SECTION program;
.ALIGN 4;
.GLOBAL _Trigger_Init;
_Trigger_Init:
//========================= BNC2 INTERUPTION ===========================
	ldAddr(P0, REG_PORTG_FER);
	R0 = TRIGGER_IN_BITM(Z); 
//На всякий случай очистка лишних настроек у порта:
	[P0+LO(REG_PORTC_FER_CLR)] = R0; 
	[P0+LO(REG_PORTC_DIR_CLR)] = R0;
	
	[P0+LO(REG_PORTC_POL_CLR)] = R0;  
//На всякий случай, пока настраиваю - выставляется запрет прерываний	
    R0 = TRIGGER_IN_PINT_BITM;                      
    [P0+LO(REG_PINT2_MSK_CLR)] = R0;               
//Настройка PINT(Программируемое Внешнее Прерывание):
//Назначение:	
	R0 = (0 << BITP_PINT_ASSIGN_B3MAP)
		|(0 << BITP_PINT_ASSIGN_B2MAP)
		|(0 << BITP_PINT_ASSIGN_B1MAP)           
		|(0 << BITP_PINT_ASSIGN_B0MAP);          
    [P0+LO(REG_PINT2_ASSIGN)] = R0;  //Отображение в регистр прерываний
	
	R0 = TRIGGER_IN_BITM(Z); 
	
	[P0+LO(REG_PORTC_INEN_SET)] = R0;  //Включение входного буфера
		
  	R0 = TRIGGER_IN_PINT_BITM(Z); 
  	
  	[P0+LO(REG_PINT2_EDGE_SET)] = R0;  //Прерывание по фронту сигнала
    [P0+LO(REG_PINT2_INV_CLR)] = R0;   //По возрастающему фронту
    [P0+LO(REG_PINT2_LATCH)] = R0;     //Фиксация текущего уровня сигнала         
    [P0+LO(REG_PINT2_REQ)] = R0;       //Флаги активных запросов прерваний

	[P0+LO(REG_PINT2_MSK_SET)] = R0; //Разрешение прерывания

	RTS;
_Trigger_Init.end: 


//==== ОБРАБОТЧИК ВЕРХНЕГО УРОВНЯ ===============================
.SECTION program
.ALIGN 4;
.GLOBAL _GPIO_Trigger_ISR;
_GPIO_Trigger_ISR:
	[--sp] = RETS;
    /* PINT2 был переполнен: сброс переполнения */
	P0.L = LO(REG_PINT2_LATCH);
	P0.H = HI(REG_PINT2_LATCH);
	R0 = [P0];
	
	R1 = BITM_PINT_INV_CLR_PIQ2; 
	R0 = R0 | R1; 
	[P0] = R0;
	
	CALL _GPIO_Inverse;
	RETS = [sp++];
	RTS;
_GPIO_Trigger_ISR.end:



