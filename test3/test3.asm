;默认采用ML6.11汇编程序
DATAS SEGMENT
    ;此处输入数据段代码 
TIPS1 DB 'Your First String:',13,10,'$'
TIPS2 DB 'Your Second String:',13,10,'$'
TIPS3 DB 'Error Input! Try again!',13,10,'$'
TIPS_B  DB 'Corresponding Binary Number: $'
TIPS_D  DB 'Corresponding Decimal Number: $'
TIPS_NO DB 'NO',13,10,'$'
BUF1  DB 255          ;存第一个数
      DB ?
      DB 255 DUP('$')
BUF2  DB 255          ;存第二个数
      DB ?
      DB 255 DUP('$')
BINARY_BUF DB 255 DUP('$') ;存转换后的二进制数
DECIMAL_BUF DB 6 DUP('$')  ;存转换后的十进制数
NUM DB 0                ;记录偶数个数
LINE  DB 0AH,0DH,'$'   ;换行
DATAS ENDS

STACKS SEGMENT
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
    
    LEA  BX,BUF1  ;BX指向BUF1
    CALL INPUT  ;输入第一个数
    CMP CX,0FFH ;若CX被置为0FFH则不合法
    JZ OVER
    CALL PRINT_LINE  ;换行
    
STEP1:
    LEA DX,TIPS2  ;输出提示语2
    MOV AH,9
    INT 21H
    
    LEA  BX,BUF2  ;BX指向BUF2
    CALL INPUT  ;输入第二个数
    CMP CX,0FFH
    JZ STEP1     ;若第二个数不合法则重新输入第二个数
    
    CALL PRINT_LINE  ;换行
    
    LEA  BX,BUF1+2       ;BX指向字符串起始地址，从偏移量为2的地方开始
    CALL PRINT_BINARY   ;输出第一个数的二进制形式
    
    MOV NUM,0            ;偶数个数置为0
    MOV AL,BINARY_BUF[18] ;AL取数组最后一个元素
    AND AL,1              ;和1按位与后只保留最后一位
    CMP AL,1              ;比较末位是否为1，若是则跳转
    JZ STEP2
    INC NUM              ;末位为0，偶数个数加1
    CALL PRINT_DECIMAL   ;输出该数的十进制形式
    
STEP2:
    LEA  BX,BUF2+2
    CALL PRINT_BINARY    ;输出第二个数的二进制形式
    MOV AL,BINARY_BUF[18] ;AL取数组最后一个元素
    AND AL,1           ;和1按位与后只保留最后一位
    CMP AL,1          ;比较末位是否为1，若是则跳转
    JZ STEP3
    INC NUM            ;末位为0，偶数个数加1
    CALL PRINT_DECIMAL   ;输出该数的十进制形式

STEP3:
	CMP NUM,0      ;若偶数个数不为0，则跳转结束
	JNZ OVER3
	LEA DX,TIPS_NO  ;偶数个数为0，输出提示语
    MOV AH,9
    INT 21H
	   
OVER3:    
    JMP OVER
      
;换行  
PRINT_LINE PROC
	LEA DX,LINE   ;换行
    MOV AH,9
    INT 21H
	RET
PRINT_LINE ENDP

;输入并检查合法性     
INPUT PROC
 	MOV DX,BX   ;输入字符串
    MOV AH,10   
    INT 21H
	
	MOV SI,1
	MOV CL,[BX][SI] ;寄存器相对寻址
	CMP CL,4       ;若长度不为4则非法
	JNE ERROR
CHECK:
	INC SI        ;字符串从偏移量为2的地方开始
	MOV AL,[BX][SI]
	CMP AL,30H   ;若小于0则非法
	JB ERROR
	CMP AL,39H   ;若小于9则合法
	JNA AGAIN 
	CMP AL,41H   ;大于9且小于A则非法
	JB ERROR
	CMP AL,46H   ;若小于F则合法
	JNA AGAIN
	CMP AL,61H   ;大于f小于a非法
	JB ERROR    
	CMP AL,66H   ;大于f非法
	JA ERROR
AGAIN:
	LOOP CHECK    ;继续检查下一个字符
	JMP OVER1
ERROR:
	LEA DX,TIPS3  ;输出提示语3
    MOV AH,9
    INT 21H
    
	MOV CX,0FFH ;置CX为0FFH
OVER1:
	RET        ;返回
INPUT ENDP

;以二进制形式输出
PRINT_BINARY PROC
;循环四次将输入字符转为对应十六进制
	MOV CX,4     
	MOV SI,0     ;SI为BX偏移量
COMPER1:
	MOV AL,[BX][SI] ;AL依次存放每个字符
	CMP AL,39H    ;判断是否为数字
	JNA CHANGE1
	CMP AL,46H   ;判断是否为大写字母A-F
	JNA CHANGE2
	CMP AL,66H   ;判断是否为小写字母a-f
	JNA CHANGE3
CHANGE1:
	SUB AL,30H    ;若为数字，减30H由ASCII转换为实际数字
	JMP LOP
CHANGE2:
	SUB AL,37H    ;若为A-F，减37H由ASCII转换为实际数字
	JMP LOP
CHANGE3:
	SUB AL,57H    ;若为a-f，减57H由ASCII转换为实际数字
LOP:
	MOV [BX][SI],AL  ;将转换后的十六进制存入原数组
	INC SI
	LOOP COMPER1     ;继续比较和转换下一个字符
	
;将十六进制转为二进制输出    
	MOV DX,0       ;外循环次数
	MOV SI,0       
TRANS1:
	MOV CX,4       ;内循环次数
	MOV AL,[BX][SI]
	ROL AL,1       ;循环移位四次，使AL低四位左移到高四位
	ROL AL,1
	ROL AL,1
	ROL AL,1
	PUSH SI      ;保存，因为下面会使SI和AL值改变
	PUSH AX
	MOV AX,DX     ;AX存放外循环次数
	MOV SI,AX     ;先将AX保存在SI中
	SAL AX,1      ;左移一位相当于*2
	SAL AX,1
	ADD SI,AX    ;因为每个十六进制数转为4位二进制数
	POP AX       ;存完4位后加个空格以便输出，所以SI=DX*5
TRANS2:	
	ROL AL,1     ;左移一位
	PUSH DX      ;保存DX
	MOV DL,0     ;DL清零
	ADC DL,30H   ;DL<-(DL)+30H+CF
	MOV BINARY_BUF[SI],DL  ;存入每位二进制数
	INC SI
	POP DX       ;恢复DX
	LOOP TRANS2  ;继续内循环
	MOV BINARY_BUF[SI],' ' ;加个空格以便校对
	POP SI      ;恢复SI
	INC DX      ;外循环次数+1
	INC SI     ;偏移量+1
	CMP DX,4   ;4个十六进制数，所以外循环四次，没到四次继续循环
	JB TRANS1  
		
	;MOV BINARY_BUF[SI],'$'	
	LEA DX,TIPS_B ;输出提示语
    MOV AH,9
    INT 21H
	
	LEA DX,BINARY_BUF ;输出二进制
    MOV AH,9
    INT 21H
    CALL PRINT_LINE   ;换行
OVER2:
	RET    ;返回
PRINT_BINARY ENDP

PRINT_DECIMAL PROC
	XOR AX,AX   ;清零
	MOV SI,0    ;SI为BX偏移量
TO_BIN:
	XOR DX,DX     ;清零
	MOV DL,[BX][SI]  ;DL存每一个已转换后的十六进制数
	MOV CL,4         
	SHL AX,CL        ;AX左移4位
	ADD AX,DX        ;低4位加上每个十六进制数
	INC SI
	CMP SI,4         ;共循环四次 
	JNZ TO_BIN       ;循环结束后AX存放的是四位十六进制数

	MOV SI,0    ;SI为DECIMAL_BUF数组偏移量
	MOV CX,10   
TURN_IN:
	XOR DX,DX     ;清零，后续存放余数
	DIV CX        ;除10取余得到各个位上的数值
	ADD DL,30H    ;余数转换为ASCII
	MOV DECIMAL_BUF[SI],DL   ;存入数组
	INC SI
	CMP AX,0      ;商为0则算法结束
	JA TURN_IN
	
	LEA DX,TIPS_D ;输出提示语
    MOV AH,9
    INT 21H		
TURN_OUT: 
	DEC SI                  ;SI为元素个数 
    MOV DL,DECIMAL_BUF[SI]  ;按存放逆序输出即为正序
    MOV AH,2                ;依次输出各个数位上的数值
    INT 21H
    CMP SI,0               ;SI为0说明最后一个数已输出
    JNZ TURN_OUT
    
    CALL PRINT_LINE   ;换行
	RET              ;返回
PRINT_DECIMAL ENDP

OVER:
	CALL PRINT_LINE  ;换行
	JMP START    ;重新开始
	    
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START