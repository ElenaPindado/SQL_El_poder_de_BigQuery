# SQL_El_poder_de_BigQuery

# ![image](https://github.com/ElenaPindado/SQL_El_poder_de_BigQuery/assets/123492666/7709dbb4-8e5b-42fa-b07f-6eb60213ed5e)

Descubriendo el poder de BigQuery :  Análisis de Datos Escalable y Eficiente

BigQuery, con su infraestructura en la nube, permite un procesamiento masivo de datos más rápido y eficiente.

# Contenido Repositorio

- Dataset en archivo Excel para la carga en BigQuery.
- Desarrollo de consultas SQL  :
  - Análisis inicial de ventas mediante consultas sencillas utilizando funciones de agregación, filtros, agrupamiento, ordenación y joins.
  - Análisis más profundo mediante consultas más avanzadas utilizando vistas, múltiples joins, subqueries, Ctes, rutinas, window functions y consultas recursivas.

# Contexto

Se ha importado la base de datos de un fichero Excel al entorno de BigQuery: 

**Tablas**  

- Categories
- Customers
- Employees
- Inventory
- Orders_items
- Orders
- Products
- Suppliers

Cada una de estas entidades tiene atributos específicos y se interrelaciona con otras entidades de manera coherente y lógica, mediante un modelo 'Entidad-Relación'.
Por ejemplo, la tabla 'Products' se vincula a la tabla 'Orders_items', lo que nos permite clasificar los productos en pedidos específicos. De manera similar, la tabla 'Customers' se conecta a la tabla 'Orders' estableciendo una relación que refleja la relación entre los clientes y sus pedidos.


# Objetivo

Mediante el uso de consultas SQL, he podido desentrañar información crítica sobre el rendimiento de las ventas, los productos más vendidos y otros KPI esenciales.

Además, he implementado estrategias de optimización para garantizar una ejecución rápida y resultados precisos.

El conjunto de más de 2000 líneas de código SQL se ha estructurado para ofrecer un análisis profundo y una comprensión completa de los datos de ventas, proporcionando información valiosa para la toma de decisiones estratégicas y la mejora del rendimiento empresarial.
