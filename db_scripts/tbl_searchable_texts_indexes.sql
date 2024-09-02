alter table searchable_texts
  add column textsearchable_index_col tsvector
    generated always as (to_tsvector('english', coalesce(title, '') || ' ' || coalesce(author_name, ''))) stored;

create index textsearchable_idx on searchable_texts using gin (textsearchable_index_col);
