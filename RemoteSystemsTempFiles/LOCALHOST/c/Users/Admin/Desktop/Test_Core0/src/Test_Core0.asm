.EXTERN _adi_initpinmux;
.EXTERN _adi_core_enable;

//ПОЛЬЗОВАТЕЛЬСКИЕ ФУНКЦИИ:
.EXTERN _GPIO_Control;
.EXTERN _GPIO_Meandr;
.EXTERN _Timer0_Init;
.EXTERN _Timer_Run;
.EXTERN _TIM_CNT_Check;
.EXTERN _sec_Init;

.SECTION L1_data;
.ALIGN 4;

 
.SECTION L1_code;
.ALIGN 4;
.GLOBAL _main;
_main:
_main.Init:	
		
	CALL _GPIO_Control;
	R4 = R0;
	
	CALL _sec_Init;
	
	CALL _Timer0_Init;
	
	CALL _Timer_Run;
_main.Loop:

	//R0 = R4;
	//CALL _GPIO_Meandr;
	//R4 = R0;
	
	//не блокирующий режим:
	CALL _TIM_CNT_Check;
	
	
	JUMP _main.Loop;
_main.end: 

