;Ĭ�ϲ���ML6.11������
DATAS SEGMENT
    ;�˴��������ݶδ���  
TIPS1 DB 'Enter Six Number:',13,10,'$'
TIPS2 DB 'Error Input! Try again!',13,10,'$'
TIPS3 DB 'After Sorting:',13,10,'$'
TIPS4 DB 'The Sum is: ',13,10,'$'
NUM   DB 10        ;����������
      DB ?          ;ʵ���������
      DB 10 DUP('$') ;�洢�ռ�
NUM_Dec DB 10 DUP('$') ;���3������
SUM   DB 8 DUP(' ')   ;���ݺ�
TEN_DB   DB 10        ;8λ10
TEN_DW   DW 10        ;16λ10
LINE  DB 0AH,0DH,'$'  ;����
DATAS ENDS

STACKS SEGMENT
    ;�˴������ջ�δ���
    DW 20H DUP(0)
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    ;�˴��������δ���
    LEA DX,TIPS1  ;�����ʾ��1
    MOV AH,9
    INT 21H
    
    LEA BX,NUM        ;BXָ��������ַ���
    CALL INPUT_DEC    ;���벢���Ϸ���
    CMP CX,0FFH       ;��CX����Ϊ0FFH�򲻺Ϸ�
    JZ OVER
    CALL PRINT_LINE   ;����
    
    LEA BX,NUM+2      ;BXָ���ַ�����ʼ��ַ
    CALL TRANSITION   ;��6λʮ������ת��Ϊ3��2λʮ������
    
    LEA BX,NUM_Dec    ;BXָ���Ŷ�λʮ������������
    CALL NUM_SUM      ;�����ܺͲ����
    
    CALL PRINT_SORT   ;����������
    
    JMP OVER
;���������
;����6λʮ�����������Ϸ���    
INPUT_DEC PROC
	MOV DX,BX    ;����ʮ������
    MOV AH,10     
    INT 21H

	MOV SI,1
 	MOV CL,[BX][SI]  ;�Ĵ������Ѱַ
    CMP CL,6         ;�����Ȳ�Ϊ6��Ƿ�
    JNE ERROR
CHECK:
 	INC SI          ;�ַ�����ƫ����Ϊ2�ĵط���ʼ
	MOV AL,[BX][SI] ;AL���δ�ÿ����
	CMP AL,30H      ;��С��0��Ƿ�
 	JB ERROR
 	CMP AL,39H      ;������9��Ƿ�
 	JA ERROR
 	LOOP CHECK  
    JMP EXIT        ;�ȽϽ������Ϸ�����ת������
ERROR:
	MOV CX,0FFH   ;��CXΪ0FFH
 	LEA DX,TIPS2  ;�����ʾ��2
    MOV AH,9
    INT 21H
EXIT: RET    ;����   
INPUT_DEC ENDP 

;��6λʮ������ת��Ϊ3��2λʮ������
TRANSITION PROC    
    MOV CX,3   ;��������ѭ������
	MOV SI,5   ;��ĩλ��ʼ
   	MOV DI,0   ;NUM_Dec�����ƫ����
   	XOR AX,AX   ;����
   	XOR DX,DX  
TRAN:
	MOV AL,[BX][SI] ;ȡʮλ
	SUB AL,30H      ;תΪ����
	MUL TEN_DB      ;��10
 	MOV DL,[BX][SI-1] ;ȡ��λ
 	SUB DL,30H       ;תΪ����
 	ADD AL,DL        ;ʮλ���ϸ�λ
 	MOV NUM_Dec[DI],AL  ;ת����Ķ�λʮ��������������
    INC DI
    SUB SI,2        ;ƫ����ÿ�μ�2
    LOOP TRAN 
	RET             ;����
TRANSITION ENDP

;�����ܺͲ����
NUM_SUM PROC
    LEA DX,TIPS4  ;�����ʾ��4
    MOV AH,9
    INT 21H
    
    XOR AX,AX   ;����
    MOV SI,0    ;SIΪBXƫ����
PLUS:
	XOR DX,DX   ;����
	MOV DL,[BX][SI] ;ȡһ��������DL��
  	ADD AX,DX       ;AX���μ���������
 	INC SI
 	CMP SI,3       ;û�ӵ�3���������ѭ��
 	JNZ PLUS
 	
 	MOV SI,0
TURN_SUM:
	XOR DX,DX      ;����
	DIV TEN_DW     ;��10ȡ��õ�����λ�ϵ���ֵ�����������DL��
	ADD DL,30H     ;����ת��ΪASCII
	MOV SUM[SI],DL ;��������
	INC SI
	CMP AX,0      ;��Ϊ0���㷨����
	JA TURN_SUM
PRINT_SUM:
	DEC SI          ;SIΪ������Ԫ�ظ��� 
	MOV DL,SUM[SI]  ;��������������Ϊ����
	MOV AH,2        ;�������������λ�ϵ���ֵ
	INT 21H
	CMP SI,0        ;SIΪ0˵�����һ���������
	JNZ PRINT_SUM 

    CALL PRINT_LINE   ;����
	RET               ;����
NUM_SUM ENDP

PRINT_SORT PROC
;ð������
	MOV CX,2   ;�����������ѭ��ִ��2��
SORT1:
	MOV SI,0   ;����
	MOV DI,0	
SORT2:
	MOV AL,[BX][SI]    ;ȡ��һ��Ԫ��
	MOV DL,[BX][SI+1]  ;ȡ�ڶ���Ԫ��
	CMP AL,DL    ;�Ƚϵ�һ��Ԫ�غ͵ڶ���Ԫ�صĴ�С����ǰ�߸�������ת
	JNB SORT3
	MOV [BX][SI],DL  ;��ǰ�߸�С���򽻻�
	MOV [BX][SI+1],AL
SORT3:
	INC SI      ;ƫ������1
	INC DI	    ;������1
	CMP DI,CX   ;DI��¼�ڲ�ѭ����������DI<CX,�����ȽϺ����Ԫ��
	JB SORT2
	LOOP SORT1   ;�ڲ�ѭ����������ʼ��һ�����ѭ��
	
;�����������
	LEA DX,TIPS3  ;�����ʾ��3
    MOV AH,9
    INT 21H

	MOV CX,3     ;ѭ������
	MOV SI,0    ;SIΪBXƫ����
OUTPUT:
	XOR AX,AX    ;����
	XOR DX,DX
	MOV AL,[BX][SI]  ;ȡһ��������AL��
	DIV TEN_DB       ;����10,�ֽڳ���������AH��
	MOV DL,AL        ;����AL��
	CMP DL,0         ;����Ϊ0˵��ʮλΪ0����ת�����λ
	JZ OUTPUT2 
	ADD DL,30H       ;�̲�Ϊ0��ת��ΪASCII���ʮλ
	PUSH AX          ;���棬��Ϊ�����ʹAHֵ�ı�
	MOV AH,2
	INT 21H
	POP AX           ;�ָ�AX
OUTPUT2:
	MOV DL,AH      ;����������DL��
	ADD DL,30H     ;ת��ΪASCII���ʮλ
	MOV AH,2
	INT 21H
	
	MOV DX,20H	   ;���һ���ո�
	MOV AH,2
	INT 21H
	
	INC SI
	LOOP OUTPUT    ;���������һ����
	
	CALL PRINT_LINE  ;����
	RET	
PRINT_SORT ENDP

PRINT_LINE PROC
 	LEA DX,LINE   ;����
    MOV AH,9
    INT 21H
 RET
PRINT_LINE ENDP
 
OVER:
 CALL PRINT_LINE  ;����
 JMP START        ;���¿�ʼ
 
 MOV AH,4CH
 INT 21H
CODES ENDS
    END START