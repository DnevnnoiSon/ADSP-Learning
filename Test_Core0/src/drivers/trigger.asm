#include "asm_def.h"
#include "defBF607.h"
#include "trigger.h"

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
	
	[P0+LO(REG_PORTG_POL_CLR)] = R0;  
//На всякий случай, пока настраиваю - выставляется запрет прерываний	
    R0 = TRIGGER_IN_PINT_BITM;                      
    [P0+LO(REG_PINT5_MSK_CLR)] = R0;               
//Настройка PINT(Программируемое Внешнее Прерывание):
//Назначение:	
	R0 = (0 << BITP_PINT_ASSIGN_B3MAP)
		|(0 << BITP_PINT_ASSIGN_B2MAP)
		|(1 << BITP_PINT_ASSIGN_B1MAP)           
		|(1 << BITP_PINT_ASSIGN_B0MAP);          
    [P0+LO(REG_PINT2_ASSIGN)] = R0;  //Отображение в регистр прерываний
	
  	R0 = TRIGGER_IN_BITM(Z); 
  	
  	[P0+LO(REG_PINT5_EDGE_SET)] = R0;  //Прерывание по фронту сигнала
    [P0+LO(REG_PINT5_INV_CLR)] = R0;   //По возрастающему фронту
    [P0+LO(REG_PINT5_LATCH)] = R0;     //Фиксация текущего урвоня сигнала         
    [P0+LO(REG_PINT5_REQ)] = R0;       //Флаги активных запросов прерваний

	[P0+LO(REG_PORTG_INEN_SET)] = R0;  //Включение входного буфера
	
	[P0+LO(REG_PINT5_MSK_SET)] = R0; //Разрешаю прерывания

_Trigger_Init.end: 


/* было в gpio: Очистка флага прерывания */
//   P0.L = LO(REG_PORTC_INEN_CLR);
//   P0.H = HI(REG_PORTC_INEN_CLR);
//   R0 = (1 << BITP_PORT_POL_PX2);
//   W[P0] = R0;  



