;Ĭ�ϲ���ML6.11������
DATAS SEGMENT
    ;�˴��������ݶδ���  
TIPS1 DB 'Your lowercase String:',13,10,'$'
TIPS2 DB 'Turn Uppercase String:',13,10,'$'
TIPS3 DB 'Error Input! Try again!',13,10,'$'
BUF   DB 255        ;����������
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
     
    LEA DX,BUF   ;�����ַ���
    MOV AH,10
    INT 21H
    
    LEA DX,CRLF   ;����
    MOV AH,9
    INT 21H
    
    MOV SI,1
    MOV CL,BUF[1] ;��cx��ѭ�������������Ͳ�ƥ�䣬�����
                  ;CL����ַ�������
TRANS:
	INC SI
	MOV AL,BUF[SI]  ;�ַ�����ƫ����Ϊ2�ĵط���ʼ
	CMP AL,97       ;С��a���Ϸ�
	JB ERROR
	CMP AL,122     ;����z���Ϸ�
	JA ERROR
	SUB AL,32      ;תΪ��Ӧ��д��ĸ
	MOV BUF[SI],AL ;�滻ԭ�ַ�����
	LOOP TRANS     ;������Ⲣת����һ���ַ�
	MOV BUF[SI+1],'$'  ;�ַ�������$��β
	JMP PRIN      ;ת����ɣ���ת�����
	  
ERROR:    
    LEA DX,TIPS3  ;�����ʾ��3
    MOV AH,9
    INT 21H
	JMP OVER
		
PRIN:
	LEA DX,TIPS2  ;�����ʾ��2
    MOV AH,9
    INT 21H

    LEA DX,BUF[2]  ;���ת������ַ���
    MOV AH,9
    INT 21H
    
    LEA DX,CRLF  ;����
    MOV AH,9
    INT 21H
    
OVER:
	LEA DX,CRLF  ;����
    MOV AH,9
    INT 21H
    
    JMP START
    
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START