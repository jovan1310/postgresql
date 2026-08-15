-- 1. BRISANJE STARIH TABELA (Ako postoje od ranije, radi čistog starta)
DROP TABLE IF EXISTS unesco CASCADE;
DROP TABLE IF EXISTS category CASCADE;
DROP TABLE IF EXISTS state CASCADE;
DROP TABLE IF EXISTS region CASCADE;
DROP TABLE IF EXISTS iso CASCADE;
DROP TABLE IF EXISTS unesco_raw CASCADE;

-- 2. KREIRANJE RAW TABELE I UVOZ PODATAKA
CREATE TABLE unesco_raw (
    name TEXT, description TEXT, justification TEXT, year INTEGER,
    longitude FLOAT, latitude FLOAT, area_hectares FLOAT,
    category TEXT, category_id INTEGER, state TEXT, state_id INTEGER,
    region TEXT, region_id INTEGER, iso TEXT, iso_id INTEGER
);

-- (Ovde pokreni svoju \copy komandu iz psql-a)
-- \copy unesco_raw(name,description,justification,year,longitude,latitude,area_hectares,category,state,region,iso) FROM 'whc-sites-2018-small.csv' WITH DELIMITER ',' CSV HEADER;


-- 3. KREIRANJE LOOKUP TABELA
CREATE TABLE category (
    id SERIAL PRIMARY KEY,
    name VARCHAR(128) UNIQUE
);

CREATE TABLE state (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE
);

CREATE TABLE region (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE
);

CREATE TABLE iso (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE
);


-- 4. PUNJENJE LOOKUP TABELA JEDINSTVENIM TEKSTUALNIM VREDNOSTIMA
INSERT INTO category (name) SELECT DISTINCT category FROM unesco_raw WHERE category IS NOT NULL;
INSERT INTO state (name) SELECT DISTINCT state FROM unesco_raw WHERE state IS NOT NULL;
INSERT INTO region (name) SELECT DISTINCT region FROM unesco_raw WHERE region IS NOT NULL;
INSERT INTO iso (name) SELECT DISTINCT iso FROM unesco_raw WHERE iso IS NOT NULL;


-- 5. KLJUČNI KORAK KOJI JE NEDOSTAJAO: Povezivanje unesco_raw sa novim ID-jevima
-- Ovim korakom punimo prazne `_id` kolone u unesco_raw tabeli na osnovu tekstualnog poklapanja
UPDATE unesco_raw u SET category_id = c.id FROM category c WHERE u.category = c.name;
UPDATE unesco_raw u SET state_id = s.id FROM state s WHERE u.state = s.name;
UPDATE unesco_raw u SET region_id = r.id FROM region r WHERE u.region = r.name;
UPDATE unesco_raw u SET iso_id = i.id FROM iso i WHERE u.iso = i.name;


-- 6. KREIRANJE FINALNE NORMALIZOVANE TABELE 'unesco'
CREATE TABLE unesco (
    id SERIAL PRIMARY KEY,
    name TEXT,
    year INT,
    category_id INT REFERENCES category(id),
    state_id INT REFERENCES state(id),
    region_id INT REFERENCES region(id),
    iso_id INT REFERENCES iso(id)
);


-- 7. PUNJENJE FINALNE TABELE (Sada unesco_raw ima spremne ID vrednosti!)
INSERT INTO unesco (name, year, category_id, state_id, region_id, iso_id)
SELECT name, year, category_id, state_id, region_id, iso_id 
FROM unesco_raw;


-- 8. PROVERA (Ovaj upit traži autograder)
SELECT unesco.name, year, category.name, state.name, region.name, iso.name
  FROM unesco
  JOIN category ON unesco.category_id = category.id
  JOIN iso ON unesco.iso_id = iso.id
  JOIN state ON unesco.state_id = state.id
  JOIN region ON unesco.region_id = region.id
  ORDER BY year, unesco.name
  LIMIT 3;

 SELECT * FROM unesco_raw;