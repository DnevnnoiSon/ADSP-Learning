#include "defBF607.h"
#include "timer.h"
#include "sec.h"

.EXTERN _Timer0_ISR;

#define ld32(R,value) 				R##.L = LO(value); R##.H = HI(value)						
#define ldAddr(P, value)			P##.L = 0; P##.H = HI(value)

.SECTION program
.ALIGN 4;
.GLOBAL _SEC_Init;	
/* Привязка: [EVENT <==> _sec_dispetcher] */
_SEC_Init:
	ldAddr(P0,REG_SEC0_GCTL);      
	                        
     R0 = ENUM_SEC_GCTL_EN;	  //включение SEC
    [P0+LO(REG_SEC0_GCTL)] = R0;   
     
    R0 = ENUM_SEC_CCTL_EN;    //Разрешение прерываний по ядру
    [P0 + LO(REG_SEC0_CCTL0)] = R0;     
                            
// Подключение источника в качестве прерывания:
	R0 =(0<<BITP_SEC_SCTL_CTG)                      
          | ENUM_SEC_SCTL_SRC_EN
          | ENUM_SEC_SCTL_INT_EN;      
// Cопоставление источника с соответствующим SCI:                
    [P0+LO(REG_SEC0_SCTL12)] = R0; 
                 
_SEC_Init.exit:
	RTS;	
_SEC_Init.end:

//===== ОБРАБОТЧИК(ДИСПЕТЧЕР) НИЖНЕГО УРОВНЯ ===================
.GLOBAL __sec_int_dispatcher;
__sec_int_dispatcher:
//Сохранение контекста:
	[--sp] = (R7:0, P5:0);
	[--sp] = ASTAT;
    [--sp] = RETS;
   
	ldAddr(P5, REG_SEC0_CSID0);
	R5 = [P0 + LO(REG_SEC0_CSID0)];
	
__sec_int_dispatcher.timer:																		
	//Прерывание от TIM0?
	R0 = INTR_TIMER0_TMR0;
	CC = R5 == R0;
	IF !CC JUMP __sec_int_dispatcher.exit; 
	//Обработчик (TIM0) верхнего уровня:
	CALL _Timer0_ISR;
	
__sec_int_dispatcher.exit:
	//Очистка флага:
	R0 = BITM_TIMER_DATA_ILAT_TMR00;
	W[P0] = R0;  
	
	RETS = [sp++];
	ASTAT = [sp++];
	(R7:0, P5:0) = [sp++];	
	RTI;
__sec_int_dispatcher.end:


