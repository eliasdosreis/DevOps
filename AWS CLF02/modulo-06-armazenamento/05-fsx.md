# Amazon FSx — sistemas de arquivos gerenciados (Windows, Lustre)

## 1. Analogia do Dia a Dia
FSx é como escolher entre diferentes tipos de armários para guardar arquivos: um para Windows, outro para alta performance, outro para integração com sistemas específicos.

## 2. O que é (definição técnica oficial AWS)
Amazon FSx oferece sistemas de arquivos gerenciados e otimizados para diferentes workloads: FSx for Windows File Server, FSx for Lustre, FSx for NetApp ONTAP e FSx for OpenZFS.

## 3. Ficha de Estudo Comentada
============================================================
SERVIÇO: Amazon FSx
DOMÍNIO DO EXAME: Armazenamento (33%)
============================================================

O QUE É:
- Sistemas de arquivos gerenciados e otimizados
- Opções: Windows, Lustre, NetApp ONTAP, OpenZFS
- Integrado com outros serviços AWS

PALAVRAS-CHAVE NA PROVA:
→ "FSx for Windows = SMB"
→ "FSx for Lustre = alta performance"
→ "FSx gerenciado"

QUANDO USAR:
✅ Workloads que exigem compatibilidade específica
✅ Alta performance (Lustre)
✅ Ambientes Windows (SMB)

QUANDO NÃO USAR:
❌ Workloads simples (use EFS ou S3)
❌ Sem necessidade de sistema de arquivos avançado

DIFERENCIAIS:
- Suporte a múltiplos protocolos e integrações
============================================================

## 4. Questões de Fixação
1. O que é o Amazon FSx?
A) Armazenamento de objetos
B) Sistema de arquivos gerenciado (correta)
C) Disco de EC2
D) CDN

Explicação:
- B) Correta: FSx é sistema de arquivos gerenciado.
- A), C), D) não são FSx.

Armadilha: confundir FSx com EFS ou S3.

2. Quando usar FSx for Lustre?
A) Para alta performance e integração com HPC (correta)
B) Para workloads simples
C) Para backups
D) Para CDN

Explicação:
- A) Correta: Lustre é para alta performance.
- B), C), D) não são casos de uso de Lustre.

Armadilha: achar que FSx é só para Windows.

## 5. Conceito Senior
- FSx permite migração de workloads legados para a nuvem.
- Suporte a snapshots, replicação e alta disponibilidade.

## 6. Resumo para Revisão
- FSx = sistemas de arquivos gerenciados | Windows, Lustre, NetApp, OpenZFS | alta performance | integração AWS | escolha depende do workload