;默认采用ML6.11汇编程序
DATAS SEGMENT
    ;此处输入数据段代码
TIPS1 DB 'Enter Your First String:$'
TIPS2 DB 'Enter Your Second String:$'
BUF1  DB 255        ;缓冲区长度
      DB ?          ;实际输入个数
      DB 255 DUP('$') ;存储空间
BUF2  DB 255        ;缓冲区长度
      DB ?          ;实际输入个数
      DB 255 DUP('$') ;存储空间
CRLF  DB 0AH,0DH,'$'  ;换行
DATAS ENDS

STACKS SEGMENT PARA STACK
    ;此处输入堆栈段代码
    DW 20H DUP(0)
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    ;此处输入代码段代码
    
    LEA DX,TIPS1  ;输出提示语1
    MOV AH,9
    INT 21H
    
    LEA DX,BUF1   ;输入第一个字符串
    MOV AH,10
    INT 21H
     
    LEA DX,CRLF   ;换行
    MOV AH,9
    INT 21H
    
    LEA DX,TIPS2  ;输出提示语2
    MOV AH,9
    INT 21H
    
    LEA DX,BUF2   ;输入第二个字符串
    MOV AH,10
    INT 21H
    
    LEA DX,CRLF   ;换行
    MOV AH,9
    INT 21H
    
    MOV CL,BUF1[1]  ;用cx做循环计数由于类型不匹配，会出错
    CMP CL,BUF2[1]  ;比较两个字符串长度
    JE COMPARE     ;长度相等跳转至依次比较字符
    JMP NO         ;长度不相等则直接跳转输出
    
COMPARE:
	MOV SI,1       
LOP:
    INC SI           ;SI=SI+1
    MOV AL,BUF1[SI]  ;字符串从偏移量为2的地方开始
    CMP AL,BUF2[SI]  ;依次比较字符
    JNE NO        ;不相等则跳转至NO
    LOOP LOP      ;相等则继续比较下一个字符
    JMP YES       ;遍历结束，跳转至YES
    
NO: MOV DL,'N'    ;输出‘N’
    MOV AH,2
    INT 21H
    JMP OVER    
    
YES:MOV DL,'Y'    ;输出‘Y’
	MOV AH,2
    INT 21H
    JMP OVER       
    
OVER:
	LEA DX,CRLF   ;换行
    MOV AH,9
    INT 21H
    JMP START   ;重新开始
    
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START