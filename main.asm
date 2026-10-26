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
.eqv E_VITORIA  3
.eqv E_DERROTA  4
.eqv N_ESTADOS  5



#--CODIGO DE CORES--------------------------------------------------
.eqv PRETO        0x00000000
.eqv BRANCO       0x00FFFFFF
.eqv VERMELHO     0x00FF0000
.eqv VERDE        0x0000FF00
.eqv AZUL         0x000000FF
.eqv AMARELO      0x00FFFF00
.eqv CIANO        0x0000FFFF
.eqv ROSA         0x00FF00FF
.eqv LARANJA      0x00FF8A3D

 
 .eqv COR_TIRO_J AMARELO
 .eqv COR_TIRO_I ROSA 
#--ASCII DE TECLAS-------------------------------------------------
.eqv TECLA_ENTER  10
.eqv TECLA_ESPACO 32
.eqv TECLA_A      97
.eqv TECLA_D      100
.eqv TECLA_P      112
.eqv TECLA_S      115
.eqv TECLA_W      119
.eqv MAX_TECLAS   64
#--AUXILIARES PARA NAVE--------------------------------------------
.eqv NAVE_Y 60
.eqv X_MAX_NAVE 61 #LARGURA - 3 (largura da nave)
.eqv TIRO_Y_INI 58
.eqv NAVE_PASSO 2   # colunas por quadro
.eqv TIRO_PASSO 2   # linhas por quadro; NAO pode passar de INI_ALTURA

#-AUXILIARES PARA INIMIGOS----------------------------------------
.eqv INI_ALTURA       3 #ALTURA DO INIMIGO
.eqv INI_LARGURA      3 #LARGURA DO INIMIGO
.eqv INI_Y_BASE       8 # LINHAS 0-7 para pontos e vidas
.eqv GRUPO_X_MIN      0 #
.eqv GRUPO_X_MAX      29 # LARG - 35
.eqv GRUPO_DIVISOR    3 # move a cada 4 quadros
.eqv N_INIMIGOS       20
.eqv INI_DESCIDA       3   # linhas que o grupo desce a cada batida na direita
.eqv INI_Y_LIMITE     59   # NAVE_Y - 1: linha do bico; inimigo aqui = derrota

#-AUXILIARES PARA TIROS INIMIGOS----------------------------------
.eqv MAX_TIROS_INI    6    # tiros inimigos simultaneos na tela
.eqv CADENCIA_INI    10    # quadros entre disparos (valor inicial)

#-AUXILIARES PARA HUD---------------------------------------------
.eqv VIDA_X        1
.eqv VIDA_Y        2
.eqv VIDA_PASSO    4

.eqv META_PONTOS  20    # pontos para vencer == N_INIMIGOS
.eqv BARRA_X      42    # inicio da barra
.eqv BARRA_Y       1
.eqv BARRA_ALT     2    # espessura, em celulas

#-AUXILIARES PARA TEXTO-------------------------------------------
.eqv CHAR_LARG     3
.eqv CHAR_ALT      5
.eqv CHAR_PASSO    4    # 3 do glifo + 1 de espaco
.eqv PAUSE_X      22    # 5 letras x 4 = 19 colunas, centralizado
.eqv PAUSE_Y      30

#-AUXILIARES PARA FIM DE JOGO-------------------------------------
.eqv FIM_TEXTO_X  18    # 7 letras x 4 = 27 colunas, centralizado
.eqv FIM_TEXTO_Y  30    # mesma linha do PAUSE
.eqv TROFEU_X     27    # 9 colunas, centralizado
.eqv TROFEU_Y     18    # 10 linhas, termina 2 acima do texto
.eqv FIM_ESPERA   20    # quadros (1 s) ignorando teclas

#-AUXILIARES PARA MENU--------------------------------------------
.eqv EEA_X          20    # "EEA-25":   6 letras x 4 = 23 colunas
.eqv EEA_Y           2
.eqv INVADERS_X     16    # "INVADERS": 8 letras x 4 = 31 colunas
.eqv INVADERS_Y      8
.eqv JOGAR_X        26    # "JOGAR":    5 letras x 4 = 19 colunas
.eqv JOGAR_Y        20
.eqv SAIR_X         28    # "SAIR":     4 letras x 4 = 15 colunas
.eqv SAIR_Y         26
.eqv MENU_JOGAR      0    # valores de menu_sel
.eqv MENU_SAIR       1
.eqv CURSOR_DX       4    # nave fica 4 colunas a esquerda da opcao
.eqv CURSOR_DY       2    # corpo da nave na linha do meio do glifo

.data
quadros: .word 0

#---MAQUINA DE ESTADO-----------------------------------------------
estado:         .word E_MENU
estado_novo:    .word 1 # 1 se tiver acabado de trocar de estado e 0 c.c
quadros_est:    .word 0 #quadros desde que entrou no estado
tabela_estados: .word est_menu, est_jogo, est_pausa, est_vitoria, est_derrota

#---MENU-------------------------------------------------------------
menu_sel:       .word MENU_JOGAR  # opcao destacada: MENU_JOGAR ou MENU_SAIR

#----ENTRADAS------------------------------------------------------
tecla:        .word 0 

#-JOGADOR--------------------------------------------------------
pontos: .word 0
vidas:  .word 5
nave_x:   .word 30 #LARG/2

#---INIMIGOS------------------------------------------------------
grupo_ini_x:   .word 14
grupo_ini_y:   .word INI_Y_BASE
grupo_x_min:   .word 0
grupo_x_max:   .word 29
grupo_lin_max: .word 12   # maior lin_rel entre os vivos (cache)
grupo_ini_dir: .word 1 

#---TIROS DOS INIMIGOS--------------------------------------------
# cada tiro ocupa 12 bytes: x, y, ativo
# o numero de slots TEM que ser igual a MAX_TIROS_INI
tiros_ini: .word 0,0,0,  0,0,0,  0,0,0,  0,0,0,  0,0,0,  0,0,0

# Cadencia em VARIAVEL, nao constante: permite dificuldade
# progressiva depois, bastando diminuir este valor.
cadencia_tiro_ini: .word CADENCIA_INI
contador_tiro_ini: .word CADENCIA_INI   # conta regressiva

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
cmd_cima:    .word 0    # 1 se W foi apertado
cmd_baixo:   .word 0    # 1 se S foi apertado
cmd_tecla:   .word 0    # 1 se QUALQUER tecla foi apertada

#---FONTE 3x5-----------------------------------------------------
# Cada caractere sao 5 words; cada word e uma linha de 3 bits,
# do bit 2 (coluna esquerda) ao bit 0 (coluna direita).
# Tabela: 000=0  001=1  010=2  011=3  100=4  101=5  110=6  111=7
f_P: .word 6,5,6,4,4        # ##.  #.#  ##.  #..  #..
f_A: .word 2,5,7,5,5        # .#.  #.#  ###  #.#  #.#
f_U: .word 5,5,5,5,2        # #.#  #.#  #.#  #.#  .#.
f_S: .word 3,4,2,1,6        # .##  #..  .#.  ..#  ##.
f_E: .word 7,4,6,4,7        # ###  #..  ##.  #..  ###
f_I: .word 7,2,2,2,7        # ###  .#.  .#.  .#.  ###
f_N: .word 5,7,7,5,5        # #.#  ###  ###  #.#  #.#
f_V: .word 5,5,5,5,2        # #.#  #.#  #.#  #.#  .#.
f_D: .word 6,5,5,5,6        # ##.  #.#  #.#  #.#  ##.
f_R: .word 6,5,6,5,5        # ##.  #.#  ##.  #.#  #.#
f_J: .word 1,1,1,5,2        # ..#  ..#  ..#  #.#  .#.
f_O: .word 2,5,5,5,2        # .#.  #.#  #.#  #.#  .#.
f_G: .word 3,4,5,5,3        # .##  #..  #.#  #.#  .##
f_HIFEN: .word 0,0,7,0,0    # ...  ...  ###  ...  ...
f_T: .word 7,2,2,2,2        # ###  .#.  .#.  .#.  .#.

# trofeu 9x10 = 3 x 2 blocos 3x5, colados sem espaco
tr_topo_esq:  .word 7,5,5,3,1
tr_topo_meio: .word 7,7,7,7,7
tr_topo_dir:  .word 7,5,5,6,4
tr_base_esq:  .word 0,0,0,1,3
tr_base_meio: .word 7,2,2,7,7
tr_base_dir:  .word 0,0,0,4,6

# os 10 digitos, CONTIGUOS: 5 words cada, 20 bytes de passo
f_digitos:
  .word 7,5,5,5,7     # 0
  .word 2,6,2,2,7     # 1
f_2:                  # rotulo dentro da tabela: nao quebra a contiguidade
  .word 7,1,7,4,7     # 2
  .word 7,1,7,1,7     # 3
  .word 5,5,7,1,1     # 4
f_5:
  .word 7,4,7,1,7     # 5
  .word 7,4,7,5,7     # 6
  .word 7,1,1,1,1     # 7
  .word 7,5,7,5,7     # 8
  .word 7,5,7,1,7     # 9


# "PAUSE": lista de ponteiros terminada em 0
s_pause: .word f_P, f_A, f_U, f_S, f_E, 0

# textos do menu, no mesmo formato
s_eea25:    .word f_E, f_E, f_A, f_HIFEN, f_2, f_5, 0
s_invaders: .word f_I, f_N, f_V, f_A, f_D, f_E, f_R, f_S, 0
s_jogar:    .word f_J, f_O, f_G, f_A, f_R, 0
s_sair:     .word f_S, f_A, f_I, f_R, 0

# textos de fim de jogo
s_vitoria: .word f_V, f_I, f_T, f_O, f_R, f_I, f_A, 0
s_derrota: .word f_D, f_E, f_R, f_R, f_O, f_T, f_A, 0

#---SONS--------------------------------------------------------------
# cada som: altura MIDI (60 = do central), duracao (ms),
#           instrumento General MIDI (0-127), volume (0-127)
som_tiro:     .word 72,  50,  13, 60   # xilofone: "tic" curto e discreto
som_explosao: .word 40, 200, 127, 110  # instrumento "gunshot", grave
som_dano:     .word 45, 300,  81, 120  # dente-de-serra grave e longo
som_jogar:    .word 76, 120,  80, 90
som_sair:     .word 71, 120,  80, 90   # 5 semitons abaixo de JOGAR

#---MENSAGENS-------------------------------------------------------
msg_erro_estado: .asciiz "ERRO: estado invalido"
msg_vitoria:     .asciiz "VITORIA!\n"
msg_derrota:     .asciiz "DERROTA!\n"

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
         
#-------------------------------------------------------------------
# desenhar_char — pinta um caractere 3x5 da fonte
#   $a0 = x, $a1 = y, $a2 = cor
#   $a3 = ponteiro para as 5 words do caractere
#
#   Cada word e uma linha; o bit 2 e a coluna da esquerda.
#   Usa $s0-$s4 porque 'pintar' destroi $a0-$a2; $t0-$t5 ficam
#   livres para o laco porque 'pintar' so destroi $t7-$t9.
#-------------------------------------------------------------------
desenhar_char:
    addi $sp, $sp, -24
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)
    sw   $s2, 12($sp)
    sw   $s3, 16($sp)
    sw   $s4, 20($sp)
    move $s0, $a0                # x base
    move $s1, $a1                # y base
    move $s2, $a2                # cor
    move $s3, $a3                # ponteiro
    li   $s4, 0                  # linha corrente

dc_linha:
    li   $t0, CHAR_ALT
    bge  $s4, $t0, dc_fim
    lw   $t1, 0($s3)             # mascara de 3 bits da linha
    li   $t2, 0                  # coluna corrente

dc_col:
    li   $t3, CHAR_LARG
    bge  $t2, $t3, dc_prox_linha
    li   $t4, 2
    sub  $t4, $t4, $t2           # bit 2 = coluna 0
    srlv $t5, $t1, $t4
    andi $t5, $t5, 1
    beqz $t5, dc_prox_col

    add  $a0, $s0, $t2
    add  $a1, $s1, $s4
    move $a2, $s2
    jal  pintar

dc_prox_col:
    addi $t2, $t2, 1
    j    dc_col

dc_prox_linha:
    addi $s3, $s3, 4
    addi $s4, $s4, 1
    j    dc_linha

dc_fim:
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $s2, 12($sp)
    lw   $s3, 16($sp)
    lw   $s4, 20($sp)
    addi $sp, $sp, 24
    jr   $ra
    
#-------------------------------------------------------------------
# desenhar_texto — escreve uma cadeia de caracteres
#   $a0 = x, $a1 = y, $a2 = cor
#   $a3 = lista de ponteiros de caractere terminada por 0
#-------------------------------------------------------------------
desenhar_texto:
    addi $sp, $sp, -20
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)
    sw   $s2, 12($sp)
    sw   $s3, 16($sp)
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3

dt_loop:
    lw   $t0, 0($s3)
    beqz $t0, dt_fim             # sentinela
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    move $a3, $t0
    jal  desenhar_char
    addi $s0, $s0, CHAR_PASSO
    addi $s3, $s3, 4
    j    dt_loop

dt_fim:
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $s2, 12($sp)
    lw   $s3, 16($sp)
    addi $sp, $sp, 20
    jr   $ra

#-------------------------------------------------------------------
# desenhar_trofeu — trofeu 9x10 em amarelo
#   $a0 = x, $a1 = y (canto superior esquerdo)
#
#     #########
#     #.#####.#
#     #.#####.#
#     .#######.
#     ..#####..
#     ...###...
#     ....#....
#     ....#....
#     ..#####..
#     .#######.
#
#   6 blocos 3x5 no formato da fonte, colados sem espaco.
#   Usa $s0-$s1 porque desenhar_char destroi $a0-$a3.
#-------------------------------------------------------------------
desenhar_trofeu:
    addi $sp, $sp, -12
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)
    move $s0, $a0
    move $s1, $a1

    move $a0, $s0                # topo, esquerda
    move $a1, $s1
    li   $a2, AMARELO
    la   $a3, tr_topo_esq
    jal  desenhar_char
    addi $a0, $s0, CHAR_LARG     # topo, meio
    move $a1, $s1
    li   $a2, AMARELO
    la   $a3, tr_topo_meio
    jal  desenhar_char
    addi $a0, $s0, CHAR_LARG     # topo, direita
    addi $a0, $a0, CHAR_LARG
    move $a1, $s1
    li   $a2, AMARELO
    la   $a3, tr_topo_dir
    jal  desenhar_char

    move $a0, $s0                # base, esquerda
    addi $a1, $s1, CHAR_ALT
    li   $a2, AMARELO
    la   $a3, tr_base_esq
    jal  desenhar_char
    addi $a0, $s0, CHAR_LARG     # base, meio
    addi $a1, $s1, CHAR_ALT
    li   $a2, AMARELO
    la   $a3, tr_base_meio
    jal  desenhar_char
    addi $a0, $s0, CHAR_LARG     # base, direita
    addi $a0, $a0, CHAR_LARG
    addi $a1, $s1, CHAR_ALT
    li   $a2, AMARELO
    la   $a3, tr_base_dir
    jal  desenhar_char

    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    addi $sp, $sp, 12
    jr   $ra
    
#-------------------------------------------------------------------
# desenhar_pontos — barra de progresso no canto superior direito
#
#   Uma celula por ponto, META_PONTOS celulas no total. Como a meta
#   e 20 e a barra tem 20 celulas, nao ha divisao nenhuma: o numero
#   de pontos E a largura preenchida.
#
#   A moldura vazia aparece sempre, para o jogador ver o quanto falta.
#-------------------------------------------------------------------
desenhar_pontos:
    addi $sp, $sp, -20
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)
    sw   $s2, 12($sp)
    sw   $s3, 16($sp)

    lw   $s2, pontos
    li   $s1, 0                   # coluna corrente, de 0 a META-1

dp_loop:
    li   $t0, META_PONTOS
    bge  $s1, $t0, dp_fim

    li   $s3, VERDE               # cor desta coluna: preenchida
    blt  $s1, $s2, dp_cor_ok
    li   $s3, AZUL                # ou vazia
dp_cor_ok:

    li   $s0, 0                   # percorre a espessura
dp_linha:
    li   $t0, BARRA_ALT
    bge  $s0, $t0, dp_prox
    li   $a0, BARRA_X
    add  $a0, $a0, $s1
    li   $a1, BARRA_Y
    add  $a1, $a1, $s0
    move $a2, $s3                 # recarrega a cor a cada pixel
    jal  pintar
    addi $s0, $s0, 1
    j    dp_linha

dp_prox:
    addi $s1, $s1, 1
    j    dp_loop

dp_fim:
    li   $a0, 33                 # a esquerda da barra
    li   $a1, BARRA_Y
    li   $a2, BRANCO
    lw   $a3, pontos
    jal  desenhar_num

    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $s2, 12($sp)
    lw   $s3, 16($sp)
    addi $sp, $sp, 20
    jr   $ra
 
#-------------------------------------------------------------------
# desenhar_num — escreve um numero de 2 digitos com zero a esquerda
#   $a0 = x, $a1 = y, $a2 = cor, $a3 = valor (0 a 99)
#-------------------------------------------------------------------
desenhar_num:
    addi $sp, $sp, -24
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)
    sw   $s2, 12($sp)
    sw   $s3, 16($sp)
    sw   $s4, 20($sp)
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3

    li   $t0, 99                 # satura: 3 digitos nao caberiam
    ble  $s3, $t0, dn_ok
    move $s3, $t0
dn_ok:
    li   $s4, 10                 # divisor corrente

dn_loop:
    div  $s3, $s4
    mflo $t0                     # digito
    mfhi $s3                     # resto para a proxima casa

    li   $t1, 20                 # 5 words por digito
    mul  $t1, $t0, $t1
    la   $a3, f_digitos
    add  $a3, $a3, $t1
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    jal  desenhar_char

    addi $s0, $s0, CHAR_PASSO
    li   $t2, 10
    div  $s4, $t2
    mflo $s4
    bnez $s4, dn_loop

    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $s2, 12($sp)
    lw   $s3, 16($sp)
    lw   $s4, 20($sp)
    addi $sp, $sp, 24
    jr   $ra
 
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
#-------------------------------------------------------------------
# E_MENU — titulo, duas opcoes e a nave como cursor
#   W / S alternam menu_sel; Espaco confirma a opcao destacada.
#   Redesenha tudo a cada quadro, como est_jogo: a opcao destacada
#   e o cursor dependem de menu_sel, que muda com a entrada.
#   Posicao do cursor sai SO de menu_sel:
#     x = JOGAR_X + menu_sel * (SAIR_X - JOGAR_X) - CURSOR_DX
#     y = JOGAR_Y + menu_sel * (SAIR_Y - JOGAR_Y) + CURSOR_DY
#-------------------------------------------------------------------
est_menu:
    addi $sp, $sp, -8
    sw   $ra, 0($sp)
    sw   $a0, 4($sp)

    lw   $t0, 4($sp)
    beqz $t0, menu_corpo
    li   $t0, MENU_JOGAR         # bloco de entrada: sempre abre em JOGAR
    sw   $t0, menu_sel

    menu_corpo:
      lw   $t0, cmd_cima          # com 2 opcoes, subir e descer
      beqz $t0, menu_testa_baixo  # sao a mesma coisa: alternar
      lw   $t1, menu_sel
      xori $t1, $t1, 1
      sw   $t1, menu_sel

    menu_testa_baixo:
      lw   $t0, cmd_baixo
      beqz $t0, menu_som
      lw   $t1, menu_sel
      xori $t1, $t1, 1
      sw   $t1, menu_sel

    menu_som:                     # W ou S: som da opcao que ficou
      lw   $t0, cmd_cima
      lw   $t1, cmd_baixo
      or   $t0, $t0, $t1
      beqz $t0, menu_testa_espaco
      la   $a0, som_jogar
      lw   $t0, menu_sel
      li   $t1, MENU_SAIR
      bne  $t0, $t1, menu_som_ok
      la   $a0, som_sair          # SAIR e mais grave
    menu_som_ok:
      jal  tocar_som

    menu_testa_espaco:
      lw   $t0, cmd_tiro          # Espaco confirma
      beqz $t0, menu_desenha
      lw   $t1, menu_sel
      li   $t2, MENU_SAIR
      beq  $t1, $t2, terminar_programa   # SAIR: syscall 10, nao volta
      jal  jogo_reset
      li   $a0, E_JOGO
      jal  mudar_estado
      j    menu_fim

    menu_desenha:
      li   $a2, PRETO
      jal  pintar_tela             # limpa o buffer da tela

      li   $a0, EEA_X              # titulo, linha 1
      li   $a1, EEA_Y
      li   $a2, CIANO
      la   $a3, s_eea25
      jal  desenhar_texto

      li   $a0, INVADERS_X         # titulo, linha 2
      li   $a1, INVADERS_Y
      li   $a2, CIANO
      la   $a3, s_invaders
      jal  desenhar_texto

      li   $a2, BRANCO             # JOGAR: laranja se destacada
      lw   $t0, menu_sel
      li   $t1, MENU_JOGAR
      bne  $t0, $t1, menu_jogar_cor_ok
      li   $a2, LARANJA
    menu_jogar_cor_ok:
      li   $a0, JOGAR_X
      li   $a1, JOGAR_Y
      la   $a3, s_jogar
      jal  desenhar_texto

      li   $a2, BRANCO             # SAIR: laranja se destacada
      lw   $t0, menu_sel
      li   $t1, MENU_SAIR
      bne  $t0, $t1, menu_sair_cor_ok
      li   $a2, LARANJA
    menu_sair_cor_ok:
      li   $a0, SAIR_X
      li   $a1, SAIR_Y
      la   $a3, s_sair
      jal  desenhar_texto

      lw   $t0, menu_sel           # cursor
      li   $t1, SAIR_X
      addi $t1, $t1, -JOGAR_X      # distancia entre as opcoes em x
      mul  $t1, $t1, $t0
      addi $a0, $t1, JOGAR_X
      addi $a0, $a0, -CURSOR_DX
      li   $t1, SAIR_Y
      addi $t1, $t1, -JOGAR_Y      # distancia entre as opcoes em y
      mul  $t1, $t1, $t0
      addi $a1, $t1, JOGAR_Y
      addi $a1, $a1, CURSOR_DY
      jal  desenhar_nave

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
      jal atualizar_tiros_ini
      jal  colisao_tiro_inimigos
      jal  colisao_tiros_ini_nave
      jal  checar_fim_jogo

    jogo_desenha:
      li   $a2, PRETO
      jal  pintar_tela             # limpa o buffer da tela
      jal desenhar_inimigos
      lw   $a0, nave_x
      li   $a1, NAVE_Y
      jal desenhar_nave
      jal desenhar_tiro_jogador
      jal desenhar_tiros_ini
      jal desenhar_vidas
      jal desenhar_pontos

    jogo_fim:
      lw   $ra, 0($sp)
      addi $sp, $sp, 4
      jr   $ra

#-------------------------------------------------------------------
# E_PAUSA — nao limpa o buffer nem redesenha nada do jogo.
#   A tela congela exatamente como estava e "PAUSE" e escrito por
#   cima, uma unica vez, no bloco de entrada.
#   Ao voltar, est_jogo limpa tudo e a palavra some sozinha.
#-------------------------------------------------------------------
est_pausa:
    addi $sp, $sp, -8
    sw   $ra, 0($sp)
    sw   $a0, 4($sp)

    lw   $t0, 4($sp)
    beqz $t0, pausa_corpo
    li   $a0, PAUSE_X            # bloco de entrada: escreve uma vez
    li   $a1, PAUSE_Y
    li   $a2, BRANCO
    la   $a3, s_pause
    jal  desenhar_texto

pausa_corpo:
    lw   $t0, cmd_pausa
    beqz $t0, pausa_fim
    li   $a0, E_JOGO
    jal  mudar_estado

pausa_fim:
    lw   $ra, 0($sp)
    addi $sp, $sp, 8
    jr   $ra

#-------------------------------------------------------------------
# E_VITORIA — mesmo molde de E_PAUSA: congela a tela do ultimo
#   quadro e desenha por cima, uma unica vez, trofeu e "VITORIA".
#   Qualquer tecla volta ao menu, mas so apos FIM_ESPERA quadros:
#   sem isso, o Espaco que o jogador segurava atirando pularia a
#   tela na hora (repeticao de tecla).
#-------------------------------------------------------------------
est_vitoria:
    addi $sp, $sp, -8
    sw   $ra, 0($sp)
    sw   $a0, 4($sp)

    lw   $t0, 4($sp)
    beqz $t0, vitoria_corpo
    li   $a0, TROFEU_X           # bloco de entrada: desenha uma vez
    li   $a1, TROFEU_Y
    jal  desenhar_trofeu
    li   $a0, FIM_TEXTO_X
    li   $a1, FIM_TEXTO_Y
    li   $a2, AMARELO
    la   $a3, s_vitoria
    jal  desenhar_texto

vitoria_corpo:
    lw   $t0, quadros_est
    li   $t1, FIM_ESPERA
    blt  $t0, $t1, vitoria_fim   # ainda na trava
    lw   $t0, cmd_tecla
    beqz $t0, vitoria_fim
    li   $a0, E_MENU
    jal  mudar_estado

vitoria_fim:
    lw   $ra, 0($sp)
    addi $sp, $sp, 8
    jr   $ra

#-------------------------------------------------------------------
# E_DERROTA — igual a E_VITORIA, sem trofeu: "DERROTA" em vermelho
#   por cima da tela congelada; qualquer tecla, apos FIM_ESPERA
#   quadros, volta ao menu.
#-------------------------------------------------------------------
est_derrota:
    addi $sp, $sp, -8
    sw   $ra, 0($sp)
    sw   $a0, 4($sp)

    lw   $t0, 4($sp)
    beqz $t0, derrota_corpo
    li   $a0, FIM_TEXTO_X        # bloco de entrada: escreve uma vez
    li   $a1, FIM_TEXTO_Y
    li   $a2, VERMELHO
    la   $a3, s_derrota
    jal  desenhar_texto

derrota_corpo:
    lw   $t0, quadros_est
    li   $t1, FIM_ESPERA
    blt  $t0, $t1, derrota_fim   # ainda na trava
    lw   $t0, cmd_tecla
    beqz $t0, derrota_fim
    li   $a0, E_MENU
    jal  mudar_estado

derrota_fim:
    lw   $ra, 0($sp)
    addi $sp, $sp, 8
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
#-------------------------------------------------------------------
# jogo_reset — devolve o jogo ao estado inicial
#
#   Chamado pela TRANSICAO menu -> jogo, nunca pela entrada do estado:
#   E_JOGO tambem e alcancado vindo da pausa, e ali nao se reinicia.
#-------------------------------------------------------------------
jogo_reset:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    # --- placar ---
    sw   $zero, pontos
    li   $t0, 5
    sw   $t0, vidas

    # --- nave e tiro do jogador ---
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
jr_inimigos:
    sw   $t3, 8($t1)             # campo 'vivo'
    addi $t1, $t1, 12
    addi $t2, $t2, -1
    bnez $t2, jr_inimigos

    # --- limpa os tiros inimigos ---
    la   $t1, tiros_ini
    li   $t2, MAX_TIROS_INI
jr_tiros:
    sw   $zero, 8($t1)           # campo 'ativo'
    addi $t1, $t1, 12
    addi $t2, $t2, -1
    bnez $t2, jr_tiros

    # --- cadencia de volta ao valor inicial ---
    li   $t0, CADENCIA_INI
    sw   $t0, cadencia_tiro_ini
    sw   $t0, contador_tiro_ini

    jal  recalcular_limites      # o cache depende de quem esta vivo

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra
    
#-------------------------------------------------------------------
# checar_fim_jogo — decide se a partida acabou
#   Vitoria: pontos >= META_PONTOS.
#   Derrota: vidas <= 0, ou invasao — a borda de baixo do inimigo
#   vivo mais baixo (grupo_ini_y + grupo_lin_max + INI_ALTURA - 1)
#   alcanca INI_Y_LIMITE.
#   Prioridade no mesmo quadro: vitoria, vidas, invasao.
#   Imprime o resultado no console (syscall 4) e pede a transicao;
#   quem espera a tecla e o estado seguinte (regra 1: sem laco aqui).
#-------------------------------------------------------------------
checar_fim_jogo:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    lw   $t0, pontos
    li   $t1, META_PONTOS
    blt  $t0, $t1, cfj_testa_derrota
    la   $a0, msg_vitoria
    li   $v0, 4
    syscall
    li   $a0, E_VITORIA
    jal  mudar_estado
    j    cfj_fim

cfj_testa_derrota:
    lw   $t0, vidas
    blez $t0, cfj_derrota
    lw   $t0, grupo_ini_y            # borda de baixo do inimigo vivo mais baixo,
    lw   $t1, grupo_lin_max          # mais 1 (evita o -1 de INI_ALTURA-1)
    add  $t0, $t0, $t1
    addi $t0, $t0, INI_ALTURA
    li   $t1, INI_Y_LIMITE
    ble  $t0, $t1, cfj_fim           # ainda acima da nave
cfj_derrota:
    la   $a0, msg_derrota
    li   $v0, 4
    syscall
    li   $a0, E_DERROTA
    jal  mudar_estado

cfj_fim:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

#---FIM ESTADOS-----------------------------------------------------

#---NAVE------------------------------------------------------------
#-------------------------------------------------------------------
# mover_nave — anda NAVE_PASSO colunas na direcao de cmd_mover
#   nave_x fica sempre em [0, X_MAX_NAVE]: o passo pode passar da
#   borda (ex.: 60 + 2 = 62), entao o valor e CORTADO no limite,
#   nao descartado — a nave encosta na parede em vez de parar antes.
#-------------------------------------------------------------------
mover_nave:
    lw   $t0, cmd_mover
    beqz $t0, mn_fim                 # parado
    lw   $t1, nave_x
    li   $t2, NAVE_PASSO
    mul  $t0, $t0, $t2               # -1/+1 vira -PASSO/+PASSO
    add  $t1, $t1, $t0

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
# desenhar_nave — pinta a nave com o corpo em (x, y)
#   $a0 = x da celula esquerda do corpo, $a1 = y do corpo
#
#     .#.      bico em (x+1, y-1)
#     ###      corpo em (x..x+2, y)
#
#   Usada pelo jogo (nave_x, NAVE_Y) e pelo cursor do menu.
#   Usa $s0-$s1 porque 'pintar' destroi $a0-$a2 a cada chamada.
#-----------------------------------------------------------------
desenhar_nave:
    addi $sp, $sp, -12
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)
    move $s0, $a0                # x
    move $s1, $a1                # y

    move $a0, $s0                # corpo: tres celulas
    move $a1, $s1
    li   $a2, BRANCO
    jal  pintar
    addi $a0, $s0, 1
    move $a1, $s1
    li   $a2, BRANCO
    jal  pintar
    addi $a0, $s0, 2
    move $a1, $s1
    li   $a2, BRANCO
    jal  pintar

    addi $a0, $s0, 1             # bico: uma acima, no centro
    addi $a1, $s1, -1
    li   $a2, BRANCO
    jal  pintar

    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    addi $sp, $sp, 12
    jr   $ra
    
#-------------------------------------------------------------------
# mover_tiro_jogador
#   Se nao ha tiro, ESPACO dispara. Se ha, ele sobe e some ao sair.
#   A flag 'ha_tiro_jogador' sozinha impoe a regra de um tiro por vez
#   Toca som_tiro quando o tiro nasce.
#-------------------------------------------------------------------
mover_tiro_jogador:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

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
    la   $a0, som_tiro
    jal  tocar_som
    j    mtj_fim

    # --- existe: sobe TIRO_PASSO linhas ---
mtj_existe:
    lw   $t1, tiro_jogador_y
    addi $t1, $t1, -TIRO_PASSO
    bgez $t1, mtj_grava
    sw   $zero, ha_tiro_jogador  # saiu pelo topo
    j    mtj_fim
mtj_grava:
    sw   $t1, tiro_jogador_y

mtj_fim:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
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
    
#-------------------------------------------------------------------
# colisao_tiros_ini_nave — tiros inimigos contra a nave
#
#   A nave ocupa:
#     corpo: (nave_x .. nave_x+2, NAVE_Y)
#     bico:  (nave_x+1, NAVE_Y-1)
#   Percorre TODOS os tiros: varios podem acertar no mesmo quadro.
#   Conta os acertos em $t5 e toca som_dano uma vez, depois do laco:
#   chamar tocar_som la dentro destruiria os $t do laco.
#-------------------------------------------------------------------
colisao_tiros_ini_nave:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    li   $t5, 0                   # acertos neste quadro
    lw   $t6, nave_x
    addi $t7, $t6, 2              # borda direita da nave
    li   $t8, NAVE_Y
    addi $t9, $t8, -1             # linha do bico

    la   $t0, tiros_ini
    li   $t1, MAX_TIROS_INI

ctn_loop:
    lw   $t2, 8($t0)              # ativo?
    beqz $t2, ctn_prox

    lw   $t2, 0($t0)              # x do tiro
    blt  $t2, $t6, ctn_prox       # a esquerda da nave
    bgt  $t2, $t7, ctn_prox       # a direita da nave

    lw   $t3, 4($t0)              # y do tiro
    blt  $t3, $t9, ctn_prox       # acima do bico
    bgt  $t3, $t8, ctn_prox       # abaixo do corpo

    # --- acertou ---
    sw   $zero, 8($t0)            # o tiro some
    lw   $t4, vidas
    addi $t4, $t4, -1
    sw   $t4, vidas
    addi $t5, $t5, 1

ctn_prox:
    addi $t0, $t0, 12
    addi $t1, $t1, -1
    bnez $t1, ctn_loop

    beqz $t5, ctn_fim
    la   $a0, som_dano
    jal  tocar_som

ctn_fim:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra
#---INIMIGOS---------------------------------------------------------

#-------------------------------------------------------------------
# recalcular_limites — atualiza grupo_x_min e grupo_x_max
#
#   Varre os inimigos vivos procurando o menor e o maior col_rel.
#   O bloco pode ir ate onde o inimigo da ponta encoste na borda.
#   Guarda tambem o maior lin_rel (grupo_lin_max): a fileira viva
#   mais baixa, usada pela derrota por invasao.
#
#   CHAMAR SEMPRE QUE: um inimigo morrer, ou o jogo for reiniciado
#-------------------------------------------------------------------
recalcular_limites:
    la   $t0, inimigos
    li   $t1, N_INIMIGOS
    li   $t2, 9999                   # menor col_rel
    li   $t3, -1                     # maior col_rel
    li   $t6, -1                     # maior lin_rel

    rl_loop:
      lw   $t4, 8($t0)                 # vivo?
      beqz $t4, rl_prox
      lw   $t4, 4($t0)                 # lin_rel
      ble  $t4, $t6, rl_col
      move $t6, $t4

    rl_col:
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

      sw   $t6, grupo_lin_max          # antes do teste de 'nenhum vivo'
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
#   Ao bater na borda direita, desce INI_DESCIDA linhas.
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
    lw   $t4, grupo_ini_y            # e avanca em direcao ao jogador
    addi $t4, $t4, INI_DESCIDA
    sw   $t4, grupo_ini_y

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


#-------------------------------------------------------------------
# colisao_tiro_inimigos — tiro do jogador contra os inimigos vivos
#
#   Teste AABB: o tiro (1x1) esta dentro do retangulo do inimigo
#   (3x3) quando cai no intervalo nos DOIS eixos.
#
#   Posicao absoluta do inimigo = grupo_ini_x + col_rel
#                                 grupo_ini_y + lin_rel
#
#   Ao acertar: mata, apaga o tiro, soma ponto, recalcula os limites
#   e encerra o laco — um tiro acerta um inimigo so.
#-------------------------------------------------------------------
colisao_tiro_inimigos:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    lw   $t0, ha_tiro_jogador
    beqz $t0, cti_fim             # sem tiro, nada a testar

    lw   $t8, tiro_jogador_x
    lw   $t9, tiro_jogador_y
    lw   $t6, grupo_ini_x
    lw   $t7, grupo_ini_y

    la   $t0, inimigos
    li   $t1, N_INIMIGOS

cti_loop:
    lw   $t2, 8($t0)              # vivo?
    beqz $t2, cti_prox

    lw   $t2, 0($t0)              # col_rel
    add  $t2, $t6, $t2            # x do inimigo
    lw   $t3, 4($t0)              # lin_rel
    add  $t3, $t7, $t3            # y do inimigo

    blt  $t8, $t2, cti_prox       # tiro a esquerda
    addi $t4, $t2, INI_LARGURA
    addi $t4, $t4, -1             # borda direita
    bgt  $t8, $t4, cti_prox       # tiro a direita

    blt  $t9, $t3, cti_prox       # tiro acima
    addi $t4, $t3, INI_ALTURA
    addi $t4, $t4, -1             # borda de baixo
    bgt  $t9, $t4, cti_prox       # tiro abaixo

    # --- acertou ---
    sw   $zero, 8($t0)            # inimigo morre
    sw   $zero, ha_tiro_jogador   # o tiro some
    lw   $t2, pontos
    addi $t2, $t2, 1
    sw   $t2, pontos
    la   $a0, som_explosao
    jal  tocar_som
    jal  recalcular_limites       # invariante do cache
    j    cti_fim                  # um tiro acerta um inimigo so

cti_prox:
    addi $t0, $t0, 12
    addi $t1, $t1, -1
    bnez $t1, cti_loop

cti_fim:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra
    
    
#-------------------------------------------------------------------
# escolher_atirador — decide QUAL inimigo dispara
#   saida: $v0 = endereco do registro do inimigo, ou 0 se nenhum vivo
#
#   Rotina folha: syscalls do MARS nao alteram os registradores $t.
#-------------------------------------------------------------------
escolher_atirador:
    # --- 1) conta quantos estao vivos ---
    la   $t0, inimigos
    li   $t1, N_INIMIGOS
    li   $t2, 0
ea_conta:
    lw   $t3, 8($t0)
    beqz $t3, ea_conta_prox
    addi $t2, $t2, 1
ea_conta_prox:
    addi $t0, $t0, 12
    addi $t1, $t1, -1
    bnez $t1, ea_conta

    beqz $t2, ea_vazio

    # --- 2) sorteia um indice entre 0 e vivos-1 ---
    li   $v0, 42
    li   $a0, 0                  # gerador 0
    move $a1, $t2                # limite superior exclusivo
    syscall                      # resultado em $a0
    move $t4, $a0

    # --- 3) caminha ate o n-esimo vivo ---
    la   $t0, inimigos
ea_busca:
    lw   $t3, 8($t0)
    beqz $t3, ea_busca_prox
    beqz $t4, ea_achou
    addi $t4, $t4, -1
ea_busca_prox:
    addi $t0, $t0, 12
    j    ea_busca

ea_achou:
    move $v0, $t0
    jr   $ra
ea_vazio:
    li   $v0, 0
    jr   $ra

#-------------------------------------------------------------------
# slot_tiro_ini_livre — procura um lugar vago no vetor de tiros
#   saida: $v0 = endereco do slot, ou 0 se todos ocupados
#-------------------------------------------------------------------
slot_tiro_ini_livre:
    la   $t0, tiros_ini
    li   $t1, MAX_TIROS_INI
stl_loop:
    lw   $t2, 8($t0)             # ativo?
    beqz $t2, stl_achou
    addi $t0, $t0, 12
    addi $t1, $t1, -1
    bnez $t1, stl_loop
    li   $v0, 0                  # cheio
    jr   $ra
stl_achou:
    move $v0, $t0
    jr   $ra

#-------------------------------------------------------------------
# disparar_tiro_ini — cria um tiro, se houver vaga e atirador
#   O tiro nasce no centro do inimigo, uma linha abaixo dele.
#-------------------------------------------------------------------
disparar_tiro_ini:
    addi $sp, $sp, -8
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)

    jal  slot_tiro_ini_livre
    beqz $v0, dti_fim            # ja ha MAX_TIROS_INI na tela
    move $s0, $v0                # guarda: o proximo jal destroi $v0

    jal  escolher_atirador
    beqz $v0, dti_fim            # nenhum inimigo vivo

    lw   $t0, 0($v0)             # col_rel
    lw   $t1, grupo_ini_x
    add  $t0, $t0, $t1
    addi $t0, $t0, 1             # centro do inimigo (3 de largura)
    sw   $t0, 0($s0)

    lw   $t0, 4($v0)             # lin_rel
    lw   $t1, grupo_ini_y
    add  $t0, $t0, $t1
    addi $t0, $t0, INI_ALTURA    # logo abaixo do sprite
    sw   $t0, 4($s0)

    li   $t0, 1
    sw   $t0, 8($s0)             # ativa o slot

dti_fim:
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    addi $sp, $sp, 8
    jr   $ra

#-------------------------------------------------------------------
# mover_tiros_ini — desce os ativos, desativa os que saem da tela
#-------------------------------------------------------------------
mover_tiros_ini:
    la   $t0, tiros_ini
    li   $t1, MAX_TIROS_INI
mti_loop:
    lw   $t2, 8($t0)
    beqz $t2, mti_prox
    lw   $t3, 4($t0)
    addi $t3, $t3, 1             # desce uma linha
    li   $t4, ALT
    blt  $t3, $t4, mti_grava
    sw   $zero, 8($t0)           # saiu por baixo: libera o slot
    j    mti_prox
mti_grava:
    sw   $t3, 4($t0)
mti_prox:
    addi $t0, $t0, 12
    addi $t1, $t1, -1
    bnez $t1, mti_loop
    jr   $ra

#-------------------------------------------------------------------
# desenhar_tiros_ini — pinta os ativos
#-------------------------------------------------------------------
desenhar_tiros_ini:
    addi $sp, $sp, -12
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)

    la   $s0, tiros_ini
    li   $s1, MAX_TIROS_INI
dts_loop:
    lw   $t0, 8($s0)
    beqz $t0, dts_prox
    lw   $a0, 0($s0)
    lw   $a1, 4($s0)
    li   $a2, COR_TIRO_I
    jal  pintar
dts_prox:
    addi $s0, $s0, 12
    addi $s1, $s1, -1
    bnez $s1, dts_loop

    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    addi $sp, $sp, 12
    jr   $ra

#-------------------------------------------------------------------
# atualizar_tiros_ini — um quadro dos tiros inimigos
#   Move os existentes e dispara um novo quando o contador zera.
#-------------------------------------------------------------------
atualizar_tiros_ini:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    jal  mover_tiros_ini

    lw   $t0, contador_tiro_ini
    addi $t0, $t0, -1
    bgtz $t0, ati_grava
    jal  disparar_tiro_ini
    lw   $t0, cadencia_tiro_ini  # recarrega o contador
ati_grava:
    sw   $t0, contador_tiro_ini

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra


#-------------------------------------------------------------------
# tocar_som — toca uma nota MIDI sem bloquear (syscall 31)
#   $a0 = endereco do registro: altura, duracao, instrumento, volume
#   Retorna na hora; o som toca enquanto o jogo segue.
#   Rotina folha.
#-------------------------------------------------------------------
tocar_som:
    move $t0, $a0
    lw   $a0, 0($t0)
    lw   $a1, 4($t0)
    lw   $a2, 8($t0)
    lw   $a3, 12($t0)
    li   $v0, 31
    syscall
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
    sw   $zero, cmd_cima
    sw   $zero, cmd_baixo
    sw   $zero, cmd_tecla

    lui  $t0, 0xffff
    li   $t4, MAX_TECLAS             # teto de seguranca

le_loop:
    beqz $t4, le_fim
    lw   $t1, 0($t0)
    andi $t1, $t1, 1
    beqz $t1, le_fim                 # fila vazia
    lw   $t2, 4($t0)
    addi $t4, $t4, -1
    li   $t5, 1                      # qualquer byte conta como tecla
    sw   $t5, cmd_tecla

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
    bne  $t2, $t3, le_testa_w
    li   $t5, 1
    sw   $t5, cmd_menu
    j    le_loop

le_testa_w:
    li   $t3, TECLA_W
    bne  $t2, $t3, le_testa_s
    li   $t5, 1
    sw   $t5, cmd_cima
    j    le_loop

le_testa_s:
    li   $t3, TECLA_S
    bne  $t2, $t3, le_loop           # tecla desconhecida: ignora
    li   $t5, 1
    sw   $t5, cmd_baixo
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
     sw $zero, cmd_cima
     sw $zero, cmd_baixo
     sw $zero, cmd_tecla
     jr $ra
     
     
#-------------------------------------------------------------------
# desenhar_vidas — uma mini-nave por vida, no canto superior esquerdo
#   Usa o mesmo formato da nave do jogador, em escala 1:1.
#-------------------------------------------------------------------
desenhar_vidas:
    addi $sp, $sp, -16
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)
    sw   $s2, 12($sp)

    lw   $s1, vidas
    blez $s1, dv_fim              # zero vidas: nada a desenhar
    li   $s0, VIDA_X              # coluna corrente

dv_loop:
    li   $a1, VIDA_Y              # corpo: tres celulas
    move $a0, $s0
    li   $a2, BRANCO
    jal  pintar
    li   $a1, VIDA_Y
    addi $a0, $s0, 1
    li   $a2, BRANCO
    jal  pintar
    li   $a1, VIDA_Y
    addi $a0, $s0, 2
    li   $a2, BRANCO
    jal  pintar

    li   $a1, VIDA_Y              # bico
    addi $a1, $a1, -1
    addi $a0, $s0, 1
    li   $a2, BRANCO
    jal  pintar

    addi $s0, $s0, VIDA_PASSO
    addi $s1, $s1, -1
    bnez $s1, dv_loop

dv_fim:
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $s2, 12($sp)
    addi $sp, $sp, 16
    jr   $ra
      
#--------------------------------------------------------------------
# terminar execucao
#--------------------------------------------------------------------
terminar_programa:
    addi  $v0, $zero, 10 
    syscall 
	
