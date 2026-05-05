create extension if not exists vector;

create table if not exists public.rag_documents (
  id uuid primary key default gen_random_uuid(),

  title text not null unique,
  source_type text not null default 'module',
  source_id uuid null,
  content_url text null,

  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.rag_chunks (
  id uuid primary key default gen_random_uuid(),

  document_id uuid not null references public.rag_documents(id) on delete cascade,

  chunk_index int not null,
  content text not null,

  embedding vector(384) null,
  metadata jsonb not null default '{}'::jsonb,

  created_at timestamptz not null default now(),

  constraint rag_chunks_document_chunk_unique unique (document_id, chunk_index)
);

create index if not exists rag_chunks_document_id_idx
on public.rag_chunks(document_id);

create index if not exists rag_chunks_metadata_gin_idx
on public.rag_chunks using gin (metadata);

create index if not exists rag_chunks_embedding_idx
on public.rag_chunks
using ivfflat (embedding vector_cosine_ops)
with (lists = 100);

create or replace function public.match_rag_chunks (
  query_embedding vector(384),
  match_threshold float default 0.50,
  match_count int default 5,
  filter jsonb default '{}'::jsonb
)
returns table (
  chunk_id uuid,
  document_id uuid,
  title text,
  content text,
  metadata jsonb,
  similarity float
)
language plpgsql
stable
as $$
begin
  return query
  select
    rc.id as chunk_id,
    rc.document_id,
    rd.title,
    rc.content,
    rc.metadata,
    1 - (rc.embedding <=> query_embedding) as similarity
  from public.rag_chunks rc
  join public.rag_documents rd on rd.id = rc.document_id
  where rd.is_active = true
    and rc.embedding is not null
    and rc.metadata @> filter
    and 1 - (rc.embedding <=> query_embedding) > match_threshold
  order by rc.embedding <=> query_embedding
  limit match_count;
end;
$$;