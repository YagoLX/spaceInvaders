#----CONFIGURACOES BITMAP DISPLAY------------------------------------
# 8,8 256, 512, 0x10040000(heap)

# ---TELA------------------------------------------------------------
.eqv LARG       32
.eqv ALT        64
.eqv NPIX       2048            # LARG * ALT
.eqv BASE       0x10040000      # heap

.eqv MS_QUADRO  50

#---ESTADOS----------------------------------------------------------
.eqv E_MENU     0
.eqv E_JOGO     1
.eqv E_PAUSA    2
.eqv N_ESTADOS  3

#--CODIGO DE CORES--------------------------------------------------
.eqv PRETO        0x00000000
.eqv BRANCO       0x00FFFFFF
.eqv VERMELHO     0x00FF0000
.eqv VERDE        0x0000FF00
.eqv AZUL         0x000000FF
.eqv AMARELO      0x00FFFF00
.eqv CIANO        0x0000FFFF
.eqv ROSA         0x00FF00FF 

.data

.text
main: 
  li $a1, 1
  li $a2, BRANCO
  jal pintar_linha
  
  li $a1, 2
  li $a2, AZUL
  jal pintar_linha
  
  li $a1, 3
  li $a2, ROSA
  jal pintar_linha
  
  li $a1, 4
  li $a2, VERMELHO
  jal pintar_linha
  
  j terminar_programa
   


#--------------------------------------------------------------------
# pintar — acende uma celula
#   $a0 = x, $a1 = y, $a2 = cor (0x00RRGGBB)
#   'sll 5' assume LARG = 32.
#--------------------------------------------------------------------
pintar:
    bltz  $a0, pintar_fim         # x < 0 invalido
    bltz  $a1, pintar_fim	  # y < 0 invalido
    li    $t7, LARG	
    bge   $a0, $t7, pintar_fim    # x <  LARG (comeca em 0)
    li    $t7, ALT   
    bge   $a1, $t7, pintar_fim    # y < ALT 

    sll   $t8, $a1, 5           # y * LARG
    add   $t8, $t8, $a0         # + x
    sll   $t8, $t8, 2           # * 4 bytes
    li    $t9, BASE         
    add   $t8, $t8, $t9         #endereco = base + (y*LARG +X)*bytes por celula
    sw    $a2, 0($t8)                 
pintar_fim:
    jr    $ra

# escolha uma linha (y) em $a1 e uma cor em $a1 2
pintar_linha:
    add $sp, $sp, -4
    sw $ra, 0($sp)
    
    add $a0, $zero, $zero  #inicializar percurso em x = 0
    
loop_pintar:
    beq $a0, LARG, sai_loop_pintar
    jal pintar
    
    addi $a0, $a0, 1
    j loop_pintar

sai_loop_pintar:    
    lw  $ra, 0($sp)
    add $sp, $sp, 4
    jr  $ra
    
    
      
#--------------------------------------------------------------------
# terminar execucao
#--------------------------------------------------------------------
terminar_programa:
    addi  $v0, $zero, 10 
    syscall 
	