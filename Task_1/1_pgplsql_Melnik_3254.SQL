--============================Мельник Степан 3254 задание 1 РПБД==============================================

--1)Выведите на экран любое сообщение
CREATE OR REPLACE FUNCTION print(stringa varchar) RETURNS VOID 
AS $$
BEGIN
	Raise Notice '%', stringa;
END;
$$ LANGUAGE plpgsql;

SELECT print('Hello world');

--2)Выведите на экран текущую дату
CREATE OR REPLACE FUNCTION date_now() RETURNS VOID 
AS $$
BEGIN
	Raise Notice '%', NOW()::DATE;
END;
$$ LANGUAGE plpgsql;

SELECT date_now();

/*3)Создайте две числовые переменные и присвойте им значение.
Выполните математические действия с этими числами и выведите результат на экран.*/

-- способ по условию:
CREATE OR REPLACE FUNCTION some_calculate() RETURNS VOID 
AS $$
DECLARE
x real:= 5;
y real:= 3;
BEGIN
	Raise Notice 'x + y = %', x + y;
	Raise Notice 'x * y = %', x * y;
	Raise Notice 'x - y = %', x - y;
	Raise Notice 'x / y = %', x / y;
	
	EXCEPTION 
		WHEN division_by_zero THEN
			RAISE EXCEPTION 'Деление на ноль, y = 0';
END;
$$ LANGUAGE plpgsql;

SELECT some_calculate();

--способ без объявления переменных

CREATE OR REPLACE PROCEDURE some_calc(INOUT x real, INOUT y real) 
LANGUAGE plpgsql
AS $$
BEGIN
	Raise Notice 'x + y = %', x + y;
	Raise Notice 'x * y = %', x * y;
	Raise Notice 'x - y = %', x - y;
	Raise Notice 'x / y = %', x / y;
	EXCEPTION 
		WHEN division_by_zero THEN
			RAISE EXCEPTION 'Деление на ноль, y = 0';
END;
$$;

CALL some_calc(5, 0);

--4)

CREATE OR REPLACE PROCEDURE write_marks(INOUT mark int)
LANGUAGE plpgsql
AS $$
--проще обрабатывать параметр, чем объявлять переменную
--DECLARE 
--mark int := 3;
BEGIN
	Raise Notice 'Оценка %', mark;
	IF mark = 5 THEN
		Raise Notice 'Отлично';
	ELSIF mark = 4 THEN
		Raise Notice 'Хорошо';
	ELSIF mark = 3 THEN
		Raise Notice 'Удовлетворительно';
	ELSIF mark = 2 THEN
		Raise Notice 'Неуд';
	ELSE
		Raise Notice 'Неверное значение оценки';
	END IF;
END;
$$;

CALL write_marks(2);

-- 2 способ
CREATE OR REPLACE PROCEDURE write_marks_two(INOUT mark int)
LANGUAGE plpgsql
AS $$
BEGIN
	Raise Notice 'Оценка %', mark;
	CASE mark 
		WHEN 5 THEN Raise Notice 'Отлично';
		WHEN 4 THEN Raise Notice 'Хорошо';
		WHEN 3 THEN Raise Notice 'Удовлетворительно';
		WHEN 2 THEN Raise Notice 'Неуд';
		ELSE Raise Notice 'Неверное значение оценки';	
	END CASE;
END;
$$;

CALL write_marks_two(5);


--5) Выведите все квадраты чисел от 20 до 30 3-мя разными способами (LOOP, WHILE, FOR).

--LOOP
CREATE OR REPLACE PROCEDURE loop_cycle()
LANGUAGE plpgsql
AS $$
DECLARE
i int := 19;
BEGIN
	LOOP 
		i :=i + 1;
		Raise Notice '%^2 = %', i, i^2;
		EXIT WHEN i = 30;
	END LOOP;
END;
$$;

CALL loop_cycle();

--WHILE


CREATE OR REPLACE PROCEDURE while_cycle()
LANGUAGE plpgsql
AS $$
DECLARE
i int := 20;
BEGIN
	WHILE i <= 30 LOOP
		Raise Notice '%^2 = %', i, i^2;
		i :=i + 1;
	END LOOP;
END;
$$;

CALL while_cycle();

-- FOR


CREATE OR REPLACE PROCEDURE for_cycle()
LANGUAGE plpgsql
AS $$
BEGIN
	FOR i IN 20..30 LOOP
		Raise Notice '%^2 = %', i, i^2;
	END LOOP;
END;
$$;

CALL while_cycle();


/*
6)
Задания: написать функцию, входной параметр - начальное число, на выходе - количество чисел, пока не получим 1;
написать процедуру, которая выводит все числа последовательности. Входной параметр - начальное число.
*/
CREATE OR REPLACE FUNCTION collatz_sequence_count(n int) RETURNS int
AS $$
DECLARE
sum_count int:= 0;
BEGIN
WHILE n != 1 LOOP
		IF mod(n, 2) = 0 THEN
			n := n/2;
			sum_count := sum_count + 1;
		ELSE
			n:= (n * 3) + 1;
			sum_count := sum_count + 1;
		END IF;
	END LOOP;
RETURN sum_count;
END;
$$ LANGUAGE plpgsql;

SELECT collatz_sequence_count(12);

CREATE OR REPLACE PROCEDURE collatz_sequence(INOUT n int)
LANGUAGE plpgsql
AS $$
BEGIN
	WHILE n != 1 LOOP
		IF mod(n, 2) = 0 THEN
			n := n/2;
			Raise Notice '%', n;
		ELSE
			n:= (n * 3) + 1;
			Raise Notice '%', n;
		END IF;
	END LOOP;
END;
$$;

CALL collatz_sequence(12);

--7)
--1 ЧАСТЬ
CREATE OR REPLACE FUNCTION Luke(n int) RETURNS int
AS $$
DECLARE
L0 int = 2;
L1 int = 1;
L_n int = 0;
BEGIN
	FOR i IN 3..n LOOP
		L_n = L1 + L0;
		L0 = L1;
		L1 = L_n;
	END LOOP;
	RETURN L1;
END;
$$ LANGUAGE plpgsql;

SELECT Luke(24);

--2 ЧАСТЬ

CREATE OR REPLACE PROCEDURE luke_range(INOUT n int)
LANGUAGE plpgsql
AS $$
DECLARE
L0 int = 2;
L1 int = 1;
L_n int = 0;
BEGIN
	RAISE NOTICE '%', L0;
	RAISE NOTICE '%', L1;
	FOR i IN 3..n LOOP
		L_n = L1 + L0;
		L0 = L1;
		L1 = L_n;
		RAISE NOTICE '%', L1;
	END LOOP;
END;
$$;

CALL luke_range(24);


--8)

CREATE OR REPLACE FUNCTION people_year(y int)RETURNS int
AS $$
DECLARE
cnt_people int;
BEGIN
	SELECT COUNT(id) INTO cnt_people
	FROM people
	WHERE date_part('year', birth_date) = y;
	RETURN cnt_people;
END;
$$ LANGUAGE plpgsql;

SELECT people_year(1989);

--9)

CREATE OR REPLACE FUNCTION people_eyes(e varchar) RETURNS int
AS $$
DECLARE
cnt_people int;
BEGIN
	SELECT COUNT(id) INTO cnt_people
	FROM people
	WHERE eyes = e;
	RETURN cnt_people;
END;
$$ LANGUAGE plpgsql;

SELECT people_eyes('brown');

--10)

CREATE OR REPLACE FUNCTION young_person() RETURNS int
AS $$
DECLARE
young int;
BEGIN
	SELECT id INTO young 
	FROM people
	ORDER BY birth_date DESC
	LIMIT 1;
	RETURN young;
END;
$$ LANGUAGE plpgsql;

SELECT young_person();

--11)

CREATE OR REPLACE PROCEDURE imt(INOUT w real) 
LANGUAGE plpgsql
AS $$
DECLARE
person people%ROWTYPE;
BEGIN
	FOR person IN
		SELECT * 
		FROM people
		WHERE weight/((growth/100))^2 > w		
	LOOP
	RAISE NOTICE 'id - %, name - %, surname - %', person.id, person.name, person.surname;
	END LOOP;
END;
$$;

CALL imt(20);

--12)

--создадим дополнительную таблицу с данными
--о родстве с использованием внешнего ключа
BEGIN;
CREATE TABLE people_ties(
	id SERIAL NOT NULL,
	id_person int NOT NULL,
	id_person_ties int,
	
	CONSTRAINT people_ties_pk PRIMARY KEY (id),
	CONSTRAINT people_ties_fk1 FOREIGN KEY (id_person)
        REFERENCES people (id),
	CONSTRAINT people_ties_fk2 FOREIGN KEY (id_person_ties)
        REFERENCES people (id)
);
COMMIT;

-- добавим данные
BEGIN;
INSERT INTO people_ties (id_person, id_person_ties)
--родственные связи работают в обе стороны, не обязательно писать (3, 4) и (4, 3)
-- но для удобного поиска по id_person укажу
	VALUES (3, 4),
	(3, 5),
	(4, 3),
	(4, 5),
	(5, 3),
	(5, 4);
COMMIT;

SELECT * FROM people_ties

--13)

CREATE OR REPLACE PROCEDURE 
add_people(
	INOUT name varchar, surname varchar, birth_date date,
	growth real, weight real, eyes varchar, hair varchar, tiess int)
LANGUAGE plpgsql
AS $$
DECLARE
	id_this_person int;
BEGIN
	INSERT INTO people(name, surname, birth_date, growth, weight, eyes, hair)
	VALUES (name, surname, birth_date, growth, weight, eyes, hair)
	RETURNING id INTO id_this_person;
	IF tiess IS NOT NULL THEN
 		INSERT INTO people_ties(id_person, id_person_ties)
 		VALUES (id_this_person, tiess);
		INSERT INTO people_ties(id_person, id_person_ties)
 		VALUES (tiess, id_this_person);
	END IF;
END;
$$;

CALL add_people('anton', 'petrov', '2.3.2000', 173, 60, 'brown', 'red', 6);
--случай, если родственных связей нет
CALL add_people('anton', 'qwertov', '2.3.2004', 177, 61, 'brown', 'red', null);

--14)

BEGIN;
ALTER TABLE people ADD COLUMN time_relevance TIMESTAMP;
COMMIT;

--15)

CREATE OR REPLACE PROCEDURE updating(INOUT nid int, ngrowth real, nweight real)
LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE people 
	SET growth = ngrowth,
		weight = nweight,
		time_relevance = CURRENT_TIMESTAMP
	WHERE id = nid;
END;
$$;

CALL updating(8, 180, 70);
