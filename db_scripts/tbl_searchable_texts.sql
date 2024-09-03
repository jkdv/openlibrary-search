create table searchable_texts (
  work_key text not null,
  title text not null,
  author1_key text,
  author2_key text,
  author3_key text,
  author4_key text,
  author1_name text,
  author2_name text,
  author3_name text,
  author4_name text,
  author_count smallint not null,
  cover text
);
