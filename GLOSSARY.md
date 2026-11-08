# Lista de Compras IFB

Contexto de negócio e engenharia móvel para o aplicativo de compras e persistência local da disciplina DPDMV 2026/2 no IFB Campus Brasília.

## Linguagem Ubíqua

**Item**:
Entidade de domínio canônica e imutável que representa um produto planejado ou adquirido na lista de compras.
_Avoid_: Produto, mercadoria, registro, tarefa

**Lista Canônica**:
Coleção de itens ordenada determinística e prioritariamente por itens pendentes (alfabético por nome) seguidos por itens já comprados (alfabético por nome).
_Avoid_: Listagem solta, catálogo, array não ordenado

**Sincronização**:
Processo de reconciliação bidirecional e idempotente entre a persistência relacional SQLite local e o serviço remoto simulado.
_Avoid_: Upload, replicação, push síncrono

**Bloqueio Otimista**:
Estratégia de controle de concorrência relacional ancorada no carimbo temporal `atualizado_em`, impedindo substituições cegas sem travar o motor SQLite.
_Avoid_: Lock pessimista, semáforo, mutex

**Full Jitter**:
Algoritmo probabilístico de dispersão no cálculo de backoff exponencial que seleciona uniformemente uma pausa entre zero e o teto exponencial atual, prevenindo colisão em massa ("thundering herd").
_Avoid_: Sleep fixo, retry imediato, backoff sem ruído

**Canal de Plataforma (Platform Channel)**:
Mecanismo de comunicação assíncrona bidirecional entre a camada Dart do Flutter e o subsistema nativo do Android implementado em Kotlin (`MethodChannel`).
_Avoid_: FFI direta, hook de sistema, ponte genérica
