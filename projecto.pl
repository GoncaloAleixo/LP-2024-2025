% lp24 - ist1106900 - projecto 
:- use_module(library(clpfd)). % para poder usar transpose/2
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % ver listas completas
:- [puzzles]. % Ficheiro dado. A avaliação terá mais puzzles.
:- [codigoAuxiliar]. % Ficheiro dado. Não alterar.
% Atenção: nao deves copiar nunca os puzzles para o teu ficheiro de código
% Nao remover nem modificar as linhas anteriores. Obrigado.
% Segue-se o código
%%%%%%%%%%%%

%------------------------------------------------------------------------------
%                             visualiza/1
% visualiza(Tabuleiro) escreve cada elemento de uma lista do tabuleiro em uma 
% nova linha.
%------------------------------------------------------------------------------
visualiza([]).
visualiza([H | T]) :-
    writeln(H),
    visualiza(T).

%------------------------------------------------------------------------------
%                          visualizaLinha/1
% visualizaLinha(Lista) escreve cada elemento de uma lista com um contador de
% linhas, para facilitar a depuração.
%------------------------------------------------------------------------------
visualizaLinha(Lista) :-
    visualizaLinha(Lista, 1).

visualizaLinha([], _).
visualizaLinha([H | T], N) :-
    write(N), write(': '), writeln(H),
    N1 is N + 1,
    visualizaLinha(T, N1).

%------------------------------------------------------------------------------
%                          insereObjecto/3
% insereObjecto((L, C), Tabuleiro, Obj) insere um objeto Obj em uma posição
% específica (L, C) no Tabuleiro, se esta estiver válida.
%------------------------------------------------------------------------------
insereObjecto((L, C), Tabuleiro, Obj) :-
    length(Tabuleiro, NumLinhas),
    (L > 0, L =< NumLinhas ->
        nth1(L, Tabuleiro, Linha),
        length(Linha, NumColunas),
        (C > 0, C =< NumColunas ->
            nth1(C, Linha, Celula),
            (var(Celula) -> Celula = Obj ; true)
        ;
            true)
    ;
        true).

%------------------------------------------------------------------------------
%                       insereVariosObjectos/3
% insereVariosObjectos(Coords, Tabuleiro, Objetos) insere uma lista de objetos
% Objetos nas coordenadas Coords do Tabuleiro.
%------------------------------------------------------------------------------
insereVariosObjectos([], _, []).
insereVariosObjectos([(L, C) | Coords], Tabuleiro, [Obj | Objs]) :-
    insereObjecto((L, C), Tabuleiro, Obj),
    insereVariosObjectos(Coords, Tabuleiro, Objs).

%------------------------------------------------------------------------------
%                       inserePontosVolta/2
% inserePontosVolta(Tabuleiro, Coord) insere pontos ao redor de uma coordenada
% específica Coord no Tabuleiro, respeitando os limites.
%------------------------------------------------------------------------------
inserePontosVolta(Tabuleiro, (L, C)) :-
    findall((NL, NC),
        (   member(DeltaL, [-1, 0, 1]),
            member(DeltaC, [-1, 0, 1]),
            NL is L + DeltaL, NC is C + DeltaC,
            \+ (DeltaL = 0, DeltaC = 0)  % Exclui a posição central
        ),
        Vizinhos),
    length(Vizinhos, N),
    length(Objetos, N), maplist(=(p), Objetos),
    insereVariosObjectos(Vizinhos, Tabuleiro, Objetos).

%------------------------------------------------------------------------------
%                           inserePontos/2
% inserePontos(Tabuleiro, Coords) insere pontos (p) em uma lista de coordenadas
% Coords no Tabuleiro.
%------------------------------------------------------------------------------
inserePontos(_, []) :- !.
inserePontos(Tabuleiro, [(L, C) | Coords]) :-
    insereObjecto((L, C), Tabuleiro, p),
    inserePontos(Tabuleiro, Coords).

%------------------------------------------------------------------------------
%                     objectosEmCoordenadas/3
% objectosEmCoordenadas(Coords, Tabuleiro, Objetos) obtém os objetos do
% Tabuleiro correspondentes a uma lista de coordenadas Coords.
%------------------------------------------------------------------------------
objectosEmCoordenadas([], _, []).
objectosEmCoordenadas([(L, C) | Coords], Tabuleiro, [Obj | Objs]) :-
    nth1(L, Tabuleiro, Linha),
    nth1(C, Linha, Obj),
    objectosEmCoordenadas(Coords, Tabuleiro, Objs).

%------------------------------------------------------------------------------
%                          coordObjectos/5
% coordObjectos(Objeto, Tabuleiro, ListaCoords, ListaCoordObjs, NumObjectos)
% obtém as coordenadas e a contagem de objetos de um tipo específico no
% Tabuleiro.
%------------------------------------------------------------------------------
coordObjectos(_, _, [], [], 0).
coordObjectos(Objeto, Tabuleiro, ListaCoords, ListaCoordObjs, NumObjectos) :-
    findall((L, C),
        (   member((L, C), ListaCoords),
            nth1(L, Tabuleiro, Linha),
            nth1(C, Linha, Obj),
            (   (nonvar(Objeto), Obj == Objeto)
            ;   (var(Objeto), var(Obj))
            )
        ),
        ListaCoordObjs),
    length(ListaCoordObjs, NumObjectos).

%------------------------------------------------------------------------------
%                      coordenadasVars/2
% coordenadasVars(Tabuleiro, ListaVars) obtém as coordenadas de todas as
% variáveis no Tabuleiro.
%------------------------------------------------------------------------------
coordenadasVars(Tabuleiro, ListaVars) :-
    findall((L, C),
        (   nth1(L, Tabuleiro, Linha),
            nth1(C, Linha, Celula),
            var(Celula)
        ),
        ListaVars).

%------------------------------------------------------------------------------
%                     fechaListaCoordenadas/2
% fechaListaCoordenadas(Tabuleiro, ListaCoord) aplica regras para fechar uma
% lista específica de coordenadas no Tabuleiro.
%------------------------------------------------------------------------------
fechaListaCoordenadas(Tabuleiro, ListaCoord) :-
    coordObjectos(e, Tabuleiro, ListaCoord, _, NumEstrelas),
    coordenadasVars(Tabuleiro, ListaVars),
    intersection(ListaCoord, ListaVars, CoordLivres),
    length(CoordLivres, NumLivres),
    (   NumEstrelas =:= 2 ->
            inserePontos(Tabuleiro, CoordLivres) % h1: 2 estrelas já preenchidas
    ;   NumEstrelas =:= 1, NumLivres =:= 1 ->
            [CoordLivre] = CoordLivres,
            insereObjecto(CoordLivre, Tabuleiro, e),
            inserePontosVolta(Tabuleiro, CoordLivre) % h2: 1 estrela e 1 posição livre
    ;   NumEstrelas =:= 0, NumLivres =:= 2 ->
            [Coord1, Coord2] = CoordLivres,
            insereObjecto(Coord1, Tabuleiro, e),
            inserePontosVolta(Tabuleiro, Coord1),
            insereObjecto(Coord2, Tabuleiro, e),
            inserePontosVolta(Tabuleiro, Coord2) % h3: 0 estrelas e 2 posições livres
    ;   true).

%------------------------------------------------------------------------------
%                              fecha/2
% fecha(Tabuleiro, ListaListaCoords) aplica fechaListaCoordenadas/2 em cada
% lista de coordenadas da ListaListaCoords no Tabuleiro.
%------------------------------------------------------------------------------
fecha(_, []) :- !.
fecha(Tabuleiro, [ListaCoord | Resto]) :- !,
    fechaListaCoordenadas(Tabuleiro, ListaCoord),
    fecha(Tabuleiro, Resto).

%------------------------------------------------------------------------------
%                    encontraSequencia/4
% encontraSequencia(Tabuleiro, N, ListaCoords, Seq) verifica se Seq é uma
% sublista de tamanho N que segue as regras especificadas, como coordenadas
% contíguas e variáveis livres.
%------------------------------------------------------------------------------
encontraSequencia(Tabuleiro, N, ListaCoords, Seq) :-
    coordObjectos(e, Tabuleiro, ListaCoords, _, NumEstrelas),
    NumEstrelas =:= 0, % Verifica que não há estrelas em ListaCoords

    % Obtém as variáveis em ListaCoords que são válidas no Tabuleiro
    findall(CoordVar, 
        (   member(CoordVar, ListaCoords),
            objectosEmCoordenadas([CoordVar], Tabuleiro, [Obj]),
            var(Obj)
        ), 
        Variaveis),

    % Verifica se o número total de variáveis não excede N
    length(Variaveis, TotalVars),
    TotalVars =:= N,
    sublista(ListaCoords, Seq), % Verifica se Seq é uma sublista válida
    length(Seq, N),
    subset(Seq, Variaveis), % Seq deve ser um subconjunto de Variáveis
    variaveisContiguas(ListaCoords, Seq),
    !.

%------------------------------------------------------------------------------
%                      sublista/2
% sublist(List, Sub) gera sublistas contínuas de qualquer tamanho da lista
% List.
%------------------------------------------------------------------------------
sublista(Lista, Sub) :-
    append(_, Cauda, Lista),
    append(Sub, _, Cauda).

%------------------------------------------------------------------------------
%                 variaveisContiguas/2
% variaveisContiguas(ListaCoords, Seq) verifica se Seq é uma sublista
% contígua dentro de ListaCoords.
%------------------------------------------------------------------------------
variaveisContiguas(ListaCoords, Seq) :-
    append(_, SeqCauda, ListaCoords),
    append(Seq, _, SeqCauda).

%------------------------------------------------------------------------------
%                          aplicaPadraoI/2
% aplicaPadraoI(Tabuleiro, Seq) aplica o padrão "I" em uma sequência Seq de
% coordenadas do Tabuleiro.
%------------------------------------------------------------------------------
aplicaPadraoI(Tabuleiro, [(L1, C1), (L2, C2), (L3, C3)]) :-
    L2 is L1 + 1, L3 is L2 + 1, C1 =:= C2, C2 =:= C3, !,
    insereObjecto((L1, C1), Tabuleiro, e),
    insereObjecto((L3, C3), Tabuleiro, e),
    inserePontosVolta(Tabuleiro, (L1, C1)),
    inserePontosVolta(Tabuleiro, (L3, C3)).

aplicaPadraoI(Tabuleiro, [(L1, C1), (L2, C2), (L3, C3)]) :-
    C2 is C1 + 1, C3 is C2 + 1, L1 =:= L2, L2 =:= L3, !,
    insereObjecto((L1, C1), Tabuleiro, e),
    insereObjecto((L3, C3), Tabuleiro, e),
    inserePontosVolta(Tabuleiro, (L1, C1)),
    inserePontosVolta(Tabuleiro, (L3, C3)).

%------------------------------------------------------------------------------
%                          aplicaPadroes/2
% aplicaPadroes(Tabuleiro, ListaListaCoords) aplica os padrões "I" e "T" em
% sequências dentro de cada lista de coordenadas da ListaListaCoords.
%------------------------------------------------------------------------------
aplicaPadroes(Tabuleiro, ListaListaCoords) :-
    aplicaPadroes_Auxiliar(Tabuleiro, ListaListaCoords),
    !.

aplicaPadroes_Auxiliar(_, []) :- !. % Caso base: termina quando não há mais coordenadas a processar.
aplicaPadroes_Auxiliar(Tabuleiro, [ListaCoords | Resto]) :-
    (
        (encontraSequencia(Tabuleiro, 3, ListaCoords, Seq), % Verifica padrão I
         aplicaPadraoI(Tabuleiro, Seq))                    % Aplica padrão I
        ;
        (encontraSequencia(Tabuleiro, 4, ListaCoords, Seq), % Verifica padrão T
         aplicaPadraoT(Tabuleiro, Seq))                    % Aplica padrão T
    ),
    aplicaPadroes_Auxiliar(Tabuleiro, Resto), !. % Continua com o restante das coordenadas.
aplicaPadroes_Auxiliar(Tabuleiro, [_ | Resto]) :-
    aplicaPadroes_Auxiliar(Tabuleiro, Resto). % Continua se nenhum padrão foi aplicado.o

%------------------------------------------------------------------------------
%                          resolve/2
% resolve(Estruturas, Tabuleiro) resolve o puzzle aplicando aplicaPadroes/2 e
% fecha/2 iterativamente até estabilizar o Tabuleiro.
%------------------------------------------------------------------------------
resolve(Estruturas, Tabuleiro) :-
    coordTodas(Estruturas, ListaListaCoords),
    resolveAuxiliar(Tabuleiro, ListaListaCoords).

resolveAuxiliar(Tabuleiro, ListaListaCoords) :-
    % Salva o estado atual do tabuleiro.
    limpaTabuleiro(Tabuleiro, TabuleiroLimpoAntes),
    % Aplica os padrões e as regras de fechamento.
    aplicaPadroes(Tabuleiro, ListaListaCoords),
    fecha(Tabuleiro, ListaListaCoords),
    % Salva o estado do tabuleiro após as alterações.
    limpaTabuleiro(Tabuleiro, TabuleiroLimpoDepois),
    % Compara o estado antes e depois. Se forem diferentes, continua a iterar.
    (   TabuleiroLimpoAntes \= TabuleiroLimpoDepois
    ->  resolveAuxiliar(Tabuleiro, ListaListaCoords)
    ;   true % Se forem iguais, o tabuleiro estabilizou.
    ).
