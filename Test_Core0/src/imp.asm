.IMPORT "imp.h";

.SECTION L1_data;
.ALIGN 4;
.STRUCT CustomData _data = { 1, 0 };


.GLOBAL _GPIO_DataInit;
.SECTION program;
.ALIGN 4;
_GPIO_DataInit:
//	.BYTE2 cmd = 0x0218, 0x0218;
	
_GPIO_DataInit.return:
	P0.L = LO(_data->index);
	P0.H = HI(_data->index); 	
	
	P0 += 4;
	R0 = P0; 
	RTS;
_GPIO_DataInit.end:	

//============================================================

.GLOBAL _GPIO_DataLoad;	
.SECTION program;
.ALIGN 4;
_GPIO_DataLoad:	
	P0 = R0; //указатель на структуру
	P1 = R1; //указатель на состояние
	
	B[P0++] = R1;
	
	R0 = P0;
	RTS;
_GPIO_DataLoad.end:	
