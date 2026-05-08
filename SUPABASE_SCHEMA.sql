create extension if not exists "pgcrypto";

drop view if exists vista_proyectos_resumen cascade;
drop table if exists proceso_notas cascade;
drop table if exists proceso_etapas cascade;
drop table if exists procesos_compras cascade;
drop table if exists pagos cascade;
drop table if exists cubicaciones cascade;
drop table if exists proyectos cascade;
drop table if exists contratistas cascade;
drop table if exists usuario_permisos cascade;
drop table if exists permisos cascade;
drop table if exists usuarios cascade;
drop table if exists areas cascade;

create table areas (
  id uuid primary key default gen_random_uuid(),
  nombre text not null unique,
  descripcion text,
  creado_en timestamp with time zone default now()
);

create table usuarios (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  usuario text not null unique,
  correo text,
  area_id uuid references areas(id),
  cargo text,
  perfil_base text,
  activo boolean default true,
  creado_en timestamp with time zone default now(),
  actualizado_en timestamp with time zone default now()
);

create table permisos (
  id uuid primary key default gen_random_uuid(),
  codigo text not null unique,
  nombre text not null,
  descripcion text
);

create table usuario_permisos (
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null references usuarios(id) on delete cascade,
  permiso_id uuid not null references permisos(id) on delete cascade,
  creado_en timestamp with time zone default now(),
  unique (usuario_id, permiso_id)
);

create table contratistas (
  id uuid primary key default gen_random_uuid(),
  nombre text not null unique,
  rnc text,
  telefono text,
  correo text,
  direccion text,
  creado_en timestamp with time zone default now()
);

create table proyectos (
  id uuid primary key default gen_random_uuid(),
  codigo_interno text unique,
  no_excel integer,
  snip text,
  proceso_compra text,
  tipo text not null,
  comunidad text not null,
  municipio text,
  poblacion integer default 0,
  presupuesto numeric(18,2) default 0,
  adjudicado numeric(18,2) default 0,
  comprometido numeric(18,2) default 0,
  pagado_base numeric(18,2) default 0,
  disponibilidad_adjudicado_base numeric(18,2) default 0,
  disponibilidad_proyecto_base numeric(18,2) default 0,
  contratista_id uuid references contratistas(id),
  estatus text default 'En proceso',
  creado_por uuid references usuarios(id),
  creado_en timestamp with time zone default now(),
  actualizado_en timestamp with time zone default now()
);

create table cubicaciones (
  id uuid primary key default gen_random_uuid(),
  proyecto_id uuid not null references proyectos(id) on delete cascade,
  numero text,
  fecha date not null,
  monto numeric(18,2) not null default 0,
  observacion text,
  registrado_por uuid references usuarios(id),
  creado_en timestamp with time zone default now()
);

create table pagos (
  id uuid primary key default gen_random_uuid(),
  proyecto_id uuid not null references proyectos(id) on delete cascade,
  cubicacion_id uuid references cubicaciones(id) on delete set null,
  fecha date,
  monto numeric(18,2) not null default 0,
  concepto text,
  metodo_pago text,
  referencia text,
  registrado_por uuid references usuarios(id),
  creado_en timestamp with time zone default now()
);

create table procesos_compras (
  id uuid primary key default gen_random_uuid(),
  expediente text unique,
  descripcion text not null,
  solicitante_id uuid references usuarios(id),
  departamento_id uuid references areas(id),
  estatus text default 'Pendiente',
  creado_en timestamp with time zone default now(),
  ultimo_cambio timestamp with time zone default now()
);

create table proceso_etapas (
  id uuid primary key default gen_random_uuid(),
  proceso_id uuid not null references procesos_compras(id) on delete cascade,
  nombre text not null,
  orden integer not null,
  estado text default 'pendiente',
  inicio timestamp with time zone,
  fin timestamp with time zone,
  actualizado_por uuid references usuarios(id),
  creado_en timestamp with time zone default now()
);

create table proceso_notas (
  id uuid primary key default gen_random_uuid(),
  proceso_id uuid not null references procesos_compras(id) on delete cascade,
  etapa_id uuid references proceso_etapas(id) on delete set null,
  nota text not null,
  autor_id uuid references usuarios(id),
  creado_en timestamp with time zone default now()
);

insert into areas (nombre)
values ('Finanzas'), ('Compras y Contrataciones'), ('Presupuesto'), ('Dirección Técnica'), ('Dirección General')
on conflict (nombre) do nothing;

insert into permisos (codigo, nombre)
values
  ('dashboard', 'Dashboard'),
  ('registro', 'Registro de proyectos'),
  ('cubicaciones', 'Registro de cubicaciones'),
  ('reportes', 'Reportes'),
  ('users-admin', 'Crear usuarios'),
  ('backup', 'Respaldos'),
  ('project-edit', 'Editar código, presupuesto y estatus'),
  ('payment-create', 'Registrar cubicaciones'),
  ('report-municipio', 'Reporte por municipio'),
  ('report-contratista', 'Reporte por contratista'),
  ('report-disponibilidad', 'Reporte disponibilidad'),
  ('report-pagos', 'Reporte pagos realizados'),
  ('report-estatus', 'Reporte estatus de obras'),
  ('report-poblacion', 'Reporte por población')
on conflict (codigo) do nothing;

create or replace view vista_proyectos_resumen as
select
  p.id,
  p.codigo_interno,
  p.snip,
  p.proceso_compra,
  p.tipo,
  p.comunidad,
  p.municipio,
  p.poblacion,
  c.nombre as contratista,
  p.estatus,
  p.presupuesto,
  p.adjudicado,
  p.comprometido,
  p.pagado_base,
  coalesce(sum(cu.monto), 0) as total_cubicaciones,
  p.pagado_base + coalesce(sum(cu.monto), 0) as total_pagado,
  p.presupuesto - (p.pagado_base + coalesce(sum(cu.monto), 0)) as disponible_adjudicado,
  p.disponibilidad_proyecto_base - (p.presupuesto - (p.pagado_base + coalesce(sum(cu.monto), 0))) as disponibilidad_proyecto
from proyectos p
left join contratistas c on c.id = p.contratista_id
left join cubicaciones cu on cu.proyecto_id = p.id
group by p.id, c.nombre;

alter table areas enable row level security;
alter table usuarios enable row level security;
alter table permisos enable row level security;
alter table usuario_permisos enable row level security;
alter table contratistas enable row level security;
alter table proyectos enable row level security;
alter table cubicaciones enable row level security;
alter table pagos enable row level security;
alter table procesos_compras enable row level security;
alter table proceso_etapas enable row level security;
alter table proceso_notas enable row level security;

create policy "areas_select" on areas for select using (true);
create policy "usuarios_all" on usuarios for all using (true) with check (true);
create policy "permisos_select" on permisos for select using (true);
create policy "usuario_permisos_all" on usuario_permisos for all using (true) with check (true);
create policy "contratistas_all" on contratistas for all using (true) with check (true);
create policy "proyectos_all" on proyectos for all using (true) with check (true);
create policy "cubicaciones_all" on cubicaciones for all using (true) with check (true);
create policy "pagos_all" on pagos for all using (true) with check (true);
create policy "procesos_all" on procesos_compras for all using (true) with check (true);
create policy "etapas_all" on proceso_etapas for all using (true) with check (true);
create policy "notas_all" on proceso_notas for all using (true) with check (true);
