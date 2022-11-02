;Ĭ�ϲ���ML6.11������
DATAS SEGMENT
    ;�˴��������ݶδ��� 
TIPS1 DB 'Your First String:',13,10,'$'
TIPS2 DB 'Your Second String:',13,10,'$'
TIPS3 DB 'Error Input! Try again!',13,10,'$'
TIPS_B  DB 'Corresponding Binary Number: $'
TIPS_D  DB 'Corresponding Decimal Number: $'
TIPS_NO DB 'NO',13,10,'$'
BUF1  DB 255          ;���һ����
      DB ?
      DB 255 DUP('$')
BUF2  DB 255          ;��ڶ�����
      DB ?
      DB 255 DUP('$')
BINARY_BUF DB 255 DUP('$') ;��ת����Ķ�������
DECIMAL_BUF DB 6 DUP('$')  ;��ת�����ʮ������
NUM DB 0                ;��¼ż������
LINE  DB 0AH,0DH,'$'   ;����
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
    
    LEA  BX,BUF1  ;BXָ��BUF1
    CALL INPUT  ;�����һ����
    CMP CX,0FFH ;��CX����Ϊ0FFH�򲻺Ϸ�
    JZ OVER
    CALL PRINT_LINE  ;����
    
STEP1:
    LEA DX,TIPS2  ;�����ʾ��2
    MOV AH,9
    INT 21H
    
    LEA  BX,BUF2  ;BXָ��BUF2
    CALL INPUT  ;����ڶ�����
    CMP CX,0FFH
    JZ STEP1     ;���ڶ��������Ϸ�����������ڶ�����
    
    CALL PRINT_LINE  ;����
    
    LEA  BX,BUF1+2       ;BXָ���ַ�����ʼ��ַ����ƫ����Ϊ2�ĵط���ʼ
    CALL PRINT_BINARY   ;�����һ�����Ķ�������ʽ
    
    MOV NUM,0            ;ż��������Ϊ0
    MOV AL,BINARY_BUF[18] ;ALȡ�������һ��Ԫ��
    AND AL,1              ;��1��λ���ֻ�������һλ
    CMP AL,1              ;�Ƚ�ĩλ�Ƿ�Ϊ1����������ת
    JZ STEP2
    INC NUM              ;ĩλΪ0��ż��������1
    CALL PRINT_DECIMAL   ;���������ʮ������ʽ
    
STEP2:
    LEA  BX,BUF2+2
    CALL PRINT_BINARY    ;����ڶ������Ķ�������ʽ
    MOV AL,BINARY_BUF[18] ;ALȡ�������һ��Ԫ��
    AND AL,1           ;��1��λ���ֻ�������һλ
    CMP AL,1          ;�Ƚ�ĩλ�Ƿ�Ϊ1����������ת
    JZ STEP3
    INC NUM            ;ĩλΪ0��ż��������1
    CALL PRINT_DECIMAL   ;���������ʮ������ʽ

STEP3:
	CMP NUM,0      ;��ż��������Ϊ0������ת����
	JNZ OVER3
	LEA DX,TIPS_NO  ;ż������Ϊ0�������ʾ��
    MOV AH,9
    INT 21H
	   
OVER3:    
    JMP OVER
      
;����  
PRINT_LINE PROC
	LEA DX,LINE   ;����
    MOV AH,9
    INT 21H
	RET
PRINT_LINE ENDP

;���벢���Ϸ���     
INPUT PROC
 	MOV DX,BX   ;�����ַ���
    MOV AH,10   
    INT 21H
	
	MOV SI,1
	MOV CL,[BX][SI] ;�Ĵ������Ѱַ
	CMP CL,4       ;�����Ȳ�Ϊ4��Ƿ�
	JNE ERROR
CHECK:
	INC SI        ;�ַ�����ƫ����Ϊ2�ĵط���ʼ
	MOV AL,[BX][SI]
	CMP AL,30H   ;��С��0��Ƿ�
	JB ERROR
	CMP AL,39H   ;��С��9��Ϸ�
	JNA AGAIN 
	CMP AL,41H   ;����9��С��A��Ƿ�
	JB ERROR
	CMP AL,46H   ;��С��F��Ϸ�
	JNA AGAIN
	CMP AL,61H   ;����fС��a�Ƿ�
	JB ERROR    
	CMP AL,66H   ;����f�Ƿ�
	JA ERROR
AGAIN:
	LOOP CHECK    ;���������һ���ַ�
	JMP OVER1
ERROR:
	LEA DX,TIPS3  ;�����ʾ��3
    MOV AH,9
    INT 21H
    
	MOV CX,0FFH ;��CXΪ0FFH
OVER1:
	RET        ;����
INPUT ENDP

;�Զ�������ʽ���
PRINT_BINARY PROC
;ѭ���Ĵν������ַ�תΪ��Ӧʮ������
	MOV CX,4     
	MOV SI,0     ;SIΪBXƫ����
COMPER1:
	MOV AL,[BX][SI] ;AL���δ��ÿ���ַ�
	CMP AL,39H    ;�ж��Ƿ�Ϊ����
	JNA CHANGE1
	CMP AL,46H   ;�ж��Ƿ�Ϊ��д��ĸA-F
	JNA CHANGE2
	CMP AL,66H   ;�ж��Ƿ�ΪСд��ĸa-f
	JNA CHANGE3
CHANGE1:
	SUB AL,30H    ;��Ϊ���֣���30H��ASCIIת��Ϊʵ������
	JMP LOP
CHANGE2:
	SUB AL,37H    ;��ΪA-F����37H��ASCIIת��Ϊʵ������
	JMP LOP
CHANGE3:
	SUB AL,57H    ;��Ϊa-f����57H��ASCIIת��Ϊʵ������
LOP:
	MOV [BX][SI],AL  ;��ת�����ʮ�����ƴ���ԭ����
	INC SI
	LOOP COMPER1     ;�����ȽϺ�ת����һ���ַ�
	
;��ʮ������תΪ���������    
	MOV DX,0       ;��ѭ������
	MOV SI,0       
TRANS1:
	MOV CX,4       ;��ѭ������
	MOV AL,[BX][SI]
	ROL AL,1       ;ѭ����λ�ĴΣ�ʹAL����λ���Ƶ�����λ
	ROL AL,1
	ROL AL,1
	ROL AL,1
	PUSH SI      ;���棬��Ϊ�����ʹSI��ALֵ�ı�
	PUSH AX
	MOV AX,DX     ;AX�����ѭ������
	MOV SI,AX     ;�Ƚ�AX������SI��
	SAL AX,1      ;����һλ�൱��*2
	SAL AX,1
	ADD SI,AX    ;��Ϊÿ��ʮ��������תΪ4λ��������
	POP AX       ;����4λ��Ӹ��ո��Ա����������SI=DX*5
TRANS2:	
	ROL AL,1     ;����һλ
	PUSH DX      ;����DX
	MOV DL,0     ;DL����
	ADC DL,30H   ;DL<-(DL)+30H+CF
	MOV BINARY_BUF[SI],DL  ;����ÿλ��������
	INC SI
	POP DX       ;�ָ�DX
	LOOP TRANS2  ;������ѭ��
	MOV BINARY_BUF[SI],' ' ;�Ӹ��ո��Ա�У��
	POP SI      ;�ָ�SI
	INC DX      ;��ѭ������+1
	INC SI     ;ƫ����+1
	CMP DX,4   ;4��ʮ����������������ѭ���ĴΣ�û���Ĵμ���ѭ��
	JB TRANS1  
		
	;MOV BINARY_BUF[SI],'$'	
	LEA DX,TIPS_B ;�����ʾ��
    MOV AH,9
    INT 21H
	
	LEA DX,BINARY_BUF ;���������
    MOV AH,9
    INT 21H
    CALL PRINT_LINE   ;����
OVER2:
	RET    ;����
PRINT_BINARY ENDP

PRINT_DECIMAL PROC
	XOR AX,AX   ;����
	MOV SI,0    ;SIΪBXƫ����
TO_BIN:
	XOR DX,DX     ;����
	MOV DL,[BX][SI]  ;DL��ÿһ����ת�����ʮ��������
	MOV CL,4         
	SHL AX,CL        ;AX����4λ
	ADD AX,DX        ;��4λ����ÿ��ʮ��������
	INC SI
	CMP SI,4         ;��ѭ���Ĵ� 
	JNZ TO_BIN       ;ѭ��������AX��ŵ�����λʮ��������

	MOV SI,0    ;SIΪDECIMAL_BUF����ƫ����
	MOV CX,10   
TURN_IN:
	XOR DX,DX     ;���㣬�����������
	DIV CX        ;��10ȡ��õ�����λ�ϵ���ֵ
	ADD DL,30H    ;����ת��ΪASCII
	MOV DECIMAL_BUF[SI],DL   ;��������
	INC SI
	CMP AX,0      ;��Ϊ0���㷨����
	JA TURN_IN
	
	LEA DX,TIPS_D ;�����ʾ��
    MOV AH,9
    INT 21H		
TURN_OUT: 
	DEC SI                  ;SIΪԪ�ظ��� 
    MOV DL,DECIMAL_BUF[SI]  ;��������������Ϊ����
    MOV AH,2                ;�������������λ�ϵ���ֵ
    INT 21H
    CMP SI,0               ;SIΪ0˵�����һ���������
    JNZ TURN_OUT
    
    CALL PRINT_LINE   ;����
	RET              ;����
PRINT_DECIMAL ENDP

OVER:
	CALL PRINT_LINE  ;����
	JMP START    ;���¿�ʼ
	    
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START