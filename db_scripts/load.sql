select now();
-- import authors csv
alter table authors set unlogged;
\i 'db_scripts/openlibrary-data-loader.sql'
alter table authors set logged;

select now();
\i 'db_scripts/tbl_authors_indexes.sql';

select now();
-- import works csv
alter table works set unlogged;
\i 'db_scripts/openlibrary-data-loader.sql'
alter table works set logged;

select now();
\i 'db_scripts/tbl_works_indexes.sql';

select now();
-- import editions csv
alter table editions set unlogged;
select now();
\i 'db_scripts/openlibrary-data-loader.sql'
alter table editions
add column work_key text;

select now();
update editions
set work_key = data->'works'->0->>'key';
alter table editions set logged;

select now();
\i 'db_scripts/tbl_editions_indexes.sql';
select now();
-- set isbn for edition_isbns from the embedded json

select now();
alter table edition_isbns set unlogged;
insert into edition_isbns (edition_key, isbn)
select
  distinct edition_key,
  isbn
from (
  select
    key as edition_key,
    jsonb_array_elements_text(data->'isbn_13') as isbn
  from editions
  where jsonb_array_length(data->'isbn_13') > 0
  and key is not null
  union all
  select
    key as edition_key,
    jsonb_array_elements_text(data->'isbn_10') as isbn
  from editions
  where jsonb_array_length(data->'isbn_10') > 0
  and key is not null
  union all
  select
    key as edition_key,
    jsonb_array_elements_text(data->'isbn') as isbn
  from editions
  where jsonb_array_length(data->'isbn') > 0
  and key is not null) isbns
where length(isbn) = 13 or length(isbn) = 10;
alter table edition_isbns set logged;

select now();
-- create isbn indexes
\i 'db_scripts/tbl_edition_isbns_indexes.sql';
select now();

select now();
alter table searchable_texts set unlogged;
insert into searchable_texts (
  work_key,
  title,
  author1_key,
  author2_key,
  author3_key,
  author4_key,
  author1_name,
  author2_name,
  author3_name,
  author4_name,
  author_count,
  cover
)
select
  w.work_key
  , w.title
  , w.author1_key
  , w.author2_key
  , w.author3_key
  , w.author4_key
  , a1.data->>'name' as author1_name
  , a2.data->>'name' as author2_name
  , a3.data->>'name' as author3_name
  , a4.data->>'name' as author4_name
  , w.author_count
  , cover
from (
    select
      key as work_key
      , jsonb_extract_path_text(data, 'title') as title
      --, jsonb_array_elements(data->'authors')->'author'->>'key' as author_key
      , data->'authors'->0->'author'->>'key' as author1_key
      , data->'authors'->1->'author'->>'key' as author2_key
      , data->'authors'->2->'author'->>'key' as author3_key
      , data->'authors'->3->'author'->>'key' as author4_key
      , coalesce(jsonb_array_length(data->'authors'), 0) as author_count
      , data->'covers'->>-1 as cover
    from works) w
left join authors a1 on w.author1_key = a1.key
left join authors a2 on w.author2_key = a2.key
left join authors a3 on w.author3_key = a3.key
left join authors a4 on w.author4_key = a4.key
where w.title is not null
  and a1.data->>'name' is not null
;
alter table searchable_texts set logged;

select now();
-- create searchable_texts indexes
\i 'db_scripts/tbl_searchable_texts_indexes.sql';
select now();