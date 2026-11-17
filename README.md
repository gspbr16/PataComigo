# PataComigo

Plataforma web gratuita que ajuda a **101 Vira-Latas** a encontrar o lar certo para cães e gatos e a organizar a coleta de tampinhas plásticas que sustenta a ONG.

> **Status:** em planejamento. Já existe um esboço visual das telas, e o desenvolvimento ainda não começou.
> Este é um projeto acadêmico criado para a ONG 101 Vira-Latas. Não é um projeto oficial da ONG.

## O problema

A 101 Vira-Latas vive de doações, principalmente de tampinhas de garrafa plástica, e doa cães e gatos. Dois pontos pesam no dia a dia:

- **Adoção por impulso.** A escolha pela foto nem sempre combina com a rotina e o espaço do tutor, e isso pode terminar em devolução.
- **Coleta de tampinhas desorganizada.** Há vários pontos de doação e pessoas que passam neles para recolher. Quem doa não sabe onde nem quando, e os pontos podem encher sem ninguém avisar.

## A solução

### 1. Adoção consciente por compatibilidade

O adotante responde um questionário sobre moradia, rotina, crianças, outros animais, atividade física e experiência. A vitrine mostra os pets **ordenados pela porcentagem de compatibilidade**, com o motivo do match.

Como o match é calculado:

1. **Filtros eliminatórios:** restrições absolutas do pet (por exemplo, não convive com outros animais ou exige rede de proteção). Quem não atende não vê aquele pet.
2. **Pontuação por pesos:**

| Critério | Peso |
|---|---|
| Espaço físico | 30% |
| Energia do pet e tempo do tutor (passeios ou brincadeiras) | 30% |
| Crianças e outros pets em casa | 20% |
| Experiência prévia do tutor | 20% |

Ao tocar em **"Quero Conhecer"**, o perfil do adotante chega organizado para a equipe de triagem da ONG.

### 2. Coleta de tampinhas

- Mapa e lista de **pontos de coleta**, com dia, horário e situação (vazio, quase cheio, caixa cheia)
- Doadores se inscrevem em um ponto e **recebem um aviso por e-mail** quando o coletor vai passar
- Os responsáveis pelos pontos podem sinalizar "caixa cheia", e o coletor prioriza esses pontos
- O coletor registra o peso retirado em cada ponto, o que gera o total arrecadado
- Avisos pelo WhatsApp ficam para uma versão futura

## Escopo do MVP

**Adotante:** cadastro e questionário de rotina, vitrine com % de match, página do pet, botão "Quero Conhecer", pontos de coleta e inscrição para avisos.

**Painel da ONG:** cadastro e edição de pets (fotos, temperamento, porte, pré-requisitos), pedidos de interesse com o perfil dos adotantes, pontos de coleta, rotas e quilos arrecadados.

## Stack planejada (custo zero)

| Camada | Tecnologia |
|---|---|
| Interface e API | Next.js (TypeScript) + Tailwind CSS |
| Banco, autenticação e fotos | Supabase (PostgreSQL, Auth, Storage) |
| Mapa | Leaflet + OpenStreetMap |
| E-mail | Resend |
| Hospedagem | Vercel (ou alternativa gratuita) |
| Design | Figma |

Os planos gratuitos têm limites (por exemplo, o Supabase pausa projetos com pouca atividade e o plano gratuito de e-mail tem teto diário). Eles são considerados no planejamento.

## Roadmap

- [ ] Modelo do banco de dados
- [ ] Login e painel de cadastro de pets
- [ ] Questionário do tutor e função de match
- [ ] Vitrine, página do pet e "Quero Conhecer"
- [ ] Painel de pedidos de interesse
- [ ] Pontos de coleta, rotas e avisos por e-mail
- [ ] Avisos pelo WhatsApp

## Protótipo

As telas do esboço (adotante, painel da ONG e coleta de tampinhas) serão adicionadas na pasta `docs/`.

## Licença

A definir.
