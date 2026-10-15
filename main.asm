#----CONFIGURACOES BITMAP DISPLAY------------------------------------
# 8,8 256, 512, 0x10040000(heap)

# ---TELA------------------------------------------------------------
.eqv LARG       32
.eqv ALT        64
.eqv NPIX       2048            # LARG * ALT
.eqv BASE       0x10040000      # heap

.eqv MS_QUADRO  50              #um quadro dura 50 ms

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
#--ASCII DE TECLAS-------------------------------------------------
.eqv TECLA_A      97
.eqv TECLA_D      100
.eqv TECLA_ESPACO 32
.eqv TECLA_P      112

.data
quadros: .word 0

#---MAQUINA DE ESTADO-----------------------------------------------
estado:         .word E_MENU
estado_novo:    .word 1 # 1 se tiver acabado de trocar de estado e 0 c.c
quadros_est:    .word 0 #quadros desde que entrou no estado
tabela_estados: .word est_menu, est_jogo, est_pausa

#----ENTRADAS------------------------------------------------------
tecla:        .word 0 


#---MENSAGENS-------------------------------------------------------
msg_erro_estado: .asciiz "ERRO: estado invalido"

.text
main: 
  #-------INICIO DE TESTE------#
  #li $a1, 1
  #li $a2, BRANCO
  #jal pintar_linha
  
  #li $a1, 2
  #li $a2, AZUL
  #jal pintar_linha
  
  #li $a1, 3
  #li $a2, ROSA
  #jal pintar_linha
  #
  #li $a1, 4
  #li $a2, VERMELHO
  # jal pintar_linha
  #------------------------------#
  #jal ler_entrada
  #beq $v0, $zero, main
  #add $a0, $zero, $v1
  #addi $v0, $zero, 1 
  #syscall
 #------------------------------#
  #FIM DO TESTE
  
  
  #li $a0, E_MENU
  li $a0, E_MENU
  jal mudar_estado
  
  
loop_principal:     #ler_entrada -> atualizar -> desenhar ->esperar ->esperar -> ler_entrada ...
    jal ler_entrada
    
    lw $t0, estado                 #$t0 recebe o estado que vamos analisar
    bltz $t0, estado_invalido      # estado < 0 é invalido
    li $t1, N_ESTADOS          
    bge $t0, $t1, estado_invalido  #estado > estado de maior numero é estado invalido
    
    sll $t1, $t0, 2                #$t1 recebe o deslocamento para acessar onde está a funcao desse estados
    la $t2, tabela_estados            #recebe a posicao de memoria da tabela de estaso
    add $t2, $t2, $t1              #recebe endereco da funcao do estado atual
    lw $t2, 0($t2)                 #recebe o endereco do estado
    
    lw   $a0, estado_novo    # $a0 = 1 no primeiro quadro do estado
    sw   $zero, estado_novo  # abaixa ANTES de chamar
    jalr $t2                       #roda o estado
    

    
    jal esperar
    j loop_principal
    
    estado_invalido:
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

# escolha uma linha (y) em $a1 e uma cor em $a2
pintar_linha:
    add $sp, $sp, -4
    sw $ra, 0($sp)
    
    add $a0, $zero, $zero  #inicializar percurso em x = 0
        li $t0, LARG
    loop_pintar:
        beq $a0, $t0, sai_loop_pintar
        jal pintar
    
        addi $a0, $a0, 1
        j loop_pintar

    sai_loop_pintar:    
        lw  $ra, 0($sp)
        add $sp, $sp, 4
        jr  $ra

#pintar_tela: escolha uma cor em $a2
pintar_tela:
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    
    li $s0, 0
    
    pintar_tela_loop:
        li $t0, ALT
        bge $s0, $t0, pintar_tela_fim
        add $a1, $s0, $zero
        jal pintar_linha
        addi $s0, $s0, 1
        j pintar_tela_loop
    
    pintar_tela_fim:
         lw $ra, 0($sp)
         lw $s0, 4($sp)
         addi $sp, $sp, 8
         jr $ra
    
#---ESTADOS---------------------------------------------------------
#   recebe a flag estado_novo em $a0
#------------------------------------------------------------------
est_menu:
    addi $sp, $sp, -8
    sw   $ra, 0($sp)
    sw   $a0, 4($sp)

    lw   $t0, 4($sp)
    beqz $t0, menu_corpo
    li   $a2, AZUL              # bloco de entrada: pinta uma vez quando a flag estado_novo é 1
    jal  pintar_tela

    menu_corpo:
      lw   $t0, tecla
      li   $t1, TECLA_ESPACO              # Enter
      bne  $t0, $t1, menu_fim
      li   $a0, E_JOGO
      jal  mudar_estado

    menu_fim:
      lw   $ra, 0($sp)
      lw   $a0, 4($sp)
      addi $sp, $sp, 8
      jr   $ra
   
est_jogo:
    addi $sp, $sp, -8
    sw   $ra, 0($sp)
    sw   $a0, 4($sp)

    lw   $t0, 4($sp)
    beqz $t0, jogo_corpo
    li   $a2, VERDE               
    jal  pintar_tela
    
    jogo_corpo:
      lw   $t0, tecla
      li   $t1, TECLA_ESPACO        # Enter
      bne  $t0, $t1, jogo_fim
      li   $a0, E_MENU
      jal  mudar_estado
     
    jogo_fim:
      lw   $ra, 0($sp)
      lw   $a0, 4($sp)
      addi $sp, $sp, 8
      jr   $ra

est_pausa:
   jr $ra
#--------------------------------------------------------------------
# mudar_estado: alterna o estado atual
#    $a0 é o proximo estado
#     
#--------------------------------------------------------------------    
mudar_estado:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    #subir flag estado_novo
    sw $a0, estado
    li $t0, 1
    sw $t0, estado_novo # se mudou de estado devemos colocar a tag estado_novo para true (1)
    
    #reiniciar quadros est
    li $t0, -1
    sw $t0, quadros_est
    
    jal limpar_buffer
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra 
    
#---FIM ESTADOS-----------------------------------------------------

#--------------------------------------------------------------------
# esperar: faz o frame esperar o tempo de um frame antes de prosseguir
#--------------------------------------------------------------------
esperar: 
  li $a0, MS_QUADRO
  li $v0, 32
  syscall
  #atulaizar quadros_est
  lw $t0, quadros_est      
  addi $t0, $t0, 1
  sw $t0, quadros_est
  
  #atualizar quadros
  lw $t0, quadros
  addi $t0, $t0, 1 
  sw $t0, quadros
  jr $ra

#---TRATAMENTO DE ENTRADAS------------------------------------------
#-------------------------------------------------------------------
#ler_entrada: salva entrada em "tecla", salva 0 em tecla c.c.
#		se houve leitura $v0 =1, 0 c.c.
# 		v1 retorna a leitura
#-------------------------------------------------------------------
ler_entrada:
  lui $t0, 0xffff   #endereco do bit de controle
  lw $t1, 0($t0)    #queremos ver se é 0 (sem entrada) ou 1 (com entada)
  andi $t1, $t1, 1  # $t1 =1 se tem entrada
  beq  $t1, $zero, entrada_vazia
  lw   $t2, 4($t0)  #codigo ASCII do caractere
  
  #transformar maiusculas em minusculas
  li $t3, 65            
  blt $t2, $t3, salvar_leitura   #se a entrada é menor que 65 nao é maiuscula
  li $t3, 90
  bgt $t2, $t3, salvar_leitura  #se a entrada é maior que 90 nao é maiscula
  addi $t2, $t2, 32            #se a entrada é maiuscula, se converte para minuscula
  
  salvar_leitura:
      sw $t2, tecla
      li $v0, 1
      add $v1, $t2, $zero 
      jr $ra
  
  entrada_vazia:
      sw $zero, tecla
      li $v0, 0
      add $v1,$zero, $zero
      jr $ra
#-------------------------------------------------------------------
#ler_entrada: salva entrada em "tecla", salva 0 em tecla c.c.
#		se houve leitura $v0 =1, 0 c.c.
# 		v1 retorna a leitura
#-------------------------------------------------------------------

limpar_buffer:
  lui $t0, 0xffff
  
  lb_loop:
      lw $t1, 0($t0)
      andi $t1,$t1,1 
      beqz $t1, lb_fim
      lw $t1, 4($t0) #le e descarta
      j lb_loop
      
  lb_fim: 
     sw $zero, tecla
     jr $ra
  
      
#--------------------------------------------------------------------
# terminar execucao
#--------------------------------------------------------------------
terminar_programa:
    addi  $v0, $zero, 10 
    syscall 
	
