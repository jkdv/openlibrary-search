alter table searchable_texts
  add column textsearchable_index_col tsvector
    generated always as (to_tsvector('english', coalesce(title, '') || ' ' || coalesce(author1_name, '') || ' ' || coalesce(author2_name, '') || ' ' || coalesce(author3_name, '') || ' ' || coalesce(author4_name, ''))) stored;

create index textsearchable_idx on searchable_texts using gin (textsearchable_index_col);
