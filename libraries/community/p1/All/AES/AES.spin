{{
////////////////////////////////////////////////////////////////////////////////////////////
//                  AES.spin
// AES implementation, 128/192/256 bit keys, ECB mode and CBC mode.

// Author: Mark Tillotson
// Updated: 2012-01-27
// Designed For: P8X32A
// Version: 1.0

// Provides Start, Stop, SetKey, ECBEncrypt, ECBDecrypt, CBCEncrypt, CBCDecrypt, ScrubState
//   NOTE: Certain arguments are required to be long-aligned, namely the key and the IV
//   Functions:

//   PUB Start

//   PUB Stop

//   PUB SetKey (bits, thekey)
//         bits must be 128, 192 or 256
//         thekey is pointer to long-aligned key of that size

//   PUB ECBEncrypt (plaintext, ciphertext)
//         plaintext is a pointer to 16 byte input block
//         ciphertext is a pointer to 16 byte output block
//       note that SetKey() must have been previously called with valid args

//   PUB ECBDecrypt (ciphertext, plaintext)
//         ciphertext is a pointer to 16 byte input block
//         plaintext is a pointer to 16 byte output block
//       note that SetKey() must have been previously called with valid args

//   PUB CBCEncrypt (plaintext, ciphertext, blockcount, initvector)
//         plaintext is a pointer to 16*blockcount byte input block
//         ciphertext is a pointer to 16*blockcount byte output block
//         blockcount is number of 16-byte blocks to process
//         initvector is the 16 byte IV (long-aligned)
//	 note that initvector is overwritten with the outgoing CBC chain variable so
//       successive CBCEncrypt calls can be part of the same chain. Remember to overwrite
//       the IV again before a new message is processed

//   PUB CBCDecrypt (ciphertext, plaintext, blockcount, initvector)
//         ciphertext is a pointer to 16*blockcount byte input block
//         plaintext is a pointer to 16*blockcount byte output block
//         blockcount is number of 16-byte blocks to process
//         initvector is the 16 byte IV (long-aligned)
//	 note that initvector is overwritten with the outgoing CBC chain variable so
//       successive CBCDecrypt calls can be part of the same chain. Remember to overwrite
//       the IV again before a new message is processed

//   PUB ScrubState
//       wipes the cached state and subkey in the cog

// Note that there is currently no lock protocol, but if you use locking you should call
// ScrubState before dropping the lock and MUST (re)call SetKey() after claiming the lock, 
// otherwise the cached subkey state will produce incorrect results and leak information.


// Inspired by several sources:

//   Some inspiration from Brian Gladman's AES implementations
//   ( http://gladman.plushost.co.uk/oldsite/AES/ )

//   Eric Ball's  AES-128  Object  - several of his tricks are 'borrowed', but not the most
//   contorted ones (clarity or coding was desired).  His object is not ready-to-use out of
//   the box, nor does it support 192 or 256 bit keys, hence the motivation to provide 
//   something more directly usable.
//   ( http://obex.parallax.com/objects/664/ )

//   The original specification for Rijndael (the original name of AES)
//   "AES Proposal: Rijndael - Joan Daemen, Vincent Rijmen"
//   ( http://csrc.nist.gov/archive/aes/rijndael/Rijndael-ammended.pdf )


// See end of file for standard MIT licence / terms of use.

// Update History:

// v1.0 - Initial version 2012-01-27

////////////////////////////////////////////////////////////////////////////////////////////
}}

CON
  IDLE           = 0  ' values for op passed to cog, cog reports back with IDLE when finished
  OP_SBOXES      = 1  ' Setup s_box, used at Start time
  OP_SETKEY      = 2
  OP_ENCRYPT     = 3
  OP_DECRYPT     = 4
  OP_CBC_ENCRYPT = 5
  OP_CBC_DECRYPT = 6
  OP_CLEAN       = 7

  MAX_ROUNDS = 14


VAR
  long args [5]   ' parameters passed to cog


PUB Start
  args [1] := @s_fwd
  args [0] := OP_SBOXES
  thecog := cognew (@entry, @args)
  repeat until args[0] == IDLE
  result := thecog

PUB Stop
  if thecog <> -1
    cogstop (thecog)

PUB SetKey (bits, thekey)
  args [1] := bits
  args [2] := thekey
  args [0] := OP_SETKEY
  repeat until args[0] == IDLE

PUB ECBEncrypt (plaintext, ciphertext)
  args [1] := plaintext
  args [2] := ciphertext
  args [0] := OP_ENCRYPT
  repeat until args[0] == IDLE

PUB ECBDecrypt (ciphertext, plaintext)
  args [1] := ciphertext
  args [2] := plaintext
  args [0] := OP_DECRYPT
  repeat until args[0] == IDLE

PUB CBCEncrypt (plaintext, ciphertext, blockcount, initvector)
  args [1] := plaintext
  args [2] := ciphertext
  args [3] := blockcount
  args [4] := initvector
  args [0] := OP_CBC_ENCRYPT
  repeat until args[0] == IDLE

PUB CBCDecrypt (ciphertext, plaintext, blockcount, initvector)
  args [1] := ciphertext
  args [2] := plaintext
  args [3] := blockcount
  args [4] := initvector
  args [0] := OP_CBC_DECRYPT
  repeat until args[0] == IDLE

PUB ScrubState                          ' wipe the subkeys and state
  args [0] := OP_CLEAN
  repeat until args[0] == IDLE
 



DAT

thecog	      long  -1                  ' store the cog

{ S-box }
s_fwd         byte  $63, $7c, $77, $7b, $f2, $6b, $6f, $c5, $30, $01, $67, $2b, $fe, $d7, $ab, $76
              byte  $ca, $82, $c9, $7d, $fa, $59, $47, $f0, $ad, $d4, $a2, $af, $9c, $a4, $72, $c0
              byte  $b7, $fd, $93, $26, $36, $3f, $f7, $cc, $34, $a5, $e5, $f1, $71, $d8, $31, $15
              byte  $04, $c7, $23, $c3, $18, $96, $05, $9a, $07, $12, $80, $e2, $eb, $27, $b2, $75
              byte  $09, $83, $2c, $1a, $1b, $6e, $5a, $a0, $52, $3b, $d6, $b3, $29, $e3, $2f, $84
              byte  $53, $d1, $00, $ed, $20, $fc, $b1, $5b, $6a, $cb, $be, $39, $4a, $4c, $58, $cf
              byte  $d0, $ef, $aa, $fb, $43, $4d, $33, $85, $45, $f9, $02, $7f, $50, $3c, $9f, $a8
              byte  $51, $a3, $40, $8f, $92, $9d, $38, $f5, $bc, $b6, $da, $21, $10, $ff, $f3, $d2
              byte  $cd, $0c, $13, $ec, $5f, $97, $44, $17, $c4, $a7, $7e, $3d, $64, $5d, $19, $73
              byte  $60, $81, $4f, $dc, $22, $2a, $90, $88, $46, $ee, $b8, $14, $de, $5e, $0b, $db
              byte  $e0, $32, $3a, $0a, $49, $06, $24, $5c, $c2, $d3, $ac, $62, $91, $95, $e4, $79
              byte  $e7, $c8, $37, $6d, $8d, $d5, $4e, $a9, $6c, $56, $f4, $ea, $65, $7a, $ae, $08
              byte  $ba, $78, $25, $2e, $1c, $a6, $b4, $c6, $e8, $dd, $74, $1f, $4b, $bd, $8b, $8a
              byte  $70, $3e, $b5, $66, $48, $03, $f6, $0e, $61, $35, $57, $b9, $86, $c1, $1d, $9e
              byte  $e1, $f8, $98, $11, $69, $d9, $8e, $94, $9b, $1e, $87, $e9, $ce, $55, $28, $df
              byte  $8c, $a1, $89, $0d, $bf, $e6, $42, $68, $41, $99, $2d, $0f, $b0, $54, $bb, $16

{ Inverse S-box }
s_inv         byte  $52, $09, $6a, $d5, $30, $36, $a5, $38, $bf, $40, $a3, $9e, $81, $f3, $d7, $fb
              byte  $7c, $e3, $39, $82, $9b, $2f, $ff, $87, $34, $8e, $43, $44, $c4, $de, $e9, $cb
              byte  $54, $7b, $94, $32, $a6, $c2, $23, $3d, $ee, $4c, $95, $0b, $42, $fa, $c3, $4e
              byte  $08, $2e, $a1, $66, $28, $d9, $24, $b2, $76, $5b, $a2, $49, $6d, $8b, $d1, $25
              byte  $72, $f8, $f6, $64, $86, $68, $98, $16, $d4, $a4, $5c, $cc, $5d, $65, $b6, $92
              byte  $6c, $70, $48, $50, $fd, $ed, $b9, $da, $5e, $15, $46, $57, $a7, $8d, $9d, $84
              byte  $90, $d8, $ab, $00, $8c, $bc, $d3, $0a, $f7, $e4, $58, $05, $b8, $b3, $45, $06
              byte  $d0, $2c, $1e, $8f, $ca, $3f, $0f, $02, $c1, $af, $bd, $03, $01, $13, $8a, $6b
              byte  $3a, $91, $11, $41, $4f, $67, $dc, $ea, $97, $f2, $cf, $ce, $f0, $b4, $e6, $73
              byte  $96, $ac, $74, $22, $e7, $ad, $35, $85, $e2, $f9, $37, $e8, $1c, $75, $df, $6e
              byte  $47, $f1, $1a, $71, $1d, $29, $c5, $89, $6f, $b7, $62, $0e, $aa, $18, $be, $1b
              byte  $fc, $56, $3e, $4b, $c6, $d2, $79, $20, $9a, $db, $c0, $fe, $78, $cd, $5a, $f4
              byte  $1f, $dd, $a8, $33, $88, $07, $c7, $31, $b1, $12, $10, $59, $27, $80, $ec, $5f
              byte  $60, $51, $7f, $a9, $19, $b5, $4a, $0d, $2d, $e5, $7a, $9f, $93, $c9, $9c, $ef
              byte  $a0, $e0, $3b, $4d, $ae, $2a, $f5, $b0, $c8, $eb, $bb, $3c, $83, $53, $99, $61
              byte  $17, $2b, $04, $7e, $ba, $77, $d6, $26, $e1, $69, $14, $63, $55, $21, $0c, $7d


              ORG    0

entry
:waitcommand  rdlong op, par        ' wait for args[0] to be set
              cmp    op, #0  wz
         if_z jmp    #:waitcommand
'              neg    duration, cnt  ' record cycle counts for testing

              cmp    op, #OP_SBOXES  wz
              mov    parm, par
        if_nz jmp    #:skipsboxes
              add    parm, #4
              rdlong s_box, parm    ' args[1] = sboxes
              mov    inv_s_box, s_box
              add    inv_s_box, #$100
              jmp    #:done
:skipsboxes
              cmp    op, #OP_SETKEY  wz
        if_nz jmp    #:skipsetkey
              add    parm, #4
              rdlong nbits, parm    ' args[1] = nbits
              add    parm, #4
              rdlong key, parm      ' args[2] = key
              call   #set_key
              jmp    #:done
:skipsetkey
              add    parm, #4
              rdlong input, parm    ' args[1] = input
              add    parm, #4
              rdlong output, parm   ' args[2] = output
              add    parm, #4
              rdlong Nblocks, parm  ' args[3] = nblock   (used in CBC mode only)
              add    parm, #4
              rdlong iv, parm       ' args[4] = iv       (used in CBC mode only)

              cmp    op, #OP_ENCRYPT  wz
        if_z  call   #encrypt
              cmp    op, #OP_CBC_ENCRYPT  wz
        if_z  call   #cbc_encrypt
              cmp    op, #OP_DECRYPT  wz
        if_z  call   #decrypt
              cmp    op, #OP_CBC_DECRYPT  wz
        if_z  call   #cbc_decrypt
              cmp    op, #OP_CLEAN  wz
        if_z  call   #clean
:done
'              add    duration, cnt    ' recording cycle counts for testing
'              wrlong duration, parm
              mov    op, #0
              wrlong op, par        ' signal that we're done
              jmp    #:waitcommand  ' and busy-wait for next operation.

{ ------------------------------------------------ }

clean         movd   keyclean, #iv0
              mov    count, #(((MAX_ROUNDS+1)*4)+16)  ' sub keys and 4 sets of variables
              mov    Nround, #0
keyclean      mov    subkey+0, #0
	      add    keyclean, D1
	      djnz   count, #keyclean

clean_ret     ret

{ ------------------------------------------------ }

split_words
	      mov     t0, state0   ' use mask to separate out parts 
	      and     t0, mask     ' of each state word so can be 
	      xor     state0, t0   'recombined in different rows

	      mov     t1, state1
	      and     t1, mask
	      xor     state1, t1

	      mov     t2, state2
	      and     t2, mask
	      xor     state2, t2

	      mov     t3, state3
	      and     t3, mask
	      xor     state3, t3
split_words_ret ret

{ ------------------------------------------------ }

inv_substitute
	      mov     box, inv_s_box
	      jmp     #subs_comm
substitute    mov     box, s_box
subs_comm     mov     count, #4
:loop
	      mov     t0, state0   ' unrolled loop to substitute byte by byte, 
	      and     t0, #$FF     ' synchronize hub instructions to avoid
	      xor     state0, t0   ' waits - 32 cycles per substitute, 7.2us 
                                   ' for all s-box substitutions
	      add     t0, box
	      rdbyte  t0, t0
	      xor     state0, t0
	      ror     state0, #8

              mov     t1, state1
	      and     t1, #$FF
	      xor     state1, t1

	      add     t1, box
	      rdbyte  t1, t1
	      xor     state1, t1
	      ror     state1, #8

              mov     t2, state2
	      and     t2, #$FF
	      xor     state2, t2

	      add     t2, box
	      rdbyte  t2, t2
	      xor     state2, t2
	      ror     state2, #8

              mov     t3, state3
	      and     t3, #$FF
	      xor     state3, t3

	      add     t3, box
	      rdbyte  t3, t3
	      xor     state3, t3
	      ror     state3, #8

	      djnz    count, #:loop  ' 132 instrs for 4 times round loop
inv_substitute_ret
substitute_ret  ret

{ ------------------------------------------------ }

	      ' now shift the rows, first move cols 2 & 3 by two rows
shift_rows_comm
	      mov     mask, HFFFF0000
	      call    #split_words
	      
	      xor     state0, t2
	      xor     state1, t3
	      xor     state2, t0
	      xor     state3, t1      ' 19 instrs, 0.95us

	      mov     mask, HFF00FF00  ' then move cols 1 & 3 by one row
	      call    #split_words
shift_rows_comm_ret 
 	      ret	     

{ ------------------------------------------------ }

shift_rows    call    #shift_rows_comm
	      xor     state0, t1
	      xor     state1, t2
	      xor     state2, t3
	      xor     state3, t0      ' 19 instrs, 0.95us
shift_rows_ret ret	      	      ' total 9.2 us

{ ------------------------------------------------ }

inv_shift_rows
	      call    #shift_rows_comm
	      xor     state0, t3
	      xor     state1, t0
	      xor     state2, t1
	      xor     state3, t2      ' 19 instrs, 0.95us
inv_shift_rows_ret
	      ret	      	      ' total 9.2 us

{ ------------------------------------------------ }

times2_word   shl     column,       #1  wc
              test    column,    #$100  wz
        if_nz xor     column,    #$11B
              test    column,   H10000  wz
        if_nz xor     column,   H11B00
              test    column, H1000000  wz
        if_nz xor     column, H11B0000
        if_c  xor     column,H1B000000
times2_word_ret ret


{ ------------------------------------------------ }

mix_cols      mov     in, state0
	      call    #mix_col
	      mov     state0, out

	      mov     in, state1
	      call    #mix_col
	      mov     state1, out

	      mov     in, state2
	      call    #mix_col
	      mov     state2, out

	      mov     in, state3
	      call    #mix_col
	      mov     state3, out
mix_cols_ret  ret

{ ------------------------------------------------ }

inv_mix_cols  mov     in, state0
	      call    #inv_mix_col
	      mov     state0, out

	      mov     in, state1
	      call    #inv_mix_col
	      mov     state1, out

	      mov     in, state2
	      call    #inv_mix_col
	      mov     state2, out

	      mov     in, state3
	      call    #inv_mix_col
	      mov     state3, out
inv_mix_cols_ret ret

{ ------------------------------------------------ }

mix_col	      mov     column, in
	      call    #times2_word
	      mov     out, column
	      ror     out, #8
	      xor     out, column
	      ror     in, #8
	      xor     out, in
	      ror     in, #8
	      xor     out, in
	      ror     in, #8
	      xor     out, in
mix_col_ret   ret

{ ------------------------------------------------ }

inv_mix_col   call    #mix_col

	      call    #times2_word
	      xor     out, column
	      ror     column, #16
	      xor     out, column
	      call    #times2_word
	      xor     out, column
	      ror     column, #8
	      xor     out, column
	      ror     column, #8
	      xor     out, column
	      ror     column, #8
	      xor     out, column
inv_mix_col_ret ret


{ ------------------------------------------------ }


add_key
keywr0	      xor    state0, subkey+0      ' add key
keywr1	      xor    state1, subkey+1
keywr2	      xor    state2, subkey+2
keywr3	      xor    state3, subkey+3
	      add    keywr0, keystep
	      add    keywr1, keystep
	      add    keywr2, keystep
	      add    keywr3, keystep
add_key_ret   ret

{ ------------------------------------------------ }

reset_keys    movs    keywr0, #(subkey+0)  ' setup key mixes
	      movs    keywr1, #(subkey+1)
	      movs    keywr2, #(subkey+2)
	      movs    keywr3, #(subkey+3)
reset_keys_ret ret

{ ------------------------------------------------ }

read_block    mov     count, #4    ' generic read 4 words into consecutive variables
rdi           rdlong  state0, input
rdii          add     input, #4
              add     rdi, D1
              djnz    count, #rdi
read_block_ret ret


write_block   mov     count, #4    ' generic write 4 words into consecutive variables
wri           wrlong  state0, output
wrii          add     output, #4
              add     wri, D1
              djnz    count, #wri
write_block_ret ret

{{ ------------------------------------------------ }}
{
read_input    movd    rdi, #state0
              movs    rdi, #input
              movd    rdii, #input
              call    #read_block
read_input_ret ret


write_output  movd    wri, #state0
              movs    wri, #output
              movd    wrii, #output
              call    #write_block
write_output_ret ret
}

{ ------------------------------------------------ }

read_input    movd    :rdstate, #state0
              mov     count, #16
              mov     t, #0
:loop
              sub     count, #1
              rdbyte  cc, input
              add     input, #1
              or      t, cc
              ror     t, #8
              test    count, #3  wz
:rdstate if_z mov     state0, t
         if_z mov     t, #0
         if_z add     :rdstate, D1
              tjnz    count, #:loop
read_input_ret ret

{{ ------------------------------------------------ }}

write_output  movs    :wrstate, #state0
              mov     count, #16
:loop
              test    count, #3  wz
:wrstate if_z mov     t, state0
         if_z add     :wrstate, #1
              wrbyte  t, output
              add     output, #1
              shr     t, #8
              djnz    count, #:loop
write_output_ret ret

{{ ------------------------------------------------ }}

encrypt	      call    #read_input
	      call    #encrypt_guts
	      call    #write_output
encrypt_ret   ret

{ ------------------------------------------------ }

read_iv       movd    rdi, #iv0
              movs    rdi, #iv
              movd    rdii, #iv
              call    #read_block
read_iv_ret   ret

{ ------------------------------------------------ }

xor_iv	      xor     state0, iv0
              xor     state1, iv1
              xor     state2, iv2
              xor     state3, iv3
xor_iv_ret    ret

{ ------------------------------------------------ }

cbc_encrypt   call    #read_iv
:loop
	      call    #read_input
              call    #xor_iv
	      call    #encrypt_guts  ' state := encrypt(state)
	      call    #write_output  ' [ cipher++ ] := state

              mov     iv0, state0
              mov     iv1, state1
              mov     iv2, state2
              mov     iv3, state3

	      djnz    Nblocks, #:loop

              call    #write_iv

cbc_encrypt_ret ret

{ ------------------------------------------------ }

write_iv      movd    wri, #iv0
              movs    wri, #iv
              movd    wrii, #iv
              call    #write_block
write_iv_ret  ret

{ ------------------------------------------------ }

decrypt       call    #read_input
	      call    #decrypt_guts
	      call    #write_output
decrypt_ret   ret

{ ------------------------------------------------ }

cbc_decrypt   call    #read_iv
:loop
	      call    #read_input  ' state := [ plain++ ]
	      mov     tt0, state0   ' t := state
	      mov     tt1, state1
	      mov     tt2, state2
	      mov     tt3, state3
	      call    #decrypt_guts ' state := decrypt (state)
	      call    #xor_iv
	      call    #write_output ' [ cipher++ ] := state
	      mov     iv0, tt0
	      mov     iv1, tt1
	      mov     iv2, tt2
	      mov     iv3, tt3
	      djnz    Nblocks, #:loop

              call    #write_iv

cbc_decrypt_ret ret

{ ------------------------------------------------ }

encrypt_guts  call    #reset_keys
              mov     rnd, Nround
	      mov     keystep, #4      ' step forwards during add_key

	      call    #add_key
	      sub     rnd, #1
:loop
	      call    #substitute        ' s-box substitute
              call    #shift_rows
              call    #mix_cols          ' mix cols
	      call    #add_key
              djnz    rnd, #:loop

	      call    #substitute
              call    #shift_rows
	      call    #add_key
encrypt_guts_ret ret

{ ------------------------------------------------ }

decrypt_guts  call    #reset_keys
              mov     offset, Nround
	      shl     offset, #2
	      add     keywr0, offset    ' step to end of subkeys
	      add     keywr1, offset
	      add     keywr2, offset
	      add     keywr3, offset
	      neg     keystep, #4       ' step backwards during add_key

              mov     rnd, Nround

              call    #add_key
              call    #inv_shift_rows
              sub     rnd, #1
	      call    #inv_substitute
:loop
	      call    #add_key
              call    #inv_mix_cols
	      call    #inv_shift_rows
	      call    #inv_substitute
              djnz    rnd, #:loop

              call    #add_key
decrypt_guts_ret ret


{ ------------------------------------------------ }

set_key       cmp     s_box, #0  wz   ' check if been initialized
        if_z  jmp     #set_key_ret ' if not abort

              mov     Nround, #0
              cmp     nbits, #128  wz
        if_nz cmp     nbits, #192  wz
        if_nz cmp     nbits, #256  wz
        if_nz jmp     #set_key_ret ' if zero then failed.
              mov     keylen, nbits
              shr     keylen, #5   ' key len in words, 4 6 or 8
              mov     Nround, keylen
              add     Nround, #6   ' Nrounds 10, 12 or 14
              mov     hi, Nround
              add     hi, #1
              shl     hi, #2       ' hi = 44, 52 or 60 words

              mov     rc, #1

              movd    rdi, #subkey0
              movs    rdi, #key
              movd    rdii, #key
              call    #read_block
              call    #read_block  ' reads too much for 128 and 192 bit keys, but ignored

	      ' setup the modified instructions in the subkey loop
	      mov     offset, #subkey
	      movs    readt2, offset
	      add     offset, keylen  ' in words, note
	      movd    writet2, offset
	      sub     offset, #1
	      movs    readt, offset

              mov     nxt, keylen
              mov     cc, keylen
setkloop
readt	      mov    t, subkey+0      ' read previous
	      add    readt, #1        ' modify

              cmp    cc, nxt  wz
        if_nz jmp    #:skip1

              add    nxt, keylen
              call   #s_box_word
              ror    t, #8
              xor    t, rc

              test   rc, #$80  wz     ' times 2 in GF(2^8)
              shl    rc, #1
        if_nz xor    rc, #$11B

              jmp    #:skip2
:skip1
              cmp    keylen, #8  wz
        if_nz jmp    #:skip2
              mov    t2, cc
              and    t2, #7
              cmp    t2, #4  wz
        if_nz jmp    #:skip2

              call   #s_box_word

:skip2
readt2	      mov    t2, subkey+0     ' read further back
	      add    readt2, #1       ' modify
	      xor    t2, t
writet2       mov    subkey+0, t2     ' write new subkey word
	      add    writet2, D1      ' modify

              add    cc, #1
              cmp    cc, hi  wz,wc
        if_b  jmp    #setkloop

set_key_ret   ret

{ ------------------------------------------------ }

s_box_word    mov    count, #3      ' apply s-box to every byte in the word t
              mov    t3, #0
:loop
              mov    t2, t
              and    t2, #$FF
              add    t2, s_box
              rdbyte t2, t2
              shr    t, #8
              or     t3, t2
              ror    t3, #8
              djnz   count, #:loop

              add    t, s_box
              rdbyte t, t
              or     t, t3
              ror    t, #8
s_box_word_ret ret

{ ------------------------------------------------ }

Nround        long   0
s_box         long   0
inv_s_box     long   0

op            long   0

D1	      long   1<<9
H10000        long   $10000
H11B00        long   $11B00
H1000000      long   $1000000
H11B0000      long   $11B0000
H1B000000     long   $1B000000
HFFFF0000     long   $FFFF0000
HFF00FF00     long   $FF00FF00

parm          res    1

' parameter variables
nbits         res    1
Nblocks       res    1
iv            res    1
key           res    1
input         res    1
output        res    1
keylen        res    1

box           res    1
rnd           res    1
count         res    1
mask          res    1
column	      res    1
in            res    1
out           res    1
keystep       res    1
offset        res    1


' iv, t, tt, state and subkey variables - these are cleared by the clean routine so keep them contiguous

iv0           res    1
iv1           res    1
iv2           res    1
iv3           res    1

t0	      res    1
t1	      res    1
t2            res    1
t3            res    1

tt0	      res    1
tt1	      res    1
tt2           res    1
tt3           res    1

state0	      res    1
state1	      res    1
state2	      res    1
state3	      res    1

subkey
subkey0	      res    1
subkey1	      res    1
subkey2	      res    1
subkey3	      res    1
	      res    MAX_ROUNDS*4

' set_key variables
t             res    1
rc            res    1
nxt           res    1
hi            res    1
cc            res    1


'duration      res    1

              FIT   $1F0

{{
////////////////////////////////////////////////////////////////////////////////////////////
//                                TERMS OF USE: MIT License
////////////////////////////////////////////////////////////////////////////////////////////
// Permission is hereby granted, free of charge, to any person obtaining a copy of this 
// software and associated documentation files (the "Software"), to deal in the Software 
// without restriction, including without limitation the rights to use, copy, modify, merge,
// publish, distribute, sublicense, and/or sell copies of the Software, and to permit 
// persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////////////////
}}
