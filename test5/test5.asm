DATAS SEGMENT
    ;�˴��������ݶδ���  
TIPS1 DB 'Enter Seven Number Separated By Space:',13,10,'$'
TIPS2 DB 'Error Input! Try again!',13,10,'$'
TIPS3 DB 'The Average Score is: $'
NUM   DB 255        ;����������
      DB ?          ;ʵ���������
      DB 255 DUP('$') ;�洢�ռ�
NUM_Dec DB 10 DUP(?) ;���7������
AVERAGE DB 10 DUP(?) ;���ƽ��ֵ
NUM_TEMP DB 10 DUP(?) ;��ʱ����
TEN_DB  DB 10         ;8λ10
TEN_DW  DW 10         ;16λ10
HUN_DB  DB 100        ;8λ100
LINE  DB 0AH,0DH,'$'  ;����
DATAS ENDS

STACKS SEGMENT
     DW 20H DUP(0)
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    
    LEA DX,TIPS1  ;�����ʾ��1
    MOV AH,9
    INT 21H
    
    MOV CX,7          ;ѭ��7�� 
    MOV DI,0          ;DIΪ���ʮ�����������ƫ����
INPUT_7:
    LEA BX,NUM        ;BXָ��������ַ���
    PUSH CX           ;����CX���ӳ�����CX�ᱻ����
    CALL INPUT        ;���벢���Ϸ���
    CMP CX,0FFH       ;��CX����Ϊ0FFH�򲻺Ϸ�
    JZ OVER
    POP CX            ;�ָ�CX
    CALL PRINT_LINE   ;����
    LOOP INPUT_7      ;ѭ������7����
    
    LEA BX,NUM_Dec     ;BXָ�򴢴�7������NUM_Dec����
    CALL SORT          ;����
    
	CALL PRINT_AVERAGE   ;���㲢��ӡƽ��ֵ
	JMP OVER

INPUT PROC
	MOV DX,BX    ;����һ����
    MOV AH,10     
    INT 21H

	XOR DX,DX    ;����
	MOV SI,1
	MOV CL,[BX][SI]  ;�����ȴ���3��Ƿ�
	CMP CL,3
	JA ERROR
CHECK:
	XOR AX,AX
	INC SI           ;SI=SI+1
	MOV AL,[BX][SI]  ;�ַ����Ǵ�ƫ����Ϊ2�ĵط���ͷ
	;MOV BYTE PTR [BX][SI],'$'    ;��ԭλ����Ϊ��$��
	CMP AL,30H      ;��С��0��Ƿ�
 	JB ERROR
 	CMP AL,39H      ;������9��Ƿ�
 	JA ERROR
 	CMP AL,31H      ;��Ϊ0��1����ת
 	JNA TRANS1
 	CMP CL,3        ;��Ϊ2-9֮�䣬���ʱ��Ϊ��λ��Ƿ�
 	JE ERROR
TRANS1:	
 	SUB AL,30H      ;��ASCIIֵת��Ϊ����
 	CMP CL,3        ;��Ϊ��λ����100
 	JNZ CHECK2
	MUL HUN_DB	
	JMP CHECK3
CHECK2: 
	CMP CL,2       ;��Ϊʮλ����10
	JNZ CHECK3     ;��Ϊ��λ����������
 	MUL TEN_DB
CHECK3:
	ADD DL,AL      ;������ֵ����DL��
	LOOP CHECK

CHECK_UPPER:
	CMP DL,100          ;�Ƚ�����ʮ�������Ƿ����100��������Ƿ�
	JA ERROR	
	MOV NUM_Dec[DI],DL   ;��ת�����ʮ����������������
	INC DI               ;ƫ������1		
	JMP EXIT
	
ERROR:
	CALL PRINT_LINE   ;����
 	LEA DX,TIPS2  ;�����ʾ��2
    MOV AH,9
    INT 21H
 	MOV CX,0FFH   ;��CXΪ0FFH
EXIT: RET         ;����
INPUT ENDP

;���㲢��ӡƽ��ֵ
PRINT_AVERAGE PROC
	XOR AX,AX     ;AX����
	MOV SI,1      ;����������ȡ�±�Ϊ1-5��Ԫ�����
	MOV CX,5      ;ѭ��5��
SUM:
	XOR DX,DX       ;DX����
	MOV DL,[BX][SI] ;ȡһ��������DL��
  	ADD AX,DX       ;AX���μ��������
  	INC SI          ;ƫ������1
  	LOOP SUM
	
	XOR DX,DX       ;����
	MOV CX,5
	DIV CX          ;�ܺͳ���5
	MOV AVERAGE,AL  ;AL��Ϊ�������֣���������
	SHL DL,1        ;����*10/5���൱��*2����ΪС������
	MOV AVERAGE[1],DL  ;С�����ִ�������
	
	MOV SI,0       ;SIΪ��ʱ�����ƫ����
TURN_AVERAGE:
	XOR DX,DX      ;����
	DIV TEN_DW     ;��10ȡ��õ�����λ�ϵ���ֵ�����������DL��
	ADD DL,30H     ;����ת��ΪASCII
	MOV NUM_TEMP[SI],DL ;�������ִ�����ʱ����
	INC SI
	CMP AX,0      ;��Ϊ0���㷨����	
	JA TURN_AVERAGE
	
	LEA DX,TIPS3  ;�����ʾ��3
    MOV AH,9
    INT 21H	
PRINT:
	DEC SI               ;SIΪ������Ԫ�ظ��� 
	MOV DL,NUM_TEMP[SI]  ;��������������Ϊ����
	MOV AH,2             ;�������������λ�ϵ���ֵ
	INT 21H
	CMP SI,0            ;SIΪ0˵�����һ���������
	JNZ PRINT
	
	MOV DX,'.'	       ;���С����
	MOV AH,2
	INT 21H
	
	XOR DX,DX          ;DX���㣬����Ҫ���С������
	MOV DL,AVERAGE[1]  ;���С������
	ADD DL,30H	       ;ת��ΪASCII
	MOV AH,2
	INT 21H
	RET
PRINT_AVERAGE ENDP

SORT PROC
;ð������
	MOV CX,6   ;�߸��������ѭ��ִ��6��
SORT1:
	MOV SI,0   ;BXƫ����
	MOV DI,0   ;�ڲ�ѭ������
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
	LOOP SORT1  ;�ڲ�ѭ����������ʼ��һ�����ѭ��

	RET
SORT ENDP

PRINT_LINE PROC
 	LEA DX,LINE   ;����
    MOV AH,9
    INT 21H
 	RET
PRINT_LINE ENDP
   
OVER:
	LEA BX,NUM     ;BXָ��NUM�ַ���
	MOV AL,24H     ;AL�桮$��
	MOV SI,0       ;SIΪBXƫ����
	MOV CX,255     ;ѭ������Ϊ����������
CLEAR_NUM:            ;����NUM
	MOV [BX][SI],AL  ;ȫ������Ϊ��$��
	INC SI
	LOOP CLEAR_NUM
	
	MOV SI,0        ;SIΪƫ�������������鳤�����
	MOV CX,10       ;ѭ��ʮ��
CLEAR_ALL:          ;������������
	MOV NUM_Dec[SI],AL
	MOV AVERAGE[SI],AL
	MOV NUM_TEMP[SI],AL
	INC SI
	LOOP CLEAR_ALL

 	CALL PRINT_LINE ;����
 	JMP START       ;���¿�ʼ
    
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START