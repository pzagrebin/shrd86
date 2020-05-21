cpu 8086

NUM_CONTEXTS equ 1024
INIT_ONE_PROB equ 0x8000
ADJUST_SHIFT equ 4

;This is depacker aimed for 8088/86.
;It decompress data compressed with Shrinkler with --data option.
;Optimized for size, 177 bytes.

;How to use:
;ds:si - must point to byte 0x80 immediately followed by compressed data block
;es:di - decompressed data goes here, value in di must be even!
;Then call shrd86_decompress. It will return decompressed data size in ax.
;It will clear compressed data block (fills it with zeroes)
;and will destroy up to two bytes after it.

shrd86_decompress:
cld
push di
mov cx, NUM_CONTEXTS
mov ax, INIT_ONE_PROB
.init_prob:
push ax
loop .init_prob
mov [cs:prob_base+2], sp ;store table pointer by modifying dummy constant
push ax ;make room for offset variable

;range decoder state
xor bp, bp
inc cx
;bp=0 - base
;cx=1 - range

xor bx, bx
.lit:
;bl=0 after getkind
inc bx
.getlit:
call getbit
adc bl, bl
jnc .getlit
xchg ax, bx
stosb

call getkind
jnc .lit
mov bh, 2
call getbit
jnc .readoff
.readlen:
mov bh, 2
call getnum
pop bx ;offset value can be reused later, must be saved
push bx
.copy:
mov al, [es:di+bx]
stosb
dec dx
jnz .copy

call getkind
jnc .lit
.readoff:
mov bh, 3
call getnum
neg dx
inc dx
inc dx ;offset=2-getnum()
pop ax
push dx ;save ofset value
jnz .readlen

.end:
add sp, NUM_CONTEXTS*2+2
pop ax
sub di, ax
xchg ax, di
ret

readbit:
shl byte [si], 1
jnz .nonewbyte
inc si
;cf=1
rcl byte [si], 1
.nonewbyte:
adc bp, bp
add cx, cx

getbit:
test cx, cx
jns readbit
push bx
add bx, bx
prob_base:
add bx, 0xDEAD ;this constant will be rewritten by actual sp value
mov ax, [ss:bx]
push cx
mov cl, ADJUST_SHIFT
shr ax, cl
pop cx
sub [ss:bx], ax
add ax, [ss:bx]
mul cx
sub bp, dx
jc .one
sub cx, dx
pop bx
ret
.one:
add word [ss:bx], 0xFFFF>>ADJUST_SHIFT
mov cx, dx
add bp, dx
pop bx
ret

getkind:
mov bx, 1
and bx, di ;di value is used as context
           ;and Shrinkler assumes it's even for the first byte
xchg bh, bl
call getbit
ret

getnum:
.numloop:
inc bx
call getbit
jc .numloop
neg bl
mov dx, 1
.bitloop:
push dx
call getbit
pop dx
adc dx, dx
inc bl
jnz .bitloop
ret
