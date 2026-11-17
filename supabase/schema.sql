create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nome text not null,
  role text not null default 'adotante' check (role in ('adotante', 'ong', 'coletor')),
  criado_em timestamptz not null default now()
);

-- Perfil de rotina do adotante (alimenta o match)
create table public.perfis_tutor (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  quer_adotar text not null default 'tanto_faz' check (quer_adotar in ('cao', 'gato', 'tanto_faz')),
  moradia text not null check (moradia in ('casa_com_quintal', 'casa_sem_quintal', 'apartamento')),
  horas_fora text not null check (horas_fora in ('ate_4h', '4_a_8h', 'mais_8h')),
  atividade text not null check (atividade in ('pouco', 'moderado', 'bastante')),
  tem_criancas boolean not null default false,
  outros_animais text not null default 'nenhum' check (outros_animais in ('nenhum', 'cao', 'gato', 'ambos')),
  experiencia text not null check (experiencia in ('nunca_teve', 'ja_teve', 'tem_hoje')),
  tem_rede_protecao boolean not null default false,
  atualizado_em timestamptz not null default now()
);

-- ========== Pets ==========
create table public.pets (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  especie text not null check (especie in ('cao', 'gato')),
  sexo text check (sexo in ('femea', 'macho')),
  idade_meses int,
  porte text check (porte in ('pequeno', 'medio', 'grande')),
  energia text not null check (energia in ('baixa', 'moderada', 'alta')),
  temperamento text,
  historia text,
  status text not null default 'disponivel' check (status in ('disponivel', 'em_processo', 'adotado')),
  -- Pré-requisitos: viram filtros eliminatórios no match
  nao_convive_outros_pets boolean not null default false,
  exige_rede_protecao boolean not null default false,
  exige_quintal boolean not null default false,
  exige_experiencia boolean not null default false,
  criado_em timestamptz not null default now()
);

create table public.pet_midias (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets(id) on delete cascade,
  tipo text not null default 'foto' check (tipo in ('foto', 'video')),
  url text not null,
  ordem int not null default 0
);

-- Pedidos "Quero Conhecer"
create table public.interesses (
  id uuid primary key default gen_random_uuid(),
  pet_id uuid not null references public.pets(id) on delete cascade,
  tutor_id uuid not null references public.profiles(id) on delete cascade,
  compatibilidade int check (compatibilidade between 0 and 100),
  status text not null default 'novo' check (status in ('novo', 'em_triagem', 'visita_marcada', 'adotado', 'recusado')),
  criado_em timestamptz not null default now(),
  unique (pet_id, tutor_id)
);

-- ========== Coleta de tampinhas ==========
create table public.rotas (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  dia_semana int not null check (dia_semana between 0 and 6), -- 0 = domingo
  coletor_id uuid references public.profiles(id)
);

create table public.pontos_coleta (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  endereco text not null,
  lat double precision,
  lng double precision,
  dia_semana int not null check (dia_semana between 0 and 6),
  horario time,
  situacao text not null default 'vazio' check (situacao in ('vazio', 'quase_cheio', 'caixa_cheia')),
  rota_id uuid references public.rotas(id),
  ativo boolean not null default true
);

create table public.coletas (
  id uuid primary key default gen_random_uuid(),
  ponto_id uuid not null references public.pontos_coleta(id),
  coletor_id uuid not null references public.profiles(id),
  data date not null default current_date,
  peso_kg numeric(7,2) not null check (peso_kg >= 0)
);

-- Doadores que querem receber aviso por e-mail (não precisam de conta)
create table public.inscricoes_aviso (
  id uuid primary key default gen_random_uuid(),
  ponto_id uuid not null references public.pontos_coleta(id) on delete cascade,
  email text not null,
  quando text not null default 'no_dia' check (quando in ('no_dia', '1_dia_antes')),
  token_cancelamento uuid not null default gen_random_uuid(), -- usado no link "cancelar" do e-mail
  consentimento_em timestamptz not null default now(),       -- LGPD
  unique (ponto_id, email)
);

-- ========== Segurança (Row Level Security) ==========
create or replace function public.papel() returns text
language sql stable security definer set search_path = public as $$
  select role from public.profiles where id = auth.uid()
$$;

alter table public.profiles enable row level security;
alter table public.perfis_tutor enable row level security;
alter table public.pets enable row level security;
alter table public.pet_midias enable row level security;
alter table public.interesses enable row level security;
alter table public.rotas enable row level security;
alter table public.pontos_coleta enable row level security;
alter table public.coletas enable row level security;
alter table public.inscricoes_aviso enable row level security;

-- Perfis e dados do tutor: o dono e a ONG
create policy "perfil: dono ou ong" on public.profiles for select using (id = auth.uid() or public.papel() = 'ong');
create policy "perfil: dono edita" on public.profiles for update using (id = auth.uid());
create policy "tutor: dono ou ong le" on public.perfis_tutor for select using (user_id = auth.uid() or public.papel() = 'ong');
create policy "tutor: dono escreve" on public.perfis_tutor for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Pets e mídias: qualquer pessoa vê; só a ONG altera
create policy "pets: leitura publica" on public.pets for select using (true);
create policy "pets: ong altera" on public.pets for all using (public.papel() = 'ong') with check (public.papel() = 'ong');
create policy "midias: leitura publica" on public.pet_midias for select using (true);
create policy "midias: ong altera" on public.pet_midias for all using (public.papel() = 'ong') with check (public.papel() = 'ong');

-- Interesses: o tutor cria e vê os seus; a ONG vê e atualiza todos
create policy "interesses: tutor cria" on public.interesses for insert with check (tutor_id = auth.uid());
create policy "interesses: tutor ou ong le" on public.interesses for select using (tutor_id = auth.uid() or public.papel() = 'ong');
create policy "interesses: ong atualiza" on public.interesses for update using (public.papel() = 'ong');

-- Pontos e rotas: leitura pública; ONG gerencia; coletor atualiza a situação
create policy "pontos: leitura publica" on public.pontos_coleta for select using (ativo);
create policy "pontos: ong altera" on public.pontos_coleta for all using (public.papel() = 'ong') with check (public.papel() = 'ong');
create policy "pontos: coletor atualiza" on public.pontos_coleta for update using (public.papel() in ('ong', 'coletor'));
create policy "rotas: leitura publica" on public.rotas for select using (true);
create policy "rotas: ong altera" on public.rotas for all using (public.papel() = 'ong') with check (public.papel() = 'ong');

-- Coletas: coletor registra; ONG e o próprio coletor leem
create policy "coletas: coletor registra" on public.coletas for insert with check (coletor_id = auth.uid() and public.papel() in ('ong', 'coletor'));
create policy "coletas: leitura" on public.coletas for select using (coletor_id = auth.uid() or public.papel() = 'ong');

-- Inscrições: qualquer pessoa se inscreve; só a ONG lê (e-mails são dados pessoais).
-- O cancelamento pelo link do e-mail deve passar por uma rota do servidor (service role), usando o token.
create policy "avisos: qualquer um se inscreve" on public.inscricoes_aviso for insert with check (true);
create policy "avisos: ong le" on public.inscricoes_aviso for select using (public.papel() = 'ong');
create policy "avisos: ong remove" on public.inscricoes_aviso for delete using (public.papel() = 'ong');
