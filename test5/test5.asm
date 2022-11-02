DATAS SEGMENT
    ;此处输入数据段代码  
TIPS1 DB 'Enter Seven Number Separated By Space:',13,10,'$'
TIPS2 DB 'Error Input! Try again!',13,10,'$'
TIPS3 DB 'The Average Score is: $'
NUM   DB 255        ;缓冲区长度
      DB ?          ;实际输入个数
      DB 255 DUP('$') ;存储空间
NUM_Dec DB 10 DUP(?) ;存放7组数据
AVERAGE DB 10 DUP(?) ;存放平均值
NUM_TEMP DB 10 DUP(?) ;临时数组
TEN_DB  DB 10         ;8位10
TEN_DW  DW 10         ;16位10
HUN_DB  DB 100        ;8位100
LINE  DB 0AH,0DH,'$'  ;换行
DATAS ENDS

STACKS SEGMENT
     DW 20H DUP(0)
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    
    LEA DX,TIPS1  ;输出提示语1
    MOV AH,9
    INT 21H
    
    MOV CX,7          ;循环7次 
    MOV DI,0          ;DI为存放十进制数数组的偏移量
INPUT_7:
    LEA BX,NUM        ;BX指向输入的字符串
    PUSH CX           ;保存CX，子程序中CX会被更改
    CALL INPUT        ;输入并检查合法性
    CMP CX,0FFH       ;若CX被置为0FFH则不合法
    JZ OVER
    POP CX            ;恢复CX
    CALL PRINT_LINE   ;换行
    LOOP INPUT_7      ;循环输入7个数
    
    LEA BX,NUM_Dec     ;BX指向储存7个数的NUM_Dec数组
    CALL SORT          ;排序
    
	CALL PRINT_AVERAGE   ;计算并打印平均值
	JMP OVER

INPUT PROC
	MOV DX,BX    ;输入一个数
    MOV AH,10     
    INT 21H

	XOR DX,DX    ;清零
	MOV SI,1
	MOV CL,[BX][SI]  ;若长度大于3则非法
	CMP CL,3
	JA ERROR
CHECK:
	XOR AX,AX
	INC SI           ;SI=SI+1
	MOV AL,[BX][SI]  ;字符串是从偏移量为2的地方开头
	;MOV BYTE PTR [BX][SI],'$'    ;将原位置置为‘$’
	CMP AL,30H      ;若小于0则非法
 	JB ERROR
 	CMP AL,39H      ;若大于9则非法
 	JA ERROR
 	CMP AL,31H      ;若为0或1则跳转
 	JNA TRANS1
 	CMP CL,3        ;若为2-9之间，则此时若为百位则非法
 	JE ERROR
TRANS1:	
 	SUB AL,30H      ;从ASCII值转换为数字
 	CMP CL,3        ;若为百位，乘100
 	JNZ CHECK2
	MUL HUN_DB	
	JMP CHECK3
CHECK2: 
	CMP CL,2       ;若为十位，乘10
	JNZ CHECK3     ;若为个位，不做处理
 	MUL TEN_DB
CHECK3:
	ADD DL,AL      ;将该数值加入DL中
	LOOP CHECK

CHECK_UPPER:
	CMP DL,100          ;比较输入十进制数是否大于100，大于则非法
	JA ERROR	
	MOV NUM_Dec[DI],DL   ;将转换后的十进制数存入数组中
	INC DI               ;偏移量加1		
	JMP EXIT
	
ERROR:
	CALL PRINT_LINE   ;换行
 	LEA DX,TIPS2  ;输出提示语2
    MOV AH,9
    INT 21H
 	MOV CX,0FFH   ;置CX为0FFH
EXIT: RET         ;返回
INPUT ENDP

;计算并打印平均值
PRINT_AVERAGE PROC
	XOR AX,AX     ;AX清零
	MOV SI,1      ;排序后的数组取下标为1-5的元素相加
	MOV CX,5      ;循环5次
SUM:
	XOR DX,DX       ;DX清零
	MOV DL,[BX][SI] ;取一个数存在DL中
  	ADD AX,DX       ;AX依次加上五个数
  	INC SI          ;偏移量加1
  	LOOP SUM
	
	XOR DX,DX       ;清零
	MOV CX,5
	DIV CX          ;总和除以5
	MOV AVERAGE,AL  ;AL中为整数部分，存入数组
	SHL DL,1        ;余数*10/5，相当于*2，即为小数部分
	MOV AVERAGE[1],DL  ;小数部分存入数组
	
	MOV SI,0       ;SI为临时数组的偏移量
TURN_AVERAGE:
	XOR DX,DX      ;清零
	DIV TEN_DW     ;除10取余得到各个位上的数值，余数存放在DL中
	ADD DL,30H     ;余数转换为ASCII
	MOV NUM_TEMP[SI],DL ;整数部分存入临时数组
	INC SI
	CMP AX,0      ;商为0则算法结束	
	JA TURN_AVERAGE
	
	LEA DX,TIPS3  ;输出提示语3
    MOV AH,9
    INT 21H	
PRINT:
	DEC SI               ;SI为数组中元素个数 
	MOV DL,NUM_TEMP[SI]  ;按存放逆序输出即为正序
	MOV AH,2             ;依次输出各个数位上的数值
	INT 21H
	CMP SI,0            ;SI为0说明最后一个数已输出
	JNZ PRINT
	
	MOV DX,'.'	       ;输出小数点
	MOV AH,2
	INT 21H
	
	XOR DX,DX          ;DX清零，后续要存放小数部分
	MOV DL,AVERAGE[1]  ;输出小数部分
	ADD DL,30H	       ;转换为ASCII
	MOV AH,2
	INT 21H
	RET
PRINT_AVERAGE ENDP

SORT PROC
;冒泡排序
	MOV CX,6   ;七个数，外层循环执行6次
SORT1:
	MOV SI,0   ;BX偏移量
	MOV DI,0   ;内层循环次数
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
	LOOP SORT1  ;内层循环结束，开始下一次外层循环

	RET
SORT ENDP

PRINT_LINE PROC
 	LEA DX,LINE   ;换行
    MOV AH,9
    INT 21H
 	RET
PRINT_LINE ENDP
   
OVER:
	LEA BX,NUM     ;BX指向NUM字符串
	MOV AL,24H     ;AL存‘$’
	MOV SI,0       ;SI为BX偏移量
	MOV CX,255     ;循环次数为缓冲区长度
CLEAR_NUM:            ;重置NUM
	MOV [BX][SI],AL  ;全部重置为‘$’
	INC SI
	LOOP CLEAR_NUM
	
	MOV SI,0        ;SI为偏移量，三个数组长度相等
	MOV CX,10       ;循环十次
CLEAR_ALL:          ;重置三个数组
	MOV NUM_Dec[SI],AL
	MOV AVERAGE[SI],AL
	MOV NUM_TEMP[SI],AL
	INC SI
	LOOP CLEAR_ALL

 	CALL PRINT_LINE ;换行
 	JMP START       ;重新开始
    
    MOV AH,4CH
    INT 21H
CODES ENDS
    END START