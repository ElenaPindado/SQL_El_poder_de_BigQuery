
   --------------PROYECTO ANÁLISIS DE VENTAS-------------------------



------------------ FILTRADO Y ORDENACIÓN DE DATOS: WHERE- ORDER BY------------------------


--1. Escribe una consulta que devuelva todas las columnas de la tabla 'Employees' donde el salario sea mayor de 50000.

SELECT * FROM `SQL_Project.Employees` 
WHERE salary > 50000

--2. Escribe una consulta que te devuelva toda las columnas de la tabla 'Products' donde la cantidad  sea mayor de 15 y el precio sea menor que 1000'

SELECT * FROM `SQL_Project.Products`
WHERE quantity > 15 AND price < 1000 

--3. Escribe una consulta para devolver todos los nombres de la tabla 'Customers' en orden alfabético

SELECT name 
FROM `SQL_Project.Customers`
ORDER BY name


--4. Escribe una consulta para devolver el número total de pedidos de la tabla 'Orders'

SELECT count(*) as total_pedidos
FROM `SQL_Project.Orders`

---------------------------------------------------------------------------------------------------------------------------------------------------------


-------------------------------------------UNIR TABLAS - JOIN--------------------------------------------------


--1. Escribe una consulta que devuelva el nombre de los clientes y fecha de pedidos de la tabla 'Customers' y 'Orders'.

SELECT  name, order_date
FROM `SQL_Project.Customers` as c 
INNER JOIN `SQL_Project.Orders`  as o ON c.customer_id= o.customer_id


-- 2. Escribe una consulta que devuelva el nombre del producto, categoría y el nombre del proveedor de las tablas 'products', 'categories' y 'suppliers'

 WITH producto AS ( 

SELECT name,
  CASE 
    WHEN product_id IN (1, 2) THEN 'Electronics'
    ELSE 'Accessories'
  END AS categoria
FROM `SQL_Project.Products`),

proveedor AS (
  SELECT c.name as categoria , 
s.name as proveedor
FROM `SQL_Project.Categories`c
INNER JOIN `SQL_Project.Suppliers`s ON c.category_id =s.supplier_id
)


SELECT producto.name as producto, producto.categoria,proveedor.proveedor as proveedor
FROM producto 
INNER JOIN proveedor
ON producto.categoria=proveedor.categoria


 --3 . Escribe una consulta que devuelva el nombre del cliente y la cantidad de pedidos que ha realizado, así como los que estén completados.

SELECT name as cliente ,
count(order_id) as pedidos_realizados,
SUM(CASE WHEN status = 'complete' THEN 1 ELSE 0 END) AS pedidos_completados 
FROM `SQL_Project.Customers` c
INNER JOIN `SQL_Project.Orders` o
ON c.customer_id=o.customer_id
group by name

-----------------------------------------------------------------------------------------------------------------------------------------------------------------


------- FUNCIONES DE AGREGACIÓN : COUNT, SUM, MIN, MAX Y AVG  - GROUP BY 


-- 1. Escriba una consulta que devuelva el número total de pedidos por cada cliente de la tabla 'orders'

SELECT  name as cliente,
count(order_id) as total_pedidos,
FROM `SQL_Project.Customers` c
INNER JOIN `SQL_Project.Orders` o
ON c.customer_id=o.customer_id
group by name


-- 2.Escribe una consulta que devuelva el precio medio de productos en cada categoria de la tabla 'productos'.

WITH preciomedio AS 
(
SELECT name as producto,price,
  CASE 
    WHEN product_id IN (1, 2) THEN 'Electronics'
    ELSE 'Accessories'
  END AS categoria
FROM `SQL_Project.Products`)

SELECT categoria,
AVG(price) as precio_medio
FROM preciomedio
GROUP BY categoria


-- 3.Escribe una consulta que devuelva el máximo salario de la tabla 'empleados'.

SELECT 
MAX(salary) as maximo_salario
FROM `SQL_Project.Employees`


--4.Escribe una consulta que devuelva el total de ganancias generadas por cada cliente de la tabla 'orders' y 'orders_items'

WITH ganancias_cliente AS(

SELECT customer_id,
SUM(price) as ganancias
FROM `SQL_Project.Order_items` i
INNER JOIN `SQL_Project.Orders`o
ON i.order_id=o.order_id
INNER JOIN `SQL_Project.Products` p 
ON i.product_id= p.product_id
GROUP BY customer_id)

SELECT name as cliente,
ganancias as ganancias_generadas
FROM `SQL_Project.Customers` c
INNER JOIN ganancias_cliente g
ON c.customer_id=g.customer_id

-------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------- DATA MANIPULACIÓN : UPDATE, DELETE AND INSERT INTO SELECT---------------------------------------------


--1. Escribe una consulta que actualice la columna 'quantity'de la tabla 'products' a 20 para todos los productos cuyo precio sea mayor de 100.

UPDATE `SQL_Project.Products`
SET quantity = 20
WHERE price > 100 


--2. Escribe una consulta para borrar todos los registros de la tabla cliente donde la última fecha de compra sea mayor que un año.

DELETE FROM `SQL_Project.Customers`
WHERE customer_id IN (
  SELECT c.customer_id
  FROM `SQL_Project.Customers` AS c
  INNER JOIN `SQL_Project.Orders` AS o
  ON c.customer_id = r.customer_id
  WHERE o.order_date > DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR)
)


--3.Escribe una consulta que borre los registros de la tabla cliente que tenga valores nulos 

DELETE FROM `SQL_Project.Customers`
WHERE name IS NULL OR email IS NULL 


--4. Escribe una consulta para actualizar el descuento de la tabla 'orders' incrementándolo en un 5% para todos los pedidos localizados en una fecha especifica.(como no tenemos la columna 'discount' tendríamos que crearla primero)

UPDATE `sql-project-399618.SQL_Project.Orders`
SET descuento = descuento * 1.05
WHERE fecha = 'fecha_especifica'

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------- FILTROS AVANZADOS : LIKE, IN, BETWEEN , NULL------------------------------

--1.Escribe una consulta SQL para devolver todos los productos con precio que sea por encima de 1000 o por debajo de 500.

SELECT name, price
FROM `SQL_Project.Products`
WHERE price > 1000 OR price < 500


--2.Escribe una consulta para devolver todos los clientes cuyos nombres empiecen por A y su email contenga la palabara 'abdul'

SELECT name, email
FROM `SQL_Project.Customers`
WHERE name LIKE 'A%' AND email LIKE '%abdul%'
 

-- 3.Escribe una consulta que devuelva los pedidos que fueron solicitados entre una fecha específica. 

SELECT *
FROM `SQL_Project.Orders`
WHERE order_date BETWEEN '2023-05-10' AND '2023-05-20'
 


--4.Escribe una consulta que devuelva todos los clientes que no tienen email especificado en la base de datos.

SELECT name, email
FROM `SQL_Project.Customers`
WHERE email IS NULL ---- solo nos devolverá los valores nulos, pero si tenemos casos donde simplemente no hay registro debemos usar la query siguiente:

SELECT *
FROM `SQL_Project.Customers`
WHERE email IN ('') OR email IS NULL;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------- FUNCIONES: STRING,DATE Y NUMERIC FUNCTIONS-------------------------------------------------


--1. Escribe una consulta que devuelva la longitud de los nombres de los productos dentro de la tabla 'products'

SELECT name, LENGTH(name) AS longitud_nombre --La función LENGTH se utiliza para contar el número de caracteres en una cadena de texto.
FROM `SQL_Project.Products`


--2. Escribe una consulta que devuelva la fecha actual.

SELECT CURRENT_DATE() AS fecha_actual


--3. Escribe una consulta que devuelva los nombres en mayúsculas de todos los empleados .

SELECT upper(name) as empleados
FROM `SQL_Project.Employees`


--4. Escribe una consulta que devuelva el precio promedio de los productos despues de aplicar un 10% dcto.

SELECT AVG(price * 0.9) AS precio_promedio_con_descuento
FROM `SQL_Project.Products`

--5. Para ver el precio de cada producto aplicando un 10 % de dcto

SELECT name as producto,
price as precio,
(price*0.9) as precio_10_dcto
FROM `SQL_Project.Products`

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------- SUBQUERIES-----------------------------------

--1.Escribe una consulta que devuelva todos los productos con un precio más alto que la media del precio de todos los productos.


SELECT name, price
FROM `SQL_Project.Products`
WHERE price > (SELECT AVG(price)
FROM `SQL_Project.Products`)


--2.Escribe una consulta que devuelva todos los clientes quienes tienen un pedido después del último pedido de una fecha específica.

SELECT name, order_date
FROM `SQL_Project.Customers` c
INNER JOIN `SQL_Project.Orders` o
ON c.customer_id=o.customer_id
WHERE order_date > '2023-05-10'


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------ VISTAS --------------------------


--1.Crea una vista llamada 'empleados_alto_salario' que devuelva todos los empleados con un salario mayor que 5000

CREATE VIEW SQL_Project.V_Empleados_alto_salario AS
SELECT name, salary 
FROM `SQL_Project.Employees`
WHERE salary > 50000

SELECT * FROM `SQL_Project.V_Empleados_alto_salario`


--2.Crea una vista llamada 'suma_pedidos' que devuelva el total de pedidos y el numero de pedidos de cada cliente.


CREATE VIEW SQL_Project.V_Suma_pedidos AS
SELECT COUNT(order_id) AS total_pedidos,
name as cliente
FROM `SQL_Project.Orders`o
INNER JOIN `SQL_Project.Customers`c
ON o.customer_id=c.customer_id
GROUP BY cliente


--3.Crea una vista llamada 'inventario' que devuelva el nombre de los productos y la cantidad disponible para cada producto.

CREATE VIEW SQL_Project.V_Inventario AS
SELECT name AS producto,
quantity AS cantidad_disponible
FROM `SQL_Project.Products`

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------INTEGRIDAD DE DATOS Y RESTRICCIONES : NOT NULL, UNIQUE-------------------------------


--1. Crea una tabla llamada empleados con columnas para cada empleado id, nombre e email que debe ser unique.


CREATE TABLE `sql-project-399618.SQL_Project.empleado2` 
  (empleado_id INT64 NOT NULL,
  nombre STRING,
  email STRING)



--2.Crea una tabla llamada pedidos con columnas para pedido id, cliente id, y fecha de pedido donde cliente id hace referencia a la tabla 'customers'.

CREATE TABLE `sql-project-399618.SQL_Project.pedidos` 
 (
Id_pedido INT64,
customer_id INT64 ,
Fecha_pedido DATE)



--3.Crea una tabla llamada productos2 con columnas para producto id, nombre y precio donde product ID  es la primary key y el precio no puede ser nulo.

CREATE TABLE  `sql-project-399618.SQL_Project.productos2`  
(
Id_producto INT64 ,
nombre STRING,
precio INT64 NOT NULL)


--4.Crea una tabla llamada categorias con columnas categoria id  y nombre donde categoria id es primary key y el nombre debe ser unico.

CREATE TABLE `sql-project-399618.SQL_Project.categorias2` 
 (
Id_categoria INT64 ,
nombre STRING)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------


------MODIFICAR TABLAS:  ALTER TABLE, DROP TABLE ,RENAME TABLE----------------------



-- 1. Modifica la tabla empleado2 y añade una nueva columna llamada dirección de tipo STRING

ALTER TABLE `sql-project-399618.SQL_Project.empleado2` 
ADD COLUMN direccion STRING


--2. Renombra la tabla cliente 

ALTER TABLE `sql-project-399618.SQL_Project.empleado2` 
RENAME TO empleado


--3.Borra la columna direccion de la tabla de empleado

ALTER TABLE `sql-project-399618.SQL_Project.empleado`
DROP COLUMN direccion


--4. Modifica la tabla pedidos para cambiar el tipo de dato de la columna fecha a fecha.

---BigQuery no permite directamente cambiar el tipo de dato de una columna en una tabla existente.
-- En cambio, debes crear una nueva tabla con el esquema modificado y luego cargar los datos de la tabla original en la nueva tabla:

CREATE OR REPLACE TABLE `sql-project-399618.SQL_Project.pedidos` AS
SELECT
  Id_pedido,
  customer_id,
  CAST(fecha_pedido AS DATE) AS fecha---Estamos utilizando la función CAST para cambiar el tipo de dato de la columna fecha a DATE.
FROM
 `sql-project-399618.SQL_Project.pedidos`


----Si deseas conservar el nombre original de la tabla, puedes eliminar la tabla original y cambiar el nombre de la nueva tabla:

---- Elimina la tabla original
DROP TABLE `sql-project-399618.SQL_Project.pedidos`

-- Cambia el nombre de la nueva tabla a 'pedidos'
ALTER TABLE `sql-project-399618.SQL_Project.pedidos` RENAME TO pedidos;

---------------------------------------------------------------------------------------------------------------------------------------------------------