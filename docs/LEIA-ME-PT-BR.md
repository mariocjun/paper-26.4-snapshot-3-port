# Reproduzir o Paper para 26.4 Snapshot 3

Este repositório contém o port experimental que usamos para compilar e testar o servidor na **26.4 Snapshot 3**. É um experimento independente; não é uma versão oficial do PaperMC. Os arquivos de origem são obtidos do Paper no commit fixado em `provenance.json`.

## Preparar e compilar

Instale **JDK 25**, Git e Python 3. Use Linux ou WSL. No Windows, abra o terminal do WSL; os comandos abaixo são Bash. Para compilar com melhor desempenho no WSL, clone dentro da pasta pessoal do Linux.

```bash
git clone https://github.com/mariocjun/paper-26.4-snapshot-3-port.git
cd paper-26.4-snapshot-3-port
java -version
bash scripts/apply-port.sh
bash scripts/build.sh
```

Se `java -version` não mostrar Java 25, selecione sua instalação antes de compilar:

```bash
export JAVA_HOME=/caminho/para/jdk-25
export PATH="$JAVA_HOME/bin:$PATH"
```

O primeiro script verifica o hash do patch, baixa o commit exato do Paper e aplica o port em uma nova pasta `build/Paper`. O segundo aplica os patches internos do Paper, executa os testes e gera:

```text
build/Paper/paper-server/build/libs/paper-bundler-26.4-snapshot-3.local-SNAPSHOT.jar
```

Você precisará de conexão à internet, vários GB livres e memória suficiente para a compilação. Uma pasta de destino existente não é sobrescrita; escolha outro caminho se quiser refazer o procedimento do zero.

## Jogar no servidor de teste

Leia e aceite a [EULA do Minecraft](https://www.minecraft.net/eula) antes de criar `eula.txt`. Estes comandos criam um mundo novo e permitem acesso local:

```bash
mkdir -p runtime/manual
cd runtime/manual
printf 'eula=true\n' > eula.txt
printf 'server-ip=127.0.0.1\nserver-port=25565\n' > server.properties
java -Xms512M -Xmx2G -jar ../../build/Paper/paper-server/build/libs/paper-bundler-26.4-snapshot-3.local-SNAPSHOT.jar --nogui
```

Entre com o cliente Java **26.4 Snapshot 3**, endereço `localhost:25565`. Para desligar salvando o mundo, digite `stop` no console do servidor.

## O que foi verificado

Os testes originais registraram 10.494 casos aprovados, 91 ignorados e nenhuma falha/erro. Também verificamos a aplicação dos patches em uma cópia limpa, inicialização, reinício, persistência de dados, precisão dos biomas e callbacks de geração. O procedimento para repetir a sonda de dois reinícios está em [VALIDATION.md](VALIDATION.md).

Antes da publicação, repetimos o procedimento em uma nova cópia do Paper obtida do GitHub: **10.497 testes aprovados, 88 ignorados e nenhuma falha/erro**, fontes geradas idênticas e sonda aprovada nas duas inicializações. Três testes de perfil dependentes dos serviços da Mojang puderam rodar nessa execução; na validação original eles tinham sido ignorados. O recibo está em [publication-replay.json](../validation/publication-replay.json).

Esses resultados não garantem compatibilidade com todos os plugins ou migração de qualquer mundo antigo. A revisão de plugins encontrou incompatibilidade de versão no Geyser e aviso de versão não suportada no Essentials. Regras customizadas de material contendo apenas condições ainda usam stone como fallback no caminho de geração Bukkit por etapas. Guarde backups intactos e faça ensaios em cópias.

O desenvolvimento contou com assistência significativa do OpenAI Codex, revisão do código, compilação, testes automatizados, sondas em execução e uma sessão humana de jogo. As referências e licenças dos projetos de origem estão preservadas no repositório.
