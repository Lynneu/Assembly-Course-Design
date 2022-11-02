;默认采用ML6.11汇编程序
DATAS SEGMENT
    ;此处输入数据段代码  
TIPS1 DB 'Enter Six Number:',13,10,'$'
TIPS2 DB 'Error Input! Try again!',13,10,'$'
TIPS3 DB 'After Sorting:',13,10,'$'
TIPS4 DB 'The Sum is: ',13,10,'$'
NUM   DB 10        ;缓冲区长度
      DB ?          ;实际输入个数
      DB 10 DUP('$') ;存储空间
NUM_Dec DB 10 DUP('$') ;存放3组数据
SUM   DB 8 DUP(' ')   ;数据和
TEN_DB   DB 10        ;8位10
TEN_DW   DW 10        ;16位10
LINE  DB 0AH,0DH,'$'  ;换行
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
    
    LEA BX,NUM        ;BX指向输入的字符串
    CALL INPUT_DEC    ;输入并检查合法性
    CMP CX,0FFH       ;若CX被置为0FFH则不合法
    JZ OVER
    CALL PRINT_LINE   ;换行
    
    LEA BX,NUM+2      ;BX指向字符串起始地址
    CALL TRANSITION   ;将6位十进制数转换为3个2位十进制数
    
    LEA BX,NUM_Dec    ;BX指向存放二位十进制数的数组
    CALL NUM_SUM      ;计算总和并输出
    
    CALL PRINT_SORT   ;排序并输出结果
    
    JMP OVER
;主程序结束
;输入6位十进制数并检查合法性    
INPUT_DEC PROC
	MOV DX,BX    ;输入十进制数
    MOV AH,10     
    INT 21H

	MOV SI,1
 	MOV CL,[BX][SI]  ;寄存器相对寻址
    CMP CL,6         ;若长度不为6则非法
    JNE ERROR
CHECK:
 	INC SI          ;字符串从偏移量为2的地方开始
	MOV AL,[BX][SI] ;AL依次存每个数
	CMP AL,30H      ;若小于0则非法
 	JB ERROR
 	CMP AL,39H      ;若大于9则非法
 	JA ERROR
 	LOOP CHECK  
    JMP EXIT        ;比较结束，合法，跳转至出口
ERROR:
	MOV CX,0FFH   ;置CX为0FFH
 	LEA DX,TIPS2  ;输出提示语2
    MOV AH,9
    INT 21H
EXIT: RET    ;返回   
INPUT_DEC ENDP 

;将6位十进制数转换为3个2位十进制数
TRANSITION PROC    
    MOV CX,3   ;三个数，循环三次
	MOV SI,5   ;从末位开始
   	MOV DI,0   ;NUM_Dec数组的偏移量
   	XOR AX,AX   ;清零
   	XOR DX,DX  
TRAN:
	MOV AL,[BX][SI] ;取十位
	SUB AL,30H      ;转为数字
	MUL TEN_DB      ;乘10
 	MOV DL,[BX][SI-1] ;取个位
 	SUB DL,30H       ;转为数字
 	ADD AL,DL        ;十位加上个位
 	MOV NUM_Dec[DI],AL  ;转换后的二位十进制数存入数组
    INC DI
    SUB SI,2        ;偏移量每次减2
    LOOP TRAN 
	RET             ;返回
TRANSITION ENDP

;计算总和并输出
NUM_SUM PROC
    LEA DX,TIPS4  ;输出提示语4
    MOV AH,9
    INT 21H
    
    XOR AX,AX   ;清零
    MOV SI,0    ;SI为BX偏移量
PLUS:
	XOR DX,DX   ;清零
	MOV DL,[BX][SI] ;取一个数存在DL中
  	ADD AX,DX       ;AX依次加上三个数
 	INC SI
 	CMP SI,3       ;没加到3个数则继续循环
 	JNZ PLUS
 	
 	MOV SI,0
TURN_SUM:
	XOR DX,DX      ;清零
	DIV TEN_DW     ;除10取余得到各个位上的数值，余数存放在DL中
	ADD DL,30H     ;余数转换为ASCII
	MOV SUM[SI],DL ;存入数组
	INC SI
	CMP AX,0      ;商为0则算法结束
	JA TURN_SUM
PRINT_SUM:
	DEC SI          ;SI为数组中元素个数 
	MOV DL,SUM[SI]  ;按存放逆序输出即为正序
	MOV AH,2        ;依次输出各个数位上的数值
	INT 21H
	CMP SI,0        ;SI为0说明最后一个数已输出
	JNZ PRINT_SUM 

    CALL PRINT_LINE   ;换行
	RET               ;返回
NUM_SUM ENDP

PRINT_SORT PROC
;冒泡排序
	MOV CX,2   ;三个数，外层循环执行2次
SORT1:
	MOV SI,0   ;清零
	MOV DI,0	
SORT2:
	MOV AL,[BX][SI]    ;取第一个元素
	MOV DL,[BX][SI+1]  ;取第二个元素
	CMP AL,DL    ;比较第一个元素和第二个元素的大小，若前者更大则跳转
	JNB SORT3
	MOV [BX][SI],DL  ;若前者更小，则交换
	MOV [BX][SI+1],AL
SORT3:
	INC SI      ;偏移量加1
	INC DI	    ;计数加1
	CMP DI,CX   ;DI记录内层循环个数，若DI<CX,继续比较后面的元素
	JB SORT2
	LOOP SORT1   ;内层循环结束，开始下一次外层循环
	
;输出排序后的数
	LEA DX,TIPS3  ;输出提示语3
    MOV AH,9
    INT 21H

	MOV CX,3     ;循环三次
	MOV SI,0    ;SI为BX偏移量
OUTPUT:
	XOR AX,AX    ;清零
	XOR DX,DX
	MOV AL,[BX][SI]  ;取一个数存在AL中
	DIV TEN_DB       ;除以10,字节除法余数在AH中
	MOV DL,AL        ;商在AL中
	CMP DL,0         ;若商为0说明十位为0，跳转输出个位
	JZ OUTPUT2 
	ADD DL,30H       ;商不为0，转换为ASCII输出十位
	PUSH AX          ;保存，因为下面会使AH值改变
	MOV AH,2
	INT 21H
	POP AX           ;恢复AX
OUTPUT2:
	MOV DL,AH      ;将余数存在DL中
	ADD DL,30H     ;转换为ASCII输出十位
	MOV AH,2
	INT 21H
	
	MOV DX,20H	   ;输出一个空格
	MOV AH,2
	INT 21H
	
	INC SI
	LOOP OUTPUT    ;继续输出下一个数
	
	CALL PRINT_LINE  ;换行
	RET	
PRINT_SORT ENDP

PRINT_LINE PROC
 	LEA DX,LINE   ;换行
    MOV AH,9
    INT 21H
 RET
PRINT_LINE ENDP
 
OVER:
 CALL PRINT_LINE  ;换行
 JMP START        ;重新开始
 
 MOV AH,4CH
 INT 21H
CODES ENDS
    END START