.EXTERN _adi_initpinmux;
.EXTERN _adi_core_enable;

.EXTERN _GPIO_Control;
.EXTERN _GPIO_Triger_Overflow;
.EXTERN _Trigger_Init;
.EXTERN _Timer0_Init;
.EXTERN _Timer_Run;
.EXTERN _Timer0_Overflow;
.EXTERN _SystClock;
.EXTERN _SEC_Init;
.EXTERN _SPORT_Init;
.EXTERN _SPORT_Tranmit_Data;

.SECTION L1_code;
.ALIGN 4;
.GLOBAL _main;
_main:
_main.Init:	

	CALL _adi_initpinmux;
	
	CALL _SystClock;
	
	CALL _Timer0_Init;
	
	CALL _SEC_Init;
	
	CALL _GPIO_Control;
	
	CALL _Trigger_Init; 
	
	//CALL _Timer_Run;
	
	CALL _SPORT_Init;
	
_main.Loop:
//меандр по опросу флага триггера вх. сигнала: 
    //CALL _Timer0_Overflow;  
//меандр по опросу флага переполнения сигнала: 
	//CALL _GPIO_Triger_Overflow;
	
	CALL _SPORT_Tranmit_Data; 
	
	JUMP _main.Loop;
_main.end: 
/* В sec.asm - реализован меандр по прерыванию от таймера */
