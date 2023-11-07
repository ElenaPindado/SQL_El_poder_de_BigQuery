
   --------------PROYECTO ANÁLISIS DE VENTAS-------------------------
   
  

--------------JOINS AVANZADAS Y SUBQUERIES:SELF JOINS,NON-EQUIJOINS Y CONDICIONES JOINS:EXISTS------------------------------



--1.Escribe una consulta que devuelva todos los pedidos que no tienen ninguna correspondencia en la tabla orders items usando una subquery.


SELECT COUNT(order_id) pedidos_sinitems
FROM `SQL_Project.Orders` o
WHERE o.order_id
NOT IN 
(select oi.order_id
FROM `SQL_Project.Order_items` oi)



--2--Escribe una consulta que devuelva todos los productos con la cantidad vendida para cada producto y las ganancias generadas usando las tablas 'products' y 'orders items'usando una join y una subquery.

WITH ventas AS (
  
SELECT product_id,
SUM(quantity) as cantidad_vendida
FROM `SQL_Project.Order_items`
GROUP BY product_id
)

SELECT p.name as producto,
v.cantidad_vendida,
cantidad_vendida * price as beneficios 
FROM `SQL_Project.Products` p
INNER JOIN ventas v
ON p.product_id=v.product_id


--3--Escribe una consulta que devuelva todos los clientes quienes hicieron un pedido y la fecha de su primer pedido.

with primer_pedido AS(


SELECT customer_id ,
MIN(order_date) as fecha_primer_pedido
FROM `SQL_Project.Orders`
GROUP BY customer_id)

SELECT c.name as cliente,
fecha_primer_pedido
FROM `SQL_Project.Customers`c
INNER JOIN primer_pedido pd
ON c.customer_id=pd.customer_id

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-------------TEMAS AVANZADOS: FUNCIONES -----------------------------



---1.Crea una función llamada 'cálculo-descuento' que tome el total de pedidos como input y devuelva la cantidad descontada en base a unas condiciones específicas.

CREATE OR REPLACE FUNCTION SQL_Project.calculo_descuento(total_pedidos FLOAT64) AS (
  CASE
    WHEN total_pedidos >= 1000 THEN total_pedidos * 0.1 -- 10% de descuento si el total es >= 1000
    WHEN total_pedidos >= 500 THEN total_pedidos * 0.05 -- 5% de descuento si el total es >= 500
    ELSE 0.0 -- Sin descuento si no se cumplen las condiciones anteriores
  END
);

-- Ejemplo de consulta que usa la función
SELECT order_id, total_amount, SQL_Project.calculo_descuento(total_amount) AS descuento---suponiendo que tenemos una columna llamada total_amount
FROM `SQL_Project.Orders`;


-- función para aplicar descuento a los precios del producto:

CREATE OR REPLACE FUNCTION SQL_Project.aplicar_descuento(price FLOAT64, descuento FLOAT64) AS (
  IF(price IS NULL OR descuento IS NULL, NULL, price - (price * descuento))
);

--En esta función, price representa el precio original del producto y descuento es el valor del descuento que deseas aplicar como un número decimal (por ejemplo, 0.1 para un 10% de descuento). La función verifica si price o descuento son nulos y devuelve nulo si cualquiera de ellos es nulo. Luego, calcula el precio con el descuento aplicado y lo devuelve.


-- Ejemplo de consulta que usa la función para aplicar un descuento del 10% a los precios:

SELECT name, price, SQL_Project.aplicar_descuento(price, 0.1) AS precio_con_descuento
FROM `SQL_Project.Products`


----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------- CONSULTAS AVANZADAS: SUBQUERIES Y CONSULTAS ANIDADAS----------------------


--1.Devuelve todos los clientes quienes tienen hecha al menos una compra

WITH pedidos_por_cliente AS 

(SELECT customer_id,
COUNT(order_id) AS pedidos_realizados
FROM `SQL_Project.Orders`
GROUP BY customer_id)---buscamnos los clientes y sus pedidos

SELECT name as cliente-- buscamos los nombres de esos clientes
FROM `SQL_Project.Customers` c
INNER JOIN pedidos_por_cliente pc
ON c.customer_id=pc.customer_id


--2.Encuentra los nombres de los cientes quienes no tienen hecha ninguna compra.


SELECT name AS cliente 
FROM `SQL_Project.Customers`
WHERE customer_id
NOT IN ---buscamos los clientes que no están en la tabla siguiente

(SELECT customer_id
FROM `SQL_Project.Orders`
GROUP BY customer_id)-- vemos que clientes aparecen en la tabla de pedidos



--3.Obtener los detalles del pedido con una cantidad total mayor que la media de la cantidad de pedidos.

WITH 

cantidad_productos AS
 (
SELECT order_id, 
SUM(quantity) AS cantidad
FROM `SQL_Project.Order_items`
GROUP BY order_id),--creamos la tabla temporal que nos agrupe los pedidos y sus cantidades

test AS (
SELECT order_id, cantidad--buscamos que pedido tiene mayor cantidad que la media 
FROM cantidad_productos
WHERE cantidad > 
(
SELECT
AVG(order_id) as media_pedidos----obtenemmos la media de pedidos que tenemos---(es 3)
FROM `SQL_Project.Orders`)

)

SELECT t.order_id as num_pedido,
 product_id as producto ,
 quantity as cantidad
 FROM test t
 INNER JOIN `SQL_Project.Order_items` i
 ON t.order_id=i.order_id


--4.Escribe una consulta que encuentre el top de los 5 clientes con el total más alto de cantidad de pedidos.


SELECT distinct name as cliente,
FROM `SQL_Project.Customers` c
INNER JOIN `SQL_Project.Orders` o
ON c.customer_id=o.customer_id


--5.Devuelve los nombres de los clientes quienes tienen pedidos en los últimos 30 días.


SELECT name as cliente,
order_date as fecha
FROM `SQL_Project.Customers`c
INNER JOIN `SQL_Project.Orders`o
ON c.customer_id=o.customer_id------ SI QUISIERAMOS ACOTAR POR LA FECHA : 
WHERE order_date >= date_sub(current_date, interval 30 DAY)--desde la fecha actual a los 30 días anteriores.



---6.Encuentra los productos que han sido pedidos al menos tres veces.


SELECT name as producto,
o.quantity as cantidad
FROM `SQL_Project.Products` p
INNER JOIN `SQL_Project.Order_items`o
ON p.product_id=o.product_id
WHERE o.quantity >=3



--7.Escribe una consulta para encontrar los clientes quienes tienen pedidos de productos con un precio mayor a 100.


SELECT  c.name as cliente,
p.name as producto_pedido, 
price as precio
FROM `SQL_Project.Products`p
INNER JOIN `SQL_Project.Order_items`i
ON p.product_id=i.product_id
INNER JOIN `SQL_Project.Orders`o
ON i.order_id=o.order_id
INNER JOIN `SQL_Project.Customers`c
ON o.customer_id=c.customer_id
WHERE price >100


--8.Busca el promedio de la cantidad de pedidos para cada cliente.

WITH pedidos_por_cliente AS (

SELECT name as cliente,
COUNT(order_id) as pedidos_realizados
FROM `SQL_Project.Customers`c
INNER JOIN `SQL_Project.Orders`o
ON c.customer_id=o.customer_id
GROUP BY name)

SELECT AVG(pedidos_realizados) AS promedio_pedidos_cliente
FROM pedidos_por_cliente


---9.Encuentra los productos que nunca han sido pedidos.


SELECT name 
FROM `SQL_Project.Products`
WHERE name 
NOT IN (
SELECT name as Producto
FROM `SQL_Project.Products`p
INNER JOIN `SQL_Project.Order_items`o
ON p.product_id=o.product_id)



--10.Devuelve los nombres de los clientes que tienen pedidos los fines de semana (sábados y domingos)

SELECT name AS nombre
FROM `SQL_Project.Customers`c
INNER JOIN `SQL_Project.Orders`o
ON c.customer_id=o.customer_id
WHERE EXTRACT(DAYOFWEEK FROM order_date) IN (1, 7)--esta función devuelve el número del día de la semana (1 para domingo, 2 para lunes y 7 para sábado) y estamos comprobando si es igual a 1 (domingo) o 7 (sábado)



--11.Total de pedidos para cada mes

SELECT EXTRACT(MONTH FROM order_date) AS mes, --agrupamos primero por mes,para después contar los pedidos por mes
COUNT(order_id) AS total_pedidos
FROM `SQL_Project.Orders`
GROUP BY mes
ORDER BY mes



---12.Escribe una consulta que encuentre los clientes quienes tienen pedidos con más de un producto diferente.

SELECT c.name AS cliente,
STRING_AGG(p.name, ', ') AS productos_comprados--- esta fórmula agrega los dos productos en una misma fila separado por coma...

FROM `SQL_Project.Customers` c
INNER JOIN `SQL_Project.Orders` o
ON c.customer_id = o.customer_id
INNER JOIN `SQL_Project.Order_items` i
ON o.order_id = i.order_id
INNER JOIN `SQL_Project.Products` p
ON i.product_id = p.product_id

GROUP BY c.name
HAVING COUNT(DISTINCT p.product_id) > 1--having acota dentro del resultado de agrupación anterior, contando los distintos productos.

----------------------------------------------------------------------------------------------------------------------------------------------------------------------


----------------- JOINS-------------------------------------------------


--1.Devuelve los detalles de los pedidos con sus respectivos nombres de clientes para todos los pedidos.

SELECT c.name AS cliente,
order_date,
p.name as producto,
price as precio,
i.quantity as cantidad
FROM `SQL_Project.Customers` c
INNER JOIN `SQL_Project.Orders` o
ON c.customer_id=o.customer_id
INNER JOIN `SQL_Project.Order_items` i
ON o.order_id=i.order_id
INNER JOIN `SQL_Project.Products`p
ON i.product_id=p.product_id
ORDER BY order_date


--2.Encuentra los productos y sus correspondientes categorias.

SELECT name as producto, 
CASE WHEN name ='Mobile'THEN 'Electronics'
WHEN name='Laptop' THEN 'Electronics'
ELSE 'Accessories'
END AS categoria

FROM `SQL_Project.Products`


--3. Consigue una lista de clientes y sus cantidades total de pedidos.

SELECT name AS cliente,
COUNT(order_id) as pedidos
FROM `SQL_Project.Customers`c
INNER JOIN `SQL_Project.Orders`o
ON c.customer_id=o.customer_id
GROUP BY name


--4.Devuelve los detalles de los pedidos con los nombres de los clientes y productos de cada pedido.

SELECT c.name as cliente,
order_date as fecha ,
i.quantity as cantidad,
price as precio,
p.name as producto
FROM `SQL_Project.Customers`c
INNER JOIN `SQL_Project.Orders`o
ON c.customer_id=o.customer_id
INNER JOIN `SQL_Project.Order_items`i
ON o.order_id=i.order_id
INNER JOIN `SQL_Project.Products`p
ON i.product_id=p.product_id


--5.Encuentra los productos y sus correspondientes nombres de proveedores.


SELECT name as producto,
CASE WHEN name='Laptop' THEN 'Supplier A'
WHEN name='Mobile' THEN 'Supplier B'
ELSE 'Supplier C'
END 
AS proveedor
FROM `SQL_Project.Products`


--6.Consigue una lista de clientes quienes nunca han realizado un pedido.


SELECT name AS cliente
FROM `SQL_Project.Customers` c
LEFT JOIN `SQL_Project.Orders` o
ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL--- hacemos una left join para obtener todos los clientes que están en ambas tablas y los que no estén en order sean nulos--(si no especificamos este dato, nos devolvera todos los clientes.)



--7. Devuelve los nombres de los clientes con el total de productos que han pedido.

SELECT name as cliente,
sum(quantity) AS cantidad_total
FROM `SQL_Project.Customers`c
INNER JOIN `SQL_Project.Orders`o
ON c.customer_id=o.customer_id
INNER JOIN `SQL_Project.Order_items`i
ON o.order_id=i.order_id
GROUP BY name



--8.Consigue el total de pedidos para cada cliente incluidos los que no tienen pedidos.


SELECT c.name AS cliente,
COALESCE(SUM(quantity), 0) AS cantidad  -- COALESCE para reemplazar los valores NULL por 0 en la columna quantity
FROM `SQL_Project.Customers` c
LEFT JOIN `SQL_Project.Orders` o   --utilizaremos una LEFT JOIN para asegurarnos que se incluyan todos los clientes de la tabla clientes aunque no tengan pedidos.
ON c.customer_id = o.customer_id
LEFT JOIN `SQL_Project.Order_items` i
ON o.order_id = i.order_id
GROUP BY c.name


--9.Devuelve los detalles de los pedidos que fueron pedidos por los clientes desde una ciudad especifica.

--como no tenemos ubicación de clientes, en mysql sería así:


SELECT distinct concat(nombre,' ', apellido) as cliente,
ciudad
FROM cliente c
INNER JOIN factura f
ON c.idCliente=f.idCliente
WHERE ciudad='Madrid';


--10.Encuentra los clientes quienes hicieron pedidos de productos con un precio mayor que la media de productos.

with precios as (


SELECT c.name as cliente,
price as precio
from `SQL_Project.Customers`c
INNER JOIN `SQL_Project.Orders`o
ON c.customer_id = o.customer_id
INNER JOIN `SQL_Project.Order_items` i
ON o.order_id=i.order_id
INNER JOIN `SQL_Project.Products`p
ON i.product_id=p.product_id)

SELECT cliente,
precio
FROM  precios
WHERE precio > ( SELECT AVG (price) 
  FROM `SQL_Project.Products`)


---11.Devuelve los nombres de los clientes con el total de pedidos que hicieron.

SELECT name as cliente,
SUM(quantity) as cantidad_total
FROM `SQL_Project.Customers` c
INNER JOIN `SQL_Project.Orders`o
ON c.customer_id=o.customer_id
INNER JOIN `SQL_Project.Order_items`i
ON o.order_id=i.order_id
GROUP BY c.name


--12.Consigue una lista de productos y el total de la cantidad pedida para cada producto.

SELECT p.name as producto,
SUM(o.quantity) as cantidad
FROM `SQL_Project.Products`p
INNER JOIN `SQL_Project.Order_items`o
ON p.product_id=o.product_id
GROUP BY name
ORDER BY cantidad DESC

-------------------------------------------------------------------------------------------------------------------------------------------

------------------ FILTROS AVANZADOS Y ORDENACIÓN----------------------------------


--1.Devuelve todos los empleados cuyo nombre empiece por 'A'

SELECT name as empleado
FROM `SQL_Project.Employees`
WHERE name LIKE 'A%'



--2.Encuentra los productos con nombres que contienen la palabra 'red'

SELECT name as producto
FROM `SQL_Project.Products`
WHERE name LIKE '%red%'


--3.Consigue la lista de empleados y ordenalos por su salario en orden descendente.

SELECT name as empleado,
salary as salario
FROM `SQL_Project.Employees`
ORDER BY salary DESC


--4.Devuelve los clientes con nombres que empiecen por 'A' y finalicen por 'n'

SELECT name as cliente
FROM `SQL_Project.Customers`
WHERE name LIKE 'A%' AND name LIKE '%n'


--5.Encuentra los productos con nombres que contienen al menos un digito.

SELECT name as producto
FROM `SQL_Project.Products`
WHERE name LIKE '%int64%'


SELECT name as producto
FROM `SQL_Project.Products`
WHERE REGEXP_CONTAINS(name, r'[0-9]')-- estamos utilizando REGEXP_CONTAINS para verificar si el nombre del producto contiene al menos un dígito. La expresión regular [0-9] coincide con cualquier dígito del 0 al 9.



--6.Consigue una lista d empleados ordenada por su salario en orden ascendente, valores nulos pueden aparecer al final.

SELECT name as empleado,
salary as salario
FROM `SQL_Project.Employees`
ORDER BY salary


--7.Devuelve los clientes cuyos nombres continen exactamente 10 caracteres.

SELECT name as cliente
FROM `SQL_Project.Customers`
WHERE LENGTH(name) = 10


--8.Encuentra los productos con nombres que empiecen por M y finalicen por e.

SELECT name as producto 
FROM `SQL_Project.Products`
WHERE name like 'M%e'


--9.Consigue una lista de empleados ordenados por su apellido y despues por su nombre.

SELECT name as empleado
FROM `SQL_Project.Employees`
ORDER BY name
------------------------------------
SELECT
  SPLIT(name, ' ')[SAFE_OFFSET(0)] AS nombre,---SPLIT(name, ' ')[SAFE_OFFSET(0)] divide el campo "name" en dos partes utilizando un espacio como delimitador y toma la primera parte, que será el nombre.
  SPLIT(name, ' ')[SAFE_OFFSET(1)] as apellido --divide el campo "name" en dos partes utilizando un espacio como delimitador y toma la segunda parte, que será el apellido.
FROM `SQL_Project.Employees`
ORDER BY nombre


--10.Devuelve los pedidos con una fecha específica y ordénalos por el nombre del cliente en orden alfabético.

SELECT order_id as pedido,
order_date as fecha,
name as cliente
FROM `SQL_Project.Orders`o
INNER JOIN `SQL_Project.Customers` c
ON o.customer_id=c.customer_id
WHERE order_date BETWEEN'2023-05-05' AND '2023-05-20'
ORDER BY name


--11.Encuentra los productos con nombres que contienen exactamente 5 letras.

SELECT name as producto
FROM `SQL_Project.Products`
WHERE  LENGTH(name)= 5


--12.Consigue una lista de empleados ordenados por su salario en orden descendente.Valores nulos deberían aparecer al principio.

SELECT name as empleado,
salary as salario
FROM  `SQL_Project.Employees`
ORDER BY salary DESC


--13.Devuelve los clientes cuyos nombres contienen un espacio.

SELECT name as cliente
FROM `SQL_Project.Customers`
WHERE REGEXP_CONTAINS(name, r'\s')--REGEXP_CONTAINS(name, r'\s') verifica si el campo "name" contiene al menos un espacio en blanco. La expresión regular r'\s' busca cualquier carácter de espacio en blanco.

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------AGREGACIONES Y AGRUPAMIENTO--------------------


--1.Calcula el total de pedidos de cada cliente

SELECT name as cliente,
COUNT(order_id) as total_pedidos
FROM `SQL_Project.Orders`o
INNER JOIN `SQL_Project.Customers`c
ON o.customer_id=c.customer_id
GROUP BY name


--2.Mínimo y máxima cantidad pedida de cada producto.

SELECT name as producto,
min(i.quantity) as cantidad_minima_pedida,
max(i.quantity)as cantidad_maxima
FROM `SQL_Project.Products`p
INNER JOIN `SQL_Project.Order_items`i
ON p.product_id=i.product_id
INNER JOIN `SQL_Project.Orders`O
on i.order_id=o.order_id
GROUP BY name


--3. Calcula el total de la cantidad de cada pedido.

SELECT order_id as pedido,
sum(quantity) as total_cantidad_producto
FROM `SQL_Project.Order_items`
GROUP BY order_id 


--4.Calcula el promedio del precio de cada producto.

SELECT AVG(price) as precio_medio
FROM `SQL_Project.Products`


--5.Encuentra los clientes con el más alto y más bajo número de pedidos.

with pedidos as-- cláusula "WITH" (también conocida como cláusula "CTE" o "Common Table Expression") 
 (
SELECT name as cliente,
COUNT(order_id)as pedidos_total
FROM `SQL_Project.Customers` c
INNER JOIN `SQL_Project.Orders`o
ON c.customer_id=o.customer_id
GROUP BY name),

 cliente_max_pedidos as 
(
SELECT cliente 
FROM pedidos
WHERE pedidos_total = (SELECT MAX(pedidos_total) from pedidos)
),

 cliente_min_pedidos as 
(
SELECT cliente 
FROM pedidos
WHERE pedidos_total = (SELECT MIN(pedidos_total) from pedidos) 
)
 
SELECT cm.cliente AS cliente_maximo_numero_pedidos_realizados, 
       cmin.cliente AS cliente_minimo_numero_pedidos_realizados
FROM cliente_max_pedidos cm
CROSS JOIN cliente_min_pedidos cmin--CROSS JOIN para combinar los resultados de las CTEs cliente_max_pedidos y cliente_min_pedidos

--CROSS JOIN: combina cada fila de la primera tabla con cada fila de la segunda tabla, generando todas las combinaciones posibles entre las filas de ambas tablas. Esto puede resultar en un gran número de filas si las tablas son lo suficientemente grandes.



--6--Calculamos el total de ventas por mes : multiplicando el precio del producto por la cantidad vendida.

with ventas as (

SELECT FORMAT_DATE('%B',order_date) AS mes,--así nos dará el nombre del mes en lugar del número.
--EXTRACT(MONTH FROM order_date) AS mes, --extraemos el mes de la fecha para el número 
price *i.quantity as total_ventas,
FROM `SQL_Project.Products`p
INNER JOIN `SQL_Project.Order_items`i
ON p.product_id=i.product_id
INNER JOIN `SQL_Project.Orders`o
ON i.order_id=o.order_id),

totalventasxmes as(

SELECT mes,
sum(total_ventas) as totalventas
FROM ventas 
GROUP BY mes),

--ahora tenemos que calcular el total de pedidos por mes:

pedidosxmes as (

SELECT FORMAT_DATE('%B',order_date) AS mes,
COUNT(order_id)as total_pedidos
FROM `SQL_Project.Orders`
GROUP BY mes)

SELECT v.mes, p.total_pedidos,v.totalventas
FROM totalventasxmes v
INNER JOIN pedidosxmes p
ON v.mes=p.mes


--7.Encuentra el precio medio y el número de productos de cada proveedor.


with tabla_proveedor as (

SELECT product_id,
name as producto,
price as precio,
CASE WHEN name= 'Mobile' THEN 'Supplier A' 
WHEN name='Laptop' THEN 'Supplier B'
ELSE 'Supplier C' 
END as proveedor
FROM `SQL_Project.Products`)


SELECT proveedor,
AVG(precio) as precio_medio,
COUNT(product_id) as productos_proveedor
FROM tabla_proveedor
GROUP BY proveedor


--8.Consigue el máximo y mínimo precio de cada categoria de producto.


SELECT
CASE WHEN name= 'Mobile' THEN 'Electronics' 
WHEN name='Laptop' THEN 'Electronics'
ELSE 'Accessories' 
END as categoria,
 max(price) as preciomax,
min(price) as preciomin
FROM `SQL_Project.Products`
GROUP BY categoria 

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------- MANIPULACIÓN AVANZADA DE DATOS-------------------------


--1.Actualiza el email de un cliente 

UPDATE `SQL_Project.Customers`
set email='adita@example.com'
WHERE customer_id=1


--2. Borra todos los pedidos de un cliente.

CREATE OR REPLACE TABLE `SQL_Project.Orders`
SELECT *
FROM `SQL_Project.Orders`
WHERE idCliente <> 10-- donde el valor de la columna idCliente no sea igual a 10: esta consulta crea o reemplaza la tabla y elimina todas las filas de la tabla original donde el cliente tiene un ID igual a 10.


--3.Inserta un nuevo producto en la base de datos y asegura la integridad transacional.

INSERT INTO `SQL_Project.Products` (product_id,name, price,quantity) 
VALUES (3,'Screen', 200,25)---No se puede deshacer la operación en BigQuery una vez que se haya completado, como si ocurre en Mysql 



--4.Incrementa el salario de los empleados un 10%.

UPDATE `SQL_Project.Employees`
SET salary = salary * 0.10 --esto lo amplia a toda la tabla , si quisieramos limitarlo : WHERE salary >10000, por ejemplo



--5.Borra todos los pedidos más antiguos de 1 año y sus detalles asociados.

DELETE FROM `SQL_Project.Orders`o
INNER JOIN `SQL_Project.Order_items`  i
ON o.order_id =i.order_id
WHERE TIMESTAMP_DIFF(CURRENT_TIMESTAMP(),order_date, DAY) > 365


--6.Inserta una nueva categoría en la base de datos y actualiza todos los productos de una especifica categoría a la nueva categoría en una transacción simple.

INSERT INTO `SQL_Project.Categories` (category_id, name)
VALUES( 4 , 'otros productos')


--7.Inserta un nuevo cliente en la base de datos al menos con sus pedidos asociados en una transacción simple;

  INSERT INTO `SQL_Project.Customers` (customer_id, name, email)
  VALUES (7, 'surender simalan', 'surender@test.com')

  INSERT INTO `SQL_Project.Order_items` (order_id, customer_id,order_date, status)
  VALUES (6,4,'2023-05-25','pending')


  --8.Incrementa el salario de todos los empleados en un departamento especifico al 15%

UPDATE `SQL_Project.Employees`
SET salary= salary * 1.5
WHERE employee_id= 3 --como no tenemos departamentos lo modificamos a un empleado en concreto.


--9-Borra todos los productos que no tienen pedidos.

DELETE FROM `SQL_Project.Products`
WHERE product_id NOT IN (
SELECT product_id
FROM `SQL_Project.Order_items`)


--10.Inserta un nuevo proveedor en la base de datos al menos con sus productos asociados.

INSERT INTO `SQL_Project.Suppliers`(supplier_id, name)
VALUES (4, 'Supplier D')


UPDATE `SQL_Project.Products`
SET id_supplier= 4
WHERE product_id= 3


--11-Actualiza las fechas de pedidos de todos los pedidos realizados durante el fin de semana al siguiente lunes.

UPDATE `SQL_Project.Orders`
SET order_date = DATE_ADD(order_date, INTERVAL CASE EXTRACT(DAYOFWEEK FROM order_date)-- La función DATE_ADD() se emplea para agregar los días necesarios para llevar los pedidos al siguiente lunes

    WHEN 1 THEN 1  --La función DAYOFWEEK() devuelve el día de la semana para una fecha dada, donde 1 corresponde al domingo y 7 al sábado. 
    WHEN 7 THEN 2--En caso que el dia del pedido sea 1: es decir domingo, pasalo al lunes, si es 7 : osea sabado, pasalo dos dias mas, sino nada.
    ELSE 0
END DAY)
WHERE EXTRACT(DAYOFWEEK FROM order_date) IN (1, 7)--La función EXTRACT() se utiliza para extraer el día de la semana de una fecha determinada.


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



------------ CONCEPTOS AVANZADOS DE UNA BASE DE DATOS:VISTAS Y OPTIMIZACIÓN DE CONSULTAS--------------------


--1.Crea una vista para devolver una lista de productos y sus cantidades en stock.


CREATE VIEW SQL_Project.V_products_stock AS 

SELECT p.product_id, 
name as producto,
available_quantity as stock
FROM `SQL_Project.Products`p
INNER JOIN `SQL_Project.Inventory` i
ON p.product_id=i.product_id


--2.Optimiza una consulta de bajo rendimiento utilizando técnicas de indexación adecuadas


--puedes mejorar el rendimiento en BigQuery utilizando buenas prácticas de diseño de esquemas y particionando y fragmentando tus datos de manera adecuada.



--3.Crea una vista para mostrar las ventas totales de cada producto


CREATE VIEW SQL_Project.V_Ventas_producto AS 

with pedidos as (
SELECT COUNT(o.order_id) as total_pedidos,
p.product_id
FROM `SQL_Project.Products`p
INNER JOIN `SQL_Project.Order_items`o
ON p.product_id=o.product_id
GROUP BY p.product_id)

SELECT pp.product_id,
pp.name as producto,
total_pedidos,
pp.price * p.total_pedidos as ventas_totales_euros
FROM pedidos p
INNER JOIN `SQL_Project.Products` pp
ON p.product_id=pp.product_id


--4.Optimiza una consulta que devuelva los detalles de los pedidos de un cliente especídico,ordenados por fecha en orden descendente.


---**Para optimizar una consulta que devuelve los detalles de los pedidos de un cliente específico ordenados por fecha en orden descendente, se pueden seguir algunos pasos clave:

--*Asegúrate de tener un índice en la columna que representa el cliente para acelerar la búsqueda.
--*Utiliza la cláusula "ORDER BY" para ordenar los resultados por fecha en orden descendente.
--*Limita la cantidad de datos devueltos en la consulta a lo estrictamente necesario.


SELECT c.name as cliente,
order_date as fecha,
p.name as producto, 
i.quantity as cantidad,
status
FROM `SQL_Project.Order_items` i
INNER JOIN `SQL_Project.Orders`o
ON i.order_id=o.order_id
INNER JOIN `SQL_Project.Customers` c
ON o.customer_id=c.customer_id
INNER JOIN `SQL_Project.Products`p
ON i.product_id=p.product_id
WHERE c.customer_id=1
ORDER BY order_date DESC

---si quisieramos ver en una misma fila los productos pedidos agrupando por fecha, en lugar de ver varias filas una para cada pedido:

SELECT c.name as cliente,
order_date as fecha,
STRING_AGG(p.name, ', ') as productos_pedidos--Esto  proporciona el resultado con los nombres de los productos concatenados en una sola celda, separados por comas.
FROM `SQL_Project.Order_items` i
INNER JOIN `SQL_Project.Orders`o
ON i.order_id=o.order_id
INNER JOIN `SQL_Project.Customers` c
ON o.customer_id=c.customer_id
INNER JOIN `SQL_Project.Products`p
ON i.product_id=p.product_id
WHERE c.customer_id=1
GROUP BY c.name, order_date
ORDER BY order_date DESC



--5. Crea una vista para devolver la media del precio y el número de pedidos de cada producto.


CREATE VIEW SQL_Project.V_Productos_info AS

with media_pedidos as(

SELECT p.name as producto,
avg(i.quantity) as media_pedidos_realizados
FROM `SQL_Project.Order_items` i
INNER JOIN `SQL_Project.Products`p
ON i.product_id=p.product_id
group by  name),


media_precios as(

SELECT p.name as producto,
avg(o.quantity*price) as precio_medio_pedidos
FROM `SQL_Project.Order_items`o
INNER JOIN `SQL_Project.Products`p
ON o.product_id=p.product_id
GROUP BY  name)


SELECT p.producto,
media_pedidos_realizados,
precio_medio_pedidos
FROM media_pedidos p
INNER JOIN media_precios pp
ON p.producto=pp.producto


--6. Optimiza una consulta que devuelva los 2 clientes con más pedidos.

with pedidos as (


SELECT c.customer_id,
COUNT(o.order_id) AS total_pedidos
FROM `SQL_Project.Customers`c
INNER JOIN `SQL_Project.Orders` o 
ON c.customer_id = o.customer_id
GROUP BY c.customer_id
LIMIT 2)

SELECT name as cliente, 
total_pedidos
FROM `SQL_Project.Customers` c
INNER JOIN pedidos p
ON c.customer_id=p.customer_id


--7.Optimiza una consulta que devuelva una lista de productos con sus respectivas categorias , filtrando por una categoria específica.

with categorias as(
SELECT name as producto,
CASE WHEN name='Mobile'THEN 'Electronics'
WHEN name= 'Laptop' THEN 'Electronics'
ELSE 'Accessories'
END AS categoria
FROM `SQL_Project.Products`  )



SELECT producto
FROM categorias
WHERE categoria = 'Electronics' 


--8.Crea una vista que devuelva el total de pedidos de cada cliente.

CREATE VIEW SQL_Project.V_pedidos as 

with pedidos as (

SELECT c.customer_id,
count(order_id) as total_pedidos
FROM `SQL_Project.Customers`c
INNER JOIN `SQL_Project.Orders`o
ON c.customer_id=o.customer_id
GROUP BY customer_id)

SELECT name as cliente,
total_pedidos
FROM `SQL_Project.Customers`c
INNER JOIN pedidos p
ON c.customer_id=p.customer_id

-------------------------------------------------------------------------------------------------------------------------------------------------------



---------------------FUNCIONES AVANZADAS :funciones---------------------------------------


#1. . Calcula el total de ventas de cada producto usando una función

--calculamos las ventas de cada producto, para ver como ejecutar la función:
SELECT product_id,
sum(quantity) as cantidad_pedida
FROM `SQL_Project.Order_items`
GROUP BY product_id


--creamos la función con esa consulta:
CREATE OR REPLACE FUNCTION SQL_Project.calcularPedidosPorProducto(product_id int64) AS (

(SELECT count(order_id)
FROM `SQL_Project.Order_items`
WHERE product_id=product_id
)
);

SELECT  SQL_Project.calcularPedidosPorProducto(1) AS cantidad_pedida

--------------------------------------------------------------

CREATE OR REPLACE  FUNCTION SQL_Project.calcular_ventas_productos(product_id INT64)
RETURNS ARRAY<STRUCT<product_id INT64, total_ventas INT64>>
AS ((
  SELECT ARRAY_AGG(STRUCT(product_id, total_ventas)) as ventas
  FROM (
    SELECT product_id, SUM(quantity) as total_ventas
    FROM SQL_Project.Order_items
    WHERE product_id = product_id
    GROUP BY product_id
  )
));

SELECT *
FROM SQL_Project.calcular_ventas_productos(1);



--2.Recupera los 3 mejores clientes según el total de sus pedidos y calcula el porcentaje de cada monto de pedido del cliente en comparación con el total.

----recuperamos los 3 mejores clientes
with pedidostotales as(

SELECT c.customer_id, 
c.name, 
count(o.order_id) AS pedidos
FROM `SQL_Project.Customers`c
INNER JOIN `SQL_Project.Orders`o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY pedidos DESC
LIMIT 3)

--calculamos ahora el porcentaje
SELECT customer_id, 
name as cliente,
pedidos,
ROUND(pedidos / (SELECT SUM(pedidos) FROM pedidostotales) * 100,2) AS porcentaje_del_total-- ROUND con 2 como segundo argumento redondea el resultado a 2 decimales después del punto decimal para obtener un resultado más legible y manejable.
--dividimos el total de pedidos por cliente entre la suma de todos los pedidos 
FROM pedidostotales



--3.Calcula el precio medio para cada producto y asigna un rango basado en la utilizando una función

SELECT product_id,
  AVG(price) AS precio_medio,
  RANK() OVER (ORDER BY AVG(price) DESC) AS price_rank--RANK() OVER (ORDER BY AVG(price) DESC) Utiliza la función RANK para asignar un rango basado en la calificación promedio en orden descendente. Esto significa que los productos con las calificaciones promedio más altas tendrán un rango más bajo.
FROM `SQL_Project.Products`
GROUP BY product_id
ORDER BY precio_medio DESC


--4.Devuelve el top de productos y sus ventas acumuladas usando una función

SELECT 
  o.product_id,
  p.name,
  COUNT(order_id) as total_pedidos,
  SUM(o.quantity) as  cantidad_vendida,
  RANK() OVER (ORDER BY SUM(o.quantity) DESC) AS product_rank------Una función de ventana (window function) como: rank(), over(), ROW_NUMBER()... es una función analítica avanzada que opera en un conjunto de filas relacionadas en una consulta. A diferencia de las funciones de agregación que calculan un solo valor para un conjunto de filas, las funciones de ventana devuelven un valor para cada fila individual.
  
FROM 
  `SQL_Project.Products` p
INNER JOIN 
  `SQL_Project.Order_items` o ON p.product_id = o.product_id
GROUP BY 1, 2
ORDER BY cantidad_vendida DESC;


--5. Calcula el promedio de precio de cada producto por categoría y asigna un ranking 


SELECT AVG(price) as precio_medio,
 c.name as categoria ,
 RANK() OVER (ORDER BY AVG(price) DESC ) AS ranking
 FROM `SQL_Project.Products`, ---producto cartesiano ya que no tenemos ids para unir estas tablas.
 `SQL_Project.Categories`c

 GROUP BY categoria 



--6.Devuelve el top de los 3 empleados en ventas con una función de ventana( window function): rank() over(), row_number()

--como no podemos unir empleados con pedidos en mysql:

SELECT RANK() OVER ( ORDER BY (COUNT(idFactura)) DESC) AS ranking_ventas,
CONCAT(nombre, ' ' ,apellido) as empleado,
COUNT(idFactura) as ventas 
FROM empleado e
INNER JOIN factura f
ON e.idEmpleado=f.idEmpleado
GROUP BY e.idEmpleado
limit 3 ;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------



------------- CONCEPTOS AVANZADOS : DATA MODELING Y NORMALIZACIÓN-----------------------------



--1.Escribe una consulta recursiva para encontrar todos los empleados y sus subordinados en una organizacion.


-- una consulta recursiva se puede usar para realizar operaciones jerárquicas, como la búsqueda de todos los empleados y sus subordinados en una organización con una estructura jerárquica. A continuación se muestra un ejemplo básico de cómo se podría escribir esta consulta en SQL utilizando un esquema de tabla simple para empleados.


--Supongamos que tenemos una tabla llamada "employees" con las siguientes columnas: employee_id, name y manager_id: el ejemplo de cómo podríamos realizar una consulta recursiva para obtener todos los empleados y sus subordinados:

--En resumen, la cláusula WITH se utiliza para definir expresiones comunes simples, mientras que WITH RECURSIVE amplía esa capacidad al permitir que una expresión común se refiera a sí misma, lo que resulta en una consulta recursiva.


WITH RECURSIVE Subordinates AS ( --WITH RECURSIVE establece el CTE (Common Table Expression) recursivo

    SELECT employee_id, 
    name, 
    manager_id, 
    0 as level
    FROM `SQL_Project.Employees`
    WHERE manager_id IS NULL --La parte no recursiva de la consulta selecciona los empleados principales (aquellos que no tienen gerente, manager_id es NULL).
    
    UNION ALL --La parte recursiva de la consulta se une con la expresión CTE "Subordinates" para encontrar los subordinados de los empleados en cada iteración.

    SELECT e.employee_id, e.name, e.manager_id, s.level + 1
    FROM `SQL_Project.Employees` e
    INNER JOIN Subordinates s 
    ON e.manager_id = s.employee_id
)

SELECT *
FROM Subordinates




---Ejemplo de BigQuery:

WITH RECURSIVE CTE_1 AS (
    (SELECT 1 AS iteration UNION ALL SELECT 1 AS iteration)
    UNION ALL
    SELECT iteration + 1 AS iteration FROM CTE_1 WHERE iteration < 3
  )
SELECT iteration FROM CTE_1
ORDER BY 1 ASC

---Esto da como resultado:

/*-----------*
 | iteration |
 +-----------+
 | 1         |
 | 1         |
 | 2         |
 | 2         |
 | 3         |
 | 3         |
 *-----------*/


--En el ejemplo anterior, la CTE recurrente contiene los siguientes componentes:

--Nombre de la CTE recurrente: CTE_1
--Término base: SELECT 1 AS iteration
--Operador de unión: UNION ALL
--Término recurrente: SELECT iteration + 1 AS iteration FROM CTE_1 WHERE iteration < 3




--2.Usa SQL avanzado para pivotar una tabla dada y transforma filas en columnas.


SELECT customer_id,
       COUNTIF(order_date = '2023-05-01') AS total_orders_20230501,--la función COUNTIF cuenta todas las filas de pedidos de esa fecha en concreto.
       COUNTIF(order_date = '2023-05-05') AS total_orders_20230505,
       COUNTIF(order_date = '2023-05-10') AS total_orders_20230510,
       COUNTIF(order_date = '2023-05-15') AS total_orders_20230515,
       COUNTIF(order_date = '2023-05-20') AS total_orders_20230520--***la función COUNTIF no exiset en MySql.
FROM `SQL_Project.Orders`
GROUP BY customer_id

-- Este enfoque simula el efecto de PIVOT utilizando funciones condicionales como COUNTIF en combinación con la instrucción GROUP BY.

--En BigQuery, no se puede utilizar la función PIVOT directamente. En su lugar, se puede usar una combinación de agregaciones condicionales y CASE para lograr un efecto similar al de PIVOT. 
--Ejemplo:


SELECT
  category_id,
  MAX(CASE WHEN name = 'Electronics' THEN Valor END) AS Categoria1,
  MAX(CASE WHEN name = 'Accessories' THEN Valor END) AS Categoria2,
  MAX(CASE WHEN name = 'Office Supplies' THEN Valor END) AS Categoria3
 
FROM
  `SQL_Project.Employees`
GROUP BY
  category_id




--3. Escribe una consulta recursiva para encontrar todas las dependencias de la tabla empleados con sus jefes, en su estructura jerárquica.


WITH RECURSIVE EmployeeHierarchy AS ( --En esta consulta, EmployeeHierarchy es el nombre de la tabla recursiva común, y la consulta obtiene el employee_id, manager_id y el nivel jerárquico para cada empleado.
  SELECT employee_id, manager_id, 1 AS level
  FROM employees
  WHERE manager_id IS NULL

  UNION ALL

  SELECT e.employee_id, e.manager_id, eh.level + 1
  FROM employees e
  JOIN EmployeeHierarchy eh ON e.manager_id = eh.employee_id
)
SELECT *
FROM EmployeeHierarchy




--4- Usa técnicas avanzadas de SQL para despivotar una tabla y transformar columnas en filas.


--Para despivotar una tabla y transformar columnas en filas, se pueden utilizar diversas técnicas, como la función UNION ALL y CASE.


SELECT ID, 'Categoria1' AS Categoria, Categoria1 AS Valor FROM TablaDatos
UNION ALL
SELECT ID, 'Categoria2' AS Categoria, Categoria2 AS Valor FROM TablaDatos
UNION ALL
SELECT ID, 'Categoria3' AS Categoria, Categoria3 AS Valor FROM TablaDatos


--Esto combinará las filas de la tabla original en una nueva tabla donde las columnas Categoria1, Categoria2 y Categoria3 se transformarán en una sola columna Categoria, y sus valores correspondientes se mostrarán en la columna Valor.


SELECT product_id,
  'name' AS attribute,
  name AS value
FROM `SQL_Project.Products`
UNION ALL --Esta consulta toma la tabla "products" y la convierte en filas utilizando la función UNION ALL. 
SELECT product_id,
  'price' AS attribute,
  CAST(price AS STRING) AS value --La función CAST se utiliza para convertir un valor de un tipo de datos a otro
FROM `SQL_Project.Products`
UNION ALL 
 SELECT product_id,
  'quantity' AS attribute,
  CAST(quantity AS STRING) AS value
FROM `SQL_Project.Products`

--ESTA TABLA DARÁ COMO RESULTADO EL TOTAL DE FILAS DE LA TABLA PRINCIPAL TANTAS VECES SE HAYA UNIDO, EN ESTE CASO 15



--5. Escribe una consulta recursiva para encontrar todas las categorías y sus subcategorías


WITH RECURSIVE CategoriasRecursivas AS (
  SELECT id, nombre, categoria_padre
  FROM Categorias
  WHERE categoria_padre IS NULL -- Seleccionar las categorías principales

  UNION ALL

  SELECT c.id, c.nombre, c.categoria_padre
  FROM Categorias c
  JOIN CategoriasRecursivas cr ON c.categoria_padre = cr.id
)
SELECT *
FROM CategoriasRecursivas --En este ejemplo, asumimos que la tabla Categorias tiene una estructura que incluye una columna id, una columna nombre y una columna categoria_padre que apunta al id de la categoría superior. Esta consulta recursiva recuperará todas las categorías y sus subcategorías de la tabla Categorias. 


--6.Escribe una consulta que utiliza una cross join entre dos tablas.

SELECT *
FROM tabla1
CROSS JOIN tabla2-- CROSS JOIN combina cada fila de la primera tabla con cada fila de la segunda tabla, lo que resulta en un conjunto de resultados que es el producto cartesiano de ambas tablas.


--Ejemplo:  

SELECT * FROM `SQL_Project.Products`
CROSS JOIN `SQL_Project.Orders` ---como cada tabla tiene 5 filas el resultado sera 25 filas, 5 *5 y 8 columnas,4 de cada tabla


--Sería lo mismo que poner la coma con dos tablas.
SELECT *FROM `SQL_Project.Products`,`SQL_Project.Orders`

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



----------------OPTIMIZACIÓN DE RENDIMIENTO -----------------------



--1.Optimiza una consulta que devuelva los detalles de los pedidos con sus compras para un rango específico.


SELECT o.order_id as num_pedido,
COUNT(o.order_id) as total_productos,
SUM(i.quantity) as cantidad_pedida
FROM `SQL_Project.Orders`o
INNER JOIN `SQL_Project.Order_items`i
ON o.order_id=i.order_id
WHERE order_date BETWEEN '2023-05-01' AND '2023-05-15'
GROUP BY o.order_id


--2.Identifica y elimina uniones innecesarias en una consulta que devuelve los detalles del producto y su respectivas categorias.


SELECT o.order_id as num_pedido,
COUNT(o.order_id) as total_productos,
CASE WHEN name = 'Laptop' THEN 'Electronics' 
     WHEN name= 'Mobile' THEN 'Electronics'
     ELSE 'Accessories'
     END as categoria,
SUM(i.quantity) as cantidad_pedida,
SUM(p.price*i.quantity) as ventas 
FROM `SQL_Project.Orders`o
INNER JOIN `SQL_Project.Order_items`i
ON o.order_id=i.order_id
INNER JOIN `SQL_Project.Products`p
ON i.product_id=p.product_id
GROUP BY o.order_id,3


--3.Reescribe una subquery como una join en una query que devuelva los detalles de los pedidos y los clientes.


SELECT
name as cliente,
COUNT(o.order_id) as total_productos,
SUM(i.quantity) as cantidad_pedida
FROM `SQL_Project.Orders`o
INNER JOIN `SQL_Project.Order_items`i
ON o.order_id=i.order_id
INNER JOIN `SQL_Project.Customers`c
ON c.customer_id=o.customer_id
GROUP BY 1

-- Ejemplo genérico:

SELECT *
FROM `SQL_Project.Orders`
WHERE customer_id IN (SELECT customer_id FROM Customers WHERE country = 'USA')----aquí tenemos una subconsulta

---ahora trasnfirmamos esa consulta en una join:
SELECT o.*
FROM `SQL_Project.Orders`   o
JOIN `SQL_Project.Customers`  c 
ON o.customer_id = c.customer_id
WHERE c.country = 'USA';


--4. Reescribe una subconsulta como una join en una consulta que devuelve los nombres de los clientes quienes tienen al menos dos pedidos.

WITH total_pedidos as (

SELECT c.name as cliente,
COUNT(order_id) as pedidos
FROM `SQL_Project.Customers` c
INNER JOIN `SQL_Project.Orders`o
ON c.customer_id=o.customer_id
GROUP BY 1)

SELECT cliente, pedidos FROM total_pedidos
WHERE pedidos >=2


--Otra forma de hacerlo:

SELECT c.name as cliente,
COUNT(order_id) as total_pedidos
FROM `SQL_Project.Customers` c
INNER JOIN `SQL_Project.Orders` o
ON c.customer_id=o.customer_id
GROUP BY c.name
HAVING COUNT(order_id) >= 2 --having nos reagrupa dentro del grupo que ya hemos creado.



--5.Optimiza una consulta que calcule el total de ventas de cada mes.


SELECT EXTRACT ( MONTH FROM order_date) as mes,
COUNT(o.order_id) as total_pedidos,
SUM(i.quantity) as total_cantidad_pedida,
SUM(i.quantity*p.price) as total_ventas
FROM `SQL_Project.Orders`o
INNER JOIN `SQL_Project.Order_items` i
ON o.order_id=i.order_id
INNER JOIN `SQL_Project.Products`p
ON i.product_id=p.product_id
GROUP BY 1;


--Para obtener el nombre del mes:

SELECT CONCAT(
  CASE EXTRACT(MONTH from order_date)
      WHEN 1 THEN 'Enero'
      WHEN 2 THEN 'Febrero'
      WHEN 3 THEN 'Marzo'
      WHEN 4 THEN 'Abril'
      WHEN 5 THEN 'Mayo'
      WHEN 6 THEN 'Junio'
      WHEN 7 THEN 'Julio'
      WHEN 8 THEN 'Agosto'
      WHEN 9 THEN 'Septiembre'
      WHEN 10 THEN 'Octubre'
      WHEN 11 THEN 'Noviembre'
      WHEN 12 THEN 'Diciembre'
  END,' ',
  EXTRACT(YEAR from order_date)) AS fecha,
  COUNT(o.order_id) as total_pedidos,
SUM(i.quantity) as total_cantidad_pedida,
SUM(i.quantity*p.price) as total_ventas
FROM `SQL_Project.Orders`o
INNER JOIN `SQL_Project.Order_items` i
ON o.order_id=i.order_id
INNER JOIN `SQL_Project.Products`p
ON i.product_id=p.product_id
GROUP BY 1


--6.Identifica y elimina innecesarias joins en una consulta que devuelve los detalles de los productos y sus proveedores.


SELECT p.name,
CASE WHEN name='Mobile' THEN 'Supplier A' 
WHEN name='Laptop' THEN 'Supplier B' 
ELSE 'Supplier C'  
END as proveedor
FROM `SQL_Project.Products`p



--7.Rescribe una subconsulta como una join que devuelva los nombres de los clientes quienes tienen pedidos de los últimos 30 días.

SELECT c.name as cliente,
order_date as fecha
FROM `SQL_Project.Customers` c
INNER JOIN `SQL_Project.Orders`o
ON c.customer_id=o.customer_id
WHERE order_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)--CURRENT_DATE() devuelve la fecha actual y DATE_SUB resta 30 días de la fecha actual, 


--8.Optimiza una consulta que devuelva el top de los 5 productos con mayor ventas.

SELECT name as producto,
SUM(i.quantity*p.price) as total_ventas
FROM `SQL_Project.Products`p
INNER JOIN `SQL_Project.Order_items`i
ON p.product_id=i.product_id
INNER JOIN `SQL_Project.Orders`o
ON i.order_id=o.order_id
GROUP BY 1
ORDER BY 1 desc
---------------------------------------------------------------------------------------------------------------------------------------------------------


----------- TÉCNICAS AVANZADAS DE SQL------------------------


--1.Escribe una consulta recursiva para encontrar todos los empleados y sus subordinados en una jeraquía.


WITH RECURSIVE EmployeeHierarchy AS (
  SELECT employee_id, manager_id, employee_name
  FROM employees
  WHERE manager_id IS NULL --La primera parte de la consulta selecciona los empleados que no tienen un manager_id, 
  
  UNION ALL
  
  SELECT e.employee_id, e.manager_id, e.employee_name
  FROM employees e
  JOIN EmployeeHierarchy eh ON e.manager_id = eh.employee_id--la segunda parte de la consulta se une a la tabla recursiva para seleccionar los subordinados de cada empleado.
)

SELECT * FROM EmployeeHierarchy



--2.Usa una cte para calcular el total de ventas de cada producto.


WITH ventas AS ( --En esta consulta, primero creamos una CTE que calcula el total de ventas para cada producto sumando el precio multiplicado por la cantidad vendida. 

  SELECT p.product_id,
  SUM(price * o.quantity) AS total_ventas
  FROM `SQL_Project.Products`p
  INNER JOIN `SQL_Project.Order_items`o
  ON p.product_id=o.product_id
  GROUP BY 1
  ORDER BY 2 DESC
)

SELECT p.product_id, p.name, v.total_ventas-- --Luego, unimos esta CTE con la tabla de productos para obtener el total de ventas de cada producto.
FROM `SQL_Project.Products`p
INNER JOIN ventas v
ON p.product_id=v.product_id



--3.Aplica una window function para calcular los promedios de los precios de ventas de producto.

WITH ventas AS (
  SELECT p.product_id,
  SUM(price * o.quantity) AS total_ventas
  FROM `SQL_Project.Products`p
  INNER JOIN `SQL_Project.Order_items`o
  ON p.product_id=o.product_id
  GROUP BY 1
  ORDER BY 2 DESC
),

tabla_final as(

SELECT p.product_id, p.name, v.total_ventas
FROM `SQL_Project.Products`p
INNER JOIN ventas v
ON p.product_id=v.product_id)


SELECT 
  p.product_id,
  p.name,
  p.price,
  total_ventas,
  total_ventas / COUNT(order_id) AS precio_medio_venta
FROM `SQL_Project.Products`p
INNER JOIN tabla_final t
ON p.product_id=t.product_id
INNER JOIN `SQL_Project.Order_items`o
ON t.product_id=o.product_id
GROUP BY 1,2,3,4


--4.Escribe una consulta recursiva para encontrar las categorias y sus subcategoria en una tabla jerárquica.


WITH RECURSIVE CTE AS (--WITH RECURSIVE se utiliza para definir el CTE,
  SELECT id, nombre, categoria_padre, CAST(nombre AS STRING) AS ruta
  FROM dataset.categoria
  WHERE categoria_padre IS NULL
  UNION ALL--UNION ALL se usa para realizar la consulta recursiva
  SELECT c.id, c.nombre, c.categoria_padre, CONCAT(cte.ruta, ' > ', c.nombre)
  FROM dataset.categoria c
  JOIN CTE ON c.categoria_padre = cte.id
)
SELECT * FROM CTE


--5 Usa una cte para calcular el total de pedidos por cada cliente.

WITH pedidos AS (

  SELECT customer_id, 
  COUNT(order_id) as pedidos
  FROM `SQL_Project.Orders`
  GROUP BY customer_id
)

SELECT p.customer_id, 
c.name as cliente,
pedidos
FROM `SQL_Project.Customers`c
INNER JOIN pedidos p
ON c.customer_id=p.customer_id


--6.Aplica una window function para calcular la media de precio y el maximo precio de cada categoria.

WITH categorias as (

 SELECT name as producto,
 CASE WHEN name='Mobile' THEN 'Electronics' 
 WHEN name='Laptop' THEN 'Electronics'
 ELSE 'Accessories'
 END as categoria
FROM `SQL_Project.Products`
)

SELECT categoria,
MAX(price) as maximo_precio,
AVG(price) as precio_medio
FROM `SQL_Project.Products`p
INNER JOIN categorias c
ON p.name=c.producto
GROUP BY categoria;


--Ejemplo con OVER()--FUNCIÓN DE VENTANA

SELECT 
  product_id,
  name,
  price,
  AVG(price) OVER (PARTITION BY product_id) AS media_precio,--OVER se utiliza para aplicar estas funciones a particiones de datos definidas por idProducto. 
  MAX(price) OVER (PARTITION BY product_id) AS max_precio 
FROM `SQL_Project.Products`


-- utilizando una función de ventana , necesitas utilizar la cláusula OVER()

WITH categorias as (
  SELECT name as producto,
  CASE 
    WHEN name='Mobile' THEN 'Electronics' 
    WHEN name='Laptop' THEN 'Electronics'
    ELSE 'Accessories'
  END as categoria
  FROM `SQL_Project.Products`
)

SELECT DISTINCT categoria,--es necesario usar distinct para solo obtener las categorias distintas.
  MAX(price) OVER (PARTITION BY categoria) as maximo_precio,---con over ya le estoy diciendo que me lo agrupe por categoría, no siendo necesario usar GROUP BY
  AVG(price) OVER (PARTITION BY categoria) as precio_medio
FROM `SQL_Project.Products` p
INNER JOIN categorias c
  ON p.name = c.producto;



--7.Escribe una consulta recursiva para encontrar todos los empleados y sus jefes directos en una tabla jeráquica.


WITH RECURSIVE employee_hierarchies AS (
  SELECT employee_id, name, manager_id, 0 as depth
  FROM `SQL_Project.Employees`
  WHERE manager_id IS NULL -- Encuentra el empleado superior o de nivel superior

  UNION ALL

  SELECT e.employee_id, e.name, e.manager_id, eh.depth + 1
  FROM `SQL_Project.Employees` e
  JOIN employee_hierarchies eh ON e.manager_id = eh.employee_id
)
SELECT * FROM employee_hierarchies;



--8.Usa un cte para calcular el acumulado de la suma de las cantidades de cada producto.

WITH stock as(

SELECT p.product_id,
name as producto,
p.quantity as cantidad_stock,
COALESCE (SUM(i.quantity),0) as cantidad_pedida
FROM `SQL_Project.Products`p
LEFT JOIN `SQL_Project.Order_items`i
ON p.product_id=i.product_id
GROUP BY 1,2,3
)

SELECT product_id,
producto,
cantidad_stock as stock_inicial,
cantidad_pedida as cantidad_vendida,
(cantidad_stock - cantidad_pedida) as stock
FROM stock


--9.Aplica una window function para calcular el mínimo y el máximo de las cantidades pedidas de cada mes.

with ventas as(

  SELECT EXTRACT( MONTH FROM order_date) as mes,
 COUNT(order_id) as pedidos
  FROM `SQL_Project.Orders`
  GROUP BY order_date)

  SELECT distinct mes,
  SUM(pedidos) as total_pedidos
FROM ventas
GROUP BY 1---Aquí estamos calculando el total de pedidos 


---Aplicando over()

SELECT DISTINCT EXTRACT(MONTH FROM order_date) as mes,
       MIN(quantity) OVER(PARTITION BY EXTRACT(MONTH FROM order_date)) as minimo_cantidad_pedida,--aquí calculamos las cantidades pedidas
       MAX(quantity) OVER(PARTITION BY EXTRACT(MONTH FROM order_date)) as maximo_cantidad_pedida
FROM `SQL_Project.Orders`o
INNER JOIN `SQL_Project.Order_items`i
ON o.order_id=i.order_id



--10.Escribe una consulta recursiva para encontrar todos los empleados anteriores de un empleado específico en una tabla jerárquica.

WITH RECURSIVE EmployeeHierarchy AS (
    SELECT employee_id, name, manager_id
    FROM Employees
    WHERE employee_id = <ID del empleado específico>

    UNION ALL

    SELECT e.employee_id, e.name, e.manager_id
    FROM Employees e
    JOIN EmployeeHierarchy eh ON e.employee_id = eh.manager_id
)

SELECT *
FROM EmployeeHierarchy;



--11.Aplica una función de ventana para calcular el ranking de ventas de cada producto.

--función rank()

WITH ventas AS(

SELECT p.product_id,
  p.name as producto,
  SUM(i.quantity) as cantidad_vendida
FROM `SQL_Project.Products`P
INNER JOIN `SQL_Project.Order_items`i
ON p.product_id=i.product_id
GROUP BY 1,2)


SELECT product_id,
producto,
RANK() OVER (ORDER BY cantidad_vendida DESC) as sales_rank
FROM ventas


--12.Escribe una consulta recursiva para encontrar todas los empleados que estén bajo un manager .


WITH RECURSIVE EmployeeUnderManager AS (

  SELECT * FROM `SQL_Project.Employees`
   WHERE manager_id = 'manager_id_value'-- "manager_id_value" es el valor específico del ID del gerente para el que deseas encontrar todos los empleados bajo él.

  UNION ALL

  SELECT e.* FROM `SQL_Project.Employees` e
  JOIN EmployeeUnderManager em ON e.manager_id = em.employee_id
)
SELECT * FROM EmployeeUnderManager;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
