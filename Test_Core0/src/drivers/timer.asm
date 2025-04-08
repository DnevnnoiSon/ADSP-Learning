#include "defBF607.h"
#include "timer.h"

#define ld32(R,value) 				R##.L = LO(value); R##.H = HI(value)						
#define ldAddr(P, value)			P##.L = 0; P##.H = HI(value)
	
.EXTERN _GPIO_Inverse;		
		
.SECTION program
.ALIGN 4;
.GLOBAL _Timer0_Init;
_Timer0_Init:	
	P0.H = HI(REG_TIMER0_RUN);
	P0.L = 0;                                                                                        
	      //было: ENUM_TIMER_TMR_CFG_PWMSING_MODE; 		     
	ld32(R0,      ENUM_TIMER_TMR_CFG_CLKSEL_SCLK
                | ENUM_TIMER_TMR_CFG_EMU_CNT 
                | ENUM_TIMER_TMR_CFG_PADOUT_DIS
                | ENUM_TIMER_TMR_CFG_IRQMODE2
                | ENUM_TIMER_TMR_CFG_PWMCONT_MODE);	   
		   
	W[P0 + LO(REG_TIMER0_TMR0_CFG)] = R0;

    r0 = 0(z);
    [p0+lo(REG_TIMER0_TMR0_DLY)] = r0;                  //Задержка перед импульсом = 0 мс
    
    ld32(r0, 1200000 );							//Период ( Значение до которого будет считать CNT)
    [p0+lo(REG_TIMER0_TMR0_PER)] = r0;   				
    	
    ld32(r0, 600000 );							//Длитльность импульса 1 секунда
    [p0+lo(REG_TIMER0_TMR0_WID)] = r0;                 
    
    r0 = BITM_TIMER_DATA_ILAT_TMR00;
    w[p0+lo(REG_TIMER0_DATA_ILAT)] = r0;                //Очищаем текущий статус прерывания
    				
    r0 = BITM_TIMER_STOP_CFG_SET_TMR00;
    w[p0+lo(REG_TIMER0_STOP_CFG_SET)] = r0;             //Моментальная остановка  счета
                      
    r0 = w[p0+lo(REG_TIMER0_DATA_IMSK)];
    bitclr(r0, BITP_TIMER_DATA_IMSK_TMR00);
    w[p0+lo(REG_TIMER0_DATA_IMSK)] = r0;                //Разрешаем генерацию прерывания
   
    RTS;
_Timer0_Init.end:

//ЗАПУСК ТАЙМЕРА
.SECTION program
.ALIGN 4;
.GLOBAL _Timer_Run;
_Timer_Run:
	P0.L = 0;
	P0.H = HI(REG_TIMER0_RUN);   

 	R0 = BITM_TIMER_RUN_TMR00;
    W[P0+LO(REG_TIMER0_RUN_SET)] = R0;
	RTS;
_Timer_Run.end:

//========= ОПРОС ФЛАГА ПЕРЕПОЛНЕНИЯ ТАЙМЕРА ======================
//РЕАЛИЗАЦИЯ БЕЗ ПРИВЯЗКИ К ВЕКТОРУ ПРЕРЫВАНИЙ
.GLOBAL _Timer0_Overflow;
.SECTION program
.ALIGN 4;
_Timer0_Overflow:
	[--sp] = RETS;

	P0.L = LO(REG_TIMER0_DATA_ILAT);
	P0.H = HI(REG_TIMER0_DATA_ILAT);  
	
	R0 = W[P0];   
	R1 = BITM_TIMER_STAT_ILAT_TMR00;
	R0  = R0 & R1;
	
	R1 = 0(Z);
    CC = R0 == R1;  
	IF CC JUMP _Timer0_Overflow.exit;

/* TIM был переполнен: */
	//Очистка флага:
	R0 = BITM_TIMER_DATA_ILAT_TMR00;
	W[P0] = R0;  
	
	CALL _GPIO_Inverse;

_Timer0_Overflow.exit:
	RETS = [sp++];
	RTS;
_Timer0_Overflow.end:

//==== ОБРАБОТЧИК ВЕРХНЕГО УРОВНЯ ===============================
.SECTION program
.ALIGN 4;
.GLOBAL _Timer0_ISR;
_Timer0_ISR:
	[--sp] = RETS;
//Действия:
	/* TIM был переполнен: сброс переполнения */
	P0.L = LO(REG_TIMER0_DATA_ILAT);
	P0.H = HI(REG_TIMER0_DATA_ILAT);
	R0 = [P0];
	
	R1 = BITM_TIMER_DATA_ILAT_TMR00;
	R0 = R0 | R1;
	[P0] = R0;  

	CALL _GPIO_Inverse;
//Флаг очищается в диспетчере
	RETS = [sp++];
	RTS;
_Timer0_ISR.end:



























