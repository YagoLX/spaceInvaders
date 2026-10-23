#----CONFIGURACOES BITMAP DISPLAY------------------------------------
# 8,8 512, 512, 0x10040000(heap)

# ---TELA------------------------------------------------------------
.eqv LARG       64
.eqv ALT        64
.eqv NPIX       4096           # LARG * ALT
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

 
 .eqv COR_TIRO_J AMARELO
 .eqv COR_TIRO_I ROSA 
#--ASCII DE TECLAS-------------------------------------------------
.eqv TECLA_ENTER  10
.eqv TECLA_ESPACO 32
.eqv TECLA_A      97
.eqv TECLA_D      100
.eqv TECLA_P      112
.eqv MAX_TECLAS   64
#--AUXILIARES PARA NAVE--------------------------------------------
.eqv NAVE_Y 60
.eqv X_MAX_NAVE 61 #LARGURA - 3 (largura da nave)
.eqv TIRO_Y_INI 58

#-AUXILIARES PARA INIMIGOS----------------------------------------
.eqv INI_ALTURA       3 #ALTURA DO INIMIGO
.eqv INI_LARGURA      3 #LARGURA DO INIMIGO
.eqv INI_Y_BASE       8 # LINHAS 0-7 para pontos e vidas
.eqv GRUPO_X_MIN      0 #
.eqv GRUPO_X_MAX      29 # LARG - 35
.eqv GRUPO_DIVISOR    3 # move a cada 4 quadros
.eqv N_INIMIGOS       20


.data
quadros: .word 0

#---MAQUINA DE ESTADO-----------------------------------------------
estado:         .word E_MENU
estado_novo:    .word 1 # 1 se tiver acabado de trocar de estado e 0 c.c
quadros_est:    .word 0 #quadros desde que entrou no estado
tabela_estados: .word est_menu, est_jogo, est_pausa

#----ENTRADAS------------------------------------------------------
tecla:        .word 0 

#---ESTADO JOGO---------------------------------------------------
nave_x:   .word 30 #LARG/2

#---INIMIGOS------------------------------------------------------
grupo_ini_x:   .word 14
grupo_ini_y:   .word INI_Y_BASE
grupo_x_min:   .word 0
grupo_x_max:   .word 29
grupo_ini_dir: .word 1 

#---TIRO DO JOGADOR-----------------------------------------------
ha_tiro_jogador:  .word 0
tiro_jogador_x:   .word 0
tiro_jogador_y:   .word 0

#Inimigo é representado no vetor por: coluna relativa ao bloco
# linha relativa ao bloco e se esta vivo
inimigos:  .word  0,0,1,   8,0,1,  16,0,1,  24,0,1,  32,0,1
           .word  0,4,1,   8,4,1,  16,4,1,  24,4,1,  32,4,1
           .word  0,8,1,   8,8,1,  16,8,1,  24,8,1,  32,8,1
           .word  0,12,1,  8,12,1, 16,12,1, 24,12,1, 32,12,1

#----ENTRADAS------------------------------------------------------
# Permite mais de uma acao no mesmo quadro
cmd_mover:   .word 0    # -1 esquerda, 0 parado, +1 direita
cmd_tiro:    .word 0    # 1 se ESPACO foi apertado neste quadro
cmd_pausa:   .word 0    # 1 se P foi apertado
cmd_menu:    .word 0    # 1 se ENTER foi apertado

#---MENSAGENS-------------------------------------------------------
msg_erro_estado: .asciiz "ERRO: estado invalido"

#---DUPLA BUFFERIZACAO---------------------------------------------
.align 2
buffer_tela: .space 16384 #Numero de Pixels * 4

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
    jal copiar_buffer
    
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

    sll   $t8, $a1, 6           # y * LARG
    add   $t8, $t8, $a0         # + x
    sll   $t8, $t8, 2           # * 4 bytes
    la    $t9, buffer_tela         
    add   $t8, $t8, $t9         #endereco = base + (y*LARG +X)*bytes por celula
    sw    $a2, 0($t8)                 
    pintar_fim:
        jr    $ra

# escolha uma linha (y) em $a1 e uma cor em $a2
pintar_linha:
    addi $sp, $sp, -4
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
#-----------------------------------------------------------------
# copiar_buffer: despeja o buffer na memoria da tela
#-----------------------------------------------------------------
copiar_buffer:
    la $t0, buffer_tela
    li $t1, BASE
    li $t2, NPIX
    copiar_buffer_loop:
        lw $t3, 0($t0)
        sw $t3, 0($t1)
        addi $t0, $t0, 4
        addi $t1, $t1, 4
        addi $t2, $t2, -1
        bne $t2, $zero, copiar_buffer_loop
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
      lw   $t0, cmd_tiro          # Espaco comeca o jogo
      beqz $t0, menu_fim
      jal jogo_reset
      li   $a0, E_JOGO
      jal  mudar_estado

    menu_fim:
      lw   $ra, 0($sp)
      lw   $a0, 4($sp)
      addi $sp, $sp, 8
      jr   $ra
   
est_jogo:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    jogo_corpo:
      lw   $t0, cmd_menu
      beqz $t0, jogo_testa_pausa
      li   $a0, E_MENU
      jal  mudar_estado
      j    jogo_fim

    jogo_testa_pausa:
      lw   $t0, cmd_pausa
      beqz $t0, jogo_atualiza
      li   $a0, E_PAUSA
      jal  mudar_estado
      j    jogo_fim

    jogo_atualiza:
      jal  mover_nave
      jal mover_tiro_jogador
      jal mover_grupo_ini

    jogo_desenha:
      li   $a2, PRETO
      jal  pintar_tela             # limpa o buffer da tela
      jal desenhar_inimigos
      jal desenhar_nave
      jal desenhar_tiro_jogador

    jogo_fim:
      lw   $ra, 0($sp)
      addi $sp, $sp, 4
      jr   $ra

est_pausa:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    lw   $t0, cmd_pausa
    beqz $t0, pausa_fim
    li   $a0, E_JOGO
    jal  mudar_estado

    pausa_fim:
      lw   $ra, 0($sp)
      addi $sp, $sp, 4
      jr   $ra
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
    
    jal limpar_buffer_teclado
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra 
    
#-------------------------------------------------------------------
# jogo_reset — devolve o jogo ao estado inicial
#
#   Chamado pela TRANSICAO menu -> jogo, nunca pela entrada do estado:
#   E_JOGO tambem e alcancado vindo da pausa, e ali nao se reinicia.
#-------------------------------------------------------------------
jogo_reset:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    # --- nave e tiro ---
    li   $t0, 30
    sw   $t0, nave_x
    sw   $zero, ha_tiro_jogador

    # --- bloco de inimigos ---
    li   $t0, 14
    sw   $t0, grupo_ini_x
    li   $t0, INI_Y_BASE
    sw   $t0, grupo_ini_y
    li   $t0, 1
    sw   $t0, grupo_ini_dir

    # --- revive todos os inimigos ---
    la   $t1, inimigos
    li   $t2, N_INIMIGOS
    li   $t3, 1
jr_loop:
    sw   $t3, 8($t1)             # campo 'vivo'
    addi $t1, $t1, 12
    addi $t2, $t2, -1
    bnez $t2, jr_loop

    jal  recalcular_limites      # o cache depende de quem esta vivo

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra
    
#---FIM ESTADOS-----------------------------------------------------

#---NAVE------------------------------------------------------------
#-------------------------------------------------------------------
# mover_nave: le TECLA, atualiza nave_x ->cuidado bordas
#-------------------------------------------------------------------
mover_nave:
    lw   $t0, cmd_mover
    beqz $t0, mn_fim                 # parado
    lw   $t1, nave_x
    add  $t1, $t1, $t0               # soma -1 ou +1 direto

    bgez $t1, mn_testa_max
    li   $t1, 0
    j    mn_grava
mn_testa_max:
    li   $t2, X_MAX_NAVE
    ble  $t1, $t2, mn_grava
    li   $t1, X_MAX_NAVE
mn_grava:
    sw   $t1, nave_x
mn_fim:
    jr   $ra

#-----------------------------------------------------------------
# desenhar_nave: le nave_x, pinta a nave em NAVE_Y
#-----------------------------------------------------------------
desenhar_nave:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    li   $a2, BRANCO
    li   $a1, NAVE_Y             # corpo: tres celulas

    lw   $a0, nave_x
    jal  pintar
    lw   $a0, nave_x
    addi $a0, $a0, 1
    jal  pintar
    lw   $a0, nave_x
    addi $a0, $a0, 2
    jal  pintar

    li   $a1, NAVE_Y             # bico: uma acima, no centro
    addi $a1, $a1, -1
    lw   $a0, nave_x
    addi $a0, $a0, 1
    jal  pintar

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra
    
#-------------------------------------------------------------------
# mover_tiro_jogador
#   Se nao ha tiro, ESPACO dispara. Se ha, ele sobe e some ao sair.
#   A flag 'ha_tiro_jogador' sozinha impoe a regra de um tiro por vez
#-------------------------------------------------------------------
mover_tiro_jogador:
    lw   $t0, ha_tiro_jogador
    bnez $t0, mtj_existe

    # --- nao existe: nasce se apertar ESPACO ---
    lw   $t1, cmd_tiro
    beq $t1, $zero, mtj_fim
    lw   $t3, nave_x
    addi $t3, $t3, 1             # sai do bico da nave
    sw   $t3, tiro_jogador_x
    li   $t3, TIRO_Y_INI
    sw   $t3, tiro_jogador_y
    li   $t3, 1
    sw   $t3, ha_tiro_jogador
    j    mtj_fim

    # --- existe: sobe uma linha ---
mtj_existe:
    lw   $t1, tiro_jogador_y
    addi $t1, $t1, -1
    bgez $t1, mtj_grava
    sw   $zero, ha_tiro_jogador  # saiu pelo topo
    j    mtj_fim
mtj_grava:
    sw   $t1, tiro_jogador_y

mtj_fim:
    jr   $ra

#-------------------------------------------------------------------
# desenhar_tiro_jogador — so pinta se a flag estiver levantada
#-------------------------------------------------------------------
desenhar_tiro_jogador:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    lw   $t0, ha_tiro_jogador
    beqz $t0, dtj_fim

    lw   $a0, tiro_jogador_x
    lw   $a1, tiro_jogador_y
    li   $a2, COR_TIRO_J
    jal  pintar

dtj_fim:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra
    
#---INIMIGOS---------------------------------------------------------

#-------------------------------------------------------------------
# recalcular_limites — atualiza grupo_x_min e grupo_x_max
#
#   Varre os inimigos vivos procurando o menor e o maior col_rel.
#   O bloco pode ir ate onde o inimigo da ponta encoste na borda.
#
#   CHAMAR SEMPRE QUE: um inimigo morrer, ou o jogo for reiniciado
#-------------------------------------------------------------------
recalcular_limites:
    la   $t0, inimigos
    li   $t1, N_INIMIGOS
    li   $t2, 9999                   # menor col_rel
    li   $t3, -1                     # maior col_rel

    rl_loop:
      lw   $t4, 8($t0)                 # vivo?
      beqz $t4, rl_prox
      lw   $t4, 0($t0)                 # col_rel
      bge  $t4, $t2, rl_testa_max
      add $t2, $zero, $t4

    rl_testa_max:
      ble  $t4, $t3, rl_prox
      move $t3, $t4

    rl_prox:
      addi $t0, $t0, 12
      addi $t1, $t1, -1
      bne $t1, $zero,rl_loop

      bltz $t3, rl_vazio               # nenhum vivo: congela onde esta

      sub  $t5, $zero, $t2             # x_min = -menor_col
      sw   $t5, grupo_x_min

      li   $t5, LARG
      addi $t5, $t5, -INI_LARGURA      # 61
      sub  $t5, $t5, $t3               # x_max = 61 - maior_col
      sw   $t5, grupo_x_max
      jr   $ra

    rl_vazio:
      lw   $t5, grupo_ini_x
      sw   $t5, grupo_x_min
      sw   $t5, grupo_x_max
      jr   $ra
      
#-------------------------------------------------------------------
# mover_grupo_ini — oscila o bloco inteiro, a cada 4 quadros
#   Le os limites do cache; nao os recalcula.
#-------------------------------------------------------------------
mover_grupo_ini:
    lw   $t0, quadros
    andi $t0, $t0, GRUPO_DIVISOR
    bnez $t0, mgi_fim                # so nos quadros multiplos de 4

    lw   $t1, grupo_ini_x
    lw   $t2, grupo_ini_dir
    add  $t1, $t1, $t2

    lw   $t3, grupo_x_min
    bgt  $t1, $t3, mgi_testa_max
    move $t1, $t3                    # bateu na esquerda
    li   $t2, 1
    j    mgi_grava

  mgi_testa_max:
    lw   $t3, grupo_x_max
    blt  $t1, $t3, mgi_grava
    move $t1, $t3                    # bateu na direita
    li   $t2, -1

  mgi_grava:
    sw   $t1, grupo_ini_x
    sw   $t2, grupo_ini_dir
  mgi_fim:
    jr   $ra
  
  
desenhar_inimigos:
    addi $sp, $sp, -20
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)
    sw   $s2, 12($sp)
    sw   $s3, 16($sp)

    la   $s0, inimigos
    li   $s1, N_INIMIGOS
    lw   $s2, grupo_ini_x
    lw   $s3, grupo_ini_y

    din_loop:
      lw   $t0, 8($s0)
      beqz $t0, din_prox

      lw   $t0, 0($s0)
      add  $a0, $s2, $t0               # x = grupo_x + col_rel
      lw   $t0, 4($s0)
      add  $a1, $s3, $t0               # y = grupo_y + lin_rel
      li   $a2, VERMELHO
      jal  desenhar_inimigo

  din_prox:
    addi $s0, $s0, 12
    addi $s1, $s1, -1
    bnez $s1, din_loop

    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $s2, 12($sp)
    lw   $s3, 16($sp)
    addi $sp, $sp, 20
    jr   $ra
    
#-------------------------------------------------------------------
# desenhar_inimigo — pinta um inimigo em (x, y)
#   $a0 = x, $a1 = y, $a2 = cor
#   Cor como argumento permite usar a mesma rotina para desenhar e
#   para apagar, se um dia for preciso.
#
#     #.#
#     ###
#     .#.
#   Usa $s0-$s2 porque 'pintar' destroi $a0-$a2 a cada chamada.
#-------------------------------------------------------------------
desenhar_inimigo:
    addi $sp, $sp, -16
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)
    sw   $s2, 12($sp)
    move $s0, $a0                # x
    move $s1, $a1                # y
    move $s2, $a2                # cor

    move $a0, $s0                # (0,0)
    move $a1, $s1
    move $a2, $s2
    jal  pintar

    addi $a0, $s0, 2             # (2,0)
    move $a1, $s1
    move $a2, $s2
    jal  pintar

    move $a0, $s0                # (0,1)
    addi $a1, $s1, 1
    move $a2, $s2
    jal  pintar

    addi $a0, $s0, 1             # (1,1)
    addi $a1, $s1, 1
    move $a2, $s2
    jal  pintar

    addi $a0, $s0, 2             # (2,1)
    addi $a1, $s1, 1
    move $a2, $s2
    jal  pintar

    addi $a0, $s0, 1             # (1,2)
    addi $a1, $s1, 2
    move $a2, $s2
    jal  pintar

    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $s2, 12($sp)
    addi $sp, $sp, 16
    jr   $ra

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
    sw   $zero, cmd_mover            # zera os pedidos do quadro
    sw   $zero, cmd_tiro
    sw   $zero, cmd_pausa
    sw   $zero, cmd_menu

    lui  $t0, 0xffff
    li   $t4, MAX_TECLAS             # teto de seguranca

le_loop:
    beqz $t4, le_fim
    lw   $t1, 0($t0)
    andi $t1, $t1, 1
    beqz $t1, le_fim                 # fila vazia
    lw   $t2, 4($t0)
    addi $t4, $t4, -1

    li   $t3, 65                     # normaliza maiuscula
    blt  $t2, $t3, le_testa
    li   $t3, 90
    bgt  $t2, $t3, le_testa
    addi $t2, $t2, 32

le_testa:
    li   $t3, TECLA_A
    bne  $t2, $t3, le_testa_d
    li   $t5, -1
    sw   $t5, cmd_mover
    j    le_loop

le_testa_d:
    li   $t3, TECLA_D
    bne  $t2, $t3, le_testa_espaco
    li   $t5, 1
    sw   $t5, cmd_mover
    j    le_loop

le_testa_espaco:
    li   $t3, TECLA_ESPACO
    bne  $t2, $t3, le_testa_p
    li   $t5, 1
    sw   $t5, cmd_tiro
    j    le_loop

le_testa_p:
    li   $t3, TECLA_P
    bne  $t2, $t3, le_testa_enter
    li   $t5, 1
    sw   $t5, cmd_pausa
    j    le_loop

le_testa_enter:
    li   $t3, TECLA_ENTER
    bne  $t2, $t3, le_loop           # tecla desconhecida: ignora
    li   $t5, 1
    sw   $t5, cmd_menu
    j    le_loop

le_fim:
    jr   $ra
#-------------------------------------------------------------------
#ler_entrada: salva entrada em "tecla", salva 0 em tecla c.c.
#		se houve leitura $v0 =1, 0 c.c.
# 		v1 retorna a leitura
#-------------------------------------------------------------------
limpar_buffer_teclado:
  lui $t0, 0xffff
  li  $t4, MAX_TECLAS
  lb_loop:
      beqz $t4, lb_fim
      lw $t1, 0($t0)
      andi $t1, $t1, 1
      beqz $t1, lb_fim
      lw $t1, 4($t0)       # le e descarta
      addi $t4, $t4, -1
      j lb_loop

  lb_fim:
     sw $zero, cmd_mover
     sw $zero, cmd_tiro
     sw $zero, cmd_pausa
     sw $zero, cmd_menu
     jr $ra
      
#--------------------------------------------------------------------
# terminar execucao
#--------------------------------------------------------------------
terminar_programa:
    addi  $v0, $zero, 10 
    syscall 
	
