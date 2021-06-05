data segment
    ; add your data here! 
    ask_msg db "What would you like to do:", 0Dh,0Ah, '$'
    option1_msg db "(1) Generate 15-bit Hamming Code", 0Dh, 0Ah, '$'
    option2_msg db "(2) Check your 15-bit Hamming Code and correct an error", 0Dh, 0Ah, '$'  
    ask_msg1 db "Your Choice is: $"
    choice_not_valid_msg db "Error: you must choose 1 or 2", 0Dh, 0Ah, 0Ah,'$'
    
    ; Part 1 - Calculating 15 bit hamming code
    enter_data_msg db  0Dh, 0Ah,"Enter Your 11-bit Binary Data: $"
    input db 14 dup(?)  
    not_valid_msg db 0Dh, 0Ah, "The data must be 11 bits and only include 0's and 1's. Please try again:",'$'
    encoded_data dw ?     
    
    ; using masks to isolate the data bits that each parity bit covers
    p1_mask equ 0101010101010101b
    p2_mask equ 0011001100110011b
    p3_mask equ 0000111100001111b
    p4_mask equ 0000000011111111b    
    
    ; using masks to set parity bits in the number
    set_p1 equ 0100000000000000b
    set_p2 equ 0010000000000000b    
    set_p3 equ 0000100000000000b  
    set_p4 equ 0000000010000000b             
    
    output_msg db "Your 15 bit Hamming Code Is: $"
    string_output db 16 dup(?)  
    
    line db 0Dh, 0Ah,"--------------------------------------------------------------------------------", '$'
    
    ; Part 1A - Generating a 16 bit Hamming Code with an extra parity bit
    extra_bit_msg db "Do You Want An Extra Parity Bit? (SECDED Hamming Code) Enter Y/n: $"
    extra_bit_not_valid_msg db 0Dh, 0Ah,"Must Enter 'y' or 'n': $"
    extra_bit_mask equ 1000000000000000b  
    output_msg_extra_bit db "Your 16 bit Hamming Code Is: $"
    string_output_extra_bit db 17 dup(?)
    
    ; Part 2 - Finding and fixing the error in 15 bit hamming code
    hamming_input db 19 dup(?)  
    hamming_code dw ?  
    hamming_input_msg db 0Dh, 0Ah, "Enter Your 15-Bit Hamming Code: $"
    not_valid_part2_msg db 0Dh, 0Ah, "The data must be 15 bits and only include 0's and 1's. Please try again:",'$'
    sum_of_incorrect_parity_pos db 0
    wrong_bit_msg db 0Dh, 0Ah, "The error is in bit No.", ?,?, ". The correct Hamming Code is: $"
    no_errors_msg db 0Dh,0Ah, "The Hamming code you entered has no errors! $"
    fixed_hamming_code dw ?  
    fix_error dw ?                          
    fixed_hamming_string db 15 dup(?), '$'  
    
    ; Part 2A - Fixing an error and finding 2 errors in SECED Hamming Code 
    SECED_input db 20 dup(?)
    SECED_input_msg db 0Dh, 0Ah, "Enter Your 16-Bit Hamming Code: $" 
    SECED_not_valid_msg db 0Dh, 0Ah, "The data must be 16 bits and only include 0's and 1's. Please try again:",'$'
    extra_bit_wrong_msg db 0Dh, 0Ah, "The extra parity bit is wrong. The correct Hamming Code is: $"
    extra_bit db 0                
    is_extra_bit_correct db 0
    cant_correct_errors_msg db 0Dh, 0Ah, "The received data contains a double bit error that can't be corrected. $"      
    fixed_SECED_string db 16 dup(?), '$'
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax

    ; add your code here    
     call welcome_msg ; printing welcome messages
    ; call decoding_SECED_hamming
    ; to-do list               
    ; add progress bar/msg/moving slash/ [**   ] 25%
    ; part 1 - change jmp exit names   
    ; Error in extra parity bit can't be corrected
         
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends       

proc welcome_msg
    pusha
    ; printing welcome messages
    mov ah, 09h
    lea dx, ask_msg ;asking the users what they want to do
    int 21h
    lea dx, option1_msg 
    int 21h
    lea dx, option2_msg
    int 21h   
    lea dx, ask_msg1
    int 21h  
    
    ; input char
    mov ah, 1
    int 21h ; chosen option in al  
    sub al, '0' ; subtracting ascii value of 0
    push ax
    
    ; printing line -------
    lea dx, line
    mov ah, 09h
    int 21h
     
    pop ax ; pop from stack the input 
    cmp al, 2
    je y/n_part2    
    cmp al, 1
    je y/n_part1 
    
    ; if it didn't jump --> input isn't valid
    lea dx, choice_not_valid_msg
    mov ah, 09h
    int 21h    
    jmp welcome_msg ; print again welcome msg
    
    popa
    ret
endp welcome_msg       

; Part 1 - Calculating 15 bit Hamming Code from 11 bit input
proc y/n_part1
    pusha
    ; printing input msg
    lea dx, extra_bit_msg
    mov ah, 09h
    int 21h
    
    ; getting input
    mov ah, 1
    int 21h ; input in al
    
    cmp al, 'y'
    je calculate_SECDED_code_extra_bit
    cmp al, 'Y'
    je calculate_SECDED_code_extra_bit
    cmp al, 'n'
    je calculate_hamming_code
    cmp al, 'N'
    je calculate_hamming_code
    
    ; if hasn't jumped it means that input isn't valid
    ; now we print not valid msg and jmp back to y/n_part1
    ; printing msg
    lea dx, extra_bit_not_valid_msg
    mov ah,09h
    int 21h       
    ; printing line
    lea dx, line
    mov ah, 09h
    int 21h
    
    jmp y/n_part1   
    popa
    ret
endp y/n_part1 

proc calculate_hamming_code
    pusha 
    
    ; calculating hamming code
    call inputs       
    call input_validation
    call convert_input 
    call calculate_p1   
    call calculate_p2    
    call calculate_p3   
    call calculate_p4 
    call convert_to_string  
    call print_hamming_code  
    
    jmp welcome_msg ; run again
    popa   
    ret
endp calculate_hamming_code

proc inputs
    pusha         
    ; printing welcome message
    lea dx, enter_data_msg
    mov ah, 9
    int 21h 
    
    ; getting the inputs
    lea dx, input
    mov bx, dx
    mov [byte ptr bx], 12
    mov ah, 0Ah
    int 21h
    
    ; converting input from string array to number arr
    xor cx, cx
    mov cl, 11       
    mov dx, '0' ;ascii value of 0
remove_ascii:       
    lea bx, [input+1]
    xor ch, ch
    add bx, cx
    sub [bx], dx
    loop remove_ascii 
    
    popa 
    ret
endp inputs 

proc input_validation
    pusha
    mov cx, 11
    mov dx, '0'
is_valid:   ; making sure that the input is the right length and is binary
    lea bx, [input+1]
    add bx, cx
    cmp [bx], 1
    jne not_1   ; if not 1   
    jmp is1
not_1:
    cmp [bx], 0
    jne not_0 ; and not 0   
    jmp is1
not_0:
    call not_valid        
is1:    
    loop is_valid    
    popa
    ret
endp input_validation 

proc not_valid
    pusha
    ; this proc is used when the input isn't valid 
    
    ; not valid msg
    lea dx, not_valid_msg
    mov ah, 09h
    int 21h 
    
    ; printing line  -----
    lea dx, line
    mov ah, 09h
    int 21h
    
    jmp calculate_hamming_code ; return to start of program because of the non_valid input
    
endp not_valid  
                           
proc convert_input
    pusha
    ; converting the input into an double word with empty spaces for parity bits
    ; p1 is in index 1 in order to avoid confustion
    ; d3 (first data bit) is in index 3         
    mov encoded_data, 0 ; clearing encoded_data beacause we could have already run
    mov cx, 11
    lea DI, input[3]
    ; the loop converts d15 to d5  
convert:    
    ; we copy a digit to the new var and shift it left every time
    mov bx, [DI]   
    xor bh, bh 
    cmp cx, 8  ; if cx == 8 we need to leave a place for p4\p8
    je cx_8
    cmp cx, 1
    je cx_1
    add encoded_data, bx
    shl encoded_data, 1 
    inc DI
    jmp convert_again
cx_8: ; when cx==8 we dont just leave a place for the p8
    shl encoded_data,1
    jmp convert_again
cx_1: ; when cx==1 we copy the element without shifting the var
    add encoded_data, bx
convert_again:          
    loop convert
    
    ; after we finshed copying d15-d5 - we manually copy d3 
    ; d3 is currently 0 so we only need to copy it if its 1
    cmp input[2], 1  ; 
    je d3_1
    jmp return
d3_1:
    or encoded_data, 0001000000000000b    
return:                  
    popa
    ret
endp convert_input  

proc calculate_p1
    pusha              
    ; if we number the bit position from 1b to 1111b --> Parity bit 1 covers all bit positions which have the least significant bit set: 
    ; p1 = parity of (D3, D5, D7, D9, D11, D13, D15)                                                                                       
    ; we use a mask to look only at the data bits that p1 covers   
    mov bx, encoded_data
    and bx, p1_mask
    or  bx, 0 ; seting the flags
    ; jp only checks the first 8 bits so we devide the 16bit word into two parts and xor the result 
    jp p1_1 ; jumps if pf = 1  
    mov dl, 0
    jmp p1_0 ; else (p1 is zero) 
p1_1:    
    mov dl, 1
p1_0:    
    mov bx, encoded_data ;creating a dup of encoded data
    and bx, p1_mask ; putting the mask 
    shr bx, 8 ; moving to right the dup of encoded_data  
    or bx, 0 ; setting the flags
    jp p1_2 ; jumps if pf = 1
    mov dh, 0
    jmp p1_0_1
p1_2:
    mov dh, 1
p1_0_1:        
    xor dh, dl  ; parity bit is in dh 
    ; after calculating the parity bit we add it back to the orignal number
    ; if p1 is 1 --> set the parity bit
    cmp dh, 1
    je set_p1
    jmp p1_0_2 ; p1 is 0
set_p1:
    or encoded_data, set_p1
p1_0_2:
    popa 
    ret
endp calculate_p1

proc calculate_p2
    pusha
    ; if we number the bit position from 1b to 1111b --> Parity bit 2 covers all bit positions which have the second least significant bit set:
    ; p2 = parity of (D3, D6, D7, D10, D11, D14, D15)
    ; we use the mask to isolate the data bits that p2 covers   
    mov bx, encoded_data
    and bx, p2_mask
    or  bx, 0 ; seting the flags
    ; jp only checks the first 8 bits so we devide the 16bit word into two parts and xor the result 
    jp p2_1 ; jumps if pf = 1  
    mov dl, 0
    jmp exit4
p2_1:    
    mov dl, 1
exit4:    
    mov bx, encoded_data ;creating a dup of encoded data
    and bx, p2_mask ; putting the mask 
    shr bx, 8 ; moving to right the dup of encoded_data  
    or bx, 0 ; setting the flags
    jp p2_2 ; jumps if pf = 1
    mov dh, 0
    jmp exit5
p2_2:
    mov dh, 1
exit5:        
    xor dh, dl  ; parity bit is in dh 
    ; after calculating the parity bit we add it back to the orignal number
    ; if p1 is 1 --> set the parity bit
    cmp dh, 1
    je set_p2
    jmp exit6
set_p2:
    or encoded_data, set_p2
exit6:
      
    popa
    ret
endp calculate_p2 

proc calculate_p3
    pusha
    ; if we number the bit position from 1b to 1111b --> Parity bit 3 covers all bit positions which have the third least significant bit set:
    ; p3 = parity of (D5, D6, D7, D12, D13, D14, D15)
    ; we use the mask to isolate the data bits that p2 covers   
    mov bx, encoded_data
    and bx, p3_mask
    or  bx, 0 ; seting the flags
    ; jp only checks the first 8 bits so we devide the 16bit word into two parts and xor the result 
    jp p3_1 ; jumps if pf = 1  
    mov dl, 0
    jmp exit7
p3_1:    
    mov dl, 1
exit7:    
    mov bx, encoded_data ;creating a dup of encoded data
    and bx, p3_mask ; putting the mask 
    shr bx, 8 ; moving to right the dup of encoded_data  
    or bx, 0 ; setting the flags
    jp p3_2 ; jumps if pf = 1
    mov dh, 0
    jmp exit8
p3_2:
    mov dh, 1
exit8:        
    xor dh, dl  ; parity bit is in dh 
    ; after calculating the parity bit we add it back to the orignal number
    ; if p1 is 1 --> set the parity bit
    cmp dh, 1
    je set_p3
    jmp exit9
set_p3:
    or encoded_data, set_p3
exit9:   
    popa
    ret                    
        
endp calculate_p3   

proc calculate_p4
    pusha
    ; if we number the bit position from 1b to 1111b --> Parity bit 3 covers all bit positions which have the third least significant bit set:
    ; p4 = parity of (D9, D10, D11, D12, D13, D14, D15)
    ; we use the mask to isolate the data bits that p2 covers   
    mov bx, encoded_data
    and bx, p4_mask
    or  bx, 0 ; seting the flags
    ; jp only checks the first 8 bits so we devide the 16bit word into two parts and xor the result 
    jp p4_1 ; jumps if pf = 1  
    mov dl, 0
    jmp exit10
p4_1:    
    mov dl, 1
exit10:    
    mov bx, encoded_data ;creating a dup of encoded data
    and bx, p4_mask ; putting the mask 
    shr bx, 8 ; moving to right the dup of encoded_data  
    or bx, 0 ; setting the flags
    jp p4_2 ; jumps if pf = 1
    mov dh, 0
    jmp exit11
p4_2:
    mov dh, 1
exit11:        
    xor dh, dl  ; parity bit is in dh 
    ; after calculating the parity bit we add it back to the orignal number
    ; if p1 is 1 --> set the parity bit
    cmp dh, 1
    je set_p4
    jmp exit12
set_p4:
    or encoded_data, set_p4
exit12:    
    popa
    ret                    
        
endp calculate_p4   

proc convert_to_string
    pusha                              
    ; after we calculate the hamming code we need to convert it back to string
    mov cx, 15 ; pointer of outer loop                                                  
    mov bx, encoded_data ; dup of final hamming code
    lea di, string_output[14]                  
to_string:                                                                              
    shr bx, 1 ; we will every time shift bx to the right and look at the carry flag
    jc carry_1 ; if the carry flag is set then the current number is 1 
    jmp carry_0
carry_1:  
    ; now we move '1' to string  
    mov [di], '1' ; in DI there is the adress of convert_to_string in the current index
    jmp exit_carry1         
carry_0:
    mov [di], '0' ; moving '0' to string
exit_carry1:
    dec DI         
    loop to_string  
    mov string_output[15], '$' ; now adding the $ at the end of the string  
    popa
    ret
endp convert_to_string 

proc print_hamming_code
    pusha
    ; getting cursor position
    mov ah, 03h
    int 10h
    ; setting cursor position     
    add dh, 2 
    mov dl, 0
    mov ah, 02h
    int 10h 
    
    ; printing msg
    lea dx, output_msg
    mov ah, 09h
    int 21h
    
    ; printing hamming code
    lea dx, string_output
    mov ah, 09h
    int 21h      
    
    ; printing --- line
    lea dx, line
    mov ah, 09h
    int 21h
    
    popa
    ret
endp print_hamming_code 
   
; Part 1A - Encoding SECDED Hamming Code with extra parity bit of entire data - 
; **** Explain SECDED ****** 
proc calculate_SECDED_code_extra_bit
    pusha
    ; calculating hamming code as if it was normal
    call inputs       
    call input_validation_1A
    call convert_input 
    call calculate_p1   
    call calculate_p2    
    call calculate_p3   
    call calculate_p4 
    
    call calculate_extra_parity ; after we calculated the parity bits we now need to calculate the parity of the entire data                                                                                                                  
    call convert_to_string_extra_bit
    call print_hamming_code_extra_bit     
    
    jmp welcome_msg ; run again
     
    popa
    ret
endp calculate_SECDED_code_extra_bit

proc input_validation_1A
    pusha
    mov cx, 11
    mov dx, '0'
is_valid_1A:   ; making sure that the input is the right length and is binary
    lea bx, [input+1]
    add bx, cx
    cmp [bx], 1
    jne not_1_1A   ; if not 1   
    jmp is1_1A
not_1_1A:
    cmp [bx], 0
    jne not_0_1A ; and not 0   
    jmp is1
not_0_1A:
    jmp not_valid_1A 
    popa
    ret       
is1_1A:    
    loop is_valid    
    popa
    ret
endp input_validation_1A 

proc not_valid_1A
    pusha
    ; this proc is used when the input isn't valid 
    
    ; not valid msg
    lea dx, not_valid_msg
    mov ah, 09h
    int 21h 
    
    ; printing line  -----
    lea dx, line
    mov ah, 09h
    int 21h
    
    call calculate_SECDED_code_extra_bit ; return to start of program because of the non_valid input
    popa
    ret
endp not_valid_1A  
   
proc calculate_extra_parity
    pusha
    ; after calculating the parity bits we need to calculate the parity of the entire data
    mov bx, encoded_data ; dup of encoded_data
    or bx, 0 ; setting the flags
    jp lower_parity_1 ;  jp only checks the first 8 bits so we devide the 16 bit word into two parts and xor the result  
    mov dl, 0 ; coping the parity of the lower part to dl
    jmp higher_part_parity
lower_parity_1: 
    mov dl, 1 ; coping the parity of the lower part to dl
    jmp higher_part_parity
higher_part_parity: 
    shr bx, 8 
    or bx, 0 ; setting flags
    jp higher_parity_1
    mov dh, 0 ; coping the parity of the higher part to dh  
    jmp set_extra_bit
higher_parity_1:
    mov dh, 1 ; coping the parity of the higher part to dh    
    jmp set_extra_bit 
set_extra_bit:
    xor dl, dh ; after calculating the parity of the higher and lower parts we xor them to get the pairy of the whole data
    cmp dl, 1 ; currently the bit is 0, we only need to change it if its 1    
    je extra_bit_1 
    popa ; if its not 1, we can exit from the procedure
    ret
extra_bit_1:
    or encoded_data, extra_bit_mask   ; setting the parity bit in the var    
    popa
    ret
endp calculate_extra_parity    

proc convert_to_string_extra_bit
    pusha                              
    ; after we calculate the hamming code we need to convert it back to string
    mov cx, 16 ; pointer of outer loop                                                  
    mov bx, encoded_data ; dup of final hamming code
    lea di, string_output_extra_bit[15]                  
exit_bit_to_string:                                                                              
    shr bx, 1 ; we will every time shift bx to the right and look at the carry flag
    jc extra_bit_carry_1 ; if the carry flag is set then the current number is 1 
    jmp extra_bit_carry_0
extra_bit_carry_1:  
    ; now we move '1' to string  
    mov [di], '1' ; in DI there is the adress of convert_to_string in the current index
    jmp extra_bit_exit_carry1         
extra_bit_carry_0:
    mov [di], '0' ; moving '0' to string
extra_bit_exit_carry1:
    dec DI         
    loop exit_bit_to_string  
    mov string_output_extra_bit[16], '$' ; now adding the $ at the end of the string  
    popa
    ret
endp convert_to_string_extra_bit 

proc print_hamming_code_extra_bit
    pusha
    ; getting cursor position
    mov ah, 03h
    int 10h
    ; setting cursor position     
    add dh, 2 
    mov dl, 0
    mov ah, 02h
    int 10h 
    
    ; printing msg
    lea dx, output_msg_extra_bit
    mov ah, 09h
    int 21h
    
    ; printing hamming code
    lea dx, string_output_extra_bit
    mov ah, 09h
    int 21h      
    
    ; printing --- line
    lea dx, line
    mov ah, 09h
    int 21h
    
    popa
    ret
endp print_hamming_code_extra_bit    

; Part 2 - Correcting 15 Bit Hamming Code
proc fixing_hamming_code
    pusha             
    call input_hamming
    call hamming_input_check  
    call convert_hamming_input
    call validating_p1 
    call validating_p2 
    call validating_p3
    call validating_p4
    call printing_wrong_data_msg  
    
    jmp welcome_msg ; run again
    popa  
    ret
endp fixing_hamming_code 

proc y/n_part2
    pusha
    ; printing input msg
    lea dx, extra_bit_msg
    mov ah, 09h
    int 21h
    
    ; getting input
    mov ah, 1
    int 21h ; input in al
    
    cmp al, 'y'
    je decoding_SECED_hamming
    cmp al, 'Y'
    je decoding_SECED_hamming
    cmp al, 'n'
    je fixing_hamming_code
    cmp al, 'N'
    je fixing_hamming_code
    
    ; if hasn't jumped it means that input isn't valid
    ; now we print not valid msg and jmp back to y/n_part1
    ; printing msg
    lea dx, extra_bit_not_valid_msg
    mov ah,09h
    int 21h       
    ; printing line
    lea dx, line
    mov ah, 09h
    int 21h
    
    jmp y/n_part1   
    popa
    ret
endp y/n_part2 

proc input_hamming
    pusha  
    ; getting 15-bit Hamming code input
    ; printing welcome msg
    lea dx, hamming_input_msg
    mov ah, 09h
    int 21h
    
    ; getting the inputs
    lea dx, hamming_input
    mov bx, dx
    mov [byte ptr bx], 16
    mov ah, 0Ah
    int 21h
    
    ; converting input from string array to number arr
    xor cx, cx
    mov cl, 15       
    mov dx, '0' ;ascii value of 0
remove_ascii_p2:       
    lea bx, [hamming_input+1]
    xor ch, ch
    add bx, cx
    sub [bx], dx
    loop remove_ascii_p2 
    popa
    ret
endp input_hamming

proc hamming_input_check
    pusha 
    ; checking the inputed hamming code input is valid
    mov cx, 15
    mov dx, '0'
is_dig_valid:   ; making sure that the input is the right length and is binary
    lea bx, [hamming_input+1]
    add bx, cx
    cmp [bx], 1
    jne dig_not_1   ; if not 1   
    jmp is_dig_1
dig_not_1:
    cmp [bx], 0
    jne dig_not_0 ; and not 0   
    jmp is_dig_1
dig_not_0:
    call dig_not_valid        
is_dig_1:    
    loop is_dig_valid    
    popa
    ret
endp hamming_input_check    

proc dig_not_valid
    pusha
    ; this proc is used when the input isn't valid 
    ; not valid msg
    lea dx, not_valid_part2_msg
    mov ah, 09h
    int 21h 
    
    ; printing line  -----
    lea dx, line
    mov ah, 09h
    int 21h
    
    jmp fixing_hamming_code ; return to start of proc because of the non_valid input
    
    popa
    ret
endp dig_not_valid  

proc convert_hamming_input
    pusha          
    mov hamming_code, 0 ; clearing hamming_code from last runs
    ; we will convert the input from int array to 2 byte var
    mov cx, 14
    lea DI, hamming_input[2]                                        
hamming_convert:                    
    ; we copy a digit to the new var
    mov bx, [DI]
    xor bh, bh   
    add hamming_code, bx
    shl hamming_code, 1
    inc DI     
loop hamming_convert  
    ; copying the last element manually and not shifting the var
    mov bx, [DI] 
    xor bh, bh   
    add hamming_code, bx
    
    popa
    ret
endp convert_haming_input    
    
proc validating_p1
    pusha
    ; we use a mask to look only at the bits that p1    
    ; p1 = parity of (P1, D3, D5, D7, D9, D11, D13, D15)    
    mov bx, hamming_code
    and bx, p1_mask     
    mov sum_of_incorrect_parity_pos, 0 ; resetting the var at the start of each run of the project
    or bx, 0 ; setting the flags 
    jp validating_p1_1 ; jumps if pf = 1
    mov dl, 0
    jmp validating_p1_0 ; else (p1 is zero)
validating_p1_1:
    mov dl, 1
validating_p1_0:
    ; jump parity only checks the first 8 bits so we devide the 16-bit word into two 8 bit parts and xor the result        
    mov bx, hamming_code ; creating dup of inputed hamming code
    and bx, p1_mask ; putting the mask on bx
    shr bx, 8 ; moving to right in order to look only at second half
    or bx, 0 ; setting the flags
    jp validating_p1_2 ; jumps if pf = 1
    mov dh, 0  
    jmp validating_p1_0_1
validating_p1_2:
    mov dh, 1
validating_p1_0_1:
    xor dh, dl ; parity bit is in dh   
    ; because we included the parity bit itself when calculating the new parity bit --> if its 0: its correct. if its 1: its incorrect
    ; now we check if the parity bit we calculated in dh is 1:
    cmp dh, 1
    je p1_dh_1  
    popa  ; else we ret
    ret
p1_dh_1:  ; if it jumps it means that p1 is wrong
    add sum_of_incorrect_parity_pos, 1 ; we add the wrong parity bit pos to the sum_of_incorrect_parity_pos var 
    popa
    ret
endp validating_p1

proc validating_p2
    pusha         
    ; we use a mask to look only at the bits that p1    
    ; p2 = parity of (P2, D3, D6, D7, D10, D11, D14, D15)      
    mov bx, hamming_code
    and bx, p2_mask
    or bx, 0 ; setting the flags 
    jp validating_p2_1 ; jumps if pf = 1
    mov dl, 0
    jmp validating_p2_0 ; else (p2 is zero)
validating_p2_1:
    mov dl, 1
validating_p2_0:
    ; jump parity only checks the first 8 bits so we devide the 16-bit word into two 8 bit parts and xor the result        
    mov bx, hamming_code ; creating dup of inputed hamming code
    and bx, p2_mask ; putting the mask on bx
    shr bx, 8 ; moving to right in order to look only at second half
    or bx, 0 ; setting the flags
    jp validating_p2_2 ; jumps if pf = 1
    mov dh, 0  
    jmp validating_p2_0_1
validating_p2_2:
    mov dh, 1
validating_p2_0_1:
    xor dh, dl ; parity bit is in dh   
    ; because we included the parity bit itself when calculating the new parity bit --> if its 0: its correct. if its 1: its incorrect
    ; now we check if the parity bit we calculated in dh is 1:
    cmp dh, 1
    je p2_dh_1  
    popa
    ret
p2_dh_1:  ; if it jumps it means that p2 is wrong
    add sum_of_incorrect_parity_pos, 2 ; we add the wrong parity bit pos to the sum_of_incorrect_parity_pos var 
    popa
    ret
endp validating_p2   

proc validating_p3
    pusha         
    ; we use a mask to look only at the bits that p1    
    ; p3 = parity of (P3, D5, D6, D7, D12, D13, D14, D15)      
    mov bx, hamming_code
    and bx, p3_mask
    or bx, 0 ; setting the flags 
    jp validating_p3_1 ; jumps if pf = 1
    mov dl, 0
    jmp validating_p3_0 ; else (p3 is zero)
validating_p3_1:
    mov dl, 1
validating_p3_0:
    ; jump parity only checks the first 8 bits so we devide the 16-bit word into two 8 bit parts and xor the result        
    mov bx, hamming_code ; creating dup of inputed hamming code
    and bx, p3_mask ; putting the mask on bx
    shr bx, 8 ; moving to right in order to look only at second half
    or bx, 0 ; setting the flags
    jp validating_p3_2 ; jumps if pf = 1
    mov dh, 0  
    jmp validating_p3_0_1
validating_p3_2:
    mov dh, 1
validating_p3_0_1:
    xor dh, dl ; parity bit is in dh   
    ; because we included the parity bit itself when calculating the new parity bit --> if its 0: its correct. if its 1: its incorrect
    ; now we check if the parity bit we calculated in dh is 1:
    cmp dh, 1
    je p3_dh_1 
    popa 
    ret
p3_dh_1:  ; if it jumps it means that p3 is wrong
    add sum_of_incorrect_parity_pos, 4 ; we add the wrong parity bit pos to the sum_of_incorrect_parity_pos var 
    popa
    ret
endp validating_p3                

proc validating_p4
    pusha         
    ; we use a mask to look only at the bits that p1    
    ; p4 = parity of (P8, D9, D10, D11, D12, D13, D14, D15)      
    mov bx, hamming_code
    and bx, p4_mask
    or bx, 0 ; setting the flags 
    jp validating_p4_1 ; jumps if pf = 1
    mov dl, 0
    jmp validating_p4_0 ; else (p4 is zero)
validating_p4_1:
    mov dl, 1
validating_p4_0:
    ; jump parity only checks the first 8 bits so we devide the 16-bit word into two 8 bit parts and xor the result        
    mov bx, hamming_code ; creating dup of inputed hamming code
    and bx, p4_mask ; putting the mask on bx
    shr bx, 8 ; moving to right in order to look only at second half
    or bx, 0 ; setting the flags
    jp validating_p4_2 ; jumps if pf = 1
    mov dh, 0  
    jmp validating_p4_0_1
validating_p4_2:
    mov dh, 1
validating_p4_0_1:
    xor dh, dl ; parity bit is in dh   
    ; because we included the parity bit itself when calculating the new parity bit --> if its 0: its correct. if its 1: its incorrect
    ; now we check if the parity bit we calculated in dh is 1:
    cmp dh, 1
    je p4_dh_1  
    popa
    ret
p4_dh_1:  ; if it jumps it means that p4 is wrong
    add sum_of_incorrect_parity_pos, 8 ; we add the wrong parity bit pos to the sum_of_incorrect_parity_pos var 
    popa
    ret
endp validating_p4 

proc printing_wrong_data_msg   
    pusha                                                                
    ; in sum_of_incorrect_parity_pos is the position of the incorrect bit
    ; if it is 0 then there is no error
    cmp sum_of_incorrect_parity_pos, 0
    je print_no_error
    jmp print_error
print_no_error:
    
    ; printing msg
    lea dx, no_errors_msg
    mov ah, 09h
    int 21h
    
    ; printing --- line
    lea dx, line
    mov ah, 09h
    int 21h
    popa
    ret
print_error:                      
    call fixing_error ; fixing the error
    call hamming_to_string ; converting to string
    
    ; printing wrong bit msg  
    ; diving parity bit by 10 in order to print two digit placment
    xor ah, ah
    mov al, sum_of_incorrect_parity_pos 
    mov bl, 10                           
    div bl
    add al, '0'
    add ah, '0'
    mov wrong_bit_msg[25], al
    mov wrong_bit_msg[26], ah 
   
    lea dx, wrong_bit_msg
    mov ah, 09h
    int 21h
    
    ; printing the hamming code
    lea dx, fixed_hamming_string
    mov ah, 09h
    int 21h    
    
    ; printing --- line
    lea dx, line
    mov ah, 09h
    int 21h
            
    popa
    ret
endp printing_wrong_data_msg 

proc fixing_error  
    pusha                               
    ; in order to fix the error we create a mask with 1 in the index of the error and flip (xor) the incorrect bit
    mov ax, hamming_code
    mov fixed_hamming_code, ax
    ; create mask
    mov fix_error, 1
    mov cl, 15
    sub cl, sum_of_incorrect_parity_pos
    xor ch, ch     
    cmp cl, 0 ; if cl is zero we don't need to shift at all, we will jump above in order to avoid an infinite loop
    jne shift_fix_error 
    mov ax, fix_error
    xor fixed_hamming_code, ax ; xor of mask and hamming code
    popa
    ret ; if cx == 0 then we exit
    
shift_fix_error:  
    shl fix_error, 1
    loop shift_fix_error
    mov ax, fix_error
    xor fixed_hamming_code, ax ; xor of mask and hamming code 
            
    popa
    ret
endp fixing_error 

proc hamming_to_string
    pusha
    ; after we fixed the error we the error we need to convert the fixed hamming code into a string
    lea di, fixed_hamming_string
    mov bx, fixed_hamming_code    
    shl bx, 1 ; because the first bit of fixed_hamming_code is not part of the hamming code, we shift before the loop
    mov cx, 15      
convert_hamming:
    shl bx, 1 ; every time we shift the dup of the fixed hamming code and move back the result into the string
    jc carry_set ; if the carry flag is set then the current number is 1     
    jmp carry_not_set
carry_set:
    mov [di], '1' ; in DI there is the 
    jmp exit_convertion
carry_not_set:
    mov [di], '0';  if the carry flag is not set the current number is 0
exit_convertion:
    inc di  
    loop convert_hamming   
    popa
    ret
endp hamming_to_string

; Part 2A - Correcting 1 error and finding 2 errors in SECED Hamming Code
proc decoding_SECED_hamming
    pusha
    ; in order to calculate SECED Hamming code we first verify the hamming code
    ; then we verify the extra parity bit
    ; if some bit is wrong, and the extra bit is wrong, then its a 1 bit error, and we can correct it like regular
    ; if some bit is wrong but the extra parity bit is correct, then its a double error that we can't correct
    call SECED_inputs
    call SECED_input_check  
    call convert_SECED_input
    call validating_p1 
    call validating_p2 
    call validating_p3
    call validating_p4     
    call validating_extra_bit   
    call fixing_SECED_hamming    
    
    ; call printing_wrong_data_msg  
    
    jmp welcome_msg ; run again 
    popa
    ret
endp decoding_SECED_hamming

proc SECED_inputs
    pusha  
    ; Getting 16-bit SECED Hamming Code
    ; printing welcome msg
    lea dx, SECED_input_msg
    mov ah, 09h
    int 21h
    
    ; getting the inputs
    lea dx, SECED_input
    mov bx, dx
    mov [byte ptr bx], 17
    mov ah, 0Ah
    int 21h
    
    ; converting input from string array to number arr
    xor cx, cx
    mov cl, 16       
    mov dx, '0' ;ascii value of 0
remove_ascii_p3:       
    lea bx, [SECED_input+1]
    xor ch, ch
    add bx, cx
    sub [bx], dx
    loop remove_ascii_p3 
    popa
    ret
endp SECED_inputs

proc SECED_input_check
    pusha
    mov cx, 16
    mov dx, '0'
dig_valid:   ; making sure that the input is the right length and is binary
    lea bx, [SECED_input+1]
    add bx, cx
    cmp [bx], 1
    jne cur_dig_not_1   ; if not 1   
    jmp cur_dig_1
cur_dig_not_1:
    cmp [bx], 0
    jne cur_dig_not_0 ; and not 0   
    jmp cur_dig_1
cur_dig_not_0:
    call SECED_not_valid        
cur_dig_1:    
    loop dig_valid    
    popa
    ret
endp SECED_input_check    

proc SECED_not_valid
    pusha
    ; this proc is used when the input isn't valid 
    ; not valid msg
    lea dx, SECED_not_valid_msg
    mov ah, 09h
    int 21h 
    
    ; printing line  -----
    lea dx, line
    mov ah, 09h
    int 21h
    
    jmp decoding_SECED_hamming ; return to start of proc because of the non_valid input
    
    popa
    ret
endp SECED_not_valid  

proc convert_SECED_input
    pusha          
    mov hamming_code, 0 ; clearing hamming_code from last runs
    ; we will convert the input from int array to 2 byte var
    mov cx, 15
    lea DI, SECED_input[2]                                        
SECED_convert:                    
    ; we copy a digit to the new var
    mov bx, [DI]
    xor bh, bh   
    add hamming_code, bx
    shl hamming_code, 1
    inc DI     
loop SECED_convert  
    ; copying the last element manually and not shifting the var
    mov bx, [DI] 
    xor bh, bh   
    add hamming_code, bx
    popa
    ret
endp convert_SECED_input   

proc validating_extra_bit
    pusha   
    ; after validating the parity bits we need to calculate and validate the parity of the entire data
    mov bx, hamming_code ; dup of hamming_input
    shl bx, 1 ; erasing the leftmost extra parity bit - not to ruin new parity check
    or bx, 0 ; setting the flags
    jp SECED_lower_parity_1 ;  jp only checks the first 8 bits so we devide the 16 bit word into two parts and xor the result  
    mov dl, 0 ; coping the parity of the lower part to dl
    jmp SECED_higher_part_parity
SECED_lower_parity_1: 
    mov dl, 1 ; coping the parity of the lower part to dl
    jmp SECED_higher_part_parity
SECED_higher_part_parity: 
    shr bx, 8 
    or bx, 0 ; setting flags
    jp SECED_higher_parity_1
    mov dh, 0 ; coping the parity of the higher part to dh  
    jmp SECED_set_extra_bit
SECED_higher_parity_1:
    mov dh, 1 ; coping the parity of the higher part to dh    
    jmp SECED_set_extra_bit 
SECED_set_extra_bit:
    xor dl, dh ; after calculating the parity of the higher and lower parts we xor them to get the pairy of the whole data
    cmp dl, 1 ; currently the bit is 0, we only need to change it if its 1    
    je SECED_extra_bit_1        
    mov extra_bit, 0
    popa ; if its not 1, we can exit from the procedure
    ret
SECED_extra_bit_1:
    mov extra_bit, 1
    popa
    ret
endp validating_extra_bit   
    
proc fixing_SECED_hamming
    pusha      
    ; there are four possible cases:
    ; 1. all bits are correct + extra parity correct --> no errors
    ; 2. all bits are correct + extra parity not correct --> extra parity bit is wrong
    ; 3. some bit is wrong + extra bit is wrong --> fixable 1 bit error
    ; 4. some bit is wrong + extra bit is correct --> unfixable double bit error
    
    ; we check if the extra parity bit is correct
    mov bx, hamming_code 
    shr bx, 15           
    cmp bl, extra_bit
    jne extra_parity_incorrect
; extra parity correct    
case_1:
    ; if extra parity is correct and there is no errors, than there are no errors in the code word
    cmp sum_of_incorrect_parity_pos, 0
    je no_error
    
case_4:    
    ; (else) if the extra parity is correct and another bit isnt, then we a double error that we can't correct 
    ; printing cant_correct_errors_msg
    lea dx, cant_correct_errors_msg
    mov ah, 09h
    int 21h  
              
    ; printing --- line
    lea dx, line
    mov ah, 09h
    int 21h
    
    popa
    ret
extra_parity_incorrect:    
case_2:     
    cmp sum_of_incorrect_parity_pos, 0 ;  checking if there are errors in the codeword
    jne case_3
    
    ; printing wrong bit msg
    lea dx, extra_bit_wrong_msg
    mov ah, 09h
    int 21h
    
    or hamming_code, extra_bit_mask ; flipping the error in the extra parity bit
    call SECED_to_string  ; convert to string    
    ; print new hamming code
    lea dx, fixed_SECED_string
    mov ah, 09h
    int 21h 
    ; printing --- line
    lea dx, line
    mov ah, 09h
    int 21h 
    popa
    ret
    
case_3:    
    ; if both the extra parity is incorrect and another bit, it means that is a regular 1 bit error the we can correct  
    call fixing_error
    call SECED_to_string   
    
    ; printing wrong bit msg  
    ; diving parity bit by 10 in order to print two digit placment
    xor ah, ah
    mov al, sum_of_incorrect_parity_pos 
    mov bl, 10                           
    div bl
    add al, '0'
    add ah, '0'
    mov wrong_bit_msg[25], al
    mov wrong_bit_msg[26], ah 
   
    lea dx, wrong_bit_msg
    mov ah, 09h
    int 21h
    
    ; printing the hamming code
    lea dx, fixed_SECED_string
    mov ah, 09h
    int 21h    
    
    ; printing --- line
    lea dx, line
    mov ah, 09h
    int 21h
    popa
    ret
    
no_error: 
    ; case 1
    ; if there is no error then we print like normal
    lea dx, no_errors_msg
    mov ah, 09h
    int 21h
    
    ; printing line ---   
    lea dx, line
    mov ah, 09h
    int 21h
      
    popa
    ret         
    
endp fixing_SECED_hamming   

proc SECED_to_string
    pusha
    ; after we fixed the error we the error we need to convert the fixed hamming code into a string
    lea di, fixed_SECED_string
    mov bx, fixed_hamming_code 
    mov cx, 16      
convert_SECED:
    shl bx, 1 ; every time we shift the dup of the fixed hamming code and move back the result into the string
    jc carry_set1 ; if the carry flag is set then the current number is 1     
    jmp carry_not_set1
carry_set1:
    mov [di], '1' ; in DI there is the 
    jmp exit_string_convertion
carry_not_set1:
    mov [di], '0';  if the carry flag is not set the current number is 0
exit_string_convertion:
    inc di  
    loop convert_SECED   
    popa
    ret
endp SECED_to_string
end start ; set entry point and stop the assembler.
