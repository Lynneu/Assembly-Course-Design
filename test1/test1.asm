;Ĭ�ϲ���ML6.11������
DATAS SEGMENT
    ;�˴��������ݶδ���
TIPS1 DB 'Enter Your First String:$'
TIPS2 DB 'Enter Your Second String:$'
BUF1  DB 255        ;����������
      DB ?          ;ʵ���������
      DB 255 DUP('$') ;�洢�ռ�
BUF2  DB 255        ;����������
      DB ?          ;ʵ���������
      DB 255 DUP('$') ;�洢�ռ�
CRLF  DB 0AH,0DH,'$'  ;����
DATAS ENDS

STACKS SEGMENT PARA STACK
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
    
    LEA DX,BUF1   ;�����һ���ַ���
    MOV AH,10
    INT 21H
     
    LEA DX,CRLF   ;����
    MOV AH,9
    INT 21H
    
    LEA DX,TIPS2  ;�����ʾ��2
    MOV AH,9
    INT 21H
    
    LEA DX,BUF2   ;����ڶ����ַ���
    MOV AH,10
    INT 21H
    
    LEA DX,CRLF   ;����
    MOV AH,9
    INT 21H
    
    MOV CL,BUF1[1]  ;��cx��ѭ�������������Ͳ�ƥ�䣬�����
    CMP CL,BUF2[1]  ;�Ƚ������ַ�������
    JE COMPARE     ;���������ת�����αȽ��ַ�
    JMP NO         ;���Ȳ������ֱ����ת���
    
COMPARE:
	MOV SI,1       
LOP:
    INC SI           ;SI=SI+1
    MOV AL,BUF1[SI]  ;�ַ�����ƫ����Ϊ2�ĵط���ʼ
    CMP AL,BUF2[SI]  ;���αȽ��ַ�
    JNE NO        ;���������ת��NO
    LOOP LOP      ;���������Ƚ���һ���ַ�
    JMP YES       ;������������ת��YES
    
NO: MOV DL,'N'    ;�����N��
    MOV AH,2
    INT 21H
    JMP OVER    
    
YES:MOV DL,'Y'    ;�����Y��
	MOV AH,2
    INT 21H
    JMP OVER       
    
OVER:
	LEA DX,CRLF   ;����
    MOV AH,9
    INT 21H
    JMP START   ;���¿�ʼ
    
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START