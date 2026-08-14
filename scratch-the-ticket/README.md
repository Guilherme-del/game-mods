# Scratch the Ticket — Mod Manager Suite

Mod Manager interativo e modular desenvolvido para o jogo **Scratch the Ticket** (*LotteryTicket*), desenvolvido em **Unreal Engine 5.7**.

---

## 📌 Funcionalidades

O Mod Manager oferece ferramentas modulares com manipulação binária direta dos arquivos de save GVAS da Unreal Engine 5:

1. **💰 Dinheiro & Saldo (Money Mod)**
   - Consulta o saldo atual em tempo real.
   - **➕ Somar Milhões (+Mi)**: +1 Mi, +5 Mi, +10 Mi, +50 Mi, +100 Mi, +500 Mi.
   - **💎 Somar Bilhões (+Bi)**: +1 Bi, +5 Bi, +10 Bi, +50 Bi, +100 Bi, +500 Bi.
   - **🚀 Somar Trilhões (+Tri)**: +1 Tri, +10 Tri, +50 Tri, +100 Tri.
   - **⚡ Multiplicadores / Personalizado**: Somar quantia personalizada digitada (+X), Dobrar saldo (x2) ou Multiplicar por 10 (x10).
   - **🎯 Definir / Outros**: Submenu para definir valores fixos, Saldo Máximo ($999 Trilhões) e Zerar Saldo ($0).

2. **🧪 Frasco & Spray Raspador (Bottle Mod)**
   - Desbloqueio instantâneo do frasco raspador (`HasBottle`).
   - Abastecimento com volume personalizado ou super carga (10.000 / 999.999).
   - Recarga em 1 clique.

3. **🔦 Ferramentas Especiais (Tool Unlocker Mod)**
   - Lanterna (`HasFlashlight`)
   - Microscópio (`HasMicroscope`)
   - Moeda de Éter (`HasEtherCoin`)
   - Frasco de Spray (`HasBottle`)
   - Botão para desbloquear todas as ferramentas de uma só vez.

4. **🏛️ Construções & Automação (Building Mod)**
   - Inspeção e modificação das quantidades de todas as 9 construções de renda passiva:
     - Agência de Espionagem
     - Padaria
     - Central Hacker
     - Prefeitura
     - Usina Solar
     - Satélite Sputnik
     - Nave Espacial
     - Planetas
     - Apartamento
   - Opção para criar Império Máximo (500 de cada).

5. **🎫 Níveis & Multiplicadores de Bilhetes (Ticket Mod)**
   - Inspeção de todos os modelos de bilhetes e raspadinhas.
   - Ajuste individual de nível/multiplicador ou aceleração global (Nível 50 ou Nível 500 Máximo).

6. **🔓 Desbloquear Tudo (Full Unlocker Mod)**
   - Desbloqueio de todas as cartelas e raspadinhas bloqueadas.
   - Modo "Full Game" que libera todas as ferramentas, bilhetes e saldo com 1 clique.

7. **🛡️ Gerenciador de Backups & Restauração (SaveBackupMod)**
   - Criação automática de backup com carimbo de data/hora antes de qualquer edição.
   - Snapshots manuais e restauração simplificada de versões anteriores.

---

## 🚀 Como Executar

### Opção 1: Executável Rápido (Recomendado)
Dê um duplo clique no arquivo:
```
Run_Mod.bat
```

### Opção 2: Pelo PowerShell
Abra o PowerShell na pasta do mod e execute:
```powershell
powershell -ExecutionPolicy Bypass -File .\main.ps1
```

---

## 🧩 Estrutura do Projeto

```
scratch-the-ticket/
├── README.md
├── Run_Mod.bat
├── main.ps1
└── src/
    ├── Core/
    │   ├── GvasHandler.psm1        # Motor de leitura/gravação binária GVAS UE5
    │   └── BackupManager.psm1      # Gestão de backups e restaurações
    └── Modules/
        ├── MoneyMod/               # Modificador de saldo de dinheiro
        ├── BottleMod/              # Modificador de frasco e spray
        ├── ToolUnlockerMod/        # Desbloqueador de ferramentas especiais
        ├── BuildingMod/            # Modificador de construções passivas
        ├── TicketMod/              # Modificador de níveis de bilhetes
        ├── UnlockAllMod/           # Desbloqueador geral do jogo
        └── SaveBackupMod/          # Menu de backups e snapshots
```

---

## ⚠️ Dica de Uso com o Jogo Aberto

- Se o jogo estiver aberto durante a edição, salve suas alterações no Mod Manager e volte ao menu principal do jogo (ou reinicie o jogo) para que o novo save seja carregado pela Unreal Engine.
- Todos os backups são salvos em `%LOCALAPPDATA%\LotteryTicket\Saved\SaveGames\ModBackups\`.
