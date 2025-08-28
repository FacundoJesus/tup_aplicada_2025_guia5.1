--a- Prepare la base de datos para el ejercicio 1 (drop y create). 
--Llamar a la base de datos: GUIA5_1_Ejercicio1_DB
USE master
GO

DROP DATABASE IF EXISTS GUIA5_1_Ejercicio1_DB;
GO

CREATE DATABASE GUIA5_1_Ejercicio1_DB;
GO

USE GUIA5_1_Ejercicio1_DB;
GO

--b- Crear las tablas siguiendo la estrategia TPH para los datos dados en la Tabla 1 y en la Tabla 2.  
--Usar como discriminador un número entero (1: Rectángulo, 2: Círculo)
CREATE TABLE Figuras
(
Id INT IDENTITY, -- O PONER PRIMARY KEY aca...
Area DECIMAL(18,2),
Tipo INT NOT NULL, -- 1 ES RECTANGULO - 2 ES CIRCULO
Ancho DECIMAL (18,2),
Largo DECIMAL (18,2),
Radio DECIMAL (18,2)
CONSTRAINT PK_Figuras PRIMARY KEY (Id)
);

GO

--c- Insertar los datos dados en la Tabla 1 y Tabla 2. Consultar los datos insertados.
INSERT INTO Figuras(Tipo, Ancho, Largo, Radio)
VALUES
-- RECTANGULO
(1,1,1, NULL),
(1,1,2, NULL),
(1, 2.2,1, NULL),
-- CIRCULO
(2,NULL, NULL, 1),
(2,NULL, NULL, 1);

SELECT f.Id,
		Tipo = CASE WHEN f.Tipo = 1 THEN 'Rectangulo'
			        WHEN f.Tipo = 2 THEN 'Círculo'
					ELSE 'Desconocido'
		END,
		f.Area,
		f.Ancho,
		f.Largo,
		f.Radio
FROM Figuras f
ORDER BY f.Area DESC

GO

--D Crear un procedimiento almacenado para calcular el área de la Figura 
--geométrica dada por Id. Debe contemplar que cada tipo de figura geométrica tiene un cálculo de área diferente. 
--El procedimiento se deberá llamar sp_CalcularArea(Id)
CREATE PROCEDURE sp_Calcular_Area
(
@Id INT
)
AS
--e- Calcular el área de un rectángulo y un círculo, tomados de la base de datos, 
--invocando al procedimientos almacenado creado en el punto anterior (d), 
--y finalmente, mostrar en una consulta las Figuras geométricas de la base. 
BEGIN
	--UPDATE Figuras SET Area = Ancho * Largo
	--WHERE Id=@Id AND Tipo=1;
	--UPDATE Figuras SET Area = 3.1415*Radio*Radio
	--WHERE Id=@Id AND Tipo=2;
	UPDATE Figuras SET Area = CASE WHEN Tipo = 1 THEN Ancho*Largo
									WHEN Tipo = 2 THEN 3.1415*POWER(Radio,2)
									ELSE 0 END
	WHERE ID=@Id
END

GO

EXEC sp_Calcular_Area @Id = 1
EXEC sp_Calcular_Area @Id = 4

SELECT * FROM Figuras;
GO

--f- Calcular el área de todas las figuras. 
-- Recorrer todas las figuras mediante un cursor. Actualizar la tabla de Figuras geométricas con dicho valor calculado.
DECLARE Figura_CURSOR CURSOR FOR SELECT f.Id FROM Figuras f;

OPEN Figura_CURSOR;

DECLARE @Id_ INT;

FETCH NEXT FROM Figura_CURSOR INTO @Id_;

WHILE @@FETCH_STATUS=0

BEGIN
	EXEC sp_Calcular_Area @Id = @Id_;
	FETCH NEXT FROM Figura_CURSOR INTO @Id_;
	END
CLOSE Figura_CURSOR;

DEALLOCATE Figura_CURSOR;

GO

SELECT f.Id,
		Tipo = CASE WHEN f.Tipo = 1 THEN 'Rectangulo'
			        WHEN f.Tipo = 2 THEN 'Círculo'
					ELSE 'Desconocido'
		END,
		f.Area,
		f.Ancho,
		f.Largo,
		f.Radio
FROM Figuras f
ORDER BY f.Area DESC

GO

USE master;