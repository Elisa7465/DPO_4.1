-- 1) Стандартные типы
CREATE TABLE standard_types (
  id              int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  small_i         smallint, --32 767
  int_i           integer, --2 147 483 647
  big_i           bigint, --9 223 372 036 854 775 807
  num_val         numeric(12,2),
  real_val        real, --6-7знаков после запятой
  double_val      double precision,--15-16знаков после запятой
  char_val        char(10), --рочно 10 символов остальное пробелы
  varchar_val     varchar(100),
  text_val        text,
  bool_val        boolean,
  date_val        date, --Y-M-D
  time_val        time,
  timetz_val      time with time zone, --14:30:00+03
  ts_val          timestamp,
  tstz_val        timestamp with time zone
);

-- 2) Перечисления (ENUM)
CREATE TYPE status_enum AS ENUM ('new','in_progress','done'); --создаёт свой тип данных — перечисление
CREATE TABLE enum_types (
  id      int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  status  status_enum NOT NULL
);

-- 3) Массивы
CREATE TABLE array_types (
  id        int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  int_arr   integer[],
  text_arr  text[]
);

-- 4) XML и JSON
CREATE TABLE xml_json_types (
  id        int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  xml_col   xml, 
  json_col  json,
  jsonb_col jsonb --сортируютсч ключи, удляются дубликаты
);

-- 5) Составные типы
CREATE TYPE address_type AS ( --новый тип с полями из которого он состоит
  city   text,
  street text,
  zip    text
);
CREATE TABLE composite_types (
  id    int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  addr  address_type
);

-- 6) Прочие типы
CREATE TABLE other_types (
  id          int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  money_col   money, --2знака после запятой
  bytea_col   bytea,  --двоичные
  point_col   point,
  line_col    line, --линия
  lseg_col    lseg, --отрезок
  box_col     box, --прямоуголиник
  polygon_col polygon,
  circle_col  circle,
  bit_col     bit(8),         -- битовые строки
  varbit_col  bit varying(32),
  uuid_col    uuid --128-битный идентификатор.
);



-- 1) Стандартные типы

INSERT INTO standard_types (
  small_i,int_i,big_i,num_val,real_val,double_val,
  char_val,varchar_val,text_val,bool_val,
  date_val,time_val,timetz_val,ts_val,tstz_val
) VALUES (
  1,42,1000000000000,12345.67,3.14159,2.718281828459045,
  'hello','alpha','lorem ipsum',TRUE,
  '2024-12-31','08:30','14:30:00+03','2025-01-10 12:00:00','2025-01-10 12:00:00+03'
);

INSERT INTO standard_types (
  small_i,int_i,big_i,num_val,real_val,double_val,
  char_val,varchar_val,text_val,bool_val,
  date_val,time_val,timetz_val,ts_val,tstz_val
) VALUES (
  32767,2147483647,9223372036854775807,9999999999.99,0.1,1e100,
  'ABCDEFGHIJ','beta gamma','quick brown fox',FALSE,
  '2020-02-29','23:59:59.999999','23:59:59+05','1999-12-31 23:59:59','1999-12-31 23:59:59+00'
);

INSERT INTO standard_types (
  small_i,int_i,big_i,num_val,real_val,double_val,
  char_val,varchar_val,text_val,bool_val,
  date_val,time_val,timetz_val,ts_val,tstz_val
) VALUES (
  -10,-100,-9000000000000000000,0.00,0.3333333,0.3333333333333333,
  'xyz','gamma','HELLO WORLD',TRUE,
  '2025-01-01','12:00','12:00+00','2025-06-15 08:00:00','2025-06-15 08:00:00+02'
);

INSERT INTO standard_types (
  small_i,int_i,big_i,num_val,real_val,double_val,
  char_val,varchar_val,text_val,bool_val,
  date_val,time_val,timetz_val,ts_val,tstz_val
) VALUES (
  0,0,0,-1234.56,-2.5,-2.5,
  'A','delta','пример текста',FALSE,
  '2000-01-01','00:00','00:00+03','2000-01-01 00:00:00','2000-01-01 00:00:00+03'
);

INSERT INTO standard_types (
  small_i,int_i,big_i,num_val,real_val,double_val,
  char_val,varchar_val,text_val,bool_val,
  date_val,time_val,timetz_val,ts_val,tstz_val
) VALUES (
  123,500000,1234567890123,42.00,10.0,10.0,
  'postgres','epsilon zeta','αβγ',TRUE,
  '2023-07-15','16:45:30','16:45:30+02','2023-07-15 16:45:30','2023-07-15 16:45:30+02'
);
SELECT * FROM standard_types WHERE small_i BETWEEN -10 AND 200;                          
SELECT * FROM standard_types WHERE int_i = 2147483647;                                    
SELECT * FROM standard_types WHERE big_i < 0 OR big_i >= 1000000000000;                   
SELECT * FROM standard_types WHERE num_val = 42.00;                                       
SELECT * FROM standard_types WHERE real_val > 3.0 AND real_val < 3.2;                     
SELECT * FROM standard_types WHERE double_val >= 1e20 OR double_val <= -1;                
SELECT * FROM standard_types WHERE char_val LIKE 'post%';                                                               
SELECT * FROM standard_types WHERE bool_val IS TRUE;                                      
SELECT * FROM standard_types WHERE date_val BETWEEN '2023-01-01' AND '2025-12-31';       
SELECT * FROM standard_types WHERE time_val >= '08:00' AND time_val < '17:00';            
SELECT * FROM standard_types WHERE timetz_val > '12:00:00+00';                             

-- 2) Перечисления (ENUM)

INSERT INTO enum_types (status) VALUES ('new');
INSERT INTO enum_types (status) VALUES ('in_progress');
INSERT INTO enum_types (status) VALUES ('done');

SELECT * FROM enum_types WHERE status >= 'in_progress';

-- 3) Массивы
INSERT INTO array_types (int_arr, text_arr) VALUES (ARRAY[1,2,3],            ARRAY['alpha','beta']);
INSERT INTO array_types (int_arr, text_arr) VALUES (ARRAY[42,100],           ARRAY['postgres','sql']);
INSERT INTO array_types (int_arr, text_arr) VALUES (ARRAY[10,11],     ARRAY['only','text']);
INSERT INTO array_types (int_arr, text_arr) VALUES (ARRAY[15,10],      ARRAY['postgres','sql']);
INSERT INTO array_types (int_arr, text_arr) VALUES (ARRAY[5,5,10],           ARRAY['alpha','gamma','delta']);

SELECT * FROM array_types WHERE 100 = ANY(int_arr);   --есть 100                   
SELECT * FROM array_types WHERE text_arr && ARRAY['alpha','omega']; --пересечение массивов

-- 4) XML и JSON
INSERT INTO xml_json_types (xml_col, json_col, jsonb_col) VALUES
  ('<tag>v1</tag>',
   '{ "b":1, "a": 2 }',
   '{ "b":1, "a": 2 }');

INSERT INTO xml_json_types (xml_col, json_col, jsonb_col) VALUES
  ('<tag>ok</tag>',
   '{ "a": 1,  "a": 2,  "b": 3 }',      
   '{ "a": 1,  "a": 2,  "b": 3 }');     

SELECT * FROM xml_json_types WHERE xmlexists('//tag[text()="ok"]' PASSING BY REF xml_col);    
SELECT * FROM xml_json_types WHERE json_col::text LIKE '%"a": 2%';                            

-- 5) Составные типы

INSERT INTO composite_types (addr) VALUES (ROW('Москва','Тверская','101000')::address_type);
INSERT INTO composite_types (addr) VALUES (ROW('Санкт-Петербург','Невский проспект','191025')::address_type);
INSERT INTO composite_types (addr) VALUES (ROW('Казань','Кремлёвская','420111')::address_type);

SELECT * FROM composite_types WHERE (addr).city = 'Москва';         
SELECT * FROM composite_types WHERE (addr).street ILIKE '%просп%';    
SELECT * FROM composite_types WHERE (addr).zip ~ '^\d{6}$';           -- ровно 6 цифр

-- 6) Прочие типы
INSERT INTO other_types (
  money_col, bytea_col, point_col, line_col, lseg_col, box_col,
  polygon_col, circle_col, bit_col, varbit_col, uuid_col
) VALUES (
  100.00::money, '\xDEADBEEF', point '(1,1)', line '[(0,0),(1,1)]', lseg '[(-1,0),(1,0)]',
  box '(2,2),(0,0)', polygon '((0,0),(2,0),(2,2))', circle '<(0,0),1>',
  B'10101010', B'11001100', '123e4567-e89b-12d3-a456-426614174000'
);

INSERT INTO other_types (
  money_col, bytea_col, point_col, line_col, lseg_col, box_col,
  polygon_col, circle_col, bit_col, varbit_col, uuid_col
) VALUES (
  12.34::money,'\xDEADBEEF', point '(-2,3)', line '[(0,1),(1,1)]', lseg '[(0,0),(3,4)]',
  box '(1,1),(-1,-1)', polygon '((0,0),(1,2),(2,0),(1,-1))', circle '<(5,5),3>',
  B'00001111', B'11110000', 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
);

INSERT INTO other_types (
  money_col, bytea_col, point_col, line_col, lseg_col, box_col,
  polygon_col, circle_col, bit_col, varbit_col, uuid_col
) VALUES (
  50.00::money, '\x00', point '(10,10)', line '[(0,0),(0,1)]', lseg '[(1,1),(1,5)]',
  box '(0,0),(-2,-2)', polygon '((0,0),(0,3),(3,3),(3,0))', circle '<(0,0),5>',
  B'11111111', B'1', 'ffffffff-ffff-ffff-ffff-ffffffffffff'
);
           
SELECT * FROM other_types WHERE area(box_col) >= 4;                               
SELECT * FROM other_types WHERE npoints(polygon_col) >= 4;                        
SELECT * FROM other_types WHERE radius(circle_col) > 1;                                                          
SELECT * FROM other_types WHERE uuid_col = '123e4567-e89b-12d3-a456-426614174000';       


