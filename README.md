# Lista de Compras IFB — Aplicativo Móvel com SQLite e Arquitetura em Camadas

> **Instituto Federal de Educação, Ciência e Tecnologia de Brasília (IFB) — Campus Brasília**  
> **Curso Superior de Tecnologia em Sistemas para Internet**  
> **Disciplina:** Desenvolvimento para Dispositivos Móveis 2026/2 (DPDMV 2026/2)  
> **Docente:** Prof. Me. Cláudio Ulhoa  
> **Discente:** Felipe Madison da Silva Veloso (Matrícula: 69815)  
> **Avaliação 1 — Tutorial Integrador (Aula 15)**

---

## 1. Visão Geral

Este projeto consiste na implementação integral e evoluída do aplicativo de lista de compras proposto na **Aula 15** da disciplina de Desenvolvimento para Dispositivos Móveis. A solução substitui abordagens simplistas de arquivo único e armazenamento desestruturado (como `shared_preferences`) por uma **arquitetura em camadas desacoplada**, fundamentada no princípio da inversão de dependência (DIP), persistência transacional em banco de dados relacional **SQLite**, gerenciamento de estado reativo com **Riverpod**, roteamento declarativo com **GoRouter** e comunicação nativa de baixo nível via **Platform Channels (Kotlin)**.

O aplicativo opera sob a premissa de *offline-first*: todos os cadastros, mutações e exclusões ocorrem localmente no dispositivo de forma atômica e imediata, enquanto um subsistema assíncrono gerencia a sincronização remota resiliente com algoritmo de recuo exponencial (*exponential backoff*) com ruído aleatório (*jitter*).

---

## 2. Arquitetura do Software

A estrutura arquitetural do sistema foi desenhada para isolar estritamente as responsabilidades do sistema, garantindo testabilidade independente, manutenibilidade e proteção das regras de negócio contra detalhes de infraestrutura ou bibliotecas visuais.

### 2.1 Diagrama de Dependências e Fluxo de Dados

```text
┌─────────────────────────────────────────────────────────────┐
│                   CAMADA DE APRESENTAÇÃO                    │
│  Telas (Lista, Formulário, Sobre, Não Encontrada)           │
│  Componentes Reutilizáveis (CartaoItem, FaixaOffline)        │
│  Roteamento Declarativo & Deep Linking (GoRouter)           │
│  Composition Root & Gerenciamento de Estado (Riverpod)      │
└──────────────────────────────┬──────────────────────────────┘
                               │ depende de (usa)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      CAMADA DE DOMÍNIO                      │
│  Entidade Imutável: Item                                    │
│  Regras Puras: validação de campos, ordenação, métricas     │
│  Contrato Abstrato de Persistência: ItemRepository          │
└──────────────────────────────▲──────────────────────────────┘
                               │ implementa (inversão DIP)
                               │
┌──────────────────────────────┴──────────────────────────────┐
│                       CAMADA DE DADOS                       │
│  Persistência Relacional: BancoDeDados (SQLite), Mapper      │
│  Repositório Concreto: ItemRepositorySqlite                 │
│  Resiliência de Rede: Nova Tentativa (Jitter), Sincronizador│
│  Canal de Plataforma Nativo: DispositivoNativo (Kotlin)      │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Detalhamento das Camadas

#### A. Camada de Domínio (`lib/dominio/`)
* **Isolamento Absoluto:** Não importa nenhuma classe do Flutter (`widgets`, `material`), SQLite ou protocolos de rede. É código Dart puro.
* **Entidade Imutável (`Item`):** Todos os campos são marcados como `final`. Mutações de estado geram novas instâncias via método `copyWith()`, viabilizando comparações estruturais rápidas por igualdade e prevenindo efeitos colaterais entre telas concorrentes.
* **Regras Determinísticas (`regras_item.dart`):**
  * `validarNome()`: Regra de consistência que valida tamanho útil entre 2 e 40 caracteres, reaproveitada diretamente no `validator` do formulário.
  * `ajustarQuantidade()`: Restrição estrita de cardinalidade utilizando método `.clamp(1, 99)`.
  * `ordenarParaExibicao()`: Priorização de itens pendentes de aquisição seguida por ordenação alfabética composta (categoria e nome).
  * `resumir()`: Cálculo determinístico de totalizadores de progresso e pendências de rede.
* **Inversão de Dependência (`ItemRepository`):** O domínio declara a interface pura do que necessita (`listar`, `salvar`, `excluir`, `marcarComoSincronizado`). Os mecanismos de banco de dados tornam-se meros adaptadores substituíveis.

#### B. Camada de Dados (`lib/dados/`)
* **Persistência SQLite (`dados/local/`):**
  * Esquema relacional estruturado com chave primária auto-incremental, campos `NOT NULL` e restrição nativa em nível de tabela `CHECK (quantidade BETWEEN 1 AND 99)` (defesa em profundidade).
  * Criação do índice relacional `idx_itens_sincronizado` para otimizar a varredura periódica de pendências de transmissão.
  * Tabela de metadados (`metadados`) com registro permanente de data/hora de inicialização do banco.
  * Injeção de dependência da `DatabaseFactory` no construtor de `BancoDeDados`, viabilizando o uso de `databaseFactoryFfi` em memória durante testes locais sem emulador.
* **Concorrência Otimista:**
  * O método `marcarComoSincronizado(Item item)` aplica atualização condicional com `WHERE id = ? AND atualizado_em = ?`. Caso o usuário altere o item durante a transmissão do pacote na rede, o carimbo local difere do pacote confirmado e a marcação é rejeitada, forçando novo envio na sincronização subsequente e evitando sobrescrita de dados recentes.
* **Resiliência a Conectividade Intermitente (`dados/remoto/`):**
  * O utilitário `comNovaTentativa()` emprega *exponential backoff* combinado com *full jitter*. A cada retentativa por `FalhaTransitoria`, o tempo de espera escala em potências de base 2 com acréscimo aleatório, prevenindo colisões sistemáticas de requisições.
* **Canal Nativo de Plataforma (`dados/plataforma/` e `MainActivity.kt`):**
  * Utilização do `MethodChannel('compras/dispositivo')` para comunicar Dart assíncrono com a camada nativa Android em Kotlin.
  * Leitura direta de `Build.MANUFACTURER`, `Build.MODEL`, `Build.VERSION.RELEASE` e telemetria de nível de bateria via `BatteryManager`.

#### C. Camada de Apresentação (`lib/apresentacao/`)
* **Composition Root com Riverpod (`providers.dart`):**
  * Centralização de todas as amarrações de dependências concretas (`bancoDeDadosProvider`, `itemRepositoryProvider`, etc.).
  * Gerenciamento de ciclo de vida com descarte automático de recursos via `ref.onDispose()`.
  * Consumo reativo via `AsyncNotifier` e `AsyncValue`, garantindo tratamento exaustivo e elegante dos estados de carregamento (`loading`), falha (`error`) e sucesso (`data`).
  * Remoção otimista de itens em `excluir()` para conformidade estrita com o ciclo de vida do widget `Dismissible`.
* **Navegação Declarativa e Deep Linking (`rotas.dart`):**
  * Definição hierárquica pelo `GoRouter`: a rota `/item/:id` mantém a rota raiz `/` na pilha, assegurando que ligações profundas abertas via terminal ou links externos retrocedam normalmente à lista principal.
  * Registro do esquema URI `compras://app/item/:id` no `AndroidManifest.xml`.
* **Acessibilidade e Responsividade:**
  * Adaptação a telas pequenas, tablets e desktops através de `LayoutBuilder` com pontos de quebra em 600 dp (2 colunas) e 840 dp (3 colunas).
  * Dimensionamento vertical de cartões com `MediaQuery.textScalerOf(context)` para impedir corte de conteúdo com fontes ampliadas no SO.
  * Acessibilidade auditiva com `Semantics(liveRegion: true)` na faixa offline e rótulos semânticos (`semanticLabel`) nos ícones de estado de rede.
  * Interceptação de saída acidental em formulários com alterações pendentes via widget `PopScope`.

---

## 3. Demonstração Visual da Aplicação

> *Inserir aqui as capturas de tela do aplicativo em execução no dispositivo ou emulador.*

| Tela Principal (Listagem) | Cadastro / Edição | Diálogo de Descarte |
|:---:|:---:|:---:|
| *(Print 1: Lista com itens e barra de progresso)* | *(Print 2: Formulário com validação e stepper)* | *(Print 3: PopScope confirmando saída)* |

| Modo Offline Detectado | Tela "Sobre" (Dados Nativos & SQLite) | Responsividade em Tela Larga |
|:---:|:---:|:---:|
| *(Print 4: Faixa offline visível)* | *(Print 5: Informações de hardware e bateria)* | *(Print 6: Grade com 2 ou 3 colunas)* |

---

## 4. Testes Automatizados e Qualidade

O projeto dispõe de cobertura de testes automatizados em três níveis, testáveis sem necessidade de emulador ativo:

```powershell
# Execução da suíte completa de testes
flutter test
```

1. **Testes Unitários de Domínio (`test/dominio/regras_item_test.dart`):**
   * Validação de restrições de nome (vazio, tamanho insuficiente, excessivo, espaçamento).
   * Verificação de limites inferior e superior de quantidade.
   * Regra de ordenação composta (pendentes primeiro, por categoria e alfabética).
   * Consolidação estatística de progresso e contagem de itens.
2. **Testes Unitários de Resiliência (`test/dados/nova_tentativa_test.dart`):**
   * Retentativa automática diante de falhas temporárias até o sucesso.
   * Interrupção e propagação correta ao exceder o teto máximo de tentativas.
3. **Testes de Integração com SQLite Real (`test/dados/item_repository_sqlite_test.dart`):**
   * Executa comandos SQL reais sobre SQLite em memória (`sqflite_common_ffi`).
   * Valida inserção, leitura atômica, exclusão e isolamento de versão concorrente.
4. **Testes de Interface / Widget Test (`test/apresentacao/fluxo_da_lista_test.dart`):**
   * Substituição seletiva (*overrides*) de provedores por repositório em memória e mock de rede.
   * Simulação ponta a ponta de abertura da lista, validação com erro e cadastro com sucesso.

---

## 5. Instruções de Compilação e Geração do APK

### 5.1 Requisitos de Ambiente
* Flutter SDK (versão estável $\ge$ 3.3.0)
* Android SDK com Platform-Tools (`adb`) configurado no PATH
* Java JDK 17

### 5.2 Compilação do APK de Distribuição

Para gerar o APK universal:
```powershell
flutter build apk --release
```
O artefato compilado é produzido em:
`build/app/outputs/flutter-apk/app-release.apk`

Para gerar APKs específicos e otimizados por arquitetura de processador (arquivos menores):
```powershell
flutter build apk --split-per-abi
```

### 5.3 Instalação via ADB
Com o dispositivo físico ou emulador conectado com depuração USB autorizada:
```powershell
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### 5.4 Teste de Ligação Profunda (Deep Link)
Para verificar a abertura direta de um item via terminal:
```powershell
adb shell am start -W -a android.intent.action.VIEW -d "compras://app/item/1" br.edu.ifb.felipemadison.compras
```

---

## 6. Download do Aplicativo (APK)

O pacote instalável compilado para Android está disponível na seção de lançamentos oficiais do repositório:

* **[Download direto do APK (Releases)](https://github.com/FelipeMadson/compras-ifb/releases/latest)**
* **Identificador do Aplicativo (Application ID):** `br.edu.ifb.felipemadison.compras`
* **Versão:** 1.0.0 (Build 1)
