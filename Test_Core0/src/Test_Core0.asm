.EXTERN _adi_initpinmux;
.EXTERN _adi_core_enable;

//ПОЛЬЗОВАТЕЛЬСКИЕ ФУНКЦИИ:
.EXTERN _GPIO_Control;
.EXTERN _GPIO_Meandr;
.EXTERN _Timer0_Init;
.EXTERN _Timer_Run;
.EXTERN _Timer0_Overflow;
//.EXTERN _SEC_Init;

.SECTION L1_data;
.ALIGN 4;

 
.SECTION L1_code;
.ALIGN 4;
.GLOBAL _main;
_main:
_main.Init:	
	CALL _GPIO_Control;
	
//	CALL _SEC_Init;
	
	CALL _Timer0_Init;
	
	CALL _Timer_Run;
_main.Loop:

	//CALL _GPIO_Meandr;

	//не блокирующий режим:
	CALL _Timer0_Overflow;
	
	
	JUMP _main.Loop;
_main.end: 

